import os
import string
import sys


def is_active():
    return True


def get_name():
    return "JavaScript"


def can_build():

    return ("EMSCRIPTEN_ROOT" in os.environ or "EMSCRIPTEN" in os.environ)


def get_opts():
    from SCons.Variables import BoolVariable
    return [
        BoolVariable('javascript_eval', 'Enable JavaScript eval interface', True),
    ]


def get_flags():

    return [
        ('tools', False),
        ('module_theora_enabled', False),
        # Disabling the OpenSSL module noticeably reduces file size.
        # The module has little use due to the limited networking functionality
        # in this platform. For the available networking methods, the browser
        # manages TLS.
        ('module_openssl_enabled', False),
    ]


def create(env):

    # remove Windows' .exe suffix
    return env.Clone(tools=['textfile', 'zip'], PROGSUFFIX='')


def escape_sources_backslashes(target, source, env, for_signature):
    return [path.replace('\\','\\\\') for path in env.GetBuildPath(source)]

def escape_target_backslashes(target, source, env, for_signature):
    return env.GetBuildPath(target[0]).replace('\\','\\\\')


def configure(env):

    ## Build type

    if (env["target"] == "release"):
        # Use -Os to prioritize optimizing for reduced file size. This is
        # particularly valuable for the web platform because it directly
        # decreases download time.
        # -Os reduces file size by around 5 MiB over -O3. -Oz only saves about
        # 100 KiB over -Os, which does not justify the negative impact on
        # run-time performance.
        env.Append(CCFLAGS=['-Os'])
        env.Append(LINKFLAGS=['-Os'])

    elif (env["target"] == "release_debug"):
        env.Append(CCFLAGS=['-O2', '-DDEBUG_ENABLED'])
        env.Append(LINKFLAGS=['-O2'])
        # retain function names at the cost of file size, for backtraces and profiling
        env.Append(LINKFLAGS=['--profiling-funcs'])

    elif (env["target"] == "debug"):
        env.Append(CCFLAGS=['-O1', '-D_DEBUG', '-g', '-DDEBUG_ENABLED'])
        env.Append(LINKFLAGS=['-O1', '-g'])
        env.Append(LINKFLAGS=['-s', 'ASSERTIONS=1'])

    ## Compiler configuration

    env['ENV'] = os.environ
    if ("EMSCRIPTEN_ROOT" in os.environ):
        env.PrependENVPath('PATH', os.environ['EMSCRIPTEN_ROOT'])
    elif ("EMSCRIPTEN" in os.environ):
        env.PrependENVPath('PATH', os.environ['EMSCRIPTEN'])
    env['CC']      = 'emcc'
    env['CXX']     = 'em++'
    env['LINK']    = 'emcc'
    env['RANLIB']  = 'emranlib'
    # Emscripten's ar has issues with duplicate file names, so use cc
    env['AR']      = 'emcc'
    env['ARFLAGS'] = '-o'

    if (os.name == 'nt'):
        # use TempFileMunge on Windows since some commands get too long for
        # cmd.exe even with spawn_fix
        # need to escape backslashes for this
        env['ESCAPED_SOURCES'] = escape_sources_backslashes
        env['ESCAPED_TARGET'] = escape_target_backslashes
        env['ARCOM'] = '${TEMPFILE("%s")}' % env['ARCOM'].replace('$SOURCES', '$ESCAPED_SOURCES').replace('$TARGET', '$ESCAPED_TARGET')

    env['OBJSUFFIX'] = '.bc'
    env['LIBSUFFIX'] = '.bc'

    ## Compile flags

    env.Append(CPPPATH=['#platform/javascript'])
    env.Append(CPPFLAGS=['-DJAVASCRIPT_ENABLED', '-DUNIX_ENABLED', '-DPTHREAD_NO_RENAME', '-DTYPED_METHOD_BIND', '-DNO_THREADS'])
    env.Append(CPPFLAGS=['-DGLES3_ENABLED'])

    # These flags help keep the file size down
    env.Append(CPPFLAGS=["-fno-exceptions", '-DNO_SAFE_CAST', '-fno-rtti'])

    if env['javascript_eval']:
        env.Append(CPPFLAGS=['-DJAVASCRIPT_EVAL_ENABLED'])

    ## Link flags

    env.Append(LINKFLAGS=['-s', 'BINARYEN=1'])
    env.Append(LINKFLAGS=['-s', 'ALLOW_MEMORY_GROWTH=1'])
    env.Append(LINKFLAGS=['-s', 'USE_WEBGL2=1'])

    env.Append(LINKFLAGS=['-s', 'INVOKE_RUN=0'])
    env.Append(LINKFLAGS=['-s', 'NO_EXIT_RUNTIME=1'])

    # TODO: Move that to opus module's config
    if 'module_opus_enabled' in env and env['module_opus_enabled']:
        env.opus_fixed_point = "yes"
