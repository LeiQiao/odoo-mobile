//
//  RecordModel.h
//

#import "ModelObserver.h"
#import "OdooData.h"

/*!
 *  @author LeiQiao, 16/05/02
 *  @brief 记录模型
 */
@interface RecordModel : BaseModel

/*!
 *  @author LeiQiao, 16/05/02
 *  @brief 获取某个窗口中的纪录
 *  @param viewMode 窗口显示模式
 */
-(void) requestMoreRecord:(WindowData*)window viewMode:(ViewModeData*)viewMode;

@end

/*!
 *  @author LeiQiao, 16/05/02
 *  @brief 记录模型监控协议
 */
@protocol RecordModelObserver <BaseModelObserver>

/*!
 *  @author LeiQiao, 16/05/02
 *  @brief 获取某个模块中的纪录结果
 *  @param recordModel 记录模型
 *  @param params      返回参数
 *         params[@"Window"]     窗口信息
 *         params[@"viewMode"]   窗口显示模式
 */
-(void) recordModel:(RecordModel*)recordModel requestMoreRecord:(ReturnParam*)params;

@end




