//
//  MainAction.m
//  odooMobile
//
//  Created by LeiQiao on 16/4/2.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "MainAction.h"
#import "LoginAction.h"
#import "Preferences.h"

@implementation MainAction

-(void) actionDidLoad
{
    [self enterAction:[LoginAction class]];
}

@end
