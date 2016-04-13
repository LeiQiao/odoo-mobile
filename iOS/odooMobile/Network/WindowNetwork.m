//
//  WindowNetwork.m
//

#import "WindowNetwork.h"
#import "GDataXMLNode.h"
#import "JSON.h"

@implementation WindowNetwork

-(NetworkResponse*) getWindowByID:(NSNumber*)windowID type:(NSString*)windowType
{
    /*---------- 查找窗口 ----------*/
    NetworkResponse* response = [self execute:windowType
                                       method:@"search_read"
                                   parameters:@[@[@[@"id", @"=", windowID]]]
                                   conditions:nil];
    if( !response.success ) return response;
    
    NSDictionary* window = [response.responseObject objectAtIndex:0];
    if( !window )
    {
        [response setFailedAndReason:@"窗口未找到"];
        return response;
    }
    
    /*---------- 找到窗口，获取内存中的窗口视图模型 ----------*/
    NSString* model = [window objectForKey:@"res_model"];
    if( [gPreferences.Windows objectForKey:model] )
    {
        response.responseObject = [gPreferences.Windows objectForKey:model];
        return response;
    }
    NSDictionary* context = [SafeCopy([window objectForKey:@"context"]) objectFromJSONString];
    if( !context )
    {
        context = [NSDictionary new];
    }
    NSMutableArray* viewModes = [NSMutableArray arrayWithArray:[[window objectForKey:@"view_mode"] componentsSeparatedByString:@","]];
    if( !viewModes )
    {
        viewModes = [NSMutableArray new];
    }
    [viewModes addObject:@"search"];
    
    /*---------- 将视图模型根据视图模式分组 ----------*/
    NSMutableDictionary* windowModes = [NSMutableDictionary new];
    for( NSString* viewMode in viewModes )
    {
        response = [self execute:model
                          method:@"fields_view_get"
                      parameters:nil
                      conditions:@{@"view_type":viewMode,
                                   @"context":context}];
        if( !response.success ) return response;
        
        [windowModes setObject:response.responseObject forKey:viewMode];
    }
    
    /*---------- 将视图模型保存到全局变量 ----------*/
    NSMutableDictionary* windows = [NSMutableDictionary dictionaryWithDictionary:gPreferences.Windows];
    [windows setObject:windowModes forKey:model];
    gPreferences.Windows = windows;
    
    response.responseObject = windowModes;
    return response;
}

@end
