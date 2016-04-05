//
//  PreferenceModule.h
//

#import "CXBaseModule.h"

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 全局变量模块，可以指定保存到内存、文件还是加密串中
 */
@interface PreferenceModule : CXBaseModule

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 保存到内存
 *  @param key   名称
 *  @param value 值
 */
-(void) set:(NSString*)key value:(id)value;

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 从内存获取值
 *  @param key 名称
 */
-(void) get:(NSString*)key callback:(RCTResponseSenderBlock)callback;

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 保存到文件
 *  @param key   名称
 *  @param value 值
 */
-(void) setUserDefault:(NSString*)key value:(id)value;

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 从文件获取值
 *  @param key 名称
 */
-(void) getUserDefault:(NSString*)key callback:(RCTResponseSenderBlock)callback;

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 保存到加密串
 *  @param key   名称
 *  @param value 值
 */
-(void) setKeyChain:(NSString*)key value:(id)value;

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 从加密串获取值
 *  @param key 名称
 */
-(void) getKeyChain:(NSString*)key callback:(RCTResponseSenderBlock)callback;

@end
