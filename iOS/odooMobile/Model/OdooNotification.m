//
//  OdooNotification.m
//

#import "OdooNotification.h"
#import "AppDelegate.h"
#import "RCTEventDispatcher.h"
#import "NetworkResponse.h"

NSString* const kWillLoginNotification = @"kWillLoginNotification";
NSString* const kDidLoginNotification = @"kDidLoginNotification";
NSString* const kShowCompanyInfoNotification  = @"kShowCompanyInfoNotification";
NSString* const kShowPersonalInfoNotification  = @"kShowPersonalInfoNotification";
NSString* const kShowSubmenuNotification  = @"kShowSubmenuNotification";
NSString* const kWillLoadSubmenuNotification = @"kWillLoadSubmenuNotification";
NSString* const kDidLoadSubmenuNotification = @"kDidLoadSubmenuNotification";
NSString* const kDidLoadWindowNotificaiton = @"kDidLoadWindowNotificaiton";

/*!
 *  @author LeiQiao, 16/04/03
 *  @brief 发送通知消息
 *  @param notificationName 消息名
 *  @param object           消息参数
 */
extern void OdooPostNotification(NSString* notificationName, id object)
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    RCTBridge* bridge = appDelegate.rootView.bridge;
    
    // 向React-Native发送事件
    id rctObject = object;
    if( [object isKindOfClass:[NetworkResponse class]] )
    {
        rctObject = ((NetworkResponse*)object).dictionary;
    }
    [bridge.eventDispatcher sendDeviceEventWithName:notificationName body:rctObject];
    
    // 向Native发送消息
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:object];
    });
}


