//
//  NullableDatePicker.h
//  NullableDatePicker
//
//  Created by He Zhongjie on 15/6/2.
//  Copyright (c) 2015年 He Zhongjie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZQNullableDatePicker;

@protocol nullableDatePickerDelegate <NSObject>
@end

@interface ZQNullableDatePicker : UIView

@property(nonatomic,weak) id<nullableDatePickerDelegate> delegate;


-(instancetype)initWithYear:(NSInteger)defaultYear month:(NSInteger)defaultMonth day:(NSInteger)defaultDay yPosition:(CGFloat)y;
-(instancetype)initWithyPosition:(CGFloat)y;


//selected result 
-(NSArray *)selectedData;
@end

