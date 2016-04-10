//
//  MainAction.m
//

#import "MainAction.h"
#import "LoginAction.h"
#import "SilentLoginAction.h"
#import "Preferences.h"
#import "SlideNavigationController.h"
#import "AppDelegate.h"
#import "NetworkResponse.h"
#import "AFXMLRPCSessionManager.h"
#import "WindowAction.h"
#import "MenuListAction.h"

@interface MainViewController : UIViewController

@end

@implementation MainViewController

-(BOOL) slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

@end

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
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    SlideNavigationController* navController = [SlideNavigationController sharedInstance];
    // 主窗口
    RCTRootView* mainView = [[RCTRootView alloc] initWithBridge:appDelegate.rootView.bridge
                                                     moduleName:@"MainView"
                                              initialProperties:nil];
    
    // 创建主窗体
    MainViewController* vcMain = [[MainViewController alloc] init];
    vcMain.title = @"首页";
    vcMain.view = mainView;
    
    [navController popAllAndSwitchToViewController:vcMain
                             withSlideOutAnimation:NO
                                     andCompletion:^{}];
    
    // 添加登录消息监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponse:)
                                                 name:kDidLoginNotification
                                               object:nil];
    
    // 添加侧边栏消息监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCompanyInfo:)
                                                 name:kShowCompanyInfoNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPersonalInfo:)
                                                 name:kShowPersonalInfoNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSubmenu:)
                                                 name:kWillLoadSubmenuNotification
                                               object:nil];
    
    // 如果没有登录则进行登陆
    if( [gPreferences.UserID integerValue] == 0 )
    {
        [self enterAction:[LoginAction class]];
        return;
    }
    else if( !gPreferences.Menus )
    {
        [self enterAction:[SilentLoginAction class]];
        return;
    }
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作被销毁
 */
-(void) actionDidDestroy
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*!
 *  @author LeiQiao, 16-04-08
 *  @brief 登录结果
 */
-(void) loginResponse:(NSNotification*)notify
{
    NetworkResponse* response = (NetworkResponse*)notify.object;
    if( !response.success ) return;
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    SlideNavigationController* navController = [SlideNavigationController sharedInstance];
    
    // 侧边栏窗
    if( !navController.leftMenu )
    {
        RCTRootView* menuView = [[RCTRootView alloc] initWithBridge:appDelegate.rootView.bridge
                                                         moduleName:@"SlideMenuView"
                                                  initialProperties:nil];
        
        UIViewController* vcMenu = [[UIViewController alloc] init];
        vcMenu.view = menuView;
        
        // 设置主窗体和侧边栏
        navController.leftMenu = vcMenu;
    }
}

/*!
 *  @author LeiQiao, 16-04-08
 *  @brief 登录结果
 */
-(void) showCompanyInfo:(NSNotification*)notify
{
    NSLog(@"showCompanyInfo");
}

/*!
 *  @author LeiQiao, 16-04-08
 *  @brief 登录结果
 */
-(void) showPersonalInfo:(NSNotification*)notify
{
    NSLog(@"showPersonalInfo");
}

/*!
 *  @author LeiQiao, 16-04-08
 *  @brief 登录结果
 */
-(void) showSubmenu:(NSNotification*)notify
{
    NSDictionary* currentMenu = (NSDictionary*)notify.object;
    NSString* action = [currentMenu objectForKey:@"action"];
    
    // 如果当前菜单项是一个动作，则运行该动作
    if( [action isKindOfClass:[NSString class]] )
    {
        [self.currentAction enterAction:[WindowAction class] withParameters:currentMenu];
    }
    // 进入展示子菜单动作
    else
    {
        [self.currentAction enterAction:[MenuListAction class] withParameters:currentMenu];
    }
}


@end
