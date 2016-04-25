//
//  CustomDataPicker.m
//  CustomDataPicker
//
//  Created by Qian Zhou on 15/5/7.
//  Copyright (c) 2015年 Qian Zhou. All rights reserved.
//

#import "ZQCustomDataPicker.h"
#import "ZQNullableDatePicker.h"

@interface ZQCustomDataPicker () <ZQCustomDataPickerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>


//subViews
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) ZQNullableDatePicker *nullablePicker;
@property (nonatomic, strong) UIView *backgroundView;




//variables
@property (nonatomic) CGFloat pickerViewHeight;
@property (nonatomic) BOOL isLevelArray;
@property (nonatomic) BOOL hasToolBar;
@property (nonatomic) NSMutableArray *componentArray;
@property (nonatomic) BOOL isDecorationView;

@end

@implementation ZQCustomDataPicker


//static int height = 162;
static float AnimateDuration = 0.3f;
static float toolbarHeight = 40;



#pragma mark - init




- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate {
    return [self initDatePickerWithDate:defaultDate isDecorationView:NO hasToolbar:YES timeMode:NO];
}

- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate isDecorationView:(BOOL)isDecorationView timeMode:(BOOL)timeMode {
    return [self initDatePickerWithDate:defaultDate isDecorationView:isDecorationView hasToolbar:YES timeMode:timeMode];
}

- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate timeMode:(BOOL)timeMode {
    return [self initDatePickerWithDate:defaultDate isDecorationView:NO hasToolbar:YES timeMode:timeMode];
}



- (instancetype)initDatePickerWithDate:(NSDate *)defaultDate isDecorationView:(BOOL)isDecorationView hasToolbar:(BOOL)hasToolbar timeMode:(BOOL)timeMode {
    
    self=[super init];
    if (self) {
        self.type = ZQCustomDataPickerTypeDate;
        _hasToolBar = hasToolbar;
        [self setMainView:isDecorationView hasToolbar:hasToolbar];
        
        if (hasToolbar) {
            //is used to add into textfield / textView's inputView
            if (isDecorationView) {
                
                [self addSubview:_toolBar];
                [self setUpDatePickerWithDate:defaultDate hasToolbar:hasToolbar timeMode:timeMode];
                [self addSubview:_datePicker];
            } else {
                [self backgroundDismiss];
                [self.backgroundView addSubview:_toolBar];
                [self setUpDatePickerWithDate:defaultDate hasToolbar:hasToolbar timeMode:timeMode];
                [self.backgroundView addSubview:_datePicker];
                [self addSubview:_backgroundView];
            }
        } else {
            if (isDecorationView) {
                [self setUpDatePickerWithDate:defaultDate hasToolbar:hasToolbar timeMode:timeMode];
                [self addSubview:_datePicker];
            } else {
                [self backgroundDismiss];
                [self setUpDatePickerWithDate:defaultDate hasToolbar:hasToolbar timeMode:timeMode];
                [self.backgroundView addSubview:_datePicker];
                [self addSubview:_backgroundView];
            }
        }
        [self showAsDecorationView:isDecorationView hasToolbar:hasToolbar];
    
    }
    return self;
}

- (instancetype)initNullableDatePicker {
    return [self initNullableDatePickerWithYear:2000 Month:1 Day:1 isDecorationView:NO hasToolbar:YES];
}

- (instancetype)initNullableDatePickerWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day {
    return [self initNullableDatePickerWithYear:year Month:month Day:day isDecorationView:NO hasToolbar:YES];
}

- (instancetype)initNullableDatePickerWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day hasToolbar:(BOOL)hasToolbar {
    return [self initNullableDatePickerWithYear:year Month:month Day:day isDecorationView:NO hasToolbar:hasToolbar];
}

- (instancetype)initNullableDatePickerWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day isDecorationView:(BOOL)isDecorationView hasToolbar:(BOOL)hasToolbar {
    self = [super init];
    if (self) {
        self.type = ZQCustomDataPickerTypeNullable;
        _hasToolBar = hasToolbar;
        [self setMainView:isDecorationView hasToolbar:hasToolbar];
        
        if (hasToolbar) {
            if (isDecorationView) {
                [self addSubview:_toolBar];
                [self setUpNullableDatePickerWithYear:year Month:month Day:day hasToolbar:hasToolbar];
                [self addSubview:_nullablePicker];
            } else {
                [self backgroundDismiss];
                [self.backgroundView addSubview:_toolBar];
                [self setUpNullableDatePickerWithYear:year Month:month Day:day hasToolbar:hasToolbar];
                [self.backgroundView addSubview:_nullablePicker];
                [self addSubview:_backgroundView];
            }
        } else {
            if (isDecorationView) {
                [self setUpNullableDatePickerWithYear:year Month:month Day:day hasToolbar:hasToolbar];
                [self addSubview:_nullablePicker];
            } else {
                [self backgroundDismiss];
                [self setUpNullableDatePickerWithYear:year Month:month Day:day hasToolbar:hasToolbar];
                [self.backgroundView addSubview:_nullablePicker];
                [self addSubview:_backgroundView];
            }
        }
        [self showAsDecorationView:isDecorationView hasToolbar:hasToolbar];
    }
    return self;
}



