//
//  DummyArgumentMatcher.h
//  rgmock
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGMockArgumentMatcher.h"


@interface DummyArgumentMatcher : NSObject <RGMockArgumentMatcher>

@property (nonatomic, copy) BOOL(^matcherImplementation)(id candidate);

@end
