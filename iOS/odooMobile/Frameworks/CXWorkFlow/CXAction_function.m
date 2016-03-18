//
//  CXAction_function.m
//

#import "CXAction_function.h"

@implementation CXAction_function {
    CXAction_function* _pushedAction;
}

#pragma mark
#pragma mark helper

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 跳转到下一个动作，由子动作调用
 */
-(void) nextSubAction
{
    /*---------- 当前动作全部执行完毕 ----------*/
    if( _subActionStack.count == [self subActionCount] )
    {
        [self exitAction];
    }
    /*---------- 进入下一个动作 ----------*/
    else
    {
        CXAction_function* nextSubAction = [self subActionAtIndex:_subActionStack.count];
        nextSubAction->_parentAction = self;
        [_subActionStack addObject:nextSubAction];
        
        [nextSubAction onEnter];
    }
}

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 跳转到上一个动作，由子动作调用
 */
-(void) backSubAction
{
    /*---------- 删除当前动作 ----------*/
    if( _subActionStack.count > 0 )
    {
        CXAction_function* action = [_subActionStack lastObject];
        [_subActionStack removeLastObject];
        [action onLeave];
    }
    
    /*---------- 退出当前动作的第一个动作并退出 ----------*/
    if( _subActionStack.count == 0 )
    {
        [self exitAction];
    }
    /*---------- 恢复上一个动作 ----------*/
    else
    {
        CXAction_function* action = [_subActionStack lastObject];
        [action onReverse];
    }
}

/*!
 *  @author LeiQiao, 16-03-18
 *  @brief 退出该动作
 */
-(void) exitAction
{
    // 清理现场
    [self onLeave];
    
    if( !_parentAction ) return;
    
    // 如果该动作是父动作的一部分则父动作继续往下执行
    if( [_parentAction->_subActionStack lastObject] == self )
    {
        [_parentAction nextSubAction];
    }
    // 恢复被中断的任务
    else
    {
        [_parentAction onResume];
    }
}

#pragma mark
#pragma mark member functions

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
    return nil;
}

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 子动作调用自己的next方法，通知父动作执行下一个子动作，调用后会退出自己的动作
 */
-(void) next
{
    if( _parentAction ) [_parentAction nextSubAction];
}

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 子动作调用自己的back方法，通知父动作返回上一个子动作，调用后会退出自己的动作
 */
-(void) back
{
    if( _parentAction ) [_parentAction backSubAction];
}

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 跳转到另一个动作，由子动作调用
 *         当前动作和最后一个子动作将被挂起，新的动作执行完毕时恢复
 *  @param 新的动作
 */
-(void) pushAction:(CXAction_function*)newAction
{
    // 如果已经被挂起则抛出异常
    if( _pushedAction )
    {
        NSString* reason = [NSString stringWithFormat:@"this action (%@) has already suspended by action: (%@)",NSStringFromClass([self class]), _pushedAction];
        NSException* exception = [NSException exceptionWithName:NSGenericException
                                                         reason:reason
                                                       userInfo:nil];
        @throw exception;
    }
    
    // 如果被跳转的动作为空
    if( !newAction )
    {
        NSString* reason = [NSString stringWithFormat:@"newAction is (NULL)"];
        NSException* exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                         reason:reason
                                                       userInfo:nil];
        @throw exception;
    }
    
    // 挂起当前工作流
    [self onSuspend];
    
    // 进入新的工作流
    _pushedAction = newAction;
    newAction->_parentAction = self;
    [newAction onEnter];
}

/*!
 *  @author LeiQiao, 16-03-18
 *  @brief 退出当前动作并弹出新的动作
 *  @param newAction 新的动作
 */
-(void) exitAndPushAction:(CXAction_function*)newAction
{
    // 保存父动作
    CXAction_function* parentAction = _parentAction;
    
    // 退出当前动作
    [self exitAction];
    
    // 在父动作中弹出新动作
    if( parentAction )
    {
        [parentAction pushAction:newAction];
    }
    // 无父动作时直接运行新动作
    else
    {
        [newAction onEnter];
    }
}

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 进入动作，开始执行动作的内容
 */
-(void) onEnter
{
    // 创建工作流的动作栈
    if( !_subActionStack )
    {
        _subActionStack = [[NSMutableArray alloc] init];
    }
    
    // 进入第一个动作
    [self nextSubAction];
}

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 退出动作，清理现场
 */
-(void) onLeave
{
    // 删除所有栈中的动作并清理现场
    while( _subActionStack.count > 0 )
    {
        CXAction_function* action = [_subActionStack lastObject];
        [_subActionStack removeLastObject];
        
        [action onLeave];
    }
}

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 挂起动作，当动作被外部条件中断时使动作挂起
 */
-(void) onSuspend
{
    // 挂起最后一个任务
    CXAction_function* lastAction = [_subActionStack lastObject];
    if( lastAction )
    {
        [lastAction onSuspend];
    }
}

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 恢复动作，当外部条件处理结束后该动作继续执行
 */
-(void) onResume
{
    _pushedAction = nil;
    
    // 恢复最后一个任务(该任务应该为挂起状态)
    CXAction_function* lastAction = [_subActionStack lastObject];
    if( lastAction )
    {
        [lastAction onResume];
    }
}

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 当该动作需要返回上一步时调用该方法
 */
-(void) onReverse
{
    // 返回当前任务的最后一个任务
    CXAction_function* lastAction = [_subActionStack lastObject];
    if( lastAction )
    {
        [lastAction onReverse];
    }
}

@end