- (instancetype)initPickerViewWithArray:(NSArray *)array {
    return [self initPickerViewWithArray:array andInitSelection:nil];
}

- (instancetype)initPickerViewWithArray:(NSArray *)array andInitSelection:(NSArray *)initArray {
    return [self initPickerViewWithArray:array andInitSelection:initArray isDecorationView:NO];
}

- (instancetype)initPickerViewWithArray:(NSArray *)array andInitSelection:(NSArray *)initArray isDecorationView:(BOOL)isDecorationView {
    return [self initPickerViewWithArray:array andInitSelection:initArray isDecorationView:isDecorationView hasToolbar:YES];
}

- (instancetype)initPickerViewWithArray:(NSArray *)array andInitSelection:(NSArray *)initArray isDecorationView:(BOOL)isDecorationView hasToolbar:(BOOL)hasToolbar {
    self=[super init];
    if (self) {
        self.type = ZQCustomDataPickerTypeNormal;
        _hasToolBar = hasToolbar;
        _dataArray = array;
        
        _selectionArray = initArray;
        if ([_dataArray[0] isKindOfClass:[NSArray class]]) {
            _isLevelArray = YES;
        } else {
            _isLevelArray = NO;
        }
        
        [self setMainView:isDecorationView hasToolbar:hasToolbar];
        if (hasToolbar) {
            //is used to add into textfield / textView's inputView
            if (isDecorationView) {
                _isDecorationView = isDecorationView;
                [self addSubview:_toolBar];
                [self setUpPickerView:hasToolbar initArray:initArray];
                [self addSubview:_pickerView];
            } else {
                [self backgroundDismiss];
                [self.backgroundView addSubview:_toolBar];
                [self setUpPickerView:hasToolbar initArray:initArray];
                [self.backgroundView addSubview:_pickerView];
                [self addSubview:_backgroundView];
            }
        } else {
            //is used to add into textfield / textView's inputView
            if (isDecorationView) {
                _isDecorationView = isDecorationView;
                [self setUpPickerView:hasToolbar initArray:initArray];
                [self addSubview:_pickerView];
            } else {
                [self backgroundDismiss];
                [self setUpPickerView:hasToolbar initArray:initArray];
                [self.backgroundView addSubview:_pickerView];
                [self addSubview:_backgroundView];
            }
        }
        
        
        [self showAsDecorationView:isDecorationView hasToolbar:hasToolbar];
    }
    return self;
}







#pragma mark - setup Main view

- (void)setMainView:(BOOL)isDecorationView hasToolbar:(BOOL)hasToolbar {
    CGFloat vfHeight;
    if (hasToolbar) {
        vfHeight = _pickerViewHeight + toolbarHeight;
    } else {
        vfHeight = _pickerViewHeight;
    }
    if (isDecorationView) {
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, vfHeight);
    } else {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    [self setUpBackgroundView];
    [self setUpToolbar];
}


//all subviews are added in background view.
- (void)setUpBackgroundView {
    _backgroundView = [[UIView alloc] init];
    _backgroundView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0);
    _backgroundView.backgroundColor = [UIColor whiteColor];
    
}

-(void)showInView:(UIView *)view{
    
    //    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
    
    [view addSubview:self];
}

