import Scripting

VERSION = '0.1.1'
APPNAME = 'commandeer'
srcdir = '.'
blddir = 'build'

Scripting.excludes += ['debian', '.bzr-builddeb']
Scripting.g_gz = 'gz'

def set_options(opt):
    opt.tool_options('compiler_cc')

def configure(conf):
    conf.check_tool('compiler_cc cc vala')
    conf.check_cfg(package='glib-2.0', uselib_store='GLIB', mandatory=1, args='--cflags --libs')
    conf.check_cfg(package='gtk+-2.0', uselib_store='GTK', atleast_version='2.10.0', mandatory=1, args='--cflags --libs')
    
    conf.define('PACKAGE', APPNAME)
    conf.define('VERSION', VERSION)
    conf.write_config_header('config.h')

def build(bld):
    bld.add_subdirs('src')
