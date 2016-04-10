//
//  TranslationNetwork.m
//

#import "TranslationNetwork.h"

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 翻译相关的网络通讯
 */
@implementation TranslationNetwork

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 翻译Model中的某个字段，根据Model项的id与翻译表中的src_id对应
 *  @param srcItems  要翻译的内容采用[{'id':'xxx', 'field':'value', ...}, ...]结构
 *  @param fieldName 要翻译的字段名
 *  @param modelName 要翻译的模块
 *  @return 翻译结果
 */
-(NetworkResponse*) translate:(NSArray*)srcItems fieldName:(NSString*)fieldName inModel:(NSString*)modelName
{
    NSMutableArray* srcIDs = [NSMutableArray new];
    for( NSDictionary* item in srcItems )
    {
        [srcIDs addObject:[item objectForKey:@"id"]];
    }
    
    /*---------- 翻译指定模块的字段 ----------*/
    NetworkResponse* response = [self execute:@"ir.translation"
                                       method:@"search_read"
                                   parameters:@[@[@[@"res_id", @"in", srcIDs],
                                                  @[@"name", @"=", [NSString stringWithFormat:@"%@,%@",
                                                                    modelName,
                                                                    fieldName]],
                                                  @[@"src", @"!=", @"value"],
                                                  @[@"lang", @"=", gPreferences.Language],
                                                  @[@"state", @"=", @"translated"]]]
                                   conditions:@{@"fields": @[@"res_id", @"value"]}];
    if( !response.success ) return response;
    
    /*---------- 设置菜单翻译对照表 ----------*/
    NSMutableDictionary* translateMap = [NSMutableDictionary new];
    for( NSDictionary* translate in response.responseObject )
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
    
    response.responseObject = translatedItems;
    return response;
}

@end
