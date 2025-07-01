string(REPLACE "." "_" MAKE_VERSION ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libs-back
    REF "back-${MAKE_VERSION}"
    SHA512 0bf9b39e7cfe704039c02cc302c091fa8c2a71aa8600be497aca025712bc9a805038310aaddba00dc523e1743dba76f3bba5cdf6d36e3b08c89bb5c18ace6175
    HEAD_REF master
    PATCHES
        0001-Don-t-link-with-libm-on-Windows.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(graphics "winlib")
    set(server "win32")
    set(options "--without-freetype")
else()
    set(graphics "cairo")
    set(server "x11")
endif()

vcpkg_configure_gnustep(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        "--enable-graphics=${graphics}"
        "--enable-server=${server}"
        ${options}
)

vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/tools/gnustep-base/")
vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/bin/")

vcpkg_install_gnustep()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB")

# gnustep-headless does not include headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