- (void)showAsDecorationViewWithToolbar:(BOOL)hasToolbar {
    [self showAsDecorationView:YES hasToolbar:hasToolbar];
}
- (void)showAsDecorationView:(BOOL)isDecorationView hasToolbar:(BOOL)hasToolbar {
    CGFloat vfHeight;
    if (hasToolbar) {
        vfHeight = _pickerViewHeight + toolbarHeight;
    } else {
        vfHeight = _pickerViewHeight;
    }
    CGFloat vfOriginY = [UIScreen mainScreen].bounds.size.height - vfHeight;

    
    if (isDecorationView) {
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, vfHeight);
    } else {
        self.backgroundView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    
    if (isDecorationView) {
        [UIView animateWithDuration:AnimateDuration animations:^{
            [self setFrame:CGRectMake(0, vfOriginY, [UIScreen mainScreen].bounds.size.width, vfHeight)];
            self.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];

    } else {
        [UIView animateWithDuration:AnimateDuration animations:^{
            [self.backgroundView setFrame:CGRectMake(0, vfOriginY, [UIScreen mainScreen].bounds.size.width, vfHeight)];
            self.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

- (void)backgroundDismiss {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgtappedCancel)];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - setup toolbar

- (void)setUpToolbar {
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, toolbarHeight)];
    
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(docancel)];
    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Finish", @"Finish") style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];
    _toolBar.items=@[leftButton,centerSpace,rightButton];
    
}

#pragma mark - Actions

- (void)doneClick {
    [self tappedCancel];
    
    if (_datePicker) {
        _resultString=[NSString stringWithFormat:@"%@", [_datePicker.date descriptionWithLocale:[NSLocale currentLocale]]];
//        NSLog(@"_resultString: %@", _resultString);
        [self.resultArray addObject:_datePicker.date];
    } else if (_pickerView) {
        //user click done without any selection
        if (!_resultString) {
            if (_isLevelArray) {
                _resultString = @"";
                
                //has selection already
                if (_selectionArray) {
                    for (int i=0; i<_dataArray.count; i++) {
                        _resultString = [NSString stringWithFormat:@"%@ %@", _resultString, _selectionArray[i]];
                        [self.resultArray addObject:_selectionArray[i]];
                    }
                //no selection
                } else {
                    for (int i=0; i<_dataArray.count; i++) {
                        _resultString = [NSString stringWithFormat:@"%@ %@", _resultString, _dataArray[i][0]];
                        [self.resultArray addObject:_dataArray[i][0]];
                    }
                }
                
                
            } else {
                //has selection already
                if (_selectionArray) {
                    _resultString = _selectionArray[0];
                    [self.resultArray addObject:_selectionArray[0]];
                //no selection
                } else {
                    _resultString = _dataArray[0];
                    [self.resultArray addObject:_dataArray[0]];
                }
                
                
            }
        }
        NSLog(@"pickerView resultstring: %@", _resultString);
    } else if (_nullablePicker) {
        _resultArray = [[_nullablePicker selectedData] copy];
    }
    
    if ([self.delegate respondsToSelector:@selector(customPickerViewDoneBtnClicked:resultString:)]) {
        [self.delegate customPickerViewDoneBtnClicked:self resultString:_resultString];
    }
    
}

- (void)docancel {
    [self tappedCancel];
}

- (void)bgtappedCancel {
    [UIView animateWithDuration:AnimateDuration animations:^{
        [self.backgroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished && !self.isDecorationView) {
            [self removeFromSuperview];
        }
    }];
}

- (void)tappedCancel {
    if (self.isDecorationView && [self.delegate respondsToSelector:@selector(customPicerShouldDisappear)]) {
        [self.delegate customPicerShouldDisappear];
    } else {
        [UIView animateWithDuration:AnimateDuration animations:^{
            [self setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
            self.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished  && !self.isDecorationView) {
                [self removeFromSuperview];
            }
        }];
        
    }
    
    
}

- (void)remove {
    [self removeFromSuperview];
    
}
#pragma mark - setup Picker view

- (void)setUpPickerView:(BOOL)hasToolbar initArray:(NSArray *)array {
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    if (hasToolbar) {
        _pickerView.frame = CGRectMake(0, toolbarHeight, _pickerView.frame.size.width, _pickerView.frame.size.height);
    } else {
        _pickerView.frame = CGRectMake(0, 0, _pickerView.frame.size.width, _pickerView.frame.size.height);
    }
    
    _pickerViewHeight = _pickerView.frame.size.height;
    
    //set init selection
    if (array) {
        if ([array[0] isKindOfClass:[NSString class]]) {
            if ([_dataArray[0] isKindOfClass:[NSArray class]]) {
                
                for (int i=0; i<array.count; i++) {
                    for (int j=0; j<[_dataArray[i] count]; j++) {
                        if ([array[i] isEqualToString:_dataArray[i][j]]) {
                            [_pickerView selectRow:j inComponent:i animated:NO];
                        }
                        
                    }
                }
                
            } else {
                for (int i=0; i<_dataArray.count; i++) {
                    if ([array[0] isEqualToString:_dataArray[i]]) {
                        [_pickerView selectRow:i inComponent:0 animated:NO];
                    }
                }
                    
            }
            
        }
        
        if ([array[0] isKindOfClass:[NSNumber class]]) {
            if ([_dataArray[0] isKindOfClass:[NSArray class]]) {
                
                for (int i=0; i<array.count; i++) {
                    for (int j=0; j<[_dataArray[i] count]; j++) {
                        NSNumber *index = array[i];
                        NSNumber *data = _dataArray[i][j];
                        if (([index doubleValue] - [data doubleValue]) < 0.0001) {
                            [_pickerView selectRow:j inComponent:i animated:NO];
                        }
                        
                    }
                }
                
            } else {
                for (int i=0; i<_dataArray.count; i++) {
                    NSNumber *index = array[0];
                    NSNumber *data = _dataArray[i];
                    if (([index doubleValue] - [data doubleValue]) < 0.0001) {
                        [_pickerView selectRow:i inComponent:0 animated:NO];
                    }

                }
            }
            
        }
        
    }
    
    
    
}

- (void)setUpDatePickerWithDate:(NSDate *)date hasToolbar:(BOOL)hasToolbar timeMode:(BOOL)timeMode {
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    if (timeMode) {
        datePicker.datePickerMode = UIDatePickerModeTime;
    } else {
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    
    datePicker.backgroundColor = [UIColor whiteColor];
    
    if (date) {
        [datePicker setDate:date];
    }
    if (hasToolbar) {
        datePicker.frame = CGRectMake(0, toolbarHeight, datePicker.frame.size.width, datePicker.frame.size.height);
    } else {
        datePicker.frame = CGRectMake(0, 0, datePicker.frame.size.width, datePicker.frame.size.height);
    }
    
    
    //set minimumDate as 1900-1-1
    NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    dateComponent.year = 1900;
    dateComponent.month = 1;
    dateComponent.day = 1;
    NSDate *minimumDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponent];
    datePicker.minimumDate = minimumDate;
    datePicker.maximumDate = [NSDate date];
    dateComponent = nil;
    
    _datePicker = datePicker;
    _pickerViewHeight = _datePicker.frame.size.height;
    
}

- (void)setUpNullableDatePickerWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day hasToolbar:(BOOL)hasToolbar {
    CGFloat y = 0;
    if (hasToolbar) {
        y = toolbarHeight;
    }
    _nullablePicker = [[ZQNullableDatePicker alloc] initWithYear:year month:month day:day yPosition:y];
    _pickerViewHeight = _nullablePicker.frame.size.height;
}


#pragma mark - Picker View Date Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    //more than one component
    if (_isLevelArray) {
        return [_dataArray count];
    }
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //more than one component
    if (_isLevelArray) {
        return [_dataArray[component] count];
    }
    
    return [_dataArray count];
}


