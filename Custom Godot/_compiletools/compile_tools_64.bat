@echo off
echo.
echo.
echo ------------------------------
echo   Compile Godot 64-bit Tools
echo ------------------------------
echo.
cd ../
"%PROGRAMFILES(X86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat" && scons -j4 p=windows