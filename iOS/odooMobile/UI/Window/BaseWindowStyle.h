//
//  BaseWindowStyle.h
//

#import <Foundation/Foundation.h>

/*!
 窗口字段的样式，文字、输入框、按钮等样式
 */
typedef enum {
    WindowFieldStyleVirtual = 0,    /*!< 虚拟样式，该样式不会显示 */
    WindowFieldStyleImage,          /*!< 照片样式 */
    WindowFieldStyleButton,         /*!< 按钮样式 */
    WindowFieldStyleLabel,          /*!< 文字样式 */
    WindowFieldStylePicker,         /*!< 选项样式 */
    WindowFieldStyleCheck,          /*!< 检查框样式 */
    WindowFieldStyleTextField,      /*!< 输入框样式 */
    WindowFieldStyleTextView,       /*!< 备注样式 */
    WindowFieldStyleExtView,        /*!< 扩展窗口样式 */
} WindowFieldStyle;

/*!
 *  @author LeiQiao, 16-04-18
 *  @brief 窗口的字段描述
 */
@interface WindowField : NSObject

@property(nonatomic, readonly) WindowFieldStyle style;          /*!< 字段样式 */
@property(nonatomic, strong, readonly) NSString* className;     /*!< 字段种类 */
@property(nonatomic, strong, readonly) NSString* name;          /*!< 字段名称 */
@property(nonatomic, strong, readonly) NSMutableDictionary* attributes;   /*!< 字段属性 */
@property(nonatomic, readonly) NSInteger flat;                  /*!< 字段宽度 */
@property(nonatomic, strong) id value;                          /*!< 字段值 */
@property(nonatomic)            BOOL hidden;                    /*!< 隐藏字段 */

@end


/*!
 字段布局的排列方式
 */
typedef enum {
    WindowLayoutStyleHorizontal,    /*!< 横向排列 */
    WindowLayoutStyleVertical,      /*!< 纵向排列 */
} WindowLayoutStyle;

/*!
 *  @author LeiQiao, 16-04-18
 *  @brief 窗口布局，可以为字段进行布局，也可以包含子布局，当两个值同时有值时先布局字段
 */
@interface WindowLayout : NSObject

@property(nonatomic, readonly) WindowLayoutStyle style;             /*!< 窗口布局排列方式 */
@property(nonatomic, strong, readonly) NSMutableArray* fieldNames;  /*!< 需要布局的字段名称 */
@property(nonatomic, strong, readonly) NSMutableArray* subLayouts;  /*!< 子布局 */

@end

/*!
 窗口信息表样式
 */
typedef enum {
    WindowStyleKanban,  /*!< 看板样式 */
    WindowStyleList,    /*!< 列表样式 */
    WindowStyleForm,    /*!< 表单样式 */
} WindowStyle;

/*!
 *  @author LeiQiao, 16-04-18
 *  @brief 窗口基础样式表
 */
@interface BaseWindowStyle : NSObject

@property(nonatomic, readonly) WindowStyle style;                       /*!< 窗口样式表样式 */
@property(nonatomic, strong, readonly) NSMutableArray* subLayouts;      /*!< 子布局，该布局为垂直方式 */
@property(nonatomic, strong, readonly) NSMutableArray* fields;          /*!< 窗口字段 */

/*!
 *  @author LeiQiao, 16-04-18
 *  @brief 解析窗口布局样式
 *  @param windowData 窗口布局数据
 *  @return 窗口样式表
 */
+(BaseWindowStyle*) windowFromWindowData:(NSString*)windowData;

@end
