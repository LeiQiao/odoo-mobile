//
//  KanbanRender.h
//

#import <UIKit/UIKit.h>
#import "OdooData.h"

@interface KanbanRender : NSObject

+(void) renderViewMode:(ViewModeData*)viewMode
        forRecordIndex:(NSUInteger)recordIndex
             withWidth:(CGFloat)width
              callback:(void(^)(UIImage*))callback;

@end
