set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CRT_LINKAGE dynamic)

# Configure toolchain
# Some ports need to be built with clang-cl instead of clang.  For example,
# - libffi and libiconv use libtool, which pass msvc-style arguments to the linker (-EXPORT:symbol)
# - libxlst uses #include <win32config.h> for a local file, and should use quotes instead
#   https://gitlab.gnome.org/GNOME/libxslt/-/blob/master/libxslt/libxslt.h#L27
# - curl somehow builds without exports; probably because all of the voodoo here:
#   https://github.com/curl/curl/blob/master/CMake/CurlSymbolHiding.cmake#L71
if(PORT MATCHES "^(libffi|libiconv|libxslt|curl|pixman|cairo)$")
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchains/x64-windows-clangcl.toolchain.cmake")
else()
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchains/x64-windows-llvm.toolchain.cmake")
endif()

# Workaround for meson-style projects, such as pixman, which try to look for lld-link in the current path
# See https://github.com/mesonbuild/meson/issues/9727
if(PORT MATCHES "^(pixman|cairo)$")
    set(ENV{PATH} "$ENV{ProgramW6432}/LLVM/bin;$ENV{PATH}")
endif()

# Port-specific fixes which we should remove over time
if(PORT MATCHES "liblzma")
    # Pretend to be msvc, as otherwise the build system will default to GCC-style semantics (and we're using clang)
    # https://github.com/tukaani-project/xz/blob/68c54e45d042add64a4cb44bfc87ca74d29b87e2/CMakeLists.txt#L1389
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DMSVC=1")
endif()

if(PORT MATCHES "libjpeg-turbo")
    # libjpeg-turbo doesn't know about clang on Windows; only considers 'vc' and 'mingw', make it think we're building for vc:
    # (https://github.com/libjpeg-turbo/libjpeg-turbo/blob/dd8b15ee82b02e41307f9ca9144d8ca140d67816/cmakescripts/BuildPackages.cmake#L71)
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DINST_ID=vc")
endif()

set(VCPKG_LOAD_VCVARS_ENV ON)
