//
//  Preferences.m
//

#import "Preferences.h"

BEGIN_DECLARE_PREFERENCE()

USE_USERDEFAULT(NSString*, ServerName)
USE_USERDEFAULT(NSString*, DBName)

USE_STATIC_RETAIN(NSNumber*, UserID)
USE_USERDEFAULT(NSString*, UserName)
USE_KEYCHAIN(NSString*, Password)
USE_USERDEFAULT(NSString*, UserImage)
USE_USERDEFAULT(NSString*, UserEmail)
USE_USERDEFAULT(NSString*, UserDisplayName)
USE_USERDEFAULT(NSString*, Language)

USE_USERDEFAULT(NSString*, CompanyDisplayName)
USE_USERDEFAULT(NSString*, CompanyCurrency)
USE_USERDEFAULT(NSString*, CompanyLogoImage)

USE_STATIC_RETAIN(NSArray*, Menus)
USE_STATIC_RETAIN(NSDictionary*, Windows)

END_DECLARE_PREFERENCE()