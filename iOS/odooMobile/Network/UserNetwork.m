//
//  UserNetwork.m
//

#import "UserNetwork.h"
#import "MenuNetwork.h"

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 用户相关网络请求
 */
@implementation UserNetwork

#pragma mark
#pragma mark helper

-(void) loginThread:(NSDictionary*)parameters
{
    NSString* serverName = [parameters objectForKey:@"serverName"];
    NSString* dbName = [parameters objectForKey:@"dbName"];
    NSString* userName = [parameters objectForKey:@"userName"];
    NSString* password = [parameters objectForKey:@"password"];
    LoginResponse callback = [parameters objectForKey:@"response"];
    
    callback([self login:serverName dbName:dbName userName:userName password:password]);
}

#pragma mark
#pragma mark 登录

/**
 *  @author LeiQiao, 16/04/20
 *  @brief 登录到远程odoo服务器（异步方式）
 *  @param serverName 服务器地址，例如：http://qitaer.com:8069
 *  @param dbName     数据库名称
 *  @param userName   登录用户名
 *  @param password   登录密码
 *  @param response   登录结果回调
 */
-(void) login:(NSString*)serverName
       dbName:(NSString*)dbName
     userName:(NSString*)userName
     password:(NSString*)password
     response:(LoginResponse)response
{
    NSDictionary* parameters = @{@"serverName":serverName,
                                 @"dbName":dbName,
                                 @"userName":userName,
                                 @"password":password,
                                 @"response":response};
    [NSThread detachNewThreadSelector:@selector(loginThread:) toTarget:self withObject:parameters];
}

/**
 *  @author LeiQiao, 16/04/04
 *  @brief 登录到远程odoo服务器
 *  @param serverName 服务器地址，例如：http://qitaer.com:8069
 *  @param dbName     数据库名称
 *  @param userName   登录用户名
 *  @param password   登录密码
 *  @return 登录结果
 */
-(NetworkResponse*) login:(NSString*)serverName
                   dbName:(NSString*)dbName
                 userName:(NSString*)userName
                 password:(NSString*)password
{
    /*---------- 登录，获取用户ID ----------*/
    NetworkResponse* response = [self authenticate:serverName
                                            dbName:dbName
                                          userName:userName
                                          password:password];
    if( !response.success ) return response;
    
    /*---------- 获取用户信息 ----------*/
    response = [self execute:@"res.users"
                      method:@"search_read"
                  parameters:@[@[@[@"id", @"=", gPreferences.UserID]]]
                  conditions:@{@"fields": @[@"image",
                                            @"email",
                                            @"display_name",
                                            @"groups_id",
                                            @"company_id",
                                            @"lang",
                                            @"active"]}];
    if( !response.success ) return response;
    
    NSDictionary* responseObject = [response.responseObject objectAtIndex:0];
    // 判断账号是否激活
    if( ![[responseObject objectForKey:@"active"] boolValue] )
    {
        [response setFailedAndReason:@"账号未激活，请联系管理员"];
        return response;
    }
    // 设置个人信息
    gPreferences.UserImage = SafeCopy([responseObject objectForKey:@"image"]);
    gPreferences.UserEmail = SafeCopy([responseObject objectForKey:@"email"]);
    gPreferences.UserDisplayName = SafeCopy([responseObject objectForKey:@"display_name"]);
    gPreferences.Language = SafeCopy([responseObject objectForKey:@"lang"]);
    NSNumber* companyID = [[responseObject objectForKey:@"company_id"] objectAtIndex:0];
    NSArray* groupIDs = [responseObject objectForKey:@"groups_id"];
    
    /*---------- 获取公司信息 ----------*/
    response = [self execute:@"res.company"
                      method:@"search_read"
                  parameters:@[@[@[@"id", @"=", companyID]]]
                  conditions:@{@"fields": @[@"logo",
                                            @"currency_id",
                                            @"display_name"]}];
    if( !response.success ) return response;
    
    // 设置公司信息
    responseObject = [response.responseObject objectAtIndex:0];
    gPreferences.CompanyDisplayName = SafeCopy([responseObject objectForKey:@"display_name"]);
    gPreferences.CompanyCurrency = SafeCopy([responseObject objectForKey:@"currency_id"]);
    gPreferences.CompanyLogoImage = SafeCopy([responseObject objectForKey:@"logo"]);
    
    /*---------- 根据用户所在的组获取用户可用的菜单 ----------*/
    MenuNetwork* menu = [[MenuNetwork alloc] init];
    response = [menu getMenuByGroupIDs:groupIDs];
    return response;
}

@end
