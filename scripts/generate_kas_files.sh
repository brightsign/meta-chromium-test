#!/bin/bash

# Generate KAS files for all combinations
# Usage: generate_kas_files.sh [browser]
# browser: chromium, electron, or both (default)

BROWSER=${1:-both}
YOCTO_VERSIONS=("kirkstone" "scarthgap" "walnascar" "master")
LIBC_FLAVOURS=("glibc" "musl")
ARCHS=("arm" "aarch64" "riscv" "x86-64")

declare -A arch_machine_dict
arch_machine_dict["arm"]="qemuarm"
arch_machine_dict["aarch64"]="qemuarm64"
arch_machine_dict["riscv"]="qemuriscv64"
arch_machine_dict["x86-64"]="qemux86-64"

BASE_DIR="/home/cal/work/yocto/poky/sources/meta-chromium-test/kas"

# Validate browser argument
if [ "$BROWSER" != "chromium" ] && [ "$BROWSER" != "electron" ] && [ "$BROWSER" != "both" ]; then
    echo "Error: Browser must be 'chromium', 'electron', or 'both'"
    echo "Usage: generate_kas_files.sh [browser]"
    exit 1
fi

# Determine which browsers to generate
if [ "$BROWSER" = "both" ]; then
    BROWSERS=("chromium" "electron")
else
    BROWSERS=("$BROWSER")
fi

echo "Generating KAS files for: ${BROWSERS[*]}"

for current_browser in "${BROWSERS[@]}"; do
    echo "Processing $current_browser..."
    
    # Define versions per browser
    if [ "$current_browser" = "electron" ]; then
        BROWSER_VERSIONS=("ozone-wayland" "ozone-x11")
    else
        BROWSER_VERSIONS=("ozone-wayland" "x11")
    fi

    for yocto_version in "${YOCTO_VERSIONS[@]}"; do
        for browser_version in "${BROWSER_VERSIONS[@]}"; do
            for libc_flavour in "${LIBC_FLAVOURS[@]}"; do
                for arch in "${ARCHS[@]}"; do
                    # Skip riscv for kirkstone
                    if [ "$yocto_version" = "kirkstone" ] && [ "$arch" = "riscv" ]; then
                        continue
                    fi

                    machine=${arch_machine_dict[$arch]}
                    kas_file_name="$libc_flavour-$yocto_version-$browser_version-$arch-$current_browser-test.yml"

                    echo "Creating $kas_file_name"

                    cat > "$BASE_DIR/$kas_file_name" << EOF
header:
  version: 11
  includes:
    - kas/$current_browser/$browser_version.yml
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
    IMAGE_NAME = "$libc_flavour-$yocto_version-$browser_version-${arch//-/_}-$current_browser"
EOF
                done
            done
        done
    done
done

echo "All KAS files generated successfully for: ${BROWSERS[*]}!"
