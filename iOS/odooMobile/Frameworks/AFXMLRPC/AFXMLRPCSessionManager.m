//
//  AFXMLRPCSessionManager.m
//  odooMobile
//
//  Created by lei.qiao on 16/2/27.
//  Copyright © 2016年 LeiQiao. All rights reserved.
//

#import "AFXMLRPCSessionManager.h"
#import "WPXMLRPC.h"

// 错误，没有XML前缀
const NSInteger kNoXMLPrefix = -999;

#define AFXMLRPCLog NSLog

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief XMLRPC网络通讯类
 */
@implementation AFXMLRPCSessionManager {
    NSURL* _baseURL;                        /*!< URL地址 */
    NSMutableDictionary* _defaultHeaders;   /*!< 默认HTTP头 */
}

#pragma mark
#pragma mark init & dealloc

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 使用URL地址初始化
 *  @param url URL地址
 *  @return 本类的实例对象
 */
-(instancetype) initWithBaseURL:(NSURL*)url
{
    if( self = [self initWithSessionConfiguration:nil] )
    {
        _baseURL = url;
        _defaultHeaders = [[NSMutableDictionary alloc] init];
        
        AFHTTPResponseSerializer* serializer = [[AFHTTPResponseSerializer alloc] init];
        serializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/plain", @"text/html", @"text/xml"]];
        self.responseSerializer = serializer;
        
        /*---------- 设置HTTP默认头 ----------*/
        if( [[[UIDevice currentDevice] systemVersion] compare:@"7.1" options:NSNumericSearch] != NSOrderedAscending )
        {
            // if iOS 7.1 or later
            [self setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];
        }
        else
        {
            // Disable compression by default, since it causes connection problems with some hosts
            // Fixed in iOS SDK 7.1 see: https://developer.apple.com/library/ios/releasenotes/General/RN-iOSSDK-7.1/
            [self setDefaultHeader:@"Accept-Encoding" value:@"identity"];
        }
        [self setDefaultHeader:@"Content-Type" value:@"text/xml"];
        
        NSString* applicationUserAgent = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"];
        if( applicationUserAgent )
        {
            [self setDefaultHeader:@"User-Agent" value:applicationUserAgent];
        }
        else
        {
            [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)]];
        }
    }
    return self;
}
#pragma mark
#pragma mark member functions

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 获取默认HTTP头
 *  @param header HTTP头
 *  @return 头域值
 */
-(NSString*) defaultValueForHeader:(NSString*)header
{
    return [_defaultHeaders valueForKey:header];
}

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 设置默认HTTP头
 *  @param header HTTP头
 *  @param value  头域值
 */
-(void) setDefaultHeader:(NSString*)header value:(NSString*)value
{
    [_defaultHeaders setValue:value forKey:header];
}

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 设置权限TOKEN
 *  @param token 权限TOKEN
 */
-(void) setAuthorizationHeaderWithToken:(NSString*)token
{
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
}

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 清除权限头
 */
-(void) clearAuthorizationHeader
{
    [_defaultHeaders removeObjectForKey:@"Authorization"];
}

/*!
 *  @author LeiQiao, 16-02-27
 *  @brief 获取XMLRPC请求对象
 *  @param method     XMLRPC方法
 *  @param parameters XMLRPC参数
 *  @return 返回XMLRPC请求对象
 */
-(NSURLRequest*) XMLRPCRequestWithMethod:(NSString*)method
                              parameters:(NSArray*)parameters
{
    // 创建POST方式的请求并设置默认HTTP头
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:_baseURL];
    request.timeoutInterval = 10;
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:_defaultHeaders];
    
    // 将XMLRPC请求添加到请求中
    WPXMLRPCEncoder* encoder = [[WPXMLRPCEncoder alloc] initWithMethod:method andParameters:parameters];
    NSData* body = [encoder dataEncodedWithError:nil];
    [request setHTTPBody:body];
    
    return request;
}

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
                                       failure:(void (^)(NSURLSessionDataTask* task, NSError* error))failure
{
    /*---------- 成功回调，解析XMLRPC结果，并调用提供的成功回调 -----------*/
    void (^xmlrpcSuccess)(NSURLSessionDataTask*, id) = ^(NSURLSessionDataTask* task, id responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            // 解析XMLRPC
            WPXMLRPCDecoder* decoder = [[WPXMLRPCDecoder alloc] initWithData:responseObject];
            NSError* err = nil;
            
            AFXMLRPCLog(@"[XML-RPC] < %@", [[NSString alloc] initWithData:responseObject
                                                                 encoding:NSUTF8StringEncoding]);
            
            // 解析失败
            if( [decoder isFault] || ([decoder object] == nil) )
            {
                err = [decoder error];
            }
            
            if( [decoder object] == nil )
            {
                AFXMLRPCLog(@"Blog returned invalid data (URL: %@)\n%@", request.URL.absoluteString, responseObject);
            }
            
            // 最终解析出来的数据结果
            id object = [[decoder object] copy];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                // 失败
                if( err )
                {
                    if( failure )
                    {
                        failure(task, err);
                    }
                }
                // 成功
                else
                {
                    if( success )
                    {
                        success(task, object);
                    }
                }
            });
        });
    };
    
    /*---------- 失败的回调，网络调用失败 ----------*/
    void (^xmlrpcFailure)(NSURLSessionDataTask*, NSError*) = ^(NSURLSessionDataTask* task, NSError* error) {
        
        AFXMLRPCLog(@"[XML-RPC] ! %@", [error localizedDescription]);
        
        // 失败
        if( failure )
        {
            failure(task, error);
        }
    };
    
    // 创建网络任务
    NSURLSessionDataTask* task = [self dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse* response, id responseObject, NSError* error) {
        // 网络调用失败
        if( error )
        {
            xmlrpcFailure(task, error);
        }
        // 网络调用成功
        else
        {
            xmlrpcSuccess(task, responseObject);
        }
    }];
    
    NSString* requestString = [[NSString alloc] initWithData:[request HTTPBody]
                                                    encoding:NSUTF8StringEncoding];
    AFXMLRPCLog(@"[XML-RPC] > %@", requestString);
    
    // 开始网络传输
    [task resume];
    
    return task;
}

@end
