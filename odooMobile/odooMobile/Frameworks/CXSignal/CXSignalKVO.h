//
//  CXSignalKVO.h
//  testKVO
//
//  Created by LeiQiao on 15/7/27.
//  Copyright (c) 2015年 LeiQiao. All rights reserved.
//

#import "CXSignal.h"

/**
 @brief KVO信号类，由keyPath触发信号（注意：target强引用）
 @since 1.0.0
 */
@interface CXSignal(KVO)

/**
 @author LeiQiao on 05/08/15
 @brief 创建信号并添加到信号树中
 @param target      监听的对象
 @param keyPath     被监听的keyPath
 @return 创建的新信号，可以用来做级联
 @since 1.0.0
 */
-(CXSignal*) addSignalWithTarget:(id)target andKeyPath:(NSString*)keyPath;

@end
