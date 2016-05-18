//
//  KanbanRender.m
//

#import "KanbanRender.h"
#import "GDataXMLNode.h"
#import "Preferences.h"
#import "JSON.h"

//#define RESOURCE_PATH       (@"/Users/lei.qiao/Desktop/LeiQiao/odoo-mobile/odooMobile")
#define RESOURCE_PATH       (@"/Users/LeiQiao/Desktop/odoo-mobile/odooMobile")

const NSString* const sKanbanRenderWebViewKey = @"WebView";             /*!< WebView的Key */
const NSString* const sKanbanRenderFinishedLoadKey = @"FinishedLoad";   /*!< 加载完成的Key */
const NSString* const sKanbanRenderUpdatedKey = @"Updated";             /*!< 更新完成的Key */

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 定义更新回调的方法
 */
typedef void (^UpdateCallback)();

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 看板样式的渲染器
 */
@implementation KanbanRender {
    ViewModeData* _viewMode;            /*!< 显示模式 */
    NSMutableArray* _recordWebviews;    /*!< 所有记录的数组 */
    
    UpdateCallback _updateCallback;     /*!< 更新结束的回调 */
}

#pragma mark
#pragma mark helper

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 将记录转换成字符串，以供js调用
 *  @param record   要转换的记录
 *  @param viewMode 显示模式
 *  @return 转换后的字符串
 */
-(NSString*) warpRecordToJSString:(NSDictionary*)record viewMode:(ViewModeData*)viewMode
{
    /*---------- 遍历记录中所有字段 ----------*/
    NSMutableDictionary* jsRecord = [NSMutableDictionary new];
    for( NSString* fieldName in record.allKeys )
    {
        /*---------- 根据字段类型设置不同样式的值 ----------*/
        FieldData* field = [viewMode fieldForName:fieldName];
        id fieldValue = [record objectForKey:fieldName];
        switch( field.type )
        {
            // 字符型
            case FieldTypeChar:
            case FieldTypeText:
            {
                if( ![fieldValue isKindOfClass:[NSString class]] )
                {
                    fieldValue = @"";
                }
                break;
            }
            // 选择型
            case FieldTypeSelection:
            {
                if( ![fieldValue isKindOfClass:[NSString class]] )
                {
                    fieldValue = @"";
                }
                break;
            }
            // 二进制型
            case FieldTypeBinary:
            {
                if( [fieldValue isKindOfClass:[NSString class]] )
                {
                    fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                }
                else
                {
                    fieldValue = @"";
                }
                break;
            }
            // 数字型
            case FieldTypeDouble:
            case FieldTypeInteger:
            {
                fieldValue = fieldValue;
                break;
            }
            // 布尔型
            case FieldTypeBoolean:
            {
                fieldValue = fieldValue;
                break;
            }
            // One2Many关联型
            case FieldTypeRelatedToField:
            {
                if( (![fieldValue isKindOfClass:[NSArray class]]) ||
                   (((NSArray*)fieldValue).count == 0) )
                {
                    fieldValue = @"";
                }
                else if( ((NSArray*)fieldValue).count == 1 )
                {
                    fieldValue = [[fieldValue objectAtIndex:0] stringValue];
                }
                break;
            }
            // Many2One关联型
            case FieldTypeRelatedToModel:
            {
                if( (![fieldValue isKindOfClass:[NSArray class]]) ||
                   (((NSArray*)fieldValue).count == 0) )
                {
                    fieldValue = @"";
                }
                else if( ((NSArray*)fieldValue).count == 1 )
                {
                    fieldValue = [[fieldValue objectAtIndex:0] stringValue];
                }
                else if( ((NSArray*)fieldValue).count > 1 )
                {
                    fieldValue = [fieldValue objectAtIndex:1];
                }
                break;
            }
            // 未知类型
            case FieldTypeUnknown:
            default:
            {
                if( (![fieldValue isKindOfClass:[NSString class]]) &&
                   (![fieldValue isKindOfClass:[NSNumber class]]) )
                {
                    fieldValue = [NSString stringWithFormat:@"Unknown field type: (%d)", field.type];
                }
                break;
            }
        }
        jsRecord[fieldName] = @{@"value":fieldValue,@"raw_value":fieldValue};
    }
    
    // 字典转换成JSON字串,由JS来解析JSON字串
    // 因为JSON字串需要再进行转移才能用到其他子串串中，所以这里用了一个巧妙的方法：
    // 将JSON字串加入到一个队列中，并再转换成JSON子串["{....}"]，并将之前的JSON字串抠出来
    NSString* javaScriptString = [@[[jsRecord JSONString]] JSONString];
    NSRange rangeJSContext = [javaScriptString rangeOfString:@"\\{[\\w|\\W]*\\}" options:NSRegularExpressionSearch];
    javaScriptString = [javaScriptString substringWithRange:rangeJSContext];
    
    return javaScriptString;
}

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 遍历所有子节点，将<node/>转换成<node></node>，以免在WebView中解析错误
 *  @param element 要转换的节点
 */
