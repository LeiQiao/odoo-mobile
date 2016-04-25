//
//  CXPickerTextField.h
//

#import <UIKit/UIKit.h>

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 选择器样式的TextField
 */
@interface CXPickerTextField : UITextField

@property(nonatomic, strong, readonly) UIToolbar* toolbar;      /*!< 选择器的确定关闭按钮 */
@property(nonatomic, strong, readonly) UIPickerView* picker;    /*!< 选择器 */
@property(nonatomic, strong) NSArray* dataArray;                /*!< 选择器的值，NSString数组 */
@property(nonatomic) BOOL enablePicker;                         /*!< 允许选择器：YES选择器，NO输入框 */

@end
