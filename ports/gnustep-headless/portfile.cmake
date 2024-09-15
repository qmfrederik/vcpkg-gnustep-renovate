string(REPLACE "." "_" MAKE_VERSION ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libs-back
    REF "back-${MAKE_VERSION}"
    SHA512 518a6fe9926c4008e5d39319dce4fa38d7328390517663aaa9e89e99c1b456bcd08b69baa793546d0f365c69f14f27f6c6f1417da5013fae5c26d7429f2f8304
    HEAD_REF master
    PATCHES
        0001-Windows-compatibility.patch
)

vcpkg_list(SET options)

# TODO: We could/should move this logic into vcpkg_configure_gnustep, as that method also calculates current_installed_dir_msys
if (VCPKG_TARGET_IS_WINDOWS)
    # Some PATH handling for dealing with spaces....some tools will still fail with that!
    # In particular, the libtool install command is unable to install correctly to paths with spaces.
    string(REPLACE " " "\\ " current_installed_dir_escaped "${CURRENT_INSTALLED_DIR}")
    set(current_installed_dir_msys "${CURRENT_INSTALLED_DIR}")

    if(CMAKE_HOST_WIN32)
        string(REGEX REPLACE "^([a-zA-Z]):/" "/\\1/" current_installed_dir_msys "${current_installed_dir_msys}")
    endif()

    # gnustep-config is not in PATH, so specify the path to the makefiles
    vcpkg_list(APPEND options "GNUSTEP_MAKEFILES=${current_installed_dir_msys}/share/GNUstep/Makefiles/")

    # fixme: Utilities such as plutil are not installed in the debug/bin location, so always add ${CURRENT_INSTALLED_DIR}/bin
    # to path
    set(path_backup $ENV{PATH})
    vcpkg_add_to_path("${current_installed_dir_msys}/bin/")
    vcpkg_add_to_path("${current_installed_dir_msys}/tools/gnustep-base/")
else()
    # gnustep-config is not in PATH, so specify the path to the makefiles
    vcpkg_list(APPEND options "GNUSTEP_MAKEFILES=${CURRENT_INSTALLED_DIR}/share/GNUstep/Makefiles/")
    vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/tools/gnustep-base/")
endif ()

vcpkg_configure_gnustep(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        "--enable-graphics=headless"
        "--enable-server=headless"
        "--without-freetype"
        "--with-name=headless"
        ${options}
)

vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/tools/gnustep-base/")
vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/bin/")

vcpkg_install_gnustep()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB")

# gnustep-headless does not include headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
