/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 *
 * Created by alex devkral@web.de
 *
 * Copyright (c) 2012
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
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
	
	self=(std::string)argv[0];
	if ( access(PACKAGE_DATA_DIR,F_OK)==0)
		srcdata=(std::string)PACKAGE_DATA_DIR;
	else
		srcdata="${PWD}/src";
	
	
	if ( access(PACKAGE_LINK_DIR"/cloneme.desktop",F_OK)==0)
		srclinkdir=(std::string)PACKAGE_LINK_DIR;
	else
		srclinkdir="${PWD}/src/desktop";
		
	destdata=dest+(std::string)PACKAGE_DATA_DIR;
	destbin=dest+(std::string)PACKAGE_BIN_DIR;
	destlinkdir=dest+(std::string)PACKAGE_LINK_DIR;

	std::string sum="";
	sum+="mkdir -p "+destdata+"\n";
	sum+="cp -r "+srcdata+"/* "+destdata+"\n";
	sum+="mkdir -p "+destbin+"\n";
	sum+="cp "+self+" "+destbin+"\n";
	//copy desktop file
	sum+="mkdir -p "+destlinkdir+"\n";
	sum+="cp "+srclinkdir+"/cloneme.desktop "+destlinkdir+"\n";
	std::string log=system2(sum);
	if (!log.empty())
		std::cerr << log;

}
