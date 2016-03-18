//
//  CXAction.h
//  odooMobile
//
//  Created by lei.qiao on 16/3/16.
//  Copyright © 2016年 LeiQiao. All rights reserved.
//

#ifndef __CXACTION_H__
#define __CXACTION_H__

#ifdef CXACTION_USING_BLOCK

#import "CXAction_block.h"

typedef CXAction_block          CXAction;

#else

#import "CXAction_function.h"
#import "CXServiceAction_function.h"
#import "CXUIAction_function.h"
#import "CXNetworkAction_function.h"

typedef CXAction_function           CXAction;
typedef CXServiceAction_function    CXServiceAction;
typedef CXUIAction_function         CXUIAction;
typedef CXNetworkAction_function    CXNetworkAction;

#endif

#endif /* __CXACTION_H__ */
