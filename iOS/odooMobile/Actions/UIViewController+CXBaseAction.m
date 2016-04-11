//
//  UIViewController+CXBaseAction.m
//

#import "UIViewController+CXBaseAction.h"
#import <objc/runtime.h>

const char* actionKey = "ActionKey";

@implementation UIViewController(CXBaseAction)

#pragma mark
#pragma mark Method Exchange
/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 替换ViewWillDisappear方法，用户点击页面返回时自动退出绑定的动作
 */
+(void) exchangeViewWillDisappearMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 替换viewWillDisappear
        Method org_Method = class_getInstanceMethod([self class], @selector(viewWillDisappear:));
        Method new_Method = class_getInstanceMethod([self class], @selector(leaveActionWhenViewWillDisappear:));
        method_exchangeImplementations(org_Method, new_Method);
    });
}

#pragma mark
#pragma mark Associate New Object

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 设置当前动作
 *  @param newAction 当前动作
 */
-(void) setAction:(CXBaseAction*)newAction
{
    objc_setAssociatedObject(self, &actionKey, newAction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[self class] exchangeViewWillDisappearMethod];
}

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 获取当前动作
 *  @return 获取当前动作
 */
-(CXBaseAction*) action
{
    CXBaseAction* action = objc_getAssociatedObject(self, &actionKey);
    return action;
}

#pragma mark
#pragma mark override

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 新的viewWillDisappear方法
 *  @param animated 老的viewWillDisappear方法的参数
 */
-(void) leaveActionWhenViewWillDisappear:(BOOL)animated
{
    [self leaveActionWhenViewWillDisappear:animated];
    
    if( !self.action ) return;
    
    // 如果当前页面退出，则退出绑定的动作
    if( [self.navigationController.viewControllers indexOfObject:self] == NSNotFound )
    {
        [self.action leaveAction];
        self.action = nil;
    }
}

@end
