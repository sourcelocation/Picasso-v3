#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "[*] Picasso Build Script"
chmod a+rwx ./bin/swiftshield

if [ ! -d "Picasso_dbg" ]; then
    mkdir Picasso_dbg
fi

rm -rf Picasso_dbg/TSRootHelper
rm -rf Picasso_dbg/Picasso
rm -rf Picasso_dbg/Picasso.xcodeproj

cp -r TSRootHelper Picasso_dbg
cp -r Picasso Picasso_dbg
cp -r Picasso.xcodeproj Picasso_dbg

cd Picasso_dbg

#rm -rf build
rm -rf .git
rm -rf bin/

rm -rf Picasso_dbg*
# try removing *.tipa, but don't fail if there are no files
if ls *.tipa 1>/dev/null 2>&1; then
    rm -rf *.tipa
fi

WORKING_LOCATION="$(pwd)"
APPLICATION_NAME=Picasso

if [ ! -d "build" ]; then
    mkdir build
fi

cd build

# echo $WORKING_LOCATION/$APPLICATION_NAME
echo $WORKING_LOCATION/$APPLICATION_NAME.xcodeproj

# COPIED_FILES
# if [ "$COPIED_FILES" = true ]; then
#     echo "[*] Obfuscating..."
#     chmod a+rwx ./bin/swiftshield
#     sudo ./bin/swiftshield obfuscate \
#         --project-file "$WORKING_LOCATION/$APPLICATION_NAME.xcodeproj" \
#         --scheme "$APPLICATION_NAME" \
#         --input-files PicassoApp.swift,DRM.swift,KFDSwift.swift,SourcedRepoFetcher.swift,ExploitKit.swift,FilePickerViewControllerDelegate.swift
# fi

echo "[*] Building..."
xcodebuild -project "$WORKING_LOCATION/$APPLICATION_NAME.xcodeproj" \
    -scheme "$APPLICATION_NAME" \
    -configuration Debug \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedDataApp" \
    -destination 'generic/platform=iOS' \
    clean build \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO"

DD_APP_PATH="$WORKING_LOCATION/build/DerivedDataApp/Build/Products/Debug-iphoneos/$APPLICATION_NAME.app"
TARGET_APP="$WORKING_LOCATION/build/$APPLICATION_NAME.app"
cp -r "$DD_APP_PATH" "$TARGET_APP"

echo "[*] Stripping signature..."
codesign --remove "$TARGET_APP"
if [ -e "$TARGET_APP/_CodeSignature" ]; then
    rm -rf "$TARGET_APP/_CodeSignature"
fi
if [ -e "$TARGET_APP/embedded.mobileprovision" ]; then
    rm -rf "$TARGET_APP/embedded.mobileprovision"
fi

# TODO: TS root helper

echo "[*] Adding entitlements..."
chmod a+x ../../bin/ldid
../../bin/ldid -S../../Picasso/PicassoTroll.entitlements $TARGET_APP

echo "[*] Building RootHelper..."
cd $WORKING_LOCATION/TSRootHelper
if ! type "gmake" > /dev/null; then
    echo "[!] gmake not found, using macOS bundled make instead"
    make clean
    make
else
    gmake clean
    gmake -j"$(nproc --ignore 1)"
fi
cp $WORKING_LOCATION/TSRootHelper/.theos/obj/debug/PicassoRootHelper $WORKING_LOCATION/build/Picasso.app/picassoroothelper
cd -

echo "[*] Packaging..."
mkdir Payload
cp -r Picasso.app Payload/Picasso.app
zip -vr Picasso_dbg.tipa Payload

echo "[*] All done, cleaning up..."
rm -rf Picasso.app
rm -rf Payload

cd ../..
mv "$WORKING_LOCATION/build/Picasso_dbg.tipa" .
#rm -rf "$WORKING_LOCATION/build/"
