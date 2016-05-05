//
//  ArchView.h
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"

/*!
 *  @author LeiQiao, 16/05/01
 *  @brief XML文件转换成View
 */
@interface ArchView : NSObject {
    NSString* _tagName;         /*!< TAG名称 */
    NSString* _styleNames;      /*!< 样式表 */
    NSString* _name;            /*!< ID名称 */
    NSMutableArray* _children;  /*!< 子窗口 */
}

@property(nonatomic) CGRect frame;                      /*!< 窗口尺寸 */
@property(nonatomic, strong, readonly) UIView* view;    /*!< UIView的窗口 */

/*!
 *  @author LeiQiao, 16/05/01
 *  @brief 使用XML的字符串创建View
 *  @param archString XML字串
 *  @return 返回创建的View
 */
+(instancetype) viewWithArchString:(NSString*)archString;

/*!
 *  @author LeiQiao, 16/05/01
 *  @brief 解析XML标签内容
 *  @param element XML标签
 */
-(void) parseElement:(GDataXMLElement*)element;

@end

///////////////////////////////////////////////////  Common  ///////////////////////////////////////////////////

/*---------- <div> ----------*/
@interface ArchView_Div : ArchView
@end

/*---------- <span> ----------*/
@interface ArchView_Span : ArchView
@end

/*---------- <strong> ----------*/
@interface ArchView_Strong : ArchView
@end

/*---------- <ul> ----------*/
@interface ArchView_UL : ArchView
@end

/*---------- <li> ----------*/
@interface ArchView_LI : ArchView
@end

/*---------- <img> ----------*/
@interface ArchView_Img : ArchView
@end

/*---------- Text, (no tag) ----------*/
@interface ArchView_Text : ArchView
@end

///////////////////////////////////////////////////  Odoo  ///////////////////////////////////////////////////

/*---------- <kanban> ----------*/
@interface ArchView_Kanban : ArchView
@end

/*---------- <templates> ----------*/
@interface ArchView_Templates : ArchView
@end

/*---------- <t> ----------*/
@interface ArchView_T : ArchView
@end

/*---------- <field> ----------*/
@interface ArchView_Field : ArchView
@end



