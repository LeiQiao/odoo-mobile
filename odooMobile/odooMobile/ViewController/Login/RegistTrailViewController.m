//
//  RegistTrailViewController.m
//

#import "RegistTrailViewController.h"

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 注册测试版窗体
 */
@implementation RegistTrailViewController

#pragma mark
#pragma mark button events

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 发送邮件按钮按下
 *  @param sender 发送邮件按钮
 */
-(IBAction) emailMe:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://leiqiaotalk@hotmail.com"]];
}

@end
