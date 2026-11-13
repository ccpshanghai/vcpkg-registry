vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  # M3 = imageio is the seventh fork (spec §2.5): the ASTC/KTX2 work lives on
  # ccpshanghai/imageio. carbon-bind's work is on the fork's `carbon-bind` branch; the REF is a
  # commit on it, never a topic branch's tip -- a pin to a retired branch breaks the day the branch
  # goes (the same trap the trinity pin fix walked one level up). Landed bottom-up: fork -> port
  # URL/REF (here) -> registry PR -> trinity baseline bump.
  #
  # 2.0.6#7: mobile-exp's caaf391e (the m3-ktx2-astc squash) plus carbon-bind's five fixes:
  # <cstring> in StdAfx.h (trinity carried it as linux-overlay-ports/carbon-imageio/cstring.patch,
  # so this port needs no patch), HostBitmap's ASTC 6x6/8x8 mip offsets and allocation (levels
  # ran past the buffer; carbon-bind carried it as an overlay patch), Result's va_list reuse,
  # HostBitmap GetPitch/GetRawData(x, y) by the format's block, and a bounded TGA RLE decoder.
  URL git@github.com:ccpshanghai/imageio.git
  REF a9db274c84785d8b8bdd7ead998e9c5af38f0760
  HEAD_REF carbon-bind
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