//
//  MCKBlockArgumentMatcher.h
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCKArgumentMatcher.h"


@interface MCKBlockArgumentMatcher : NSObject <MCKArgumentMatcher>

@property (nonatomic, copy) BOOL(^matcherBlock)(id candidate);

- (id)initWithMatcherBlock:(BOOL(^)(id candidate))matcherBlock;

@end
