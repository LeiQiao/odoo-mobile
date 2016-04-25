//
//  OdooNetwork.h
//

#import "NetworkResponse.h"
#import "Preferences.h"


/*!
 *  @author LeiQiao, 15-11-24
 *  @brief  将变量为null转换为nil，防止调用崩溃
 *  @param obj 变量
 *  @return 安全变量
 */
NS_INLINE id SafeValue(id obj){return ([obj isKindOfClass:[NSNull class]])?nil:obj;}

/*!
 *  @author LeiQiao, 15-11-24
 *  @brief  对字符串进行安全拷贝（不能是nil或者null）
 *  @param str 字符串
 *  @return 安全字符串
 */
NS_INLINE NSString* SafeCopy(NSString* str){return SafeValue(str)?[NSString stringWithFormat:@"%@", str]:@"";}


/*!
 *  @author LeiQiao, 16-04-09
 *  @brief Odoo网络操作类
 */
@interface OdooNetwork : NSObject

/*!
 *  @author LeiQiao, 16/04/04
 *  @brief 授权，登录接口
 *  @param urlString 服务器接口
 *  @param dbName    数据库名称
 *  @param userName  用户名
 *  @param password  用户密码
 *  @param callback  登录回调
 *  @return 返回网络调用结果
 */
-(NetworkResponse*) authenticate:(NSString*)serverName
                          dbName:(NSString*)dbName
                        userName:(NSString*)userName
                        password:(NSString*)password;

/*!
 *  @author LeiQiao, 16/04/04
 *  @brief 执行增删改查功能
 *  @param model      模块名称
 *  @param method     方法名称
 *  @param parameters 参数列表
 *  @param conditions 筛选条件
 *  @param callback   功能回调
 *  @return 返回网络调用结果
 */
-(NetworkResponse*) execute:(NSString*)model
                     method:(NSString*)method
                 parameters:(NSArray*)parameters
                 conditions:(NSDictionary*)conditions;

@end
