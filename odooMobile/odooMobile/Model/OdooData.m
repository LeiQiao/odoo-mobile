//
//  OdooData.m
//

#import "OdooData.h"

NSString* const kKanbanViewModeName = @"kanban";     /*!< 看板显示模式名称 */
NSString* const kListViewModeName = @"list";         /*!< 列表显示模式名称 */
NSString* const kFormViewModeName = @"form";         /*!< 表单显示模式名称 */
NSString* const kSearchViewModeName = @"search";     /*!< 搜索显示模式名称 */

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 窗口数据
 */
@implementation WindowData

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 初始化
 *  @return 本类的实例化对象
 */
-(instancetype) init
{
    if( self = [super init] )
    {
        self.ID = @(0);
        self.name = @"";
        self.displayName = @"";
        self.modelName = @"";
        self.viewModes = @[];
        self.context = @{};
    }
    return self;
}

/*!
 *  @author LeiQiao, 16-05-09
 *  @brief 根据名称获取显示模式
 *  @param viewModeName 显示模式名称
 *  @return 显示模式
 */
-(ViewModeData*) viewModeForName:(NSString*)viewModeName
{
    for( ViewModeData* viewMode in self.viewModes )
    {
        if( [viewMode.name isEqualToString:viewModeName] )
        {
            return viewMode;
        }
    }
    return nil;
}

@end

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 窗口显示模式数据
 */
@implementation ViewModeData

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 初始化
 *  @return 本类的实例化对象
 */
-(instancetype) init
{
    if( self = [super init] )
    {
        self.ID = @"";
        self.name = @"";
        self.displayName = @"";
        self.htmlContext = @"";
        self.fields = @[];
        self.records = [NSMutableArray new];
    }
    return self;
}

/*!
 *  @author LeiQiao, 16/05/08
 *  @brief 根据字段名获取字段属性
 *  @param fieldName 字段名
 *  @return 字段属性
 */
-(FieldData*) fieldForName:(NSString*)fieldName
{
    for( FieldData* field in self.fields )
    {
        if( [field.name isEqualToString:fieldName] )
        {
            return  field;
        }
    }
    return nil;
}

@end

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 字段数据
 */
@implementation FieldData

/*!
 *  @author LeiQiao, 16/05/03
 *  @brief 初始化
 *  @return 本类的实例化对象
 */
-(instancetype) init
{
    if( self = [super init] )
    {
        self.name = @"";
        self.displayName = @"";
        self.readonly = NO;
        self.required = NO;
        self.type = FieldTypeUnknown;
        self.relationModel = @"";
        self.relationField = @"";
    }
    return self;
}

@end
