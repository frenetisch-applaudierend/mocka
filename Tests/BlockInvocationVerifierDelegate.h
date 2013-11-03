//
//  BlockInvocationVerifierDelegate.h
//  mocka
//
//  Created by Markus Gasser on 3.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCKInvocationVerifier.h"


@interface BlockInvocationVerifierDelegate : NSObject <MCKInvocationVerifierDelegate>

@property (nonatomic, copy) void(^onFailure)(NSString *reason);
@property (nonatomic, copy) void(^onFinish)(void);
@property (nonatomic, copy) void(^onWillProcessTimeout)(void);
@property (nonatomic, copy) void(^onDidProcessTimeout)(void);

@end
