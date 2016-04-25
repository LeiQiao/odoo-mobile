//
//  NullableDatePicker.h
//  NullableDatePicker
//
//  Created by He Zhongjie on 15/6/2.
//  Copyright (c) 2015年 He Zhongjie. All rights reserved.
//

#import "ZQNullableDatePicker.h"

#define MAXROW 8192

@interface ZQNullableDatePicker ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property(nonatomic, strong)UIPickerView *pickerView;
@property(nonatomic, strong)NSMutableArray *yearPickerData;
@property(nonatomic, strong)NSMutableArray *monthPickerData;
@property(nonatomic, strong)NSMutableArray *dayPickerData;
@property(nonatomic, strong)NSDateComponents *todayComponents;
@end

@implementation ZQNullableDatePicker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [_yearPickerData count];
    } else {
        return MAXROW;
    }
}

-(instancetype)init {
    return [self initWithYear:2000 month:1 day:1 yPosition:300];
}

-(instancetype)initWithyPosition:(CGFloat)y{
    return [self initWithYear:2000 month:1 day:1 yPosition:y];
}

-(instancetype)initWithYear:(NSInteger)defaultYear month:(NSInteger)defaultMonth day:(NSInteger)defaultDay yPosition:(CGFloat)y{
    self=[super init];
    if (self) {
        UIPickerView *pickerView = [[UIPickerView alloc]init];
        _pickerView = pickerView;
        pickerView.delegate = self;
        pickerView.dataSource = self;
        [self addSubview:pickerView];
        
        CGFloat x = 0;
        CGFloat w = pickerView.frame.size.width;
        CGFloat h = pickerView.frame.size.height;
        self.frame = CGRectMake(x, y, w, h);
        
        // 初始化pickerData
        NSDate *currentDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        _todayComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
        _yearPickerData = [[NSMutableArray alloc] init];
        for (int i=1900; i<= [_todayComponents year]; i++) {
            [_yearPickerData addObject:[NSNumber numberWithInt:i]];
        }
        _monthPickerData = [[NSMutableArray alloc] init];
        for (int i=0; i<=12; i++) {
            [_monthPickerData addObject:[NSNumber numberWithInt:i]];
        }
        _dayPickerData = [[NSMutableArray alloc] init];
        for (int i=0; i<=31; i++) {
            [_dayPickerData addObject:[NSNumber numberWithInt:i]];
        }
        [pickerView selectRow:[_yearPickerData indexOfObject:[NSNumber numberWithInteger:defaultYear]] inComponent:0 animated:NO];
        [pickerView selectRow:[_monthPickerData indexOfObject:[NSNumber numberWithInteger:defaultMonth]]+MAXROW/2/13*13 inComponent:1 animated:NO];
        [pickerView selectRow:[_dayPickerData indexOfObject:[NSNumber numberWithInteger:defaultDay]]+MAXROW/2/32*32 inComponent:2 animated:NO];
    }
    return self;
}


//
-(NSArray *)selectedData{
    return [NSArray arrayWithObjects:
            [_yearPickerData objectAtIndex:[_pickerView selectedRowInComponent:0]],
            [_monthPickerData objectAtIndex:[_pickerView selectedRowInComponent:1]%13],
            [_dayPickerData objectAtIndex:[_pickerView selectedRowInComponent:2]%32], nil];
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@年", [_yearPickerData objectAtIndex:row]]];
    } else if (component == 1) {
        NSInteger actualRow = row % 13;
        if (actualRow == 0) {
            return [[NSAttributedString alloc] initWithString:@"不记得"];
        } else if ([[self selectedData][0] integerValue] >= [_todayComponents year] && actualRow > [_todayComponents month]){
            NSString *month = [NSString stringWithFormat:@"%@月", [_monthPickerData objectAtIndex:actualRow]];
            return [[NSAttributedString alloc] initWithString:month attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        } else {
            return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@月", [_monthPickerData objectAtIndex:actualRow]]];
        }
    } else {
        NSInteger actualRow = row % 32;
        NSArray *selectedData = [self selectedData];
        if (actualRow == 0) {
            return [[NSAttributedString alloc] initWithString:@"不记得"];
        } else if (actualRow > [self theDays] ||
                   [_pickerView selectedRowInComponent:1]%13 == 0 ||
                   ([selectedData[0] integerValue] >= [_todayComponents year] && [selectedData[1] integerValue] >= [_todayComponents month] && actualRow > [_todayComponents day])) {
            NSString *days = [NSString stringWithFormat:@"%@日", [_dayPickerData objectAtIndex:actualRow]];
            return [[NSAttributedString alloc]initWithString:days attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        } else {
            return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@日", [_dayPickerData objectAtIndex:actualRow]]];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView reloadComponent:2];
    NSInteger days = [self theDays];
    NSInteger c1 = [pickerView selectedRowInComponent:1];
    NSInteger c2 = [pickerView selectedRowInComponent:2];
    NSArray *selectData = [self selectedData];
    
    if ([selectData[0] integerValue] == [_todayComponents year]
        && ([selectData[1] integerValue] > [_todayComponents month]
             || ([selectData[1] integerValue] == [_todayComponents month]
                 && [selectData[2] integerValue] >= [_todayComponents day]))) {
        [pickerView selectRow:c1/13*13+[_todayComponents month] inComponent:1 animated:YES];
        if ([selectData[2] integerValue] > [_todayComponents day]) {
            [pickerView selectRow:c2/32*32+[_todayComponents day] inComponent:2 animated:YES];
        }
    } else if (c1%13 == 0) {
        [pickerView selectRow:c2-c2%32 inComponent:2 animated:YES];
    } else if (c2 % 32 > days){
        [pickerView selectRow:c2/32*32+days inComponent:2 animated:YES];
    }
}

-(NSInteger)theDaysInYear:(NSInteger)year inMonth:(NSInteger)month {
    if (month == 0) {
        return 0;
    }
    if (month == 1||month == 3||month == 5||month == 7||month == 8||month == 10||month == 12) {
        return 31;
    }
    if (month == 4||month == 6||month == 9||month == 11) {
        return 30;
    }
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
    }
    return 28;
}

-(NSInteger)theDays
{
    NSInteger selectedYear = [_pickerView selectedRowInComponent:0];
    NSInteger selectedMonth = [_pickerView selectedRowInComponent:1]%13;
    return [self theDaysInYear:selectedYear inMonth:selectedMonth];
}


@end