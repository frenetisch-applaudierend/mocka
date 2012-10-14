//
//  MCKInvocationMatcher.h
//  mocka
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MCKInvocationMatcher : NSObject

- (BOOL)invocation:(NSInvocation *)candidate matchesPrototype:(NSInvocation *)prototype withPrimitiveArgumentMatchers:(NSArray *)matchers;

@end
