# Matching

Matching allows you to check wether certain messages were sent to your mocks. It's the equivalent of "verification" in Mockito and other mocking frameworks. Unfortunately Xcode bugs prohibit conventient usage of `verify` as a keyword, which is why it was replaced with `match` in Mocka.


## Matching a Method Call

To check wether a specific method call was made you can use the `match` keyword.

    match ([mock someMethodCall]);

If a matching call was previously made on the given mock, then `match` will succeed. Otherwise a test failure is generated.

Once you have matched a method call it won't be matched again.

    NSMutableArray *arrayMock = mockForClass(NSMutableArray);
    
    [arrayMock addObject:@"foo"];
    
    match ([arrayMock addObject:@"foo"]); // succeeds
    match ([arrayMock addObject:@"foo"]); // fails, because previous already matched

By default only one possible call is matched. Further calls can be matched later.

    NSMutableArray *arrayMock = mockForClass(NSMutableArray);
    
    [arrayMock addObject:@"foo"];
    [arrayMock addObject:@"foo"];
    
    match ([arrayMock addObject:@"foo"]); // succeeds
    match ([arrayMock addObject:@"foo"]); // succeeds, because there are 2 matching calls

By default calls are matched by evaluating the arguments for equality. You can use [argument matchers](ArgumentMatchers.md) to adjust this behavior.

    match ([mock methodWithArgument:anyObject()]);


## Match Descriptors

`match` normally succeeds if at least one matching call was made. To change this you can use match descriptors such as `never` and `exactly()`, by appending them to the `match` statement.

    match ([mock someMethodCall]) never;


### Match an Exact Number of Calls

`exactly(n times)` will only match if the specified call can be matched n times.

    NSMutableArray *arrayMock = mockForClass(NSMutableArray);
    
    [arrayMock addObject:@"foo"];
    [arrayMock addObject:@"foo"];
    
    [arrayMock addObject:@"bar"];
    [arrayMock addObject:@"bar"];
    [arrayMock addObject:@"bar"];
    
    match ([arrayMock addObject:@"foo"]) exactly(2 times); // succeeds, 2 calls matched
    match ([arrayMock addObject:@"bar"]) exactly(2 times); // fails, 3 calls matched

If you want to check that there was exactly one call, you can use `exactly(once)`. It's equivalent to `exactly(1 times)` but it reads nicer.

    match ([arrayMock addObject:@"foo"]) exactly(once);

_**Note:** `exactly(once)` is not the same as leaving the descriptor out. By default `match` will also succeed if there is more than one matching call._


### Match Never

`never` will only match if the specified call cannot be matched at all.

    NSMutableArray *arrayMock = mockForClass(NSMutableArray);
    
    [arrayMock addObject:@"foo"];
    
    match ([arrayMock addObject:@"bar"]) never; // succeeds
    match ([arrayMock addObject:@"foo"]) never; // fails, 1 matching call

`noMore` is an alias to `never`.


## Matching with Timeout

Sometimes it's necessary to wait for a callback or similar. For this you can specify a timeout when matching calls.

    match ([arrayMock addObject:@"foo"]) withTimeout(1.0); // wait up to 1 second

_**Note:** For some verification modes like `exactly()` the timeout must be awaited fully, thus making your tests significantly slower. If possible use a small timeout value in those cases._


## Matcher Groups

You can use matcher groups to achieve ordering or choice when matching.


### Matching in Order

You can verify that a group of calls were made in a given order using `matchInOrder`. This is especially useful when testing interaction with a delegate or data source.

    matchInOrder {
        match ([delegateMock someObjectWillStart:source]);
        match ([delegateMock someObjectDidStart:source]);
        match ([delegateMock someObjectWillEnd:source]);
        match ([delegateMock someObjectDidEnd:source]);
    }; // fails if above calls were not made in this exact order

Note that when checking calls in order, interleaving calls do not cause a failure. E.g. the following verification will succeed, because the tested calls were all made and in order.

    NSMutableArray *arrayMock = mockForClass(NSMutableArray);
    
    [arrayMock count];
    [arrayMock addObject:@"foo"];
    [arrayMock removeAllObjects];
    
    matchInOrder {
        match ([arrayMock count]);
        match ([arrayMock removeAllObjects]);
    };


### Matching with Choice

If there are more than one call which would satisfy you requirement you can use `matchAnyOf` to present a choice. For example to get the first element of an array you can either use `-firstObject`, `-objectAtIndex:` or `-objectAtIndexedSubscript:`.

    matchAnyOf {
        match ([arrayMock firstObject]);
        match ([arrayMock objectAtIndex:0]);
        match ([arrayMock objectAtIndexedSubscript:0]);
    }; // matching any of the above calls will make this group succeed
