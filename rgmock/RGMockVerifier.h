//
//  RGMockVerifier.h
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

@class RGMockRecorder;


@interface RGMockVerifier : NSObject

@property (nonatomic, readwrite, copy)   NSString   *fileName;
@property (nonatomic, readwrite, assign) NSUInteger  lineNumber;

- (id)initWithRecorder:(RGMockRecorder *)recorder;

@end
