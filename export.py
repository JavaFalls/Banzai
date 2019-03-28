"""
Script that automates the build process for the project Robo Dojo

NOTES: Must be located in the directory that contains both the
       'Client' folder as well as the 'Custom Godot' folder

KNOWN BUGS: . . .
"""
import os, shutil, sys

def main():
   is_release = False

   visual_studio_path = (sys.argv[1] + '\\vcvarsall.bat')

   if os.path.isfile(visual_studio_path):
      # Initialize directory for build
      initialize(build_debug=(not is_release))

      # Build executables and move them to the created directory
      build_godot(build_32=True, build_64=True, build_debug=(not is_release), vs_path=('"' + visual_studio_path + '"'))
      build_project(build_debug=(not is_release))
      build_nnserver(build_debug=(not is_release))

      # Package build files and clean remaining artifacts
      export_files(build_debug=(not is_release))
      zip_directory(build_debug=(not is_release))
      clean()

      # Print message to signify completion
      print('------------------------------')
      print('    EXPORTING FINISHED!!!')
      print('------------------------------')

   else:
      print('------------------------------')
      print('   vcvarsall.bat Not Found')
      print('------------------------------')

def clean():
   print('------------------------------')
   print('      Removing Artifacts')
   print('------------------------------')
   cmd(['rmdir /S /Q Robo_Dojo'])
   cmd(['rename bin Robo_Dojo'])

# Create a single Windows shell command from an array of commands
def cmd(commands):
   command = ''
   total_commands = len(commands)
   current_command = 0

   # Build Windows shell command string
   for each in commands:
      current_command +=1
      command = command + each
      if current_command != total_commands:
         command = command + ' && '

   # Print and process command
   print('\nRunning Command:')
   print('   ' + command)
   os.system(command)

# Build Custom Godot version
def build_godot(build_32=True, build_64=True, build_debug=True, vs_path='"%PROGRAMFILES(X86)%\\Microsoft Visual Studio\\2017\\Enterprise\\VC\\Auxiliary\\Build\\vcvarsall.bat"'):
   if build_64:
      print('------------------------------')
      print('  Compile Godot 64-bit Tools')
      print('------------------------------')
      commands = ['cd "Custom Godot\\"',
                  vs_path + ' amd64',
                  'scons -j4 p=windows']
      cmd(commands)
      
      print('------------------------------')
      print(' Compile Godot 64-bit Release')
      print('------------------------------')
      commands = ['cd "Custom Godot\\"',
                  vs_path + ' amd64',
                  'scons -j4 platform=windows tools=no target=release']
      cmd(commands)
      
      if build_debug:
         print('------------------------------')
         print('  Compile Godot 64-bit Debug')
         print('------------------------------')
         commands = ['cd "Custom Godot\\"',
                     vs_path + ' amd64',
                     'scons -j4 platform=windows tools=no target=release_debug']
         cmd(commands)

   if build_32:
      print('------------------------------')
      print('  Compile Godot 32-bit Tools')
      print('------------------------------')
      commands = ['cd "Custom Godot\\"',
                  vs_path + ' amd64_x86',
                  'scons -j4 p=windows']
      cmd(commands)
      
      print('------------------------------')
      print(' Compile Godot 32-bit Release')
      print('------------------------------')
      commands = ['cd "Custom Godot\\"',
                  vs_path + ' amd64_x86',
                  'scons -j4 platform=windows tools=no target=release']
      cmd(commands)
      
      if build_debug:
         print('------------------------------')
         print('  Compile Godot 32-bit Debug')
         print('------------------------------')
         commands = ['cd "Custom Godot\\"',
                     vs_path + ' amd64',
                     'scons -j4 platform=windows tools=no target=release_debug']
         cmd(commands)

   print('------------------------------')
   print('   Rename Godot Executables')
   print('------------------------------')
   if build_64:
      print('Copy file as godot_64.exe')
      commands = ['cd "Custom Godot\\bin"',
                  'copy /Y godot.windows.tools.64.exe godot_64.exe']
      cmd(commands)

      print('Copy file as windows_64_release.exe')
      commands = ['cd "Custom Godot\\bin"',
                  'copy /Y godot.windows.opt.64.exe windows_64_release.exe']
      cmd(commands)

      if build_debug:
         print('Copy file as windows_64_release.exe')
         commands = ['cd "Custom Godot\\bin"',
                     'copy /Y godot.windows.opt.debug.64.exe windows_64_debug.exe']
         cmd(commands)

   if build_32:
      print('Copy file as windows_64_release.exe')
      commands = ['cd "Custom Godot\\bin"',
                  'copy /Y godot.windows.tools.32.exe godot_32.exe']
      cmd(commands)

      print('Copy file as windows_64_release.exe')
      commands = ['cd "Custom Godot\\bin"',
                  'copy /Y godot.windows.opt.32.exe windows_32_release.exe']
      cmd(commands)

      if build_debug:
         print('Copy file as windows_64_release.exe')
         commands = ['cd "Custom Godot\\bin"',
                     'copy /Y godot.windows.opt.debug.32.exe windows_32_debug.exe']
         cmd(commands)

