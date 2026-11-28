# Copyright © 2025 CCP ehf.
# This toolchain is meant for use inside a vcpkg triplet. See `README.md` for more details.
# Shared by arm64-ios-* and arm64-ios-simulator-*; the sysroot is the triplet's business.
include($ENV{PATH_TO_VCPKG_ROOT}/scripts/toolchains/ios.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../toolchains/arm64-ios-carbon.cmake)
