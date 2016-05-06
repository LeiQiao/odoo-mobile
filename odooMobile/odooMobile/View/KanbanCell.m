//
//  KanbanCell.m
//

#import "KanbanCell.h"


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
        [self.contentView addSubview:_webView];
    }
    
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
