set -e

echo "Building Framework..."
mkdir -p Distribution
xcodebuild -scheme "Universal Framework" -configuration "Release" > Distribution/build.log
open Distribution/
echo "Done."
