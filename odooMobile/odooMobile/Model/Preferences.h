//
//  Preferences.h
//

#import "PreferencesDefine.h"
#import "OdooData.h"

BEGIN_DEFINE_PREFERENCE()

DEFINE_PREFERENCE(NSString*, ServerName)
DEFINE_PREFERENCE(NSString*, DBName)

DEFINE_PREFERENCE(NSNumber*, UserID)
DEFINE_PREFERENCE(NSString*, UserName)
DEFINE_PREFERENCE(NSString*, Password)
DEFINE_PREFERENCE(NSString*, UserImage)
DEFINE_PREFERENCE(NSString*, UserEmail)
DEFINE_PREFERENCE(NSString*, UserDisplayName)
DEFINE_PREFERENCE(NSString*, Language)

DEFINE_PREFERENCE(NSString*, CompanyDisplayName)
DEFINE_PREFERENCE(NSString*, CompanyCurrency)
DEFINE_PREFERENCE(NSString*, CompanyLogoImage)


DEFINE_PREFERENCE(NSArray*, Menus)
DEFINE_PREFERENCE(NSDictionary*, Windows)

DEFINE_PREFERENCE(NSDictionary*, CSSFiles)
DEFINE_PREFERENCE(NSDictionary*, JSFiles)

END_DEFINE_PREFERENCE()
