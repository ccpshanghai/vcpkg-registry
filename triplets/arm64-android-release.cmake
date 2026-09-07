# Copyright © 2025 CCP ehf.
set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_BUILD_TYPE "release")

set(VCPKG_CMAKE_SYSTEM_NAME Android)
# minSdk 31 (Android 12). Reaches scripts/toolchains/android.cmake as
# ANDROID_NATIVE_API_LEVEL / ANDROID_PLATFORM.
set(VCPKG_CMAKE_SYSTEM_VERSION 31)
# openssl and curl are autotools ports and need this to cross-configure.
set(VCPKG_MAKE_BUILD_TRIPLET "--host=aarch64-linux-android")

# vcpkg never derives ANDROID_ABI from VCPKG_TARGET_ARCHITECTURE — neither
# scripts/toolchains/android.cmake nor anything under scripts/ mentions it — and the NDK's
# own android.toolchain.cmake defaults to armeabi-v7a. So the triplet has to say it.
# Anything below that touches VCPKG_CMAKE_CONFIGURE_OPTIONS must APPEND, never set.
set(VCPKG_CMAKE_CONFIGURE_OPTIONS -DANDROID_ABI=arm64-v8a)

# Changes in vcpkg-tool (https://github.com/microsoft/vcpkg-tool/pull/1931) removed the ability to access the VCPKG_ROOT
# environment variable from inside the VCPKG build environment while VCPKG_LOAD_VCVARS_ENV is set to ON.
# For consistency, we have changed this for both windows & macos.
# More information available here: https://github.com/carbonengine/vcpkg-registry/pull/34
#
# ANDROID_NDK_HOME is added for this platform. scripts/toolchains/android.cmake reads it out
# of the environment, and its fallbacks are android-ndk-r13b and a Xamarin path — both dead.
# Without the passthrough the build environment does not carry it and configure fails with
# "Could not find android ndk".
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED PATH_TO_VCPKG_ROOT ANDROID_NDK_HOME)

set(CARBON_BUILD_TYPE "Release")

if (PORT MATCHES "carbon-.*")
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchains/arm64-android-triplet.cmake")
    set(VCPKG_HASH_ADDITIONAL_FILES "${CMAKE_CURRENT_LIST_DIR}/../toolchains/arm64-android-carbon.cmake")
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

# CPython, shared -- the same rule and the same reason as arm64-ios-release.cmake's python3
# block: a static libpython is a whole private interpreter, and blue.so, _trinity_vulkan.so
# and every Python-imported carbon .so would each get their own. On Android the failure is
# the one iOS measured ("initialization of X did not return an extension module"), and
# the app shell's payload contract requires libpython3.13.so by name (M6 second-half spec §5).
if (PORT MATCHES "^python3$")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif ()

# oneTBB, shared -- trinity/TriDevice.cpp:28 constructs a tbb::global_control at file scope,
# and with libtbb.a its initializer runs in link order beside TBB's own. iOS took SIGSEGV
# inside dlopen(_trinity_metal.so) for exactly this; bionic, like dyld, runs a DT_NEEDED
# library's initializers before the image that needs it, so the shared form is the fix here
# too rather than making that global lazy in trinity.
if (PORT MATCHES "^tbb$")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif ()

if (PORT MATCHES "libuv")
    list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DBUILD_TESTING=OFF")
endif()

if (PORT MATCHES "carbon-pdmprotowrapper")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "meshoptimizer")
    set(VCPKG_LIBRARY_LINKAGE static)
endif ()

if (PORT MATCHES "tinyfiledialogs")
    list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_POLICY_VERSION_MINIMUM=3.5")
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

