@echo off
setlocal enabledelayedexpansion

if "%NODE_VERSION%"=="" (
    set /p NODE_VERSION=<version.txt
)

if "%ARCH%"=="amd64" (
    set NODE_ARCH=x64
) else if "%ARCH%"=="arm64" (
    set NODE_ARCH=arm64
) else (
    set NODE_ARCH=x64
)

set "SCCACHE_DIR=%GITHUB_WORKSPACE%\.sccache"
if not exist "%SCCACHE_DIR%" mkdir "%SCCACHE_DIR%"
set CC_WRAPPER=sccache
set CXX_WRAPPER=sccache
set "SCCACHE_CACHE_SIZE=1536M"

REM Prevent treating warnings as errors and suppress all warnings
set "CFLAGS=/WX- /w -Wno-error -Wno-incompatible-pointer-types"
set "CXXFLAGS=/WX- /w -Wno-error -Wno-incompatible-pointer-types"
set "CL=/WX- /w /clang:-Wno-error /clang:-Wno-incompatible-pointer-types"

if not exist "node\" (
    git clone https://github.com/nodejs/node --branch %NODE_VERSION% --depth=1
)
cd node

REM BUGFIX for Node v26 Windows DLL build using Clang-CL & lld-link.
REM node_mksnapshot statically links to node_base.lib but gets compiled 
REM expecting dllimport symbols. Patching it to expect static symbols instead.
if "!NODE_VERSION:~0,4!"=="v26." (
    findstr /C:"#undef NODE_SHARED_MODE" "tools\snapshot\node_mksnapshot.cc" >nul
    if !ERRORLEVEL! neq 0 (
        echo #undef NODE_SHARED_MODE > tmp_patch.cc
        type "tools\snapshot\node_mksnapshot.cc" >> tmp_patch.cc
        move /y tmp_patch.cc "tools\snapshot\node_mksnapshot.cc" >nul
        echo Applied NODE_SHARED_MODE patch to node_mksnapshot.cc for version !NODE_VERSION!
    )
)

call .\vcbuild.bat %NODE_ARCH% dll
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

sccache --show-stats