//
//  OdooModule.m
//

#import "OdooModule.h"
#import "AFXMLRPCSessionManager.h"
#import "Preferences.h"

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
 *  @author LeiQiao, 16/04/04
 *  @brief 与odoo服务器进行通讯的接口类，使用XMLRPC协议
 */
@implementation OdooModule

RCT_EXPORT_MODULE();

/*!
 *  @author LeiQiao, 16/04/04
 *  @brief 授权，登录接口
 *  @param urlString 服务器接口
 *  @param dbName    数据库名称
 *  @param userName  用户名
 *  @param password  用户密码
 *  @param callback  登录回调
 */
RCT_EXPORT_METHOD(authenticate:(NSString*)serverName
                  dbName:(NSString*)dbName
                  userName:(NSString*)userName
                  password:(NSString*)password
                  callback:(RCTResponseSenderBlock)callback)
{
    NSString* urlString = [NSString stringWithFormat:@"%@/xmlrpc/2/common", serverName];
    AFXMLRPCSessionManager* odooServer = [[AFXMLRPCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    NSNumber* userID = [odooServer execute:@"authenticate" parameters:@[dbName, userName, password, @{}]];
    
    if( [userID isKindOfClass:[NSError class]] )
    {
        NSError* error = (NSError*)userID;
        if( error.code == 1 )
        {
            callback(@[@(NO), @"登录失败，数据库不存在"]);
        }
        if( error.code == -1001 )
        {
            callback(@[@(NO), @"登录失败，服务器无法连接"]);
        }
        else
        {
            callback(@[@(NO), @"登录失败"]);
        }
    }
    else if( [userID integerValue] == 0 )
    {
        callback(@[@(NO), @"登录失败，用户名密码错误"]);
    }
    else
    {
        gPreferences.serverName = serverName;
        gPreferences.dbName = dbName;
        gPreferences.userID = [userID stringValue];
        gPreferences.userName = userName;
        gPreferences.password = password;
        
        callback(@[@(YES), @"登录成功", userID]);
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
 */
RCT_EXPORT_METHOD(execute:(NSString*)model
                  method:(NSString*)method
                  parameters:(NSArray*)parameters
                  conditions:(NSDictionary*)conditions
                  callback:(RCTResponseSenderBlock)callback)
{
    NSString* urlString = [NSString stringWithFormat:@"%@/xmlrpc/2/object", gPreferences.serverName];
    AFXMLRPCSessionManager* odooServer = [[AFXMLRPCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    id response = [odooServer execute:@"execute_kw" parameters:@[gPreferences.dbName,
                                                                 @([gPreferences.userID integerValue]),
                                                                 gPreferences.password,
                                                                 model,
                                                                 method,
                                                                 parameters,
                                                                 conditions]];
    
    if( [response isKindOfClass:[NSError class]] )
    {
        NSError* error = (NSError*)response;
        NSString* failedReason = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        failedReason = unicodeToUTF8(failedReason);
        callback(@[@(NO), failedReason]);
    }
    else
    {
        callback(@[@(YES), @"", response]);
    }
}

@end
