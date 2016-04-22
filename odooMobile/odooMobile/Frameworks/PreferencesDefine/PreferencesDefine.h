//
//  PreferencesDefine.h
//

#import <Foundation/Foundation.h>
#import "SFHFKeychainUtils.h"
#define kKeychainServiceName (@"kcOdooMobile")

#define gPreferences             [Preferences getPreferencesInstance]

#define BEGIN_DEFINE_PREFERENCE() \
    @interface Preferences : NSObject \
    +(Preferences*) getPreferencesInstance; \
    +(void) setUserDefault:(NSString*)key value:(id)value; \
    +(id) getUserDefault:(NSString*)key; \


#define END_DEFINE_PREFERENCE() \
    @end \


#define BEGIN_DECLARE_PREFERENCE() \
    @implementation Preferences \
    +(Preferences*) getPreferencesInstance \
    { \
        static Preferences* g_defaultPreferences = nil; \
        if( g_defaultPreferences == nil ) \
        { \
            g_defaultPreferences = [[Preferences alloc] init]; \
        } \
        return g_defaultPreferences; \
    } \
    +(void) setUserDefault:(NSString*)key value:(id)value \
    { \
        if( !key ) return; \
        if( !value ) \
        { \
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key]; \
        } \
        else \
        { \
            [[NSUserDefaults standardUserDefaults] setValue:value forKey:key]; \
        } \
        [[NSUserDefaults standardUserDefaults] synchronize]; \
    } \
    +(id) getUserDefault:(NSString*)key \
    { \
        if( !key ) return nil; \
        return [[NSUserDefaults standardUserDefaults] objectForKey:key]; \
    } \
    +(void) setKeychain:(NSString*)key value:(id)value \
    { \
        if( !key ) return; \
        if( !value ) value = @""; \
        [SFHFKeychainUtils storeUsername:key \
                             andPassword:value \
                          forServiceName:kKeychainServiceName \
                          updateExisting:YES \
                                   error:nil]; \
    } \
    +(id) getKeychain:(NSString*)key \
    { \
        if( !key ) return nil; \
        return [SFHFKeychainUtils getPasswordForUsername:key \
                                          andServiceName:kKeychainServiceName \
                                                   error:nil]; \
    } \


#define END_DECLARE_PREFERENCE() \
    @end


#define DEFINE_PREFERENCE(type, name) \
    @property(atomic, strong, getter=get##name) type name; \

#define DEFINE_READONLY_PREFERENCE(type, name) \
@property(atomic, strong, readonly, getter=get##name) type name; \

#define DEFINE_ENUM_PREFERENCE(type, name) \
    @property(atomic, getter=get##name) type name; \

#define USE_KEYCHAIN(type, name) \
    @synthesize name; \
    -(void) set##name:(type)new##name \
    { \
        [Preferences setKeychain:[NSString stringWithFormat:@"(_kc%s)", #name] value:new##name]; \
    } \
    -(type) get##name \
    { \
        return [Preferences getKeychain:[NSString stringWithFormat:@"(_kc%s)", #name]]; \
    } \

#define USE_USERDEFAULT(type, name) \
    @synthesize name; \
    -(void) set##name:(type)new##name \
    { \
        [Preferences setUserDefault:[NSString stringWithFormat:@"%s", #name] value:new##name]; \
    } \
    -(type) get##name \
    { \
        return [Preferences getUserDefault:[NSString stringWithFormat:@"%s", #name]]; \
    } \

#if !__has_feature(objc_arc)

#define USE_STATIC_RETAIN(type, name) \
    @synthesize name; \
    -(void) set##name:(type)new##name \
    { \
        if( self.##name == new##name ) return; \
        if( self.##name != nil ) \
        { \
            [self.##name release]; \
            self.##name = nil; \
        } \
        self.##name = new##name; \
        [self.##name retain]; \
    } \
    -(type) get##name \
    { \
        return self.##name; \
    } \

#else

#define USE_STATIC_RETAIN(type, name) \
    @synthesize name; \
    -(void) set##name:(type)new##name \
    { \
        name = new##name; \
    } \
    -(type) get##name \
    { \
        return name; \
    } \

#endif

#define USE_STATIC_ASSIGN(type, name) \
    @synthesize name; \
    -(void) set##name:(type)new##name \
    { \
        name = new##name; \
    } \
    -(type) get##name \
    { \
        return name; \
    } \
