# Build the libraries
xcodebuild -target rgmock -configuration Release -arch i386 x86_64 -sdk iphonesimulator5.0 clean build
xcodebuild -target rgmock -configuration Release -arch armv7 -sdk iphoneos5.0 clean build

# Make a fat binary and copy the headers
rm -rf distribution
mkdir -p distribution/Headers
lipo -output distribution/librgmock-universal.a -create -arch armv7 build/Release-iphoneos/librgmock.a -arch i386 build/Release-iphonesimulator/librgmock.a
cp -R build/Release-iphoneos/usr/local/include/* distribution/Headers/
