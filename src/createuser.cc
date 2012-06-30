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
#include "basismethods.h"
#include <string>
//#include <unistd.h>
//#include <getopt.h>
#include <iostream>

int createuser::usercreation()
{
	
	if (log="")
		return 0;
	
	std::cerr << log;
	return 1;
	
}

void createuser::adduser()
{
	if (usercreation()==0)
		std::cout << "success";
}

void createuser::quit()
{
	kitcreate.quit();
}

void createuser::adduserquit()
{
	if (usercreation()==0)
		kitcreate.quit();
}

createuser::createuser(int argc, char* argv[]): kitcreate(argc, argv)
{
	builder = Gtk::Builder::create();
	try
	{
		builder->add_from_file(PACKAGE_DATA_DIR"/ui/createuser.ui");
	}
	catch(const Glib::FileError& ex)
	{
		//std::cerr << ENOENT;
		//if (ex.code()==ENOENT)
		//	std::cerr << "good";
		//strange ENOENT doesn't work even it should correspond
		if (ex.code()==4)
		{
			std::cerr << "createuser.ui not found; fall back to src directory\n";
			try
			{
				builder->add_from_file("./src/ui/createuser.ui");
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
	createuser_win=transform_to_rptr<Gtk::Window>(builder->get_object("copyuser_win"));

	//init entry, checkbutton
	username=transform_to_rptr<Gtk::Button>(builder->get_object("username"));
	admswitch=transform_to_rptr<Gtk::CheckButton>(builder->get_object("admswitch"));
	
	//init buttons
	addnewuser=transform_to_rptr<Gtk::Button>(builder->get_object("addnewuser"));
	addnewuser->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::adduser));
	breaknewuser=transform_to_rptr<Gtk::Button>(builder->get_object("breaknewuser"));
	breaknewuser->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::quit));
	addnewuserandbreak=transform_to_rptr<Gtk::Button>(builder->get_object("addnewuserandbreak"));
	addnewuserandbreak->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::adduserquit));

	createuser_win->show();
	
	if (createuser_win!=0)
	{
		kitcreate.run(*main_win.operator->());
	}
}

