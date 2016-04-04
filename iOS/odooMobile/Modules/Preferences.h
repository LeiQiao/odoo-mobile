//
//  Preferences.h
//

#import <Foundation/Foundation.h>

#define gPreferences        [Preferences sharedPreference]

@interface Preferences : NSObject

+(Preferences*) sharedPreference;

@property(nonatomic, strong) NSString* serverName;
@property(nonatomic, strong) NSString* dbName;
@property(nonatomic, strong) NSString* userID;
@property(nonatomic, strong) NSString* userName;
@property(nonatomic, strong) NSString* password;

@end
