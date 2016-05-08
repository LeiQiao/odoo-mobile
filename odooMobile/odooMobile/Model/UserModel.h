//
//  UserModel.h
//

#import "ModelObserver.h"



/*!
 *  @author LeiQiao, 16/05/08
 *  @brief 使用货币表示法返回金额
 *  @param amount 金额
 *  @return 金额的货币表示法
 */
extern NSString* getMonetary(NSNumber* amount);

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 用户模型
 */
@interface UserModel : BaseModel

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 请求指定服务器的所有数据库
 *  @param serverName 服务器地址
 */
-(void) requestDatabase:(NSString*)serverName;

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 查找指定的服务器是否存在指定数据库
 *  @param serverName 服务器地址
 *  @param dbName     数据库名称
 */
-(void) checkDatabaseExist:(NSString*)serverName dbName:(NSString*)dbName;

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 登录
 *  @param serverName 服务器地址
 *  @param dbName     数据库名称
 *  @param userName   用户名
 *  @param password   密码
 */
-(void) login:(NSString*)serverName
       dbName:(NSString*)dbName
     userName:(NSString*)userName
     password:(NSString*)password;

@end


/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 用户模型监听协议
 */
@protocol UserModelObserver <BaseModelObserver>

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 请求指定服务器的所有数据库结果
 *  @param userModel 用户模型
 *  @param params    返回参数
 *         params[@"Databases"]     数据库列表
 */
-(void) userModel:(UserModel*)userModel requestDatabase:(ReturnParam*)params;

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 查找指定的服务器是否存在指定数据库
 *  @param userModel 用户模型
 *  @param params    返回参数
 */
-(void) userModel:(UserModel*)userModel checkDatabaseExist:(ReturnParam*)params;

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 登录结果
 *  @param userModel 用户模型
 *  @param params    返回参数
 *         params[@"UserID"]     用户ID
 */
-(void) userModel:(UserModel*)userModel login:(ReturnParam*)params;

@end









