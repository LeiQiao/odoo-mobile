//
//  CXPickerTextField.m
//

#import "CXPickerTextField.h"

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 选择器样式的TextField
 */
@implementation CXPickerTextField {
    NSString* _oldValue;    /*!< 用来保存取消时恢复的值 */
}

#pragma mark
#pragma mark helper

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 初始化控件
 */
-(void) setup
{
    /*---------- UIPickerView ----------*/
    _picker = [[UIPickerView alloc] init];
    _picker.dataSource = (id<UIPickerViewDataSource>)self;
    _picker.delegate = (id<UIPickerViewDelegate>)self;
    
    /*---------- 确定／取消的toolbar ----------*/
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    _toolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(cancelButtonDidClicked:)],
                       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                     target:nil
                                                                     action:nil],
                       [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                        style:UIBarButtonItemStyleDone
                                                       target:self
                                                       action:@selector(okButtonDidClicked:)]];
    
    /*---------- 设置当前TextField的输入框和输入辅助框 ----------*/
    self.enablePicker = YES;
}

#pragma mark
#pragma mark init & dealloc

-(instancetype) initWithFrame:(CGRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        [self setup];
    }
    return self;
}

-(instancetype) initWithCoder:(NSCoder*)aDecoder
{
    if( self = [super initWithCoder:aDecoder] )
    {
        [self setup];
    }
    return self;
}

#pragma mark
#pragma mark override

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 设置选择器内容
 *  @param newDataArray 选择器内容，NSString的数组
 */
-(void) setDataArray:(NSArray*)newDataArray
{
    _dataArray = newDataArray;
    
    // 重新加载Picker
    [self.picker reloadAllComponents];
}

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 设置是否允许选择器
 *  @param newEnablePicker 是否允许选择器
 */
-(void) setEnablePicker:(BOOL)newEnablePicker
{
    if( _enablePicker == newEnablePicker ) return;
    
    _enablePicker = newEnablePicker;
    if( _enablePicker )
    {
        self.inputView = _picker;
        self.inputAccessoryView = _toolbar;
    }
    else
    {
        self.inputView = nil;
        self.inputAccessoryView = nil;
    }
}


/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 变成第一响应者
 *  @return 是否已变成第一响应者
 */
-(BOOL) becomeFirstResponder
{
    BOOL bRet = [super becomeFirstResponder];
    
    if( bRet )
    {// 选中当前已选择的项
        if( self.text.length > 0 )
        {
            for( NSUInteger i=0; i<self.dataArray.count; i++ )
            {
                NSString* value = [self.dataArray objectAtIndex:i];
                if( [value isEqualToString:self.text] )
                {
                    [self.picker selectRow:i inComponent:0 animated:NO];
                }
            }
        }
        else
        {
            [self pickerView:self.picker didSelectRow:0 inComponent:0];
//            [self.picker selectRow:0 inComponent:0 animated:NO];
        }
    }
    
    return bRet;
}

#pragma mark
#pragma mark button events

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 确定按钮按下事件
 *  @param sender 确定按钮
 */
-(void) okButtonDidClicked:(id)sender
{
    // 清除旧值
    _oldValue = nil;
    [self resignFirstResponder];
}

/*!
 *  @author LeiQiao, 16/04/24
 *  @brief 取消按钮按下事件
 *  @param sender 取消按钮
 */
-(void) cancelButtonDidClicked:(id)sender
{
    // 恢复旧值
    if( _oldValue )
    {
        self.text = _oldValue;
    }
    [self resignFirstResponder];
}

#pragma mark
#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataArray.count;
}

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.dataArray[row];
}

-(void) pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // 如果是第一次选择，则设置旧值
    if( !_oldValue ) _oldValue = self.text;
    self.text = self.dataArray[row];
}

@end
