vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  # M3 = imageio is the seventh fork (spec §2.5): the ASTC/KTX2 work lives on
  # ccpshanghai/imageio. Pins point at the merged commit on the fork's mobile-exp rather than
  # a topic branch's tip -- a pin to a retired branch breaks the day the branch goes (the same
  # trap the trinity pin fix walked one level up). Landed bottom-up: fork -> port URL/REF
  # (here) -> registry PR -> trinity baseline bump.
  #
  # prototype-texture-conversion M2: the imageio PR's head (uncompressed and 3D KTX2, R16F as
  # VkFormat 76, OpenVDB optional, ASTC volumes, five HostBitmap/TGA/build fixes). While that
  # PR is open the REF is its head; it is re-pinned to the squash commit on mobile-exp when it
  # merges, before this registry PR merges.
  URL git@github.com:ccpshanghai/imageio.git
  REF 14e043e96f673a334542b89a848e71e96e018c62
  HEAD_REF mobile-exp
)

# NanoVDB volume support is the `openvdb` feature: a default feature on the desktop triplets and
# off on Android and iOS, which do not carry VDB (vcpkg.json "default-features").
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    openvdb IMAGEIO_OPENVDB
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
