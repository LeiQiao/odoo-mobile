//
//  CustomDataPicker.h
//  CustomDataPicker
//
//  Created by Qian Zhou on 15/5/7.
//  Copyright (c) 2015年 Qian Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, CustomPickerType) {
    ZQCustomDataPickerTypeNormal = 0,
    ZQCustomDataPickerTypeNullable,
    ZQCustomDataPickerTypeDate
};

@class ZQCustomDataPicker;


@protocol ZQCustomDataPickerDelegate <NSObject>

@optional
//implement it to get result when there's toolbar
- (void)customPickerViewDoneBtnClicked:(ZQCustomDataPicker *)pickerView resultString:(NSString *)resultString;
//implement it to get result when there's NO toolbar
- (void)customPickerView:(UIPickerView *)pickerView didSelectWithResultArray:(NSArray *)resultArray ResultString:(NSString *)resultString;
//implement it to hide the picker when used as text field or text view's input view
- (void)customPicerShouldDisappear;
@end

@interface ZQCustomDataPicker : UIView 

//result
@property (nonatomic, strong) NSString *resultString;
@property (nonatomic, strong) NSMutableArray *resultArray; //nullableDatePicker must use it to get result
//input data to be displayed, must be of string type.
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *selectionArray;

@property (nonatomic) CustomPickerType type;

@property (nonatomic, weak) id<ZQCustomDataPickerDelegate> delegate;




/****************** designated initializers ***********************/

/**
 *  Date picker
 *
 *  @param defaultDate      the date shows in picker when shows
 *  @param isDecorationView YES = is used as textfield / textView's inputView. NO = is an independent view
 *  @param hasToolbar       YES = toolbar on top. NO = no toolbar
 *  @param timeMode         YES = UIDatePickerModeTime. NO = UIDatePickerModeDate
 *
 *  @return a CustomDataPicker instance.
 */
- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate isDecorationView:(BOOL)isDecorationView hasToolbar:(BOOL)hasToolbar timeMode:(BOOL)timeMode;

/**
 *  Nullable date picker
 *
 *  @param year             year displayed in picker
 *  @param month            month displayed in picker
 *  @param day              day displayed in picker
 *  @param isDecorationView YES = is used as textfield / textView's inputView. NO = is an independent view
 *  @param hasToolbar       YES = toolbar on top. NO = no toolbar
 *
 *  @return a CustomDataPicker instance.
 */
- (instancetype)initNullableDatePickerWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day isDecorationView:(BOOL)isDecorationView hasToolbar:(BOOL)hasToolbar;

/**
 *  normal picker
 *
 *  @param array            source array containing content shown in picker. It only contains NSString object.
 *  @param initArray        initial selection shown in picker. It only contains NSString object.
 *  @param isDecorationView YES = is used as textfield / textView's inputView. NO = is an independent view
 *  @param hasToolbar       YES = toolbar on top. NO = no toolbar
 *
 *  @return a CustomDataPicker instance.
 */
- (instancetype)initPickerViewWithArray:(NSArray *)array andInitSelection:(NSArray *)initArray isDecorationView:(BOOL)isDecorationView hasToolbar:(BOOL)hasToolbar;







/****************** Picker ***********************/
/**
 *  @param array picker datasource array, must be of NSString type.
 */
- (instancetype)initPickerViewWithArray:(NSArray *)array;
/**
 *
 *  @param array     datasource array
 *  @param initArray initial selection array
 */
- (instancetype)initPickerViewWithArray:(NSArray *)array andInitSelection:(NSArray *)initArray;
/**
 *  @param array            datasource array
 *  @param initArray        initial selection array
 *  @param isDecorationView YES = is used as textfield / textView's inputView. NO = is an independent view
 */
- (instancetype)initPickerViewWithArray:(NSArray *)array andInitSelection:(NSArray *)initArray isDecorationView:(BOOL)isDecorationView;




/****************** Date/Time Picker ***********************/
/**
 *  Show a DatePicker from bottom with an initial date.
 */
- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate;
/**
 *  @param defaultDate initial date
 *  @param timeMode    YES = UIDatePickerModeTime. NO = UIDatePickerModeDate
 */
- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate timeMode:(BOOL)timeMode;
/**
 *  @param defaultDate      initial date.
 *  @param isDecorationView YES = is used as textfield / textView's inputView. NO = is an independent view
 *  @param timeMode         YES = UIDatePickerModeTime. NO = UIDatePickerModeDate
 */
- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate isDecorationView:(BOOL)isDecorationView timeMode:(BOOL)timeMode;




/****************** Nullable Date/Time Picker ***********************/
/**
 *  initial date: 2000/1/1
 */
- (instancetype)initNullableDatePicker;

/**
 *  user input initial date
 */
- (instancetype)initNullableDatePickerWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day;
/**
 *  user input initial date. Can have toolbar or not
 */
- (instancetype)initNullableDatePickerWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day hasToolbar:(BOOL)hasToolbar;



/****************** public methods ***********************/
/**
 *  Add pickerView into a view to display. Must call this method to show the picker
 *
 *  @param view the container view you want pickerview to add to.
 */
-(void)showInView:(UIView *)view;
/**
 *  Add pickerView to textfield / textView's inputView.
 *
 *  @param hasToolbar      YES = toolbar on top. NO = no toolbar
 */
- (void)showAsDecorationViewWithToolbar:(BOOL)hasToolbar;
/**
 *  remove custom picker view from its super view
 */
- (void)remove;





@end
