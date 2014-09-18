//
//  ExamplesHamcrest.m
//  Examples
//
//  Created by Markus Gasser on 14.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"

#import <Mocka/Mocka.h>
#import <OCHamcrest/OCHamcrest.h>


@interface ExamplesHamcrest : ExampleTestCase @end
@implementation ExamplesHamcrest {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Test Using Hamcrest Matchers

- (void)testYouCanUseHamcrestMatchersForObjects {
    // for object args you can use hamcrest matchers just like this
    
    [mockArray addObject:@"Hello World"];
    
    match ([mockArray addObject:HC_startsWith(@"Hello")]);
}

- (void)testYouCanUseHamcrestMatchersForScalars {
    // for primitive args you can use hamcrest matchers by wrapping them in the mck_hamcrestArg() macro
    
    [mockArray objectAtIndex:10];
    
    match ([mockArray objectAtIndex:hamcrestArg(NSInteger, HC_lessThan(@20))]);
}

- (void)testYouCanUseHamcrestMatchersForObjectsWrappedInMacro {
    // you can also wrap objects in the macro, it's just not necessary
    
    [mockArray addObject:@"Hello World"];
    
    match ([mockArray addObject:hamcrestArg(id, HC_startsWith(@"Hello"))]);
}


@end
