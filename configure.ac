dnl Process this file with autoconf to produce a configure script.
dnl Created by Anjuta application wizard.

AC_INIT(cloneme, 0.2)

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11])

AM_SILENT_RULES([yes])

AC_PROG_CXX




dnl ***************************************************************************
dnl Internationalization
dnl ***************************************************************************
# IT_PROG_INTLTOOL([0.35.0])

# GETTEXT_PACKAGE=cloneme
# AC_SUBST(GETTEXT_PACKAGE)
# AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE", [GETTEXT package name])
# AM_GLIB_GNU_GETTEXT



# LT_INIT



PKG_CHECK_MODULES(CLONEME, vte-2.90
gtkmm-3.0
[ ])

# po/Makefile.in
AC_OUTPUT([
Makefile
src/Makefile
src/share/Makefile
src/share/ui/Makefile
src/share/sh/Makefile
src/share/src/Makefile
src/desktop/Makefile
tools/Makefile
])