-(void) setNoEmptyElement:(GDataXMLElement*)element
{
    if( element.kind != GDataXMLElementKind ) return;
    
    // 如果子节点为空，则设置节点内容为空白串
    if( element.childCount == 0 )
    {
        element.stringValue = @" ";
    }
    
    // 遍历所有子节点，继续转换
    for( id subElement in element.children )
    {
        [self setNoEmptyElement:subElement];
    }
}

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 获取记录的模版内容
 *  @param viewMode 显示模式
 *  @return 显示模式的模版内容
 */
-(NSString*) getHTMLContext:(ViewModeData*)viewMode
{
    /*---------- 从看板模版中获取节点 ----------*/
    GDataXMLDocument* xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:viewMode.htmlContext
                                                                   options:0
                                                                     error:nil];
    if( !xmlDoc ) return @"";
    
    NSArray* kanbanChildren = [[xmlDoc rootElement] nodesForXPath:@"/kanban/templates/*" error:nil];
    if( kanbanChildren.count == 0 ) return @"";
    
    /*---------- 将节点放置到单独div节点中，并设置节点的样式 ----------*/
    GDataXMLElement* kanbanElement = [GDataXMLElement elementWithName:@"div"];
    [kanbanElement addAttribute:[GDataXMLElement elementWithName:@"class" stringValue:@"o_kanban_record"]];
    
    for( GDataXMLElement* child in kanbanChildren )
    {
        [kanbanElement addChild:child];
    }
    
    /*---------- 遍历所有子节点，将<node/>转换成<node></node>，否则WebView会解析错误 ----------*/
    [self setNoEmptyElement:kanbanElement];
    
    // 返回节点的HTML信息
    return [kanbanElement XMLString];
}

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 更新下一条记录的高度
 *  @param indexNumber 更新的记录索引
 */
-(void) updateNext:(NSNumber*)indexNumber
{
    NSUInteger index = [indexNumber unsignedIntegerValue];
    
    /*--------- 如果更新记录的索引大于所有记录，则通知回调更新结束 ----------*/
    if( index >= _recordWebviews.count )
    {
        if( (index == _recordWebviews.count) && _updateCallback )
        {
            _updateCallback();
        }
        return;
    }
    
    /*---------- 获取记录窗口的实际高度 ----------*/
    NSMutableDictionary* item = [_recordWebviews objectAtIndex:index];
    WKWebView* webView = item[sKanbanRenderWebViewKey];
    [webView evaluateJavaScript:@"document.height;" completionHandler:^(NSNumber* height, NSError* error) {
        // 更新高度
        CGRect newFrame = webView.frame;
        if( newFrame.size.height != [height floatValue] )
        {
            newFrame.size.height = [height floatValue];
            webView.frame = newFrame;
            
            item[sKanbanRenderUpdatedKey] = @(YES);
            
            [self debug:index];
        }
        
        // 更新下一条记录的高度
        [self performSelector:@selector(updateNext:) withObject:@(index+1) afterDelay:0.0];
    }];
}

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 开启调试，将网页内容及网页截屏保存到本地
 *  @param index 记录的索引
 */
