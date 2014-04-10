//
//  ExamplesCreating+Spies.m
//  Examples
//
//  Created by Markus Gasser on 07.04.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import "ExampleTestCase.h"
#import "TestObject.h"


@interface ExamplesCreating_Spies : ExampleTestCase @end
@implementation ExamplesCreating_Spies

#pragma mark - Creating Spies

- (void)testCreatingSpy
{
    // to create a spy you need an existing object
    // spy(...) converts your object to a spy and returns it
    
    TestObject *object = [[TestObject alloc] init];
    TestObject *spyObject = spy(object);
    
    expect(object == spyObject).to.beTruthy();
}


#pragma mark - Things That Won't Work

- (void)testCreatingSpyForNilIsNotPossible
{
    // you may not pass nil as an argument to spy(...)
    
    // a literal nil will give you a compilation error
    ThisWillNotCompile({
        (void)spy(nil);
    });
    
    // if you hide it in a variable it will compile, but throw an exception at runtime
    ThisWillFail({
        id nilObject = nil;
        (void)spy(nilObject);
    });
}

- (void)testCreatingSpyForInternalFoundationClassesIsNotPossible
{
    // you cannot spy(...) on internal foundation classes
    // this means a lot of class clusters like NSArray or NSString can't be spied upon
    
    ThisWillFail({
        (void)spy(@[]);
    });
    
    ThisWillFail({
        (void)spy(@"");
    });
}

@end
