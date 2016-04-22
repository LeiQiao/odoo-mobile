//
//  ServerSettingViewController.h
//

#import <UIKit/UIKit.h>

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 服务器设置界面视图
 */
@interface ServerSettingViewController : UITableViewController

@property(nonatomic, strong) UITextField* serverNameField;      /*!< 服务器名称 */
@property(nonatomic, strong) UITextField* protocolTypeField;    /*!< 协议类型名称 */
@property(nonatomic, strong) UISwitch*  protocolTypeSwitch;     /*!< 协议类型开关 */
@property(nonatomic, strong) UITextField* dbNameField;          /*!< 数据库名称 */

@end
