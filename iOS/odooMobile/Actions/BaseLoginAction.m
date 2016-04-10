//
//  BaseLoginAction.m
//

#import "BaseLoginAction.h"
#import "UserNetwork.h"
#import "OdooNotification.h"
#import "HUD.h"

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 登录动作，封装了登录的逻辑
 */
@implementation BaseLoginAction

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作已加载
 */
-(void) actionDidLoad
{
    // 添加登录通知观察
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginRequest:)
                                                 name:kWillLoginNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponse:)
                                                 name:kDidLoginNotification
                                               object:nil];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 动作被销毁
 */
-(void) actionDidDestroy
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 开始登录
 *  @param notify 登录通知
 *         -- ServerName 服务器名称
 *         -- DBName     数据库名称
 *         -- UserName   用户名
 *         -- Password   密码
 */
-(void) loginRequest:(NSNotification*)notify
{
    // 创建静默登录线程
    [NSThread detachNewThreadSelector:@selector(loginThread:)
                             toTarget:self
                           withObject:notify.object];
}

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 登录完成
 *  @param notify 登录结果通知
 */
-(void) loginResponse:(NSNotification*)notify
{
    NetworkResponse* response = (NetworkResponse*)notify.object;
    if( !response.success )
    {
        popError(response.failedReason);
        return;
    }
    
    [self leaveAction];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 登录线程
 */
-(void) loginThread:(NSDictionary*)userInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        popWaiting();    
    });
    
    NSString* serverName = [userInfo objectForKey:@"ServerName"];
    NSString* dbName = [userInfo objectForKey:@"DBName"];
    NSString* userName = [userInfo objectForKey:@"UserName"];
    NSString* password = [userInfo objectForKey:@"Password"];
    
    UserNetwork* user = [[UserNetwork alloc] init];
    NetworkResponse* response = [user login:serverName dbName:dbName userName:userName password:password];
    OdooPostNotification(kDidLoginNotification, response);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        dismissWaiting();
    });
}

@end
