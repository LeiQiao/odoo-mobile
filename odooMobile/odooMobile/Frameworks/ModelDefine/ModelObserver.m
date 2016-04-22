//
//  ModelObserver.m
//  KCService
//
//  Created by dongwen on 12-1-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ModelObserver.h"
#import <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 使用weak的方式将观察者添加到数组中的辅助类
 */
@interface ObserverAssign : NSObject
@property (weak, nonatomic) id<BaseModelObserver> observer;   /*!< weak的观察者 */
@end
@implementation ObserverAssign
@end

#pragma mark
#pragma mark BaseModel

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 模型类的基类
 */
@implementation BaseModel

#pragma mark
#pragma mark observer

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 添加观察者
 *  @param observer 观察者
 */
-(void) addObserver:(id<BaseModelObserver>)observer
{
	if( observer == nil ) return;
	
    // 从队列中查看是否已经存在该观察者，防止重复添加造成一个时间通知多次观察者
	for(NSInteger index=0; index < _observers.count; index++ )
	{
		ObserverAssign* eachAs = [_observers objectAtIndex:index];
		if( eachAs.observer == observer ) return;
	}
	
    // 使用弱类型观察者对象将观察者添加到观察队列中
	ObserverAssign* as = [[ObserverAssign alloc] init];
	as.observer = observer;
    [_observers addObject:as];
#if !__has_feature(objc_arc)
	[as release];
#endif
}

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 删除观察者
 *  @param observer 观察者
 */
-(void) removeObserver:(id<BaseModelObserver>)observer
{
	if( observer == nil ) return;
	
	for( NSInteger index = _observers.count-1; index >= 0; index-- )
	{
		ObserverAssign* as = [_observers objectAtIndex:index];
		if( as.observer == observer )
		{
			[_observers removeObject:as];
		}
	}
}

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 通知观察者
 *  @param action  观察消息
 *  @param object1 参数1
 *  @param object2 参数2
 */
-(void) callObserver:(SEL)action withObject:(id)object1 withObject:(id)object2
{
    [_locker lock];
    NSInteger count = _observers.count;
    for( NSInteger index=count-1; index >=0; index-- )
    {
        ObserverAssign* eachAs = [_observers objectAtIndex:index];
        if( [eachAs.observer respondsToSelector:action] )
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [eachAs.observer performSelector:action withObject:object1 withObject:object2];
#pragma clang diagnostic pop
        }
    }
    [_locker unlock];
}

-(void) callObserver:(SEL)action withObject:(id)object
{
    [self callObserver:action withObject:object withObject:nil];
}

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 检查是否是观察者队列中的第一个观察者
 *  @param observer 观察者
 *  @return 是否是观察者队列中的第一个观察者
 */
-(BOOL) isFirstResponder:(id)observer
{
	return ( (_observers.count > 0) && (((ObserverAssign*)[_observers objectAtIndex:0]).observer == observer) );
}


#pragma mark
#pragma mark init & dealloc

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 初始化
 *  @return 返回BaseModel对象
 */
-(id) init
{
	if( self = [super init] )
	{
        _locker = [[NSCondition alloc] init];
		_observers = [[NSMutableArray alloc] init];
	}
	return self;
}

#if !__has_feature(objc_arc)
/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 销毁模型类对象，及清理现场
 */
-(void) dealloc
{
	[super dealloc];
	
	if( _locker != nil )
	{
		[_locker release];
		_locker = nil;
	}
	if( _observers != nil )
	{
		[_observers removeAllObjects];
		[_observers release];
		_observers = nil;
	}
}
#endif

@end

#pragma mark
#pragma mark ReturnParam

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 返回参数列表
 */
@implementation ReturnParam

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 初始化
 *  @return 返回ReturnParam对象
 */
