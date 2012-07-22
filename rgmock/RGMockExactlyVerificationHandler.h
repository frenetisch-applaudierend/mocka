//
//  RGMockExactlyVerificationHandler.h
//  rgmock
//
//  Created by Markus Gasser on 22.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockVerificationHandler.h"


@interface RGMockExactlyVerificationHandler : NSObject <RGMockVerificationHandler>

+ (id)exactlyHandlerWithCount:(NSUInteger)count;
- (id)initWithCount:(NSUInteger)count;

@end


// Mocking Syntax
#define mock_exactly(count) mock_set_verification_handler([RGMockExactlyVerificationHandler exactlyHandlerWithCount:(count)])
#define mock_once mock_exactly(1)

#ifndef MOCK_DISABLE_NICE_SYNTAX
#define exactly(count) mock_exactly((count))
#define once mock_once
#endif
