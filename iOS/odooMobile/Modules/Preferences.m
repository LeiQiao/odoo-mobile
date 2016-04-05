//
//  Preferences.m
//

#import "Preferences.h"

BEGIN_DECLARE_PREFERENCE()

USE_USERDEFAULT(NSString*, ServerName)
USE_USERDEFAULT(NSString*, DBName)
USE_USERDEFAULT(NSNumber*, UserID)
USE_USERDEFAULT(NSString*, UserName)
USE_USERDEFAULT(NSString*, Password)

USE_STATIC_RETAIN(NSMutableDictionary*, ReactNativeStaticPreferences)
USE_USERDEFAULT(NSMutableDictionary*, ReactNativeUserDefaultPreferences)
USE_KEYCHAIN(NSString*, ReactNativeKeyChainPreferences)

END_DECLARE_PREFERENCE()