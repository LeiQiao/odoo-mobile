//
//  AFXMLRPCSessionManager.h
//  odooMobile
//
//  Created by lei.qiao on 16/2/27.
//  Copyright © 2016年 LeiQiao. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

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
-(NSURLRequest*) XMLRPCRequestWithMethod:(NSString*)method
                              parameters:(NSArray*)parameters;

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

@end
