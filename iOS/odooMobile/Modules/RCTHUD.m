//
//  RCTHUD.m
//

#import "RCTHUD.h"

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
