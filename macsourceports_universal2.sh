# game/app specific values
export APP_VERSION="1.12.2"
export ICONSDIR="Misc"
export ICONSFILENAME="quake"
export PRODUCT_NAME="vkQuake"
export EXECUTABLE_NAME="vkquake"
export PKGINFO="APPLVKQ1"
export COPYRIGHT_TEXT="QUAKE Copyright © 1996-2021 id Software, Inc. All rights reserved."

#constants
source ../MSPScripts/constants.sh

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

cd Quake
make clean
(ARCH=x86_64 make -j$NCPU) || exit 1;
cd ..
mkdir -p ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mv Quake/"${EXECUTABLE_NAME}" ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

cd Quake
make clean
(ARCH=arm64 make -j$NCPU) || exit 1;
cd ..
mkdir -p ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mv Quake/"${EXECUTABLE_NAME}" ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

# create the app bundle
"../MSPScripts/build_app_bundle.sh"

"../MSPScripts/sign_and_notarize.sh" "$1"