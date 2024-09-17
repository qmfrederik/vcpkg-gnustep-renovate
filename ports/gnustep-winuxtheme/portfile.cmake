vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/plugins-themes-WinUXTheme
    REF "1d9a37136b8dfc6dcea811ef28defbe52f954d0d"
    SHA512 aa503870573dbb0b219e2488078f53a6e259bd64926ceb315284a1bf7deef38a5ba208fdbd0fef560c3628e1b2854b242b353f9a62f793122b35040f54c4b8c4
    HEAD_REF master
    PATCHES
)

# Although winuxtheme does not ship with a configure script, we call vcpkg_configure_gnustep
# as it takes care of a lot of auxilliary tasks, such as copying the sources to the buildtree,
# and acquiring and configuring MSYS2
file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")
vcpkg_configure_gnustep(
    SOURCE_PATH ${SOURCE_PATH})

# Add plmerge (and others) to PATH    
vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/tools/gnustep-base/")

vcpkg_install_gnustep(
    OPTIONS
        "GNUSTEP_MAKEFILES=${CURRENT_INSTALLED_DIR}/share/GNUstep/Makefiles/"
)

# gnustep-winuxtheme does not include headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
