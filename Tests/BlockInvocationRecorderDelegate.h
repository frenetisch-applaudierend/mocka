//
//  BlockInvocationRecorderDelegate.h
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKInvocationRecorder.h"


@interface BlockInvocationRecorderDelegate : NSObject <MCKInvocationRecorderDelegate>

@property (nonatomic, copy) void(^onRecordInvocation)(NSInvocation *invocation);

@end
