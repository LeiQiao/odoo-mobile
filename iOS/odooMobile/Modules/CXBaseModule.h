//
//  CXBaseModule.h
//

#import "NetworkResponse.h"
#import "RCTBridgeModule.h"

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 与React-Native交互的模块类的基类，实现JS与Native的中间层通讯
 *         由JS或者Native调用，将结果通知给双方(JS方主动或监听事件)
 */
@interface CXBaseModule : NSObject <RCTBridgeModule>

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
