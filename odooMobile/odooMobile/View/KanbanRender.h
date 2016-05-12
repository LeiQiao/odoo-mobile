//
//  KanbanRender.h
//

#import <UIKit/UIKit.h>
#import "OdooData.h"

@interface KanbanRender : NSObject

-(instancetype) initWithViewMode:(ViewModeData*)viewMode readyCallback:(void(^)())readyCallback;
-(UIImage*) renderRecord:(NSUInteger)index withWidth:(CGFloat)width;

@end
