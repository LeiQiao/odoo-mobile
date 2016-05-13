//
//  KanbanRender.h
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "OdooData.h"

@interface KanbanRender : NSObject

-(instancetype) initWithViewMode:(ViewModeData*)viewMode updateCallback:(void(^)(WKWebView*, NSInteger))callback;

-(void) updateWithWidth:(CGFloat)width;

-(NSUInteger) recordCount;
-(CGFloat) recordHeight:(NSUInteger)index;
-(WKWebView*) recordWebView:(NSUInteger)index;

@end
