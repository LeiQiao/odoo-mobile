//
//  UIViewController+CXBaseAction.h
//

#import <UIKit/UIKit.h>
#import "CXBaseAction.h"

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 动作类的视图控制器扩展方法
 */
@interface UIViewController (CXBaseAction)

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 当前动作
 *         实现：1. 用户点击页面返回时自动退出绑定的动作
 *  @param action 绑定的动作
 */
@property(nonatomic, assign) CXBaseAction* action;

@end
