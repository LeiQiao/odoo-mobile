//
//  LoginViewController.m
//

#import "LoginViewController.h"
#import "Preferences.h"
#import "HUD.h"
#import "GlobalModels.h"

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 登录界面视图
 */
@implementation LoginViewController

#pragma mark
#pragma mark init & dealloc

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // 显示用户名密码
    self.userNameField.text = gPreferences.UserName;
    // 因为密码存储在keychain中，如果重新安装应用后密码不会删除
    if( self.userNameField.text.length > 0 )
    {
        self.passwordField.text = gPreferences.Password;
    }
    [self textFieldDidChanged:nil];
    
    ADDOBSERVER(UserModel, (id<UserModelObserver>)self);
}

-(void) dealloc
{
    REMOVEOBSERVER(UserModel, (id<UserModelObserver>)self);
}

#pragma mark
#pragma mark button events

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 登录按钮按下
 *  @param sender 登录按钮
 */
-(IBAction) onLogin:(id)sender
{
    if( gPreferences.ServerName.length == 0 )
    {
        popError(@"请先设置服务器地址");
        [self performSegueWithIdentifier:@"ServerSettingSegue" sender:self];
        return;
    }
    
    // 登录
    popWaiting();
    [GETMODEL(UserModel) login:gPreferences.ServerName
                        dbName:gPreferences.DBName
                      userName:self.userNameField.text
                      password:self.passwordField.text];
}

#pragma mark
#pragma mark UITextFieldDelegate

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 输入框点击确定事件
 *  @param sender 输入框对象
 */
-(IBAction) textFieldDidReturn:(id)sender
{
    // 输入框焦点向下传递
    if( sender == self.userNameField )
    {
        [self.passwordField becomeFirstResponder];
    }
}

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 输入框输入事件
 *  @param sender 输入框对象
 */
-(IBAction) textFieldDidChanged:(id)sender
{
    self.loginButton.enabled = ((self.userNameField.text.length > 0) &&
                                (self.passwordField.text.length > 0));
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 点击任意行则隐藏键盘
 *  @param tableView tableView
 *  @param indexPath 点击的行索引
 */
-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

#pragma mark
#pragma mark UserModelObserver

-(void) userModel:(UserModel*)userModel login:(ReturnParam*)params
{
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
        return;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

@end
