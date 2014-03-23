# Introduction

Mocka is an Objective-C mocking library inspired by [mockito](http://code.google.com/p/mockito/). The goal is to provide a powerful yet simple and readable way to isolate your objects and to test messages between objects in your unit tests.

Mocka is distributed under the [MIT License](http://opensource.org/licenses/mit-license.php). See the [LICENSE](LICENSE) file for details.


## Features

These are some highlights of Mocka:

 * **Use first, check later** – Some mocking frameworks force you to declare your expectations before using the mocks, cluttering the test. In Mocka you use the mock first and in the end you check your expectations, leading to a much more natural flow.
 * **Readable syntax** – Mocka tries to make the syntax understandable, even if you never used it before.
 * **Type safe mocks** – Mock objects in Mocka are typed and all calls done on the mocks are done on typed objects. This helps the IDE with code completion and renaming.
 * **Type safe argument matchers** - Mocka comes with a set of argument matchers for all kinds of argument types, including structs. [OCHamcrest](https://github.com/hamcrest/OCHamcrest) matchers are supported too.
 * **Support for spies** – Spies allow you to mock specific methods on already existing objects (sometimes called *partial mocks*).
 * **Network Mocking** - Mocka provides support for [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) to stub and check network calls using the same DSL as for mocking objects.


# Installation

To use the library in your project you can either add it using [CocoaPods](http://cocoapods.org) or as a framework.


## CocoaPods

The easiest way is using CocoaPods. To add Mocka to your testing target include the following in your `Podfile` and run `pod install`.

    pod 'Mocka'
    #pod 'OHHTTPStubs' # Uncomment to support network mocking
    #pod 'OCHamcrest'  # Uncomment to support hamcrest matchers

To use Mocka in your tests include it using `#import <Mocka/Mocka.h>`.


## Mocka.framework

To use the framework either download it from the project page or build it from sources. The framework contains binaries for iOS, iOS Simulator and OS X.

To build the library execute the `MakeDistribution.sh` file in the project directory:

	$ cd /path/to/project
	$ ./MakeDistribution.sh

This will open the `Distribution/` directory in finder and give you both a .zip file and the framework ready to be copied to your project.

When you have the framework ready, simply drag it into your project and add it to your project's unit testing bundle.

After this make sure you have `-ObjC` added to your test target's `Other Linker Flags` otherwise you'll run into problems with categories not being loaded.

To use Mocka in your tests include it using `#import <Mocka/Mocka.h>`.


## Prefixed Syntax

Mocka does not use prefixes by default. If you experience problems because of this add `#define MCK_DISABLE_NICE_SYNTAX` before importing any Mocka header.


# Usage

This is an example of a simple test using Mocka.

	- (void)testThatGuardianCallsOperatorOnErrorCondition {
		CallCenter *callCenter = mockForClass(CallCenter);
		Guardian *guardian = [[Guardian alloc] initWithCallCenter:callCenter];
		
		[guardian errorConditionDetected];
		
		verifyCall ([callCenter callOperator]);
	}


## Creating mock objects

> This is a summary. See [Documentation/Mocks.md](Documentation/Mocks.md) for details.
> You can find examples of creating mocks in
> [`Tests/ExamplesCreatingMocks.m`](Tests/ExamplesCreatingMocks.m).


### Mocking Classes or Protocols

Use `mockForClass(...)` to create a mock for a class:

    NSArray *arrayMock = mockForClass(NSArray);

Use `mockForProtocol(...)` to create a mock for a prococol:

    id<NSCoding> codingMock = mockForProtocol(NSCoding);
    
Or use `mock(...)` to create combinations thereof.

    MYObject<NSCoding, NSCopying> *combinedMock = mock([MYObject class],
                                                       @protocol(NSCoding),
                                                       @protocol(NSCopying));    

### Mocking existing Objects

You can also mock existing objects (called partial mocks or spies). While it’s generally not a good idea to rely too strongly on this feature, it’s still useful to have it in your mocking toolbox.

You create a spy using `spy(...)`.

    MyObject *objectMock = spy([[MYObject alloc] init]);

***Note:** It's not possible to create spies for internal Foundation classes. This includes class clusters like `NSString` or `NSArray`.*


## Stubbing

> This is a summary. See [Documentation/Stubbing.md](Documentation/Stubbing.md) for details.
> You can find examples of stubs in
> [`Tests/ExamplesStub.m`](Tests/ExamplesStub.m).

By default when a method is called on a mock it will do nothing and simply return the default value (`nil` for objects, `0` for integers, an empty struct, etc). Stubbing allows you to specify actions that should be executed when a given method on the mock is called.

To stub a method use the `stub ... with ...` construct.
    
    stub ([mock methodToStub]) with {
        NSLog(@"Stub was called");
        return YES;
    };

It's possible to examine and use the arguments passed to the stubbed method call by adding the argument list between the `with` keyword and the action block.

    stub ([mock methodWithArgument1:@"Foo" argument2:YES]) with (id arg1, BOOL arg2) {
        NSLog(@"Stub was called with %@ and %ld", arg1, (unsigned long)arg2);
    };

***Note:** The return type of the action block is checked by the compiler, the argument types are checked at runtime.*


## Verifying

To verify that a certain call was made use the `verifyCall` keyword.

	NSArray *arrayMock = mockForClass(NSArray);
	
	DoSomethingWith(arrayMock);
	
	verifyCall ([arrayMock objectAtIndex:0]);

If `DoSomethingWith(...)` didn’t call `[arrayMock objectAtIndex:0]` then `verifyCall` will generate a test failure.

By default `verifyCall` will succeed if at least one matching call was made, but you can change this behavior. For example to verify an exact number of calls use `verifyCall (exactly(N) <#CALL#>)` (where `N` is the number of invocations).

	// only succeed if there were exactly 3 calls to -addObject:
	verifyCall (exactly(3) [arrayMock addObject:@"Foo"])

Note that matching calls are not evaluated again. Consider the following example:

	NSArray *arrayMock = mockForClass(NSArray);
	
	[arrayMock objectAtIndex:0];
	
	verifyCall ([arrayMock objectAtIndex:0]); // this succeeds, since the call was made
	verifyCall ([arrayMock objectAtIndex:0]); // this fails, because the previous verification
	                                      // removes the call

If there were two calls to `[arrayMock objectAtIndex:0]` the second verification would succeed now, because `verifyCall (...)` only removes the first matching invocation.

More examples can be found in `Examples/ExamplesVerify.m`.


### Ordered Verification

You can verify that a group of calls was made in a given order. This is especially useful when testing interaction with a delegate or data source.

    NSArray *arrayMock = mockForClass(NSArray);
    
    [self doSomethingWith:arrayMock];
    
    // check if the following calls were made in order
    verifyInOrder {
        [arrayMock count];
        [arrayMock objectAtIndex:0];
        [arrayMock objectAtIndex:1];
    };

Note that when checking calls in order, interleaving calls do not cause a failure. E.g. the following verification will succeed, because the tested calls were all made and in order.

    NSArray *arrayMock = mockForClass(NSArray);
    
    [arrayMock count];
    [arrayMock objectAtIndex:0];
    [arrayMock objectAtIndex:1];
    [arrayMock removeAllObjects];
    
    // check if the following calls were made in order
    verifyInOrder {
        [arrayMock count];
        [arrayMock removeAllObjects];
    };


## Network Mocking

You need to add the `OHHTTPStubs` library for those features to be available.

If you have it installed you can disable access to the real network using `[Network disable]`. From this point on HTTP(S) calls won't hit the network and you'll get a "No internet connection" error instead. This is useful to avoid potentially slow and unreliable internet access, instead seeing an error directly if you accidentally hit the network. To reenable it later use `[Network enable]`.


### Network Stubbing

Regardless wether the real network is enabled or not, you can define stubbed responses for specific network calls.

    stub (Network.GET(@"http://www.google.ch")) with {
        return @"Hello World";
    };

You can return any of the following types:

* `NSData` is returned exactly as is
* `NSString` is interpreted as UTF-8 data
* `NSDictionary` and `NSArray` are interpreted as JSON objects and return JSON data
* `NSError` is interpreted as a connection error
* `nil` is interpreted as not available (no internet connection)
* `OHHTTPStubsResponse` to configure exactly what you want returned


### Network Verification

You can also monitor and verify network calls.

    [Network startObservingNetworkCalls]; // needed to verify
    
    [controller reloadSomeData];
    
    verifyCall (Network.GET(@"http://my-service.com/some/resource"));
