echo "-----------------------------------"
echo "Mocka library distribution builder"
echo "-----------------------------------"
echo

build() {
  local target=$1
  local arch=$2
  local sdk=$3
	
  echo -n "  Building for architecture $arch ($sdk)... "
  xcodebuild -target $1 -configuration Release -arch "$arch" -sdk "$sdk" build PRODUCT_NAME="mocka-$arch" > "build/mocka-$arch.buildlog"
  echo "Done"
}

# Build the libraries
echo "Building subtype libraries..."
xcodebuild clean > /dev/null
mkdir -p "build/"
build libmocka-ios armv7  iphoneos
build libmocka-ios armv7s iphoneos
build libmocka-ios i386   iphonesimulator
build libmocka-osx x86_64 macosx
echo "Done"
echo

# Copy Resources
echo -n "Copying resources to the distribution directory..."
rm -rf distribution
mkdir -p distribution/Mocka
cp -R build/Release-iphoneos/include/Mocka/ distribution/Mocka/Mocka/
cp Readme.md distribution/Mocka/Readme.md
echo "Done"
echo

# Build fat library
echo -n "Creating universal library... "
lipo \
  build/Release-iphoneos/libmocka-armv7.a \
  build/Release-iphoneos/libmocka-armv7s.a \
  build/Release-iphonesimulator/libmocka-i386.a \
  build/Release/libmocka-x86_64.a \
  -create -output distribution/Mocka/libmocka.a
echo "Done"
echo


# Make a ZIP distribution
echo "Creating ZIP..."
cd distribution
zip -r Mocka.zip Mocka
cd ..
echo "Done"
echo

open distribution