//
//  EditableInvocationRecorder.h
//  mocka
//
//  Created by Markus Gasser on 06.10.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import "MCKInvocationCollection.h"

@interface CannedInvocationCollection : MCKInvocationCollection

@property (nonatomic, copy) NSIndexSet *cannedResult;

- (id)initWithCannedResult:(NSIndexSet *)indexSet;

@end
