## Process this file with automake to produce Makefile.in

## Created by Anjuta



AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_BIN_DIR=\""$(bindir)"\" \
	-DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
	-DPACKAGE_LINK_DIR=\""$(datarootdir)/applications"\" \
	$(CLONEME_CFLAGS)

AM_CFLAGS =\
	 -Wall\
	 -g


bin_PROGRAMS = cloneme

cloneme_SOURCES = \
	main.cc \
	gui.cc \
	gui.h \
	copyuser.cc \
	copyuser.h \
	createuser.cc \
	createuser.h \
	myfilechooser.cc \
	myfilechooser.h \
	base.h \
	base.cc

cloneme_LDFLAGS = 

cloneme_LDADD = $(CLONEME_LIBS)

cmdverdir = $(bindir)

cmdver_SCRIPTS = clonemecmd.sh

#adjust path (data-hook because exec-hook is too fast)
install-data-hook:
	sed -i -e "s|.* #--replacepattern--|sharedir=\"$(pkgdatadir)\" #--replacepattern--|" "$(bindir)"/clonemecmd.sh
		
SUBDIRS = \
	desktop \
	share
