#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

if [ ! -f "$XCODE_PATH" ]; then
    echo "${XCODE_PATH} does not exist, skipping"
    exit 0
fi

echo "unpacking xcode"
xip -x ${XCODE_PATH}
#
echo "Move Xcode to /Applications"
sudo mv ~/Xcode*.app /Applications/

#echo "xattar remove quarantine attributes"
XCODE_APP=$(ls -d /Applications/Xcode*.app)
sudo xattr -dr com.apple.quarantine ${XCODE_APP}

echo "Verify & configure Xcode..."
sudo /usr/bin/xcode-select -s ${XCODE_APP}/Contents/Developer
sudo /usr/bin/xcodebuild -license accept
sudo /usr/bin/xcodebuild -runFirstLaunch

exit 0