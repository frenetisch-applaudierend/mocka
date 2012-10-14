//
//  DummyArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 10.09.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKArgumentMatcher.h"


@interface BlockArgumentMatcher : NSObject <MCKArgumentMatcher>

@property (nonatomic, copy) BOOL(^matcherImplementation)(id candidate);

@end
