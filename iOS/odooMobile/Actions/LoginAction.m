//
//  LoginAction.m
//

#import "LoginAction.h"
#import "AppDelegate.h"
#import "ModuleNotification.h"
#import "NetworkResponse.h"
#import "Preferences.h"
#import "AFXMLRPCSessionManager.h"

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 登录动作
 */
@implementation LoginAction {
    UIViewController* _loginViewController;     /*!< 登录窗 */
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作已加载
 */
-(void) actionDidLoad
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

    // 创建登录窗
    RCTRootView* loginView = [[RCTRootView alloc] initWithBridge:appDelegate.rootView.bridge
                                                      moduleName:@"LoginView"
                                               initialProperties:nil];
    _loginViewController = [UIViewController new];
    _loginViewController.view = loginView;
    
    // 弹出登陆窗
    [appDelegate.window.rootViewController presentViewController:_loginViewController animated:YES completion:^{}];
    
    // 注册通知消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponse:)
                                                 name:kLoginNetworkNotification
                                               object:nil];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作已离开
 */
-(void) actionDidLeave
{
    [_loginViewController dismissViewControllerAnimated:YES completion:^{}];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作被销毁
 */
-(void) actionDidDestroy
{
    _loginViewController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 登录结果回调
 *  @param notify 登录结果的回调消息
 */
-(void) loginResponse:(NSNotification*)notify
{
    NetworkResponse* response = (NetworkResponse*)notify.object;
    
    // 登录成功则退出登录界面
    if( response.success )
    {
        [self leaveAction];
    }
}

@end
