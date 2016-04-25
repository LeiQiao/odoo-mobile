//
//  CXBaseAction.m
//

#import "CXBaseAction.h"

NSString *const kCXActionDidLoadNotifaction = @"kCXActionDidLoadNotifaction";           /*!< 事件被加载 */
NSString *const kCXActionDidSuspendNotifaction = @"kCXActionDidSuspendNotifaction";     /*!< 事件被挂起 */
NSString *const kCXActionDidResumeNotifaction = @"kCXActionDidResumeNotifaction";       /*!< 事件被恢复 */
NSString *const kCXActionDidLeaveNotifaction = @"kCXActionDidLeaveNotifaction";         /*!< 事件被卸载 */
NSString *const kCXActionDidDestroyNotifaction = @"kCXActionDidDestroyNotifaction";     /*!< 事件被销毁 */

static NSOperationQueue* CXActionNotificationQueue; /*!< 通知队列 */

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 动作类，定义程序的每一个环节，一个程序只有一个动作栈，一个动作栈不允许中间插入新动作
 */
@implementation CXBaseAction {
    CXBaseAction* _parentAction;    /*!< 父动作 */
    CXBaseAction* _childAction;     /*!< 子动作 */
}

#pragma mark
#pragma mark helper

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 使用异步的方式通知观察者，异步用来保证在消息之间不会在一个mainLoop中
 *  @param notificationName 通知消息名称
 */
-(void) addNotificationToQueue:(NSString*)notificationName
{
    NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(postNotification:)
                                                                              object:notificationName];
    [CXActionNotificationQueue addOperation:operation];
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 异步通知观察者，该方法不运行在主线程，所以需要使用dispatch放到主线程运行
 *  @param notificationName 通知消息名称
 */
-(void) postNotification:(NSString*)notificationName
{
    sleep(0);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:self
                                                          userInfo:nil];
    });
}



/**
 *  @author LeiQiao, 16/04/02
 *  @brief 销毁子动作，子动作将发送kCXActionDidDestroyNotifaction通知，
 *         但是不给该动作发送kCXActionDidResumeNotifaction通知
 */
-(void) destroyChildActionAndNotResume
{
    CXBaseAction* lastAction = self;
    
    // 倒叙查找最后一个动作
    while( lastAction->_childAction )
    {
        lastAction = lastAction->_childAction;
    }
    
    // 倒叙销毁子动作
    while( lastAction != self )
    {
        CXBaseAction* parentAction = lastAction->_parentAction;
        
        // 断开与上一个动作的绑定
        lastAction->_parentAction->_childAction = nil;
        lastAction->_parentAction = nil;
        
        // 销毁最后一个动作
        [lastAction addNotificationToQueue:kCXActionDidDestroyNotifaction];
        
        lastAction = parentAction;
    }
}

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 设置参数
 *  @param parameters 参数
 */
