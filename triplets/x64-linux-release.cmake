# Copyright © 2025 CCP ehf.
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_BUILD_TYPE "release")

set(VCPKG_CMAKE_SYSTEM_NAME Linux)

# Same passthrough as the POSIX triplets: preset environment blocks do not land in the
# build tree, and the carbon toolchain includes $ENV{PATH_TO_VCPKG_ROOT}/scripts/toolchains/linux.cmake.
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED PATH_TO_VCPKG_ROOT)

set(CARBON_BUILD_TYPE "Release")

if (PORT MATCHES "carbon-.*")
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-linux-triplet.cmake")
    set(VCPKG_HASH_ADDITIONAL_FILES "${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-linux-carbon.cmake")
endif ()

if (PORT MATCHES "libyaml")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "ccd")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "curl")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "openssl")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "protobuf")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "zlib")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libuv")
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DBUILD_TESTING=OFF")
endif()

if (PORT MATCHES "carbon-pdmprotowrapper")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "meshoptimizer")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "tinyfiledialogs")
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_POLICY_VERSION_MINIMUM=3.5")
endif ()

if (PORT MATCHES "libjpeg-turbo")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libsquish")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libpng")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "freetype")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "brotli")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "bzip2")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libogg")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libvorbis")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "openvdb")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "boost-*")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "imath")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "blosc")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "lz4")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "zstd")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "libvpx")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "yaml-cpp")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()