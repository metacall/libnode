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

        export CXXFLAGS="-include stdlib.h"
        export CC="$(brew --prefix llvm)/bin/clang"
        export CXX="$(brew --prefix llvm)/bin/clang++"
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
