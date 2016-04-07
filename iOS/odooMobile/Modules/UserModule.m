//
//  UserModule.m
//

#import "UserModule.h"
#import "AppDelegate.h"

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 用户管理模块，包括登录等逻辑处理，
 *         React-Native和Native双方都可以调用，不管哪一方调用回调消息都会通知双方
 */
@implementation UserModule

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
    /*---------- 登录，获取用户ID ----------*/
    NetworkResponse* response = [self authenticate:serverName
                                            dbName:dbName
                                          userName:userName
                                          password:password];
    
    if( !response.success )
    {
        [self postNotificationName:kLoginNetworkNotification withResponse:response];
        return;
    }
    
    /*---------- 获取用户所在组信息 ----------*/
    response = [self execute:@"res.groups"
                      method:@"search"
                  parameters:@[@[@[@"users", @"in", gPreferences.UserID]]]
                  conditions:nil];
    
    if( !response.success )
    {
        [self postNotificationName:kLoginNetworkNotification withResponse:response];
        return;
    }
    
    /*---------- 根据用户所在的组获取用户可用的菜单 ----------*/
    NSArray* groupIDs = response.responseObject;
    response = [self execute:@"ir.ui.menu"
                      method:@"search_read"
                  parameters:@[@[@[@"groups_id", @"in", groupIDs]]]
                  conditions:@{@"fields": @[@"id", @"parent_id", @"web_icon_data", @"action", @"name"]}];
    
    if( !response.success )
    {
        [self postNotificationName:kLoginNetworkNotification withResponse:response];
        return;
    }
    
    gPreferences.Menus = response.responseObject;
    [self postNotificationName:kLoginNetworkNotification withResponse:response];
}

@end
