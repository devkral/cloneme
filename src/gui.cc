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

#include "basismethods.h"
#include "gui.h"
#include "myfilechooser.h"

//#include <iostream>
//#include <unistd.h>

#include <cstdlib>
#include <cassert>
#include <thread>
#include <vte/vte.h>

//#include <cerrno>





void execparted(gui *refback)
{
	std::system("gparted");
	refback->gpartmut.unlock();
}

void gui::chooseeditor()
{
	if (graphicaleditor->get_active ())
	{
		std::string sum="EDITOR=gedit\n";
		vte_terminal_feed_child (VTE_TERMINAL(vteterm),sum.c_str(),sum.length());
	}
	else
	{
//TODO:
//buggy;can't fetch the editor from the main system
//most probably because of missing environment variables
		std::string sum="EDITOR="+system2("echo \"$EDITOR\"")+"\n";
		std::cout << sum;
//so use my favourite
		sum="EDITOR=nano\n";
		vte_terminal_feed_child (VTE_TERMINAL(vteterm),sum.c_str(),sum.length());
	}

}
//is src and dest mounted
bool gui::partready()
{
	Glib::RefPtr<Gio::File> tempsrc = Gio::File::create_for_path (src->get_text());
	if (tempsrc->query_file_type()  == Gio::FILE_TYPE_SYMBOLIC_LINK | tempsrc->query_file_type() ==   Gio::FILE_TYPE_REGULAR)
	{
		if (partnumbsrc->get_text()=="")
			return false;

	}
	Glib::RefPtr<Gio::File> tempdest = Gio::File::create_for_path (dest->get_text());
	if (tempdest->query_file_type()  == Gio::FILE_TYPE_SYMBOLIC_LINK | tempdest->query_file_type() ==   Gio::FILE_TYPE_REGULAR)
	{
		if (partnumbdest->get_text()=="")
			return false;
	}
	return true;
}


bool gui::lockoperation()
{
	if (operationlock==false)
	{
		operationlock=true;
		installb->set_sensitive(false);
		updateb->set_sensitive(false);
		
		src->set_sensitive(false);
		dest->set_sensitive(false);
		partnumbsrc->set_sensitive(false);
		partnumbdest->set_sensitive(false);
		srcselect->set_sensitive(false);
		destselect->set_sensitive(false);
	}
	else
	{
		return false;
	}
}

bool gui::unlockoperation()
{
	if (operationlock==true)
	{
		operationlock=false;

		installb->set_sensitive(true);
		updateb->set_sensitive(true);
		src->set_sensitive(true);
		dest->set_sensitive(true);
		partnumbsrc->set_sensitive(true);
		partnumbdest->set_sensitive(true);
		srcselect->set_sensitive(true);
		destselect->set_sensitive(true);
		return true;
	}
	else
	{
		return false;
	}
}


void gui::opengparted()
{
	if (gpartmut.try_lock())
	{
		gpartthread=std::thread(execparted,this);
	}
}

void gui::update()
{
	//handled by gui::gui
	//updatedsrc();
	//updateddest();
	if (lockoperation()==true && partready()==true);
	{
		std::string sum="";
		sum+=bindir()+"/clonemecmd.sh update "+syncdir()+"/src "+syncdir()+"/dest "+home_path+" "+"installer_grub2"+"\n";
		vte_terminal_feed_child (VTE_TERMINAL(vteterm),sum.c_str(),sum.length());
		unlockoperation();
	}
}

void gui::install()
{
	//handled by gui::gui
	//updatedsrc();
	//updateddest();
	if (lockoperation()==true && partready()==true);
	{
		std::string sum="";
		sum+=bindir()+"/clonemecmd.sh install "+syncdir()+"/src "+syncdir()+"/dest "+home_path+" "+"installer_grub2"+"\n";
		vte_terminal_feed_child (VTE_TERMINAL(vteterm),sum.c_str(),sum.length());
		unlockoperation();
	}
}

void gui::choosesrc()
{
	
	myfilechooser select;
	std::string temp=select.run();
	if (!temp.empty())
	{
		src->set_text(temp);
		updatedsrc(0);
	}
}

void gui::choosedest()
{
	myfilechooser select;
	std::string temp=select.run();
	if (!temp.empty())
	{
		dest->set_text(temp);
		//update 
		updateddest(0);
	}
}

bool gui::updatedsrc(void*)
{
	if (operationlock==false)
	{
		Glib::RefPtr<Gio::File> tempsrc = Gio::File::create_for_path (src->get_text());
		if (tempsrc->query_file_type() ==   Gio::FILE_TYPE_DIRECTORY)
		{
			sourcepart->hide();
			std::string sum=sharedir()+"/sh/mountscript.sh mount "+src->get_text()+" "+syncdir()+"/src";
			std::cerr << system2(sum);
		} else if (tempsrc->query_file_type()  == Gio::FILE_TYPE_SYMBOLIC_LINK | tempsrc->query_file_type() ==   Gio::FILE_TYPE_REGULAR)
		{
			sourcepart->show();
			partnumbsrc->set_text("");
		
		}
	}
	return false;
}

