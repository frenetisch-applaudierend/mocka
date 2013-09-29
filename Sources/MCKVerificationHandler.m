//
//  MCKVerificationHandler.m
//  Framework
//
//  Created by Markus Gasser on 27.9.2013.
//
//

#import "MCKVerificationHandler.h"

#import "MCKMockingContext.h"


@implementation MCKVerificationResult

#pragma mark - Initialization

+ (instancetype)successWithMatchingIndexes:(NSIndexSet *)matches {
    return [[self alloc] initWithSuccess:YES failureReason:nil matchingIndexes:matches];
}

+ (instancetype)failureWithReason:(NSString *)reason matchingIndexes:(NSIndexSet *)matches {
    return [[self alloc] initWithSuccess:NO failureReason:reason matchingIndexes:matches];
}

- (instancetype)initWithSuccess:(BOOL)success failureReason:(NSString *)failureReason matchingIndexes:(NSIndexSet *)matches {
    if ((self = [super init])) {
        _success = success;
        _failureReason = [failureReason copy];
        _matchingIndexes = (matches != nil ? [matches copy] : [NSIndexSet indexSet]);
    }
    return self;
}

@end


#pragma mark - Getting or Setting Verification Handlers

id<MCKVerificationHandler> _mck_getVerificationHandler(void) {
    return [[MCKMockingContext currentContext] verificationHandler];
}

void _mck_setVerificationHandler(id<MCKVerificationHandler> handler) {
    [[MCKMockingContext currentContext] setVerificationHandler:handler];
}
