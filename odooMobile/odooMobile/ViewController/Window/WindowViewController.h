//
//  WindowViewController.h
//

#import <UIKit/UIKit.h>

/*!
 *  @author LeiQiao, 16-04-27
 *  @brief 窗口菜单视图
 */
@interface WindowViewController : UITableViewController

@property(nonatomic) NSNumber* windowID;    /*!< 窗口ID */
@property(nonatomic, strong) IBOutlet UISegmentedControl* viewModeSegment;  /*!< 试图模式切换器 */

@end
