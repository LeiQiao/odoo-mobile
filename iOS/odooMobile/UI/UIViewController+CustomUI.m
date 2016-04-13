//
//  UIViewController+CustomUI.m
//  DPAS
//
//  Created by LeiQiao on 15/12/7.
//  Copyright © 2015年 LeiQiao. All rights reserved.
//

#import "UIViewController+CustomUI.h"

@implementation UIViewController (CustomUI)

#pragma mark
#pragma mark member functions

-(void) removeNavigationBarBackground
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        // 子视图添加至数组
        NSArray *list=self.navigationController.navigationBar.subviews;
        // 遍历子视图数组
        for (id obj in list) {
            
            if ([obj isKindOfClass:[UIImageView class]]) {
                
                UIImageView *imageView=(UIImageView *)obj;
                
                imageView.hidden=YES;
            }
        }
    }
    // 设置状态栏
    UIView* statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     -20,
                                                                     [UIScreen mainScreen].bounds.size.width,
                                                                     20)];
    statusBarView.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addSubview:statusBarView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
}

-(void) setLeftButtonTitle:(NSString*)leftButtonTitle
{
    if( !leftButtonTitle )
    {
        // 使用隐藏的View来设置按钮
        UIView* emptyV = [[UIView alloc] init];
        emptyV.hidden = YES;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:emptyV];
    }
    else
    {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:leftButtonTitle
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(leftButtonDidClicked:)];
        self.navigationItem.leftBarButtonItem = button;
    }
}

-(void) setLeftButtonImage:(UIImage*)leftButtonImage
{
    if( !leftButtonImage )
    {
        // 使用隐藏的View来设置按钮
        UIView* emptyV = [[UIView alloc] init];
        emptyV.hidden = YES;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:emptyV];
    }
    else
    {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:leftButtonImage
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(leftButtonDidClicked:)];
        self.navigationItem.leftBarButtonItem = button;
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1];
    }
}

-(void) setRightButtonTitle:(NSString*)rightButtonTitle
{
    if( !rightButtonTitle )
    {
        // 使用隐藏的View来设置按钮
        UIView* emptyV = [[UIView alloc] init];
        emptyV.hidden = YES;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:emptyV];
    }
    else
    {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:rightButtonTitle
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(rightButtonDidClicked:)];
        self.navigationItem.rightBarButtonItem = button;
    }
}

-(void) setRightButtonImage:(UIImage*)rightButtonImage
{
    if( !rightButtonImage )
    {
        // 使用隐藏的View来设置按钮
        UIView* emptyV = [[UIView alloc] init];
        emptyV.hidden = YES;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:emptyV];
    }
    else
    {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithImage:rightButtonImage
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(rightButtonDidClicked:)];
        self.navigationItem.rightBarButtonItem = button;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1];
    }
}

-(void) leftButtonDidClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) rightButtonDidClicked:(id)sender
{
    NSAssert(NO, @"subclass MUST override (rightButtonDidClicked:)");
}

@end
