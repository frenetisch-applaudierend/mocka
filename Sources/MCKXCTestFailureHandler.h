//
//  MCKXCTestFailureHandler.h
//  Framework
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import <Foundation/Foundation.h>
#import "MCKFailureHandler.h"


@class XCTestCase;


@interface MCKXCTestFailureHandler : MCKFailureHandler

- (instancetype)initWithTestCase:(XCTestCase *)testCase;

@property (nonatomic, readonly) XCTestCase *testCase;

@end
