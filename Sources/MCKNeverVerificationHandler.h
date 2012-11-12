//
//  MCKNeverVerificationHandler.h
//  mocka
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerificationHandler.h"


@interface MCKNeverVerificationHandler : NSObject <MCKVerificationHandler>

+ (id)neverHandler;

@end


// Mocking Syntax
#define mck_never mck_setVerificationHandler([MCKNeverVerificationHandler neverHandler])

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define never mck_never
#endif