#pragma mark - Picker View delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //more than one component
    if (_isLevelArray) {
        return _dataArray[component][row];
    }
    
    return _dataArray[row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //more than one component
    [self.resultArray removeAllObjects];
    if (_isLevelArray) {
        _resultString = @"";
        if (![self.componentArray containsObject:@(component)]) {
            [self.componentArray addObject:@(component)];
        }
        for (int i=0; i<_dataArray.count; i++) {
            if ([self.componentArray containsObject:@(i)]) {
                NSInteger selectedItemIndex = [pickerView selectedRowInComponent:i];
                _resultString = [NSString stringWithFormat:@"%@ %@", _resultString, _dataArray[i][selectedItemIndex]];
                [self.resultArray addObject:_dataArray[i][selectedItemIndex]];
            
            //the component not been selected
            } else {
                if (_selectionArray) {
                    _resultString = [NSString stringWithFormat:@"%@ %@", _resultString, _selectionArray[i]];
                    [self.resultArray addObject:_selectionArray[i]];
                } else {
                    _resultString = [NSString stringWithFormat:@"%@ %@", _resultString, _dataArray[i][0]];
                    [self.resultArray addObject:_dataArray[i][0]];
                }
                
            }
        }
    } else {
        _resultString = _dataArray[row];
        [self.resultArray addObject:_dataArray[row]];
    }
    
    if (!self.hasToolBar && [self.delegate respondsToSelector:@selector(customPickerView:didSelectWithResultArray:ResultString:)]) {
        [self.delegate customPickerView:pickerView didSelectWithResultArray:self.resultArray ResultString:_resultString];
    }

    
}



- (void)resultStringChange:(NSString *)text {
    text = _resultString;
}

#pragma mark - Setter and Getter

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSArray alloc] init];
    }
    return _dataArray;
}

- (NSMutableArray *)componentArray {
    if (!_componentArray) {
        _componentArray = [[NSMutableArray alloc] init];
    }
    return _componentArray;
}

- (NSMutableArray *)resultArray {
    if (!_resultArray) {
        _resultArray = [[NSMutableArray alloc] init];
    }
    return _resultArray;
}


@end
