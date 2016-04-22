//
//  ServerSettingViewController.m
//

#import "ServerSettingViewController.h"
#import "Preferences.h"

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 服务器设置界面视图
 */
@implementation ServerSettingViewController

#pragma mark
#pragma mark init & dealloc

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.serverNameField.text = gPreferences.ServerName;
    if( [gPreferences.ServerName hasPrefix:@"https://"] )
    {
        self.protocolTypeField.text = @"HTTPS";
        self.protocolTypeSwitch.on = YES;
    }
    else
    {
        self.protocolTypeField.text = @"HTTP";
        self.protocolTypeSwitch.on = NO;
    }
    self.dbNameField.text = gPreferences.DBName;
}

#pragma mark
#pragma mark UITextFieldDelegate

-(IBAction) :(id)sender

@end