-(void) setParameters:(id)parameters
{
    _parameters = parameters;
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 创建新动作
 *  @param actionClass 类名
 *  @param paramenters 参数
 *  @return 创建的新动作
 */
-(CXBaseAction*) newAction:(Class)actionClass withParameters:(id)paramenters
{
    // 创建新的动作
    CXBaseAction* newAction = [actionClass new];
    NSAssert((newAction != nil), @"action \"%@\" did NOT exist", NSStringFromClass(actionClass));
    NSAssert([newAction isKindOfClass:[CXBaseAction class]], @"action \"%@\" is NOT kind of CXBaseAction", actionClass);
    
    self->_childAction = newAction;
    newAction->_parentAction = self;
    
    [newAction setParameters:paramenters];
    
    return newAction;
}

#pragma mark
#pragma mark override

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 获取当前动作是否时最上层活动的动作
 *  @return 获取当前动作是否时最上层活动的动作
 */
-(BOOL) isActive
{
    return (!_childAction);
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 获取根动作
 *  @return 获取根动作
 */
-(CXBaseAction*) rootAction
{
    CXBaseAction* rootAction = self;
    while( rootAction->_parentAction )
    {
        rootAction = rootAction->_parentAction;
    }
    return rootAction;
}

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 获取当前根动作的最后一个动作
 *  @return 获取当前根动作的最后一个动作
 */
-(CXBaseAction*) currentAction
{
    CXBaseAction* currentAction = self;
    while( currentAction->_childAction )
    {
        currentAction = currentAction->_childAction;
    }
    return currentAction;
}

#pragma mark
#pragma mark member functions

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 使用该动作作为根动作，新动作将会发送kCXActionDidLoadNotifaction通知
 *  @param actionClass 根动作类名
 */
+(CXBaseAction*) launchAsRootAction:(Class)actionClass
{
    // 创建新的通知队列
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /*---------- 动作监听队列 ----------*/
        CXActionNotificationQueue = [NSOperationQueue new];
        
        // 同时只能通知一个消息
        CXActionNotificationQueue.maxConcurrentOperationCount = 1;
        
        // 添加观察者
        [[NSNotificationCenter defaultCenter] addObserver:[CXBaseAction class]
                                                 selector:@selector(actionDidLoad:)
                                                     name:kCXActionDidLoadNotifaction
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:[CXBaseAction class]
                                                 selector:@selector(actionDidSuspend:)
                                                     name:kCXActionDidSuspendNotifaction
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:[CXBaseAction class]
                                                 selector:@selector(actionDidResume:)
                                                     name:kCXActionDidResumeNotifaction
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:[CXBaseAction class]
                                                 selector:@selector(actionDidLeave:)
                                                     name:kCXActionDidLeaveNotifaction
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:[CXBaseAction class]
                                                 selector:@selector(actionDidDestroy:)
                                                     name:kCXActionDidDestroyNotifaction
                                                   object:nil];
    });
    
    // 创建新的动作
    CXBaseAction* rootAction = [actionClass new];
    NSAssert((rootAction != nil), @"action \"%@\" did NOT exist", NSStringFromClass(actionClass));
    NSAssert([rootAction isKindOfClass:[CXBaseAction class]], @"action \"%@\" is NOT kind of CXBaseAction", actionClass);
    
    // 进入新动作
    [rootAction addNotificationToQueue:kCXActionDidLoadNotifaction];
    
    return rootAction;
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 进入新动作，该动作将发送kCXActionDidSuspendNotifaction通知
 *         新动作将会发送kCXActionDidLoadNotifaction通知
 *  @param actionClass 新动作类名
 */
-(void) enterAction:(Class)actionClass
{
    [self enterAction:actionClass withParameters:nil];
}

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 进入新动作，该动作将发送kCXActionDidSuspendNotifaction通知
 *         新动作将会发送kCXActionDidLoadNotifaction通知
 *  @param actionClass 新动作类名
 *  @param parameters  参数
 */
-(void) enterAction:(Class)actionClass withParameters:(NSDictionary*)parameters
{
    CXBaseAction* newAction = [self newAction:actionClass withParameters:parameters];
    
    // 挂起本动作并进入新动作
    [self addNotificationToQueue:kCXActionDidSuspendNotifaction];
    [newAction addNotificationToQueue:kCXActionDidLoadNotifaction];
}

/*!
 *  @author LeiQiao, 16-04-07
 *  @brief 离开本动作切换到另外一个动作
 *  @param actionClass 另外一个动作的类名
 */
-(void) switchToAction:(Class)actionClass
{
    [self switchToAction:actionClass withParameters:nil];
}

/*!
 *  @author LeiQiao, 16-04-09
 *  @brief 离开本动作切换到另外一个动作
 *  @param actionClass 另外一个动作的类名
 *  @param parameters  参数
 */
-(void) switchToAction:(Class)actionClass withParameters:(NSDictionary*)parameters
{
    CXBaseAction* parentAction = self->_parentAction;
    
    // 销毁父动作中的子动作
    [parentAction destroyChildActionAndNotResume];
    
    // 给父动作创建新动作，这时父动作已经被挂起，所以不会再次调用挂起事件
    CXBaseAction* newAction = [parentAction newAction:actionClass withParameters:parameters];
    [newAction addNotificationToQueue:kCXActionDidLoadNotifaction];
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 离开本动作，该动作将发送kCXActionDidLeaveNotifaction和kCXActionDidDestroyNotifaction通知，
 *         子动作只发送kCXActionDidDestroyNotifaction通知
 */
-(void) leaveAction
{
    // 销毁子动作
    [self destroyChildActionAndNotResume];
    
    // 离开并销毁该动作
    [self addNotificationToQueue:kCXActionDidLeaveNotifaction];
    [self addNotificationToQueue:kCXActionDidDestroyNotifaction];
    
    CXBaseAction* parentAction = self->_parentAction;
    if( parentAction )
    {
        // 断开与上一个动作的绑定
        parentAction->_childAction = nil;
        self->_parentAction = nil;
        
        // 恢复上一个动作
        [parentAction addNotificationToQueue:kCXActionDidResumeNotifaction];
    }
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 销毁子动作，子动作将发送kCXActionDidDestroyNotifaction通知，
 *         该动作会发送kCXActionDidResumeNotifaction通知
 */
-(void) destroyChildAction
{
    [self destroyChildActionAndNotResume];
    
    // 恢复该动作
    [self addNotificationToQueue:kCXActionDidResumeNotifaction];
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 获取子动作
 *  @param className 子动作类名
 *  @return 获取子动作
 */
-(CXBaseAction*) childActionForClass:(Class)className
{
    CXBaseAction* action = [self rootAction];
    while( action )
    {
        if( [action class] == className )
        {
            return action;
        }
        action = action->_childAction;
    }
    return nil;
}

#pragma mark
#pragma mark 子类需要继承

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 动作被加载
 */
+(void) actionDidLoad:(NSNotification*)notify
{
    CXBaseAction* action = (CXBaseAction*)notify.object;
    if( [action isKindOfClass:[CXBaseAction class]] )
    {
        [action actionDidLoad];
    }
}

-(void) actionDidLoad
{
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 动作被挂起
 */
+(void) actionDidSuspend:(NSNotification*)notify
{
    CXBaseAction* action = (CXBaseAction*)notify.object;
    if( [action isKindOfClass:[CXBaseAction class]] )
    {
        [action actionDidSuspend];
    }
}

-(void) actionDidSuspend
{
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 动作被恢复
 */
+(void) actionDidResume:(NSNotification*)notify
{
    CXBaseAction* action = (CXBaseAction*)notify.object;
    if( [action isKindOfClass:[CXBaseAction class]] )
    {
        [action actionDidResume];
    }
}

-(void) actionDidResume
{
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 动作被卸载
 */
+(void) actionDidLeave:(NSNotification*)notify
{
    CXBaseAction* action = (CXBaseAction*)notify.object;
    if( [action isKindOfClass:[CXBaseAction class]] )
    {
        [action actionDidLeave];
    }
}

-(void) actionDidLeave
{
}

/**
 *  @author LeiQiao, 16/04/02
 *  @brief 动作被销毁
 */
+(void) actionDidDestroy:(NSNotification*)notify
{
    CXBaseAction* action = (CXBaseAction*)notify.object;
    if( [action isKindOfClass:[CXBaseAction class]] )
    {
        [action actionDidDestroy];
    }
}

-(void) actionDidDestroy
{
}

@end
