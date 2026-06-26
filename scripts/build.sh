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
        # Binary names without absolute paths so ccache can intercept them
        export CC="clang"
        export CXX="clang++"
        # Prepend Homebrew's LLVM to the PATH so it overrides Apple's default Clang
        export PATH="$(brew --prefix llvm)/bin:$PATH"
    else
        OS="linux"
        CORES=$(nproc)

        export CC="gcc"
        export CXX="g++"
    fi
fi

export CCACHE_COMPRESS="true"
export CCACHE_BASEDIR="$GITHUB_WORKSPACE"
export CCACHE_DIR="$CCACHE_BASEDIR/.ccache"
export PATH="/usr/lib/ccache:/usr/local/opt/ccache/libexec:/opt/homebrew/opt/ccache/libexec:$PATH"
mkdir -p "$CCACHE_DIR"

if [ ! -d "node" ]; then
    git clone https://github.com/nodejs/node --branch "$NODE_VERSION" --depth=1
fi

cd node
./configure --shared --dest-cpu "$NODE_ARCH" --dest-os "$OS"
make -j$CORES
