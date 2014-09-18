# Stubbing

Stubbing allows you to add behavior to your mock objects. It allows you for example to specify a certain return value or save a passed argument for later examination.

However mock objects are not intended to contain complex logic. If you find your stubs reacting differently depending on some mutable state for example, you might want to use a more suitable tool instead. Usually creating a dummy subclass works better in this scenario.


## Stubbing a Method

To stub a method use the `stub ... with ...` construct to provide a call prototype and an action block.

    stub ([mock methodToStub]) with {
        return YES;
    };

You can also group multiple calls to have the same actions by putting them in braces.

	stub ({
	    [mock firstMethodToStub];
	    [mock secondMethodToStub];
	}) with {
	    @throw [NSException exceptionWithName:@"ExceptionalException"
	                                   reason:nil
	                                 userInfo:nil];
	};

Alternatively you can just list all the calls to stub as parameters.

    stub ([mock firstMethodToStub], [mock secondMethodToStub]) with {
	    @throw [NSException exceptionWithName:@"ExceptionalException"
	                                   reason:nil
	                                 userInfo:nil];
	};

By default stubs are matched by evaluating the arguments for equality. You can use [argument matchers](ArgumentMatchers.md) to fine-tune this behavior.

    stub ([mock methodWithArgument:anyObject()]) with {
        return YES;
    };

The return type of the action block is type checked by the compiler for a `stub` block. In case of multiple calls it's your responsibility to make sure someting sensible is returned for all methods as the compiler only checks the type of the last call.


## Evaluating Method Arguments

You can access the passed method arguments from the action block by adding the method's argument list between the `with` keyword and the action block.

    stub ([arrayMock objectAtIndex:10]) with (NSUInteger idx) {
        return @(idx);
    };

If you need access to `self` or `_cmd` use the full argument list instead.

    stub ([arrayMock objectAtIndex:10]) with (NSArray *self, SEL _cmd, NSUInteger idx) {
        if (self.count > idx) {
            return @(idx);
        } else {
            @throw [NSException exceptionWithName:NSRangeException
                                           reason:@"Index out of bounds"
                                         userInfo:nil];
        }
    };

_**Note:** You can either use the no argument list, the reduced argument list (all arguments, but without `self` and `_cmd`) or the full one. Any other combination of arguments will result in a failure at runtime._