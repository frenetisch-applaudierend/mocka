set -e

echo "Building Framework..."
xcodebuild -scheme "Universal Framework" -configuration "Debug" > /dev/null
open Distribution/
echo "Done."
