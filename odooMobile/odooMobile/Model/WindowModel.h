//
//  WindowModel.h
//

#import "ModelObserver.h"

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 窗口模型
 */
@interface WindowModel : BaseModel

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 更新指定窗口
 *  @param windowID 窗口ID
 */
-(void) updateWindowByID:(NSNumber*)windowID;

@end

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 窗口模型监听协议
 */
@protocol WindowModelObserver <BaseModelObserver>

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 更新指定窗口结果
 *  @param windowModel 窗口模型
 *  @param params      返回参数
 *         params[@"WindowID"]     窗口ID
 *         params[@"Window"]       窗口
 */
-(void) windowModel:(WindowModel*)windowModel updateWindowByID:(ReturnParam*)params;

@end
