//
//  UserModel.m
//

#import "UserModel.h"
#import "OdooRequestModel.h"
#import "Preferences.h"
#import "GlobalModels.h"

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
    OdooRequestModel* request = [[OdooRequestModel alloc] initWithObserveModel:self andCallback:@selector(userModel:login:)];
    request.reqParam = [OdooRequestParam execute:@"authenticate" parameters:@[dbName, userName, password, @{}]];
    request.reqParam.timeout = 10;
    [request POST:[NSString stringWithFormat:@"%@/xmlrpc/2/common", serverName]
          success:^(id responseObject) {
              if( [responseObject integerValue] == 0 )
              {
                  request.retParam.success = NO;
                  request.retParam.failedCode = @"-1";
                  request.retParam.failedReason = @"登录失败，用户名密码错误";
              }
              else
              {
                  [request setObserveModel:nil andCallback:nil];
                  
                  gPreferences.ServerName = serverName;
                  gPreferences.DBName = dbName;
                  gPreferences.UserID = responseObject;
                  gPreferences.UserName = userName;
                  gPreferences.Password = password;
                  
                  [self updateUserInfo];
              }
          }];
}

-(void) updateUserInfo
{
    OdooRequestModel* request = [[OdooRequestModel alloc] initWithObserveModel:self andCallback:@selector(userModel:login:)];
    request.reqParam = [OdooRequestParam execute:@"execute_kw"
                                      parameters:@[gPreferences.DBName,
                                                   @([gPreferences.UserID integerValue]),
                                                   gPreferences.Password,
                                                   @"res.users",
                                                   @"search_read",
                                                   @[@[@[@"id", @"=", gPreferences.UserID]]],
                                                   @{@"fields": @[@"image",
                                                                  @"email",
                                                                  @"display_name",
                                                                  @"groups_id",
                                                                  @"company_id",
                                                                  @"lang",
                                                                  @"active"]}]];
    request.reqParam.timeout = 10;
    [request POST:[NSString stringWithFormat:@"%@/xmlrpc/2/object", gPreferences.ServerName]
          success:^(id responseObject) {
              responseObject = [responseObject objectAtIndex:0];
              // 判断账号是否激活
              if( ![[responseObject objectForKey:@"active"] boolValue] )
              {
                  request.retParam.success = NO;
                  request.retParam.failedCode = @"-1";
                  request.retParam.failedReason = @"账号未激活，请联系管理员";
              }
              else
              {
                  [request setObserveModel:nil andCallback:nil];
                  
                  gPreferences.UserImage = SafeCopy([responseObject objectForKey:@"image"]);
                  gPreferences.UserEmail = SafeCopy([responseObject objectForKey:@"email"]);
                  gPreferences.UserDisplayName = SafeCopy([responseObject objectForKey:@"display_name"]);
                  gPreferences.Language = SafeCopy([responseObject objectForKey:@"lang"]);
                  
                  NSNumber* companyID = [[responseObject objectForKey:@"company_id"] objectAtIndex:0];
                  NSArray* groupIDs = [responseObject objectForKey:@"groups_id"];
                  
                  [self updateCompanyInfo];
              }
          }];
}

-(void) updateCompanyInfo
{
}

@end
