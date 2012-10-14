//
//  EditableInvocationRecorder.h
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKInvocationRecorder.h"

@interface CannedInvocationRecorder : MCKInvocationRecorder

@property (nonatomic, copy) NSIndexSet *cannedResult;

- (id)initWithCannedResult:(NSIndexSet *)indexSet;

@end
