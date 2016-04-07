//
//  SilentLoginAction.m
//

#import "SilentLoginAction.h"
#import "LoginAction.h"
#import "AppDelegate.h"
#import "HUD.h"
#import "UserModule.h"

@implementation SilentLoginAction

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作已加载
 */
-(void) actionDidLoad
{
    popWaiting();
    
    // 添加登录结果观察
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponse:)
                                                 name:kLoginNetworkNotification
                                               object:nil];
    
    // 创建静默登录线程
    [NSThread detachNewThreadSelector:@selector(silentLoginThread)
                             toTarget:self
                           withObject:nil];
    
    
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 静默登录线程
 */
-(void) silentLoginThread
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UserModule* userModule = [appDelegate.rootView.bridge moduleForClass:[UserModule class]];
    
    // 开始登录
    [userModule login:gPreferences.ServerName
               DBName:gPreferences.DBName
             userName:gPreferences.UserName
             password:gPreferences.Password];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 登录结果回调
 *  @param notify 登录结果
 */
-(void) loginResponse:(NSNotification*)notify
{
    dismissWaiting();
    
    // 登录完成
    NetworkResponse* response = (NetworkResponse*)notify.object;
    if( response.success )
    {
        [self leaveAction];
    }
    else
    {
        popError(response.failedReason);
        
        // 登录失败切换到登录界面
        [self switchToAction:[LoginAction class]];
        // 删除登录信息
        gPreferences.UserID = nil;
    }
}

@end
