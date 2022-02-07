#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

if [ ! -f "${XCODE_PATH}" ]; then
    echo "${XCODE_PATH} does not exist, skipping"
    exit 0
fi

echo "generate dummy file to handle 'not enough storage when unpacking xip'"
dd if=/dev/urandom of=/tmp/dummy-20gb bs=1024 count=$[1024 * 1024 * 20]
sleep 10s
rm /tmp/dummy-20gb

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

echo "Cleanup Xcode installer files (optional, it might be provisioned via cd_files)"
rm "${XCODE_PATH}" || true

exit 0