-(void) debug:(NSUInteger)index
{
    NSMutableDictionary* item = [_recordWebviews objectAtIndex:index];
    WKWebView* webView = item[sKanbanRenderWebViewKey];
    
    /*---------- 获取记录的内容 ----------*/
    [webView evaluateJavaScript:@"document.documentElement.outerHTML;"
              completionHandler:^(NSString* fileContent, NSError* error) {
                  /*---------- HTML内容 ----------*/
                  NSString* fileName = [NSString stringWithFormat:@"%@/debug/%@.%03d.html", RESOURCE_PATH, _viewMode.ID, (int)index];
                  [fileContent writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
                  
                  /*---------- 截屏 ----------*/
                  UIGraphicsBeginImageContextWithOptions(webView.frame.size, YES, 0);
                  [webView drawViewHierarchyInRect:webView.frame afterScreenUpdates:YES];
                  UIImage* uiImage = UIGraphicsGetImageFromCurrentImageContext();
                  UIGraphicsEndImageContext();
                  NSData* imageData = UIImagePNGRepresentation(uiImage);
                  [imageData writeToFile:[NSString stringWithFormat:@"%@/debug/%@.%03d.png", RESOURCE_PATH, _viewMode.ID, (int)index]
                              atomically:YES];
              }];
}

#pragma mark
#pragma mark init & dealloc

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 使用窗口显示模式初始化渲染器
 *  @param viewMode 窗口显示模式
 *  @return 新建的渲染器
 */
-(instancetype) initWithViewMode:(ViewModeData*)viewMode
{
    if( self = [super init] )
    {
        _viewMode = viewMode;
        
        _recordWebviews = [NSMutableArray new];
    }
    return self;
}

#pragma mark
#pragma mark member functions

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 更新记录，重新设置记录窗口的内容
 *  @param width    记录窗口的宽度
 *  @param callback 更新完毕后的回调
 */
-(void) updateWithWidth:(CGFloat)width callback:(void(^)())callback
{
    // 设置更新回调
    _updateCallback = callback;
    
    for( NSInteger i=0; i<_viewMode.records.count; i++ )
    {
        // 如果该记录的窗口存在，则直接更新
        if( i < _recordWebviews.count )
        {
            // 重置记录标志位
            NSMutableDictionary* item = _recordWebviews[i];
            item[sKanbanRenderFinishedLoadKey] = @(NO);
            item[sKanbanRenderUpdatedKey] = @(NO);
            
            // 重置记录窗体的高度
            WKWebView* webView = item[sKanbanRenderWebViewKey];
            webView.frame = CGRectMake(0, 0, width, 1);
            [webView reload];
        }
        else
        {
            // 新建记录窗体
            WKWebView* webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
            
            // 添加进索引
            NSMutableDictionary* item = [NSMutableDictionary new];
            item[sKanbanRenderWebViewKey] = webView;
            item[sKanbanRenderFinishedLoadKey] = @(NO);
            item[sKanbanRenderUpdatedKey] = @(NO);
            [_recordWebviews addObject:item];
            
            // 初始化记录窗体
            webView.scrollView.scrollEnabled = NO;
            webView.scrollView.userInteractionEnabled = NO;
            webView.backgroundColor = [UIColor clearColor];
            webView.navigationDelegate = (id<WKNavigationDelegate>)self;
            webView.backgroundColor = [UIColor clearColor];
            
            // 添加该视图的css样式及js代码
            NSString* cssFilePath = [NSString stringWithFormat:@"%@/odooMobile/kanban.css", RESOURCE_PATH];
            NSString* jsFilePath = [NSString stringWithFormat:@"%@/odooMobile/kanban.js", RESOURCE_PATH];
            NSString* faFilePath = [NSString stringWithFormat:@"%@/odooMobile/font-awesome.css", RESOURCE_PATH];
            
            cssFilePath = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"css"];
            jsFilePath = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"js"];
            faFilePath = [[NSBundle mainBundle] pathForResource:@"font-awesome" ofType:@"css"];
            
            // 根据显示模式获取记录窗口的模版
            NSString* htmlString = [self getHTMLContext:_viewMode];
            
            // 获取纪录内容
            NSString* recordJSONString = [self warpRecordToJSString:[_viewMode.records objectAtIndex:i]
                                                           viewMode:_viewMode];
            NSString* recordScript = [NSString stringWithFormat:@"setRecordValue(\"%@\");", recordJSONString];
            
            // 生成记录的内容信息
            htmlString = [NSString stringWithFormat:
                          @"<html>\n"
                          @"    <head>\n"
                          @"        <link href=\"file://%@\" rel=\"stylesheet\"></link>"
                          @"        <link href=\"file://%@\" rel=\"stylesheet\"></link>"
                          @"        <script src=\"file://%@\" type=\"text/javascript\"></script>"
                          @"        <meta name=\"viewport\" content=\"initial-scale=1.0\" />"
                          @"    </head>\n"
                          @"    <body>\n"
                          @"        %@\n"
                          @"    </body>\n"
                          @"    <script>%@</script>"
                          @"</html>", cssFilePath, faFilePath, jsFilePath, htmlString, recordScript];
            
            // 加载完整的记录内容
            [webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
        }
    }
    
    // 删除上次更新过后多余的记录
    for( NSInteger i=_recordWebviews.count-1; i >= _viewMode.records.count; i-- )
    {
        WKWebView* webView = [_recordWebviews objectAtIndex:i];
        [webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
        [_recordWebviews removeObjectAtIndex:i];
    }
}

#pragma mark - for UITableView

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 获取记录的个数
 *  @return 返回记录的个数
 */
-(NSUInteger) recordCount
{
    return _recordWebviews.count;
}

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 获取某条记录窗口的高度
 *  @param index 记录的索引
 *  @return 某条记录窗口的高度
 */
-(CGFloat) recordHeight:(NSUInteger)index
{
    NSMutableDictionary* item = [_recordWebviews objectAtIndex:index];
    WKWebView* webView = item[sKanbanRenderWebViewKey];
    return webView.bounds.size.height;
}

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 获取记录的窗口
 *  @param index 记录的索引
 *  @return 记录的窗口
 */
-(WKWebView*) recordWebView:(NSUInteger)index
{
    NSMutableDictionary* item = [_recordWebviews objectAtIndex:index];
    WKWebView* webView = item[sKanbanRenderWebViewKey];
    return webView;
}

#pragma mark
#pragma mark UIWebViewDelegate

-(void) webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation
{
    /*---------- 设置加载完成标志 ----------*/
    for( NSMutableDictionary* item in _recordWebviews )
    {
        if( [item objectForKey:sKanbanRenderWebViewKey] == webView )
        {
            item[sKanbanRenderFinishedLoadKey] = @(YES);
            break;
        }
    }
    
    /*---------- 检查是否全部加载完成 ----------*/
    for( NSDictionary* item in _recordWebviews )
    {
        if( ![[item objectForKey:sKanbanRenderFinishedLoadKey] boolValue] )
        {
            return;
        }
    }
    
    /*---------- 全部加载完成后开始更新记录窗口的高度 ----------*/
    [self updateNext:0];
}

@end
