//
//  CXSignalTransformer.m
//  testKVO
//
//  Created by LeiQiao on 15/8/4.
//  Copyright (c) 2015年 LeiQiao. All rights reserved.
//

#import "CXSignalTransformer.h"

typedef id (^CXSIGNAL_REACTION_TRANSFORMER)(id);

@interface CXSignalTransformer : CXSignal

@end

@implementation CXSignalTransformer {
    CXSIGNAL_REACTION_TRANSFORMER _transformer;
}

#pragma mark
#pragma mark override

-(CXSignal*) clone
{
    CXSignalTransformer* signal = [[CXSignalTransformer alloc] init];
    signal->_transformer = _transformer;
    
    return signal;
}

-(void) executeSignal:(id)value
{
    // 调用转换函数来转换给定的值
    if( _transformer )
    {
        value = _transformer(value);
    }
    
    // 将新值向下传递
    [super executeSignal:value];
}

-(BOOL) isEqual:(CXSignal*)otherSignal
{
    if( [super isEqual:otherSignal] ) return YES;
    if( ![otherSignal isKindOfClass:[CXSignalTransformer class]] ) return NO;
    
    CXSignalTransformer* otherTransformerSignal = (CXSignalTransformer*)otherSignal;
    if( otherTransformerSignal->_transformer == _transformer )
    {
        return YES;
    }
    return NO;
}

#pragma mark
#pragma mark init & dealloc

-(id) initWithTransformer:(id(^)(id value))transformer
{
    if( self = [super init] )
    {
        _transformer = transformer;
    }
    return self;
}

@end

@implementation CXSignal(Transformer)

-(CXSignal*) addSignalWithTransformer:(id(^)(id value))transformer
{
    // 创建信号转换信号
    CXSignalTransformer* signal = [[CXSignalTransformer alloc] initWithTransformer:transformer];
    // 添加到信号树中，并返回新的信号
    return [self addSignal:signal];
}

@end
