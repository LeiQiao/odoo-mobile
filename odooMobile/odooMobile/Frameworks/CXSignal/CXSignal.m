//
//  CXSignal.m
//  testKVO
//
//  Created by LeiQiao on 15/7/27.
//  Copyright (c) 2015年 LeiQiao. All rights reserved.
//

#import "CXSignal.h"

@implementation CXSignal {
    __weak CXSignal* _rootSignal;       // 根信号
    
    NSMutableArray* _prevSignals;       // 上层信号
    NSMutableArray* _nextSignals;       // 下层信号
}

#pragma mark
#pragma mark member functions

-(CXSignal*) searchSignal:(CXSignal*)signal
{
    // 循环搜索下层信号
    for( CXSignal* childSignal in _nextSignals )
    {
        // 判断是否是相似信号
        if( [signal isEqual:childSignal] ) return childSignal;
        else
        {
            CXSignal* sameSignal = [childSignal searchSignal:signal];
            if( sameSignal ) return sameSignal;
        }
    }
    return nil;
}

-(CXSignal*) addSignal:(CXSignal*)signal
{
    // 插入信号树
    signal->_rootSignal = _rootSignal;
    [signal->_prevSignals addObject:self];
    [_nextSignals addObject:signal];
    return signal;
}

-(void) removeSignal
{
    // 从上层信号中删除自己
    for( CXSignal* signal in _prevSignals )
    {
        [signal->_nextSignals removeObject:self];
    }
    // 从下层信号中删除自己
    for( CXSignal* signal in _nextSignals )
    {
        [signal->_prevSignals removeObject:self];
        // 如果下层信号只有本信号作为上层信号，则删除下层信号分支
        if( signal->_prevSignals.count == 0 )
        {
            [signal removeSignal];
        }
    }
    [_nextSignals removeAllObjects];
    _rootSignal = nil;
}

-(CXSignal*) clone
{
    return nil;
}

-(void) executeSignal:(id)value
{
    // 触发信号，向下层信号传递
    for( CXSignal* signal in _nextSignals )
    {
        [signal executeSignal:value];
    }
}

-(BOOL) isEqual:(CXSignal*)otherSignal
{
    if( self == otherSignal ) return YES;
    return NO;
}

-(BOOL) hasSameDNA:(CXSignal*)otherSignal
{
    if( ![self isEqual:otherSignal] ) return NO;
    if( _nextSignals.count != otherSignal->_nextSignals.count ) return NO;
    for( int i=0; i<_nextSignals.count; i++ )
    {
        CXSignal* selfNextSignal = [_nextSignals objectAtIndex:i];
        CXSignal* otherNextSignal = [otherSignal->_nextSignals objectAtIndex:i];
        if( ![selfNextSignal hasSameDNA:otherNextSignal] ) return NO;
    }
    return YES;
}

#pragma mark
#pragma mark init & dealloc

+(instancetype) createRootSignal
{
    CXSignal* signal = [[CXSignal alloc] init];
    signal->_rootSignal = signal;
    return signal;
}

-(id) init
{
    if( self = [super init] )
    {
        _prevSignals = [[NSMutableArray alloc] init];
        _nextSignals = [[NSMutableArray alloc] init];
//        NSLog(@"alloc me %@", self);
    }
    return self;
}

-(void) dealloc
{
//    NSLog(@"dealloc me %@", self);
}

@end
