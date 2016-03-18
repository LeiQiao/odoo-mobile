//
//  MainAction.m
//  odooMobile
//
//  Created by lei.qiao on 16/3/18.
//  Copyright © 2016年 LeiQiao. All rights reserved.
//

#import "MainAction.h"
#import "AppDelegate.h"

#define SINGLETION_ACTION(__ACTION_CLASS)    \
    { \
        static __ACTION_CLASS* s__##__ACTION_CLASS = nil; \
        static dispatch_once_t s__##__ACTION_CLASS_once; \
        dispatch_once(&s__##__ACTION_CLASS_once, ^{ \
            s__##__ACTION_CLASS = [[__ACTION_CLASS alloc] init]; \
        }); \
        return s__##__ACTION_CLASS; \
    }


CXAction* CXActionForClass(Class actionClass)
{
    if( actionClass  == [MainAction class] )
    {
        SINGLETION_ACTION(MainAction);
    }
    return nil;
}

@implementation MainAction

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 获取子动作的个数，工厂模式，子类无需主动调用，只要复写即可
 *  @return 自动作的个数
 */
-(NSUInteger) subActionCount
{
    return 0;
}

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 获取指定索引的子动作，工厂模式，子类无需主动调用，只要复写即可
 *  @param index          子动作的索引
 *  @return 子动作
 */
-(CXAction_function*) subActionAtIndex:(NSUInteger)index
{
}

@end
