set -e

echo "Building Framework..."
xcodebuild -scheme "Universal Framework" -configuration "Debug" > Distribution/build.log
open Distribution/
echo "Done."
