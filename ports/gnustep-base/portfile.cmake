string(REPLACE "." "_" MAKE_VERSION ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libs-base
    REF "base-${MAKE_VERSION}"
    SHA512 f656ad73138e476874fa70c5fa74718b023e97314e80d3a75ec7f25efe90d11a8dd6dd5d18706797e7be590f53300e9adb031bba3c85fdf9fd909dbf0d57b08e
    HEAD_REF master
    PATCHES
)

vcpkg_list(SET options)

if (VCPKG_TARGET_IS_WINDOWS)
    # Disable a bunch of options for now; this allows us to get a minimal libs-base port merged into main;
    # and we can then light up extra features one by one.
    vcpkg_list(APPEND options "--disable-tls")
endif ()

vcpkg_configure_gnustep(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # GNUstep.conf contains absolute paths, and doesn't exist in vcpkg
        --disable-importing-config-file
        # gnustep-config is not in PATH, so specify the path to the makefiles
        GNUSTEP_MAKEFILES=${CURRENT_INSTALLED_DIR}/share/GNUstep/Makefiles/
        ${options}
)

vcpkg_install_gnustep(
    OPTIONS
        # gnustep-config is not in PATH, so specify the path to the makefiles
        GNUSTEP_MAKEFILES=${CURRENT_INSTALLED_DIR}/share/GNUstep/Makefiles/
)

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB")

# Copy tools to the tools directory, remove duplicate instances in debug/
vcpkg_copy_tools(
    TOOL_NAMES
        autogsdoc
        cvtenc
        defaults
        gdnc
        gspath
        HTMLLinker
        make_strings
        pl
        pl2link
        pldes
        plget
        plmerge
        plparse
        plser
        plutil
        sfparse
        xmlparse
    AUTO_CLEAN
)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(
        TOOL_NAMES
            gdomap
        AUTO_CLEAN)
endif ()

# The makefiles used by GNUstep go in share, and are different for the release and debug configuration
set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)
