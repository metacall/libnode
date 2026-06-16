#!/bin/bash
set -e

if [ -z "$NODE_VERSION" ]; then
    NODE_VERSION=$(head -n 1 version.txt | tr -d '\r\n')
fi

if [ -z "$OS" ]; then
    if [ "$(uname)" = "Darwin" ]; then
        OS="mac"
    else
        OS="linux"
    fi
fi
if [ "$ARCH" = "amd64" ]; then
    NODE_ARCH="x64"
else
    NODE_ARCH="arm64"
fi

if [ "$(uname)" = "Darwin" ]; then
    CORES=$(sysctl -n hw.ncpu)
else
    CORES=$(nproc)
fi
THREADS=$((CORES * 2))

if [ ! -d "node" ]; then
    git clone https://github.com/nodejs/node --branch "$NODE_VERSION" --depth=1
fi

cd node
./configure --shared --dest-cpu "$NODE_ARCH" --dest-os "$OS"
make -j$THREADS
