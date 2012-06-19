/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * cloneme
 * Copyright (C) alex 2012 <devkral@web.de>
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

#include "gui.h"

#include <iostream>
#include <cstdlib>
#include <cassert>
#include <thread>
#include <unistd.h>
#include <vte/vte.h>

#include <cstdio>
//#include <cerrno>

std::string system2(std::string _tcommand)
{
   FILE * proc;
   std::string temp;

   proc = popen (_tcommand.c_str() , "r");
   if (proc == NULL)
		{
			perror ("Error opening command");
			return NULL;
		}
   else 
		{
			while (!feof(proc))
				{
					temp+=fgetc (proc);
				}
			fclose (proc);
			temp.erase(temp.length()-2, temp.length()-1);
			return temp;
		}
}


template< class T_CppObject > Glib::RefPtr<T_CppObject>
transform_to_rptr(const Glib::RefPtr< Glib::Object >& p)
{
	if (p==0)
		std::cerr << "Error object empty";
	return Glib::RefPtr<T_CppObject>::cast_dynamic(p);
}


void execparted(gui *refback)
{
	std::system("gparted");
	refback->gpartmut.unlock();
}

void gui::opengparted()
{
	if (gpartmut.try_lock())
	{
		gpartthread=std::thread(execparted,this);
	}
}

srcdest execmounting(std::string src, std::string dest)
{
	srcdest temp;
	temp.src=system2(PACKAGE_DATA_DIR"/sh/mounting.sh "+src);
	temp.dest=system2(PACKAGE_DATA_DIR"/sh/mounting.sh "+dest);
	return temp;
}

void execunmounting(srcdest umountobject)
{
	system2(PACKAGE_DATA_DIR"/sh/unmounting.sh "+umountobject.src+" "+umountobject.dest);
}

void execupdate(srcdest temp)
{
	execmounting(temp.src,temp.dest);
	std::string sum=PACKAGE_DATA_DIR;
	sum+="/sh/update.sh "+temp.src+" "+temp.dest;
	system(sum.c_str());
}

void gui::update()
{
	srcdest updatepaths=execmounting(src->get_text(),dest->get_text());
	execupdate(updatepaths);
	//copydialog.run();
	execunmounting(updatepaths);
}



gui::gui(int argc, char** argv): kit(argc, argv),gpartthread()//,copydialog(this),createdialog(this)
{
	//syncdir="";
	builder = Gtk::Builder::create();
	try
	{
		builder->add_from_file(PACKAGE_DATA_DIR"/ui/cloneme.ui");
	}
	catch(const Glib::FileError& ex)
	{
		//std::cerr << ENOENT;
		//if (ex.code()==ENOENT)
		//	std::cerr << "good";
		//strange ENOENT doesn't work even it should correspond
		if (ex.code()==4)
		{
			std::cerr << "cloneme.ui not found; fall back to src directory\n";
			try
			{
				builder->add_from_file("src/ui/cloneme.ui");
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
	main_win=transform_to_rptr<Gtk::Window>(builder->get_object("main_win"));

	//Terminal
	terminal=transform_to_rptr<Gtk::Alignment>(builder->get_object("termspace"));
	vteterm=vte_terminal_new();
	terminal->add(*Glib::wrap(vteterm));
	char* startterm[2]={(char*)"/bin/sh",0};
	
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
	
	//Buttons
	gparted=transform_to_rptr<Gtk::Button>(builder->get_object("gparted"));
	gparted->signal_clicked ().connect(sigc::mem_fun(*this,&gui::opengparted));
	
	//Filechooser
	src=transform_to_rptr<Gtk::Entry>(builder->get_object("src"));
	src->set_text("/");
	dest=transform_to_rptr<Gtk::Entry>(builder->get_object("dest"));
	dest->set_text("/syncdir");
	
	main_win->show_all_children();
	if (main_win!=0)
	{
		kit.run(*main_win.operator->());
	}
}