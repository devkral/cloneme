/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
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



//#include "config.h"
#include "gui.h"
#include "copyuser.h"
#include "createuser.h"
#include "base.h"

#include <getopt.h>
//#include <cstdio>

//#ifdef ENABLE_NLS
//#  include <libintl.h>
//#endif

/**
bool comparechar(char *r1, char *r2)
{
	if (r1==NULL||r2==NULL)
		return false;
	else
		if (strcmp(r1,r2)==0)
			return true;
		else
			return false;

}*/



Glib::ustring becomeroot()
{
	//because polkit is bugged
	//if ( access("/usr/bin/pkexec",F_OK)==0)
	//		return (Glib::ustring)"/usr/bin/pkexec ";
			
	if ( access("/usr/bin/gksudo",F_OK)==0)
			return (Glib::ustring)"gksu -S -k ";

	if ( access("/usr/bin/sudo",F_OK)==0)
			return (Glib::ustring)"sudo -E ";
	
	return (Glib::ustring)"su -c";
};

int startgui(int argc, char* argv[])
{
	if (getuid()==0)
	{
		gui(argc,argv);
		return 0;
	}else
	{
		Glib::ustring summary=becomeroot();
		summary+=argv[0];
		for (int count=1; count<argc; count++)
			summary+=argv[count];
		return system(summary.c_str());
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
			default: return startgui(argc,argv);
				break;
		};
	}
	else
		return startgui(argc,argv);
		
	return 0;
}
