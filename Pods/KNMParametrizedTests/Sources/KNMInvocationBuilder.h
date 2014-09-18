//
//  KNMInvocationBuilder.h
//  KNMParametrizedTests
//
//  Created by Markus Gasser on 24.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KNMInvocationBuilder : NSObject

+ (instancetype)builder;

- (NSInvocation *)buildTestInvocationForSelector:(SEL)selector inClass:(Class)cls withParameter:(id)parameter;

@end
