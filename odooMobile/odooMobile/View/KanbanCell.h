//
//  KanbanCell.h
//

#import <UIKit/UIKit.h>
#import "OdooData.h"


@protocol KanbanCellDelegate;

/*!
 *  @author LeiQiao, 16-05-03
 *  @brief 看板项
 */
@interface KanbanCell : UITableViewCell

@property(nonatomic, weak) id<KanbanCellDelegate> delegate; /*!< 看板消息回调对象 */

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 使用记录更新看板项
 *  @param record   记录
 *  @param viewMode 看板数据
 */
-(void) setRecord:(NSDictionary*)record viewMode:(ViewModeData*)viewMode;

@end

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 看板项消息回调协议
 */
@protocol KanbanCellDelegate <NSObject>

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 看板项刷新高度
 *  @param cell   看板项
 *  @param height 新的看板项的高度
 */
-(void) kanbanCell:(KanbanCell*)cell didUpdateHeight:(CGFloat)height;

@end
