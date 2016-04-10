//
//  WindowAction.m
//

#import "WindowAction.h"
#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "UIViewController+CXBaseAction.h"
#import "HUD.h"
#import "WindowNetwork.h"

@implementation WindowAction {
    UIViewController* _windowController;
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
    
    // 窗口
    RCTRootView* menuListView = [[RCTRootView alloc] initWithBridge:appDelegate.rootView.bridge
                                                         moduleName:@"WindowView"
                                                  initialProperties:nil];
    
    _windowController = [UIViewController new];
    _windowController.action = self;
    _windowController.view = menuListView;
    _windowController.title = [currentMenu objectForKey:@"name"];
    [navController pushViewController:_windowController animated:YES];
    
    // 更新窗口线程
    [NSThread detachNewThreadSelector:@selector(loadWindowThread:)
                             toTarget:self
                           withObject:currentMenu];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作已离开
 */
-(void) actionDidLeave
{
    [_windowController.navigationController popViewControllerAnimated:YES];
    _windowController = nil;
}

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 动作被销毁
 */
-(void) actionDidDestroy
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _windowController = nil;
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 更新窗口线程
 */
-(void) loadWindowThread:(NSDictionary*)currentMenu
{
    dispatch_async(dispatch_get_main_queue(), ^{
        popWaiting();
    });
    
    NSString* action = [currentMenu objectForKey:@"action"];
    NSString* windowType = [[action componentsSeparatedByString:@","] objectAtIndex:0];
    NSNumber* windowID = @([[[action componentsSeparatedByString:@","] objectAtIndex:1] integerValue]);
    
    WindowNetwork* window = [[WindowNetwork alloc] init];
    NetworkResponse* response = [window getWindowByID:windowID type:windowType];
    
    // 如果获取成功则返回当前菜单和子菜单
    if( response.success )
    {
        response.responseObject = @{@"Menu":currentMenu,
                                    @"SubMenus":response.responseObject};
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        dismissWaiting();
    });
}

@end
