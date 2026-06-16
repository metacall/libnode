# Prebuilt libnode Binaries by Metacall

This repository provides an automated build pipeline that monitors official Node.js releases and compiles the latest versions into embeddable shared libraries (`libnode.so`, `libnode.dylib`, `libnode.dll`).

These prebuilt binaries are optimized for maximum performance on modern hardware and are primarily used by the [MetaCall Core](https://github.com/metacall/core) repository to embed Node.js into multiple programming languages seamlessly.

## Supported Platforms
The automated GitHub Actions workflow provides nightly checks and generates releases for the following architectures:

- Linux: x64, ARM64
- Windows: x64, ARM64
- macOS: x64, ARM64 (Apple Silicon / M-Series)

## Installation & Usage
You can download the latest prebuilt binaries from the Releases page. Each release contains the compiled shared library, the standalone node executable, and the necessary C/C++ header files for embedding.

### Linux
Linux builds are packaged as `.tar.xz` archives.

```bash
# 1. Download the archive (Replace <version> and <arch> e.g., v26.3.0 and amd64)
wget https://github.com/metacall/libnode/releases/download/<version>/libnode-<arch>-linux.tar.xz

# 2. Extract the archive
tar -xvf libnode-<arch>-linux.tar.xz

# 3. Install the shared libraries and executable globally
sudo cp libnode.so* /usr/local/lib/
sudo cp node /usr/local/bin/

# 4. (Optional) Install header files for C/C++ development
sudo cp -r include /usr/local/include/node

# 5. Update the linker cache
sudo ldconfig
```

### macOS
macOS builds are packaged as .tar.xz archives.

```bash
# 1. Download the archive (Replace <version> and <arch> e.g., v26.3.0 and arm64)
curl -LO https://github.com/metacall/libnode/releases/download/<version>/libnode-<arch>-macos.tar.xz

# 2. Extract the archive
tar -xvf libnode-<arch>-macos.tar.xz

# 3. Install the shared library and executable globally
sudo cp libnode.*dylib /usr/local/lib/
sudo cp node /usr/local/bin/

# 4. (Optional) Install header files for C/C++ development
sudo cp -r include /usr/local/include/node
```

### Windows
Windows builds are packaged as .zip archives.

1. Download `libnode-<arch>-windows.zip` from the Releases page. (Replace `<arch>` e.g., `amd64`)
2. Extract the ZIP file to a permanent directory (e.g., C:\libnode).
3. Add the extracted directory path to your System PATH environment variable so your OS can locate libnode.dll and node.exe at runtime.
4. When linking against libnode in your C/C++ project, point your linker to the extracted libnode.lib file, and your include directories to the extracted include folder.

## Integrating with MetaCall
Once you have installed the binaries on your system, you can configure MetaCall to use them via CMake.
Be sure to pass the absolute paths to the executable and the shared library matching your operating system.

Linux Example
```bash
cmake \
  -DNodeJS_EXECUTABLE=/usr/local/bin/node \
  -DNodeJS_LIBRARY=/usr/local/lib/libnode.so \
  ..
```

MacOS Example
```bash
cmake \
  -DNodeJS_EXECUTABLE=/usr/local/bin/node \
  -DNodeJS_LIBRARY=/usr/local/lib/libnode.dylib \
  ..
```

Windows Example
```dos
cmake ^
  -DNodeJS_EXECUTABLE="C:\libnode\node.exe" ^
  -DNodeJS_LIBRARY="C:\libnode\libnode.lib" ^
  ..
```

## Automated Build Pipeline
This repository requires zero manual intervention to generate new releases. The pipeline is fully automated via GitHub Actions:

- scripts/daily-check.sh: Runs on a cron schedule to check nodejs.org/dist/index.json. If a new version exists, it updates version.txt and triggers the build matrices.
- scripts/build.sh: Handles cloning, configuring, and building the shared library for Linux and macOS runners.
- scripts/build.bat: Handles the Visual Studio MSBuild/ClangCL pipeline for Windows runners.

Note on Performance: The Windows builds utilize full OpenSSL hardware assembly optimizations (e.g., AVX2/AVX-512). The resulting .dll dynamically detects CPU capabilities at runtime, ensuring maximum cryptographic performance on modern hardware while safely falling back on older machines.

## License:

This project is licensed under the Apache-2.0 License.
