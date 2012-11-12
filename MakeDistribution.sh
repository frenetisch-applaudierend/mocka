#!/bin/sh

echo "Building Framework..."
xcodebuild -scheme "Mocka Framework" -configuration "Release" > /dev/null
echo "Done."

