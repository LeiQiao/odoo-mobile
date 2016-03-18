//
//  CXAction_function.h
//

#import <Foundation/Foundation.h>

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 动作定义，需要根据实际情况处理进入、恢复、退出等动作
 *         一个动作中可以包含更多的子动作，子动作使用更小颗粒度实现单一的功能，父动作实现流程控制和数据存储
 *         一个单一功能的动作可以被用于不同的父动作中，一个流程功能的动作也可以被用于多个不同的父动作中
 *         一个动作可以被顺序／倒叙的执行，也可以被其它的动作中断执行
 *         1. 顺序执行动作时，将该动作作为子动作中的一项，可以使用subActionAtIndex将动作创建出来
 *         2. 中断执行动作时，调用pushAction来执行一个新的任务，新的任务执行完毕后返回该任务继续执行
 *            中断执行时会先挂起当前执行的动作和当前执行的动作的最后一个子动作
 *            当该中断运行的动作执行完毕后恢复被中断的动作和被中断的最后一个子动作
 *
 */
@interface CXAction_function : NSObject {
    __weak CXAction_function* _parentAction;    /*!< 父动作 */
    NSMutableArray* _subActionStack;            /*!< 子动作的栈 */
}

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 获取子动作的个数，工厂模式，子类无需主动调用，只要复写即可
 *  @return 自动作的个数
 */
-(NSUInteger) subActionCount;

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 获取指定索引的子动作，工厂模式，子类无需主动调用，只要复写即可
 *  @param index          子动作的索引
 *  @return 子动作
 */
-(CXAction_function*) subActionAtIndex:(NSUInteger)index;

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 跳转到另一个动作，由子动作调用
 *         当前动作和最后一个子动作将被挂起，新的动作执行完毕时恢复
 *  @param 新的动作
 */
-(void) pushAction:(CXAction_function*)newAction;

/*!
 *  @author LeiQiao, 16-03-18
 *  @brief 退出当前动作并弹出新的动作
 *  @param newAction 新的动作
 */
-(void) exitAndPushAction:(CXAction_function*)newAction;

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 子动作调用自己的next方法，通知父动作执行下一个子动作，调用后会退出自己的动作
 */
-(void) next;

/*!
 *  @author LeiQiao, 16-03-15
 *  @brief 子动作调用自己的back方法，通知父动作返回上一个子动作，调用后会退出自己的动作
 */
-(void) back;

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 进入动作，开始执行动作的内容
 */
-(void) onEnter;

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 退出动作，清理现场
 */
-(void) onLeave;

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 挂起动作，当动作被外部条件中断时使动作挂起
 */
-(void) onSuspend;

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 恢复动作，当外部条件处理结束后该动作继续执行
 */
-(void) onResume;

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 当该动作需要返回上一步时调用该方法
 */
-(void) onReverse;

@end
