set -e

echo "Building Framework..."
mkdir -p Distribution
xcodebuild -scheme "Universal Framework" -configuration "Debug" > Distribution/build.log
open Distribution/
echo "Done."
