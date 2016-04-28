//
//  MenuModel.m
//

#import "MenuModel.h"
#import "OdooRequestModel.h"
#import "Preferences.h"
#import "GlobalModels.h"

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
        // 剔除已存在的菜单
        for( NSDictionary* existMenu in allMenus )
        {
            if( [[existMenu objectForKey:@"id"] isEqual:[menu objectForKey:@"id"]] )
            {
                [allMenus removeObject:menu];
                break;
            }
        }
        // 添加菜单到Preferences菜单列表
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
 *  @author LeiQiao, 16-04-26
 *  @brief 同步方式根据给定的组获取该组可用的菜单
 *  @param request  请求对象
 *  @param groupIDs 组ID
 *  @param error    错误对象指针
 *  @return 菜单列表
 */
NSArray* asyncRequestMenu(OdooRequestModel* request, NSArray* groupIDs, NSError** error)
{
    if( !request )
    {
        request = [[OdooRequestModel alloc] initWithObserveModel:nil andCallback:nil];
    }
    
    id responseObject = [request asyncExecute:@"ir.ui.menu"
                                       method:@"search_read"
                                   parameters:@[@[@[@"groups_id", @"in", groupIDs]]]
                                   conditions:@{@"fields": menuFields()}
                                        error:error];
    if( *error ) return nil;
    
    return asyncTranslateFields(request, responseObject, @"name", @"ir.ui.menu", error);
}

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 菜单模型
 */
@implementation MenuModel

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 获取指定菜单的子菜单
 *  @param menu 父菜单
 */
-(void) updateSubMenuByMenu:(NSDictionary*)menu
{
    [NSThread detachNewThreadSelector:@selector(updateSubMenuByMenuThread:) toTarget:self withObject:menu];
}

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 获取指定菜单的子菜单线程
 *  @param menu 父菜单
 */
-(void) updateSubMenuByMenuThread:(NSDictionary*)menu
{
    OdooRequestModel* request = [[OdooRequestModel alloc] initWithObserveModel:self andCallback:@selector(menuModel:updateSubMenuByMenu:)];
    request.retParam[@"ParentMenu"] = menu;
    
    /*---------- 是否包含子菜单 ----------*/
    NSMutableArray* subMenuIDs = [menu objectForKey:@"child_id"];
    
    if( (![subMenuIDs isKindOfClass:[NSArray class]]) ||
       (subMenuIDs.count == 0) )
    {
        request.retParam.success = NO;
        request.retParam.failedCode = @"-1";
        request.retParam.failedReason = @"没有子菜单";
        [request callObserver];
        return;
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
        request.retParam.success = YES;
        request.retParam.failedCode = @"0";
        request.retParam.failedReason = @"菜单获取成功";
        request.retParam[@"SubMenus"] = reorderMenuWithIDs(subMenus, [menu objectForKey:@"child_id"]);
        [request callObserver];
        return;
    }
    
    /*---------- 获取当前菜单列表没有的子菜单 ----------*/
    NSError* error = nil;
    id responseObject = [request asyncExecute:@"ir.ui.menu"
                                       method:@"search_read"
                                   parameters:@[@[@[@"id", @"in", subMenuIDs]]]
                                   conditions:@{@"fields": menuFields()}
                                        error:&error];
    if( error )
    {
        [request callObserver];
        return;
    }
    
    /*---------- 翻译菜单 ----------*/
    responseObject = asyncTranslateFields(request, responseObject, @"name", @"ir.ui.menu", &error);
    
    /*---------- 更新菜单列表 ----------*/
    addMenusToPreferences(responseObject);
    [subMenus addObjectsFromArray:responseObject];
    reorderMenuWithIDs(subMenus, [menu objectForKey:@"child_id"]);
    
    /*---------- 更新完成，回调观察者 ----------*/
    request.retParam.success = YES;
    request.retParam.failedCode = @"0";
    request.retParam.failedReason = @"菜单获取成功";
    request.retParam[@"SubMenus"] = reorderMenuWithIDs(subMenus, [menu objectForKey:@"child_id"]);
    [request callObserver];
}

@end
