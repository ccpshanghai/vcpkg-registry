vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:ccpshanghai/blueexposure.git
  REF e32445e39efc532c6d0991a6964521d7a33c9a90
  HEAD_REF main
  # Both Android fixes live in the fork's source now (ccpshanghai/blueexposure#1) instead of in
  # PATCHES here: `long` and `int64_t` are the same type under bionic on LP64, which three traits
  # specialisations did not expect, and three interfaces blue dynamic_casts to across shared
  # objects needed key functions, because the NDK's libc++abi compares type_info by address. The
  # second is ABI-shaped -- it adds a virtual -- which is precisely why it should not be a
  # downstream patch: a consumer could otherwise build unpatched source against a patched header.
  # 2.2.0#2 (ccpshanghai/blueexposure e32445e): the same two fixes made to build and link with
  # MSVC, every change inside #if defined( _MSC_VER ), so Clang builds compile what #1 did.
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
  -DBUILD_TESTING=OFF
  -DVCPKG_USE_HOST_TOOLS=ON
  -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
  -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()