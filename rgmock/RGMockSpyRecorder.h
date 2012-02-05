//
//  RGMockSpyRecorder.h
//  rgmock
//
//  Created by Markus Gasser on 05.02.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockRecorder.h"

@interface RGMockSpyRecorder : RGMockRecorder

+ (id)mockRecorderForSpyingObject:(id)object;
- (id)initWithObject:(id)object;

@end
