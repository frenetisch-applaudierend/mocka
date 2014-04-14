//
//  IntegrationTests.m
//  Integration Tests
//
//  Created by Markus Gasser on 14.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "IntegrationTests.h"


@implementation IntegrationTests_Common

#pragma mark - Abstract Test Support

+ (NSArray *)testInvocations
{
    // make sure we don't execute the test base
    if (self == [IntegrationTests_Common class]) {
        return @[];
    } else {
        return [super testInvocations];
    }
}

- (id)newTestObjectForClass:(Class)cls
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"You must override this method" userInfo:nil];
}

@end


@implementation IntegrationTests_MockObjects

- (id)newTestObjectForClass:(Class)cls
{
    return mock(cls);
}

@end


@implementation IntegrationTests_Spies

- (id)newTestObjectForClass:(Class)cls
{
    id object = [[cls alloc] init];
    spy(object);
    return object;
}

@end
