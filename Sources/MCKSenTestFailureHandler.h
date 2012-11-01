//
//  MCKSenTestFailureHandler.h
//  mocka
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKFailureHandler.h"


@interface MCKSenTestFailureHandler : NSObject <MCKFailureHandler>

@property (nonatomic, readonly, weak) id testCase;

- (id)initWithTestCase:(id)testCase;

@end
