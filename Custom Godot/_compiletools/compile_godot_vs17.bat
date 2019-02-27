start "Godot Compile Environment x64" "%PROGRAMFILES(X86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64 ^&^& cd ../ ^&^& scons -j4 p=windows --config=force
