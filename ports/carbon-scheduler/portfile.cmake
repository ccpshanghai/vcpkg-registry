vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL https://github.com/carbonengine/scheduler.git
  REF 5bd0a40ca8e899795e20b794abb0e6f479badade
  HEAD_REF main
  # The install destination is $<IF:$<PLATFORM_ID:Darwin,Linux>,lib,bin> (1.4.3 had only
  # Darwin), so macOS and Linux get lib/ but iOS (CMAKE_SYSTEM_NAME=iOS) and Android install
  # the Python module into bin/ -- and vcpkg then rewrote the exported config to
  # tools/carbon-scheduler/_scheduler.so while the file stayed in bin/, so every consumer died
  # in carbon-schedulerConfig.cmake on "references the file ... but this file does not exist".
  # Naming platforms one at a time is the wrong shape: lib/ is the convention for every
  # non-Windows target, so the condition is inverted instead. Patch rebased onto 1.6.0.
  PATCHES
    install-dir-by-platform.patch
)

# The source does `find_package(Python3 COMPONENTS Development Interpreter REQUIRED)`
# unconditionally, but every use of Python3_EXECUTABLE sits behind BUILD_TESTING or
# BUILD_DOCUMENTATION -- both switched off just below. When cross-compiling, vcpkg's
# FindPython wrapper points the Interpreter at the *target* tree, and
# `<target>/tools/python3/python3.13` is a Mach-O iOS executable: CMake runs it to read its
# version and fails with "Cannot run the interpreter". Hand it the host triplet's
# interpreter instead -- the same one CPython's own cross-build uses via
# --with-build-python. It satisfies the REQUIRED component and is never invoked here.
#
# Removing the requirement at its source would be cleaner, but that means forking
# carbonengine/scheduler, which docs/forks.md deliberately retired from the fork set.
set(_scheduler_python_option "")
if(VCPKG_CROSSCOMPILING)
  find_program(_scheduler_host_python3
    NAMES python3.13 python3 python
    PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/python3"
    NO_DEFAULT_PATH REQUIRED
  )
  set(_scheduler_python_option "-DPython3_EXECUTABLE=${_scheduler_host_python3}")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DBUILD_TESTING=OFF
    -DBUILD_DOCUMENTATION=OFF
    -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
    ${_scheduler_python_option}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
set(BUILD_PATHS
  "${CURRENT_PACKAGES_DIR}/bin/*.dll"
  "${CURRENT_PACKAGES_DIR}/debug/bin/*.dll"
  "${CURRENT_PACKAGES_DIR}/bin/*.pyd"
  "${CURRENT_PACKAGES_DIR}/debug/bin/*.pyd"
)
vcpkg_copy_pdbs(
  BUILD_PATHS ${BUILD_PATHS}
)
ccp_externalize_apple_debuginfo()
