#!/bin/bash

set -e

# Global Valuess
readonly TAG_VERSION="v1.1.0"
readonly WEBP_GIT_URL="https://chromium.googlesource.com/webm/libwebp"
readonly WEBP_SRC_DIR="libwebp"

# Extract Xcode version.
readonly XCODE=$(xcodebuild -version | grep Xcode | cut -d " " -f2)
if [[ -z "${XCODE}" ]]; then
  echo "Xcode not available"
  exit 1
fi

# Global Static 
readonly DEVELOPER=$(xcode-select --print-path)
readonly PLATFORMSROOT="${DEVELOPER}/Platforms"
readonly OLDPATH=${PATH}
readonly EXTRA_CFLAGS="-fembed-bitcode"

usage() {
cat <<EOF
Usage: sh $0 command [argument]

command:
  all:          builds all frameworks
  ios:          builds iOS framework
  tvos:         builds tvOS framework
  macos:        builds macOS framework
  watchos:      builds watchOS framework       
EOF
}

# Clone a fresh copy of the libwep source code
clone_repo() {
    # Clone a copy of the WebP source code
    if [[ ! -d ${WEBP_SRC_DIR} ]]; then
        git clone --depth 1 --branch ${TAG_VERSION} ${WEBP_GIT_URL}
    fi

    # Move to the directory
    cd ${WEBP_SRC_DIR}
}

build_ios() {
  # Query for the SDK version installed
  SDK=$(xcodebuild -showsdks \
    | grep iphoneos | sort | tail -n 1 | awk '{print substr($NF, 9)}'
  )

  # Check to make sure we found the SDK version
  if [[ -z "${SDK}" ]]; then
    echo "iOS SDK not available"
    exit 1
  else 
    echo "iOS SDK Version ${SDK}"
  fi

  BUILDDIR="$(pwd)/iosbuild"

  build_common
  build_slice "x86_64" "x86_64-apple-ios13.0-macabi" "x86_64-apple-darwin" "MacOSX" ""
  build_slice "armv7" "armv7-apple-ios" "arm-apple-darwin" "iPhoneOS" "-miphoneos-version-min=9.0"
  build_slice "arm64" "aarch64-apple-ios" "arm-apple-darwin" "iPhoneOS" "-miphoneos-version-min=9.0"
  build_slice "x86_64" "x86_64-apple-ios" "x86_64-apple-darwin" "iPhoneSimulator" "-miphoneos-version-min=9.0"
  build_slice "i386" "i386-apple-ios" "i386-apple-darwin" "iPhoneSimulator" "-miphoneos-version-min=9.0"
}

build_tvos() {
  # Query for the SDK version installed
  SDK=$(xcodebuild -showsdks \
    | grep appletvos | sort | tail -n 1 | awk '{print substr($NF, 10)}'
  )

  # Check to make sure we found the SDK version
  if [[ -z "${SDK}" ]]; then
    echo "tvOS SDK not available"
    exit 1
  else 
    echo "tvOS SDK Version ${SDK}"
  fi

  BUILDDIR="$(pwd)/tvosbuild"

  build_common
  build_slice "arm64" "aarch64-apple-tvos" "arm-apple-darwin" "AppleTVOS" "-mtvos-version-min=9.0"
  build_slice "x86_64" "x86_64-apple-tvos" "x86_64-apple-darwin" "AppleTVSimulator" "-mtvos-version-min=9.0"
}

build_macos() {
  # Query for the SDK version installed
  SDK=$(xcodebuild -showsdks \
    | grep macosx | sort | tail -n 1 | awk '{print substr($NF, 7)}'
  )

  # Check to make sure we found the SDK version
  if [[ -z "${SDK}" ]]; then
    echo "macOS SDK not available"
    exit 1
  else 
    echo "macOS SDK Version ${SDK}"
  fi

  BUILDDIR="$(pwd)/macosbuild"

  build_common
  build_slice "x86_64" "x86_64-apple-macos10.12" "x86_64-apple-darwin" "MacOSX" "-mmacosx-version-min=10.9"
}

