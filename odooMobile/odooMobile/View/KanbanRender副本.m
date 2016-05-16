//
//  KanbanRender.m
//

#import "KanbanRender.h"
#import "GDataXMLNode.h"
#import "UIWebView+TS_JavaScriptContext.h"
#import "Preferences.h"
#import "JSON.h"

//#define RESOURCE_PATH       (@"/Users/lei.qiao/Desktop/LeiQiao/odoo-mobile/odooMobile")
#define RESOURCE_PATH       (@"/Users/LeiQiao/Desktop/odoo-mobile/odooMobile")

typedef void (^UpdateCallback)(WKWebView* webView, NSInteger index);

@implementation KanbanRender {
    ViewModeData* _viewMode;
    NSMutableArray* _recordImages;
    
    WKWebView* _renderWebView;
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

-(void) renderNext:(NSInteger)index
{
}

#pragma mark
#pragma mark init & dealloc

-(instancetype) initWithViewMode:(ViewModeData*)viewMode
{
    if( self = [super init] )
    {
        _viewMode = viewMode;
        
        _renderWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _renderWebView.backgroundColor = [UIColor clearColor];
        _renderWebView.navigationDelegate = (id<WKNavigationDelegate>)self;
        _renderWebView.backgroundColor = [UIColor clearColor];
        
        // 添加加载完成的监听
        [_renderWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
        _recordImages = [NSMutableArray new];
    }
    return self;
}

-(void) dealloc
{
    [_renderWebView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
}

-(void) updateWithWidth:(CGFloat)width callback:(void(^)(WKWebView*, NSInteger))callback
{
    _updateCallback = callback;
    
    [_recordImages removeAllObjects];
    [self startRenderNext:0];
    
    for( NSInteger i=0; i<_viewMode.records.count; i++ )
    {
        if( i < _recordWebviews.count )
        {
            WKWebView* webView = [_recordWebviews objectAtIndex:i];
            webView.frame = CGRectMake(0, 0, width, 1);
            [webView reload];
        }
        else
        {
            
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
            [_recordWebviews addObject:webView];
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
    WKWebView* webView = [_recordWebviews objectAtIndex:index];
    return webView.bounds.size.height;
}

-(WKWebView*) recordWebView:(NSUInteger)index
{
    WKWebView* webView = [_recordWebviews objectAtIndex:index];
    return webView;
}

#pragma mark
#pragma mark UIWebViewDelegate

-(void) webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation
{
}

-(void) observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if( ![keyPath isEqualToString:@"estimatedProgress"] ) return;
    
    WKWebView* webView = (WKWebView*)object;
    NSInteger index = [_recordWebviews indexOfObject:webView];
    if( index >= _recordWebviews.count ) return;
    
    NSLog(@"estimatedProgress changed");
    [webView evaluateJavaScript:@"document.height;" completionHandler:^(NSNumber* height, NSError* error) {
        CGRect newFrame = webView.frame;
        if( newFrame.size.height == [height floatValue] ) return;
        
        newFrame.size.height = [height floatValue];
        webView.frame = newFrame;
        
        [webView evaluateJavaScript:@"document.documentElement.outerHTML;"
                  completionHandler:^(NSString* fileContent, NSError* error) {
                      NSString* fileName = [NSString stringWithFormat:@"%@/debug/%@.%03d.html", RESOURCE_PATH, _viewMode.ID, (int)index];
                      [fileContent writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
                  }];

        
        if( _updateCallback )
        {
            _updateCallback(webView, index);
        }
    }];
//        CGFloat newHeight = webView.scrollView.contentSize.height;
//        CGRect newFrame = webView.frame;
//        
//        if( newFrame.size.height == newHeight ) return;
//        
//        newFrame.size.height = webView.scrollView.contentSize.height;
//        webView.frame = newFrame;
//        
//        if( _updateCallback )
//        {
//            _updateCallback(webView, i);
//        }
}

@end
