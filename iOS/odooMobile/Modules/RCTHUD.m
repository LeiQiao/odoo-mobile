//
//  RCTHUD.m
//

#import "RCTHUD.h"
#import "HUD.h"

/**
 *  @author LeiQiao, 16/04/04
 *  @brief HUD提示框，提供给React-Native使用，功能与HUD.h一样
 */
@implementation RCTHUD

RCT_EXPORT_MODULE(HUD);

RCT_EXPORT_METHOD(popWaiting:(NSString*)message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if( message.length > 0 )
        {
            popWaitingWithHint(message);
        }
        else
        {
            popWaiting();
        }
    });
}

RCT_EXPORT_METHOD(dismissWaiting)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        dismissWaiting();
    });
}

RCT_EXPORT_METHOD(popSuccess:(NSString*)message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        popSuccess(message);
    });
}

RCT_EXPORT_METHOD(popError:(NSString*)message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        popError(message);
    });
}

@end
