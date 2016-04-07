//
//  MainAction.m
//

#import "MainAction.h"
#import "LoginAction.h"
#import "SilentLoginAction.h"
#import "Preferences.h"

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 主动作负责首页及登陆页的调度
 */
@implementation MainAction

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 首页加载完成后的回调
 */
-(void) actionDidLoad
{
    // 如果没有登录则进行登陆
    if( [gPreferences.UserID integerValue] == 0 )
    {
        [self enterAction:[LoginAction class]];
        return;
    }
    else
    {
        [self enterAction:[SilentLoginAction class]];
        return;
    }
}

@end
