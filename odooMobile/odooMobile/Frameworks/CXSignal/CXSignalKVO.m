//
//  CXSignalKVO.m
//  testKVO
//
//  Created by LeiQiao on 15/7/27.
//  Copyright (c) 2015年 LeiQiao. All rights reserved.
//

#import "CXSignalKVO.h"
#import <UIKit/UIKit.h>

@interface CXSignalKVO : CXSignal

@end

@implementation CXSignalKVO {
    id _target;                     // 要监听的对象
    NSString* _keyPath;             // 要监听的KeyPath
    BOOL _signalFromPrevSignal;     // 信号是否是从上层信号树中触发,如果是则忽略KVO和赋值事件
}

#pragma mark
#pragma mark helper

/**
 @author LeiQiao on 05/08/15
 @brief 添加KVO观察者
 @since 1.0.0
 */
-(void) addObserver
{
    if( _target && (_keyPath.length > 0) )
    {
        // 添加KVO监听
        [_target addObserver:self
                  forKeyPath:_keyPath
                     options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                     context:nil];
        
        // 如果是UIControl控件在操作中不会触发KVO监听
        if( [_target isKindOfClass:[UIControl class]] )
        {
            [((UIControl*)_target) addTarget:self
                                      action:@selector(controlValueDidChanged:)
                            forControlEvents:UIControlEventValueChanged|UIControlEventEditingChanged];
        }
    }
}

/**
 @author LeiQiao on 05/08/15
 @brief 删除KVO观察者
 @since 1.0.0
 */
-(void) removeObserver
{
    // 删除KVO监听
    [_target removeObserver:self forKeyPath:_keyPath];
    
    // 删除UIControl的事件
    if( [_target isKindOfClass:[UIControl class]] )
    {
        [((UIControl*)_target) removeTarget:self
                                     action:@selector(controlValueDidChanged:)
                           forControlEvents:UIControlEventValueChanged|UIControlEventEditingChanged];
    }
}

#pragma mark
#pragma mark override

-(void) removeSignal
{
    // 删除KVO监听
    [self removeObserver];
    [super removeSignal];
}

-(CXSignal*) clone
{
    CXSignalKVO* signal = [[CXSignalKVO alloc] init];
    signal->_target = _target;
    signal->_keyPath = _keyPath;
    // 添加KVO监听
    [signal addObserver];
    
    return signal;
}

-(void) executeSignal:(id)value
{
    // 如果值跟现有的值一样则忽略
    id orgValue = [_target valueForKeyPath:_keyPath];
    if( [orgValue isEqual:value] )
    {
        return;
    }
    
    _signalFromPrevSignal = YES;
    
    // 赋值
    [_target setValue:value forKeyPath:_keyPath];
    value = [_target valueForKeyPath:_keyPath];
    
    // 触发下层信号
    [super executeSignal:value];
    
    _signalFromPrevSignal = NO;
}

-(BOOL) isEqual:(CXSignal*)otherSignal
{
    if( [super isEqual:otherSignal] ) return YES;
    if( ![otherSignal isKindOfClass:[CXSignalKVO class]] ) return NO;
    
    CXSignalKVO* otherKVOSignal = (CXSignalKVO*)otherSignal;
    if( (otherKVOSignal->_target == _target) &&
       [otherKVOSignal->_keyPath isEqualToString:_keyPath] )
    {
        return YES;
    }
    return NO;
}

#pragma mark
#pragma mark observer

-(void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    id new = [change objectForKey:@"new"];
    // 如果新值为空则跳过
    if( !new ) return;
    
    // 如果信号从上层信号中触发得来则忽略，否则会引起死循环
    if( _signalFromPrevSignal ) return;
    
    // 触发下层信号
    [super executeSignal:new];
}

-(void) controlValueDidChanged:(UIControl*)control
{
    // 如果信号从上层信号中触发得来则忽略，否则会引起死循环
    if( _signalFromPrevSignal ) return;
    
    // 触发下层信号
    [super executeSignal:[control valueForKeyPath:_keyPath]];
}

#pragma mark
#pragma mark init & dealloc

-(id) initWithTarget:(id)target andKeyPath:(NSString*)keyPath
{
    if( self = [super init] )
    {
        _target = target;
        _keyPath = keyPath;
        
        // 添加KVO监听
        [self addObserver];
    }
    return self;
}

@end

@implementation CXSignal(KVO)

-(CXSignal*) addSignalWithTarget:(id)target andKeyPath:(NSString*)keyPath
{
    // 创建KVO信号
    CXSignalKVO* signal = [[CXSignalKVO alloc] initWithTarget:target andKeyPath:keyPath];
    // 添加到信号树中，并返回新的信号
    return [self addSignal:signal];
}

@end
