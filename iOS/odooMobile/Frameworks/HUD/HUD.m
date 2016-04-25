//
//  HUD.m
//  YAroundMe_Telecom
//
//  Created by Hugh on 10/14/10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HUD.h"
#import "MBProgressHUD.h"


@implementation HUD

#pragma mark
#pragma mark singlition message box

+(void) popMessage:(NSString*)message withCustomIcon:(UIImage*)icon
{
	UIView* parentView = [UIApplication sharedApplication].delegate.window;
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:parentView];
	[parentView addSubview:hud];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	hud.customView = [[UIImageView alloc] initWithImage:icon];
    
#if !__has_feature(objc_arc)
    [hud.customView autorelease];
#endif
	
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
	
    hud.detailsLabelText = message;
    hud.detailsLabelFont = [UIFont boldSystemFontOfSize:16.0];
	hud.removeFromSuperViewOnHide = YES;
	
    [hud show:YES];
	[hud hide:YES afterDelay:2];
    
#if !__has_feature(objc_arc)
	[hud release];
#endif
}

+(void) popSuccess:(NSString*)message
{
	[HUD popMessage:message withCustomIcon:[UIImage imageNamed:@"success.png"]];
}

+(void) popError:(NSString*)message
{
	[HUD popMessage:message withCustomIcon:[UIImage imageNamed:@"error.png"]];
}

#pragma mark
#pragma mark singlition waiting view

static MBProgressHUD* g_HUD = nil;
static NSInteger g_referenceTime = 0;

+(void) createHUD
{
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
		g_HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].delegate.window];
	});
}

+(void) popWaiting
{
    [HUD popWaiting:@"加载中..."];
}

+(void) popWaiting:(NSString*)hint
{
    [HUD popWaiting:hint userInteractionEnabled:YES];
}

+(void) popWaiting:(NSString*)hint userInteractionEnabled:(BOOL)userInteractionEnabled
{
    [HUD createHUD];
    if( g_referenceTime++ == 0 )
    {
        g_HUD.labelText = hint;
        g_HUD.userInteractionEnabled = userInteractionEnabled;
//		g_HUD.dimBackground = YES;
        [[UIApplication sharedApplication].delegate.window addSubview:g_HUD];
        [g_HUD show:YES];
    }
}

+(void) dismissWaiting
{
	g_referenceTime--;
	if( g_referenceTime == 0 )
	{
		[g_HUD removeFromSuperview];
	}
	if( g_referenceTime < 0 )
	{
        g_referenceTime = 0;
//		NSAssert((g_referenceTime>=0), @"HUD has already dismissed.");
	}
}

@end
