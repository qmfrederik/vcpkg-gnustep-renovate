# Get Program Files root to lookup possible LLVM installation
file(TO_CMAKE_PATH "$ENV{ProgramW6432}/LLVM/bin" LLVM_BIN_DIR)

# Set NO_DEFAULT_PATH to prevent the toolchain from picking up the copy of LLVM which ships with
# Visual Studio, which may be outdated
find_program(CLANG_CL_EXECUTABLE NAMES "clang-cl.exe" PATHS ${LLVM_BIN_DIR} NO_DEFAULT_PATH REQUIRED)
find_program(CLANG_RC_EXECUTABLE NAMES "llvm-rc.exe" PATHS ${LLVM_BIN_DIR} NO_DEFAULT_PATH REQUIRED)

set(CMAKE_C_COMPILER ${CLANG_CL_EXECUTABLE} CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER ${CLANG_CL_EXECUTABLE} CACHE STRING "" FORCE)
set(CMAKE_RC_COMPILER  ${CLANG_RC_EXECUTABLE} CACHE STRING "" FORCE)
