//
//  Preferences.m
//

#import "Preferences.h"

@implementation Preferences

+(Preferences*) sharedPreference
{
    static Preferences* sharedPreference;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPreference = [Preferences new];
    });
    return sharedPreference;
}

@end
