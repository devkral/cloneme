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
#include "installguiinstaller.h"

#include <getopt.h>
#include <unistd.h>
#include <cstdlib>
#include <string>
#include <iostream>
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



std::string becomeroot()
{
//what did I want to prevent here?
//	bool preserving=false;
//	if ( access(PACKAGE_DATA_DIR"/ui/",F_OK)==0)
//		preserving=true;
	
	if ( access("/usr/bin/gksudo",F_OK)==0)
//		if (preserving)
			return (std::string)"gksudo -k ";
//		else
//			return (std::string)"gksudo ";
	if ( access("/usr/bin/gksu",F_OK)==0)
//		if (preserving)
			return (std::string)"gksu -S -k ";
//		else
//			return (std::string)"gksu -S ";
	
	if ( access("/usr/bin/sudo",F_OK)==0)
//		if (preserving)
			return (std::string)"sudo -E ";
//		else
//			return (std::string)"sudo ";
	
	return (std::string)"su -c";
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
	int ch=0;
	// options descriptor 
	static struct option longopts[] = {
		//needs args but this is handled by copyuser directly
        { "copyuser", no_argument, &ch, 1 },
        { "createuser", no_argument, &ch, 2 },
		{ "installme", no_argument, &ch, 3 },
		{0, 0, 0, 0}
	};
	int index=1;
	if (getopt_long(argc, argv, "", longopts, &index) != -1)
	{
		switch(ch)
		{
			case 1: copyuser(argc,argv);
				break;
			case 2: createuser(argc,argv);
				break;
			case 3: installguiinstaller (argc, argv);
				break;
//			case 'e': //not ready
//				break;
			default: startgui(argc,argv);
				break;
		};
	}
	else
		startgui(argc,argv);

	return 0;
}
