//
//  LoginViewController.h
//

#import <UIKit/UIKit.h>

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 登录界面视图
 */
@interface LoginViewController : UITableViewController

@property(nonatomic, strong) IBOutlet UITextField* userNameField;   /*!< 用户名输入框 */
@property(nonatomic, strong) IBOutlet UITextField* passwordField;   /*!< 密码输入框 */
@property(nonatomic, strong) IBOutlet UIButton* loginButton;        /*!< 确定按钮 */

@end
