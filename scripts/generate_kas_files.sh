#!/bin/bash

# Generate KAS files for all combinations
# Usage: generate_kas_files.sh

YOCTO_VERSIONS=("kirkstone" "scarthgap" "walnascar" "master")
CHROMIUM_VERSIONS=("ozone-wayland" "x11")
LIBC_FLAVOURS=("glibc" "musl")
ARCHS=("arm" "aarch64" "riscv" "x86-64")

declare -A arch_machine_dict
arch_machine_dict["arm"]="qemuarm"
arch_machine_dict["aarch64"]="qemuarm64"
arch_machine_dict["riscv"]="qemuriscv64"
arch_machine_dict["x86-64"]="qemux86-64"

BASE_DIR="/home/cal/work/yocto/poky/sources/meta-chromium-test/kas"

for yocto_version in "${YOCTO_VERSIONS[@]}"; do
    for chromium_version in "${CHROMIUM_VERSIONS[@]}"; do
        for libc_flavour in "${LIBC_FLAVOURS[@]}"; do
            for arch in "${ARCHS[@]}"; do
                # Skip riscv for kirkstone
                if [ "$yocto_version" = "kirkstone" ] && [ "$arch" = "riscv" ]; then
                    continue
                fi

                machine=${arch_machine_dict[$arch]}
                kas_file_name="$libc_flavour-$yocto_version-$chromium_version-$arch-test.yml"

                echo "Creating $kas_file_name"

                cat > "$BASE_DIR/$kas_file_name" << EOF
header:
  version: 11
  includes:
    - kas/chromium/$chromium_version.yml
    - kas/repos/$yocto_version.yml
    - kas/common.yml
EOF

                # Add musl include if needed
                if [ "$libc_flavour" = "musl" ]; then
                    echo "    - kas/musl.yml" >> "$BASE_DIR/$kas_file_name"
                fi

                cat >> "$BASE_DIR/$kas_file_name" << EOF

machine: $machine

local_conf_header:
  image_name: |
    IMAGE_NAME = "$libc_flavour-$yocto_version-$chromium_version-${arch//-/_}"
EOF
            done
        done
    done
done

echo "All KAS files generated successfully!"
