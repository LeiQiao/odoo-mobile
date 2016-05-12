//
//  KanbanRender.m
//

#import "KanbanRender.h"
#import "GDataXMLNode.h"
#import "UIWebView+TS_JavaScriptContext.h"
#import "Preferences.h"
#import <WebKit/WebKit.h>
#import "JSON.h"

#define RESOURCE_PATH       (@"/Users/lei.qiao/Desktop/LeiQiao/odoo-mobile/odooMobile")

typedef void (^ReadyCallback)();

@implementation KanbanRender {
    ViewModeData* _viewMode;
    WKWebView* _renderWebView;
    JSContext* _jsContext;
    
    ReadyCallback _readyCallback;
}

#pragma mark
#pragma mark helper

-(NSDictionary*) warpRecordToJSContext:(NSDictionary*)record
{
    NSMutableDictionary* jsRecord = [NSMutableDictionary new];
    for( NSString* fieldName in record.allKeys )
    {
        FieldData* field = [_viewMode fieldForName:fieldName];
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
    
    return jsRecord;
}

-(NSString*) getHTMLContext
{
    GDataXMLDocument* xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:_viewMode.htmlContext
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

-(void) debug:(NSUInteger)index
{
    NSString* filePath = [NSString stringWithFormat:@"%@/debug/%@.%03u.html", RESOURCE_PATH, _viewMode.ID, (unsigned)index];
    
    [_renderWebView evaluateJavaScript:@"document.documentElement.outerHTML;"
                     completionHandler:^(NSString* fileContent, NSError* error) {
                         [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                         return;
                     }];
}

#pragma mark
#pragma mark init & dealloc

-(instancetype) initWithViewMode:(ViewModeData*)viewMode readyCallback:(void(^)())readyCallback
{
    if( self = [super init] )
    {
        _readyCallback = readyCallback;
        
        _viewMode = viewMode;
        
        // 清楚cookie及缓存
        NSHTTPCookieStorage* storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie* cookie in [storage cookies]){[storage deleteCookie:cookie];}
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        _renderWebView = [[WKWebView alloc] init];
        _renderWebView.navigationDelegate = (id<WKNavigationDelegate>)self;
        _renderWebView.backgroundColor = [UIColor clearColor];
        
        // 添加该视图的css样式及js代码
        NSString* cssFilePath = [NSString stringWithFormat:@"%@/odooMobile/kanban.css", RESOURCE_PATH];
        NSString* jsFilePath = [NSString stringWithFormat:@"%@/odooMobile/kanban.js", RESOURCE_PATH];
        
        NSString* htmlString = [self getHTMLContext];
        
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
        
        [_renderWebView loadHTMLString:htmlString baseURL:nil];
    }
    return self;
}

-(UIImage*) renderRecord:(NSUInteger)index withWidth:(CGFloat)width
{
    _renderWebView.frame = CGRectMake(0, 0, width, 1);
    
    NSDictionary* record = [_viewMode.records objectAtIndex:index];
    record = [self warpRecordToJSContext:record];
    NSString* javaScriptString = [@[[record JSONString]] JSONString];
    javaScriptString = [javaScriptString substringWithRange:[javaScriptString rangeOfString:@"\\{[\\w|\\W]*\\}" options:NSRegularExpressionSearch]];
    javaScriptString = [NSString stringWithFormat:@"abc();"];
    [_renderWebView evaluateJavaScript:javaScriptString completionHandler:^(NSNumber* height, NSError* error) {
        _renderWebView.frame = CGRectMake(0, 0, width, [height floatValue]);
        [self debug:index];
        [self renderToImage];
    }];
    return [self renderToImage];
}

#pragma mark
#pragma mark UIWebViewDelegate

-(void) webView:(UIWebView*)webView didCreateJavaScriptContext:(JSContext*)context
{
    context.exceptionHandler = ^(JSContext* context, JSValue* exception) {
        NSLog(@"%@", exception);
        context.exception = exception;
    };
    
    context[@"nslog"] = ^(NSString* logMessage) {
        NSLog(@"***** JSLog: %@", logMessage);
    };
    
    context[@"_s"] = gPreferences.ServerName;
    context[@"record"] = [JSValue valueWithObject:nil inContext:context];
}

-(void) webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation
{
    if( _readyCallback )
    {
        _readyCallback();
    }
}

@end
