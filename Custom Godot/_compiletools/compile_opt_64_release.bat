@echo off
echo.
echo.
echo ------------------------------
echo  Compile Godot 64-bit Release
echo ------------------------------
echo.
cd ../
"%PROGRAMFILES(X86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64 && scons -j4 platform=windows tools=no target=release