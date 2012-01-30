//
//  RGMockSyntax.m
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockSyntax.h"
#import "RGMockRecorder.h"
#import "RGClassMockRecorder.h"


id mock_classMock(Class cls) {
    return [[RGClassMockRecorder alloc] initWithClass:cls];
}

id mock_verify_location(id mock, const char *fileName, int lineNumber) {
    
    return nil;
}
