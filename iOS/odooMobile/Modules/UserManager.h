//
//  UserManager.h
//  odooMobile
//
//  Created by lei.qiao on 16/3/31.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "BaseModule.h"
#import "RCTBridgeModule.h"

@interface UserManager : BaseModule <RCTBridgeModule>

@property(nonatomic, strong) NSString* serverName;
@property(nonatomic, strong) NSString* dbName;
@property(nonatomic, strong) NSString* userID;
@property(nonatomic, strong) NSString* userName;
@property(nonatomic, strong) NSString* password;

-(void) login:(NSString*)serverName
       DBName:(NSString*)DBName
     userName:(NSString*)userName
     password:(NSString*)password
     callback:(RCTResponseSenderBlock)callback;

@end
