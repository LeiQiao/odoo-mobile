//
//  BaseViewModel.h
//  SUPAY
//
//  Created by LeiQiao on 15/7/16.
//  Copyright (c) 2015年 chinapnr.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ViewModelCallback_0)();
typedef void (^ViewModelCallback_1)(id obj);
typedef void (^ViewModelCallback_1B)(BOOL boolValue);


@interface BaseViewModel : NSObject

// viewController's stack

@property(nonatomic, strong) NSMutableArray* viewControllerStack;

-(UIViewController*)topViewController;
-(void) pushViewController:(UIViewController*)viewController;
-(void) popViewController;

+(id) registNewViewModel:(Class)newViewModelClass viewController:(UIViewController*)viewController;
+(id) unregistViewModel:(Class)viewModelClass;
+(id) getViewModel:(Class)viewModelClass;

// KVO

-(void) setKVOObject:(NSString*)selfObject
                  to:(id)target
             keyPath:(NSString*)keyPath
         transformer:(id(^)(id value))transformer;

-(void) setKVOObject:(NSString*)selfObject
                  to:(id)target
             keyPath:(NSString*)keyPath;

-(void) setKVOObject:(NSString*)selfObject
             toBlock:(void (^)(id))block;

@end

#define REGIST_VIEWMODEL(VIEWMODELCLASSNAME, VIEWCONTROLLER)    \
    ((VIEWMODELCLASSNAME*)[BaseViewModel registNewViewModel:[VIEWMODELCLASSNAME class] viewController:VIEWCONTROLLER])
#define UNREGIST_VIEWMODEL(VIEWMODELCLASSNAME)  \
    [BaseViewModel unregistViewModel:[VIEWMODELCLASSNAME class]]
#define GET_VIEWMODEL(VIEWMODELCLASSNAME)   \
    ((VIEWMODELCLASSNAME*)[BaseViewModel getViewModel:[VIEWMODELCLASSNAME class]])

// KVO


