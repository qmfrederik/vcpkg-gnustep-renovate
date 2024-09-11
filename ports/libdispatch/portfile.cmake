vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apple/swift-corelibs-libdispatch
    REF "swift-${VERSION}-RELEASE"
    SHA512 fa8278adbdfd5b041c89a7b14a17aaa805a6f4db12221ff469288bb8d945fd28f16a8d66f56148aeba2e6be30bd6655fbe375d7843d1cb54407527d998e6d6fa
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
