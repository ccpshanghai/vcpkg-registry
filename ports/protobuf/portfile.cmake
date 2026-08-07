include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/protobuf
    REF v3.6.0.1
    SHA512 63cd799d5d6edbb05a87bc07992271c5bdb9595366d698b4dc5476cc89dc278d1c43186b9e56340958aefea2ce23e15a9c3a550158414add868b56e789ceafe4
    HEAD_REF master
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/js-embed.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-uwp.patch"
)

# Build protoc only when host and target are the same triplet. When they differ, the host
# protobuf supplies it -- see the self host dependency in vcpkg.json. This is the same test
# our 6.33.4 port uses, backported.
#
# Upstream decided this from CMAKE_HOST_WIN32 instead, which was wrong in both directions:
# on a Windows host it then demanded protoc at a hardcoded x86-windows path, failing for
# every other host triplet; and on a non-Windows host it fell through to building protoc
# for the target and installing that as the host tool, which cannot execute and does not
# announce itself.
string(COMPARE EQUAL "${TARGET_TRIPLET}" "${HOST_TRIPLET}" protobuf_BUILD_PROTOC_BINARIES)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(protobuf_BUILD_SHARED_LIBS ON)
else()
    set(protobuf_BUILD_SHARED_LIBS OFF)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(protobuf_MSVC_STATIC_RUNTIME ON)
else()
    set(protobuf_MSVC_STATIC_RUNTIME OFF)
endif()

if("zlib" IN_LIST FEATURES)
    set(protobuf_WITH_ZLIB ON)
else()
    set(protobuf_WITH_ZLIB OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    PREFER_NINJA
    OPTIONS
        -Dprotobuf_BUILD_SHARED_LIBS=${protobuf_BUILD_SHARED_LIBS}
        -Dprotobuf_MSVC_STATIC_RUNTIME=${protobuf_MSVC_STATIC_RUNTIME}
        -Dprotobuf_WITH_ZLIB=${protobuf_WITH_ZLIB}
        -Dprotobuf_BUILD_TESTS=OFF
        -DCMAKE_INSTALL_CMAKEDIR:STRING=share/protobuf
        -Dprotobuf_BUILD_PROTOC_BINARIES=${protobuf_BUILD_PROTOC_BINARIES}
)

vcpkg_install_cmake()

# It appears that at this point the build hasn't actually finished. There is probably
# a process spawned by the build, therefore we need to wait a bit.

function(protobuf_try_remove_recurse_wait PATH_TO_REMOVE)
    file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    if (EXISTS "${PATH_TO_REMOVE}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 5)
        file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    endif()
endfunction()

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/include)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake RELEASE_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/protobuf/protoc${CMAKE_EXECUTABLE_SUFFIX}" RELEASE_MODULE "${RELEASE_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake "${RELEASE_MODULE}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/share/protobuf/protobuf-targets-debug.cmake DEBUG_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
    string(REPLACE "\${_IMPORT_PREFIX}/debug/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/protobuf/protoc${CMAKE_EXECUTABLE_SUFFIX}" DEBUG_MODULE "${DEBUG_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-debug.cmake "${DEBUG_MODULE}")
endif()

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/share)

# Where protoc comes from depends on whether we cross-compiled, not on the host OS.
if(NOT protobuf_BUILD_PROTOC_BINARIES)
    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
elseif(CMAKE_HOST_WIN32)
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/protoc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/protobuf)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/protobuf)
else()
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/protoc DESTINATION ${CURRENT_PACKAGES_DIR}/tools/protobuf
            PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_WRITE GROUP_EXECUTE WORLD_READ)
endif()

# Cleaning up bin/ is about the target, not the host. Upstream had these two branches
# keyed on CMAKE_HOST_WIN32, so a Windows host cross-compiling to Android took the
# Windows cleanup and looked for a protoc.exe that was never built.
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)
    else()
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin/protoc.exe)
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin/protoc.exe)
    endif()
else()
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(READ ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h _contents)
    string(REPLACE "\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" "\#define PROTOBUF_USE_DLLS\n\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h "${_contents}")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/protobuf RENAME copyright)
vcpkg_copy_pdbs()
