//
//  OdooRequestModel.h
//

#import "ModelObserver.h"

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief Odoo的请求参数列表
 */
@interface OdooRequestParam : RequestParam

@property(nonatomic) NSUInteger timeout;                    /*!< 超时时间（默认30秒） */
@property(nonatomic, strong, readonly) NSString* method;    /*!< 命令方法 */
@property(nonatomic, strong, readonly) NSArray* parameters; /*!< 参数 */

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief 创建网络请求
 *  @param method     方法
 *  @param parameters 参数
 */
+(OdooRequestParam*) execute:(NSString*)method
                  parameters:(NSArray*)parameters;

@end

/*!
 *  @author LeiQiao, 16/04/23
 *  @brief 包装了Odoo的XMLRPC的传输方式
 */
@interface OdooRequestModel : BaseRequestModel

@property(nonatomic, strong) OdooRequestParam* reqParam;  /*!< 请求参数 */

@end
