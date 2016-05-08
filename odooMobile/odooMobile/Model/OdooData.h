//
//  OdooData.h
//

#import <Foundation/Foundation.h>

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 窗口数据
 */
@interface WindowData : NSObject

@property(nonatomic, strong) NSNumber* ID;              /*!< 窗口ID */
@property(nonatomic, strong) NSString* name;            /*!< 窗口名称 */
@property(nonatomic, strong) NSString* displayName;     /*!< 窗口显示名称 */
@property(nonatomic, strong) NSString* modelName;       /*!< 模型名称 */
@property(nonatomic, strong) NSArray* viewModes;        /*!< 窗口显示模式 */
@property(nonatomic, strong) NSDictionary* context;     /*!< 窗口配置 */

@end

@class FieldData;
/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 窗口显示模式数据
 */
@interface ViewModeData : NSObject

@property(nonatomic, strong) NSString* ID;              /*!< 窗口显示模式ID */
@property(nonatomic, strong) NSString* name;            /*!< 窗口显示模式名称 */
@property(nonatomic, strong) NSString* displayName;     /*!< 窗口显示模式显示名称 */
@property(nonatomic, strong) NSString* htmlContext;     /*!< 窗口显示模式HTML布局样式 */
@property(nonatomic, strong) NSArray* fields;           /*!< 窗口显示模式字段集 */
@property(nonatomic, strong) NSMutableArray* records;   /*!< 窗口显示模式记录集 */

/*!
 *  @author LeiQiao, 16/05/08
 *  @brief 根据字段名获取字段属性
 *  @param fieldName 字段名
 *  @return 字段属性
 */
-(FieldData*) fieldForName:(NSString*)fieldName;

@end

/** 字段类型 */
typedef enum {
    FieldTypeUnknown,           /*!< 未知字段类型 */
    FieldTypeText,              /*!< 文本字段 */
    FieldTypeChar,              /*!< 单个字符字段 */
    FieldTypeBoolean,           /*!< 布尔字段 */
    FieldTypeInteger,           /*!< 数字型字段 */
    FieldTypeDouble,            /*!< 双精度字段 */
    FieldTypeBinary,            /*!< 二进制字段 */
    FieldTypeSelection,         /*!< 选择项字段 */
    FieldTypeRelatedToModel,    /*!< Many2One字段，例如：一个产品只能有一个计量单位 */
    FieldTypeRelatedToField,    /*!< One2Many字段，例如：一个产品可以有多个供应商 */
} FieldType;

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 字段数据
 */
@interface FieldData : NSObject

@property(nonatomic, strong) NSString* name;            /*!< 字段名称 */
@property(nonatomic, strong) NSString* displayName;     /*!< 字段显示名称 */
@property(nonatomic)         BOOL readonly;             /*!< 字段是否只读 */
@property(nonatomic)         BOOL required;             /*!< 字段是否必填 */
@property(nonatomic)         FieldType type;            /*!< 字段类型 */
@property(nonatomic, strong) NSString* relationModel;   /*!< 字段相关模型 */
@property(nonatomic, strong) NSString* relationField;   /*!< 字段相关字段 */

@end
