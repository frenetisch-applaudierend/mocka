//
//  HCBlockMatcher.h
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCMatcher.h"


@interface HCBlockMatcher : NSObject <HCMatcher>

@property (nonatomic, copy) BOOL(^matcherBlock)(id candidate);

+ (id)matcherWithBlock:(BOOL(^)(id candidate))block;

@end
