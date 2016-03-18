//
//  CXServiceAction_function.m
//

#import "CXServiceAction_function.h"

/*!
 *  @author LeiQiao, 16-03-18
 *  @brief 服务类动作，提供后台服务功能，动作序列化时直接跳转到上／下一个动作
 */
@implementation CXServiceAction_function

/*!
 *  @author LeiQiao, 16-03-16
 *  @brief 服务类动作进入时不会逗留，直接跳转到下一个动作
 */
-(void) onEnter
{
    [super onEnter];
    
    [self next];
}

/*!
 *  @author LeiQiao, 16-03-16
 *  @brief 服务类动作回退时不会逗留，直接跳转到上一个动作
 */
-(void) onReverse
{
    [super onReverse];
    
    [self back];
}

@end
