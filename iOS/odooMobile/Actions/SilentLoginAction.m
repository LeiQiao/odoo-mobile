//
//  SilentLoginAction.m
//

#import "SilentLoginAction.h"
#import "LoginAction.h"
#import "NetworkResponse.h"
#import "Preferences.h"

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 静默登录，用于用户上次登录后关闭程序再打开程序时自动登录
 */
@implementation SilentLoginAction

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作已加载
 */
-(void) actionDidLoad
{
    [super actionDidLoad];
    
    // 动作加载时自动发送登录通知
    NSDictionary* notifyObject = @{@"ServerName" : gPreferences.ServerName,
                                   @"DBName" : gPreferences.DBName,
                                   @"UserName" : gPreferences.UserName,
                                   @"Password" : gPreferences.Password};
    OdooPostNotification(kWillLoginNotification, notifyObject);
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 登录结果回调
 *  @param notify 登录结果
 */
-(void) loginResponse:(NSNotification*)notify
{
    [super loginResponse:notify];
    
    // 登录完成
    NetworkResponse* response = (NetworkResponse*)notify.object;
    if( !response.success )
    {
        // 登录失败切换到登录界面
        [self switchToAction:[LoginAction class]];
        // 删除登录信息
        gPreferences.UserID = nil;
    }
}

@end
