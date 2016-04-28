//
//  WindowViewController.m
//

#import "WindowViewController.h"
#import "GlobalModels.h"
#import "HUD.h"
#import "UIViewController+CustomUI.h"

/*!
 *  @author LeiQiao, 16-04-27
 *  @brief 窗口菜单视图
 */
@implementation WindowViewController {
    NSArray* _viewModes;    /*!< 所有可用的视图模式 */
}

#pragma mark
#pragma mark init & dealloc

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    ADDOBSERVER(WindowModel, (id<WindowModelObserver>)self);
    popWaiting();
    [GETMODEL(WindowModel) updateWindowByID:_windowID];
}

-(void) dealloc
{
    REMOVEOBSERVER(WindowModel, (id<WindowModelObserver>)self);
}

#pragma mark
#pragma mark button events

-(IBAction) viewModeChanged:(id)sender
{
    NSUInteger index = self.viewModeSegment.selectedSegmentIndex;
    NSDictionary* viewMode = [[_viewModes objectAtIndex:index] objectAtIndex:1];
    NSLog(@"%@", viewMode);
}

#pragma mark
#pragma mark WindowModelObserver

-(void) windowModel:(WindowModel*)windowModel updateWindowByID:(ReturnParam*)params
{
    NSNumber* windowID = params[@"WindowID"];
    if( ![windowID isEqual:_windowID] ) return;
    
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
        return;
    }
    
    _viewModes = params[@"WindowModes"];
    
    [self.viewModeSegment removeAllSegments];
    for( NSUInteger i=0; i<_viewModes.count; i++ )
    {
        NSArray* viewMode = [_viewModes objectAtIndex:i];
        NSString* viewModeName = [viewMode objectAtIndex:0];
        
        
        // search和form不单独显示视图模式，这两种显示模式集成在其他页面
        NSString* viewModeType = [[viewMode objectAtIndex:1] objectForKey:@"type"];
        if( (![viewModeType isEqualToString:@"search"]) &&
           (![viewModeType isEqualToString:@"form"]) )
        {
            [self.viewModeSegment insertSegmentWithTitle:viewModeName atIndex:i animated:NO];
        }
    }
    self.viewModeSegment.hidden = NO;
    
    // 默认选中第一个,直接调用按钮事件，下面一句不会触发事件
    self.viewModeSegment.selectedSegmentIndex = 0;
    [self viewModeChanged:self.viewModeSegment];
}

@end
