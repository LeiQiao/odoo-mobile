//
//  RCTHUD.h
//

#import "CXBaseModule.h"
#import "HUD.h"

/**
 *  @author LeiQiao, 16/04/04
 *  @brief HUD提示框，提供给React-Native使用，功能与HUD.h一样
 */
@interface RCTHUD : CXBaseModule

-(void) popWaiting:(NSString*)message;
-(void) dismissWaiting;
-(void) popSuccess:(NSString*)message;
-(void) popError:(NSString*)message;

@end
