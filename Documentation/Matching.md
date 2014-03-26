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