@echo off
echo.
echo -------------------------
echo Godot 64 bit Tools
"%PROGRAMFILES(X86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64 && scons -j4 p=windows