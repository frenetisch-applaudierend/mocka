//
//  RGClassMockObject.h
//  rgmock
//
//  Created by Markus Gasser on 30.01.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockRecorder.h"


@interface RGMockClassRecorder : RGMockRecorder

+ (id)mockRecorderForClass:(Class)cls;

- (id)initWithClass:(Class)cls;

@end
