//
//  UserModel.h
//

#import "ModelObserver.h"

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
 *  @author LeiQiao, 16-04-22
 *  @brief 登录结果
 *  @param userModel 用户模型
 *  @param params    返回参数
 *         params[@"UserID"]     用户ID
 */
-(void) userModel:(UserModel*)userModel login:(ReturnParam*)params;

@end









