#!/bin/bash

if [ $# -le 4 ]; then
  echo Usage: $0 yocto_version arch browser_version browser [libc_flavour]
  echo E.g. $0 master aarch64 ozone-wayland electron
  echo E.g. $0 kirkstone aarch64 ozone-wayland chromium
  exit 1
fi

declare -A arch_qemu_dict
arch_qemu_dict["arm"]="qemuarm"
arch_qemu_dict["aarch64"]="qemuarm64"
arch_qemu_dict["riscv"]="qemuriscv64"
arch_qemu_dict["x86-64"]="qemux86-64"

yocto_version=$1
arch=$2
browser_version=$3
browser=$4
libc_flavour=$5

kas_file_name=$yocto_version-$browser_version-$arch-$browser

if [ -n "$libc_flavour" ]; then
  kas_file_name=$libc_flavour-$kas_file_name
else
  kas_file_name=glibc-$kas_file_name
fi

# check if it needs to be built, if the flag has been set
#if [ -d /yocto/test-images/$kas_file_name ]; then
#  echo Image has been already built, exiting.
#  exit 0
#fi

cd /yocto/$yocto_version

# Ensure all required Yocto subdirectories exist with proper permissions
# This creates the shared directories that are used across all builds
mkdir -p /yocto/yocto_dl
mkdir -p /yocto/yocto_sstate_chromium
mkdir -p /yocto/yocto_ccache
mkdir -p /yocto/test-images
chmod 755 /yocto/yocto_dl /yocto/yocto_sstate_chromium /yocto/yocto_ccache /yocto/test-images

if [ "$arch" = "riscv" ]; then
  OPENSBI="opensbi"
else
  OPENSBI=""
fi

qemu_machine=${arch_qemu_dict[$arch]}

rm -rf ./build/tmp/deploy/images/$qemu_machine

kas checkout --update ./meta-chromium-test/kas/$kas_file_name-test.yml || exit 1

# Clean previous builds - adjust packages based on browser
if [ "$browser" = "electron" ]; then
  BROWSER_PACKAGES="electron-ozone-wayland electron-ozone-x11"
else
  BROWSER_PACKAGES="chromium-ozone-wayland chromium-x11"
fi

kas shell ./meta-chromium-test/kas/$kas_file_name-test.yml -c "bitbake -c clean $BROWSER_PACKAGES \
         virtual/kernel $OPENSBI" || exit 1

# Build the image
kas build ./meta-chromium-test/kas/$kas_file_name-test.yml || exit 1

# Copy the built image to test images directory
if [ -d ./build/tmp/deploy/images/$qemu_machine ]; then
  echo "Copying built image to /yocto/test-images/$kas_file_name"
  rm -rf /yocto/test-images/$kas_file_name
  cp -r ./build/tmp/deploy/images/$qemu_machine /yocto/test-images/$kas_file_name
  echo "Successfully created test image: $kas_file_name"
  ls -la /yocto/test-images/$kas_file_name
else
  echo "ERROR: Built image directory not found: ./build/tmp/deploy/images/$qemu_machine"
  exit 1
fi
