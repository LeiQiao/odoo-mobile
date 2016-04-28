//
//  TranslateModel.m
//

#import "TranslateModel.h"
#import "Preferences.h"
#import "GlobalModels.h"

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 翻译Model中的某个字段，根据Model项的id与翻译表中的src_id对应
 *  @param request   请求对象
 *  @param srcItems  要翻译的内容采用[{'id':'xxx', 'field':'value', ...}, ...]结构
 *  @param fieldName 要翻译的字段名
 *  @param modelName 要翻译的模块
 *  @param error     错误对象指针
 *  @return 翻译结果
 */
id asyncTranslateFields(OdooRequestModel* request, NSArray* srcItems, NSString* fieldName, NSString* modelName, NSError** error)
{
    if( !request )
    {
        request = [[OdooRequestModel alloc] initWithObserveModel:nil andCallback:nil];
    }
    
    NSMutableArray* srcIDs = [NSMutableArray new];
    for( NSDictionary* item in srcItems )
    {
        [srcIDs addObject:[item objectForKey:@"id"]];
    }
    
    /*---------- 翻译指定模块的字段 ----------*/
    id responseObject = [request asyncExecute:@"ir.translation"
                                       method:@"search_read"
                                   parameters:@[@[@[@"res_id", @"in", srcIDs],
                                                  @[@"name", @"=", [NSString stringWithFormat:@"%@,%@",
                                                                    modelName,
                                                                    fieldName]],
                                                  @[@"src", @"!=", @"value"],
                                                  @[@"lang", @"=", gPreferences.Language],
                                                  @[@"state", @"=", @"translated"]]]
                                   conditions:@{@"fields": @[@"res_id", @"value"]}
                                        error:error];
    if( *error ) return nil;
    
    /*---------- 设置菜单翻译对照表 ----------*/
    NSMutableDictionary* translateMap = [NSMutableDictionary new];
    for( NSDictionary* translate in responseObject )
    {
        NSNumber* resID = [translate objectForKey:@"res_id"];
        NSString* translatedString = SafeCopy([translate objectForKey:@"value"]);
        
        [translateMap setObject:translatedString forKey:resID];
    }
    
    /*---------- 开始翻译字段 ----------*/
    NSMutableArray* translatedItems = [NSMutableArray new];
    for( NSDictionary* item in srcItems )
    {
        NSMutableDictionary* translatedItem = [NSMutableDictionary dictionaryWithDictionary:item];
        NSString* translatedString = [translateMap objectForKey:[translatedItem objectForKey:@"id"]];
        if( translatedString.length > 0 )
        {
            [translatedItem setObject:translatedString forKey:fieldName];
        }
        [translatedItems addObject:translatedItem];
    }
    return translatedItems;
}

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 翻译Model中的名称
 *  @param request   请求对象
 *  @param srcItems  要翻译的内容采用['src1', 'src2', ...]结构
 *  @param fieldName 要翻译的字段名
 *  @param modelName 要翻译的模块
 *  @param error     错误对象指针
 *  @return 翻译结果
 */
id asyncTranslateNames(OdooRequestModel* request, NSArray* srcItems, NSString* fieldName, NSString* modelName, NSError** error)
{
    if( !request )
    {
        request = [[OdooRequestModel alloc] initWithObserveModel:nil andCallback:nil];
    }
    
    /*---------- 翻译指定模块的字段 ----------*/
    id responseObject = [request asyncExecute:@"ir.translation"
                                       method:@"search_read"
                                   parameters:@[@[@[@"name", @"=", [NSString stringWithFormat:@"%@,%@",
                                                                    modelName,
                                                                    fieldName]],
                                                  @[@"src", @"!=", @"value"],
                                                  @[@"lang", @"=", gPreferences.Language],
                                                  @[@"state", @"=", @"translated"]]]
                                   conditions:@{@"fields": @[@"src", @"res_id", @"value"]}
                                        error:error];
    if( *error ) return nil;
    
    /*---------- 设置菜单翻译对照表 ----------*/
    NSMutableDictionary* translateMap = [NSMutableDictionary new];
    for( NSDictionary* translate in responseObject )
    {
        NSString* src = [[translate objectForKey:@"src"] lowercaseString];
        NSString* translatedString = SafeCopy([translate objectForKey:@"value"]);
        
        [translateMap setObject:translatedString forKey:src];
    }
    
    /*---------- 开始翻译字段 ----------*/
    NSMutableDictionary* translatedItems = [NSMutableDictionary new];
    for( NSString* item in srcItems )
    {
        NSString* translatedString = [translateMap objectForKey:item];
        if( translatedString.length == 0 ) translatedString = item;
        [translatedItems setObject:translatedString forKey:item];
    }
    return translatedItems;
}

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 翻译模型
 */
@implementation TranslateModel

@end
