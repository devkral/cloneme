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
	basismethods.h \
	basismethods.cc \
	installguiinstaller.cc \
	installguiinstaller.h

cloneme_LDFLAGS = 

cloneme_LDADD = $(CLONEME_LIBS)



SUBDIRS = \
	ui \
	sh \
	desktop

AM_CXXFLAGS = -std=c++11 
