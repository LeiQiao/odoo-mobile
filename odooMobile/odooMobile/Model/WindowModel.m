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
    request.retParam[@"WindowID"] = windowID;
    
    /*---------- 查找窗口 ----------*/
    WindowData* window = [gPreferences.Windows objectForKey:windowID];
    if( window )
    {
        request.retParam[@"Window"] = window;
        request.retParam.success = YES;
        request.retParam.failedCode = @"0";
        request.retParam.failedReason = @"获取成功";
        [request callObserver];
        return;
    }
    
    id responseObject = [request asyncExecute:@"ir.actions.act_window"
                                       method:@"search_read"
                                   parameters:@[@[@[@"id", @"=", windowID]]]
                                   conditions:@{@"fields": @[@"id",
                                                             @"name",
                                                             @"display_name",
                                                             @"res_model",
                                                             @"context",
                                                             @"view_mode"]}
                                        error:&error];
    if( error )
    {
        [request callObserver];
        return;
    }
    
    NSDictionary* windowData = [responseObject objectAtIndex:0];
    if( !windowData )
    {
        request.retParam.success = NO;
        request.retParam.failedCode = @"-1";
        request.retParam.failedReason = @"窗口未找到";
        [request callObserver];
        return;
    }
    
    /*---------- 转换窗口数据 ----------*/
    window = [[WindowData alloc] init];
    window.ID = [windowData objectForKey:@"id"];
    window.name = [windowData objectForKey:@"name"];
    window.displayName = [windowData objectForKey:@"display_name"];
    window.modelName = [windowData objectForKey:@"res_model"];
    
    NSMutableDictionary* context = [NSMutableDictionary dictionaryWithDictionary:[[windowData objectForKey:@"context"] objectFromJSONString]];
    [context setValue:gPreferences.Language forKey:@"lang"];
    window.context = context;
    
    /*---------- 窗口显示模式名称 ----------*/
    NSMutableArray* viewModeNames = [NSMutableArray arrayWithArray:[[windowData objectForKey:@"view_mode"] componentsSeparatedByString:@","]];
    if( !viewModeNames )
    {
        viewModeNames = [NSMutableArray new];
    }
    [viewModeNames addObject:@"search"];
    
    /*---------- 翻译窗口显示模式名称 ----------*/
    NSDictionary* translatedNames = asyncTranslateNames(request, viewModeNames, @"view_mode", @"ir.actions.act_window.view", &error);
    if( error )
    {
        [request callObserver];
        return;
    }
    
    /*---------- 获取窗口显示模式 ----------*/
    NSMutableArray* viewModes = [NSMutableArray new];
    for( NSString* viewModeName in viewModeNames )
    {
        // 获取显示模式
        responseObject = [request asyncExecute:window.modelName
                                        method:@"fields_view_get"
                                    parameters:nil
                                    conditions:@{@"view_type":viewModeName,
                                                 @"context":window.context}
                                         error:&error];
        if( error )
        {
            [request callObserver];
            return;
        }
        
        /*--------- 转换窗口显示模式数据 ----------*/
        ViewModeData* viewMode = [[ViewModeData alloc] init];
        viewMode.ID = [responseObject objectForKey:@"name"];
        viewMode.name = viewModeName;
        viewMode.displayName = [translatedNames objectForKey:viewModeName];
        viewMode.htmlContext = [responseObject objectForKey:@"arch"];
        
        /*--------- 转换窗口显示模式的字段类型数据 ----------*/
        NSMutableArray* viewModeFields = [NSMutableArray new];
        NSArray* fieldNames = ((NSDictionary*)[responseObject objectForKey:@"fields"]).allKeys;
        for( NSString* fieldName in fieldNames )
        {
            NSDictionary* fieldData = [[responseObject objectForKey:@"fields"] objectForKey:fieldName];
            
            FieldData* field = [[FieldData alloc] init];
            field.name = fieldName;
            field.displayName = [fieldData objectForKey:@"string"];
            field.readonly = [[fieldData objectForKey:@"readonly"] boolValue];
            field.required = [[fieldData objectForKey:@"required"] boolValue];
            if( [[fieldData objectForKey:@"type"] isEqualToString:@"text"] )
            {
                field.type = FieldTypeText;
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"char"] )
            {
                field.type = FieldTypeChar;
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"boolean"] )
            {
                field.type = FieldTypeBoolean;
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"integer"] )
            {
                field.type = FieldTypeInteger;
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"float"] )
            {
                field.type = FieldTypeDouble;
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"monetary"] )
            {
                field.type = FieldTypeDouble;
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"binary"] )
            {
                field.type = FieldTypeBinary;
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"selection"] )
            {
                field.type = FieldTypeSelection;
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"many2one"] )
            {
                field.type = FieldTypeRelatedToModel;
                field.relationModel = [fieldData objectForKey:@"relation"];
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"many2many"] )
            {
                field.type = FieldTypeRelatedToModel;
                field.relationModel = [fieldData objectForKey:@"relation"];
            }
            else if( [[fieldData objectForKey:@"type"] isEqualToString:@"one2many"] )
            {
                field.type = FieldTypeRelatedToField;
                field.relationModel = [fieldData objectForKey:@"relation"];
                field.relationField = [fieldData objectForKey:@"relation_field"];
            }
            else
            {
                NSLog(@"unknown field type: %@", [fieldData objectForKey:@"type"]);
                field.type = FieldTypeUnknown;
            }
            [viewModeFields addObject:field];
        }
        viewMode.fields = viewModeFields;
        
        [viewModes addObject:viewMode];
    }
    window.viewModes = viewModes;
    
    /*---------- 将窗口保存到全局变量 ----------*/
    NSMutableDictionary* windows = [NSMutableDictionary dictionaryWithDictionary:gPreferences.Windows];
    [windows setObject:window forKey:windowID];
    gPreferences.Windows = windows;
    
    request.retParam.success = YES;
    request.retParam.failedCode = @"0";
    request.retParam.failedReason = @"请求成功";
    request.retParam[@"Window"] = window;
    [request callObserver];
}

@end
