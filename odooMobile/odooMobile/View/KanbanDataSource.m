//
//  KanbanDataSource.m
//

#import "KanbanDataSource.h"
#import "GDataXMLNode.h"
#import "UIWebView+TS_JavaScriptContext.h"

NSString* const kKanbanCellIdentifier = @"kKanbanCellIdentifier";   /*!< 看板项重用标示 */

@implementation KanbanDataSource {
    NSMutableArray* _recordWebViews;
}

-(NSString*) fieldValue:(NSString*)fieldName withRecord:(NSDictionary*)record
{
    FieldData* field = [_viewMode fieldForName:fieldName];
    id fieldValue = [record objectForKey:fieldName];
    switch( field.type )
    {
        case FieldTypeChar:
        case FieldTypeText:
        case FieldTypeSelection:
        {
            if( ![fieldValue isKindOfClass:[NSString class]] ) return @"";
            return fieldValue;
        }
        case FieldTypeBinary:
        {
            if( ![fieldValue isKindOfClass:[NSString class]] ) return @"";
            return [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        }
        case FieldTypeDouble:
        {
            return [NSString stringWithFormat:@"%.02f", [fieldValue floatValue]];
        }
        case FieldTypeInteger:
        {
            return [fieldValue stringValue];
        }
        case FieldTypeRelatedToField:
        case FieldTypeRelatedToModel:
        {
            if( (![fieldValue isKindOfClass:[NSArray class]]) ||
               (((NSArray*)fieldValue).count == 0) ) return @"";
            if( ((NSArray*)fieldValue).count > 1 )
            {
                return [fieldValue objectAtIndex:1];
            }
            else
            {
                return [[fieldValue objectAtIndex:0] stringValue];
            }
        }
        case FieldTypeBoolean:
        {
            return ([fieldValue boolValue] ? @"1" : @"0");
        }
        case FieldTypeUnknown:
        default:
        {
            if( [fieldValue isKindOfClass:[NSString class]] )
            {
                return fieldValue;
            }
            if( [fieldValue isKindOfClass:[NSNumber class]] )
            {
                return [fieldValue stringValue];
            }
            return [NSString stringWithFormat:@"Unknown field type: (%d)", field.type];
        }
    }
}

-(void) warpRecord:(NSDictionary*)record toJSContext:(JSContext*)context
{
    [context evaluateScript:@"var record = new Object();"];
    JSValue* jsRecord = context[@"record"];
    for( NSString* fieldName in record.allKeys )
    {
        NSString* value = [self fieldValue:fieldName withRecord:record];
        jsRecord[fieldName] = @{@"value":value, @"raw_value":value};
    }
    NSLog(@"%@", [jsRecord toDictionary]);
}

-(void) reloadWebView:(UIWebView*)webView withRecord:(NSDictionary*)record
{
    NSString* cssContent = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"css"];
    cssContent = [NSString stringWithContentsOfFile:cssContent encoding:NSUTF8StringEncoding error:nil];
    
    NSString* jsContent = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"js"];
    jsContent = [NSString stringWithContentsOfFile:jsContent encoding:NSUTF8StringEncoding error:nil];
    
    NSString* htmlString = _viewMode.htmlContext;
//    htmlString = [self replaceFieldValue:htmlString withRecord:record];
    
    htmlString = [NSString stringWithFormat:@"<html><head><style>%@</style></head><body>%@<script>%@</script></body></html>", cssContent, htmlString, jsContent];
    [webView loadHTMLString:htmlString baseURL:nil];
}

-(instancetype) initWithWindow:(WindowData*)window
{
    if( self = [super initWithWindow:window] )
    {
        for( ViewModeData* viewMode in _window.viewModes )
        {
            if( [viewMode.name isEqualToString:@"kanban"] )
            {
                _viewMode = viewMode;
                _recordWebViews = [NSMutableArray new];
                break;
            }
        }
    }
    return self;
}

-(void) updateHeightWithWidth:(CGFloat)width updatedTarget:(id)target andAction:(SEL)action
{
    [super updateHeightWithWidth:width updatedTarget:target andAction:action];
    
    [_recordWebViews removeAllObjects];
    for( NSDictionary* record in _viewMode.records )
    {
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
        webView.scrollView.scrollEnabled = NO;
        webView.delegate = (id<UIWebViewDelegate>)self;
        webView.backgroundColor = [UIColor clearColor];
        webView.opaque = NO;
        [self reloadWebView:webView withRecord:record];
        
        [_recordWebViews addObject:webView];
    }
}

-(void) cleanRecord
{
    [super cleanRecord];
    [_recordWebViews removeAllObjects];
}

-(CGFloat) heightOfRecord:(NSInteger)index
{
    UIWebView* webView = _recordWebViews[index];
    return webView.frame.size.height;
}

-(UITableViewCell*) cellOfRecord:(NSInteger)index inTableView:(UITableView*)tableView
{
    UIWebView* webView = _recordWebViews[index];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kKanbanCellIdentifier];
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kKanbanCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else
    {
        for( UIView* view in cell.subviews )
        {
            if( [view isKindOfClass:[UIWebView class]] && ([_recordWebViews indexOfObject:view] < _recordWebViews.count) )
            {
                [view removeFromSuperview];
            }
        }
    }
    
    if( webView.superview ) [webView removeFromSuperview];
    [cell addSubview:webView];
    [cell sendSubviewToBack:webView];
    return cell;
}

-(void) callUpdate:(NSNumber*)index
{
    if( !index )
    {
        [self updateHeightWithWidth:_updateWidth updatedTarget:_updatedTarget andAction:_updatedAtion];
        return;
    }
    [super callUpdate:index];
}

#pragma mark
#pragma mark UIWebViewDelegate

-(void) webView:(UIWebView*)webView didCreateJavaScriptContext:(JSContext*)context
{
    NSInteger index = [_recordWebViews indexOfObject:webView];
    NSDictionary* record = _viewMode.records[index];
    
    context.exceptionHandler = ^(JSContext* context, JSValue* exception) {
        NSLog(@"%@", exception);
        context.exception = exception;
    };
    
    // 设置记录的值
    [self warpRecord:record toJSContext:context];
}

-(void) webViewDidFinishLoad:(UIWebView*)webView
{
    // 调用内置的JS方法显示记录的值
    [webView stringByEvaluatingJavaScriptFromString:@"set_record_value();"];
    
    // 获取HTML窗体的高度
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height;"] floatValue];
    
    // 设置webView的高度
    if( webView.frame.size.height <= 5 )
    {
        CGRect newFrame = webView.frame;
        newFrame.size.height = height;
        webView.frame = newFrame;
    }
    
    // 通知更新某Cell
    NSInteger index = [_recordWebViews indexOfObject:webView];
    [super callUpdate:@(index)];
    
    // 通知更新全局
    for( UIWebView* webView in _recordWebViews )
    {
        if( webView.frame.size.height < 5 ) return;
    }
    [super callUpdate:nil];
}



@end
