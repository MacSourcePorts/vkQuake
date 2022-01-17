# game/app specific values
export APP_VERSION="1.12.2"
export ICONSDIR="Misc"
export ICONSFILENAME="quake"
export PRODUCT_NAME="vkQuake"
export EXECUTABLE_NAME="vkquake"
export PKGINFO="APPLVKQ1"
export COPYRIGHT_TEXT="QUAKE Copyright © 1996-2021 id Software, Inc. All rights reserved."

# constants
export BUILT_PRODUCTS_DIR="release"
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export ICONS="${ICONSFILENAME}.icns"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"

CURRENT_ARCH=$(uname -m)
echo "CURRENT_ARCH: $CURRENT_ARCH"

# For parallel make on multicore boxes...
NCPU=`sysctl -n hw.ncpu`

# make the thing

# rm -rf "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

cd Quake
rm -rf "x86_64"
mkdir -p "x86_64" || exit 1;
rm -rf "arm64"
mkdir -p "arm64" || exit 1;

make clean
(ARCH=x86_64 make -j$NCPU) || exit 1;
(ARCH=arm64 make -j$NCPU) || exit 1;

cd x86_64
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" "${EXECUTABLE_FOLDER_PATH}"
echo dylibbundler -od -b -x ./"${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}" -d ./"${EXECUTABLE_FOLDER_PATH}"/libs-x86_64/ -p @executable_path/libs-x86_64/
dylibbundler -od -b -x ./"${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}" -d ./"${EXECUTABLE_FOLDER_PATH}"/libs-x86_64/ -p @executable_path/libs-x86_64/
cd ..

cd arm64
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" "${EXECUTABLE_FOLDER_PATH}"
echo dylibbundler -od -b -x ./"${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}" -d ./"${EXECUTABLE_FOLDER_PATH}"/libs-arm64/ -p @executable_path/libs-arm64/
dylibbundler -od -b -x ./"${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}" -d ./"${EXECUTABLE_FOLDER_PATH}"/libs-arm64/ -p @executable_path/libs-arm64/
cd ..

cd ..

# here we go
echo "Creating bundle '${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}'"

# create the app bundle
"../MSPScripts/build_app_bundle.sh"

# copy and generate some application bundle resources
lipo Quake/x86_64/"${EXECUTABLE_FOLDER_PATH}"/vkquake Quake/arm64/"${EXECUTABLE_FOLDER_PATH}"/vkquake -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/vkquake" -create

mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libs-x86_64"
cp -a "Quake/x86_64/${EXECUTABLE_FOLDER_PATH}/libs-x86_64/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libs-x86_64"

mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libs-arm64"
cp -a "Quake/arm64/${EXECUTABLE_FOLDER_PATH}/libs-arm64/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libs-arm64"

echo "bundle done."

"../MSPScripts/sign_and_notarize.sh" "$1"