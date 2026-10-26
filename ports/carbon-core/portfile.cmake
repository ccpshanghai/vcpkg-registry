vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:ccpshanghai/core.git
  REF c8e50e0851897cdea0f2669a863f3616eb9356ab
  HEAD_REF mobile-exp
)

# The git tree spells these Ccp* while CMakeLists.txt spells CCP*. Windows finds
# them because its filesystem is case-insensitive. Linux does not.
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "CCPDefines.cpp" "CcpDefines.cpp")
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "CCPMemoryTrackerMutex.h" "CcpMemoryTrackerMutex.h")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
      documentation BUILD_DOCUMENTATION
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
