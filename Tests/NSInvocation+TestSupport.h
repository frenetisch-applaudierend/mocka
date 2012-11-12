//
//  NSInvocation+TestSupport.h
//  mocka
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSInvocation (TestSupport)

+ (id)invocationForTarget:(id)target selectorAndArguments:(SEL)selector, ...;
+ (id)voidMethodInvocationForTarget:(id)target;

#pragma mark - Convenience Getters

- (int)intArgumentAtIndex:(NSInteger)index;
- (unsigned int)unsignedIntArgumentAtIndex:(NSInteger)index;
- (const char *)cStringArgumentAtIndex:(NSInteger)index;
- (void *)pointerArgumentAtIndex:(NSInteger)index;

@end
