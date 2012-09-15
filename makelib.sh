# Build the libraries
xcodebuild -target RGMock -configuration Release -arch i386 -sdk iphonesimulator clean build
xcodebuild -target RGMock -configuration Release -arch armv7 -sdk iphoneos clean build

# Copy Resources
rm -rf distribution
mkdir -p distribution/RGMock
cp -R build/Release-iphoneos/include/RGMock/ distribution/RGMock/RGMock/
cp Readme.md distribution/RGMock/Readme.md

# Build fat library
lipo -output distribution/RGMock/librgmock.a -create \
  -arch armv7 build/Release-iphoneos/librgmock.a \
  -arch i386 build/Release-iphonesimulator/librgmock.a


# Make a ZIP distribution
cd distribution
zip -r RGMock.zip RGMock
cd ..