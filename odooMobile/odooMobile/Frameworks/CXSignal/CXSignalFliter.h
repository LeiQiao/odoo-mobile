//
//  CXSignalFliter.h
//  testKVO
//
//  Created by LeiQiao on 15/8/4.
//  Copyright (c) 2015年 LeiQiao. All rights reserved.
//

#import "CXSignal.h"

/**
 @brief 信号筛选类，值从上层信号中传来，通过给定的block来判断是否继续向下传递
 @since 1.0.0
 */
@interface CXSignal(Fliter)

/**
 @author LeiQiao on 05/08/15
 @brief 创建信号并添加到信号树中
 @param transformer      信号筛选函数
 @return 创建的新信号，可以用来做级联
 @since 1.0.0
 */
-(CXSignal*) addSignalWithFliter:(BOOL(^)(id value))fliter;

@end
