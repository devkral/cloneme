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

#include "copyuser.h"
#include "basismethods.h"
#include <iostream>
#include <string>
#include <unistd.h>
#include <getopt.h>



static struct option longopts[] = {
	{ "src", required_argument, 0, 0 },
	{ "dest", required_argument, 0, 0 },
	{ "name", required_argument, 0, 0 }
};



void copyuser::synch()
{
	std::string sum="";
	sum+="        rsync -a -A --progress --delete --exclude \""+dest+"\" \""+src+"\"home/\""+name+"\" \""+dest+"\"/home/\n";
	std::cerr << system2(sum);
}

void copyuser::clean()
{
	std::string sum="";
sum+="        if [ ! -d \""+dest+"\"/home/\""+name+"\" ];then\n";
	if (==true)
		sum+="question_delete=\"yes\"\n";
	else
		sum+="question_delete=\"no\"\n";
		
sum+="          if [ \"$question_delete\" = \"yes\" ]; then\n";
sum+="            \n";
sum+="            sed -i -e \"/^"+name+"/d\" \""+dest+"\"/etc/passwd\n";
sum+="            sed -i -e \"/^"+name+"/d\" \""+dest+"\"/etc/passwd-\n";
sum+="            sed -i -e \"/^"+name+"/d\" \""+dest+"\"/etc/group\n";
sum+="            sed -i -e \"s/\b"+name+"\b//g\" \""+dest+"\"/etc/group\n";
sum+="            sed -i -e \"/^"+name+"/d\" \""+dest+"\"/etc/group-\n";
sum+="            sed -i -e \"s/\b"+name+"\b//g\" \""+dest+"\"/etc/group-\n";
sum+="            sed -i -e \"/^"+name+"/d\" \""+dest+"\"/etc/gshadow\n";
sum+="            sed -i -e \"s/\b"+name+"\b//g\" \""+dest+"\"/etc/gshadow\n";
sum+="            sed -i -e \"/^"+name+"/d\" \""+dest+"\"/etc/gshadow-\n";
sum+="            sed -i -e \"s/\b"+name+"\b//g\" \""+dest+"\"/etc/gshadow-\n";
sum+="            rm \"/var/spool/mail/"+name+"\" 2> /dev/null\n";
sum+="            echo \"cleaning finished\"\n";
sum+="          fi\n";
sum+="        fi\n";

	system2(sum);

}

void copyuser::empty()
{
	std::string sum="";
	sum+="        mkdir -p \""+dest+"\"/home/\"$usertemp\"\n";
	sum+="        \n";
	sum+="        if grep \"$usertemp\" \""+src+"\"etc/passwd > /dev/null;then\n";
	sum+="          chown $usertemp \""+dest+"\"/home/\"$usertemp\"\n";
	sum+="          \n";
	sum+="          if grep \"$usertemp\" \""+src+"\"etc/group > /dev/null;then\n";
	sum+="            chown $usertemp:$usertemp \""+dest+"\"/home/\"$usertemp\"\n";
	sum+="          fi\n";
	sum+="        fi\n";

	system2(sum);
}

void copyuser::explaining()
{
	if (explaination->get_visible())
		explaination->hide();
	else
		explaination->show();

}

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

	builder = Gtk::Builder::create();
	try
	{
		builder->add_from_file(PACKAGE_DATA_DIR"/ui/copyuser.ui");
	}
	catch(const Glib::FileError& ex)
	{
		//std::cerr << ENOENT;
		//if (ex.code()==ENOENT)
		//	std::cerr << "good";
		//strange ENOENT doesn't work even it should correspond
		if (ex.code()==4)
		{
			std::cerr << "copyuser.ui not found; fall back to src directory\n";
			try
			{
				builder->add_from_file("./src/ui/copyuser.ui");
			}
			catch(const Glib::FileError& ex)
			{
				std::cerr << "FileError: " << ex.what() << std::endl;
				throw(ex);
			}
			catch(const Glib::MarkupError& ex)
			{
				std::cerr << "MarkupError: " << ex.what() << std::endl;
				throw(ex);
			}
			catch(const Gtk::BuilderError& ex)
			{
				std::cerr << "BuilderError: " << ex.what() << std::endl;
				throw(ex);
			}
		}
		else
		{
			std::cerr << "FileError: " << ex.what() << std::endl;
			throw(ex);
		}
	}
	catch(const Glib::MarkupError& ex)
	{
		std::cerr << "MarkupError: " << ex.what() << std::endl;
		throw(ex);
	}
	catch(const Gtk::BuilderError& ex)
	{
		std::cerr << "BuilderError: " << ex.what() << std::endl;
		throw(ex);
	}
	copyuser_win=transform_to_rptr<Gtk::Window>(builder->get_object("copyuser_win"));
	explaination=transform_to_rptr<Gtk::Window>(builder->get_object("explaination"));
	
	username=transform_to_rptr<Gtk::Label>(builder->get_object("username"));
	username->set_text(name);
	copysynch=transform_to_rptr<Gtk::Button>(builder->get_object("copysynch"));
	copysynch->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::synch));
	createempty=transform_to_rptr<Gtk::Button>(builder->get_object("createempty"));
	createempty->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::empty));
	explain=transform_to_rptr<Gtk::Button>(builder->get_object("explain"));
	explain->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::explaining));
	deleteusercomp=transform_to_rptr<Gtk::Button>(builder->get_object("deleteusercomp"));
	deletepasswd=transform_to_rptr<Gtk::CheckButton>(builder->get_object("deletepasswd"));
	if ( access("/home/"+name,F_OK)==0)
	{
		//hide
		deletepasswd->set_active(false);
		deletepasswd->hide();
		explain->hide();
		copysynch->set_text("Synchronize target account");
		copysynch->set_text("Delete the user files of the existing target account");
		copysynch->set_text("Don't touch the existing target account");

	}
	copyuser_win->show();
}
