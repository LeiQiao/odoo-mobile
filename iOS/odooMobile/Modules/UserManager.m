//
//  UserManager.m
//  odooMobile
//
//  Created by lei.qiao on 16/3/31.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "UserManager.h"
#import "RCTRootView.h"
#import "AFXMLRPCSessionManager.h"
#import "HUD.h"


@implementation UserManager {
    UIViewController* _loginViewController;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_PROPERTY(serverName);

-(void) onEnter
{
    [super onEnter];
    
    RCTRootView* loginView = [[RCTRootView alloc] initWithBridge:_jsBridge
                                                      moduleName:@"Login"
                                               initialProperties:nil];
    _loginViewController = [UIViewController new];
    _loginViewController.view = loginView;
    [[self topViewController] presentViewController:_loginViewController animated:YES completion:^{}];
}

-(void) onLeave
{
    [_loginViewController dismissViewControllerAnimated:YES completion:^{}];
}

RCT_EXPORT_METHOD(login:(NSString*)serverName
                  DBName:(NSString*)dbName
                  userName:(NSString*)userName
                  password:(NSString*)password
                  callback:(RCTResponseSenderBlock)callback)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        popWaiting();
    });
    
    NSString* urlString = [NSString stringWithFormat:@"%@/xmlrpc/2/common", serverName];
    AFXMLRPCSessionManager* manager = [[AFXMLRPCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    NSURLRequest* request = [manager XMLRPCRequestWithMethod:@"authenticate" parameters:@[dbName, userName, password, @{}]];
    [manager XMLRPCTaskWithRequest:request success:^(NSURLSessionDataTask *task, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dismissWaiting();
        });
        
        NSString* userID = SafeCopy(responseObject);
        if( [userID integerValue] > 0 )
        {
            self.serverName = serverName;
            self.dbName = dbName;
            self.userID = userID;
            self.userName = userName;
            self.password = password;
            callback(@[@(YES), @"登录成功"]);
            
            [self leaveModule];
        }
        else
        {
            callback(@[@(NO), @"登录失败，用户名密码错误"]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dismissWaiting();
        });
        
        if( error.code == -1001 )
        {
            callback(@[@(NO), @"登录失败，服务器无法连接"]);
        }
        else if( error.code == 1 )
        {
            callback(@[@(NO), @"登录失败，数据库不存在"]);
        }
        else
        {
            callback(@[@(NO), @"登录失败，请重试"]);
        }
    }];
}

@end
