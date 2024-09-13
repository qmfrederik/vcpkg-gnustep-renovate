include_guard(GLOBAL)

function(vcpkg_configure_gnustep)
    cmake_parse_arguments(PARSE_ARGV 0 "arg"
        ""
        "SOURCE_PATH"
        "OPTIONS"
    )

    if(VCPKG_TARGET_IS_LINUX)
        vcpkg_configure_make(
            SOURCE_PATH ${arg_SOURCE_PATH}
            # This would pass --disable-silent-rules, which is not supported by the GNUstep build system
            DISABLE_VERBOSE_FLAGS
            # Allow ./configure to find gnustep-config, which is in bin/
            ADD_BIN_TO_PATH
            # GNUstep does not support out-of-tree builds
            COPY_SOURCE
            OPTIONS
                "LDFLAGS=-fuse-ld=lld"
                ${arg_OPTIONS}
        )
    elseif(VCPKG_TARGET_IS_WINDOWS)
        # We don't use vcpkg_configure_make on Windows because it ends up breaking the linker in such a way that it cannot
        # find the Windows libraries in %WindowsSdkDir% / %WindowsSdkVerBinPath%.  It should be possible to pass the paths
        # to the Windows SDK files via command-line arguments, but escaping spaces remains a challenge in a MSYS environment.
        vcpkg_acquire_msys(MSYS_ROOT
            PACKAGES
                bash
                autoconf-wrapper
                automake-wrapper
                binutils
                libtool
                make
                pkgconf
                which
        )

        z_vcpkg_get_cmake_vars(cmake_vars_file)
        include("${cmake_vars_file}")

        set(base_cmd "${MSYS_ROOT}/usr/bin/bash.exe" --noprofile --norc --debug)

        vcpkg_list(APPEND path_list "${MSYS_ROOT}/usr/bin")

        get_filename_component(LLVM_PATH ${VCPKG_DETECTED_CMAKE_C_COMPILER} DIRECTORY)
        get_filename_component(GNUSTEP_C_COMPILER_NAME ${VCPKG_DETECTED_CMAKE_C_COMPILER} NAME)
        get_filename_component(GNUSTEP_CXX_COMPILER_NAME ${VCPKG_DETECTED_CMAKE_CXX_COMPILER} NAME)
        get_filename_component(GNUSTEP_LINKER_NAME ${VCPKG_DETECTED_CMAKE_LINKER} NAME)
        vcpkg_list(APPEND path_list "${LLVM_PATH}")

        cmake_path(CONVERT "${path_list}" TO_NATIVE_PATH_LIST native_path_list)
        set(ENV{PATH} "${native_path_list}")

        # Cleanup previous build dirs
        set(short_name_RELEASE "rel")
        set(short_name_DEBUG "dbg")
        set(path_suffix_RELEASE "/")
        set(path_suffix_DEBUG "/debug")

        file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_RELEASE}"
                            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_DEBUG}"
                            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

        # Some PATH handling for dealing with spaces....some tools will still fail with that!
        # In particular, the libtool install command is unable to install correctly to paths with spaces.
        string(REPLACE " " "\\ " current_installed_dir_escaped "${CURRENT_INSTALLED_DIR}")
        set(current_installed_dir_msys "${CURRENT_INSTALLED_DIR}")

        if(CMAKE_HOST_WIN32)
            string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" current_installed_dir_msys "${current_installed_dir_msys}")
        endif()

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT arg_NO_DEBUG)
            list(APPEND all_buildtypes DEBUG)
        endif()

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            list(APPEND all_buildtypes RELEASE)
        endif()

        # Allow ./configure to find gnustep-config, which is in bin/
        set(path_backup $ENV{PATH})
        vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/bin")

        foreach(current_buildtype IN LISTS all_buildtypes)
            vcpkg_list(APPEND CONFIGURE_OPTIONS
                                # ${prefix} has an extra backslash to prevent early expansion when calling `bash -c configure "..."`.
                                "--prefix=${current_installed_dir_msys}${path_suffix_${current_buildtype}}"
                                # Important: These should all be relative to prefix!
                                "--bindir=\\\${prefix}/../tools/${PORT}${path_suffix_${current_buildtype}}/bin"
                                "--sbindir=\\\${prefix}/../tools/${PORT}${path_suffix_${current_buildtype}}/sbin"
                                "--libdir=\\\${prefix}/lib" # On some Linux distributions lib64 is the default
                                "--datarootdir=\\\${prefix}/share/${PORT}"
                                "--host=x86_64-pc-windows"
                                "--target=x86_64-pc-windows"
                                "CC=${GNUSTEP_C_COMPILER_NAME}"
                                "CXX=${GNUSTEP_CXX_COMPILER_NAME}"
                                "LDFLAGS=-fuse-ld=${GNUSTEP_LINKER_NAME}"
                                ${arg_OPTIONS})

            list(JOIN CONFIGURE_OPTIONS " " CONFIGURE_OPTIONS)

            # Copy the sources to the target directory for an out-of-source build
            set(target_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_${current_buildtype}}")
            file(COPY "${arg_SOURCE_PATH}/" DESTINATION "${target_dir}")

            vcpkg_execute_required_process(
                COMMAND ${base_cmd} -c "./configure ${CONFIGURE_OPTIONS}"
                WORKING_DIRECTORY "${target_dir}"
                LOGNAME "config-${TARGET_TRIPLET}-${short_name_${current_buildtype}}"
                SAVE_LOG_FILES config.log
            )
        endforeach()
        
        set(ENV{PATH} "${path_backup}")
    else()
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} is not implemented for your platform")
    endif()
endfunction()
