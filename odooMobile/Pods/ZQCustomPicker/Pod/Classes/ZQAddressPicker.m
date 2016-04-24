//
//  AddressPicker.m
//  AddressPicker
//
//  Created by Qian Zhou on 15/10/12.
//  Copyright © 2015年 Qian Zhou. All rights reserved.
//

#import "ZQAddressPicker.h"


@interface ZQAddressPicker () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *addresses;
@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSMutableArray *cities;
@property (nonatomic, strong) NSArray *regions;

@property (nonatomic) NSInteger selectedProvinceIndex;
@property (nonatomic) NSInteger selectedCityIndex;
@property (nonatomic) NSInteger selectedRegionIndex;

@property (nonatomic, strong) NSString *selectedProvince;
@property (nonatomic, strong) NSString *selectedCity;
@property (nonatomic, strong) NSString *selectedRegion;
@end

@implementation ZQAddressPicker



- (instancetype)initWithYposition:(CGFloat)y initArray:(NSArray *)initArray {
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"address" ofType:@"plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
        _addresses = dic[@"address"];
        NSMutableArray *provinces = [NSMutableArray array];
        for (int i=0; i<_addresses.count; i++) {
            NSDictionary *tempDic = _addresses[i];
            [provinces addObject:tempDic[@"name"]];
        }
        _provinces = provinces;
        
        _cities = [NSMutableArray array];
        _regions = [NSArray array];
        if (initArray.count == 0) {
            //默认第一个省的城市
            self.selectedProvinceIndex = 0;
            [self citiesOfProvinceIndex:0];
            
            //默认第一个省的第一个城市的区
            self.selectedCityIndex = 0;
            [self regionsOfCity:0 inProvince:0];
        } else {
            self.selectedProvinceIndex = [self indexOfSelection:initArray[0] array:_provinces];
            [self citiesOfProvinceIndex:self.selectedProvinceIndex];
            self.selectedCityIndex = [self indexOfSelection:initArray[1] array:_cities];
            [self regionsOfCity:self.selectedCityIndex inProvince:self.selectedProvinceIndex];
            self.selectedRegionIndex = [self indexOfSelection:initArray[2] array:_regions];
        }
        
        
        
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        CGRect oldFrame = pickerView.frame;
        pickerView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, [UIScreen mainScreen].bounds.size.width, oldFrame.size.height);
        _pickerView = pickerView;
        
        
        self.frame = CGRectMake(0, y, pickerView.frame.size.width, pickerView.frame.size.height);
        [self addSubview:pickerView];
        
        if (initArray.count > 0) {
            [_pickerView selectRow:self.selectedProvinceIndex inComponent:0 animated:NO];
            [_pickerView selectRow:self.selectedCityIndex inComponent:1 animated:NO];
            [_pickerView selectRow:self.selectedRegionIndex inComponent:2 animated:NO];
        }
        
        self.resultProvince = self.provinces[self.selectedProvinceIndex];
        self.resultCity = self.cities[self.selectedCityIndex];
        self.resultRegion = self.regions[self.selectedRegionIndex];
    }
    
    
    return self;
}

- (NSInteger)indexOfSelection:(NSString *)selection array:(NSArray *)array {
    for (int i=0; i<array.count; i++) {
        if ([array[i] isEqualToString:selection]) {
            return i;
        }
    }
    return -1;
}

#pragma PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [self.provinces count];
        case 1:
            return [self.cities count];
        case 2:
            return [self.regions count];
        default:
            return 0;
    }
}


#pragma PickerView Delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        tView.textAlignment = NSTextAlignmentCenter;
    }
    // Fill the label text here
    NSString *title = nil;
    switch (component) {
        case 0:
            title = self.provinces[row];
            break;
        case 1:
            title = self.cities[row];
            break;
        case 2:
            if (self.regions.count == 0) {
                return nil;
            }
            title = self.regions[row];
            break;
        default:
            break;
    }
    CGFloat componentWidth = [pickerView rowSizeForComponent:component].width;
    NSInteger fontSize = 14;
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]}];
    while (size.width > componentWidth) {
        --fontSize;
        size = [title sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]}];
    }
    tView.font = [UIFont systemFontOfSize:fontSize];
    tView.text = title;
    return tView;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
        {
            [self citiesOfProvinceIndex:row];
            [self regionsOfCity:0 inProvince:row];
            self.selectedProvinceIndex = row;
            self.selectedCityIndex = 0;
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            self.selectedRegionIndex = 0;
            [pickerView selectRow:0 inComponent:2 animated:YES];
            
            break;
        }
        case 1:
        {
            [self regionsOfCity:row inProvince:self.selectedProvinceIndex];
            self.selectedCityIndex = row;
            self.selectedRegionIndex = 0;
            [pickerView selectRow:0 inComponent:2 animated:YES];
            [pickerView reloadComponent:2];
            break;
        }
        case 2:
        {
            self.selectedRegionIndex = row;
            break;
        }
        default:
            break;
    }
    self.resultProvince = self.provinces[self.selectedProvinceIndex];
    self.resultCity = self.cities[self.selectedCityIndex];
    if (self.regions.count == 0) {
        self.resultRegion = nil;
    } else {
        self.resultRegion = self.regions[self.selectedRegionIndex];
    }
    
}

- (NSArray *)citiesOfProvinceIndex:(NSInteger)row {
    [self.cities removeAllObjects];
    NSArray *subCity = [_addresses[row] objectForKey:@"sub"];
    for (int i=0; i<subCity.count; i++) {
        [self.cities addObject:[subCity[i] objectForKey:@"name"]];
    }
    return self.cities;
}

- (NSArray *)regionsOfCity:(NSInteger)cityIndex inProvince:(NSInteger)provinceIndex {
    self.regions = nil;
    NSArray *cities = [_addresses[provinceIndex] objectForKey:@"sub"];
    self.regions = [cities[cityIndex] objectForKey:@"sub"];
    return self.regions;
}
@end
