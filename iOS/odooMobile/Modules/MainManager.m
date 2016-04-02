//
//  MainManager.m
//  odooMobile
//
//  Created by lei.qiao on 16/4/1.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "MainManager.h"
#import "UserManager.h"



@implementation MainManager

RCT_EXPORT_MODULE();

#pragma mark
#pragma mark override

-(void) onEnter
{
    [super onEnter];
    
    UserManager* userManager = [_jsBridge moduleForName:@"UserManager"];
    if( (userManager.userID.length == 0) && (userManager.userName.length == 0) )
    {
        [self enterModule:@"UserManager"];
    }
}

@end
