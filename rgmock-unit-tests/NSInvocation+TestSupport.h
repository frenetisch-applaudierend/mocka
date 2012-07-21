//
//  NSInvocation+TestSupport.h
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@interface NSInvocation (TestSupport)

+ (id)invocationForTarget:(id)target selectorAndArguments:(SEL)selector, ...;

@end
