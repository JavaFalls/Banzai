"""
Build and export each piece for the project Robo Dojo
"""
import os, shutil


# Initialize a log file
def initialize_log():
   os.system('echo. > export_log.txt')

def log(info, to_console=True):
   if to_console:
      print(info)
   else:
      os.system(f'echo {info} >> export_log.txt')

def pause():
   os.system('pause')

def cmd(commands, to_console=True):
   command = ''
   total_commands = len(commands)
   current_command = 0

   for each in commands:
      current_command +=1
      command = command + each
      if not to_console:
         command = command + ' >> ..\\export_log.txt'
      if current_command != total_commands:
         command = command + ' && '
   print(command)
   os.system(command)

# Build custom Godot version
def build_godot():
   log('------------------------------')
   log('  Compile Godot 64-bit Tools')
   log('------------------------------')
   commands = ['cd "Custom Godot\\"',
               '"%PROGRAMFILES(X86)%\\Microsoft Visual Studio\\2017\\Enterprise\\VC\\Auxiliary\\Build\\vcvarsall.bat" amd64',
               'scons -j4 p=windows']
   cmd(commands)

   log('------------------------------')
   log('  Compile Godot 32-bit Tools')
   log('------------------------------')
   commands = ['cd "Custom Godot\\"',
               '"%PROGRAMFILES(X86)%\\Microsoft Visual Studio\\2017\\Enterprise\\VC\\Auxiliary\\Build\\vcvarsall.bat" amd64_x86',
               'scons -j4 p=windows']
   cmd(commands)
   
   log('------------------------------')
   log(' Compile Godot 64-bit Release')
   log('------------------------------')
   commands = ['cd "Custom Godot\\"',
               '"%PROGRAMFILES(X86)%\\Microsoft Visual Studio\\2017\\Enterprise\\VC\\Auxiliary\\Build\\vcvarsall.bat" amd64',
               'scons -j4 platform=windows tools=no target=release']
   cmd(commands)
   
   log('------------------------------')
   log(' Compile Godot 32-bit Release')
   log('------------------------------')
   commands = ['cd "Custom Godot\\"',
               '"%PROGRAMFILES(X86)%\\Microsoft Visual Studio\\2017\\Enterprise\\VC\\Auxiliary\\Build\\vcvarsall.bat" amd64_x86',
               'scons -j4 platform=windows tools=no target=release']
   cmd(commands)
   
   log('------------------------------')
   log('  Compile Godot 64-bit Debug')
   log('------------------------------')
   commands = ['cd "Custom Godot\\"',
               '"%PROGRAMFILES(X86)%\\Microsoft Visual Studio\\2017\\Enterprise\\VC\\Auxiliary\\Build\\vcvarsall.bat" amd64',
               'scons -j4 platform=windows tools=no target=release_debug']
   cmd(commands)
   
   log('------------------------------')
   log('  Compile Godot 32-bit Debug')
   log('------------------------------')
   commands = ['cd "Custom Godot\\"',
               '"%PROGRAMFILES(X86)%\\Microsoft Visual Studio\\2017\\Enterprise\\VC\\Auxiliary\\Build\\vcvarsall.bat" amd64',
               'scons -j4 platform=windows tools=no target=release_debug']
   cmd(commands)

   log('------------------------------')
   log('   Rename Godot Executables')
   log('------------------------------')
   commands = ['cd "Custom Godot\\bin"',
               'copy godot.windows.tools.64.exe godot_64.exe']
   cmd(commands)
   commands = ['cd "Custom Godot\\bin"',
               'copy godot.windows.tools.32.exe godot_32.exe']
   cmd(commands)
   commands = ['cd "Custom Godot\\bin"',
               'copy godot.windows.opt.64.exe windows_64_release.exe']
   cmd(commands)
   commands = ['cd "Custom Godot\\bin"',
               'copy godot.windows.opt.32.exe windows_32_release.exe']
   cmd(commands)
   commands = ['cd "Custom Godot\\bin"',
               'copy godot.windows.opt.debug.64.exe windows_64_debug.exe']
   cmd(commands)
   commands = ['cd "Custom Godot\\bin"',
               'copy godot.windows.opt.debug.32.exe windows_32_debug.exe']
   cmd(commands)

# Build Godot project
def build_robodojo(is_testing=True):
   log('------------------------------')
   log('    Building Main Project')
   log('------------------------------')
   if is_testing:
      commands = ['cd "Custom Godot\\bin"',
                  'godot_64.exe --path ../../Client --export-debug "Default" ../bin/robo_dojo.exe']
      cmd(commands)
   else:
      commands = ['cd "Custom Godot\\bin"',
                  'godot_64.exe --path ../../Client --export "Default" ../bin/robo_dojo.exe']
      cmd(commands)

# Build NNServer
def build_nnserver():
   log('------------------------------')
   log('Building Neural Network Server')
   log('------------------------------')
   commands = ['cd Client\\NeuralNetwork',
               'pyinstaller nnserver.py',
               'move /Y dist\\nnserver dist\\NeuralNetwork',
               'move /Y dist\\NeuralNetwork ..\\..\\bin',
               'rmdir /S /Q __pycache__',
               'rmdir /S /Q build',
               'rmdir /S /Q dist',
               'del nnserver.spec']
   cmd(commands)

# Export remaining dependencies
def export_files(is_testing=True):
   log('------------------------------')
   log('   Exporting Various Files')
   log('------------------------------')
   cmd(['mkdir bin\\NeuralNetwork\\models'])
   cmd(['copy /Y Client\\NeuralNetwork\\generic_model.h5 bin\\NeuralNetwork\\models\\generic_model.h5'])
   if is_testing:
      # Export database connection override file
      cmd(['copy /Y Client\\DBConnectionOverride.ODBCconString bin\\DBConnectionOverride.ODBCconString'])

def initialize_export():
   log('------------------------------')
   log('     Initializing Export')
   log('------------------------------')
   cmd(['mkdir bin'])

def clean():
   log('------------------------------')
   log('      Removing Artifacts')
   log('------------------------------')
   cmd(['rmdir /S /Q bin'])

def zip_directory():
   log('------------------------------')
   log('      Zipping Directory')
   log('------------------------------')
   shutil.make_archive('robo_dojo', 'zip', 'bin')

def main():
   initialize_log()
   initialize_export()
   #build_godot()
   build_robodojo()
   #build_nnserver()
   export_files()
   zip_directory()
   #clean()
   log('------------------------------')
   log('    EXPORTING FINISHED!!!')
   log('------------------------------')

if __name__ == '__main__':
   main()