//
//  UserNetwork.h
//

#import "OdooNetwork.h"

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 用户相关网络请求
 */
@interface UserNetwork : OdooNetwork

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 登录到远程odoo服务器
 *  @param serverName 服务器地址，例如：http://qitaer.com:8069
 *  @param dbName     数据库名称
 *  @param userName   登录用户名
 *  @param password   登录密码
 *  @return 登录结果
 */
-(NetworkResponse*) login:(NSString*)serverName
                   dbName:(NSString*)dbName
                 userName:(NSString*)userName
                 password:(NSString*)password;

@end
