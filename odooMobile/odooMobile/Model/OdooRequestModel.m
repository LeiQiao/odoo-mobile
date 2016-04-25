//
//  OdooRequestModel.m
//

#import "OdooRequestModel.h"
#import "AFXMLRPCSessionManager.h"
#import "Preferences.h"

/*!
 *  @author LeiQiao, 16-04-05
 *  @brief 将unicode编码转换成UTF8编码
 *  @param unicodeString unicode编码的字符串
 *  @return utf8编码的字符串
 */
NSString* unicodeToUTF8(NSString* unicodeString)
{
    NSString *tempStr1 = [unicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief Odoo的请求参数列表
 */
@implementation OdooRequestParam

#pragma mark
#pragma mark class method

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief 创建网络请求
 *  @param method     方法
 *  @param parameters 参数
 */
+(OdooRequestParam*) execute:(NSString*)method
                  parameters:(NSArray*)parameters
{
    OdooRequestParam* reqParam = [[OdooRequestParam alloc] init];
    reqParam->_method = method;
    if( parameters )
    {
        reqParam->_parameters = parameters;
    }
    else
    {
        reqParam->_parameters = @[];
    }
    return reqParam;
}

@end

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief 包装了Odoo的XMLRPC的传输方式
 */
@implementation OdooRequestModel

#pragma mark
#pragma mark helper

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief 发送XMLRPC请求
 */
-(void) sendRequest
{
    AFXMLRPCSessionManager* xmlRPC = [[AFXMLRPCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_requestURLString]];
    NSURLRequest*request = [xmlRPC XMLRPCRequestWithMethod:self.reqParam.method
                                                   timeout:self.reqParam.timeout
                                                parameters:self.reqParam.parameters];
    
    [xmlRPC XMLRPCTaskWithRequest:request
                          success:^(NSURLSessionDataTask* task, id responseObject) {
                              // 设置返回值
                              self.retParam.success = YES;
                              self.retParam.failedCode = 0;
                              self.retParam.failedReason = @"请求成功";
                              if( [responseObject isKindOfClass:[NSDictionary class]] )
                              {
                                  [self.retParam.userInfo setValuesForKeysWithDictionary:responseObject];
                              }
                              
                              // 成功回调
                              if( _successCallback )
                              {
                                  _successCallback(responseObject);
                              }
                          }
                          failure:^(NSURLSessionDataTask* task, NSError* error) {
                              // 设置失败结果
                              self.retParam.success = NO;
                              self.retParam.failedCode = [@(error.code) stringValue];
                              if( error.code == 1 )
                              {
                                  self.retParam.failedReason = @"登录失败，数据库不存在";
                              }
                              if( error.code == -1001 )
                              {
                                  self.retParam.failedReason = @"登录失败，服务器无法连接";
                              }
                              else
                              {
                                  NSString* failedReason = [error.userInfo objectForKey:@"NSLocalizedDescription"];
                                  if( failedReason )
                                  {
                                      self.retParam.failedReason = unicodeToUTF8(failedReason);
                                  }
                                  else
                                  {
                                      self.retParam.failedReason = @"连接失败，请重试";
                                  }
                              }
                              
                              // 失败回调
                              if( _failureCallback )
                              {
                                  _failureCallback(error);
                              }
                          }];
}

#pragma mark
#pragma mark override

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief 通知回调
 */
-(void) callObserver
{
    [self.observeModel callObserver:self.observeCallback withObject:self.observeModel withObject:self.retParam];
}

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief POST请求
 */
-(void) doPOST
{
    [self sendRequest];
}

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief GET请求
 */
-(void) doGET
{
    [self sendRequest];
}

@end
