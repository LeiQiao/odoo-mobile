//
//  KanbanRender.m
//

#import "KanbanRender.h"
#import "GDataXMLNode.h"
#import "UIWebView+TS_JavaScriptContext.h"
#import "Preferences.h"
#import <WebKit/WebKit.h>
#import "JSON.h"

//#define RESOURCE_PATH       (@"/Users/lei.qiao/Desktop/LeiQiao/odoo-mobile/odooMobile")
#define RESOURCE_PATH       (@"/Users/LeiQiao/Desktop/odoo-mobile/odooMobile")

typedef void (^KanbanRenderCallback)();
static NSMutableArray* sKanbanRenderHolder;

@implementation KanbanRender {
    WKWebView* _renderWebView;
    NSString* _recordJSONString;
    
    KanbanRenderCallback _kanbanRenderCallback;
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
                fieldValue = [NSString stringWithFormat:@"%.02f", [fieldValue floatValue]];
                break;
            }
            case FieldTypeInteger:
            {
                fieldValue = [fieldValue stringValue];
                break;
            }
            case FieldTypeRelatedToField:
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

-(NSString*) getHTMLContext:(ViewModeData*)viewMode
{
    GDataXMLDocument* xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:viewMode.htmlContext
                                                                   options:0
                                                                     error:nil];
    if( !xmlDoc ) return @"";
    
    NSArray* kanbanChildren = [[xmlDoc rootElement] nodesForXPath:@"/kanban/templates/*" error:nil];
    if( kanbanChildren.count == 0 ) return @"";
    
    GDataXMLElement* kanbanElement = [GDataXMLElement elementWithName:@"div"];
    
    for( GDataXMLElement* child in kanbanChildren )
    {
        [kanbanElement addChild:child];
    }
    
    return [kanbanElement XMLString];
}

-(UIImage*) renderToImage
{
    CGSize imageSize = _renderWebView.frame.size;
    imageSize.width *= 2;
    imageSize.height *= 2;
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat scalingFactor = 2;
    CGContextScaleCTM(context, scalingFactor,scalingFactor);
    
    [_renderWebView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString* filePath = [NSString stringWithFormat:@"%@/debug/%d.png", RESOURCE_PATH, rand()%100];
    [UIImagePNGRepresentation(thumbImage) writeToFile:filePath atomically:YES];
    return thumbImage;
}

-(void) debug:(ViewModeData*)viewMode index:(NSUInteger)index
{
    NSString* filePath = [NSString stringWithFormat:@"%@/debug/%@.%03u.html", RESOURCE_PATH, viewMode.ID, (unsigned)index];
    
    [_renderWebView evaluateJavaScript:@"document.documentElement.outerHTML;"
                     completionHandler:^(NSString* fileContent, NSError* error) {
                         [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                         return;
                     }];
}

#pragma mark
#pragma mark init & dealloc

+(void) renderViewMode:(ViewModeData*)viewMode
        forRecordIndex:(NSUInteger)recordIndex
             withWidth:(CGFloat)width
              callback:(void(^)(UIImage*))callback
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sKanbanRenderHolder = [NSMutableArray new];
    });
    
    KanbanRender* render = [[KanbanRender alloc] initWithViewMode:viewMode
                                                   forRecordIndex:recordIndex
                                                        withWidth:width
                                                         callback:callback];
    [sKanbanRenderHolder addObject:render];
}

-(instancetype) initWithViewMode:(ViewModeData*)viewMode
                  forRecordIndex:(NSUInteger)recordIndex
                       withWidth:(CGFloat)width
                        callback:(void(^)(UIImage*))callback
{
    if( self = [super init] )
    {
        _kanbanRenderCallback = callback;
        
        _renderWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
        _renderWebView.navigationDelegate = (id<WKNavigationDelegate>)self;
        _renderWebView.backgroundColor = [UIColor clearColor];
        
        _recordJSONString = [self warpRecordToJSString:[viewMode.records objectAtIndex:recordIndex] viewMode:viewMode];
        
        // 添加该视图的css样式及js代码
        NSString* cssFilePath = [NSString stringWithFormat:@"%@/odooMobile/kanban.css", RESOURCE_PATH];
        NSString* jsFilePath = [NSString stringWithFormat:@"%@/odooMobile/kanban.js", RESOURCE_PATH];
        
//        cssFilePath = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"css"];
//        jsFilePath = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"js"];
        
        NSString* htmlString = [self getHTMLContext:viewMode];
        
        htmlString = [NSString stringWithFormat:
                      @"<html>\n"
                      @"    <head>\n"
                      @"        <link href=\"file://%@\" rel=\"stylesheet\"></link>"
                      @"        <script src=\"file://%@\" type=\"text/javascript\"></script>"
                      @"    </head>\n"
                      @"    <body>\n"
                      @"        %@\n"
                      @"    </body>\n"
                      @"</html>", cssFilePath, jsFilePath, htmlString];
        
        [_renderWebView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
    }
    return self;
}

#pragma mark
#pragma mark UIWebViewDelegate

-(void) webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation
{
    NSString* javaScriptString = [NSString stringWithFormat:@"setRecordValue(\"%@\");", _recordJSONString];
    [_renderWebView evaluateJavaScript:javaScriptString completionHandler:^(NSNumber* height, NSError* error) {
        _renderWebView.frame = CGRectMake(0, 0, _renderWebView.frame.size.width, [height floatValue]);
        [self debug:nil index:0];
        [self renderToImage];
        [sKanbanRenderHolder removeObject:self];
    }];
}

@end
