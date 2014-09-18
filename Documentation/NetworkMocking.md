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
