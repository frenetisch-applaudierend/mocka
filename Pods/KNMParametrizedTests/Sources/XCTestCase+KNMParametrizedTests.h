//
//  XCTestCase+KNMParametrizedTests.h
//  konoma-parametrized-tests
//
//  Created by Markus Gasser on 24.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>


@interface XCTestCase (KNMParametrizedTests)

/**
 * Provide parameter data for the test identified by the given selector.
 *
 * The default implementation of this method searches the receiving class for
 * a method whose name matches the pattern +parametersFor<TestName> or
 * +parametersFor_<testName> (note the difference in capitalization),
 * and returns the result of invoking that method if it is found.
 *
 * A parametrized test is executed once for each object in the returned
 * array. If nil or an empty array is returned, the test is skipped.
 *
 * @param selector The selector of the test to pass parameters back.
 * @return The parameters for the given test
 */
+ (NSArray *)parametersForTestWithSelector:(SEL)selector;

@end
