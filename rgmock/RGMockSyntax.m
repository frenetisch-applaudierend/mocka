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
#import "RGMockVerifier.h"


id mock_classMock(Class cls) {
    return [[RGMockClassRecorder alloc] initWithClass:cls];
}

id mock_verify_location(id mock, const char *fileName, int lineNumber) {
    RGMockVerifier *verifier = [[RGMockVerifier alloc] initWithRecorder:mock];
    verifier.fileName = [NSString stringWithCString:fileName encoding:NSUTF8StringEncoding];
    verifier.lineNumber = lineNumber;
    return verifier;
}
