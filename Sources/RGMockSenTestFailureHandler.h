//
//  RGMockSenTestFailureHandler.h
//  rgmock
//
//  Created by Markus Gasser on 05.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockFailureHandler.h"

@interface RGMockSenTestFailureHandler : NSObject <RGMockFailureHandler>

- (id)initWithTestCase:(id)testCase;

@end
