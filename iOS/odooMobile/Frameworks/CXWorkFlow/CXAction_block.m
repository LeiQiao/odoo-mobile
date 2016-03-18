//
//  CXAction_block.m
//

#import "CXAction_block.h"

@implementation CXAction_block

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 初始化方法
 *  @return 该类的实例对象
 */
-(instancetype) init
{
    if( self = [super init] )
    {
        // 设置默认的动作
        self.onEnter =
        self.onLeave =
        self.onSuspend =
        self.onResume =
        self.onReverse = ^(CXAction_block* action) {
        };
        
        /*---------- 跳转到另一个工作流 ----------*/
        self.pushAction = ^(CXAction_block* currentAction, CXAction_block* nextAction) {
            // 挂起当前工作流
            currentAction.onSuspend(currentAction);
            
            // 进入新的工作流
            nextAction.parentAction = currentAction;
            nextAction.onEnter(nextAction);
        };
        
        /*---------- 获取工作流中的动作数 ----------*/
        self.subActionCount = ^NSUInteger (){
            return 0;
        };
        
        /*---------- 获取工作流中指定索引的子动作 ----------*/
        self.subActionAtIndex = ^CXAction_block* (NSUInteger index){
            return nil;
        };
        
        /*---------- 进入当前工作流的下一个动作 ----------*/
        self.next = ^(CXAction_block* action) {
            // 当前工作流全部执行完毕
            if(action.subActionStack.count == action.subActionCount() )
            {
                action.exit(action);
                return;
            }
            // 进入下一个动作
            else
            {
                CXAction_block* nextSubAction = action.subActionAtIndex(action.subActionStack.count);
                nextSubAction.parentAction = action;
                [action.subActionStack addObject:nextSubAction];
                
                nextSubAction.onEnter(nextSubAction);
            }
        };
        
        /*---------- 跳转到当前工作流的上一个动作 ----------*/
        self.back = ^(CXAction_block* action) {
            // 删除当前动作
            CXAction_block* prevAction = [action.subActionStack lastObject];
            [action.subActionStack removeLastObject];
            
            action.onLeave(action);
            
            // 退出当前工作流的第一个动作，退出工作流
            if( action.subActionStack.count == 0 )
            {
                action.exit(action);
            }
            // 返回到上一个动作
            else
            {
                prevAction = [action.subActionStack lastObject];
                prevAction.onReverse(prevAction);
            }
        };
        
        /*---------- 退出当前工作流 ----------*/
        self.exit = ^(CXAction_block* action) {
            // 删除所有栈中的动作并清理现场
            while( action.subActionStack.count > 0 )
            {
                CXAction_block* subAction = [action.subActionStack lastObject];
                [action.subActionStack removeLastObject];
                
                subAction.onLeave(action);
            }
            
            action.onLeave(action);
            
            // 恢复跳转来的工作流
            if( action.parentAction )
            {
                action.parentAction.onResume(action.parentAction);
            }
        };
        
        /*---------- 进入工作流 ----------*/
        self.onEnter = ^(CXAction_block* action) {
            // 创建工作流的动作栈
            if( !action.subActionStack )
            {
                action.subActionStack = [[NSMutableArray alloc] init];
            }
            
            // 进入第一个动作
            action.next(action);
        };
        
        /*---------- 挂起工作流，push到另外一个工作流时由pushWorkFlow函数调用 ----------*/
        self.onSuspend = ^(CXAction_block* action) {
            // 挂起最后一个任务
            CXAction_block* lastAction = [action.subActionStack lastObject];
            if( lastAction )
            {
                lastAction.onSuspend(lastAction);
            }
        };
        
        /*---------- 恢复工作流，从另外一个工作流恢复时由上一个工作流调用 ----------*/
        self.onResume = ^(CXAction_block* action) {
            // 恢复最后一个任务(该任务应该为挂起状态)
            CXAction_block* lastAction = [action.subActionStack lastObject];
            if( lastAction )
            {
                lastAction.onResume(lastAction);
            }
        };
    }
    return self;
}

@end
