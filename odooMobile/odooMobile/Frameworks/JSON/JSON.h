//
//  JSON.h
//  SUPAY
//
//  Created by LeiQiao on 15/9/21.
//  Copyright (c) 2015年 chinapnr.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* JSONString(id object);
id objectFromJSONString(NSString* jsonString);


@interface NSObject (JSON)

-(NSString*) JSONString;
-(id) objectFromJSONString;

@end
