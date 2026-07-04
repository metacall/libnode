#!/bin/bash
set -e

if [ -z "$NODE_VERSION" ]; then
    NODE_VERSION=$(head -n 1 version.txt | tr -d '\r\n')
fi

if [ "$ARCH" = "amd64" ]; then
    NODE_ARCH="x64"
else
    NODE_ARCH="arm64"
fi

if [ -z "$OS" ]; then
    if [ "$(uname)" = "Darwin" ]; then
        OS="mac"
        CORES=$(sysctl -n hw.ncpu)
 
        # Force-include stdlib.h to resolve undeclared 'malloc' and 'free' errors in the LIEF/spdlog dependency.
        # This is specifically required for macOS because its C++ standard library (libc++) is strictly structured 
        # and does not transitively include <stdlib.h> via other headers. In contrast, Linux builds succeed 
        # because GNU's libstdc++ often pulls it in implicitly by luck through other standard headers.
        export CXXFLAGS="-include cstdlib"

        # Binary names without absolute paths so sccache can intercept them
        export CC="sccache clang"
        export CXX="sccache clang++"

        # Prepend Homebrew's LLVM to the PATH so it overrides Apple's default Clang
        export PATH="$(brew --prefix llvm)/bin:$PATH"
    else
        OS="linux"
        CORES=$(nproc)

        export CC="sccache gcc"
        export CXX="sccache g++"
    fi
fi

export SCCACHE_DIR="$GITHUB_WORKSPACE/.sccache"
mkdir -p "$SCCACHE_DIR"

if [ ! -d "node" ]; then
    git clone https://github.com/nodejs/node --branch "$NODE_VERSION" --depth=1
fi

cd node
./configure --shared --dest-cpu "$NODE_ARCH" --dest-os "$OS"
make -j$CORES

sccache --show-stats