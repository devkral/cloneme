/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * main.cc
 * Copyright (C) 2012 alex <devkral@web.de>
 * 
 * cloneme is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * cloneme is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */



//#include "config.h"
#include "gui.h"
#include "copyuser.h"
#include "createuser.h"

#include <getopt.h>
//#include <unistd.h>
//#include <gio.h>
#include <cstdlib>
#include <string>
//#include <iostream>
//#include <cstdio>

#ifdef ENABLE_NLS
#  include <libintl.h>
#endif


bool comparechar(char *r1, char *r2)
{
	if (r1==NULL||r2==NULL)
		return false;
	else
		if (strcmp(r1,r2)==0)
			return true;
		else
			return false;

}

// options descriptor 
static struct option longopts[] = {
        { "copyuser", no_argument, 0, 'c' },
        { "create", no_argument, 0, 'n' },
        { "install_bootloader",  no_argument, 0, 'i' },
        { "edit", no_argument, 0, 'e' }
};

std::string becomeroot()
{
	//Gtk::Main t();
/**	
	Glib::RefPtr<Gio::File> preserve = Gio::File::create_for_path ((std::string)(PACKAGE_DATA_DIR"/ui/"));

	Glib::RefPtr<Gio::File> testsudo1 = Gio::File::create_for_path ("/usr/bin/gksudo");
	Glib::RefPtr<Gio::File> testsudo2 = Gio::File::create_for_path ("/usr/bin/sudo");
	Glib::RefPtr<Gio::File> testsu1 = Gio::File::create_for_path ("/usr/bin/gksu");
//	Glib::RefPtr<Gio::File> testsu2 = Gio::File::create_for_path ("/bin/su");
//in case of a strange distro
//	Glib::RefPtr<Gio::File> testsu3 = Gio::File::create_for_path ("/usr/bin/su");
	bool preserving=false;
	if ( preserve->query_exists())
		preserving=true;
	if ( testsudo1->query_exists())
		if (preserving)
			return (std::string)"gksudo -k ";
		else
			return (std::string)"gksudo ";
	if ( testsudo2->query_exists())
		if (preserving)
			return (std::string)"sudo -E ";
		else
			return (std::string)"sudo ";
	if ( testsu1->query_exists())
		if (preserving)
			return (std::string)"gksu -k ";
		else
			return (std::string)"gksu ";*/
	//return (std::string)"su -c";
	return (std::string)"gksudo -k ";
};

void startgui(int argc, char* argv[])
{
	if (getuid()==0)
	{
		gui(argc,argv);
	}
	if (getuid()!=0)
	{
		std::string summary=becomeroot();
		summary+=argv[0];
		for (int count=1; count<argc; count++)
			summary+=argv[count];
		system(summary.c_str());
	}
}


int
main (int argc, char *argv[])
{
	//std::cout << getuid();
	
	//Gtk::Main();
	int ch;

	if (ch = getopt_long(argc, argv, ":", longopts, NULL) != -1)
	{
		switch(ch)
		{
			case 1: copyuser(argc,argv);
				break;
			case 2: createuser(argc,argv);
				break;
			case 3: //not ready
				break;
			case 4: //not ready
				break;
			default: startgui(argc,argv);
				break;
		};
	}
	else
		startgui(argc,argv);

	return 0;
}
