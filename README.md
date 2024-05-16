# Prebuilt libnode binaries

This project automatically monitors Node.js for new releases and compiles the latest versions into shared libraries using GitHub Actions. You can conveniently access these binaries in the release section of this repository.

## Supported platforms:

- Linux x64
- Linux ARM64
- MacOS x64
- MacOS ARM64 (M series)
- Windows x64

## Possible Future Support:

- Windows ARM64 (The Windows ARM64 support is dependent on solving [https://github.com/nodejs/node/issues/52664](https://github.com/nodejs/node/issues/52664))

## Usage:

Download your suitable release and place the binaries into your Operating System's shared library location. On Linux for example, you'd do:

```bash
# Replace <version> with the version you're willing to download, e.g. `v22.1.0`.
# Replace <arch> with your CPU architecture. e.g. `amd64` or `arm64`.
wget https://github.com/metacall/libnode/releases/download/<version>/libnode-<arch>-linux.tar.xz
# Extract the archive.
tar xvf libnode-<arch>-linux.tar.xz
# Move the binaries to `/usr/lib`
sudo mv libnode.so* /usr/lib/
# Move the node executable to `/usr/bin/`
sudo mv node /usr/bin/
```

## Usage with Metacall:

After doing the previous step, you can use libnode in Metacall like this:

```bash
cmake \
  # Your options ...
  # Replace the path with your Operating System's shared library location
  # if you're not using Linux
  -DNodeJS_EXECUTABLE=/usr/bin/node \
  -DNodeJS_LIBRARY=/usr/lib/libnode.so \
  ..
```

## License:

This project is licensed under the Apache-2.0 License.
