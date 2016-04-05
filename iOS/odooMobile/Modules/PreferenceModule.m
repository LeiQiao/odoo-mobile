//
//  PreferenceModule.m
//

#import "PreferenceModule.h"
#import "Preferences.h"
#import "JSON.h"

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 全局变量模块，可以指定保存到内存、文件还是加密串中
 */
@implementation PreferenceModule

RCT_EXPORT_MODULE()

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 保存到内存
 *  @param key   名称
 *  @param value 值
 */
RCT_EXPORT_METHOD(set:(NSString*)key value:(id)value)
{
    NSMutableDictionary* dict = gPreferences.ReactNativeStaticPreferences;
    dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    [dict setObject:value forKey:key];
    gPreferences.ReactNativeStaticPreferences = dict;
}

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 从内存获取值
 *  @param key 名称
 */
RCT_EXPORT_METHOD(get:(NSString*)key callback:(RCTResponseSenderBlock)callback)
{
    NSMutableDictionary* dict = gPreferences.ReactNativeStaticPreferences;
    id value = [dict objectForKey:key];
    if( value )
    {
        callback(@[value]);
    }
    else
    {
        callback(@[]);
    }
}

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 保存到文件
 *  @param key   名称
 *  @param value 值
 */
RCT_EXPORT_METHOD(setUserDefault:(NSString*)key value:(NSString*)value)
{
    NSMutableDictionary* dict = gPreferences.ReactNativeUserDefaultPreferences;
    dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    [dict setObject:value forKey:key];
    gPreferences.ReactNativeUserDefaultPreferences = dict;
}

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 从文件获取值
 *  @param key 名称
 */
RCT_EXPORT_METHOD(getUserDefault:(NSString*)key callback:(RCTResponseSenderBlock)callback)
{
    NSMutableDictionary* dict = gPreferences.ReactNativeUserDefaultPreferences;
    id value = [dict objectForKey:key];
    if( value )
    {
        callback(@[value]);
    }
    else
    {
        callback(@[]);
    }
}

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 保存到加密串
 *  @param key   名称
 *  @param value 值
 */
RCT_EXPORT_METHOD(setKeyChain:(NSString*)key value:(NSString*)value)
{
    NSMutableDictionary* dict = [gPreferences.ReactNativeKeyChainPreferences objectFromJSONString];
    dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    [dict setObject:value forKey:key];
    gPreferences.ReactNativeKeyChainPreferences = [dict JSONString];
}

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 从加密串获取值
 *  @param key 名称
 */
RCT_EXPORT_METHOD(getKeyChain:(NSString*)key callback:(RCTResponseSenderBlock)callback)
{
    NSMutableDictionary* dict = [gPreferences.ReactNativeKeyChainPreferences objectFromJSONString];
    id value = [dict objectForKey:key];
    if( value )
    {
        callback(@[value]);
    }
    else
    {
        callback(@[]);
    }
}

@end
