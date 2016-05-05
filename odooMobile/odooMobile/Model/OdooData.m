//
//  OdooData.m
//

#import "OdooData.h"

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
