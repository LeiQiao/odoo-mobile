//
//  OdooModule.m
//

#import "OdooModule.h"
#import "AFXMLRPCSessionManager.h"
#import "Preferences.h"

static AFXMLRPCSessionManager* OdooServer = nil; /*!< odoo服务器 */

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
    OdooServer = [[AFXMLRPCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    
    NSNumber* userID = [OdooServer execute:@"authenticate" parameters:@[dbName, userName, password, @{}]];
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
        gPreferences.serverName = urlString;
        gPreferences.dbName = dbName;
        gPreferences.userID = [userID stringValue];
        gPreferences.userName = userName;
        gPreferences.password = password;
        
        callback(@[@(YES), @"登录成功"]);
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
}

@end
