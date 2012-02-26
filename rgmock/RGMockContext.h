//
//  RGMockContext.h
//  rgmock
//
//  Created by Markus Gasser on 26.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//


@interface RGMockContext : NSObject

@property (nonatomic, readonly, copy)   NSString   *fileName;
@property (nonatomic, readonly, assign) NSUInteger  lineNumber;

+ (id)contextWithFileName:(const char *)fileName lineNumber:(NSUInteger)lineNumber;

@end
