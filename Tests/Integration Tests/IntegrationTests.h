//
//  IntegrationTests.h
//  Integration Tests
//
//  Created by Markus Gasser on 14.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCHamcrest/OCHamcrest.h>
#import <KNMParametrizedTests/KNMParametrizedTests.h>
#import <Mocka/Mocka.h>

#define CreateTestObject(CLS) ((CLS *)[self newTestObjectForClass:[CLS class]])


@interface IntegrationTests_Common : XCTestCase

- (id)newTestObjectForClass:(Class)cls;

@end

@interface IntegrationTests_MockObjects : IntegrationTests_Common
@end

@interface IntegrationTests_Spies : IntegrationTests_Common
@end
