//
//  ModelObserver.h
//  KCService
//
//  Created by dongwen on 12-1-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ADDOBSERVER(modelName, observer) [GETMODEL(modelName) addObserver:observer];
#define REMOVEOBSERVER(modelName, observer) [GETMODEL(modelName) removeObserver:observer];

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 模型类的观察者列表基类
 */
@protocol BaseModelObserver <NSObject>
@end

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 模型类的基类
 */
@interface BaseModel : NSObject {
    NSCondition*	_locker;        /*!< 多线程保护锁 */
	
	NSMutableArray* _observers;     /*!< 观察者队列 */
}

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 添加观察者
 *  @param observer 观察者
 */
-(void) addObserver:(id<BaseModelObserver>)observer;

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 删除观察者
 *  @param observer 观察者
 */
-(void) removeObserver:(id<BaseModelObserver>)observer;

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 通知观察者
 *  @param action  观察消息
 *  @param object1 参数1
 *  @param object2 参数2
 */
-(void) callObserver:(SEL)action withObject:(id)object1 withObject:(id)object2;
-(void) callObserver:(SEL)action withObject:(id)object;

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 检查是否是观察者队列中的第一个观察者，
 *         观察者本来不用考虑使用时间序列，调用该方法时请再三考虑是否合理
 *  @param observer 观察者
 *  @return 是否是观察者队列中的第一个观察者
 */
-(BOOL) isFirstResponder:(id)observer;

@end

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 返回参数列表
 */
@interface ReturnParam : NSObject

@property (nonatomic)		  BOOL				   success;         /*!< 是否返回成功 */
@property (nonatomic, strong) NSString*			   failedCode;      /*!< 失败代码 */
@property (strong, nonatomic) NSString*			   failedReason;    /*!< 失败原因 */
@property (strong, nonatomic) NSMutableDictionary* userInfo;        /*!< 附加信息 */

@end

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 请求参数列表
 */
@interface RequestParam : NSObject

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 使用Key获取请求参数
 *  @param aKey 请求参数的Key
 *  @return 请求参数的Value
 */
-(id) objectForKeyedSubscript:(id)key;

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 使用Key设置请求参数
 *  @param obj 请求参数的Value
 *  @param key 请求参数的Key
 */
-(void) setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey;

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 删除所有参数
 */
-(void) removeAllObjects;

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 更新参数
 */
-(void) updateParameters;

/*!
 *  @author LeiQiao, 15-12-14
 *  @brief 将参数转成字典
 *  @return 返回字典
 */
-(NSDictionary*) dictionary;

@end

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 请求模型使用的成功回调方法
 *  @param responseObject 请求的返回对象
 */
typedef void (^BaseRequestModelSuccess)(id responseObject);

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 请求模型使用的失败回调方法
 *  @param error 错误码
 */
typedef void (^BaseRequestModelFailure)(NSError* error);

/*! 请求模型使用的网络调用方法 */
typedef enum {
    BaseRequestModelMethodPost,     /*!< POST方法 */
    BaseRequestModelMethodGet       /*!< GET方法 */
} BaseRequestModelMethod;

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 请求模型
 */
@interface BaseRequestModel : NSObject {
    BaseRequestModelMethod _requestMethod;      /*!< 网络请求方式POST、GET */
    NSString* _requestURLString;                /*!< 请求URI地址 */
    BaseRequestModelSuccess _successCallback;   /*!< 请求成功的回调 */
    BaseRequestModelFailure _failureCallback;   /*!< 请求失败的回调 */
}

@property(nonatomic, assign, readonly) id observeModel;                         /*!< 观察模型 */
@property(nonatomic, assign, readonly) SEL observeCallback;                     /*!< 观察模型的回调方法 */
@property(nonatomic, strong, readonly) RequestParam* reqParam;                  /*!< 请求参数 */
@property(nonatomic, strong, readonly) ReturnParam* retParam;                   /*!< 返回值 */
@property(nonatomic, assign, readonly, getter=isFinished) BOOL finished;        /*!< 请求是否已完成 */
@property(atomic, assign, getter=isWaiting) BOOL wait;                          /*!< 请求玩成功暂停回调，解除等待后才可回调 */
@property(nonatomic, readonly) BaseRequestModelSuccess originSuccessCallback;   /*!< 原始的成功回调 */
@property(nonatomic, readonly) BaseRequestModelFailure originFailureCallback;   /*!< 原始的失败回调 */

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 创建新的请求模型
 *  @param observeModel 观察者模型(BaseModel)
 *  @param observeCallback 观察者方法
 *  @return 请求模型实例
 */
-(instancetype) initWithObserveModel:(id)observeModel andCallback:(SEL)observeCallback;

/*!
 *  @author LeiQiao, 15-12-16
 *  @brief 替换观察模型和观察方法
 *  @param observeModel 观察者模型(BaseModel)
 *  @param observeCallback 观察者方法
 */
-(void) setObserveModel:(id)observeModel andCallback:(SEL)observeCallback;

/*!
 *  @author LeiQiao, 15-12-11
 *  @brief 使用代理替换观察者通知
 *  @param target 代理对象
 *  @param action 代理方法
 */
-(void) replaceObserveWithTarget:(id)target andAction:(SEL)action;

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 观察者通知是否被代理替换
 *  @return 观察者通知是否被代理替换
 */
-(BOOL) isObserveReplaced;

/*!
 *  @author LeiQiao, 15-12-11
 *  @brief 删除代理恢复观察者通知
 *  @param callObserver 是否立刻通知观察者
 */
-(void) restoreObserveModel:(BOOL)callObserver;

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 发送POST请求
 *  @param urlString 请求接口
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
-(void) POST:(NSString*)urlString success:(BaseRequestModelSuccess)success failure:(BaseRequestModelFailure)failure;
-(void) POST:(NSString*)urlString success:(BaseRequestModelSuccess)success;
-(void) POST:(NSString*)urlString;

/*!
 *  @author LeiQiao, 15-12-10
 *  @brief 发送GET请求
 *  @param urlString 请求接口
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
-(void) GET:(NSString*)urlString success:(BaseRequestModelSuccess)success failure:(BaseRequestModelFailure)failure;
-(void) GET:(NSString*)urlString success:(BaseRequestModelSuccess)success;
-(void) GET:(NSString*)urlString;

/*!
 *  @author LeiQiao, 15-12-16
 *  @brief 设置成功的回调
 *  @param successCallback 成功的回调
 */
-(void) setSuccessCallback:(BaseRequestModelSuccess)successCallback;

/*!
 *  @author LeiQiao, 15-12-16
 *  @brief 设置失败的回调
 *  @param failureCallback 失败的回调
 */
-(void) setFailureCallback:(BaseRequestModelFailure)failureCallback;

/*!
 *  @author LeiQiao, 15-12-11
 *  @brief 重新发送请求
 */
-(void) reSend;

/*!
 *  @author LeiQiao, 15-12-11
 *  @brief 抛弃请求
 */
-(void) drop;

#pragma mark - 私有函数，子类必须继承

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 通知观察者
 */
-(void) callObserver;

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 公共函数的POST只做为封装操作，实际网络请求在该函数中执行
 */
-(void) doPOST;

/*!
 *  @author LeiQiao, 15-12-15
 *  @brief 公共函数的GET只做为封装操作，实际网络请求在该函数中执行
 */
-(void) doGET;

@end


