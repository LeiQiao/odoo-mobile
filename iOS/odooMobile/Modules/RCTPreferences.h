//
//  RCTPreferences.h
//

#import "RCTBridgeModule.h"

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 将Preferences的全局变量提供给React-Native使用，调用时需要跟Preferences中的参数名一致
 */
@interface RCTPreferences : NSObject <RCTBridgeModule>

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 获取全局变量的值
 *  @param preferencesName 全局变量的名称
 *  @param callback        获取到全局变量后的回调函数
 */
-(void) get:(NSString*)preferencesName callback:(RCTResponseSenderBlock)callback;

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 设置全局变量的值
 *  @param preferencesName  全局变量的名称
 *  @param preferencesValue 全局变量的值
 */
-(void) set:(NSString*)preferencesName value:(id)preferencesValue;

@end
