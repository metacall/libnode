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

REM libffi performs atomic operations using legacy macros. 
REM Its macros expect volatile long * for atomic variables, 
REM but they are being passed int *.
REM On modern versions of Visual Studio (like 2026)
REM -Wincompatible-pointer-types is triggered.
REM https://learn.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-1-c4047
REM https://learn.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-3-c4133
set "CFLAGS=/wd4047 /wd4133 -Wno-incompatible-pointer-types"
set "CXXFLAGS=/wd4047 /wd4133 -Wno-incompatible-pointer-types"

if not exist "node\" (
    git clone https://github.com/nodejs/node --branch %NODE_VERSION% --depth=1
)

cd node
call .\vcbuild.bat %NODE_ARCH% dll
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

sccache --show-stats