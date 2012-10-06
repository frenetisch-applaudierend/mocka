//
//  EditableInvocationRecorder.h
//  rgmock
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockInvocationRecorder.h"

@interface CannedInvocationRecorder : RGMockInvocationRecorder

@property (nonatomic, copy) NSIndexSet *cannedResult;

- (id)initWithCannedResult:(NSIndexSet *)indexSet;

@end
