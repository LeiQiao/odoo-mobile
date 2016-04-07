//
//  CXBaseModule.h
//

#import "NetworkResponse.h"
#import "RCTBridgeModule.h"
#import "Preferences.h"
#import "ModuleNotification.h"

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 与React-Native交互的模块类的基类，实现JS与Native的中间层通讯
 *         由JS或者Native调用，将结果通知给双方(JS方主动或监听事件)
 */
@interface CXBaseModule : NSObject <RCTBridgeModule>

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

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 发送网络请求结果消息(同时向React-Native和Native发送)
 *  @param notificationName 消息名
 *  @param response         响应结果
 */
-(void) postNotificationName:(NSString*)notificationName withResponse:(NetworkResponse*)response;

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 向React-Native导出属性
 *  @param propertyName 属性名称
 */
#define RCT_EXPORT_PROPERTY(propertyName) \
    RCT_EXPORT_METHOD(propertyName:(RCTResponseSenderBlock)callback) \
    { \
        callback(@[SafeCopy(self.propertyName)]); \
    }

@end
