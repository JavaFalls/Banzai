import os
import sys


def is_active():
    return True


def get_name():
    return "OSX"


def can_build():

    if (sys.platform == "darwin" or ("OSXCROSS_ROOT" in os.environ)):
        return True

    return False


def get_opts():
    from SCons.Variables import BoolVariable, EnumVariable

    return [
        ('osxcross_sdk', 'OSXCross SDK version', 'darwin14'),
        EnumVariable('debug_symbols', 'Add debug symbols to release version', 'yes', ('yes', 'no', 'full')),
        BoolVariable('separate_debug_symbols', 'Create a separate file with the debug symbols', False),
    ]


def get_flags():

    return [
    ]


def configure(env):

	## Build type

    if (env["target"] == "release"):
        env.Prepend(CCFLAGS=['-O3', '-ffast-math', '-fomit-frame-pointer', '-ftree-vectorize', '-msse2'])
        if (env["debug_symbols"] == "yes"):
            env.Prepend(CCFLAGS=['-g1'])
        if (env["debug_symbols"] == "full"):
            env.Prepend(CCFLAGS=['-g2'])

    elif (env["target"] == "release_debug"):
        env.Prepend(CCFLAGS=['-O2', '-DDEBUG_ENABLED'])
        if (env["debug_symbols"] == "yes"):
            env.Prepend(CCFLAGS=['-g1'])
        if (env["debug_symbols"] == "full"):
            env.Prepend(CCFLAGS=['-g2'])

    elif (env["target"] == "debug"):
        env.Prepend(CCFLAGS=['-g3', '-DDEBUG_ENABLED', '-DDEBUG_MEMORY_ENABLED'])

    ## Architecture

    is64 = sys.maxsize > 2**32
    if (env["bits"] == "default"):
        env["bits"] = "64" if is64 else "32"

    ## Compiler configuration

    if "OSXCROSS_ROOT" not in os.environ: # regular native build
        if (env["bits"] == "fat"):
            env.Append(CCFLAGS=['-arch', 'i386', '-arch', 'x86_64'])
            env.Append(LINKFLAGS=['-arch', 'i386', '-arch', 'x86_64'])
        elif (env["bits"] == "32"):
            env.Append(CCFLAGS=['-arch', 'i386'])
            env.Append(LINKFLAGS=['-arch', 'i386'])
        else: # 64-bit, default
            env.Append(CCFLAGS=['-arch', 'x86_64'])
            env.Append(LINKFLAGS=['-arch', 'x86_64'])
        if (env["macports_clang"] != 'no'):
            mpprefix = os.environ.get("MACPORTS_PREFIX", "/opt/local")
            mpclangver = env["macports_clang"]
            env["CC"] = mpprefix + "/libexec/llvm-" + mpclangver + "/bin/clang"
            env["LINK"] = mpprefix + "/libexec/llvm-" + mpclangver + "/bin/clang++"
            env["CXX"] = mpprefix + "/libexec/llvm-" + mpclangver + "/bin/clang++"
            env['AR'] = mpprefix + "/libexec/llvm-" + mpclangver + "/bin/llvm-ar"
            env['RANLIB'] = mpprefix + "/libexec/llvm-" + mpclangver + "/bin/llvm-ranlib"
            env['AS'] = mpprefix + "/libexec/llvm-" + mpclangver + "/bin/llvm-as"
            env.Append(CCFLAGS=['-D__MACPORTS__']) #hack to fix libvpx MM256_BROADCASTSI128_SI256 define

    else: # osxcross build
        root = os.environ.get("OSXCROSS_ROOT", 0)
        if env["bits"] == "fat":
            basecmd = root + "/target/bin/x86_64-apple-" + env["osxcross_sdk"] + "-"
            env.Append(CCFLAGS=['-arch', 'i386', '-arch', 'x86_64'])
            env.Append(LINKFLAGS=['-arch', 'i386', '-arch', 'x86_64'])
        elif env["bits"] == "32":
            basecmd = root + "/target/bin/i386-apple-" + env["osxcross_sdk"] + "-"
        else: # 64-bit, default
            basecmd = root + "/target/bin/x86_64-apple-" + env["osxcross_sdk"] + "-"

        ccache_path = os.environ.get("CCACHE")
        if ccache_path == None:
            env['CC'] = basecmd + "cc"
            env['CXX'] = basecmd + "c++"
        else:
            # there aren't any ccache wrappers available for OS X cross-compile,
            # to enable caching we need to prepend the path to the ccache binary
            env['CC'] = ccache_path + ' ' + basecmd + "cc"
            env['CXX'] = ccache_path + ' ' + basecmd + "c++"
        env['AR'] = basecmd + "ar"
        env['RANLIB'] = basecmd + "ranlib"
        env['AS'] = basecmd + "as"
        env.Append(CCFLAGS=['-D__MACPORTS__']) #hack to fix libvpx MM256_BROADCASTSI128_SI256 define

    if (env["CXX"] == "clang++"):
        env.Append(CPPFLAGS=['-DTYPED_METHOD_BIND'])
        env["CC"] = "clang"
        env["LINK"] = "clang++"

    ## Dependencies

    if env['builtin_libtheora']:
        env["x86_libtheora_opt_gcc"] = True

    ## Flags

    env.Append(CPPPATH=['#platform/osx'])
    env.Append(CPPFLAGS=['-DOSX_ENABLED', '-DUNIX_ENABLED', '-DGLES_ENABLED', '-DAPPLE_STYLE_KEYS', '-DCOREAUDIO_ENABLED'])
    env.Append(LINKFLAGS=['-framework', 'Cocoa', '-framework', 'Carbon', '-framework', 'OpenGL', '-framework', 'AGL', '-framework', 'AudioUnit', '-framework', 'CoreAudio', '-lz', '-framework', 'IOKit', '-framework', 'ForceFeedback'])
    env.Append(LIBS=['pthread'])

    env.Append(CPPFLAGS=['-mmacosx-version-min=10.9'])
    env.Append(LINKFLAGS=['-mmacosx-version-min=10.9'])
