//
//  KNMNilValue.m
//  KNMParametrizedTests
//
//  Created by Markus Gasser on 24.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "KNMParametrizedTestsValues.h"


#pragma mark - Nil Value Class

@interface KNMNilValue : NSObject @end
@implementation KNMNilValue

+ (instancetype)nilValue
{
    static KNMNilValue *nilValue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nilValue = [[KNMNilValue alloc] init];
    });
    return nilValue;
}

@end


#pragma mark - Value Helper Methods

id _knm_nilValue(void)
{
    return [KNMNilValue nilValue];
}
