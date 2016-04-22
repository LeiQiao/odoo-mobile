// AFJSONRPCClient.m
// 
// Created by wiistriker@gmail.com
// Copyright (c) 2013 JustCommunication
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFJSONRPCClient.h"

#import <objc/runtime.h>

NSString * const AFJSONRPCErrorDomain = @"com.alamofire.networking.json-rpc";

static NSString * AFJSONRPCLocalizedErrorMessageForCode(NSInteger code) {
    switch(code) {
        case -32700:
            return @"Parse Error";
        case -32600:
            return @"Invalid Request";
        case -32601:
            return @"Method Not Found";
        case -32602:
            return @"Invalid Params";
        case -32603:
            return @"Internal Error";
        default:
            return @"Server Error";
    }
}

@interface AFJSONRPCProxy : NSProxy
- (id)initWithClient:(AFJSONRPCClient *)client
            protocol:(Protocol *)protocol;
@end

#pragma mark -

@interface AFJSONRPCClient ()
@property (readwrite, nonatomic, strong) NSURL *endpointURL;
@property (readwrite, nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@end

@implementation AFJSONRPCClient

+ (instancetype)clientWithEndpointURL:(NSURL *)URL {
    return [[self alloc] initWithEndpointURL:URL];
}

- (id)initWithEndpointURL:(NSURL *)URL {
    NSParameterAssert(URL);

    self = [super initWithSessionConfiguration:nil];
    if (!self) {
        return nil;
    }

    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFHTTPResponseSerializer* serializer = [[AFHTTPResponseSerializer alloc] init];
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"application/json-rpc", @"application/jsonrequest", nil];
    self.responseSerializer = serializer;

    self.endpointURL = URL;

    return self;
}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                         parameters:(id)parameters
{
    return [self requestWithMethod:method
                        parameters:parameters
                           timeout:-1
                         requestId:nil];
}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                         parameters:(id)parameters
                            timeout:(NSTimeInterval)timeout
{
    return [self requestWithMethod:method
                        parameters:parameters
                           timeout:timeout
                         requestId:@(1)];
}

- (NSURLRequest *)requestWithMethod:(NSString *)method
                         parameters:(id)parameters
                            timeout:(NSTimeInterval)timeout
                          requestId:(id)requestId
{
    NSParameterAssert(method);

    if (!parameters) {
        parameters = @[];
    }

    NSAssert([parameters isKindOfClass:[NSDictionary class]] || [parameters isKindOfClass:[NSArray class]], @"Expect NSArray or NSDictionary in JSONRPC parameters");

    if (!requestId) {
        requestId = @(1);
    }

    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = method;
    payload[@"params"] = parameters;
    if( requestId )
    {
        payload[@"id"] = [requestId description];
    }
    
    NSMutableURLRequest* request = [self.requestSerializer requestWithMethod:@"POST"
                                                                   URLString:[self.endpointURL absoluteString] parameters:payload
                                                                       error:nil];
    request.timeoutInterval = timeout;
    
    return request;
}

- (void)invokeMethod:(NSString *)method
             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self invokeMethod:method withParameters:@[] success:success failure:failure];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self invokeMethod:method withParameters:parameters timeout:-1 requestId:@(1) success:success failure:failure];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
             timeout:(NSTimeInterval)timeout
           requestId:(id)requestId
             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:method
                                         parameters:parameters
                                            timeout:timeout
                                          requestId:requestId];
    
    [self invokeRequest:request success:success failure:failure];
}

