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

#include "createuser.h"
#include "base.h"
#include <getopt.h>

int createuser::makeuser()
{
	if (username->get_text_length () ==0)
		return 2;
	Glib::ustring sum="";
	Glib::ustring supplement_groups="video audio optical power";
	if (admswitch->get_state()==true)
	{
		supplement_groups+=" wheel adm admin";
	}
	sum+="useradd -m -R \""+dest+"\" -U \""+(Glib::ustring)username->get_text()+"\" -p \"\" -G $(\""\
		+sharedir()+\
		"\"/sh/groupexist.sh "+supplement_groups+")\n";
	sum+="passwd -e \""+username->get_text()+"\"\n";
	if (system(sum.c_str())==0)
		username->set_text("");
	return 0;
	
}

void createuser::adduser()
{
	int temp=makeuser();
	if (temp!=0)
	{
		std::cerr << "Error";
	}
	if (temp==2)
	{
		std::cerr << "Error: name empty\n";
	}
}

void createuser::quit()
{
	kitcreate.quit();
}

void createuser::adduserquit()
{
	int temp=makeuser();
	if (temp==0)
		kitcreate.quit();
	if (temp==2)
	{
		std::cerr << "Error: name empty\n";
	}
}

createuser::createuser(int argc, char* argv[]): kitcreate(argc, argv)
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
	
	builder = Gtk::Builder::create();
	try
	{
		builder->add_from_file(sharedir()+"/ui/createuser.ui");
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
	createuser_win=transform_to_rptr<Gtk::Window>(builder->get_object("createuser_win"));

	//init entry, checkbutton
	username=transform_to_rptr<Gtk::Entry>(builder->get_object("username"));
	admswitch=transform_to_rptr<Gtk::CheckButton>(builder->get_object("admswitch"));
	
	//init buttons
	addnewuser=transform_to_rptr<Gtk::Button>(builder->get_object("addnewuser"));
	addnewuser->signal_clicked ().connect(sigc::mem_fun(*this,&createuser::adduser));
	breaknewuser=transform_to_rptr<Gtk::Button>(builder->get_object("breaknewuser"));
	breaknewuser->signal_clicked ().connect(sigc::mem_fun(*this,&createuser::quit));
	addnewuserandbreak=transform_to_rptr<Gtk::Button>(builder->get_object("addnewuserandbreak"));
	addnewuserandbreak->signal_clicked ().connect(sigc::mem_fun(*this,&createuser::adduserquit));

	createuser_win->show();
	
	if (createuser_win!=0)
	{
		kitcreate.run(*createuser_win.operator->());
	}
}

