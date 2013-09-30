//
//  MCKXCTestFailureHandler.m
//  mocka
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import "MCKXCTestFailureHandler.h"


@implementation MCKXCTestFailureHandler

#pragma mark - Initialization

- (instancetype)initWithTestCase:(XCTestCase *)testCase {
    if ((self = [super init])) {
        _testCase = testCase;
    }
    return self;
}


#pragma mark - Handling Failures

- (void)handleFailureWithReason:(NSString *)reason {
    [(id)self.testCase recordFailureWithDescription:reason inFile:self.fileName atLine:self.lineNumber expected:NO];
}

- (void)recordFailureWithDescription:(NSString *)d inFile:(NSString *)f atLine:(NSUInteger)l expected:(BOOL)e {
}

@end
