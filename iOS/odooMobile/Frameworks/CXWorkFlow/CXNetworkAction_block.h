//
//  CXNetworkAction_block.h
//

#import "CXAction_block.h"


typedef void(^CXNetworkActionMethod)(CXAction_block* action, id responseObject);

/*!
 *  @author LeiQiao, 16-03-16
 *  @brief 网络请求动作
 */
@interface CXNetworkAction_block : CXAction_block

@property(nonatomic, copy) CXNetworkActionMethod onRequestFinished;  /*!< 网络请求结果的回调 */

@end
