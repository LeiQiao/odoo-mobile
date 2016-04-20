//
//  WindowAction.m
//

#import "WindowAction.h"
#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "HUD.h"
#import "WindowNetwork.h"
#import "OdooNotification.h"

@implementation WindowAction {
}

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 动作已加载
 */
-(void) actionDidLoad
{
    // 更新窗口线程
    NSString* actionTypeID = (NSString*)_parameters;
    [NSThread detachNewThreadSelector:@selector(loadWindowThread:)
                             toTarget:self
                           withObject:actionTypeID];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作已离开
 */
-(void) actionDidLeave
{
}

/*!
 *  @author LeiQiao, 16-04-1
 *  @brief 动作被销毁
 */
-(void) actionDidDestroy
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 更新窗口线程
 */
-(void) loadWindowThread:(NSString*)actionTypeID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        popWaiting();
    });
    
    NSArray* actionTypeAndID = [actionTypeID componentsSeparatedByString:@","];
    NSString* windowType = [actionTypeAndID objectAtIndex:0];
    NSNumber* windowID = @([[actionTypeAndID objectAtIndex:1] integerValue]);
    
    WindowNetwork* window = [[WindowNetwork alloc] init];
    NetworkResponse* response = [window getWindowByID:windowID type:windowType];
    
    // 如果获取成功则返回当前菜单和子菜单
    if( response.success )
    {
        response.responseObject = @{@"action":actionTypeID,
                                    @"window":response.responseObject};
    }
    OdooPostNotification(kDidLoadWindowNotificaiton, response);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        dismissWaiting();
    });
}

@end
