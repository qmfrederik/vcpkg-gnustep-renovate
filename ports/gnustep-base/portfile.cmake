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
if (VCPKG_TARGET_IS_WINDOWS)
    # vcpkg_copy_tools fails with the following error:
    #  CMake Error at scripts/cmake/vcpkg_copy_tool_dependencies.cmake:31 (message):
    #  Could not find PowerShell Core; please open an issue to report this.
    # so do a manual copy instead
    file(
        COPY
            ${CURRENT_PACKAGES_DIR}/bin/autogsdoc.exe
            ${CURRENT_PACKAGES_DIR}/bin/cvtenc.exe
            ${CURRENT_PACKAGES_DIR}/bin/defaults.exe
            ${CURRENT_PACKAGES_DIR}/bin/gdnc.exe
            ${CURRENT_PACKAGES_DIR}/bin/gspath.exe
            ${CURRENT_PACKAGES_DIR}/bin/HTMLLinker.exe
            ${CURRENT_PACKAGES_DIR}/bin/make_strings.exe
            ${CURRENT_PACKAGES_DIR}/bin/pl.exe
            ${CURRENT_PACKAGES_DIR}/bin/pl2link.exe
            ${CURRENT_PACKAGES_DIR}/bin/pldes.exe
            ${CURRENT_PACKAGES_DIR}/bin/plget.exe
            ${CURRENT_PACKAGES_DIR}/bin/plmerge.exe
            ${CURRENT_PACKAGES_DIR}/bin/plparse.exe
            ${CURRENT_PACKAGES_DIR}/bin/plser.exe
            ${CURRENT_PACKAGES_DIR}/bin/plutil.exe
            ${CURRENT_PACKAGES_DIR}/bin/sfparse.exe
            ${CURRENT_PACKAGES_DIR}/bin/xmlparse.exe

            # Shared libraries required by these tools
            ${CURRENT_PACKAGES_DIR}/bin/gnustep-base-1_30.dll
            ${CURRENT_INSTALLED_DIR}/bin/objc.dll
            ${CURRENT_INSTALLED_DIR}/bin/iconv-2.dll
            ${CURRENT_INSTALLED_DIR}/bin/libxml2.dll
            ${CURRENT_INSTALLED_DIR}/bin/libxslt.dll
            ${CURRENT_INSTALLED_DIR}/bin/libcurl.dll
            ${CURRENT_INSTALLED_DIR}/bin/dispatch.dll
            ${CURRENT_INSTALLED_DIR}/bin/ffi-8.dll
            ${CURRENT_INSTALLED_DIR}/bin/liblzma.dll
            ${CURRENT_INSTALLED_DIR}/bin/zlib1.dll

        DESTINATION
            ${CURRENT_PACKAGES_DIR}/tools/gnustep-base/
    )

    # Clean up after copying
    file(
        REMOVE
            ${CURRENT_PACKAGES_DIR}/bin/autogsdoc.exe
            ${CURRENT_PACKAGES_DIR}/bin/cvtenc.exe
            ${CURRENT_PACKAGES_DIR}/bin/defaults.exe
            ${CURRENT_PACKAGES_DIR}/bin/gdnc.exe
            ${CURRENT_PACKAGES_DIR}/bin/gspath.exe
            ${CURRENT_PACKAGES_DIR}/bin/HTMLLinker.exe
            ${CURRENT_PACKAGES_DIR}/bin/make_strings.exe
            ${CURRENT_PACKAGES_DIR}/bin/pl.exe
            ${CURRENT_PACKAGES_DIR}/bin/pl2link.exe
            ${CURRENT_PACKAGES_DIR}/bin/pldes.exe
            ${CURRENT_PACKAGES_DIR}/bin/plget.exe
            ${CURRENT_PACKAGES_DIR}/bin/plmerge.exe
            ${CURRENT_PACKAGES_DIR}/bin/plparse.exe
            ${CURRENT_PACKAGES_DIR}/bin/plser.exe
            ${CURRENT_PACKAGES_DIR}/bin/plutil.exe
            ${CURRENT_PACKAGES_DIR}/bin/sfparse.exe
            ${CURRENT_PACKAGES_DIR}/bin/xmlparse.exe

            ${CURRENT_PACKAGES_DIR}/debug/bin/autogsdoc.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/cvtenc.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/defaults.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/gdnc.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/gspath.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/HTMLLinker.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/make_strings.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/pl.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/pl2link.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/pldes.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/plget.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/plmerge.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/plparse.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/plser.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/plutil.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/sfparse.exe
            ${CURRENT_PACKAGES_DIR}/debug/bin/xmlparse.exe
    )
else()
    vcpkg_copy_tools(
        TOOL_NAMES
            autogsdoc
            cvtenc
            defaults
            gdnc
            gspath
            gdomap
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
endif ()

# The makefiles used by GNUstep go in share, and are different for the release and debug configuration
set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)
