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
#include <unistd.h>
#include <gtkmm.h>
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

int
main (int argc, char *argv[])
{
	//std::cout << getuid();
	if (getuid()==0 || comparechar(argv[1],(char*)"test"))
		gui(argc,argv);
	if (getuid()!=0 && comparechar(argv[1],(char*)"test")==false)
	{
		std::string summary="gksu -k ";
		summary+=argv[0];
		system(summary.c_str());
	}
	return 0;
}
