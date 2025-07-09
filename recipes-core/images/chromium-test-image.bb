require recipes-sato/images/core-image-sato.bb

# Install the preferred Chromium provider (set via KAS configuration)
IMAGE_INSTALL += "${PREFERRED_PROVIDER_chromium} chromium-tests"

SUMMARY = "Test image for Chromium browser builds"
DESCRIPTION = "This image contains the configured Chromium variant for testing purposes."

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
