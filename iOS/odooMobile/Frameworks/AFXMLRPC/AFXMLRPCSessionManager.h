//
//  AFXMLRPCSessionManager.h
//  odooMobile
//
//  Created by lei.qiao on 16/2/27.
//  Copyright © 2016年 LeiQiao. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>


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




extern const NSInteger kNoXMLPrefix; /*!< 没有XML前缀 */


/*!
 *  @author LeiQiao, 16-02-27
 *  @brief XMLRPC网络通讯类
 */
@interface AFXMLRPCSessionManager : AFURLSessionManager

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 使用URL地址初始化
 *  @param url URL地址
 *  @return 本类的实例对象
 */
-(instancetype) initWithBaseURL:(NSURL*)url;

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 获取默认HTTP头
 *  @param header HTTP头
 *  @return 头域值
 */
-(NSString*) defaultValueForHeader:(NSString*)header;

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 设置默认HTTP头
 *  @param header HTTP头
 *  @param value  头域值
 */
-(void) setDefaultHeader:(NSString*)header value:(NSString*)value;

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 设置权限TOKEN
 *  @param token 权限TOKEN
 */
-(void) setAuthorizationHeaderWithToken:(NSString*)token;

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 清除权限头
 */
-(void) clearAuthorizationHeader;

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 获取XMLRPC请求对象
 *  @param method     XMLRPC方法
 *  @param parameters XMLRPC参数
 *  @return 返回XMLRPC请求对象
 */
-(NSURLRequest*) XMLRPCRequestWithMethod:(NSString*)method parameters:(NSArray*)parameters;

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 获取XMLRPC请求对象
 *  @param method     XMLRPC方法
 *  @param timeout    超时时间（秒）
 *  @param parameters XMLRPC参数
 *  @return 返回XMLRPC请求对象
 */
-(NSURLRequest*) XMLRPCRequestWithMethod:(NSString*)method timeout:(NSTimeInterval)timeout parameters:(NSArray*)parameters;

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 发送XMLRPC请求
 *  @param request 请求对象
 *  @param success 成功回调
 *  @param failure 失败回调
 *  @return XMLRPC结果
 */
-(NSURLSessionDataTask*) XMLRPCTaskWithRequest:(NSURLRequest*)request
                                       success:(void (^)(NSURLSessionDataTask* task, id responseObject))success
                                       failure:(void (^)(NSURLSessionDataTask* task, NSError* error))failure;

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 执行XMLRPC请求，并返回之行结果，
 *         !!!!!!注意!!!!! 该请求会阻塞线程，直到请求成功或者失败才会返回
 *  @param method     请求方法
 *  @param timeout    超时时间（秒）
 *  @param parameters 请求参数
 *  @return 成功则返回NSArray或者NSDictionary，失败则返回NSError
 */
-(id) execute:(NSString*)method timeout:(NSTimeInterval)timeout parameters:(NSArray*)parameters;

@end
