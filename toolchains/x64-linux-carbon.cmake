# Copyright © 2025 CCP ehf.
if (NOT _CCP_TOOLCHAIN_FILE_LOADED)
    set(_CCP_TOOLCHAIN_FILE_LOADED 1)

    # The machine this desktop target was brought up on has g++ and no clang.
    # Naming the compiler here keeps a later Clang install from becoming the default.
    if(NOT DEFINED CMAKE_C_COMPILER)
        set(CMAKE_C_COMPILER "gcc" CACHE STRING "")
    endif()
    if(NOT DEFINED CMAKE_CXX_COMPILER)
        set(CMAKE_CXX_COMPILER "g++" CACHE STRING "")
    endif()

    set (VCPKG_USE_HOST_TOOLS ON CACHE STRING "")
    set (CMAKE_CXX_STANDARD 17 CACHE STRING "")
    set (CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
    set (CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")
    set (CMAKE_POSITION_INDEPENDENT_CODE ON CACHE STRING "")

    # Default, not hidden. CcpMacros.h grants BLUEIMPORT default visibility under
    # _MSC_VER and __APPLE__ only. Hidden visibility on GCC strips Blue's C++ API
    # (BeOS and the rest), which is how the first Android link of _trinity_vulkan.so
    # failed before that platform grew its own export. Linux has no such branch.
    set (CMAKE_CXX_VISIBILITY_PRESET default CACHE STRING "")
    set (CMAKE_VISIBILITY_INLINES_HIDDEN OFF CACHE BOOL "")

    # GCC LTO across the vcpkg graph fails in ways that point at the wrong library.
    # The window is the acceptance evidence, so leave IPO off.
    set (CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF CACHE STRING "")

    #[[
        - `CCP_PLATFORM` indicates the operating system a binary was built for
        - `CCP_ARCHITECTURE` indicates the hardware architecture a binary was built for
        - `CCP_TOOLSET` indicates the compiler (or toolset) a binary was built with
        - `CCP_VENDOR_LIB_PATH` is a convenience variable for find_package modules, to construct the default `lib` folder for a vendored SDK.
        - `CCP_VENDOR_BIN_PATH` is the same as CCP_VENDOR_LIB_PATH, but for the `bin` folder for a vendored SDK.

        See Platform Agnostic Developement section of the wiki:
        https://ccpgames.atlassian.net/wiki/spaces/PAD/overview?homepageId=171868162
    ]]
    set(CCP_PLATFORM "Linux" CACHE STRING "Target Platform")
    set(CCP_ARCHITECTURE "x64" CACHE STRING "Target Architecture")
    set(CCP_TOOLSET "GCC" CACHE STRING "Target Toolset")

    # adjust warning settings for all our projects, but do not treat them as errors just yet.
    add_compile_options(-Wall)
    # we want to use the two ones below once we're good with -Wall
    #    add_compile_options(-Wpedantic)
    #    add_compile_options(-Wextra)

    # We're using a lot of MSVC specific pragmas in our codebase, so we silence those warnings until we got around to
    # cleaning them up
    add_compile_options(-Wno-unknown-pragmas)
    # There's a surprising amount of unused functions, we need to investigate this deeper at one point
    add_compile_options(-Wno-unused-function)
    # Ditto, much like the functions there are also a lot of unused variables it appears
    add_compile_options(-Wno-unused-variable)
    # We've not been very good at keeping order
    add_compile_options(-Wno-reorder)
    # -Wmissing-braces should only be used by C / ObjectiveC, but for some reason it shows up for our C++ code, too.
    add_compile_options(-Wno-missing-braces)

    # Manually add debug symbols to builds
    add_compile_options(-g)

    # GCC has no -ffp-model and no -fhonor-infinities/-fhonor-nans. -ffast-math is the
    # flag TrinityAL's MATH_OPTIMIZE_FLAG consumer can pass on this compiler.
    set(MATH_OPTIMIZE_FLAG -ffast-math)
endif ()
