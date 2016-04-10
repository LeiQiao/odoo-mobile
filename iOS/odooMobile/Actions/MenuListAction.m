//
//  MenuListAction.m
//

#import "MenuListAction.h"
#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "OdooNotification.h"
#import "HUD.h"
#import "MenuNetwork.h"
#import "UIViewController+CXBaseAction.h"

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 菜单列表页面，展示所有的二级或更多级的菜单
 */
@implementation MenuListAction {
    UIViewController* _menuViewController;  /*!< 菜单窗 */
}

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 动作已加载
 */
-(void) actionDidLoad
{
    NSDictionary* currentMenu = (NSDictionary*)_parameters;
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    SlideNavigationController* navController = [SlideNavigationController sharedInstance];
    
    // 菜单窗体
    RCTRootView* menuListView = [[RCTRootView alloc] initWithBridge:appDelegate.rootView.bridge
                                                         moduleName:@"MenuListView"
                                                  initialProperties:currentMenu];
    
    _menuViewController = [UIViewController new];
    _menuViewController.action = self;
    _menuViewController.view = menuListView;
    _menuViewController.title = [currentMenu objectForKey:@"name"];
    [navController pushViewController:_menuViewController animated:YES];
    
    // 更新子菜单线程
    [NSThread detachNewThreadSelector:@selector(loadSubmenuThread:)
                             toTarget:self
                           withObject:currentMenu];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作已离开
 */
-(void) actionDidLeave
{
    [_menuViewController.navigationController popViewControllerAnimated:YES];
    _menuViewController = nil;
}

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 动作被销毁
 */
-(void) actionDidDestroy
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _menuViewController = nil;
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 刷新子菜单线程
 */
-(void) loadSubmenuThread:(NSDictionary*)currentMenu
{
    dispatch_async(dispatch_get_main_queue(), ^{
        popWaiting();
    });
    
    MenuNetwork* menuOperator = [[MenuNetwork alloc] init];
    NetworkResponse* response = [menuOperator getSubMenuByMenu:currentMenu];
    
    // 如果获取成功则返回当前菜单和子菜单
    if( response.success )
    {
        response.responseObject = @{@"Menu":currentMenu,
                                    @"SubMenus":response.responseObject};
    }
    OdooPostNotification(kDidLoadSubmenuNotification, response);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        dismissWaiting();
    });
}

@end
