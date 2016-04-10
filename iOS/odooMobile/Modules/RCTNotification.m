//
//  RCTNotification.m
//

#import "RCTNotification.h"
#import "OdooNotification.h"

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 用于React-Native给Native发送通知消息，消息发出后双方都会接收到
 */
@implementation RCTNotification

RCT_EXPORT_MODULE(Notification)

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 发送通知
 *  @param notificationName 通知消息名称
 *  @param object           通知消息内容
 */
RCT_EXPORT_METHOD(postNotification:(NSString*)notificationName object:(id)object)
{
    OdooPostNotification(notificationName, object);
}

@end
