//
//  RGMockSyntax.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockSyntax.h"

#import "RGMockRecorder.h"
#import "RGMockClassRecorder.h"
#import "RGMockSpyRecorder.h"

#import "RGMockVerifier.h"


#pragma mark - Creating Mock Objects

id mock_classMock(Class cls) {
    return [RGMockClassRecorder mockRecorderForClass:cls];
}

id mock_spy(id<NSObject> object) {
    return [RGMockSpyRecorder mockRecorderForSpyingObject:object];
}


#pragma mark - Verifying Behavior

id mock_verify_location(id mock, const char *fileName, int lineNumber) {
    RGMockVerifier *verifier = [[RGMockVerifier alloc] initWithRecorder:[mock self]];
    verifier.fileName = [NSString stringWithCString:fileName encoding:NSUTF8StringEncoding];
    verifier.lineNumber = lineNumber;
    return verifier;
}
