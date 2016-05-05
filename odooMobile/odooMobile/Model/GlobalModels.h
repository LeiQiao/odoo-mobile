//
//  GlobalModels.h
//

#import "GlobalModelsDefine.h"
#import "UserModel.h"
#import "MenuModel.h"
#import "TranslateModel.h"
#import "WindowModel.h"
#import "RecordModel.h"

BEGIN_DEFINE_GLOBALMODEL()

DEFINE_NEW_GLOBALMODEL(UserModel)                       /*!< 用户模型 */
DEFINE_NEW_GLOBALMODEL(MenuModel)                       /*!< 菜单模型 */
DEFINE_NEW_GLOBALMODEL(TranslateModel)                  /*!< 翻译模型 */
DEFINE_NEW_GLOBALMODEL(WindowModel)                     /*!< 窗口模型 */
DEFINE_NEW_GLOBALMODEL(RecordModel)                     /*!< 记录模型 */

END_DEFINE_GLOBALMODEL()

