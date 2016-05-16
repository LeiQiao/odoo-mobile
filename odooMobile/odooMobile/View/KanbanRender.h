//
//  KanbanRender.h
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "OdooData.h"

@protocol KanbanRenderDelegate;

@interface KanbanRender : NSObject

-(instancetype) initWithViewMode:(ViewModeData*)viewMode;

-(void) updateWithWidth:(CGFloat)width callback:(void(^)())callback;

-(NSUInteger) recordCount;
-(CGFloat) recordHeight:(NSUInteger)index;
-(WKWebView*) recordWebView:(NSUInteger)index;

@end
