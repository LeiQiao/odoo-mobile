//
//  LoginAction.m
//  odooMobile
//
//  Created by LeiQiao on 16/4/2.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "LoginAction.h"
#import "AppDelegate.h"
#import "ModuleNotification.h"
#import "NetworkResponse.h"

@implementation LoginAction {
    UIViewController* _loginViewController;
}

-(void) dealloc
{
}

-(void) actionDidLoad
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // 创建登录窗
    RCTRootView* loginView = [[RCTRootView alloc] initWithBridge:appDelegate.rootView.bridge
                                                      moduleName:@"Login"
                                               initialProperties:nil];
    _loginViewController = [UIViewController new];
    _loginViewController.view = loginView;
    
    // 弹出登陆窗
    [appDelegate.window.rootViewController presentViewController:_loginViewController animated:YES completion:^{}];
    
    // 注册通知消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponse:)
                                                 name:kLoginNetworkNotification
                                               object:nil];
}

-(void) actionDidLeave
{
    [_loginViewController dismissViewControllerAnimated:YES completion:^{}];
}

-(void) actionDidDestroy
{
    _loginViewController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) loginResponse:(NSNotification*)notify
{
    NetworkResponse* response = (NetworkResponse*)notify.object;
    
    // 登录成功则退出登录界面
    if( response.success )
    {
        [self leaveAction];
    }
}

@end