-(NSURLSessionDataTask*) invokeRequest:(NSURLRequest*)request
                               success:(void (^)(NSURLSessionDataTask* task, id responseObject))success
                               failure:(void (^)(NSURLSessionDataTask* task, NSError* error))failure
{
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse* response, id responseObject, NSError* error) {
        NSInteger code = 0;
        NSString *message = nil;
        id data = nil;

        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id result = responseObject[@"result"];
            id error = responseObject[@"error"];

            if (result && result != [NSNull null]) {
                if (success) {
                    success(task, result);
                    return;
                }
            } else if (error && error != [NSNull null]) {
                if ([error isKindOfClass:[NSDictionary class]]) {
                    if (error[@"code"]) {
                        code = [error[@"code"] integerValue];
                    }

                    if (error[@"message"]) {
                        message = error[@"message"];
                    } else if (code) {
                        message = AFJSONRPCLocalizedErrorMessageForCode(code);
                    }

                    data = error[@"data"];
                } else {
                    message = NSLocalizedStringFromTable(@"Unknown Error", @"AFJSONRPCClient", nil);
                }
            } else {
                message = NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"AFJSONRPCClient", nil);
            }
        } else {
            message = NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"AFJSONRPCClient", nil);
        }

        if (failure) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            if (message) {
                userInfo[NSLocalizedDescriptionKey] = message;
            }

            if (data) {
                userInfo[@"data"] = data;
            }

            NSError *error = [NSError errorWithDomain:AFJSONRPCErrorDomain code:code userInfo:userInfo];

            failure(task, error);
        }
    }];
    
    // 开始网络传输
    [task resume];
    
    return task;
}

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 执行JSONRPC请求，并返回之行结果，
 *         !!!!!!注意!!!!! 该请求会阻塞线程，直到请求成功或者失败才会返回
 *  @param method     请求方法
 *  @param timeout    超时时间（秒）
 *  @param parameters 请求参数
 *  @return 成功则返回NSArray或者NSDictionary，失败则返回NSError
 */
-(id) execute:(NSString*)method timeout:(NSTimeInterval)timeout parameters:(NSArray*)parameters
{
    __block id result = nil;
    NSCondition* networkFinishedSignal = [NSCondition new];
    
    NSURLRequest* request = [self requestWithMethod:method parameters:parameters timeout:timeout];
    [self invokeRequest:request
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    result = responseObject;
                    
                    [networkFinishedSignal lock];
                    [networkFinishedSignal signal];
                    [networkFinishedSignal unlock];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    result = error;
                    
                    [networkFinishedSignal lock];
                    [networkFinishedSignal signal];
                    [networkFinishedSignal unlock];
                }];
    
    [networkFinishedSignal lock];
    [networkFinishedSignal wait];
    [networkFinishedSignal unlock];
    
    return result;
}

#pragma mark - AFHTTPClient

- (id)proxyWithProtocol:(Protocol *)protocol {
    return [[AFJSONRPCProxy alloc] initWithClient:self protocol:protocol];
}

@end

#pragma mark -

typedef void (^AFJSONRPCProxySuccessBlock)(id responseObject);
typedef void (^AFJSONRPCProxyFailureBlock)(NSError *error);

@interface AFJSONRPCProxy ()
@property (readwrite, nonatomic, strong) AFJSONRPCClient *client;
@property (readwrite, nonatomic, strong) Protocol *protocol;
@end

@implementation AFJSONRPCProxy

- (id)initWithClient:(AFJSONRPCClient*)client
            protocol:(Protocol *)protocol
{
    self.client = client;
    self.protocol = protocol;

    return self;
}

- (BOOL)respondsToSelector:(SEL)selector {
    struct objc_method_description description = protocol_getMethodDescription(self.protocol, selector, YES, YES);

    return description.name != NULL;
}

- (NSMethodSignature *)methodSignatureForSelector:(__unused SEL)selector {
    // 0: v->RET || 1: @->self || 2: :->SEL || 3: @->arg#0 (NSArray) || 4,5: ^v->arg#1,2 (block)
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:@^v^v"];

    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSParameterAssert(invocation.methodSignature.numberOfArguments == 5);

    NSString *RPCMethod = [NSStringFromSelector([invocation selector]) componentsSeparatedByString:@":"][0];

    __unsafe_unretained id arguments;
    __unsafe_unretained AFJSONRPCProxySuccessBlock unsafeSuccess;
    __unsafe_unretained AFJSONRPCProxyFailureBlock unsafeFailure;
    id target = nil;

    [invocation getArgument:&arguments atIndex:2];
    [invocation getArgument:&unsafeSuccess atIndex:3];
    [invocation getArgument:&unsafeFailure atIndex:4];
    
    [invocation invokeWithTarget:target];

    __strong AFJSONRPCProxySuccessBlock strongSuccess = [unsafeSuccess copy];
    __strong AFJSONRPCProxyFailureBlock strongFailure = [unsafeFailure copy];

    [self.client invokeMethod:RPCMethod withParameters:arguments success:^(NSURLSessionDataTask *task, id responseObject) {
        if (strongSuccess) {
            strongSuccess(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (strongFailure) {
            strongFailure(error);
        }
    }];
}

@end
