# Introduction
Mocka is an Objective-C mocking library designed after [mockito](http://code.google.com/p/mockito/). The goal is to provide a powerful yet simple and readable way to isolate your objects when doing unit tests.

## Features
These are some highlights of Mocka:

* **Use-then-verify style** – As opposed to the *record-use-verify* style found for example in OCMock and LRMocky. You create a mock, you use it, and when you’re done you verify that all was as expected. This keeps your tests clean and simple.
* **Easy to refactor** – Mocka tries to make Xcode’s life as easy as possible when it comes to refactoring; particularly renaming methods. This means no calls are passed as arguments to macros and all mocks are objects of the mocked types, not a generic id object.
* **Readable syntax** – Mocka is focused on making the syntax understandable, even if you never used it before. This means keywords that make sense, as well as the *use-then-verify* style.
* **Support for spies** – Spies allow you to verify methods on already existing objects (this is what OCMock calls *partial mocks*). While it’s generally not a good idea to rely strongly on this feature, it’s nonetheless useful to have it in your mocking toolbox.

# Installation

## Build the library
To build the library execute the `MakeDistribution.sh` file in the project directory:

	$ cd /path/to/project
	$ ./MakeDistribution.sh
This will open the `Distribution/` directory in finder and give you both a .zip file and the framework ready to be copied to your project.

## Use it in your project
1. Drag the `Mocka.framework` directory into your project and add it to your unit testing target
2. Use Mocka in your unit tests with `#import <Mocka/Mocka.h>`

# Alternatives
If you don’t like my implementation or you’re just looking for alternatives, here are a few other mocking libraries I’ve used before. Maybe one of those suits your needs:

* [OCMock](https://github.com/erikdoe/ocmock) – As far as I know the most feature complete mocking library out there. It’s also the most mature mocking library I know of.
* [OCMockito](https://https://github.com/jonreid/OCMockito/) – An Objective-C implementation of mockito. 
* [LRMocky](https://https://github.com/lukeredpath/LRMocky) – An Objective-C mocking framework modeled after jMock.