# Build neural network module
def build_nnserver(build_debug=True):
   print('------------------------------')
   print('Building Neural Network Server')
   print('------------------------------')
   commands = ['cd Client\\NeuralNetwork',
               'pyinstaller nnserver.py',
               'move /Y dist\\nnserver dist\\NeuralNetwork',
               'move /Y dist\\NeuralNetwork ..\\..\\bin\\Release',
               'rmdir /S /Q __pycache__',
               'rmdir /S /Q build',
               'rmdir /S /Q dist',
               'del nnserver.spec']
   cmd(commands)
   if build_debug:
      cmd(['cd bin',
           'mkdir Debug\\NeuralNetwork',
           'xcopy /Y /S Release\\NeuralNetwork Debug\\NeuralNetwork'])

# Build project executable
def build_project(build_debug=True):
   print('------------------------------')
   print('    Building Main Project')
   print('------------------------------')

   # Export asset information
   cmd(['cd "Custom Godot\\bin"',
        'godot_64.exe --path ../../Client --export "Default" ../bin/robo_dojo.zip'])

   # Build release version
   cmd(['cd "Custom Godot\\bin"',
        'godot_64.exe --path ../../Client --export "Default" ../bin/Release/Robo_Dojo.exe'])
   shutil.unpack_archive('bin/robo_dojo.zip', extract_dir='bin/Release')

   # Build debug version
   if build_debug:
      cmd(['cd "Custom Godot\\bin"',
           'godot_64.exe --path ../../Client --export-debug "Default" ../bin/Debug/Robo_Dojo.exe'])
      shutil.unpack_archive('bin/robo_dojo.zip', extract_dir='bin/Debug')

   # Delete Unneeded file
   cmd(['del bin\\robo_dojo.zip'])

# Export remaining dependencies
def export_files(build_debug=True):
   print('------------------------------')
   print('   Exporting Various Files')
   print('------------------------------')

   # Export default neural network model
   cmd(['mkdir bin\\Release\\NeuralNetwork\\models',
        'copy /Y Client\\NeuralNetwork\\generic_model.h5 bin\\Release\\NeuralNetwork\\models\\generic_model.h5'])

   # Export files for debug version
   if build_debug:
      # Export database connection override file and default neural network model
      cmd(['copy /Y Client\\DBConnectionOverride.ODBCconString bin\\Debug\\DBConnectionOverride.ODBCconString',
           'mkdir bin\\Debug\\NeuralNetwork\\models',
           'copy /Y Client\\NeuralNetwork\\generic_model.h5 bin\\Debug\\NeuralNetwork\\models\\generic_model.h5'])

def initialize(build_debug=True):
   # Create directory to store all build files
   print('------------------------------')
   print('     Initializing Export')
   print('------------------------------')

   # Create build directory for release version
   cmd(['mkdir bin',
        'cd bin',
        'mkdir Release'])

   # Create a batch file to start the release version
   cmd(['cd bin',
        'echo cd Release > Robo_Dojo.bat',
        'echo start Robo_Dojo.bat >> Robo_Dojo.bat'])

   # Create a batch file to start both the game and the Neural Network
   cmd(['cd bin\\Release',
        'echo start Robo_Dojo.exe > Robo_Dojo.bat',
        'echo start NeuralNetwork\\nnserver.exe >> Robo_Dojo.bat'])

   if build_debug:
      # Create build directory for debug version
      cmd(['cd bin',
           'mkdir Debug'])

      # Create a batch file to start the debug version
      cmd(['cd bin',
           'echo cd Debug > Robo_Dojo_Debug.bat',
           'echo start Robo_Dojo.bat >> Robo_Dojo_Debug.bat'])

      # Create a batch file to start both the game and the Neural Network
      cmd(['cd bin\\Debug',
           'echo start Robo_Dojo.exe > Robo_Dojo.bat',
           'echo start NeuralNetwork\\nnserver.exe >> Robo_Dojo.bat'])

def zip_directory(build_debug=True):
   # Compress directory to a zip archive
   print('------------------------------')
   print('      Zipping Directory')
   print('------------------------------')
   shutil.make_archive('Robo_Dojo', 'zip', 'bin/Release')
   if build_debug:
      shutil.make_archive('Robo_Dojo_Debug', 'zip', 'bin/Debug')


if __name__ == '__main__':
   main()