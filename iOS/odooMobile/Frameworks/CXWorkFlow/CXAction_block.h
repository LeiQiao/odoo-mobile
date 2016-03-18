//
//  CXAction_block.h
//

#import <Foundation/Foundation.h>

@class CXAction_block;

typedef void(^CXActionMethod)(CXAction_block* action);
typedef void (^CXPushActionMethod)(CXAction_block* currentAction, CXAction_block* newAction);
typedef NSUInteger (^CXSubActionCountMethod)();
typedef CXAction_block* (^CXSubActionFactoryMethod)(NSUInteger index);

/*!
 *  @author LeiQiao, 16-03-14
 *  @brief 动作定义，需要根据实际情况处理进入、恢复、退出等动作
 */
@interface CXAction_block : NSObject

@property(nonatomic, weak) CXAction_block* parentAction;        /*!< 被中断的父事件 */
@property(nonatomic, strong) NSMutableArray* subActionStack;    /*!< 子动作的栈 */

/*!
 *  @brief 动作事件
 */

@property(nonatomic, copy) CXPushActionMethod pushAction;   /*!< 跳转到另一个工作流（如需要登录），当前工作流挂起 */
@property(nonatomic, copy) CXSubActionCountMethod subActionCount;     /*!< 工作流中的子动作数 */
@property(nonatomic, copy) CXSubActionFactoryMethod subActionAtIndex; /*!< 工作流中指定索引的子动作 */
@property(nonatomic, copy) CXActionMethod next;             /*!< 跳转到下一个动作，由子动作调用 */
@property(nonatomic, copy) CXActionMethod back;             /*!< 跳转到上一个动作，由子动作调用 */
@property(nonatomic, copy) CXActionMethod exit;             /*!< 退出当前工作流 */

@property(nonatomic, copy) CXActionMethod onEnter;      /*!< 进入动作，开始执行动作的内容 */
@property(nonatomic, copy) CXActionMethod onLeave;      /*!< 退出动作，清理现场 */
@property(nonatomic, copy) CXActionMethod onSuspend;    /*!< 挂起动作，当动作被外部条件中断时使动作挂起 */
@property(nonatomic, copy) CXActionMethod onResume;     /*!< 恢复动作，当外部条件处理结束后该动作继续执行 */
@property(nonatomic, copy) CXActionMethod onReverse;    /*!< 当该动作需要返回上一步时调用该方法 */

@end
