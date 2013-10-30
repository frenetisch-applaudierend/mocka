# Introduction
Mocka is an Objective-C mocking library designed after [mockito](http://code.google.com/p/mockito/). The goal is to provide a powerful yet simple and readable way to isolate your objects when doing unit tests.

Mocka is distributed under the [MIT License](http://opensource.org/licenses/mit-license.php). See the LICENSE file for more details.

## Features
These are some highlights of Mocka:

* **Use & verify** – Some mocking frameworks like OCMock and LRMocky force you to declare your expectations before using the mocks, cluttering the test. In Mocka (like in OCMockito) you use the mock first and in the end you verify your expectations, leading to a much more natural flow.
* **Readable syntax** – In addition to the clean use & verify approach, Mocka is focused on making the syntax understandable, even if you never used it before.
* **Easy to refactor** – Mocka makes Xcode’s life as easy as possible when it comes to refactoring, particularly renaming methods. This means no calls are passed as arguments to macros and all mocks are objects of the mocked types, not a generic id object.
* **Support for spies** – Spies allow you to verify methods on already existing objects (this is what OCMock calls *partial mocks*). While it’s generally not a good idea to rely strongly on this feature, it’s nonetheless useful to have it in your mocking toolbox.

# Building the library
To build the library execute the `MakeDistribution.sh` file in the project directory:

	$ cd /path/to/project
	$ ./MakeDistribution.sh
This will open the `Distribution/` directory in finder and give you both a .zip file and the framework ready to be copied to your project.

# Usage
To use Mocka in your project do the following steps.

1. Drag the `Mocka.framework` directory into your project and add it to your unit testing target
2. Add "-ObjC" to "Other Linker Flags" of your unit test target in your project's build settings
3. Make Mocka available in your unit tests with `#import <Mocka/Mocka.h>`

This is an example of a simple test using Mocka.

	- (void)testThatGuardianCallsOperatorOnErrorCondition {
		// given
		CallCenter *callCenter = mockForClass(CallCenter);
		Guardian *guardian = [[Guardian alloc] initWithCallCenter:callCenter];
		
		// when
		[guardian errorConditionDetected];
		
		// then
		verifyCall [callCenter callOperator];
	}

## Creating mock objects
Use `mock(...)` to create mock objects.

	// create a mock just for a class
	NSArray *arrayMock = mock([NSArray class]);
	
	// create a mock for some protocols
	id<NSCoding, NSCopying> protocolMock = mock(@protocol(NSCoding), @protocol(NSCopying));
	
	// create a mock for a combination of a class with some protocols
	NSObject<NSCoding> *weirdMock = mock([NSObject class], @protocol(NSCoding));

You can create arbitrary combinations, with the rule that you can have at most one class and if it’s there it must be the first parameter.

If you just want to mock a single protocol or class there is a shortcut.

	// create a mock for just a class
	NSArray *arrayMock = mockForClass(NSArray);
	
	// create a mock for just a protocol
	id<NSCoding> codingMock = mockForProtocol(NSCoding);

Note that you don’t need to call `[Foo class]` or `@protocol(Bar)` in this case.

To spy on an existing object you use `spy(...)`. You pass it an existing object instance which will then be turned into a mocka spy object. The returned object is the same instance as the passed one.

	Foo *foo = [[Foo alloc] init];
	Foo *fooMock = spy(foo);

Now you can use the mock (or the original object) in any way you could use any other mock, including stubbing and verifying. Note that you cannot spy on core foundation bridging classes (all classes that start with `__NSCF`).

To see some examples for creating mocks see `Examples/ExamplesCreatingMocks.m`.

## Verifying
To verify that a certain call was made use the `verify` keyword.

	// given
	NSArray *arrayMock = mockForClass(NSArray);
	
	// when
	DoSomethingWith(arrayMock);
	
	// then
	verifyCall [arrayMock objectAtIndex:0];

If `DoSomethingWith(...)` didn’t call `[arrayMock objectAtIndex:0] the `verify` line will generate a test failure.

By default `verify` will succeed if one or more matching calls were made, but you can change this behavior. For example to verify an exact number of calls use `verify exactly(N)` (where `N` is the number of invocations).

	// only succeed if there were exactly 3 calls to -addObject:
	verify exactly(3) [arrayMock addObject:@"Foo"]

More examples can be found in `Examples/ExamplesVerify.m`.

## Stubbing
By default when a method is called on a mock it will do nothing and simply return the default value (`nil` for objects, `0` for integers, etc). Stubbing allows you to specify actions that should be executed when a certain method on a mock is called. To stub a method use the `whenCalling ... thenDo` keywords.

	NSArray *arrayMock = mockForClass(NSArray);
	
	whenCalling [arrayMock count] thenDo returnValue(1);
	whenCalling [arrayMock objectAtIndex:0] thenDo returnValue(@"Foo");

You can group multiple calls to have the same actions…

	whenCalling [foo doSomething]
	orCalling [foo doSomethingElse]
	thenDo throwNewException(NSRangeException, @"Some Reason", nil);

…or you can add multiple actions to the same call…

	whenCalling [foo doSomething]
	thenDo performBlock(^(NSInvocation *inv) { NSLog(@"Was called"); })
	andDo returnValue(@"Hello World");

…or both of course.

Tip: Add a snippet to the Xcode snippet library for `whenCalling ... thenDo ...`

Examples about stubbing are in `Examples/ExamplesStub.m`.

# Alternatives to Mocka
If you don’t like my implementation or you’re just looking for alternatives, here are a few other mocking libraries I’ve used before. Maybe one of those suits your needs:

* [OCMock](https://github.com/erikdoe/ocmock) – As far as I know the most feature complete mocking library out there. It’s also the most mature mocking library I know of.
* [OCMockito](https://github.com/jonreid/OCMockito/) – An Objective-C implementation of mockito. 
* [LRMocky](https://github.com/lukeredpath/LRMocky) – An Objective-C mocking framework modeled after jMock.