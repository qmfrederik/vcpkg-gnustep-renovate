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

# Port-specific fixes which we should remove over time
if(PORT MATCHES "liblzma")
    # Pretend to be msvc, as otherwise the build system will default to GCC-style semantics (and we're using clang)
    # https://github.com/tukaani-project/xz/blob/68c54e45d042add64a4cb44bfc87ca74d29b87e2/CMakeLists.txt#L1389
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DMSVC=1")
endif()

set(VCPKG_LOAD_VCVARS_ENV ON)
