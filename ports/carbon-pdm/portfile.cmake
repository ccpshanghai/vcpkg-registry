vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:ccpshanghai/pdm.git
  REF 13d210d4fd57674b268828524aa87beb2e7c49b5
  HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
  ${FEATURE_OPTIONS}
  -DBUILD_TESTING=OFF
  -DVCPKG_USE_HOST_TOOLS=ON
  -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
ccp_externalize_apple_debuginfo()
