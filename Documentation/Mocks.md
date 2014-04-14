# Mock Objects

Mock objects or simply mocks are stand-ins for real objects to use in your test code.

There are two types of mocks available in Mocka.

 * Class and Protocol Mocks
 * Spies


## Class and Protocol Mocks

Class and protocol mocks are used to represent objects of a specific class, one or more protocols or a combination thereof.

To create a class/protocol mock you use `mock(...)` and pass the class or protocol instances as arguments.

    NSArray *arrayMock = mock([NSArray class]);
    id<NSCoding> codingMock = mock(@protocol(NSCoding));

You also can combine multiple protocols or a class with additional protocols.

    MYObject<NSCoding, NSCopying> *combinedMock = mock([MYObject class],
                                                       @protocol(NSCoding),
                                                       @protocol(NSCopying));

There are some rules for mocking classes and protocols:

 * You must mock at least one entity (class or protocol)
 * You can mock at most one class
 * You can mock any number of protocols


### Shorthands

For the most part you probably will only need to mock a single class or protocol. For this case there are two shorthand macros:

    NSArray *arrayMock = mockForClass(NSArray);
    id<NSCoding> codingMock = mockForProtocol(NSCoding);

Note that you don't need to add `[... class]` or `@protocol(...)` since those are implied.

You can only mock a single class or protocol using those macros.


## Spies (partial mocks)

Spies or partial mocks are mocks for existing objects. You can use spies to stub only specific methods while retaining the original implementation of unstubbed methods. Also it allows you to match methods being called on the spied object.

To create a spy you use `spy(...)` and pass the existing object.

    NSObject *object = [[NSObject alloc] init];
    (void)spy(object);
    // 'object' can now be used like a mock

`spy(...)` does not create a new object, instead the existing object is modified to enable stubbing and matching. This allows you to mock dependencies which cannot be replaced (e.g. in legacy or third party code). The passed object is also returned, so you can simplify the above statement to the following:

    NSArray *array = spy([[NSObject alloc] init]);

Spies cannot be created on internal foundation classes (e.g. all classes starting with `__NS`). This includes most instances of `NSString`, `NSArray` and similar classes. There is usually no need for those classes to be spied upon anyway.

While spies can be very useful at certain times, you should only use them in legacy or third party code. Having to use a spy hints at too much complexity in your design (e.g. a class that has too many responsibilities). If you believe you are in the need of a spy, you should review your design first.

For consistency it's also possible to create a spy using `mock(...)` by passing a single object to be spied upon. This is not recommended however since you loose type safety and gain nothing.