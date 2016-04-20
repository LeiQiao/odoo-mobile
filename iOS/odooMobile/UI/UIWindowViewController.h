//
//  UIWindowViewController.h
//

#import <UIKit/UIKit.h>

/*!
 窗体视图,使用TableView列表方式展示
 */
@interface UIWindowViewController : UIViewController

/*!
 *  @author LeiQiao, 16-04-19
 *  @brief 使用窗体信息重新加载窗体视图
 *  @param windowData 窗体视图
 */
-(void) updateWindowWithWindowData:(NSString*)windowData;

@end
