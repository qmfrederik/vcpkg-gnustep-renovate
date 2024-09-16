#[=======================================================================[.rst:
FindGNUstep
-----------

Finds GNUstep, including libobjc2, gnustep-base and gnustep-gui.

#]=======================================================================]

# See https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html#a-sample-find-module
# for details

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    include("${CMAKE_CURRENT_LIST_DIR}/FindGNUstep.darwin.cmake")
else()
    include("${CMAKE_CURRENT_LIST_DIR}/FindGNUstep.vcpkg.cmake")
endif()