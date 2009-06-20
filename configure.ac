# Init autoconf/automake
AC_INIT([Commandeer], [0.1], [https://launchpad.net/commandeer/+filebug])
AM_INIT_AUTOMAKE(foreign -Wall)
AC_PREREQ(2.60)

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_SRCDIR([src/commandeer.vala])

AC_PROG_CC
AC_PATH_PROG(VALAC, valac, valac)
AC_PROG_INSTALL

PKG_CHECK_MODULES(GLIB, glib-2.0,,AC_MSG_ERROR([glib-2.0 is required]))
PKG_CHECK_MODULES(GOBJECT, gobject-2.0,,AC_MSG_ERROR([gobject-2.0 is required]))
PKG_CHECK_MODULES(GTK, gtk+-2.0,,AC_MSG_ERROR([gtk+-2.0 is required]))

AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)
AC_SUBST(GOBJECT_CFLAGS)
AC_SUBST(GOBJECT_LIBS)
AC_SUBST(GTK_CFLAGS)
AC_SUBST(GTK_LIBS)

AC_CONFIG_FILES([Makefile
	src/Makefile])
AC_OUTPUT

# Finalize script output
printf "\nConfiguration complete.\n"
printf "Type 'make' to build, 'make all' to install.\n"
