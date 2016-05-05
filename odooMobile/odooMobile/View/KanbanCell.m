//
//  KanbanCell.m
//

#import "KanbanCell.h"

NSString* const kKanbanCellIdentifier = @"kKanBanIdentifier";

@implementation KanbanCell {
    UIWebView* _webView;
}

#pragma mark
#pragma mark override

-(void) layoutSubviews
{
    [super layoutSubviews];
    _webView.frame = self.contentView.bounds;
    NSLog(@"layout size:(%.02f, %.02f)", self.contentView.bounds.size.width, self.contentView.bounds.size.height);
}

#pragma mark
#pragma mark member functions

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 使用记录更新看板项
 *  @param record   记录
 *  @param viewMode 看板数据
 */
-(void) setRecord:(NSDictionary*)record viewMode:(ViewModeData*)viewMode
{
    if( !_webView )
    {
        NSLog(@"init size:(%.02f, %.02f)", self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        _webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
        _webView.scrollView.scrollEnabled = NO;
        _webView.delegate = (id<UIWebViewDelegate>)self;
        [self.contentView addSubview:_webView];
    }
    
    NSString* cssContent = [[NSBundle mainBundle] pathForResource:@"kanban" ofType:@"css"];
    cssContent = [NSString stringWithContentsOfFile:cssContent encoding:NSUTF8StringEncoding error:nil];
    
    NSString* htmlString = viewMode.htmlContext;
    // TODO: need replace html with field data
    
    htmlString = [NSString stringWithFormat:@"<html><head><style>%@</style></head><body>%@</body></html>", cssContent, htmlString];
    [_webView loadHTMLString:htmlString baseURL:nil];
}

#pragma mark
#pragma mark UIWebViewDelegate

-(void) webViewDidFinishLoad:(UIWebView*)webView
{
    // 获取HTML窗体的高度
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height;"] floatValue];
    if( _delegate && [_delegate respondsToSelector:@selector(kanbanCell:didUpdateHeight:)] )
    {
        NSLog(@"calc size:(%.02f, %.02f)", self.contentView.bounds.size.width, height);
        [_delegate kanbanCell:self didUpdateHeight:height];
    }
}

@end
