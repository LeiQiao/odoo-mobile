//
//  KanbanDataSource.m
//

#import "KanbanDataSource.h"

NSString* const kKanbanCellIdentifier = @"kKanbanCellIdentifier";   /*!< 看板项重用标示 */

@implementation KanbanDataSource {
    NSMutableArray* _recordWebViews;
}

-(void) reloadWebView:(UIWebView*)webView withRecord:(NSDictionary*)record
{
    NSString* cssContent = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"css"];
    cssContent = [NSString stringWithContentsOfFile:cssContent encoding:NSUTF8StringEncoding error:nil];
    
    NSString* htmlString = _viewMode.htmlContext;
    // TODO: need replace html with field data
    
    htmlString = [NSString stringWithFormat:@"<html><head><style>%@</style></head><body>%@</body></html>", cssContent, htmlString];
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
    }
    
    if( webView.superview ) [webView removeFromSuperview];
    [cell.contentView addSubview:webView];
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

-(void) webViewDidFinishLoad:(UIWebView*)webView
{
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
    NSLog(@"webview %02d height: %.02f", index, height);
    [super callUpdate:@(index)];
    
    // 通知更新全局
    for( UIWebView* webView in _recordWebViews )
    {
        if( webView.frame.size.height < 5 ) return;
    }
    [super callUpdate:nil];
}



@end
