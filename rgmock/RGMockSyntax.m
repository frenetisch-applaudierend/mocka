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

id mock_verify(RGMockContext *context, id mock) {
    RGMockVerifier *verifier = [[RGMockVerifier alloc] initWithRecorder:[mock self]];
    verifier.fileName = context.fileName;
    verifier.lineNumber = context.lineNumber;
    return verifier;
}
