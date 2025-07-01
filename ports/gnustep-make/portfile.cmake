string(REPLACE "." "_" MAKE_VERSION ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/tools-make
    REF "make-${MAKE_VERSION}"
    SHA512 e3230d3bf5ca6cb0cb721ebc9f2a0b554315e14d7e71a6e4d4f54d23d8e4c09cc229609e5b87f911f59873721ba46bd7f3cc22d19a4b5a2fd1456c2f7e3ec50d
    HEAD_REF master
    PATCHES
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/FilesystemLayouts/vcpkg-debug DESTINATION ${SOURCE_PATH}/FilesystemLayouts/)

vcpkg_configure_gnustep(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --with-library-combo=ng-gnu-gnu
        --with-runtime-abi=gnustep-2.2
    OPTIONS_DEBUG
        --with-layout=vcpkg-debug
)

vcpkg_install_gnustep()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

# Empty directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/GNUstep/Makefiles/Additional")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/GNUstep/Makefiles/Additional")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/GNUstep/Makefiles/Auxiliary")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/GNUstep/Makefiles/Auxiliary")

# Utilities which are not used in the build process and contain absolute path
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/debugapp")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/gnustep-tests")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/openapp")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/opentool")

file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/debugapp")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/gnustep-tests")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/openapp")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/opentool")

# These files contain absolute paths and are not portable
file(REMOVE "${CURRENT_PACKAGES_DIR}/etc/GNUstep/GNUstep.conf")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/etc/GNUstep/GNUstep.conf")

# We don't use .csh files in the build process. They contain absolute paths;
# remove them.
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/GNUstep/Makefiles/GNUstep.csh")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/share/GNUstep/Makefiles/GNUstep.csh")
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/GNUstep/Makefiles/filesystem.csh")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/share/GNUstep/Makefiles/filesystem.csh")

# Fix path in gnustep-config, GNUstep.sh, GNUstep.conf and filesystem.sh
function(z_vcpkg_fixup_gnustep_path file find replace)
    file(READ ${file} contents)
    string(REPLACE ${find} ${replace} contents "${contents}")
    file(WRITE ${file} "${contents}")
endfunction()

set(vcpkg_package_prefix "${CURRENT_INSTALLED_DIR}")

# vcpkg_build_make will convert Windows paths to Unix-like paths, so we need to do the same before we do a find and
# replace operation.
if (CMAKE_HOST_WIN32)
    string(REPLACE " " [[\ ]] vcpkg_package_prefix "${vcpkg_package_prefix}")
    string(REGEX REPLACE [[([a-zA-Z]):/]] [[/\1/]] vcpkg_package_prefix "${vcpkg_package_prefix}")
endif()

z_vcpkg_fixup_gnustep_path("${CURRENT_PACKAGES_DIR}/bin/gnustep-config" "${vcpkg_package_prefix}" "$(realpath \"$(dirname $0)/../\")")
z_vcpkg_fixup_gnustep_path("${CURRENT_PACKAGES_DIR}/debug/bin/gnustep-config" "${vcpkg_package_prefix}/debug" "$(realpath \"$(dirname $0)/../\")")

# because GNUstep.sh is sourced, use ${BASH_SOURCE[0]}.  This is less portable but works.
z_vcpkg_fixup_gnustep_path("${CURRENT_PACKAGES_DIR}/share/GNUstep/Makefiles/GNUstep.sh" "${vcpkg_package_prefix}" "$(realpath \"$(dirname \${BASH_SOURCE[0]})/../../../\")")
z_vcpkg_fixup_gnustep_path("${CURRENT_PACKAGES_DIR}/debug/share/GNUstep/Makefiles/GNUstep.sh" "${vcpkg_package_prefix}/debug" "$(realpath \"$(dirname \${BASH_SOURCE[0]})/../../../\")")

z_vcpkg_fixup_gnustep_path("${CURRENT_PACKAGES_DIR}/share/GNUstep/Makefiles/GNUstep-reset.sh" "${vcpkg_package_prefix}" "$(realpath \"$(dirname \${BASH_SOURCE[0]})/../../../\")")
z_vcpkg_fixup_gnustep_path("${CURRENT_PACKAGES_DIR}/debug/share/GNUstep/Makefiles/GNUstep-reset.sh" "${vcpkg_package_prefix}/debug" "$(realpath \"$(dirname \${BASH_SOURCE[0]})/../../../\")")

z_vcpkg_fixup_gnustep_path("${CURRENT_PACKAGES_DIR}/share/GNUstep/Makefiles/filesystem.sh" "${vcpkg_package_prefix}" "$(realpath \"$(dirname \${BASH_SOURCE[0]})/../../../\")")
z_vcpkg_fixup_gnustep_path("${CURRENT_PACKAGES_DIR}/debug/share/GNUstep/Makefiles/filesystem.sh" "${vcpkg_package_prefix}/debug" "$(realpath \"$(dirname \${BASH_SOURCE[0]})/../../../\")")

# gnustep-make has no headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# The makefiles used by GNUstep go in share, and are different for the release and debug configuration
set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)
set(VCPKG_POLICY_ALLOW_EMPTY_FOLDERS enabled)
