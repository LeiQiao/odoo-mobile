//
//  Preferences.h
//

#import "PreferencesDefine.h"

BEGIN_DEFINE_PREFERENCE()

DEFINE_PREFERENCE(NSString*, ServerName)
DEFINE_PREFERENCE(NSString*, DBName)
DEFINE_PREFERENCE(NSNumber*, UserID)
DEFINE_PREFERENCE(NSString*, UserName)
DEFINE_PREFERENCE(NSString*, Password)

DEFINE_PREFERENCE(NSMutableDictionary*, ReactNativeStaticPreferences)
DEFINE_PREFERENCE(NSMutableDictionary*, ReactNativeUserDefaultPreferences)
DEFINE_PREFERENCE(NSString*, ReactNativeKeyChainPreferences)

END_DEFINE_PREFERENCE()
