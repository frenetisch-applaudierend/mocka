echo "-----------------------------------"
echo "RGMock library distribution builder"
echo "-----------------------------------"
echo

build() {
  local target=$1
  local arch=$2
  local sdk=$3
	
  echo -n "  Building for architecture $arch ($sdk)... "
  xcodebuild -target $1 -configuration Release -arch "$arch" -sdk "$sdk" build PRODUCT_NAME="rgmock-$arch" > "build/rgmock-$arch.buildlog"
  echo "Done"
}

# Build the libraries
echo "Building subtype libraries..."
xcodebuild clean > /dev/null
mkdir -p "build/"
build librgmock-ios armv7  iphoneos
build librgmock-ios armv7s iphoneos
build librgmock-ios i386   iphonesimulator
build librgmock-osx x86_64 macosx
echo "Done"
echo

# Copy Resources
echo -n "Copying resources to the distribution directory..."
rm -rf distribution
mkdir -p distribution/RGMock
cp -R build/Release-iphoneos/include/RGMock/ distribution/RGMock/RGMock/
cp Readme.md distribution/RGMock/Readme.md
echo "Done"
echo

# Build fat library
echo -n "Creating universal library... "
lipo \
  build/Release-iphoneos/librgmock-armv7.a \
  build/Release-iphoneos/librgmock-armv7s.a \
  build/Release-iphonesimulator/librgmock-i386.a \
  build/Release/librgmock-x86_64.a \
  -create -output distribution/RGMock/librgmock.a
echo "Done"
echo


# Make a ZIP distribution
echo "Creating ZIP..."
cd distribution
zip -r RGMock.zip RGMock
cd ..
echo "Done"
echo

open distribution