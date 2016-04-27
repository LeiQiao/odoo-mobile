//
//  MenuViewController.h
//

#import <UIKit/UIKit.h>


@interface MenuViewController : UITableViewController

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 使用父菜单初始化
 *  @param parentMenu 父菜单
 *  @return 本类的实例化对象
 */
-(instancetype) initWithParentMenu:(NSDictionary*)parentMenu;

@end
