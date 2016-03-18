//
//  CXNetworkAction_function.h
//

#import "CXAction_function.h"

/*!
 *  @author LeiQiao, 16-03-18
 *  @brief 接口类动作，处理接口的调用与结果的处理，动作序列化中后退时直接跳转到上一个动作，当接口调用失败时也要返回上一个动作
 */
@interface CXNetworkAction_function : CXAction_function

@end
