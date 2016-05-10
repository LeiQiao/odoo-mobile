//
//  KanbanViewController.m
//

#import "KanbanViewController.h"
#import "UIWebView+TS_JavaScriptContext.h"
#import "HUD.h"
#import "GlobalModels.h"
#import "Preferences.h"

@implementation KanbanViewController {
    NSMutableArray* _recordWebViews;
}

#pragma mark
#pragma mark helper

-(void) warpRecord:(NSDictionary*)record toJSContext:(JSContext*)context
{
    context[@"_s"] = gPreferences.ServerName;
    
    [context evaluateScript:@"var record = new Object();"];
    JSValue* jsRecord = context[@"record"];
    ViewModeData* viewMode = [_window viewModeForName:kKanbanViewModeName];
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
    NSLog(@"%@", [jsRecord toDictionary]);
}

-(void) reloadWebView:(UIWebView*)webView withRecord:(NSDictionary*)record
{
    NSString* cssContent = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"css"];
    cssContent = [NSString stringWithContentsOfFile:cssContent encoding:NSUTF8StringEncoding error:nil];
    
    NSString* jsContent = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"js"];
    jsContent = [NSString stringWithContentsOfFile:jsContent encoding:NSUTF8StringEncoding error:nil];
    
    ViewModeData* viewMode = [_window viewModeForName:kKanbanViewModeName];
    NSString* htmlString = viewMode.htmlContext;
    
    htmlString = [NSString stringWithFormat:
                  @"<html>\n"
                  @"    <head>\n"
                  @"        <style>\n%@\n</style>\n"
                  @"    </head>\n"
                  @"    <body>\n%@\n"
                  @"        <script>\n%@\n</script>\n"
                  @"    </body>\n"
                  @"</html>", cssContent, htmlString, jsContent];
    [webView loadHTMLString:htmlString baseURL:nil];
}

-(void) reloadData
{
    [_recordWebViews removeAllObjects];
    
    ViewModeData* viewMode = [_window viewModeForName:kKanbanViewModeName];
    for( NSDictionary* record in viewMode.records )
    {
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
        webView.scrollView.scrollEnabled = NO;
        webView.delegate = (id<UIWebViewDelegate>)self;
        webView.backgroundColor = [UIColor clearColor];
        webView.opaque = NO;
        [self reloadWebView:webView withRecord:record];
        
        [_recordWebViews addObject:webView];
    }
    [self.tableView reloadData];
}

-(void) updateWebView:(JSContext*)context withHeight:(CGFloat)height
{
    for( NSInteger i=0; i<_recordWebViews.count; i++ )
    {
        UIWebView* webView = _recordWebViews[i];
        if( webView.ts_javaScriptContext == context )
        {
            CGRect newFrame = webView.frame;
            if( height != newFrame.size.height )
            {
                newFrame.size.height = height;
                webView.frame = newFrame;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i
                                                                            inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}

#pragma mark
#pragma mark init & dealloc

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    _recordWebViews = [NSMutableArray new];
    [self reloadData];
    
    ADDOBSERVER(RecordModel, (id<RecordModelObserver>)self);
    
    ViewModeData* viewMode = [_window viewModeForName:kKanbanViewModeName];
    if( viewMode.records.count == 0 )
    {
        popWaiting();
        [GETMODEL(RecordModel) requestMoreRecord:_window viewMode:viewMode];
    }
}

-(void) dealloc
{
    REMOVEOBSERVER(RecordModel, (id<RecordModelObserver>)self);
}

#pragma mark
#pragma mark UIWebViewDelegate

-(void) webView:(UIWebView*)webView didCreateJavaScriptContext:(JSContext*)context
{
    NSInteger index = [_recordWebViews indexOfObject:webView];
    
    context.exceptionHandler = ^(JSContext* context, JSValue* exception) {
        NSLog(@"%@", exception);
        context.exception = exception;
    };
    
    context[@"nslog"] = ^(NSString* logMessage) {
        NSLog(@"***** JSLog: %@", logMessage);
    };
    
    context[@"onUpdateHeight"] = ^(JSValue* height) {
        JSContext* context = [JSContext currentContext];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateWebView:context withHeight:[height toDouble]];
        });
    };
    
    // 设置记录的值
    ViewModeData* viewMode = [_window viewModeForName:kKanbanViewModeName];
    NSDictionary* record = viewMode.records[index];
    [self warpRecord:record toJSContext:context];
}

-(void) webViewDidFinishLoad:(UIWebView*)webView
{
    // 调用内置的JS方法显示记录的值
    [webView stringByEvaluatingJavaScriptFromString:@"setRecordValue();"];
}

#pragma mark
#pragma mark RecordModelObserver

-(void) recordModel:(RecordModel*)recordModel requestMoreRecord:(ReturnParam*)params
{
    if( (params[@"Window"] != _window) ||
       (params[@"ViewMode"] != [_window viewModeForName:kKanbanViewModeName]) ) return;
    
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
    }
    
    [self reloadData];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _recordWebViews.count;
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UIWebView* webView = _recordWebViews[indexPath.row];
    return webView.frame.size.height;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
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
    
    UIWebView* webView = _recordWebViews[indexPath.row];
    if( webView.superview ) [webView removeFromSuperview];
    [cell addSubview:webView];
    [cell sendSubviewToBack:webView];
    return cell;
}

@end
