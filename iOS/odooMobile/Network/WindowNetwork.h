//
//  WindowNetwork.h
//

#import "OdooNetwork.h"

@interface WindowNetwork : OdooNetwork

-(NetworkResponse*) getWindowByID:(NSNumber*)windowID type:(NSString*)windowType;

@end
