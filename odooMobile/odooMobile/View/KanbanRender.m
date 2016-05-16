//
//  KanbanRender.m
//

#import "KanbanRender.h"
#import "GDataXMLNode.h"
#import "UIWebView+TS_JavaScriptContext.h"
#import "Preferences.h"
#import "JSON.h"

#define RESOURCE_PATH       (@"/Users/lei.qiao/Desktop/LeiQiao/odoo-mobile/odooMobile")
//#define RESOURCE_PATH       (@"/Users/LeiQiao/Desktop/odoo-mobile/odooMobile")

const NSString* const sKanbanRenderWebViewKey = @"WebView";
const NSString* const sKanbanRenderFinishedLoadKey = @"FinishedLoad";
const NSString* const sKanbanRenderUpdatedKey = @"Updated";

typedef void (^UpdateCallback)();

@implementation KanbanRender {
    ViewModeData* _viewMode;
    NSMutableArray* _recordWebviews;
    
    UpdateCallback _updateCallback;
}

#pragma mark
#pragma mark helper

-(NSString*) warpRecordToJSString:(NSDictionary*)record viewMode:(ViewModeData*)viewMode
{
    NSMutableDictionary* jsRecord = [NSMutableDictionary new];
    for( NSString* fieldName in record.allKeys )
    {
        FieldData* field = [viewMode fieldForName:fieldName];
        id fieldValue = [record objectForKey:fieldName];
        switch( field.type )
        {
            case FieldTypeChar:
            case FieldTypeText:
            {
                if( ![fieldValue isKindOfClass:[NSString class]] )
                {
                    fieldValue = @"";
                }
                break;
            }
            case FieldTypeSelection:
            {
                if( ![fieldValue isKindOfClass:[NSString class]] )
                {
                    fieldValue = @"";
                }
                break;
            }
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
            case FieldTypeDouble:
            {
                fieldValue = fieldValue;
                break;
            }
            case FieldTypeInteger:
            {
                fieldValue = fieldValue;
                break;
            }
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
            case FieldTypeBoolean:
            {
                fieldValue = fieldValue;
                break;
            }
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
    
    NSString* javaScriptString = [@[[jsRecord JSONString]] JSONString];
    NSRange rangeJSContext = [javaScriptString rangeOfString:@"\\{[\\w|\\W]*\\}" options:NSRegularExpressionSearch];
    javaScriptString = [javaScriptString substringWithRange:rangeJSContext];
    
    return javaScriptString;
}

-(void) setNoEmptyElement:(GDataXMLElement*)element
{
    if( element.kind != GDataXMLElementKind ) return;
    
    if( element.childCount == 0 )
    {
        element.stringValue = @" ";
    }
    
    for( id subElement in element.children )
    {
        [self setNoEmptyElement:subElement];
    }
}

-(NSString*) getHTMLContext:(ViewModeData*)viewMode
{
    GDataXMLDocument* xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:viewMode.htmlContext
                                                                   options:0
                                                                     error:nil];
    if( !xmlDoc ) return @"";
    
    NSArray* kanbanChildren = [[xmlDoc rootElement] nodesForXPath:@"/kanban/templates/*" error:nil];
    if( kanbanChildren.count == 0 ) return @"";
    
    GDataXMLElement* kanbanElement = [GDataXMLElement elementWithName:@"div"];
    [kanbanElement addAttribute:[GDataXMLElement elementWithName:@"class" stringValue:@"o_kanban_record"]];
    
    for( GDataXMLElement* child in kanbanChildren )
    {
        [kanbanElement addChild:child];
    }
    
    [self setNoEmptyElement:kanbanElement];
    
    return [kanbanElement XMLString];
}

-(void) finishedLoad:(WKWebView*)webView
{
    for( NSMutableDictionary* item in _recordWebviews )
    {
        if( [item objectForKey:sKanbanRenderWebViewKey] == webView )
        {
            item[sKanbanRenderFinishedLoadKey] = @(YES);
            break;
        }
    }
    
    for( NSDictionary* item in _recordWebviews )
    {
        if( ![[item objectForKey:sKanbanRenderFinishedLoadKey] boolValue] )
        {
            return;
        }
    }
    
    [self updateNext:0];
}

-(void) updateNext:(NSNumber*)indexNumber
{
    NSUInteger index = [indexNumber unsignedIntegerValue];
    if( index >= _recordWebviews.count )
    {
        if( (index == _recordWebviews.count) && _updateCallback )
        {
            _updateCallback();
        }
        return;
    }
    
    NSMutableDictionary* item = [_recordWebviews objectAtIndex:index];
    WKWebView* webView = item[sKanbanRenderWebViewKey];
    [webView evaluateJavaScript:@"document.height;" completionHandler:^(NSNumber* height, NSError* error) {
        
        CGRect newFrame = webView.frame;
        if( newFrame.size.height != [height floatValue] )
        {
            newFrame.size.height = [height floatValue];
            webView.frame = newFrame;
            
            item[sKanbanRenderUpdatedKey] = @(YES);
            
            [self debug:index];
        }
        
        [self performSelector:@selector(updateNext:) withObject:@(index+1) afterDelay:0.0];
    }];
}

-(void) debug:(NSUInteger)index
{
    NSMutableDictionary* item = [_recordWebviews objectAtIndex:index];
    WKWebView* webView = item[sKanbanRenderWebViewKey];
    
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

-(instancetype) initWithViewMode:(ViewModeData*)viewMode
{
    if( self = [super init] )
    {
        _viewMode = viewMode;
        
        _recordWebviews = [NSMutableArray new];
    }
    return self;
}

-(void) updateWithWidth:(CGFloat)width callback:(void(^)())callback
{
    _updateCallback = callback;
    
    for( NSInteger i=0; i<_viewMode.records.count; i++ )
    {
        if( i < _recordWebviews.count )
        {
            NSMutableDictionary* item = _recordWebviews[i];
            item[sKanbanRenderFinishedLoadKey] = @(NO);
            item[sKanbanRenderUpdatedKey] = @(NO);
            
            WKWebView* webView = item[sKanbanRenderWebViewKey];
            webView.frame = CGRectMake(0, 0, width, 1);
            [webView reload];
        }
        else
        {
            WKWebView* webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
            
            NSMutableDictionary* item = [NSMutableDictionary new];
            item[sKanbanRenderWebViewKey] = webView;
            item[sKanbanRenderFinishedLoadKey] = @(NO);
            item[sKanbanRenderUpdatedKey] = @(NO);
            [_recordWebviews addObject:item];
            
            webView.scrollView.scrollEnabled = NO;
            webView.scrollView.userInteractionEnabled = NO;
            webView.backgroundColor = [UIColor clearColor];
            webView.navigationDelegate = (id<WKNavigationDelegate>)self;
            webView.backgroundColor = [UIColor clearColor];
            
            // 添加该视图的css样式及js代码
            NSString* cssFilePath = [NSString stringWithFormat:@"%@/odooMobile/kanban.css", RESOURCE_PATH];
            NSString* jsFilePath = [NSString stringWithFormat:@"%@/odooMobile/kanban.js", RESOURCE_PATH];
            NSString* faFilePath = [NSString stringWithFormat:@"%@/odooMobile/font-awesome.css", RESOURCE_PATH];
            
//            cssFilePath = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"css"];
//            jsFilePath = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"js"];
//            faFilePath = [[NSBundle mainBundle] pathForResource:@"font-awesome" ofType:@"css"];
            
            NSString* htmlString = [self getHTMLContext:_viewMode];
            
            // 设置纪录内容
            NSString* recordJSONString = [self warpRecordToJSString:[_viewMode.records objectAtIndex:i]
                                                           viewMode:_viewMode];
            NSString* recordScript = [NSString stringWithFormat:@"setRecordValue(\"%@\");", recordJSONString];
            
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
            
            [webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
        }
    }
    
    for( NSInteger i=_recordWebviews.count-1; i >= _viewMode.records.count; i-- )
    {
        WKWebView* webView = [_recordWebviews objectAtIndex:i];
        [webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
        [_recordWebviews removeObjectAtIndex:i];
    }
}

-(NSUInteger) recordCount
{
    return _recordWebviews.count;
}

-(CGFloat) recordHeight:(NSUInteger)index
{
    NSMutableDictionary* item = [_recordWebviews objectAtIndex:index];
    WKWebView* webView = item[sKanbanRenderWebViewKey];
    return webView.bounds.size.height;
}

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
    [self finishedLoad:webView];
}

@end
