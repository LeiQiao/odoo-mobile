//
//  TranslateModel.h
//

#import "ModelObserver.h"
#import "OdooRequestModel.h"

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 翻译Model中的某个字段，根据Model项的id与翻译表中的src_id对应
 *  @param request   请求对象
 *  @param srcItems  要翻译的内容采用[{'id':'xxx', 'field':'value', ...}, ...]结构
 *  @param fieldName 要翻译的字段名
 *  @param modelName 要翻译的模块
 *  @param error     错误对象指针
 *  @return 翻译结果
 */
extern id asyncTranslateFields(OdooRequestModel* request, NSArray* srcItems, NSString* fieldName, NSString* modelName, NSError** error);

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 翻译Model中的名称
 *  @param request   请求对象
 *  @param srcItems  要翻译的内容采用['src1', 'src2', ...]结构
 *  @param fieldName 要翻译的字段名
 *  @param modelName 要翻译的模块
 *  @param error     错误对象指针
 *  @return 翻译结果
 */
extern id asyncTranslateNames(OdooRequestModel* request, NSArray* srcItems, NSString* fieldName, NSString* modelName, NSError** error);

/*!
 *  @author LeiQiao, 16-04-26
 *  @brief 翻译模型
 */
@interface TranslateModel : BaseModel

@end
