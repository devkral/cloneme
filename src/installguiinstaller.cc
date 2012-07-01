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

#include "installguiinstaller.h"
#include "basismethods.h"
#include <iostream>
#include <getopt.h>
#include <unistd.h>

installguiinstaller::installguiinstaller(int argc, char* argv[] )
{

	int ch=0;
	int index=0;
	// options descriptor 
	static struct option longopts[] = {
		{ "dest", required_argument, &ch, 1 },
		{0,0,0,0}
	};
	
	while (getopt_long(argc, argv, "", longopts, &index) != -1)
	{
		switch(ch)
		{
			case 1: dest=optarg;
				break;
			default: ;
				break;
		};
    }

	if (dest.empty())
	{
		std::cerr << "Error: dest wasn't specified\n";
		throw (-1);
	}
	
	if ( access(PACKAGE_DATA_DIR,F_OK)==0)
		srcdata=(std::string)PACKAGE_DATA_DIR;
	else
		srcdata="${PWD}/src";
	destdata=dest+(std::string)PACKAGE_DATA_DIR;
	destbin=dest+(std::string)PACKAGE_BIN_DIR;

	std::string sum="";
	sum+="mkdir -p "+destdata+"\n";
	sum+="cp -r "+srcdata+"/* "+destdata+"\n";
	sum+="cp "+(std::string)argv[0]+" "+destbin+"\n";
	//TODO: copy desktop file
	//sum+=(std::string)"cp "+(std::string)argv[0]+(std::string)" "+dest+(std::string)PACKAGE_BIN_DIR+(std::string)"\n";
	//what is wrong?
	std::string log=system2(sum);
	if (log.empty()==false)
		std::cerr << log;

}
