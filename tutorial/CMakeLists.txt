cmake_minimum_required(VERSION 3.10)

project(Tutorial)

find_package(GNUstep)

add_executable(Tutorial main.m)
target_link_libraries(Tutorial GNUstep::Base)

# At the time of writing, the following files need to be copied to the output folder:
if(WIN32)
    set(VCPKG_BINDIR "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin")
    file(COPY
        ${VCPKG_BINDIR}/objc.dll
        ${VCPKG_BINDIR}/gnustep-base-1_31.dll
        ${VCPKG_BINDIR}/libxml2.dll
        ${VCPKG_BINDIR}/ffi-8.dll
        ${VCPKG_BINDIR}/libxml2.dll
        ${VCPKG_BINDIR}/libcurl.dll
        ${VCPKG_BINDIR}/libxslt.dll
        ${VCPKG_BINDIR}/dispatch.dll
        ${VCPKG_BINDIR}/iconv-2.dll
        ${VCPKG_BINDIR}/zlib1.dll
        ${VCPKG_BINDIR}/liblzma.dll
        DESTINATION
        ${CMAKE_CURRENT_BINARY_DIR}
    )
endif()
