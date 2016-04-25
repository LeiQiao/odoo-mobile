//
//  MenuNetwork.m
//

#import "MenuNetwork.h"
#import "TranslationNetwork.h"

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 获取菜单表的字段
 *  @return 获取菜单表的字段
 */
NSArray* menuFields()
{
    return @[@"id",
             @"parent_id",
             @"child_id",
             @"web_icon",
             @"action",
             @"name"];
}

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 将菜单添加至Preferences中，没有防重复机制，需要调用者自己处理
 *  @param menus 菜单项
 */
void addMenusToPreferences(NSArray* menus)
{
    NSMutableArray* allMenus = [NSMutableArray arrayWithArray:gPreferences.Menus];
    for( NSDictionary* menu in menus )
    {
        [allMenus addObject:menu];
    }
    gPreferences.Menus = allMenus;
}

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 使用给定的顺序重新排列菜单，
 *         ＊如果顺序ID列表中没有菜单中的项则最后排序好的菜单就没有该项
 *  @param menus    菜单
 *  @param orderIDs ID顺序
 *  @return 顺序排列好的菜单
 */
NSArray* reorderMenuWithIDs(NSArray* menus, NSArray* orderIDs)
{
    NSMutableArray* orderedMenus = [NSMutableArray new];
    for( NSNumber* orderID in orderIDs )
    {
        for( NSDictionary* menu in menus )
        {
            if( [[menu objectForKey:@"id"] integerValue] == [orderID integerValue] )
            {
                [orderedMenus addObject:menu];
            }
        }
    }
    return orderedMenus;
}

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 菜单网络相关
 */
@implementation MenuNetwork

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 根据给定的组获取该组可用的菜单
 *  @param groupIDs 组ID
 *  @return 菜单结果
 */
-(NetworkResponse*) getMenuByGroupIDs:(NSArray*)groupIDs
{
    /*---------- 获取指定组的菜单 ----------*/
    NetworkResponse* response = [self execute:@"ir.ui.menu"
                                       method:@"search_read"
                                   parameters:@[@[@[@"groups_id", @"in", groupIDs]]]
                                   conditions:@{@"fields": menuFields()}];
    if( !response.success ) return response;
    
    /*---------- 翻译菜单 ----------*/
    TranslationNetwork* translation = [[TranslationNetwork alloc] init];
    response = [translation translate:response.responseObject
                            fieldName:@"name"
                              inModel:@"ir.ui.menu"];
    
    /*---------- 更新菜单列表 ----------*/
    addMenusToPreferences(response.responseObject);
    
    return response;
}

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 获取指定菜单的子菜单
 *  @param menu 父菜单
 *  @return 子菜单结果
 */
-(NetworkResponse*) getSubMenuByMenu:(NSDictionary*)menu
{
    NetworkResponse* response = [[NetworkResponse alloc] initWithSuccess:NO
                                                         andFailedReason:@"没有子菜单"];
    
    /*---------- 是否包含子菜单 ----------*/
    NSMutableArray* subMenuIDs = [menu objectForKey:@"child_id"];
    
    if( (![subMenuIDs isKindOfClass:[NSArray class]]) ||
       (subMenuIDs.count == 0) )
    {
        return response;
    }
    
    /*---------- 筛选当前菜单列表中没有的子菜单 ----------*/
    subMenuIDs = [NSMutableArray arrayWithArray:subMenuIDs];
    NSMutableArray* subMenus = [NSMutableArray new];
    
    for( NSDictionary* menu in gPreferences.Menus )
    {
        NSNumber* menuID = [menu objectForKey:@"id"];
        if( [subMenuIDs containsObject:menuID] )
        {
            [subMenuIDs removeObject:menuID];
            [subMenus addObject:menu];
        }
    }
    
    /*---------- 如果所有子菜单都已经获取成功 ----------*/
    if( subMenuIDs.count == 0 )
    {
        [response setSuccessAndMessage:@"菜单获取成功"];
        response.responseObject = reorderMenuWithIDs(subMenus, [menu objectForKey:@"child_id"]);
        return response;
    }
    
    /*---------- 获取当前菜单列表没有的子菜单 ----------*/
    response = [self execute:@"ir.ui.menu"
                      method:@"search_read"
                  parameters:@[@[@[@"id", @"in", subMenuIDs]]]
                  conditions:@{@"fields": menuFields()}];
    if( !response.success ) return response;
    
    /*---------- 翻译菜单 ----------*/
    TranslationNetwork* translation = [[TranslationNetwork alloc] init];
    response = [translation translate:response.responseObject
                            fieldName:@"name"
                              inModel:@"ir.ui.menu"];
    
    /*---------- 更新菜单列表 ----------*/
    addMenusToPreferences(response.responseObject);
    [subMenus addObjectsFromArray:response.responseObject];
    
    response.responseObject = reorderMenuWithIDs(subMenus, [menu objectForKey:@"child_id"]);
    return response;
}

@end
