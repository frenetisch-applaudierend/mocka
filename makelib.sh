# Build the libraries
xcodebuild -target RGMock -configuration Release -arch i386 -sdk iphonesimulator clean build
xcodebuild -target RGMock -configuration Release -arch armv7 -sdk iphoneos clean build

# Copy Resources
rm -rf distribution
mkdir distribution
cp -R build/Release-iphoneos/include/RGMock distribution/
cp Readme.md distribution/Readme.md

# Build fat library
lipo -output distribution/librgmock.a -create \
  -arch armv7 build/Release-iphoneos/librgmock.a \
  -arch i386 build/Release-iphonesimulator/librgmock.a


# Make a ZIP distribution
cd distribution
zip -r RGMock.zip RGMock librgmock.a Readme.md
cd ..