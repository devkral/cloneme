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
#include "base.h"
#include <getopt.h>




void copyuser::cleanuser()
{
	Glib::ustring sum=sharedir()+"/sh/cleanuser.sh \""+name+"\" \""+dest+"\"\n";
	if (system(sum.c_str())==0)
		kitcopy.quit();
}


void copyuser::copysynchf()
{
	Glib::ustring sum=sharedir()+"/sh/copyuser.sh --src \""+src+"\" --dest \""+dest+"\" --user \""+name+"\" --action s\n";
	if (system(sum.c_str())==0)
		kitcopy.quit();
}

void copyuser::ignoref()
{
	//user_exist==true has an extra button for this
	if (cleantargetsys->get_active ()==true && user_exist==false)
		cleanuser();
	kitcopy.quit();
}

void copyuser::emptyf()
{
	Glib::ustring sum=sharedir()+"/sh/copyuser.sh --src \""+src+"\" --dest \""+dest+"\" --user \""+name+"\" --action e\n";
	if (system(sum.c_str())==0)
		kitcopy.quit();
}

void copyuser::explainf()
{
	if (explaination->get_visible())
		explaination->hide();
	else
		explaination->show();

}

void copyuser::setactionspace(Gtk::Widget &actionbar)
{
	//pactions->remove();
	pactions->add(actionbar);
	pactions->show ();
}

copyuser::copyuser(int argc, char* argv[]): kitcopy(argc, argv)
{
	int ch=0;
	int index=0;
	// options descriptor 
	static struct option longopts[] = {
		{ "src", required_argument, &ch, 1 },
		{ "dest", required_argument, &ch, 2 },
		{ "user", required_argument, &ch, 3 },
		{0,0,0,0}
	};
	
	while (getopt_long(argc, argv, "", longopts, &index) != -1)
	{
		switch(ch)
		{
			case 1: src=optarg;
				break;
			case 2: dest=optarg;
				break;
			case 3: name=optarg;
				break;
			default: ;
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
		std::cerr << "Error: user wasn't specified\n";
		throw (-1);
	}

	builder = Gtk::Builder::create();
	try
	{
		builder->add_from_file(sharedir()+"/ui/copyuser.ui");
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
	copyuser_win=transform_to_rptr<Gtk::Window>(builder->get_object("copyuser_win"));
	explaination=transform_to_rptr<Gtk::Window>(builder->get_object("explaination"));
	
	username=transform_to_rptr<Gtk::Label>(builder->get_object("username"));
	username->set_text(name);

	//frame for actions
	pactions=transform_to_rptr<Gtk::Alignment>(builder->get_object("pactions"));
	
	//userexist
	userexist=transform_to_rptr<Gtk::Grid>(builder->get_object("userexist"));
	
	synch=transform_to_rptr<Gtk::Button>(builder->get_object("synch"));
	synch->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::copysynchf));
	empty=transform_to_rptr<Gtk::Button>(builder->get_object("empty"));
	empty->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::emptyf));
	ignoreuser=transform_to_rptr<Gtk::Button>(builder->get_object("ignoreuser"));
	ignoreuser->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::ignoref));
	cleaner=transform_to_rptr<Gtk::Button>(builder->get_object("cleaner"));
	cleaner->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::cleanuser));

	//usernotexist
	usernotexist=transform_to_rptr<Gtk::Grid>(builder->get_object("usernotexist"));
	copy=transform_to_rptr<Gtk::Button>(builder->get_object("copy"));
	copy->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::copysynchf));
	createempty=transform_to_rptr<Gtk::Button>(builder->get_object("createempty"));
	createempty->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::emptyf));
	nocopy=transform_to_rptr<Gtk::Button>(builder->get_object("nocopy"));
	nocopy->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::ignoref));
	cleantargetsys=transform_to_rptr<Gtk::CheckButton>(builder->get_object("cleantargetsys"));
	explain=transform_to_rptr<Gtk::Button>(builder->get_object("explain"));
	explain->signal_clicked ().connect(sigc::mem_fun(*this,&copyuser::explainf));
	
	
	if ( access(((Glib::ustring)"/home/"+name).c_str(),F_OK)==0)
	{
		setactionspace(*((Gtk::Widget *)userexist.operator->()));
		user_exist=true;
	}
	else
	{
		setactionspace(*((Gtk::Widget *)usernotexist.operator->()));
		user_exist=false;
	}
	copyuser_win->show();

	if (copyuser_win!=0)
	{
		kitcopy.run(*copyuser_win.operator->());
	}
}
