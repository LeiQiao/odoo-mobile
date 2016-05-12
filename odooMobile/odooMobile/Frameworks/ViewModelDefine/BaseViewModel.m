//
//  BaseViewModel.m
//  SUPAY
//
//  Created by LeiQiao on 15/7/16.
//  Copyright (c) 2015年 chinapnr.com. All rights reserved.
//

#import "BaseViewModel.h"
#import "CXSignal.h"
#import "CXSignalKVO.h"
#import "CXSignalTransformer.h"
#import <objc/runtime.h>

@interface ViewControllerAssign : NSObject

@property(nonatomic, weak) UIViewController* viewController;

@end

@implementation ViewControllerAssign

@synthesize viewController;

@end

@implementation BaseViewModel {
    NSMutableArray* _viewControllerStack;
    NSMutableArray* _KVOSignals;
}

@synthesize viewControllerStack = _viewControllerStack;

-(UIViewController*) topViewController
{
    if( self.viewControllerStack && (self.viewControllerStack.count > 0) )
    {
        return ((ViewControllerAssign*)[_viewControllerStack objectAtIndex:0]).viewController;
    }
    return nil;
}

-(void) pushViewController:(UIViewController*)viewController
{
    if( !self.viewControllerStack )
    {
        self.viewControllerStack = [NSMutableArray array];
    }
    ViewControllerAssign* va = [[ViewControllerAssign alloc] init];
    va.viewController = viewController;
    [self.viewControllerStack insertObject:va atIndex:0];
}

-(void) popViewController
{
    if( self.viewControllerStack && (self.viewControllerStack.count > 0) )
    {
        [self.viewControllerStack removeObjectAtIndex:0];
    }
}

NSMutableArray* gExistViewModels = nil;

+(id) registNewViewModel:(Class)newViewModelClass viewController:(UIViewController*)viewController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gExistViewModels = [NSMutableArray array];
    });
    
    BaseViewModel* viewModel = [BaseViewModel getViewModel:newViewModelClass];
    if( !viewModel )
    {
        viewModel = [[newViewModelClass alloc] init];
        [gExistViewModels addObject:viewModel];
    }
    [viewModel pushViewController:viewController];
    return viewModel;
}

+(id) unregistViewModel:(Class)viewModelClass
{
    BaseViewModel* viewModel = [BaseViewModel getViewModel:viewModelClass];
    if( viewModel )
    {
        [viewModel popViewController];
        if( [viewModel topViewController] == nil )
        {
            [viewModel cleanSignals];
            [gExistViewModels removeObject:viewModel];
        }
    }
    return nil;
}

+(id) getViewModel:(Class)viewModelClass
{
    for( BaseViewModel* viewModel in gExistViewModels )
    {
        if( [viewModel class] == viewModelClass )
        {
            return viewModel;
        }
    }
    return nil;
}

-(void) saveSignal:(CXSignal*)oneRootSignal
{
    if( !_KVOSignals )
    {
        _KVOSignals = [[NSMutableArray alloc] init];
    }
    else
    {
        for( CXSignal* rootSignal in _KVOSignals )
        {
            if( [rootSignal hasSameDNA:oneRootSignal] ) return;
        }
    }
    
    [_KVOSignals addObject:oneRootSignal];
}

-(void) cleanSignals
{
    for( int i=((int)_KVOSignals.count)-1; i>= 0; i-- )
    {
        CXSignal* signal = [_KVOSignals objectAtIndex:i];
        [signal removeSignal];
    }
    [_KVOSignals removeAllObjects];
}

-(void) setKVOObject:(NSString*)selfObject
                  to:(id)target
             keyPath:(NSString*)keyPath
         transformer:(id(^)(id value))transformer
{
    if( ((!selfObject) || (selfObject.length == 0)) &&
       ((!target) || (!keyPath) || (keyPath.length == 0)) &&
       (!transformer) )
    {
        return;
    }
    
    CXSignal* rootSignal = nil;
    rootSignal = [CXSignal createRootSignal];
    CXSignal* signal = [rootSignal addSignalWithTarget:self andKeyPath:selfObject];
    
    if( transformer )
    {
        signal = [signal addSignalWithTransformer:transformer];
    }
    if( target && keyPath && keyPath.length > 0 )
    {
        signal = [signal addSignalWithTarget:target andKeyPath:keyPath];
        if( !transformer )
        {
            [signal addSignalWithTarget:self andKeyPath:selfObject];
        }
        id value = [self valueForKey:selfObject];
        if( transformer )
        {
            value = transformer(value);
        }
        [target setValue:value forKeyPath:keyPath];
    }
    
    [self saveSignal:rootSignal];
}

-(void) setKVOObject:(NSString*)selfObject to:(id)target keyPath:(NSString*)keyPath
{
    [self setKVOObject:selfObject
                    to:target
               keyPath:keyPath
           transformer:nil];
}

-(void) setKVOObject:(NSString*)selfObject toBlock:(void (^)(id))block
{
    [self setKVOObject:selfObject
                    to:nil
               keyPath:nil
           transformer:^id(id value) {
               block(value);
               return value;
           }];
}

#pragma mark
#pragma mark init & dealloc

-(id) init
{
    if( self = [super init] )
    {
    }
    return self;
}

-(void) dealloc
{
}

@end
