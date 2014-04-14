# Argument Matchers

By default `stub` and `verifyCall` match the passed calls by comparing the arguments for equality.

    [mock methodWithArgument:@"Foo"];
    
    verfiyCall ([mock methodWithArgument:@"Foo"]); // succeeds
    verfiyCall ([mock methodWithArgument:@"Bar"]); // fails

Sometimes the actual argument is not important or is should be checked in a different way. Mocka allows you to fine tune argument checking using matchers. For example, you could use the following to match any passed argument.

    [mock methodWithArgument:@"Foo"];
    
    verfiyCall ([mock methodWithArgument:anyObject()]); // succeeds


## Usage

Matchers can be substituted for arguments whenever a call prototype is required. `stub` and `verifyCall` both support argument matchers.

    stub ([mock methodWithArgument:anyObject()]) with {
        NSLog(@"Stub called");
    };
    
    [mock methodWithArgument:nil]; // stub called
    [mock methodWithArgument:@"Foo"]; // stub called
    [mock methodWithArgument:@"Bar"]; // stub called

Argument matchers must be declared while stubbing or verifying a call.

    // correct
    stub ([mock methodWithArgument:anyObject()]) with {
        NSLog(@"Stub called")
    };
    
    // incorrect: matcher must be declared inline
    id matcher = anyObject();
    stub ([mock methodWithArgument:matcher]) with {
        NSLog(@"Stub called")
    };


### Scalar and Struct Matchers

Mocka has support for using argument matchers also on scalar or struct types.

    stub ([mock methodWithIntegerArgument:anyInt()]) with {
        NSLog(@"Stub called");
    };
    
    [mock methodWithIntegerArgument:0];  // stub called
    [mock methodWithIntegerArgument:15]; // stub called


#### Limitations

When using scalar or struct matchers, all arguments must use a matcher.

    // correct: no primitive arguments are matchers
    stub ([mock methodWithIntArgument1:50 intArgument2:60]) with {
        NSLog(@"Stub called")
    };
    
    // correct: all primitive arguments are matchers
    stub ([mock methodWithIntArgument1:anyInt() intArgument2:anyInt()]) with {
        NSLog(@"Stub called")
    };
    
    // incorrect: mixed arguments and matchers
    stub ([mock methodWithIntArgument1:50 intArgument2:anyInt()]) with {
        NSLog(@"Stub called")
    };

In case where you only need a matcher for one argument, but want to check the value of another, there are the `<type>Arg()` matchers. These matchers check if the passed argument is the same value as the value passed to the matcher.

    // correct: all primitive arguments are matchers
    stub ([mock methodWithIntArgument1:intArg(50) intArgument2:anyInt()]) with {
        NSLog(@"Stub called")
    };


## Available Matchers

Mocka comes with a few built-in matchers for common tasks. If you like more options you can also use hamcrest matchers using [OCHamcrest](https://github.com/hamcrest/OCHamcrest).


### Any Argument Matcher

If you want to ignore the value of an argument when matching calls you can use the `any<Type>()` matcher. This matcher matches on any passed value.

    stub ([mock methodWithArgument:anyObject()]) with {
        NSLog(@"Stub called");
    };


### Block Argument Matcher

Use the `<type>Matching()` matcher to pass a block where you have the chance to evaluate the argument and return wether it should match or not. Using this matcher you can implement almost anything.

    stub ([mock methodWithArgument:objectMatching(^BOOL(id candidate) {
        return (candidate != nil);
    })]) with {
        NSLog(@"Stub called");
    };


### Hamcrest Matcher Support

Use `<type>That()` to pass a hamcrest matcher for scalar types.

    stub ([mock methodWithIntArgument:intThat(is(greaterThan(@5)))]) with {
        NSLog(@"Stub called");
    };

For object arguments you can simply pass the matcher itself.

    stub ([mock methodWithArgument:startsWith(@"Hello")]) with {
        NSLog(@"Stub called");
    };
