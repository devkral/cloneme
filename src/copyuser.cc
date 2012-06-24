/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * cloneme
 * Copyright (C) 2012 alex <alex@archal>
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

#include "copyuser.h"
#include <iostream>
#include <string>
#include <unistd.h>
#include <getopt.h>

static struct option longopts[] = {
	{ "src", required_argument, 0, 0 },
	{ "dest", required_argument, 0, 0 },
	{ "name", required_argument, 0, 0 }
};


copyuser::copyuser(int argc, char* argv[])
{
	int ch;
	while (ch = getopt_long(argc, argv, "+:", longopts, NULL) != -1)
	{
		switch(ch)
		{
			case 0: src=optarg;
				break;
			case 1: dest=optarg;
				break;
			case 2: name=optarg;
				break;
		};
    }
	if  (src.empty())
	{
		std::cerr << "Error: src wasn't specified\n";
		throw (-1);
		
	}

	if (dest.empty())
	{
		std::cerr << "Error: dest wasn't specified\n";
		throw (-1);
	}

	if (name.empty())
	{
		std::cerr << "Error: User wasn't specified\n";
		throw (-1);
	}
}
