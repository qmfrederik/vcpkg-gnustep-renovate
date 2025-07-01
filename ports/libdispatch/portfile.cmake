vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apple/swift-corelibs-libdispatch
    REF "swift-${VERSION}-RELEASE"
    SHA512 09613b213e57f6c2ca483a0a7833b2240e5017cf33f90405f88cbf20131b301f96127f69808720e44f6a050f1ae19f80da40f6eecc63395beeea4f796d27b222
    HEAD_REF main
    PATCHES
        0001-Use-CMAKE_C_COMPILER_FRONTEND_VARIANT-to-detect-msvc.patch
        0001-Fix-Windows-compatibility.patch
        0001-Use-external-BlocksRuntime.patch
)

set(libobjc_name "libobjc.so")

if(VCPKG_TARGET_IS_WINDOWS)
    set(libobjc_name "objc.lib")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-D BUILD_SHARED_LIBS=YES"
        "-D BlocksRuntime_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"
        "-D BUILD_TESTING=NO"
    OPTIONS_RELEASE
        "-D BlocksRuntime_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/${libobjc_name}"
    OPTIONS_DEBUG
        "-D BlocksRuntime_LIBRARIES=${CURRENT_INSTALLED_DIR}/debug/lib/${libobjc_name}"
)
vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
