string(REPLACE "." "_" MAKE_VERSION ${VERSION})

# On Windows, the libraries include a version number in their name, such as
# gnustep-base-1_30.dll .
# Determine that form $VERSION through some CMake magic
string(REPLACE "." ";" VERSION_COMPONENTS ${VERSION})
list(SUBLIST VERSION_COMPONENTS 0 2 VERSION_MAJOR_MINOR)
string(REPLACE ";" "_" LIBRARY_VERSION "${VERSION_MAJOR_MINOR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libs-base
    REF "base-${MAKE_VERSION}"
    SHA512 8035409dd6f8e2fd4ba2255c6df4add2e88f50159f67a9de22a3fd7743db8a8a90cc61e91c43c91727204bb07b337aa96fb679f72b70c98fa9389c5ceeaad3cc
    HEAD_REF master
    PATCHES
        # https://github.com/gnustep/libs-base/pull/514
        # Expose declarations in NSDebug.h even when NDEBUG is defined #514
        ec6299f72faa04f4bb019d4f2a0984fe832b09c0.patch
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
        ${options}
)

vcpkg_install_gnustep()

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
            ${CURRENT_PACKAGES_DIR}/bin/gnustep-base-${LIBRARY_VERSION}.dll
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
