# ==============================================================================
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=<this file>

# CMAKE COMMAND from oot build directory without plugins:
# cmake -S ../opensmalltalk-vm -DBUILD_BUNDLE=FALSE -DGENERATE_SOURCES=FALSE -DFLAVOUR=CoInterpreter -DPHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES=FALSE \
# -DFEATURE_FFI=FALSE -DFEATURE_THREADED_FFI=FALSE -DFEATURE_LIB_GIT2=FALSE \
# -DCMAKE_TOOLCHAIN_FILE=../opensmalltalk-vm/cmake/riscv.cmake -B .

# CMake command setup:
# --------------------

# Base command, no build bundle, sources already generated to the corresponding flavour
# cmake -S ../opensmalltalk-vm -DBUILD_BUNDLE=FALSE -DGENERATE_SOURCES=FALSE -DFLAVOUR=CoInterpreter -DPHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES=FALSE

# FFI
# -DFFI_INCLUDE_DIR=/home/quentin/Desktop/GitProjects/tools/libffi/libffi-rv64/include \
# -DFFI_LIBRARY=/home/quentin/Desktop/GitProjects/tools/libffi/libffi-rv64/lib/libffi.so \

# libgit
# -DFEATURE_LIB_GIT2=FALSE \

# Openssl
# -DOPENSSL_ROOT_DIR=/home/quentin/Desktop/GitProjects/tools/openssl-build \
# -DOPENSSL_INCLUDE_DIR=/home/quentin/Desktop/GitProjects/tools/openssl-build/include \
# -DOPENSSL_CRYPTO_LIBRARY=/home/quentin/Desktop/GitProjects/tools/openssl-build/lib \

# uuid
# -DLIB_UUID_INCLUDE_DIR=/opt/riscv-glibc/sysroot/usr/include/linux \

# toolchain
# -DCMAKE_TOOLCHAIN_FILE=../opensmalltalk-vm/cmake/riscv.cmake -B .

# ==============================================================================

# Complete command:
# cmake -S ../opensmalltalk-vm -DBUILD_BUNDLE=FALSE -DGENERATE_SOURCES=FALSE -DFLAVOUR=CoInterpreter -DPHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES=FALSE \
# -DFFI_INCLUDE_DIR=/home/quentin/Desktop/GitProjects/tools/libffi/libffi-rv64/include \
# -DFFI_LIBRARY=/home/quentin/Desktop/GitProjects/tools/libffi/libffi-rv64/lib/libffi.so \
# -DFEATURE_LIB_GIT2=FALSE \
# -DOPENSSL_ROOT_DIR=/home/quentin/Desktop/GitProjects/tools/openssl-build \
# -DOPENSSL_INCLUDE_DIR=/home/quentin/Desktop/GitProjects/tools/openssl-build/include \
# -DOPENSSL_CRYPTO_LIBRARY=/home/quentin/Desktop/GitProjects/tools/openssl-build/lib \
# -DLIB_UUID_INCLUDE_DIR=/opt/riscv-glibc/sysroot/usr/include/linux \
# -DCMAKE_TOOLCHAIN_FILE=../opensmalltalk-vm/cmake/riscv.cmake -B .

# ==============================================================================

# Look for RISC-V github GCC
FIND_FILE(RISCV_GLIBC_GCC_COMPILER "riscv64-unknown-linux-gnu-gcc" PATHS ENV INCLUDE)
set(RISCV_GCC_COMPILER ${RISCV_GLIBC_GCC_COMPILER})

# Get gcc path and  extract the prefix
get_filename_component(RISCV_TOOLCHAIN_BIN_GCC ${RISCV_GCC_COMPILER} NAME)
STRING(REGEX REPLACE "\-gcc" "-" CROSS_COMPILE ${RISCV_TOOLCHAIN_BIN_GCC})

# Define the System and Processor
set(CMAKE_SYSTEM_NAME          Linux)
set(CMAKE_SYSTEM_PROCESSOR     riscv.64) # This format is useful if we need the libffi that will work out of the box this way
# Set the sysroot path for RISCV
set(CMAKE_SYSROOT "/opt/riscv-glibc/sysroot")

# Setup the C and C++ compilers
set(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++)

# Adjust the default behavior of the FIND_XXX() commands:
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
