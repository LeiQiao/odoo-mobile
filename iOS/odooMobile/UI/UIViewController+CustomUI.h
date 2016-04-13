//
//  UIViewController+CustomUI.h
//  DPAS
//
//  Created by LeiQiao on 15/12/7.
//  Copyright © 2015年 LeiQiao. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  @author LeiQiao, 15-12-07
 *  @brief UIViewController的定制样式
 */
@interface UIViewController (CustomUI)

/*!
 *  @author LeiQiao, 15-12-07
 *  @brief 删除默认的标题背景
 */
-(void) removeNavigationBarBackground;

/*!
 *  @author LeiQiao, 15-12-07
 *  @brief 设置左上角按钮的文字
 *  @param button 左上角按钮的文字
 */
-(void) setLeftButtonTitle:(NSString*)leftButtonTitle;

/*!
 *  @author LeiQiao, 15-12-07
 *  @brief 设置左上角按钮的图片
 *  @param leftButtonImage 左上角按钮的图片
 */
-(void) setLeftButtonImage:(UIImage*)leftButtonImage;

/*!
 *  @author LeiQiao, 15-12-07
 *  @brief 设置右上角按钮的文字
 *  @param button 右上角按钮的文字
 */
-(void) setRightButtonTitle:(NSString*)rightButtonTitle;

/*!
 *  @author LeiQiao, 15-12-07
 *  @brief 设置右上角按钮的图片
 *  @param rightButtonImage 右上角按钮的图片
 */
-(void) setRightButtonImage:(UIImage*)rightButtonImage;

/* need override */
-(void) leftButtonDidClicked:(id)sender;
-(void) rightButtonDidClicked:(id)sender;

@end
