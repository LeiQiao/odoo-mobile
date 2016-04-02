//
//  BaseModule.h
//  odooMobile
//
//  Created by lei.qiao on 16/4/1.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridge.h"

#define RCT_EXPORT_PROPERTY(propertyName) \
    RCT_EXPORT_METHOD(propertyName:(RCTResponseSenderBlock)callback) \
    { \
        callback(@[SafeCopy(self.propertyName)]); \
    }

@interface BaseModule : NSObject {
    RCTBridge* _jsBridge;
    BaseModule* _parentModule;
    BaseModule* _childModule;
}


-(void) launchAsRootModule:(RCTBridge*)jsBridge;

-(void) enterModule:(NSString*)moduleName;
-(void) leaveModule;

-(void) onEnter;
-(void) onSuspend;
-(void) onResume;
-(void) onLeave;

-(UIViewController*) topViewController;

@end


