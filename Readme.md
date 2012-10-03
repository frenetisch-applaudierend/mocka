# Introduction
RGMock is an Objective-C mocking library designed after [mockito](http://code.google.com/p/mockito/). The goal is to provide a powerful yet simple and readable way to isolate your objects when doing unit tests.

## Why another mocking library?
There are other mocking libraries around and they’re quite good. So why write another one? RGMock has some features which (together) are not found in the others.

* **Use-then-verify style** – As opposed to the *record-use-verify* style found for example in OCMock and LRMocky. You create a mock, you use it, and when you’re done you verify that all was as expected. This keeps your tests clean and simple.
*  **Easy to refactor** – RGMock tries to make Xcode’s life as easy as possible when it comes to refactoring; particularly renaming methods. This means no calls are passed as arguments to macros and all mocks are objects of the mocked types, not a generic id object.
* **Readable syntax** – A lot is already done for readability by using the *use-then-verify* style. But RGMock is also focused on making the syntax understandable, even if you never used it before.
* **Support for spies** – Spies allow you to verify methods on already existing objects (OCMock calls them *partial mocks*). While it’s genrally not a good idea to rely too strongly on this feature, it’s nonetheless useful to have it in your mocking toolbox.

## Alternatives
If you don’t like my implementation or you’re just looking for alternatives, here are a few I’ve used before:

* [OCMock](https://github.com/erikdoe/ocmock) – As far as I know the most feature complete mocking library out there. It’s also the most mature mocking library I know of.
* [OCMockito](https://https://github.com/jonreid/OCMockito/) – An Objective-C implementation of mockito. 
* [LRMocky](https://https://github.com/lukeredpath/LRMocky) – An Objective-C mocking framework modeled after jMock.

# Installation

## Build the library
To build the library execute the `makelib.sh` file in the project directory:

	$ cd /path/to/project
	$ ./makelib.sh
This will open the `distribution/` directory in finder and give you both a .zip file and a directory ready to be copied to your project.

## Use it in your project
To use it in your project copy the `RGMock/` folder into your project where you store your third party libraries (I usually create a folder `Libraries/` just under the project root.

Next add the library to your unit testing target in Xcode:

1. In Xcode select your unit testing target
2. Go to the „Build Phases“ tab
3. Under „Link Binary With Libraries“ press the + button, press „Add Other...“ and look for the `librgmock.a` file

After this you need also to add the header path:

1. In Xcode select your unit testing target
2. Go to the „Build Settings“ tab
3. Search for „Header Search Paths“
4. In the column for the unit testing target add the location of the folder containing the `librgmock.a` file (For example `"$(SRCROOT)/Libraries/RGMock“`; you can check in „Library Search Paths“, it should contain the correct directory for the library).

Now you can use RGMock with `#import <RGMock/RGMock.h>`.
