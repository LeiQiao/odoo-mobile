//
//  RCTPreferences.m
//

#import "RCTPreferences.h"


/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 提供给React-Native使用的全局变量
 */
@implementation RCTPreferences

RCT_EXPORT_MODULE(Preferences)

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 获取全局变量的值
 *  @param preferencesName 全局变量的名称
 *  @param callback        获取到全局变量后的回调函数
 */
RCT_EXPORT_METHOD(get:(NSString*)preferencesName callback:(RCTResponseSenderBlock)callback)
{
    NSString* selectorName = [NSString stringWithFormat:@"get%@", preferencesName];
    id object = [gPreferences performSelector:NSSelectorFromString(selectorName)];
    if( object ) callback(@[object]);
    else callback(@[]);
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 设置全局变量的值
 *  @param preferencesName  全局变量的名称
 *  @param preferencesValue 全局变量的值
 *  @param callback         获取到全局变量后的回调函数
 */
RCT_EXPORT_METHOD(set:(NSString*)preferencesName value:(id)preferencesValue)
{
    NSString* selectorName = [NSString stringWithFormat:@"set%@:", preferencesName];
    [gPreferences performSelector:NSSelectorFromString(selectorName) withObject:preferencesValue];
}

@end
