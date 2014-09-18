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
		
		match ([callCenter callOperator]);
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

_**Note:** It's not possible to create spies for internal Foundation classes. This includes class clusters like `NSString` or `NSArray`._


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

_**Note:** The return type of the action block is checked by the compiler, the argument types are checked at runtime._


## Matching

> This is a summary. See [Documentation/Matching.md](Documentation/Matching.md) for details.
> You can find examples of stubs in
> [`Tests/ExamplesMatch.m`](Tests/ExamplesMatch.m).

You can test wether a set of methods were called on a mock or not. To do so use the `match` keyword.

    NSArray *arrayMock = mockForClass(NSArray);
	
	[arrayMock objectAtIndex:0];
	
	match ([arrayMock objectAtIndex:0]); // succeeds
	match ([arrayMock objectAtIndex:1]); // fails

A failure to match a call results in a test case failure.

By default `match` will succeed if at least one matching call was made. You can fine tune this behavior by adding match descriptors.

    match ([mock someMethod]) exactly(2 times); // must have exactly 2 matching invocations
    match ([mock someMethod]) never;            // must not have any invocations

You can also test asynchronously using `withTimeout()`.

    match ([mock someMethod]) withTimeout(2.0); // wait up to 2 seconds for this invocation

Sometimes you need to check that a set of calls was made in a specific order (e.g. data source/delegate flows). To match in a specific order use the `inOrder` keyword.

    inOrder {
        match ([mock someMethod]);
        match ([mock someOtherMethod]);
    }; // must match both calls in order


## Network Mocking

> This is a summary. See [Documentation/NetworkMocking.md](Documentation/NetworkMocking.md) for details.
> You can find examples of stubs in
> [`Tests/ExamplesNetworkMocking.m`](Tests/ExamplesNetworkMocking.m).

_**Note:** You need to link the `OHHTTPStubs` library for those features to be available._

Mocka provides a singleton object called `Network`. You can use it turn HTTP(S) network access off and on as well as stubbing and matching HTTP(S) network calls.

To disable and enable the network simply use `[Network disable]` and `[Network enable]`. While network access is disabled, trying to make a connection will result in a "No internet connection" error.

Regardless wether the network is enabled or not, you can define stubbed responses for specific network calls.

    stub (Network.GET(@"http://www.google.ch")) with {
        return @"Hello World";
    };

To check for network calls you must first record them explicitly. Then later you can match them just like you would match a method call.

    [Network startObservingNetworkCalls]; // record network calls
    
    [controller reloadSomeData];
    
    match (Network.GET(@"http://my-service.com/some/resource"));
