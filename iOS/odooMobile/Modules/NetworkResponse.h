//
//  NetworkResponse.h
//

#import <Foundation/Foundation.h>

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 网络响应结果类
 */
@interface NetworkResponse : NSObject

@property(nonatomic) BOOL success;                      /*!< 是否成功 */
@property(nonatomic, strong) NSString* failedReason;    /*!< 失败原因 */

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 初始化网络响应类
 *  @param success      是否成功
 *  @param failedReason 失败原因
 *  @return 本类的实例对象
 */
-(instancetype) initWithSuccess:(BOOL)success andFailedReason:(NSString*)failedReason;

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 设置请求成功和成功的提示
 *  @param message 成功的提示消息
 */
-(void) setSuccessAndMessage:(NSString*)message;

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 设置请求失败和失败的消息
 *  @param failedReason 失败的提示消息
 */
-(void) setFailedAndReason:(NSString*)failedReason;

/**
 *  @author LeiQiao, 16/04/03
 *  @brief 将响应转换成字典以供React-Native调用，字典的key为该类的property，value为property的value
 *  @return 字典对象
 */
-(NSDictionary*) dictionary;

@end
