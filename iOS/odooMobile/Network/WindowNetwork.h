//
//  WindowNetwork.h
//  odooMobile
//
//  Created by lei.qiao on 16/4/10.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "OdooNetwork.h"

@interface WindowNetwork : OdooNetwork

-(NetworkResponse*) getWindowByID:(NSNumber*)windowID type:(NSString*)windowType;

@end
