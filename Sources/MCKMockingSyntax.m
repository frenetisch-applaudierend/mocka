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


id _mck_createMock(MCKLocation *location, NSArray *entities)
{
    MCKMockingContext *context = [MCKMockingContext currentContext];
    context.currentLocation = location;
    
    if ([entities count] == 1 && [MCKTypeDetector isObject:[entities lastObject]]) {
        return mck_createSpyForObject([entities lastObject], context);
    } else {
        return [MCKMockObject mockWithContext:context entities:entities];
    }
}

id _mck_createSpy(MCKLocation *location, id object)
{
    MCKMockingContext *context = [MCKMockingContext currentContext];
    context.currentLocation = location;
    
    return mck_createSpyForObject(object, context);
}