-(id) init
{
	if( self = [super init] )
	{
		self.success = NO;
		self.failedCode = @"";
		self.failedReason = @"";
		_userInfo = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#if !__has_feature(objc_arc)
/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 销毁返回参数列表对象，及清理现场
 */
-(void) dealloc
{
    self.failedCode = nil;
    self.failedReason = nil;
    [_userInfo release];
    
    [super dealloc];
}
#endif

@end

#pragma mark
#pragma mark RequestParam

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 请求参数列表
 */
@implementation RequestParam {
    NSMutableDictionary* _parameters;
}

#pragma mark
#pragma mark helper

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 将dictionary转换成字符串
 *  @return 返回Dictionary转换成的字符串
 */
-(NSString*) description
{
    return [_parameters description];
}

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 将dictionary转换成字符串（供调试模式）
 *  @return 返回Dictionary转换成的字符串（供调试模式）
 */
-(NSString*) debugDescription
{
    return [_parameters debugDescription];
}

#pragma mark
#pragma mark init & dealloc

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 初始化
 *  @return 返回RequestParam对象
 */
-(id) init
{
    if( self = [super init] )
    {
        _parameters = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark
#pragma mark member functions

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 使用Key获取请求参数
 *  @param aKey 请求参数的Key
 *  @return 请求参数的Value
 */
-(id) objectForKeyedSubscript:(id)key
{
    return [_parameters objectForKeyedSubscript:key];
}

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 使用Key设置请求参数
 *  @param obj 请求参数的Value
 *  @param key 请求参数的Key
 */
-(void) setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey
{
    [_parameters setObject:object forKeyedSubscript:aKey];
}

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 删除所有参数
 */
-(void) removeAllObjects
{
    [_parameters removeAllObjects];
}

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 更新参数
 */
-(void) updateParameters
{
}

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 将参数转成字典
 *  @return 返回字典
 */
-(NSDictionary*) dictionary
{
    return _parameters;
}

@end

#pragma mark
#pragma mark BaseRequestModel

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 请求模型
 */
@implementation BaseRequestModel {
    __weak id _delegateTarget;  /*!< 替换观察者的代理 */
    SEL _delegateAction;        /*!< 替换观察者的代理回调 */
    
    BOOL _finished;             /*!< 请求是否结束 */
    
    NSCondition* _locker;       /*!< 是否允许调用请求结果的互斥锁 */
    BOOL _isLocking;            /*!< 是否已上锁 */
}

#pragma mark
#pragma mark helper

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 请求成功的回调方法
 *  @param success 下层的请求成功的回调方法
 *  @return 返回本类中使用的请求回调方法
 */
-(BaseRequestModelSuccess) extendSuccess:(BaseRequestModelSuccess)success
{
    BaseRequestModelSuccess reqSuccess = ^(id responseObject) {
        
        // 加锁,防止回调过程中被代理替换或恢复
        self.wait = YES;
        
        // 请求成功调用下层请求成功的回调方法
        if( success )
        {
            success(responseObject);
        }
        
        // 通知观察者或代理
        [self callObserverOrDelegate];
        
        // 解锁
        self.wait = NO;
    };
    
    return reqSuccess;
}

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 请求失败的回调方法
 *  @param failure 下层的请求失败的回调方法
 *  @return 返回本类中使用的请求回调方法
 */
-(BaseRequestModelFailure) extendFailure:(BaseRequestModelFailure)failure
{
    BaseRequestModelFailure reqFailure = ^(NSError* error) {
        
        // 加锁,防止回调过程中被代理替换或恢复
        self.wait = YES;
        
        // 请求失败调用下层请求失败的回调方法
        if( failure )
        {
            failure(error);
        }
        
        // 通知观察者或代理
        [self callObserverOrDelegate];
        
        // 解锁
        self.wait = NO;
    };
    
    return reqFailure;
}

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 请求成功或失败后调用该函数来回调观察者或者代理
 */
-(void) callObserverOrDelegate
{
    // 标志请求完成
    _finished = YES;

    // 如果观察者被代理替换则回调代理
    if( _delegateTarget && [_delegateTarget respondsToSelector:_delegateAction] )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_delegateTarget performSelector:_delegateAction withObject:self];
#pragma clang diagnostic pop
    }
    else if( _observeModel && _observeCallback )
    {
        // 调用子类的通知观察者方法
        [self callObserver];
    }
}

#pragma mark
#pragma mark init & dealloc

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 创建新的请求模型
 *  @param target 观察者模型(BaseModel)
 *  @param action 观察者方法
 *  @return 请求模型实例
 */
-(instancetype) initWithObserveModel:(id)observeModel andCallback:(SEL)observeCallback
{
    if( self = [self init] )
    {
        [self setObserveModel:observeModel andCallback:observeCallback];
    }
    return self;
}

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 创建新的请求模型，该类
 *  @return 请求模型实例
 */
-(instancetype) init
{
    if( self = [super init] )
    {
        _observeModel = nil;
        _observeCallback = nil;
        
        _reqParam = [[RequestParam alloc] init];
        _retParam = [[ReturnParam alloc] init];
        
        _locker = [[NSCondition alloc] init];
    }
    return self;
}

#if !__has_feature(objc_arc)
/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 销毁返回参数列表对象，及清理现场
 */
-(void) dealloc
{
    [_requestParameters release];
    [_retParam release];
    [_locker release];
    
    [super dealloc];
}
#endif

#pragma mark
#pragma mark override

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 请求是否完成
 *  @return 返回请求是否完成
 */
-(BOOL) isFinished
{
    return _finished;
}

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 是否请求结果回调已上锁
 *  @return 返回是否请求结果回调已上锁
 */
-(BOOL) isWaiting
{
    return _isLocking;
}

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 设置请求结果是否锁定
 *  @param bWait 是否锁定
 */
-(void) setWait:(BOOL)bWait
{
    // 锁定状态已经跟现在一致则什么也不做
    if( _isLocking && bWait ) return;
    if( (!_isLocking) && (!bWait) ) return;
    
    // 锁定
    if( bWait )
    {
        _isLocking = YES; // 先使用标志位防止锁定过程中再次锁定
        [_locker lock];
    }
    // 解锁
    else
    {
        [_locker unlock];
        _isLocking = NO;// 后使用标志位防止解锁过程中再次解锁
    }
}

#pragma mark
#pragma mark 替换观察者及观察者通知

/*!
 *  @author LeiQiao, 15-12-16
 *  @brief 替换观察模型和观察方法
 *  @param observeModel 观察者模型(BaseModel)
 *  @param observeCallback 观察者方法
 */
-(void) setObserveModel:(id)observeModel andCallback:(SEL)observeCallback
{
    self.wait = YES;
    _observeModel = observeModel;
    _observeCallback = observeCallback;
    self.wait = NO;
}

#pragma mark
#pragma mark 使用代理替换观察者通知

/*!
 *  @author LeiQiao, 15-12-11
 *  @brief 使用代理替换观察者通知
 *  @param target 代理对象
 *  @param action 代理方法
 */
-(void) replaceObserveWithTarget:(id)target andAction:(SEL)action
{
    self.wait = YES;
    _delegateTarget = target;
    _delegateAction = action;
    self.wait = NO;
}

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 观察者通知是否被代理替换
 *  @return 观察者通知是否被代理替换
 */
-(BOOL) isObserveReplaced
{
    return (_delegateTarget);
}

/*!
 *  @author LeiQiao, 15-12-11
 *  @brief 删除代理恢复观察者通知
 *  @param callObserver 是否立刻通知观察者
 */
-(void) restoreObserveModel:(BOOL)callObserver
{
    _delegateTarget = nil;
    _delegateAction = nil;
    if( callObserver )
    {
        [self callObserver];
    }
}

#pragma mark
#pragma mark POST 请求

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 发送POST请求
 *  @param urlString 请求接口
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
-(void) POST:(NSString*)urlString success:(BaseRequestModelSuccess)success failure:(BaseRequestModelFailure)failure
{
    // 重置标志位
    _finished = NO;
    
    // 设置参数
    _requestMethod = BaseRequestModelMethodPost;
    _requestURLString = urlString;
    _successCallback = [self extendSuccess:success];
    _failureCallback = [self extendFailure:failure];
    
    _originSuccessCallback = success;
    _originFailureCallback = failure;
    
    // 调用子类来实际发送请求
    [self doPOST];
}

-(void) POST:(NSString*)urlString success:(BaseRequestModelSuccess)success
{
    [self POST:urlString success:success failure:nil];
}

-(void) POST:(NSString*)urlString
{
    [self POST:urlString success:nil];
}

#pragma mark
#pragma mark GET 请求

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 发送GET请求
 *  @param urlString 请求接口
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
-(void) GET:(NSString*)urlString success:(BaseRequestModelSuccess)success failure:(BaseRequestModelFailure)failure
{
    // 重置标志位
    _finished = NO;
    
    // 设置参数
    _requestMethod = BaseRequestModelMethodGet;
    _requestURLString = urlString;
    _successCallback = [self extendSuccess:success];
    _failureCallback = [self extendFailure:failure];
    
    _originSuccessCallback = success;
    _originFailureCallback = failure;
    
    // 调用子类来实际发送请求
    [self doGET];
}

-(void) GET:(NSString*)urlString success:(BaseRequestModelSuccess)success
{
    [self GET:urlString success:success failure:nil];
}

-(void) GET:(NSString*)urlString
{
    [self GET:urlString success:nil];
}

#pragma mark
#pragma mark 设置成功失败的回调

/*!
 *  @author LeiQiao, 15-12-16
 *  @brief 设置成功的回调
 *  @param successCallback 成功的回调
 */
-(void) setSuccessCallback:(BaseRequestModelSuccess)successCallback
{
    self.wait = YES;
    _successCallback = [self extendSuccess:successCallback];
    self.wait = NO;
}

/*!
 *  @author LeiQiao, 15-12-16
 *  @brief 设置失败的回调
 *  @param failureCallback 失败的回调
 */
-(void) setFailureCallback:(BaseRequestModelFailure)failureCallback
{
    self.wait = YES;
    _failureCallback = [self extendFailure:failureCallback];
    self.wait = NO;
}

#pragma mark
#pragma mark 请求操作

/*!
 *  @author LeiQiao, 15-12-11
 *  @brief 重新发送请求
 */
-(void) reSend
{
    // 重置标志位
    _finished = NO;
    
    // 更新请求参数（如token或者checkValue等需要在重发时更新）
    [self.reqParam updateParameters];
    
    // 根据请求方式来调用相应的子类函数完成实际发送网络请求
    if( _requestMethod == BaseRequestModelMethodGet )
    {
        [self doGET];
    }
    else
    {
        [self doPOST];
    }
}

/*!
 *  @author LeiQiao, 15-12-11
 *  @brief 抛弃请求
 */
-(void) drop
{
    // 销毁所有对象
    _observeModel = nil;
    _observeCallback = nil;
    _delegateTarget = nil;
    _delegateAction = nil;
    _successCallback = nil;
    _failureCallback = nil;
}

#pragma mark
#pragma mark 私有函数

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 通知观察者
 */
-(void) callObserver
{
    NSAssert(NO, @"子类必须重载该方法");
}

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 公共函数的POST只做为封装操作，实际网络请求在该函数中执行
 */
-(void) doPOST
{
    NSAssert(NO, @"子类必须重载该方法");
}

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 公共函数的GET只做为封装操作，实际网络请求在该函数中执行
 */
-(void) doGET
{
    NSAssert(NO, @"子类必须重载该方法");
}

@end











