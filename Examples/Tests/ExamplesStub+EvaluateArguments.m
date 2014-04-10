//
//  ExamplesStub+EvaluateArguments.m
//  Examples
//
//  Created by Markus Gasser on 10.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"

#import <Mocka/Mocka.h>


@interface ExamplesStub_EvaluateArguments : ExampleTestCase @end
@implementation ExamplesStub_EvaluateArguments {
    NSMutableArray *mockArray;
    NSMutableString *mockString;
}

#pragma mark - Setup

- (void)setUp {
    // we'll use these objects in the examples
    mockArray = mock([NSMutableArray class]);
    mockString = mock([NSMutableString class]);
}


#pragma mark - Examining Arguments

- (void)testYouCanExamineTheArgumentsPassedToTheStubbedMethod
{
    // if you declare the arguments after the with keyword, you can use them in your stub action
    
    stub ([mockArray objectAtIndex:any(NSUInteger)]) with (NSUInteger index) {
        return @(index);
    };
    
    expect([mockArray objectAtIndex:0]).to.equal(@0);
    expect([mockArray objectAtIndex:1]).to.equal(@1);
    expect([mockArray objectAtIndex:99]).to.equal(@99);
}

- (void)testYouCanAlsoExamineSelfAndCmd
{
    // if you also include self and _cmd, those parameters are passed as well to the block
    // NOTE: Either both self and _cmd must be declared or neither. You cannot choose to only have self or _cmd passed.
    //       Also if you declare self and _cmd, you must also declare all other parameters
    
    stub ([mockArray objectAtIndex:any(NSUInteger)]) with (NSArray *self, SEL _cmd, NSUInteger index) {
        return self;
    };
    
    expect([mockArray objectAtIndex:0]).to.equal(mockArray);
}

- (void)testYouCanSetOutParametersFromStubbedMethods
{
    // you can set parameters passed by reference
    
    stub ([mockArray getObjects:any(id __unsafe_unretained *) range:any(NSRange)]) with (id __unsafe_unretained objects[], NSRange range) {
        objects[0] = @"Hello";
        objects[1] = @"World";
    };
    
    id __unsafe_unretained objects[2];
    [mockArray getObjects:objects range:NSMakeRange(0, 2)];
    
    id object0 = objects[0]; id object1 = objects[1];
    expect(object0).to.equal(@"Hello");
    expect(object1).to.equal(@"World");
}

@end