build_watchos() {
  # Query for the SDK version installed
  SDK=$(xcodebuild -showsdks \
    | grep watchos | sort | tail -n 1 | awk '{print substr($NF, 8)}'
  )

  # Check to make sure we found the SDK version
  if [[ -z "${SDK}" ]]; then
    echo "watchOS SDK not available"
    exit 1
  else 
    echo "watchOS SDK Version ${SDK}"
  fi

  BUILDDIR="$(pwd)/watchosbuild"

  build_common
  build_slice "arm64_32" "arm64_32-apple-watchos" "arm-apple-darwin" "WatchOS" "-mwatchos-version-min=2.0"
  build_slice "armv7k" "armv7k-apple-watchos" "arm-apple-darwin" "WatchOS" "-mwatchos-version-min=2.0"
  build_slice "x86_64" "x86_64-apple-watchos" "x86_64-apple-darwin" "WatchSimulator" "-mwatchos-version-min=2.0"
  build_slice "i386" "i386-apple-watchos" "i386-apple-darwin" "WatchSimulator" "-mwatchos-version-min=2.0"
}

# Perform common set-up/reset between builds
build_common() {
  SRCDIR=$(dirname $0)

  # Remove previous build folders
  rm -rf ${BUILDDIR}
  mkdir -p ${BUILDDIR}

  # Configure build settings
    if [[ ! -e ${SRCDIR}/configure ]]; then
      if ! (cd ${SRCDIR} && sh autogen.sh); then
        cat <<EOT
Error creating configure script!
This script requires the autoconf/automake and libtool to build. MacPorts can
be used to obtain these:
http://www.macports.org/install.php
EOT
        exit 1
      fi
    fi
}

build_slice() {
  ARCH=$1
  TARGET=$2
  HOST=$3
  PLATFORM=$4
  VERSION=$5
  
  ROOTDIR="${BUILDDIR}/${PLATFORM}-${ARCH}"
  mkdir -p "${ROOTDIR}"
  
  DEVROOT="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain"
  SDKROOT="${PLATFORMSROOT}/"
  SDKROOT+="${PLATFORM}.platform/Developer/SDKs/${PLATFORM}.sdk/"
  CFLAGS="-arch ${ARCH} -pipe -isysroot ${SDKROOT} -O3 -DNDEBUG -target ${TARGET}"
  CFLAGS+=" ${VERSION} ${EXTRA_CFLAGS}"

  set -x
  export PATH="${DEVROOT}/usr/bin:${OLDPATH}"
  ${SRCDIR}/configure --host=${HOST} --prefix=${ROOTDIR} \
    --build=$(${SRCDIR}/config.guess) \
    --disable-shared --enable-static \
    --enable-libwebpdecoder --enable-swap-16bit-csp \
    --enable-libwebpmux \
    CFLAGS="${CFLAGS}"
  set +x

  # run make only in the src/ directory to create libwebp.a/libwebpdecoder.a
  cd src/
  make V=0
  make install

  make clean
  cd ..

  export PATH=${OLDPATH}
}

# Commands
COMMAND="$1"
case "$COMMAND" in

      "all")
        clone_repo
        build_ios
        build_tvos
        build_macos
        build_watchos
        exit 0
        ;;

    "ios")
        clone_repo
        build_ios
        exit 0
        ;;
    
    "tvos")
        clone_repo
        build_tvos
        exit 0
        ;;

    "macos")
        clone_repo
        build_macos
        exit 0
        ;;

    "watchos")
        clone_repo
        build_watchos
        exit 0
        ;;
esac

# Print usage instructions if no arguments were set
if [ "$#" -eq 0 -o "$#" -gt 3 ]; then
    usage
    exit 1
fi