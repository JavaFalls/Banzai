# Compile Godot
Set-Location '.\Custom Godot\'
pause
cmd.exe
echo Hello World! > log.txt
exit

# Export Robo Dojo

# Export Asset Dependencies

# Compile NNServer

# Export NNServer

# Export Various Dependencies


<#
"%PROGRAMFILES(X86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64
scons -j4 p=windows
scons -j4 platform=windows tools=no target=release
scons -j4 platform=windows tools=no target=release_debug

"%PROGRAMFILES(X86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64_x86
scons -j4 p=windows
scons -j4 platform=windows tools=no target=release
scons -j4 platform=windows tools=no target=release_debug
#>

Pause