//
//  OdooNetwork.m
//

#import "OdooNetwork.h"

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
 *  @author LeiQiao, 16-04-09
 *  @brief Odoo网络操作类
 */
@implementation OdooNetwork

#pragma mark
#pragma mark member functions

/*!
 *  @author LeiQiao, 16/04/04
 *  @brief 授权，登录接口
 *  @param urlString 服务器接口
 *  @param dbName    数据库名称
 *  @param userName  用户名
 *  @param password  用户密码
 *  @param callback  登录回调
 *  @return 返回网络调用结果
 */
-(NetworkResponse*) authenticate:(NSString*)serverName
                          dbName:(NSString*)dbName
                        userName:(NSString*)userName
                        password:(NSString*)password
{
    NSString* urlString = [NSString stringWithFormat:@"%@/xmlrpc/2/common", serverName];
    AFXMLRPCSessionManager* odooServer = [[AFXMLRPCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    NSNumber* userID = [odooServer execute:@"authenticate" timeout:10 parameters:@[dbName, userName, password, @{}]];
    
    if( [userID isKindOfClass:[NSError class]] )
    {
        NSError* error = (NSError*)userID;
        if( error.code == 1 )
        {
            return [[NetworkResponse alloc] initWithSuccess:NO andFailedReason:@"登录失败，数据库不存在"];
        }
        if( error.code == -1001 )
        {
            return [[NetworkResponse alloc] initWithSuccess:NO andFailedReason:@"登录失败，服务器无法连接"];
        }
        else
        {
            return [[NetworkResponse alloc] initWithSuccess:NO andFailedReason:@"登录失败"];
        }
    }
    else if( [userID integerValue] == 0 )
    {
        return [[NetworkResponse alloc] initWithSuccess:NO andFailedReason:@"登录失败，用户名密码错误"];
    }
    else
    {
        // 登录成功设置全局变量
        gPreferences.ServerName = serverName;
        gPreferences.DBName = dbName;
        gPreferences.UserID = userID;
        gPreferences.UserName = userName;
        gPreferences.Password = password;
        
        NetworkResponse* response = [[NetworkResponse alloc] initWithSuccess:YES andFailedReason:@"登录成功"];
        response.responseObject = userID;
        return response;
    }
}

/*!
 *  @author LeiQiao, 16/04/04
 *  @brief 执行增删改查功能
 *  @param model      模块名称
 *  @param method     方法名称
 *  @param parameters 参数列表
 *  @param conditions 筛选条件
 *  @param callback   功能回调
 *  @return 返回网络调用结果
 */
-(NetworkResponse*) execute:(NSString*)model
                     method:(NSString*)method
                 parameters:(NSArray*)parameters
                 conditions:(NSDictionary*)conditions
{
    if( !parameters ) parameters = @[];
    if( !conditions ) conditions = @{};
    
    NSString* urlString = [NSString stringWithFormat:@"%@/xmlrpc/2/object", gPreferences.ServerName];
    AFXMLRPCSessionManager* odooServer = [[AFXMLRPCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    id response = [odooServer execute:@"execute_kw" timeout:30 parameters:@[gPreferences.DBName,
                                                                            @([gPreferences.UserID integerValue]),
                                                                            gPreferences.Password,
                                                                            model,
                                                                            method,
                                                                            parameters,
                                                                            conditions]];
    
    if( [response isKindOfClass:[NSError class]] )
    {
        NSError* error = (NSError*)response;
        NSString* failedReason = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        failedReason = unicodeToUTF8(failedReason);
        return [[NetworkResponse alloc] initWithSuccess:NO andFailedReason:failedReason];
    }
    else
    {
        NetworkResponse* result = [[NetworkResponse alloc] initWithSuccess:YES andFailedReason:@"请求成功"];
        result.responseObject = response;
        return result;
    }
}

@end
