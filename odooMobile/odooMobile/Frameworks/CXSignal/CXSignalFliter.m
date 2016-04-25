//
//  CXSignalFliter.m
//  testKVO
//
//  Created by LeiQiao on 15/8/4.
//  Copyright (c) 2015年 LeiQiao. All rights reserved.
//

#import "CXSignalFliter.h"

typedef BOOL (^CXSIGNAL_REACTION_FLITER)(id);

@interface CXSignalFliter : CXSignal

@end

@implementation CXSignalFliter {
    CXSIGNAL_REACTION_FLITER _fliter;
}

#pragma mark
#pragma mark override

-(CXSignal*) clone
{
    CXSignalFliter* signal = [[CXSignalFliter alloc] init];
    signal->_fliter = _fliter;
    
    return signal;
}

-(void) executeSignal:(id)value
{
    // 调用筛选函数来判断是否继续向下传递
    if( _fliter )
    {
        if( !_fliter(value) ) return;
    }
    
    // 筛选通过向下传递
    [super executeSignal:value];
}

-(BOOL) isEqual:(CXSignal*)otherSignal
{
    if( [super isEqual:otherSignal] ) return YES;
    if( ![otherSignal isKindOfClass:[CXSignalFliter class]] ) return NO;
    
    CXSignalFliter* otherFliterSignal = (CXSignalFliter*)otherSignal;
    if( otherFliterSignal->_fliter == _fliter )
    {
        return YES;
    }
    return NO;
}

#pragma mark
#pragma mark init & dealloc

-(id) initWithFliter:(BOOL(^)(id value))fliter
{
    if( self = [super init] )
    {
        _fliter = fliter;
    }
    return self;
}

@end

@implementation CXSignal(Fliter)

-(CXSignal*) addSignalWithFliter:(BOOL(^)(id value))fliter
{
    // 创建信号转换信号
    CXSignalFliter* signal = [[CXSignalFliter alloc] initWithFliter:fliter];
    // 添加到信号树中，并返回新的信号
    return [self addSignal:signal];
}

@end





