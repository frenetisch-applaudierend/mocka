# KNMParametrizedTest

KNMParametrizedTest adds support for parametrized test cases using the XCTest framework. Here is an example:

    KNMParametersFor(testExample, @[ @"Hello", @"World" ])
    - (void)testExample:(NSString *)word
    {
    	NSString *result = [myUppercaser uppercaseString:word];
        XCTAssertEqualObjects(result, [word uppercaseString],
                              @"Uppercaser failed for word %@", word);
    }


## Installation

The easiest way is using [CocoaPods](http://cocoapods.org). Just add the following to your Podfile for your testing target.

    pod 'KNMParametrizedTests'


## Declaring a Parametrized Test


A parametrized test is declared just like a regular unit test method, but takes a single argument which is then used to pass the parameter in. So a parametrized test must:

 * be an instance method
 * return `void`
 * start with `test`
 * and have exactly 1 argument

```
    - (void)testSomeParametrizedSomething:(NSDictionary *)param {
    }
```


## Providing Parameters

To provide parameters KNMParametrizedTest calls `+ (NSArray *)parametersForTestWithSelector:(SEL)selector` on the test case class and passes the test selector as the argument.

The default implementation will try to find a class method matching the pattern

 * `+ (NSArray *)parametersFor<TestName>` or alternatively
 * `+ (NSArray *)parametersFor_<testName>` (note the different capitalization).
 
The second alternative is primarily intended for use in macros, as it's easier to construct.

_**Note:** parameter methods are class methods, not instance methods._

So for a test case named `- (void)testExample:(NSString *)param` either of the following methods could provide the parameters.


```
    + (NSArray *)parametersForTestExample {
        return @[ @"Foo", @"Bar" ];
    }
```

```
    + (NSArray *)parametersFor_testExample {
        return @[ @"Foo", @"Bar" ];
    }
```

If both implementations are provided, the former is used.

If none of the above implementations can be found the default implementation returns `@[ NIL ]`. This executes the test once with `nil`/`0` as parameter.

The parametrized test is preformed once for each object provided. If no objects are provided or a `nil` array is returned, then the test method is skipped.


### Nil Parameters

If you want to provide `nil` as a parameter use the `NIL` macro.

    + (NSArray *)parametersForTestEmptyness {
        return @[ @"", NIL ];
    }

_**Note:** If you return `[NSNull null]` as a parameter it will be passed as is and not converted to `nil`._


### Scalar and Struct Parameters


KNMParametrizedTest supports struct and scalar parameters. Simply use the desired argument type in the test method declaration.

    + (NSArray *)parametersForTestScalars {
        return @[ @10, @20 ];
    }
    
    - (void)testScalars:(NSUInteger)scalar {
        XCTAssert(scalar >= 10, @"Should be greater or equal 10");
    }

For struct parameters use the `VALUE(...)` macro.

    + (NSArray *)parametersForTestStructs {
        return @[ VALUE(NSMakeRange(10, 10)), VALUE(NSMakeRange(20, 20)) ];
    }
    
    - (void)testStructs:(NSRange)range {
        XCTAssert(range.location >= 10, @"Should be greater or equal 10");
    }


### Macros

If you want to minimize typing you can use some shorthand macros. To provide parameters for a given test case you can use the `KNMParametersFor(...)` macro.

    KNMParametersFor(testExample, @[ @10, @20, @30 ])
    - (void)testExample:(NSNumber *)number {
        XCTAssert([number integerValue] > 0, @"Should be positive");
    }

This keeps the parameters and the test together without cluttering the test too much. Also the macro checks wether the referenced test actually exists. If it doesn't, the compiler will warn you.


## Shorthands

There are some unprefixed macros declared (e.g. `NIL`). If you run into problems with those macros, add `#define KNM_PARAM_NO_SHORTHAND` before you import any KNMParametrizedTest header.

    #define KNM_PARAM_NO_SHORTHAND
    #import <KNMParametrizedTest/KNMParametrizedTest.h>

This will disable the unprefixed macros. You need to prefix them with `knm_` in this case (e.g. `knm_NIL`).
