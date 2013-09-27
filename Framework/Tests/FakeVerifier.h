//
//  FakeVerifier.h
//  mocka
//
//  Created by Markus Gasser on 16.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKVerifier.h"


@interface FakeVerifier : NSObject <MCKVerifier>

@property (nonatomic, readonly) NSInvocation *lastPassedInvocation;
@property (nonatomic, readonly) MCKArgumentMatcherCollection *lastPassedMatchers;
@property (nonatomic, readonly) NSMutableArray *lastPassedRecordedInvocations;

- (id)initWithNewContextMode:(MCKContextMode)mode;

@end
