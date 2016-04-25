//
//  CXSignal.h
//  testKVO
//
//  Created by LeiQiao on 15/7/27.
//  Copyright (c) 2015年 LeiQiao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 信号类，用来对值进行操作，信号可以由KVO或者手动触发，
        信号呈多叉树结构，每个信号可以对值进行操作，并将处理之后的值向下级信号传递
 @since 1.0.0
 */
@interface CXSignal : NSObject

/**
 @author LeiQiao on 05/08/15
 @brief 创建根信号，所有信号类（包括子类）不允许使用单独的alloc来创建，
 根信号由该方法提供，后继信号由子类的扩展方法来生成
 @return 根信号
 @since 1.0.0
 */
+(instancetype) createRootSignal;

/**
 @author LeiQiao on 05/08/15
 @brief 搜索后继信号中与给定信号相似的信号
 @param signal      搜索的信号
 @return 返回与给定信号相似的信号
 @since 1.0.0
 */
-(CXSignal*) searchSignal:(CXSignal*)signal;

/**
 @author LeiQiao on 05/08/15
 @brief 添加信号
 @param signal      要添加的后继信号
 @return 添加的信号，可以用来做级联
 @since 1.0.0
 */
-(CXSignal*) addSignal:(CXSignal*)signal;

/**
 @author LeiQiao on 05/08/15
 @brief 删除该信号，一并删除后继的单独信号
 @since 1.0.0
 */
-(void) removeSignal;

/**
 @author LeiQiao on 05/08/15
 @brief 克隆一个相似的信号
 @return 新信号
 @since 1.0.0
 */
-(CXSignal*) clone;

/**
 @author LeiQiao on 05/08/15
 @brief 判断该信号是否与给定的信号相似，子类必须继承该方法来判断是否相似
 @return 是否与给定的信号相似
 @since 1.0.0
 */
-(BOOL) isEqual:(CXSignal*)otherSignal;

/*!
 *  @author LeiQiao, 15-12-04
 *  @brief 是否跟另一个信号完全相同
 *  @return 是否跟另一个信号完全相同
 *  @since 1.0.0
 */
-(BOOL) hasSameDNA:(CXSignal*)otherSignal;

/**
 @author LeiQiao on 05/08/15
 @brief 触发信号
 @param value       触发信号的值
 @since 1.0.0
 */
-(void) executeSignal:(id)value;

@end
