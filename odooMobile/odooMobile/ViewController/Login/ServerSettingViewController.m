//
//  ServerSettingViewController.m
//

#import "ServerSettingViewController.h"
#import "Preferences.h"
#import "GlobalModels.h"
#import "HUD.h"
#import "ZQCustomDataPicker.h"

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 服务器设置界面视图
 */
@implementation ServerSettingViewController {
    NSArray* _databases;    /*!< 可用的数据库列表 */
}

#pragma mark
#pragma mark helper

-(NSString*) serverName
{
    // 剔除手动打上去的协议头
    NSString* serverName = self.serverNameField.text;
    if( [serverName hasPrefix:@"http://"] )
    {
        serverName = [serverName substringFromIndex:@"http://".length];
    }
    else if( [serverName hasPrefix:@"https://"] )
    {
        serverName = [serverName substringFromIndex:@"https://".length];
    }
    
    // 添加配置的协议头
    if( self.protocolTypeSwitch.on )
    {
        serverName = [NSString stringWithFormat:@"https://%@", serverName];
    }
    else
    {
        serverName = [NSString stringWithFormat:@"http://%@", serverName];
    }
    return serverName;
}

#pragma mark
#pragma mark init & dealloc

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // 根据服务器地址前缀显示是否加密传输
    NSString* serverName = gPreferences.ServerName;
    if( [serverName hasPrefix:@"http://"] )
    {
        self.protocolTypeSwitch.on = NO;
        serverName = [serverName substringFromIndex:@"http://".length];
    }
    else if( [serverName hasPrefix:@"https://"] )
    {
        self.protocolTypeSwitch.on = YES;
        serverName = [serverName substringFromIndex:@"https://".length];
    }
    
    // 初始化字段
    self.serverNameField.text = serverName;
    self.dbNameField.text = gPreferences.DBName;
    
    ADDOBSERVER(UserModel, (id<UserModelObserver>)self);
}

-(void) dealloc
{
    REMOVEOBSERVER(UserModel, (id<UserModelObserver>)self);
}

#pragma mark
#pragma mark button events

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief 保存配置按钮按下
 *  @param sender 保存配置按钮
 */
-(IBAction) done:(id)sender
{
    if( self.serverNameField.text.length == 0 )
    {
        popError(@"请先输入服务器地址");
    }
    else if( self.dbNameField.text.length == 0 )
    {
        popError(@"请选择数据库");
    }
    else if( !_databases )
    {
        popWaiting();
        [GETMODEL(UserModel) checkDatabaseExist:self.serverName dbName:self.dbNameField.text];
    }
    else
    {
        gPreferences.ServerName = self.serverName;
        gPreferences.DBName = self.dbNameField.text;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark
#pragma mark UITextFieldDelegate

/*!
 *  @author LeiQiao, 16/04/22
 *  @brief 加密传输方式改变
 *  @param sender 加密传输开关控件
 */
-(IBAction) onProtocolChanged:(id)sender
{
    if( self.protocolTypeSwitch.on )
    {
        self.protocolTypeLabel.text = @"HTTPS";
    }
    else
    {
        self.protocolTypeLabel.text = @"HTTP";
    }
}

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 改变服务器名称
 *  @param sender 服务器名称输入框
 */
-(IBAction) onServerNameChanged:(id)sender
{
    _databases = nil;
    self.dbNameField.text = @"";
}

#pragma mark
#pragma mark UITextFieldDelegate

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField
{
    if( textField == self.dbNameField )
    {
        // 先输入服务器地址
        if( self.serverNameField.text.length == 0 )
        {
            [self.serverNameField becomeFirstResponder];
            popError(@"请先输入服务器地址");
            return NO;
        }
        
        // 请求数据库列表
        if( !_databases )
        {
            [self.dbNameField resignFirstResponder];
            
            popWaiting();
            [GETMODEL(UserModel) requestDatabase:self.serverName];
            return NO;
        }
        else return YES;
    }
    
    return YES;
}

#pragma mark
#pragma mark UserModelObserver

-(void) userModel:(UserModel*)userModel requestDatabase:(ReturnParam*)params
{
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
        [self.dbNameField resignFirstResponder];
        return;
    }
    
    _databases = params.userInfo[@"Databases"];
    
    if( _databases.count == 0 )
    {
        popError(@"没有搜索到数据库，请手动指定数据库");
        self.dbNameField.placeholder = @"没有搜索到数据库，请手动指定数据库";
        self.dbNameField.enablePicker = NO;
        self.dbNameField.enabled = YES;
        return;
    }
    else if( _databases.count == 1 )
    {
        // 如果只有一个数据库则默认选择该数据库
        self.dbNameField.text = _databases[0];
        self.dbNameField.enablePicker = YES;
        [self.navigationController popViewControllerAnimated:YES];
        
        gPreferences.ServerName = self.serverName;
        gPreferences.DBName = self.dbNameField.text;
        return;
    }
    else // 弹出Picker选择数据库
    {
        self.dbNameField.dataArray = _databases;
        self.dbNameField.enablePicker = YES;
        self.dbNameField.enabled = YES;
        [self.dbNameField becomeFirstResponder];
    }
}

-(void) userModel:(UserModel*)userModel checkDatabaseExist:(ReturnParam*)params
{
    dismissWaiting();
    if( !params.success )
    {
        popError(params.failedReason);
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
