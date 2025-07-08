require recipes-sato/images/core-image-sato.bb

IMAGE_INSTALL += "chromium-ozone-wayland chromium-x11 chromium-tests"

SUMMARY = "Test image for Chromium browser builds"
DESCRIPTION = "This image contains both Chromium variants (Ozone Wayland and X11) for testing purposes."

# Add common packages for testing
IMAGE_INSTALL += " \
    packagegroup-core-x11-sato \
    packagegroup-core-x11-xserver \
    xorg-minimal-fonts \
    liberation-fonts \
    ttf-dejavu-sans \
    ttf-dejavu-sans-mono \
    ttf-dejavu-serif \
"

# Development and debugging tools
IMAGE_INSTALL += " \
    strace \
    gdb \
    valgrind \
    procps \
    util-linux \
    coreutils \
"

# Network tools for testing
IMAGE_INSTALL += " \
    curl \
    wget \
    openssh-sftp-server \
    openssh-scp \
"

# Additional features for testing
EXTRA_IMAGE_FEATURES += "debug-tweaks"
