//
//  UserModel.m
//

#import "UserModel.h"
#import "OdooRequestModel.h"
#import "Preferences.h"
#import "GlobalModels.h"

/*!
 *  @author LeiQiao, 16/05/08
 *  @brief 使用货币表示法返回金额
 *  @param amount 金额
 *  @return 金额的货币表示法
 */
NSString* getMonetary(NSNumber* amount)
{
    NSString* currency = [gPreferences.CompanyCurrency uppercaseString];
    if( [currency isEqualToString:@"USD"] )
    {
        return [NSString stringWithFormat:@"$ %.02f", [amount floatValue]];
    }
    if( [currency isEqualToString:@"CNY"] )
    {
        return [NSString stringWithFormat:@"%.02f ¥", [amount floatValue]];
    }
    return [NSString stringWithFormat:@"%.02f", [amount floatValue]];
}

@implementation UserModel

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 请求制定服务器的所有数据库
 *  @param serverName 服务器地址
 */
-(void) requestDatabase:(NSString*)serverName
{
    OdooRequestModel* request = [[OdooRequestModel alloc] initWithObserveModel:self andCallback:@selector(userModel:requestDatabase:)];
    request.reqParam = [OdooRequestParam execute:@"list" parameters:nil];
    request.reqParam.timeout = 10;
    [request POST:[NSString stringWithFormat:@"%@/xmlrpc/2/db", serverName]
          success:^(id responseObject) {
              request.retParam[@"Databases"] = responseObject;
          }];
}

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 查找指定的服务器是否存在指定数据库
 *  @param serverName 服务器地址
 *  @param dbName     数据库名称
 */
-(void) checkDatabaseExist:(NSString*)serverName dbName:(NSString*)dbName
{
    OdooRequestModel* request = [[OdooRequestModel alloc] initWithObserveModel:self andCallback:@selector(userModel:checkDatabaseExist:)];
    request.reqParam = [OdooRequestParam execute:@"db_exist" parameters:@[dbName]];
    request.reqParam.timeout = 10;
    [request POST:[NSString stringWithFormat:@"%@/xmlrpc/2/db", serverName]
          success:^(id responseObject) {
              if( ![responseObject boolValue] )
              {
                  request.retParam.success = NO;
                  request.retParam.failedCode = @"-1";
                  request.retParam.failedReason = @"数据库不存在";
              }
          }];
}

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 登录
 *  @param serverName 服务器地址
 *  @param dbName     数据库名称
 *  @param userName   用户名
 *  @param password   密码
 */
-(void) login:(NSString*)serverName
       dbName:(NSString*)dbName
     userName:(NSString*)userName
     password:(NSString*)password
{
    NSDictionary* parameters = @{@"serverName":serverName,
                                 @"dbName":dbName,
                                 @"userName":userName,
                                 @"password":password};
    [NSThread detachNewThreadSelector:@selector(loginThread:) toTarget:self withObject:parameters];
}

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 登录线程
 *  @param parameters 参数，从login函数传来登录所需的信息
 */
-(void) loginThread:(NSDictionary*)parameters
{
    NSString* serverName = [parameters objectForKey:@"serverName"];
    NSString* dbName = [parameters objectForKey:@"dbName"];
    NSString* userName = [parameters objectForKey:@"userName"];
    NSString* password = [parameters objectForKey:@"password"];
    
    OdooRequestModel* request = [[OdooRequestModel alloc] initWithObserveModel:self andCallback:@selector(userModel:login:)];
    
    /*---------- 授权登录 ----------*/
    request.reqParam = [OdooRequestParam execute:@"authenticate" parameters:@[dbName, userName, password, @{}]];
    request.reqParam.timeout = 10;
    NSError* error = nil;
    id responseObject = [request asyncPOST:[NSString stringWithFormat:@"%@/xmlrpc/2/common", serverName] error:&error];
    if( error )
    {
        [request callObserver];
        return;
    }
    // 判断是否登录成功
    if( [responseObject integerValue] == 0 )
    {
        request.retParam.success = NO;
        request.retParam.failedCode = @"-1";
        request.retParam.failedReason = @"登录失败，用户名密码错误";
        [request callObserver];
        return;
    }
    
    gPreferences.ServerName = serverName;
    gPreferences.DBName = dbName;
    gPreferences.UserID = responseObject;
    gPreferences.UserName = userName;
    gPreferences.Password = password;
    
    /*---------- 获取用户信息 ----------*/
    error = nil;
    responseObject = [request asyncExecute:@"res.users"
                                    method:@"search_read"
                                parameters:@[@[@[@"id", @"=", gPreferences.UserID]]]
                                conditions:@{@"fields": @[@"image",
                                                          @"email",
                                                          @"display_name",
                                                          @"groups_id",
                                                          @"company_id",
                                                          @"lang",
                                                          @"active"]} error:&error];
    if( error )
    {
        [request callObserver];
        return;
    }
    // 判断账号是否激活
    responseObject = [responseObject objectAtIndex:0];
    if( ![[responseObject objectForKey:@"active"] boolValue] )
    {
        request.retParam.success = NO;
        request.retParam.failedCode = @"-1";
        request.retParam.failedReason = @"账号未激活，请联系管理员";
        [request callObserver];
        return;
    }
    
    gPreferences.UserImage = SafeCopy([responseObject objectForKey:@"image"]);
    gPreferences.UserEmail = SafeCopy([responseObject objectForKey:@"email"]);
    gPreferences.UserDisplayName = SafeCopy([responseObject objectForKey:@"display_name"]);
    gPreferences.Language = SafeCopy([responseObject objectForKey:@"lang"]);
    
    NSNumber* companyID = [[responseObject objectForKey:@"company_id"] objectAtIndex:0];
    NSArray* groupIDs = [responseObject objectForKey:@"groups_id"];
    
    /*---------- 获取公司信息 ----------*/
    responseObject = [request asyncExecute:@"res.company"
                                    method:@"search_read"
                                parameters:@[@[@[@"id", @"=", companyID]]]
                                conditions:@{@"fields": @[@"logo",
                                                          @"currency_id",
                                                          @"display_name"]} error:&error];
    if( error )
    {
        [request callObserver];
        return;
    }
    responseObject = [responseObject objectAtIndex:0];
    gPreferences.CompanyDisplayName = SafeCopy([responseObject objectForKey:@"display_name"]);
    gPreferences.CompanyCurrency = SafeCopy([[responseObject objectForKey:@"currency_id"] objectAtIndex:1]);
    gPreferences.CompanyLogoImage = SafeCopy([responseObject objectForKey:@"logo"]);
    
    /*---------- 获取用户所在的组的可用菜单 ----------*/
    NSArray* menus = asyncRequestMenu(request, groupIDs, &error);
    addMenusToPreferences(menus);
    if( error )
    {
        [request callObserver];
        return;
    }
    
    /*---------- 登录成功，通知观察者 ----------*/
    [request callObserver];
}

@end
