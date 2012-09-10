//
//  NSInvocation+TestSupport.h
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@interface NSInvocation (TestSupport)

+ (id)invocationForTarget:(id)target selectorAndArguments:(SEL)selector, ...;


#pragma mark - Convenience Getters

- (int)intArgumentAtIndex:(NSInteger)index;
- (unsigned int)unsignedIntArgumentAtIndex:(NSInteger)index;
- (const char *)cStringArgumentAtIndex:(NSInteger)index;
- (void *)pointerArgumentAtIndex:(NSInteger)index;

@end
