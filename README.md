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
wget https://github.com/devraymondsh/libnode/releases/download/<version>/libnode-<arch>-linux.tar.xz
# Extract the archive.
tar xvf libnode-<arch>-linux.tar.xz
# Move the binaries to `/usr/lib`
sudo mv libnode.so libnode.so.127 /usr/lib/
# Ideally, move the node executable to `/usr/bin/`
sudo mv node /usr/bin/
```

## License:
This project is licensed under the MIT License.
