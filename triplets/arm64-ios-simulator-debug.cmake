# Copyright © 2025 CCP ehf.
set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_BUILD_TYPE "release")

set(VCPKG_CMAKE_SYSTEM_NAME iOS)
set(VCPKG_OSX_ARCHITECTURES arm64)
# Must match CMAKE_OSX_DEPLOYMENT_TARGET in arm64-ios-carbon.cmake, or ports and their
# consumers are built against different floors.
set(VCPKG_OSX_DEPLOYMENT_TARGET 26.0)

# Autotools ports cannot detect that this is a cross-compile without help. vcpkg-make
# derives --host from VCPKG_TARGET_IS_IOS as "${TARGET_ARCH}-apple-darwin" and --build from
# the build machine, which on an Apple Silicon Mac is the *same string* -- so autoconf sets
# cross_compiling=no, runs a freshly built iOS a.out on macOS, and dies with
#   configure: error: cannot run C compiled programs. If you meant to cross compile, use --host
# libffi is the first port in carbon-blue's closure to hit it; CPython itself is autotools
# too. config.sub (>=2019) canonicalises this triple, and vcpkg_make.cmake honours an
# explicit --host over its own derivation. The Android triplets carry the same line for the
# same reason.
set(VCPKG_MAKE_BUILD_TRIPLET "--host=aarch64-apple-ios")
# scripts/toolchains/ios.cmake only auto-selects the simulator sysroot for x64 and x86,
# so arm64 has to name it here. Same CPU as the device triplet, different sysroot.
set(VCPKG_OSX_SYSROOT iphonesimulator)

# Changes in vcpkg-tool (https://github.com/microsoft/vcpkg-tool/pull/1931) removed the ability to access the VCPKG_ROOT
# environment variable from inside the VCPKG build environment while VCPKG_LOAD_VCVARS_ENV is set to ON.
# For consistency, we have changed this for both windows & macos.
# More information available here: https://github.com/carbonengine/vcpkg-registry/pull/34
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED PATH_TO_VCPKG_ROOT)

set(CARBON_BUILD_TYPE "Debug")

if (PORT MATCHES "carbon-.*")
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchains/arm64-ios-triplet.cmake")
    set(VCPKG_HASH_ADDITIONAL_FILES "${CMAKE_CURRENT_LIST_DIR}/../toolchains/arm64-ios-carbon.cmake")
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

# --------------------------------------------------------------------------------------
# Libraries that carry process-global runtime state are DYNAMIC here, whatever the default
# above says. There are two, and both were found by an app that crashed rather than by
# reading.
#
# The rule: a static archive linked into N shared objects is copied N times, and if what was
# copied is a runtime -- type objects, registries, an allocator, a thread pool -- then those
# are N runtimes that cannot recognise each other's objects. Worse, they are N sets of static
# initializers running in link order inside one image instead of one set that dyld is
# guaranteed to run first. Neither failure exists on Windows (everything is a DLL) or on
# arm64-osx-release (its default is dynamic), which is why nothing caught either of these
# until iOS.
# --------------------------------------------------------------------------------------

# CPython. It carries PyModule_Type, the type objects, the interpreter state and the GIL, so a
# static copy is a whole private interpreter -- and iOS had SIX: blue.so, _carbonsocket.so,
# carbonselect.so, _greenlet.so, _scheduler.so and _carbonssl.so, about 46 MB of duplicated
# runtime. `import _carbonsocket` then fails with
#   SystemError: initialization of _carbonsocket did not return an extension module
# because PyInit__carbonsocket returns a module of its OWN PyModule_Type while the importing
# interpreter checks it against blue.so's. Blue's startup dies on exactly that
# ("Failed acquiring carbon-io socket module"), and PyInit_blue's only failure path sets no
# Python exception, so the app sees a contentless
#   SystemError: initialization of blue failed without raising an exception
#
# The port needs nothing: it always passes --enable-shared on unix and only patches the shared
# library out for static linkage, and ccp_customizations/ios-allow-non-framework.patch already
# permits a non-framework CPython on iOS. Measured after: _carbonsocket.so 5.6 MB -> 300 KB.
if (PORT MATCHES "^python3$")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif ()

# oneTBB. trinity/TriDevice.cpp:28 has a file-scope
#   tbb::global_control* g_threadCountControl = new tbb::global_control( ... );
# and with libtbb.a that initializer runs in link order beside TBB's own -- TriDevice's went
# first, so global_control_impl::create dereferenced TBB's not-yet-constructed control storage
# and the app took SIGSEGV at 0x28 inside dlopen of _trinity_metal.so, in
# dyld4::Loader::findAndRunAllInitializers. As a dylib, dyld runs TBB's initializers before the
# image that links it, which is what macOS has always relied on.
#
# The alternative was making that global lazy in trinity, and it is the wrong fix: it would
# repair one call site of a guarantee that every other TBB static-init user also needs.
if (PORT MATCHES "^tbb$")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif ()
