//
//  ModelsDefine.h
//
//  Created by apple on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @author LeiQiao, 15-11-24
 *  @brief  将变量为null转换为nil，防止调用崩溃
 *  @param obj 变量
 *  @return 安全变量
 */
NS_INLINE id SafeValue(id obj){return ([obj isKindOfClass:[NSNull class]])?nil:obj;}

/*!
 *  @author LeiQiao, 15-11-24
 *  @brief  对字符串进行安全拷贝（不能是nil或者null）
 *  @param str 字符串
 *  @return 安全字符串
 */
NS_INLINE NSString* SafeCopy(NSString* str){return SafeValue(str)?str:@"";}


/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 开始声明全局模型标志, 写在 .h 文件中
 */
#define BEGIN_DEFINE_GLOBALMODEL() \
    @interface GlobalModels : NSObject \
    +(GlobalModels*) getGlobalModelsInstance; \

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 结束声明全局模型标志, 写在 .h 文件中
 */
#define END_DEFINE_GLOBALMODEL() \
    @end \

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 声明一个全局模型类, 写在 .h 文件中
 *  @param modelName 模型类类名
 */
#define DEFINE_NEW_GLOBALMODEL(modelName)	\
    @property(nonatomic, strong, readonly, getter=getP##modelName) modelName* p##modelName; \

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 开始定义全局模型标志, 写在 .m 文件中
 */
#define BEGIN_DECLARE_GLOBALMODEL() \
    @implementation GlobalModels \
    +(GlobalModels*) getGlobalModelsInstance \
    { \
        static GlobalModels* g_defaultGlobalModels = nil; \
        if( g_defaultGlobalModels == nil ) \
        { \
            g_defaultGlobalModels = [[GlobalModels alloc] init]; \
        } \
        return g_defaultGlobalModels; \
    } \

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 结束定义全局模型标志, 写在 .m 文件中
 */
#define END_DECLARE_GLOBALMODEL() \
    @end \

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 定义一个全局模型类, 写在 .m 文件中
 *  @param modelName 模型类类名
 */
#define DECLARE_NEW_GLOBALMODEL(modelName) \
    @synthesize p##modelName = _p##modelName; \
    -(modelName*) getP##modelName \
    { \
        if( _p##modelName == nil ) {_p##modelName = [[modelName alloc] init];} \
        return _p##modelName; \
    } \

/*!
 *  @author LeiQiao, 16-04-22
 *  @brief 获取一个全局模型的对象
 *  @param modelName 模型类类名
 *  @return 返回一个全局模型的对象
 */
#define GETMODEL(modelName) ([GlobalModels getGlobalModelsInstance].p##modelName)