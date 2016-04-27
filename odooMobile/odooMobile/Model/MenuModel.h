//
//  MenuModel.h
//

#import "ModelObserver.h"
#import "OdooRequestModel.h"

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 将菜单添加至Preferences中，没有防重复机制，需要调用者自己处理
 *  @param menus 菜单项
 */
void addMenusToPreferences(NSArray* menus);

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 同步方式根据给定的组获取该组可用的菜单
 *  @param request  请求对象
 *  @param groupIDs 组ID
 *  @param error    错误对象指针
 *  @return 菜单列表
 */
extern NSArray* asyncRequestMenu(OdooRequestModel* request, NSArray* groupIDs, NSError** error);

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 菜单模型
 */
@interface MenuModel : BaseModel

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 获取指定菜单的子菜单
 *  @param menu 父菜单
 */
-(void) updateSubMenuByMenu:(NSDictionary*)menu;

@end

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 菜单模型监听协议
 */
@protocol MenuModelObserver <BaseModelObserver>

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 获取指定菜单的子菜单结果
 *  @param userModel 用户模型
 *  @param params    返回参数
 *         params[@"ParentMenu"]   父菜单
 *         params[@"SubMenus"]     子菜单列表
 */
-(void) menuModel:(MenuModel*)menuModel updateSubMenuByMenu:(ReturnParam*)params;

@end
