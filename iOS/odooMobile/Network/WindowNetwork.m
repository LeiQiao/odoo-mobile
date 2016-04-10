//
//  WindowNetwork.m
//  odooMobile
//
//  Created by lei.qiao on 16/4/10.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "WindowNetwork.h"
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
    NSArray* viewModes = [[window objectForKey:@"view_mode"] componentsSeparatedByString:@","];
    if( [gPreferences.Windows objectForKey:model] )
    {
        response.responseObject = [gPreferences.Windows objectForKey:model];
        return response;
    }
    if( !viewModes )
    {
        viewModes = @[];
    }
    
    /*---------- 获取窗口的所有视图模型 ----------*/
    response = [self execute:@"ir.ui.view"
                      method:@"search_read"
                  parameters:@[@[@[@"model", @"=", model],
                                 @[@"type", @"in", viewModes]]]
                  conditions:nil];
    if( !response.success ) return response;
    
    /*---------- 将视图模型根据视图模式分组 ----------*/
    NSMutableDictionary* windowModes = [NSMutableDictionary new];
    NSArray* views = response.responseObject;
    for( NSDictionary* view in views )
    {
        NSString* type = [view objectForKey:@"type"];
        NSMutableArray* modeDatas = [NSMutableArray arrayWithArray:[windowModes objectForKey:type]];
        [modeDatas addObject:view];
        [windowModes setObject:modeDatas forKey:type];
    }
    
    /*---------- 将视图模型保存到全局变量 ----------*/
    NSMutableDictionary* windows = [NSMutableDictionary dictionaryWithDictionary:gPreferences.Windows];
    [windows setObject:windowModes forKey:model];
    gPreferences.Windows = windows;
    
    response.responseObject = windowModes;
    return response;
}

@end
