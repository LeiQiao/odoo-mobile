//
//  BaseLoginAction.h
//

#import "CXBaseAction.h"
#import "OdooNotification.h"

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 登录动作，封装了登录的逻辑
 */
@interface BaseLoginAction : CXBaseAction

#pragma mark - override

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 开始登录
 *  @param notify 登录通知
 *         -- ServerName 服务器名称
 *         -- DBName     数据库名称
 *         -- UserName   用户名
 *         -- Password   密码
 */
-(void) loginRequest:(NSNotification*)notify;

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 登录完成
 *  @param notify 登录结果通知
 */
-(void) loginResponse:(NSNotification*)notify;

@end
