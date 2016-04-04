//
//  CXBaseModule.m
//

#import "CXBaseModule.h"
#import "RCTEventDispatcher.h"
#import "RCTBridgeModule.h"

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 与React-Native交互的模块类，实现JS与Native的中间层通讯
 *         由JS或者Native调用，将结果通知给双方(JS方主动或监听事件)
 */
@implementation CXBaseModule

RCT_EXPORT_MODULE();
@synthesize bridge = _bridge;

#pragma mark
#pragma mark member functions

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 发送网络请求结果消息
 *  @param notificationName 消息名
 *  @param response         响应结果
 */
-(void) postNotificationName:(NSString*)notificationName withResponse:(NetworkResponse*)response
{
    // 向React-Native发送事件
    [_bridge.eventDispatcher sendDeviceEventWithName:notificationName body:response.dictionary];
    
    // 向Native发送消息
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:response];
    });
}

@end
