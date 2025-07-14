#!/bin/bash

if [ $# -le 3 ]; then
  echo Usage: $0 yocto_version arch chromium_version [libc_flavour]
  echo E.g. $0 kirkstone aarch64 ozone-wayland
  exit 1
fi

declare -A arch_qemu_dict
arch_qemu_dict["arm"]="qemuarm"
arch_qemu_dict["aarch64"]="qemuarm64"
arch_qemu_dict["riscv"]="qemuriscv64"
arch_qemu_dict["x86-64"]="qemux86-64"

yocto_version=$1
arch=$2
chromium_version=$3
libc_flavour=$4

kas_file_name=$yocto_version-$chromium_version-$arch

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

if [ "$arch" = "riscv" ]; then
  OPENSBI="opensbi"
else
  OPENSBI=""
fi

qemu_machine=${arch_qemu_dict[$arch]}

rm -rf ./build/tmp/deploy/images/$qemu_machine

kas checkout --update ./meta-chromium-test/kas/$kas_file_name-test.yml || exit 1

# Clean previous builds
kas shell ./meta-chromium-test/kas/$kas_file_name-test.yml -c "bitbake -c clean chromium-ozone-wayland chromium-x11 \
         virtual/kernel $OPENSBI" || exit 1

# Build the image
kas build ./meta-chromium-test/kas/$kas_file_name-test.yml || exit 1

# Copy the built image to test images directory
cp -r ./build/tmp/deploy/images/$qemu_machine /yocto/test-images/$kas_file_name
