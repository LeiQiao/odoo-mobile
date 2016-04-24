//
//  AddressPicker.h
//  AddressPicker
//
//  Created by Qian Zhou on 15/10/12.
//  Copyright © 2015年 Qian Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZQAddressPicker : UIView
@property (strong, nonatomic) NSString *resultProvince;
@property (strong, nonatomic) NSString *resultCity;
@property (strong, nonatomic) NSString *resultRegion;

- (instancetype)initWithYposition:(CGFloat)y initArray:(NSArray *)initArray;
@end
