//
//  RGMockContext.m
//  rgmock
//
//  Created by Markus Gasser on 26.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockContext.h"

@implementation RGMockContext

#pragma mark - Properties

@synthesize fileName = _fileName;
@synthesize lineNumber = _lineNumber;


#pragma mark - Initialization

+ (id)contextWithFileName:(const char *)fileName lineNumber:(NSUInteger)lineNumber {
    NSString *fileNameString = [NSString stringWithCString:fileName encoding:NSUTF8StringEncoding];
    return [[self alloc] initWithFileName:fileNameString lineNumber:lineNumber];
}

- (id)initWithFileName:(NSString *)fileName lineNumber:(NSUInteger)lineNumber {
    if ((self = [super init])) {
        _fileName = [fileName copy];
        _lineNumber = lineNumber;
    }
    return self;
}

@end
