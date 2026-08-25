vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  # M3 = imageio is the seventh fork (spec §2.5): ASTC work lives on ccpshanghai/imageio
  # branch m3-ktx2-astc. Landed bottom-up: fork -> port URL/REF (here) -> registry PR ->
  # trinity baseline bump. "main" tracks upstream + merge-back at fork chains' landing.
  URL git@github.com:ccpshanghai/imageio.git
  REF 2e2ffff015614309f84ed39e664dfaf27ec81b37
  HEAD_REF m3-ktx2-astc
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
  ${FEATURE_OPTIONS}
  -DBUILD_TESTING=OFF
  -DVCPKG_USE_HOST_TOOLS=ON
  -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
  -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
ccp_externalize_apple_debuginfo()