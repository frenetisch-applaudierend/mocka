//
//  MCKMockingSyntax.m
//  mocka
//
//  Created by Markus Gasser on 25.9.2013.
//
//

#import "MCKMockingSyntax.h"

#import "MCKMockingContext.h"
#import "MCKMockObject.h"
#import "MCKSpy.h"

#import "MCKTypeDetector.h"


id _mck_createMock(MCKLocation *location, NSArray *items) {
    MCKMockingContext *context = [MCKMockingContext currentContext];
    context.currentLocation = location;
    
    if ([items count] == 1 && [MCKTypeDetector isObject:[items lastObject]]) {
        return mck_createSpyForObject([items lastObject], context);
    } else {
        return [MCKMockObject mockWithContext:context classAndProtocols:items];
    }
}