bool gui::updatedsrcpart(void*)
{
	if (operationlock==false)
	{
		std::string sum=sharedir()+"/sh/mountscript.sh mount "+src->get_text()+" "+partnumbsrc->get_text()+" "+syncdir()+"/src";
		std::cerr << system2(sum);
	}
	return false;
}

bool gui::updateddest(void*)
{
	if (operationlock==false)
	{
		Glib::RefPtr<Gio::File> tempdest = Gio::File::create_for_path (dest->get_text());
		if (tempdest->query_file_type() == Gio::FILE_TYPE_DIRECTORY)
		{
			destpart->hide();
			std::string sum=sharedir()+"/sh/mountscript.sh mount "+dest->get_text()+" "+syncdir()+"/dest";
			std::cerr << system2(sum);
		} else if (tempdest->query_file_type()  == Gio::FILE_TYPE_SYMBOLIC_LINK | tempdest->query_file_type() ==   Gio::FILE_TYPE_REGULAR)
		{
			destpart->show();
			partnumbdest->set_text("");
		}
	}
	return false;
}



bool gui::updateddestpart(void*)
{
	if (operationlock==false)
	{
		std::string sum=sharedir()+"/sh/mountscript.sh mount "+dest->get_text()+" "+partnumbdest->get_text()+" "+syncdir()+"/dest";
		std::cerr << system2(sum);
	}
	return false;
}

gui::gui(int argc, char** argv): kit(argc, argv),gpartthread()//,copydialog(this),createdialog(this)
{

	//syncdir="";
	//lock for preserving src and dest positions
	operationlock=false;
	home_path=argv[0];
	builder = Gtk::Builder::create();
	try
	{
		builder->add_from_file(sharedir()+"/ui/cloneme.ui");
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
	main_win=transform_to_rptr<Gtk::Window>(builder->get_object("main_win"));
	
	
	//Terminal
	terminal=transform_to_rptr<Gtk::Alignment>(builder->get_object("termspace"));
	vteterm=vte_terminal_new();
	terminal->add(*Glib::wrap(vteterm));
	char* startterm[2]={vte_get_user_shell (),0};
	
	bool test=vte_terminal_fork_command_full(VTE_TERMINAL(vteterm),
			                           VTE_PTY_DEFAULT,
			                           0,
			                           startterm,
			                           0, //Environment
			                           (GSpawnFlags)(G_SPAWN_DO_NOT_REAP_CHILD | G_SPAWN_SEARCH_PATH),  //Spawnflags
			                           0,
			                           0,
			                           0,
		                               0);
	if (!test)
	{
		std::cerr << "Terminal child didn't start.\n";
	}

	//initialize syncdir
	std::cerr << system2(sharedir()+"/sh/prepsyncscript.sh "+syncdir()+"\n");
	
	//Buttons
	gparted=transform_to_rptr<Gtk::Button>(builder->get_object("gparted"));
	gparted->signal_clicked ().connect(sigc::mem_fun(*this,&gui::opengparted));
	if ( access("/usr/sbin/gparted",F_OK)!=0)
	{
		std::cerr << "gparted not found";
		gparted->hide();
	}
	installb=transform_to_rptr<Gtk::Button>(builder->get_object("installb"));
	installb->signal_clicked ().connect(sigc::mem_fun(*this,&gui::install));
	updateb=transform_to_rptr<Gtk::Button>(builder->get_object("updateb"));
	updateb->signal_clicked ().connect(sigc::mem_fun(*this,&gui::update));
	
	//Filechooser
	src=transform_to_rptr<Gtk::Entry>(builder->get_object("src"));
	src->set_text("/");
	sourcepart=transform_to_rptr<Gtk::Grid>(builder->get_object("sourcepart"));
	partnumbsrc=transform_to_rptr<Gtk::Entry>(builder->get_object("partnumbsrc"));

	//use unfocus
	src->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updatedsrc));
	partnumbsrc->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updatedsrcpart));
	srcselect=transform_to_rptr<Gtk::Button>(builder->get_object("srcselect"));
	srcselect->signal_clicked ().connect(sigc::mem_fun(*this,&gui::choosesrc));
	
	dest=transform_to_rptr<Gtk::Entry>(builder->get_object("dest"));
	dest->set_text("/dev/sdb1");
	destpart=transform_to_rptr<Gtk::Grid>(builder->get_object("destpart"));
	partnumbdest=transform_to_rptr<Gtk::Entry>(builder->get_object("partnumbdest"));

	//use unfocus
	dest->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updateddest));
	partnumbdest->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updateddestpart));
	destselect=transform_to_rptr<Gtk::Button>(builder->get_object("destselect"));
	destselect->signal_clicked ().connect(sigc::mem_fun(*this,&gui::choosedest));

	graphicaleditor=transform_to_rptr<Gtk::CheckButton>(builder->get_object("graphicaleditor"));
	graphicaleditor->signal_toggled ().connect(sigc::mem_fun(*this,&gui::chooseeditor));

	updatedsrc(0);
	updateddest(0);
	
	main_win->show_all_children();
	if (main_win!=0)
	{
		kit.run(*main_win.operator->());
	}
}

gui::~gui()
{
	//cleanup
	std::cerr << system2(sharedir()+"/sh/umountsyncscript.sh "+syncdir()+"\n");
}
