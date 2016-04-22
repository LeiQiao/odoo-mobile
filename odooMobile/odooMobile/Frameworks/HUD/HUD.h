//
//  HUD.h
//  YAroundMe_Telecom
//
//  Created by Hugh on 10/14/10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HUD : NSObject

+(void) popSuccess:(NSString*)message;
+(void) popError:(NSString*)message;

+(void) popWaiting;
+(void) popWaiting:(NSString*)hint;
+(void) popWaiting:(NSString*)hint userInteractionEnabled:(BOOL)userInteractionEnabled;
+(void) dismissWaiting;

@end

NS_INLINE void popWaiting(){[HUD popWaiting];}
NS_INLINE void popWaitingWithHint(NSString* hint){[HUD popWaiting:hint];}
NS_INLINE void popWaitingWithHintAndUserInteraction(NSString* hint, BOOL userInteractionEnabled){[HUD popWaiting:hint
                                                                                          userInteractionEnabled:userInteractionEnabled];}
NS_INLINE void dismissWaiting(){[HUD dismissWaiting];}
NS_INLINE void popSuccess(NSString* message){[HUD popSuccess:message];}
NS_INLINE void popError(NSString* message){[HUD popError:message];}
