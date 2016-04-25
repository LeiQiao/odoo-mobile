//
//  LoginAction.m
//

#import "LoginAction.h"
#import "AppDelegate.h"
#import "UIViewController+CXBaseAction.h"

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 登录，第一次登录时或者推出后再登录时，需要弹出登录界面
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
    [super actionDidLoad];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

    // 创建登录窗
    RCTRootView* loginView = [[RCTRootView alloc] initWithBridge:appDelegate.rootView.bridge
                                                      moduleName:@"LoginView"
                                               initialProperties:nil];
    _loginViewController = [UIViewController new];
    _loginViewController.view = loginView;
    _loginViewController.action = self;
    
    // 弹出登陆窗
    [appDelegate.window.rootViewController presentViewController:_loginViewController animated:YES completion:^{}];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作已离开
 */
-(void) actionDidLeave
{
    [super actionDidLeave];
    
    [_loginViewController dismissViewControllerAnimated:YES completion:^{}];
    _loginViewController = nil;
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作被销毁
 */
-(void) actionDidDestroy
{
    [super actionDidDestroy];
    
    _loginViewController = nil;
}

@end
