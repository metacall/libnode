#!/bin/bash
set -e

# Version
if [ -z "$NODE_VERSION" ]; then
    NODE_VERSION=$(head -n 1 version.txt | tr -d '\r\n')
fi

# Operative System
if [ -z "$OS" ]; then
    if [ "$(uname)" = "Darwin" ]; then
        OS="mac"
    else
        OS="linux"
    fi
fi

# Architecture
if [ "$ARCH" = "amd64" ]; then
    NODE_ARCH="x64"
else
    NODE_ARCH="arm64"
fi

# Cores
if [ "$(uname)" = "Darwin" ]; then
    CORES=$(sysctl -n hw.ncpu)
else
    CORES=$(nproc)
fi

# Debug
if [ "${DEBUG+x}" ]; then
    BUILD_DEBUG=--debug
else
    BUILD_DEBUG=
fi

# Address Sanitizer
if [ "${ASAN+x}" ]; then
    BUILD_ASAN=--enable-asan
else
    BUILD_ASAN=
fi

if [ ! -d "node" ]; then
    git clone https://github.com/nodejs/node --branch "$NODE_VERSION" --depth=1
fi

cd node
./configure --shared --dest-cpu "$NODE_ARCH" --dest-os "$OS" $BUILD_DEBUG $BUILD_ASAN
make -j$CORES
