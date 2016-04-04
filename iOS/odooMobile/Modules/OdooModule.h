//
//  OdooModule.h
//

#import "CXBaseModule.h"

/*!
 *  @author LeiQiao, 16/04/04
 *  @brief 与odoo服务器进行通讯的接口类，使用XMLRPC协议
 */
@interface OdooModule : CXBaseModule

/*!
 *  @author LeiQiao, 16/04/04
 *  @brief 授权，登录接口
 *  @param urlString 服务器接口
 *  @param dbName    数据库名称
 *  @param userName  用户名
 *  @param password  用户密码
 *  @param callback  登录回调
 */
-(void) authenticate:(NSString*)serverName
              dbName:(NSString*)dbName
            userName:(NSString*)userName
            password:(NSString*)password
            callback:(RCTResponseSenderBlock)callback;

/*!
 *  @author LeiQiao, 16/04/04
 *  @brief 执行增删改查功能
 *  @param model      模块名称
 *  @param method     方法名称
 *  @param parameters 参数列表
 *  @param conditions 筛选条件
 *  @param callback   功能回调
 */
-(void) execute:(NSString*)model
         method:(NSString*)method
     parameters:(NSArray*)parameters
     conditions:(NSDictionary*)conditions
       callback:(RCTResponseSenderBlock)callback;




@end
