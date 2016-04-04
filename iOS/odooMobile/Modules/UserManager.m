//
//  UserManager.m
//

#import "UserManager.h"
#import "AFXMLRPCSessionManager.h"
#import "AppDelegate.h"
#import "Preferences.h"
#import "ModuleNotification.h"
#import "NetworkResponse.h"

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 用户管理模块，包括登录等逻辑处理，
 *         React-Native和Native双方都可以调用，不管哪一方调用回调消息都会通知双方
 */
@implementation UserManager

RCT_EXPORT_MODULE();

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 登录到远程odoo服务器
 *  @param serverName 服务器地址，例如：http://qitaer.com:8069
 *  @param DBName     数据库名称
 *  @param userName   登录用户名
 *  @param password   登录密码
 */
RCT_EXPORT_METHOD(login:(NSString*)serverName
                  DBName:(NSString*)dbName
                  userName:(NSString*)userName
                  password:(NSString*)password)
{
    NSString* urlString = [NSString stringWithFormat:@"%@/xmlrpc/2/common", serverName];
    AFXMLRPCSessionManager* manager = [[AFXMLRPCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    NSURLRequest* request = [manager XMLRPCRequestWithMethod:@"authenticate" parameters:@[dbName, userName, password, @{}]];
    [manager XMLRPCTaskWithRequest:request success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NetworkResponse* result = [[NetworkResponse alloc] initWithSuccess:NO andFailedReason:@"登录失败，用户名密码错误"];
        
        NSString* userID = SafeCopy(responseObject);
        if( [userID integerValue] > 0 )
        {
            gPreferences.serverName = serverName;
            gPreferences.dbName = dbName;
            gPreferences.userID = userID;
            gPreferences.userName = userName;
            gPreferences.password = password;
            [result setSuccessAndMessage:@"登录成功"];
            
            [self getUserGroup];
        }
        else
        {
            [self postNotificationName:kLoginNetworkNotification withResponse:result];
        }
        
        [self postNotificationName:kLoginNetworkNotification withResponse:result];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NetworkResponse* result = [[NetworkResponse alloc] initWithSuccess:NO andFailedReason:@"登录失败，请重试"];
        
        if( error.code == -1001 )
        {
            [result setFailedAndReason:@"登录失败，服务器无法连接"];
        }
        else if( error.code == 1 )
        {
            [result setFailedAndReason:@"登录失败，数据库不存在"];
        }
        
        [self postNotificationName:kLoginNetworkNotification withResponse:result];
    }];
}

@end
