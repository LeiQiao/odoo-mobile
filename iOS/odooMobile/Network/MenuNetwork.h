//
//  MenuNetwork.h
//

#import "OdooNetwork.h"

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 菜单网络相关
 */
@interface MenuNetwork : OdooNetwork

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 根据给定的组获取该组可用的菜单
 *  @param groupIDs 组ID
 *  @return 菜单结果
 */
-(NetworkResponse*) getMenuByGroupIDs:(NSArray*)groupIDs;

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 获取指定菜单的子菜单
 *  @param menu 父菜单
 *  @return 子菜单结果
 */
-(NetworkResponse*) getSubMenuByMenu:(NSDictionary*)menu;

@end
