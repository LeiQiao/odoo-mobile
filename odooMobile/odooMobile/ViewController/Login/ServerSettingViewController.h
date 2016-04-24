//
//  ServerSettingViewController.h
//

#import <UIKit/UIKit.h>
#import "CXPickerTextField.h"

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 服务器设置界面视图
 */
@interface ServerSettingViewController : UITableViewController

@property(nonatomic, strong) IBOutlet UITextField* serverNameField;      /*!< 服务器名称 */
@property(nonatomic, strong) IBOutlet UILabel* protocolTypeLabel;        /*!< 协议类型名称 */
@property(nonatomic, strong) IBOutlet UISwitch*  protocolTypeSwitch;     /*!< 协议类型开关 */
@property(nonatomic, strong) IBOutlet CXPickerTextField* dbNameField;    /*!< 数据库名称 */

@end
