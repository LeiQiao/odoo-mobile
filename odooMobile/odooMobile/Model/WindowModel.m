//
//  WindowModel.m
//

#import "WindowModel.h"
#import "Preferences.h"
#import "GlobalModels.h"
#import "JSON.h"

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 窗口模型
 */
@implementation WindowModel

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 更新指定窗口
 *  @param windowID 窗口ID
 */
-(void) updateWindowByID:(NSNumber*)windowID
{
    [NSThread detachNewThreadSelector:@selector(updateWindowByIDThread:) toTarget:self withObject:windowID];
}

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 更新指定窗口线程
 *  @param windowID 窗口ID
 */
-(void) updateWindowByIDThread:(NSNumber*)windowID
{
    NSError* error = nil;
    OdooRequestModel* request = [[OdooRequestModel alloc] initWithObserveModel:self andCallback:@selector(windowModel:updateWindowByID:)];
    
    /*---------- 查找窗口 ----------*/
    id responseObject = [request asyncExecute:@"ir.actions.act_window"
                                       method:@"search_read"
                                   parameters:@[@[@[@"id", @"=", windowID]]]
                                   conditions:nil
                                        error:&error];
    if( error )
    {
        [request callObserver];
        return;
    }
    NSDictionary* window = [responseObject objectAtIndex:0];
    if( !window )
    {
        request.retParam.success = NO;
        request.retParam.failedCode = @"-1";
        request.retParam.failedReason = @"窗口未找到";
        [request callObserver];
        return;
    }
    
    /*---------- 找到窗口，获取内存中的窗口视图模型 ----------*/
    NSString* model = [window objectForKey:@"res_model"];
    if( [gPreferences.Windows objectForKey:model] )
    {
        request.retParam.success = YES;
        request.retParam.failedCode = @"0";
        request.retParam.failedReason = @"获取成功";
        request.retParam[@"Window"] = [gPreferences.Windows objectForKey:model];
        [request callObserver];
        return;
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
        responseObject = [request asyncExecute:model
                                        method:@"fields_view_get"
                                    parameters:nil
                                    conditions:@{@"view_type":viewMode,
                                                 @"context":context}
                                         error:&error];
        if( error )
        {
            [request callObserver];
            return;
        }
        
        [windowModes setObject:responseObject forKey:viewMode];
    }
    
    /*---------- 将视图模型保存到全局变量 ----------*/
    NSMutableDictionary* windows = [NSMutableDictionary dictionaryWithDictionary:gPreferences.Windows];
    [windows setObject:windowModes forKey:model];
    gPreferences.Windows = windows;
    
    request.retParam.success = YES;
    request.retParam.failedCode = @"0";
    request.retParam.failedReason = @"请求成功";
    request.retParam[@"WindowModes"] = windowModes;
    [request callObserver];
}

@end
