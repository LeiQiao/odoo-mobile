//
//  BaseModule.m
//  odooMobile
//
//  Created by lei.qiao on 16/4/1.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "BaseModule.h"

@implementation BaseModule

-(void) launchAsRootModule:(RCTBridge*)jsBridge
{
    NSAssert((!_jsBridge), @"module \"%@\" has already in current module stack.", NSStringFromClass([self class]));
    _jsBridge = jsBridge;
    _parentModule = nil;
    [self onEnter];
}

-(void) enterModule:(NSString*)moduleName
{
    
    BaseModule* module = [_jsBridge moduleForName:moduleName];
    
    NSAssert((module != nil), @"module \"%@\" did NOT exist", moduleName);
    NSAssert((!module->_jsBridge), @"module has already in current module stack.");
    
    module->_jsBridge = _jsBridge;
    module->_parentModule = self;
    module->_childModule = nil;
    
    _childModule = module;
    
    [self onSuspend];
    [module onEnter];
}

-(void) leaveModule
{
    if( _childModule )
    {
        [_childModule leaveModule];
    }
    
    [self onLeave];
    _jsBridge = nil;
    
    [_parentModule onResume];
    _parentModule = nil;
}

-(void) onEnter
{
}

-(void) onSuspend
{
}

-(void) onResume
{
}

-(void) onLeave
{
}

-(UIViewController*) topViewController
{
    UIViewController* rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while( rootViewController.presentedViewController != nil )
    {
        rootViewController = rootViewController.presentedViewController;
    }
    return rootViewController;
}

@end
