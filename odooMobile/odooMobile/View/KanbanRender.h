//
//  KanbanRender.h
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "OdooData.h"

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 看板样式的渲染器
 */
@interface KanbanRender : NSObject

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 使用窗口显示模式初始化渲染器
 *  @param viewMode 窗口显示模式
 *  @return 新建的渲染器
 */
-(instancetype) initWithViewMode:(ViewModeData*)viewMode;

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 更新记录
 *  @param width    记录窗口的宽度
 *  @param callback 更新完毕后的回调
 */
-(void) updateWithWidth:(CGFloat)width callback:(void(^)())callback;

#pragma mark - for UITableView

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 获取记录的个数
 *  @return 返回记录的个数
 */
-(NSUInteger) recordCount;

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 获取某条记录窗口的高度
 *  @param index 记录的索引
 *  @return 某条记录窗口的高度
 */
-(CGFloat) recordHeight:(NSUInteger)index;

/*!
 *  @author LeiQiao, 16/05/16
 *  @brief 获取记录的窗口
 *  @param index 记录的索引
 *  @return 记录的窗口
 */
-(WKWebView*) recordWebView:(NSUInteger)index;

@end
