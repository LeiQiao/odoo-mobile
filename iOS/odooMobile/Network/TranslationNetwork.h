//
//  TranslationNetwork.h
//

#import "OdooNetwork.h"

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 翻译相关的网络通讯
 */
@interface TranslationNetwork : OdooNetwork

/*!
 *  @author LeiQiao, 16-04-10
 *  @brief 翻译Model中的某个字段，根据Model项的id与翻译表中的src_id对应
 *  @param srcItems  要翻译的内容采用[{'id':'xxx', 'field':'value', ...}, ...]结构
 *  @param fieldName 要翻译的字段名
 *  @param modelName 要翻译的模块
 *  @return 翻译结果
 */
-(NetworkResponse*) translate:(NSArray*)srcItems fieldName:(NSString*)fieldName inModel:(NSString*)modelName;

@end
