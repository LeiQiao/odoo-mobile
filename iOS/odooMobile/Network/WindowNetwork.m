//
//  WindowNetwork.m
//

#import "WindowNetwork.h"
#import "GDataXMLNode.h"

/*!
 *  @author LeiQiao, 16-04-11
 *  @brief 从视图列表中搜索根视图
 *  @param views 视图列表
 *  @return 根视图
 */
NSDictionary* getRootViewInViews(NSArray* views)
{
    for( NSDictionary* view in views )
    {
        if( [[view objectForKey:@"inherit_id"] isKindOfClass:[NSNumber class]] )
        {
            return view;
        }
    }
    return nil;
}

/*!
 *  @author LeiQiao, 16-04-11
 *  @brief 从View列表中查找指定ID的视图
 *  @param views  View列表
 *  @param viewID 要查找的视图ID
 *  @return 从View列表中查找指定ID的视图
 */
NSDictionary* viewInViews(NSArray* views, NSNumber* viewID)
{
    for( NSDictionary* view in views )
    {
        if( [[view objectForKey:@"id"] integerValue] == [viewID integerValue] )
        {
            return view;
        }
    }
    return nil;
}

/*!
 *  @author LeiQiao, 16-04-11
 *  @brief 从View列表中查找指定View的子视图
 *  @param views      View列表
 *  @param parentView 父视图
 *  @return 从View列表中查找指定View的子视图
 */
NSArray* childViewsFromViews(NSArray* views, NSDictionary* parentView)
{
    NSArray* childViewIDs = [parentView objectForKey:@"inherit_children_ids"];
    NSMutableArray* childViews = [NSMutableArray new];
    
    for( NSNumber* childViewID in childViewIDs )
    {
        [childViews addObject:viewInViews(views, childViewID)];
    }
    return childViews;
}

/*!
 *  @author LeiQiao, 16-04-11
 *  @brief 从View列表查找根View的XML信息
 *  @param views      View列表
 *  @param parentView 根View
 *  @return 根View的XML信息
 */
NSArray* getChildViewXMLList(NSArray* views, NSDictionary* parentView)
{
    NSMutableArray* xmls = [NSMutableArray new];
    
    // 如果根View为空则查找列表中引用为空的View作为根View
    if( !parentView )
    {
        parentView = getRootViewInViews(views);
        [xmls addObject:[parentView objectForKey:@"arch"]];
    }
    
    // 查找子View，获取子View的XML信息
    NSArray* childViews = childViewsFromViews(views, parentView);
    for( NSDictionary* view in childViews )
    {
        [xmls addObject:[view objectForKey:@"arch"]];
    }
    
    // 便利子View，获取子View的所有XML信息
    for( NSDictionary* view in childViews )
    {
        [xmls addObjectsFromArray:getChildViewXMLList(views, view)];
    }
    
    return xmls;
}

/*!
 *  @author LeiQiao, 16-04-11
 *  @brief 合并视图及扩展视图的XML
 *  @param viewXMLs 所有视图和扩展视图的XML
 */
void mergeViewXMLs(NSArray* viewXMLs)
{
    for( NSString* xml in viewXMLs )
    {
        GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithXMLString:xml
                                                                    options:0
                                                                      error:nil];
        if (doc == nil) { return; }
    }
}

@implementation WindowNetwork

/*!
 *  @author LeiQiao, 16-04-11
 *  @brief 根据视图的所有扩展视图
 *  @param views 所有被扩展的视图
 *  @return 所有被扩展的视图及扩展的视图
 */
-(NetworkResponse*) getAllInheritChildrenViews:(NSArray*)views
{
    /*---------- 查找所有不存在的扩展视图 ----------*/
    NSMutableArray* inheritChildrenIDs = [NSMutableArray new];
    for( NSDictionary* view in views )
    {
        NSArray* inheritChildren = [view objectForKey:@"inherit_children_ids"];
        for( NSNumber* inheritChild in inheritChildren )
        {
            NSDictionary* view = viewInViews(views, inheritChild);
            if( !view )
            {
                [inheritChildrenIDs addObject:inheritChild];
            }
        }
    }
    
    /*---------- 如果没有不存在扩展视图则获取成功，直接返回 ----------*/
    if( inheritChildrenIDs.count == 0 )
    {
        NetworkResponse* response = [[NetworkResponse alloc] initWithSuccess:YES
                                                             andFailedReason:@"获取成功"];
        response.responseObject = views;
        return response;
    }
    
    /*---------- 获取视图模型 ----------*/
    NetworkResponse* response = [self execute:@"ir.ui.view"
                                       method:@"search_read"
                                   parameters:@[@[@[@"id", @"in", inheritChildrenIDs]]]
                                   conditions:nil];
    if( !response.success ) return response;
    
    NSMutableArray* allViews = [NSMutableArray arrayWithArray:views];
    [allViews addObjectsFromArray:response.responseObject];
    
    return [self getAllInheritChildrenViews:allViews];
}

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
    NSMutableArray* viewModes = [NSMutableArray arrayWithArray:[[window objectForKey:@"view_mode"] componentsSeparatedByString:@","]];
    if( !viewModes )
    {
        viewModes = [NSMutableArray new];
    }
    [viewModes addObject:@"search"];
    
    /*---------- 获取窗口的所有视图模型 ----------*/
    response = [self execute:@"ir.ui.view"
                      method:@"search_read"
                  parameters:@[@[@[@"model", @"=", model],
                                 @[@"type", @"in", viewModes],
                                 @[@"mode", @"=", @"primary"]]]
                  conditions:nil];
    if( !response.success ) return response;
    
    /*---------- 获取所有主视图模型扩展的视图模型 ----------*/
    response = [self getAllInheritChildrenViews:response.responseObject];
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
    
    NSArray* typeKeys = windowModes.allKeys;
    for( NSString* type in typeKeys )
    {
        NSArray* modeDatas = [windowModes objectForKey:type];
        NSArray* xmllist = getChildViewXMLList(modeDatas, nil);
        mergeViewXMLs(xmllist);
    }
    
    /*---------- 将视图模型保存到全局变量 ----------*/
    NSMutableDictionary* windows = [NSMutableDictionary dictionaryWithDictionary:gPreferences.Windows];
    [windows setObject:windowModes forKey:model];
    gPreferences.Windows = windows;
    
    response.responseObject = windowModes;
    return response;
}

@end
