//
//  MenuViewController.h
//

#import <UIKit/UIKit.h>

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 菜单界面视图
 */
@interface MenuViewController : UITableViewController

@property(nonatomic, strong) NSDictionary* parentMenu;      /*!< 父菜单 */

@end
