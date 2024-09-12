set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CRT_LINKAGE dynamic)

# Configure toolchain
# Some ports need to be built with clang-cl instead of clang.  For example,
# libffi uses libtool, which pass msvc-style arguments to the linker (-EXPORT:symbol)
if(PORT MATCHES "^(libffi|libiconv)$")
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchains/x64-windows-clangcl.toolchain.cmake")
else()
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchains/x64-windows-llvm.toolchain.cmake")
endif()

set(VCPKG_LOAD_VCVARS_ENV ON)
