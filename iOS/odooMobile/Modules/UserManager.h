//
//  UserManager.h
//

#import "CXBaseModule.h"

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 用户管理模块，包括登录等逻辑处理，
 *         React-Native和Native双方都可以调用，不管哪一方调用回调消息都会通知双方
 */
@interface UserManager : CXBaseModule

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 登录到远程odoo服务器
 *  @param serverName 服务器地址，例如：http://qitaer.com:8069
 *  @param DBName     数据库名称
 *  @param userName   登录用户名
 *  @param password   登录密码
 */
-(void) login:(NSString*)serverName
       DBName:(NSString*)DBName
     userName:(NSString*)userName
     password:(NSString*)password;

@end
