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

if not exist "node\" (
    git clone https://github.com/nodejs/node --branch %NODE_VERSION% --depth=1
)

cd node
call .\vcbuild.bat %NODE_ARCH% dll
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%