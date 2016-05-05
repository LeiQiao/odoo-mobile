//
//  RecordModel.m
//

#import "RecordModel.h"
#import "Preferences.h"
#import "GlobalModels.h"

/*!
 *  @author LeiQiao, 16/05/02
 *  @brief 记录模型
 */
@implementation RecordModel

/*!
 *  @author LeiQiao, 16/05/02
 *  @brief 获取某个窗口中的纪录
 *  @param viewMode 窗口显示模式
 */
-(void) requestMoreRecord:(WindowData*)window viewMode:(ViewModeData*)viewMode
{
    NSDictionary* parameters = @{@"Window":window, @"ViewMode":viewMode};
    [NSThread detachNewThreadSelector:@selector(requestMoreRecordThread:) toTarget:self withObject:parameters];
}

-(void) requestMoreRecordThread:(NSDictionary*)parameters
{
    WindowData* window = parameters[@"Window"];
    ViewModeData* viewMode = parameters[@"ViewMode"];
    
    OdooRequestModel* request = [[OdooRequestModel alloc] initWithObserveModel:self andCallback:@selector(recordModel:requestMoreRecord:)];
    [request.retParam.userInfo addEntriesFromDictionary:parameters];
    
    /*---------- 获取所有字段的名称 ----------*/
    NSMutableArray* fieldNames = [NSMutableArray new];
    for( FieldData* field in viewMode.fields )
    {
        [fieldNames addObject:field.name];
    }
    
    /*---------- 获取记录 ----------*/
    NSError* error = nil;
    id responseObject = [request asyncExecute:window.modelName
                                       method:@"search_read"
                                   parameters:nil
                                   conditions:@{@"fields":fieldNames,
                                                @"context":window.context,
                                                @"offset":@(viewMode.records.count),
                                                @"limit":@(20)}
                                        error:&error];
    
    if( error )
    {
        [request callObserver];
        return;
    }
    
    /*---------- 保存到全局变量 ----------*/
    [viewMode.records addObjectsFromArray:responseObject];
    
    request.retParam.success = YES;
    request.retParam.failedCode = @"0";
    request.retParam.failedReason = @"请求成功";
    [request callObserver];
}

@end
