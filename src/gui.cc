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

#include "gui.h"
#include "base.h"
//#include "myfilechooser.h"

#include <fstream>
#include <cstdio>
//#include <unistd.h>

#include <cstdlib>
//#include <cassert>
//#include <thread>
#include <vte/vte.h>

#include <memory>

//#include <cerrno>


bool setpidlock(Glib::ustring lockfile)
{ 
	if (access(lockfile.c_str(),F_OK)==0)
	{
		std::ifstream pidread(lockfile.c_str());
		char extract[25];
		pidread.getline(extract,25);
		Glib::ustring tempof="/proc/";
		tempof+=extract;
		std::cerr << "Debug: " << tempof << std::endl;
		if (access(tempof.c_str(),F_OK)==0)
		{
			std::cerr << "cloneme gui runs already. abort\n";
			return false;
		}
	}
	//elsewise set pid and return true
	std::ofstream pidwrite(lockfile.c_str());
	pidwrite << getpid();
	pidwrite.close();
	return true;
}

bool unsetpidlock(Glib::ustring lockfile)
{

	if (access(lockfile.c_str(),F_OK)==0)
	{
		std::ifstream pidread(lockfile.c_str());
		char extract[25];
		pidread.getline(extract,25);

		if ((int)getpid()==atoi(extract))
		{
			if(remove(lockfile.c_str()) != 0 )
				std::cerr << "error: error while removing file\n";
			else
				return true;
		}
		else
		{
			std::cerr << "Error: an other cloneme service is running. Don't unmount!\n";
		}
	}
	else
		std::cerr << "debug: pidfile doesn't exist\n";
	return false;
}
/**
bool islocked(Glib::ustring lockfile)
{
	if (access(lockfile.c_str(),F_OK)==0)
		return true;
	else
		return false;
	
}*/

void gui::useeditorf()
{
	if (useeditor->get_active ())
	{
		editortouse->show();
	}
	else
	{
		editortouse->hide();
	}

}



/**
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
		return true;
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
		return true;
	}
	else
	{
		return false;
	}
}*/

void gui::execparted()
{
	if (system("gpartedbin")!=0)
		std::cerr << "An error happened\n";
	gparted_mutex.unlock();
}

void gui::opengparted()
{
	
	if (gparted_mutex.trylock())
	{
		//threadpart=std::thread(execparted,this);
		//threadpart->join( );
		threadpart=Glib::Threads::Thread::create(sigc::mem_fun(*this,&gui::execparted));
	}
}

void gui::update()
{
	if (partready()==true)
	{
		if (setpidlock(syncdir()+"/guilock.pid")==true)
		{
			Glib::ustring sum="";
			sum+=sharedir()+"/sh/rsyncci.sh ";
			sum+="--mode update ";
			sum+="--src \""+syncdir()+"\"/src ";
			sum+="--dest \""+syncdir()+"\"/dest ";
			sum+="--copyuser \""+bindir()+"/cloneme --copyuser\" ";
//doesn't work
//			if (useeditor->get_active ())
//				sum+="--editfstab \""+editortouse->get_text()+"\" ";
			sum+="\n";
			sum+="rm \""+syncdir()+"\"/guilock.pid\n";
			vte_terminal_feed_child (VTE_TERMINAL(vteterm),sum.c_str(),sum.length());
		}
	}
}

void gui::install()
{
	if (partready()==true)
	{
		if (setpidlock(syncdir()+"/guilock.pid")==true)
		{
			Glib::ustring sum="";
			sum+=sharedir()+"/sh/rsyncci.sh ";
			sum+="--mode install ";
			sum+="--src \""+syncdir()+"\"/src ";
			sum+="--dest \""+syncdir()+"\"/dest ";
			sum+="--adduser \""+bindir()+"/cloneme --createuser\" ";
			sum+="--copyuser \""+bindir()+"/cloneme --copyuser\" ";
			if (useeditor->get_active ())
				sum+="--editfstab \""+editortouse->get_text()+"\" ";
			sum+="--installinstaller \""+sharedir()+"/sh/install-installer.sh "+bindir()+" $(dirname "+sharedir()+")/applications/ "+syncdir()+"/dest\" ";
			sum+="--bootloader \""+sharedir()+"/sh/grub-installer_phase_1.sh "+syncdir()+"/dest\"\n";
			sum+="rm \""+syncdir()+"\"/guilock.pid\n";
			vte_terminal_feed_child (VTE_TERMINAL(vteterm),sum.c_str(),sum.length());
		}
	}
}

void gui::choosesrc(Gtk::EntryIconPosition pos, const GdkEventButton* event)
{
	filechoosesrc.run(src);
	updatedsrc(0);
}


void gui::choosedest(Gtk::EntryIconPosition pos, const GdkEventButton* event)
{
	filechoosedest.run(dest);
	updateddest(0);		
}

//is src and dest mounted
bool gui::partready()
{
	if (is_mounteds==true && is_mountedd==true)
		return true;
	else
	{
		//std::cerr << "src and/or dest not mounted\n";
		return false;
	}
}

bool gui::updatedsrc(void*)
{
	if (operationlock==false && src->get_text()!="")
	{
		if (system2(sharedir()+"/sh/mountscript.sh needpart \""+src->get_text()+"\"")=="false")
		{
			sourcepart->hide();
			Glib::ustring sum=sharedir()+"/sh/mountscript.sh mount \""+src->get_text()+"\" \""+syncdir()+"\"/src";
			if ( system(sum.c_str())==0)
				is_mounteds=true;
		} else
		{
			sourcepart->show();
			partnumbsrc->set_text("");
			is_mounteds=false;
		}
	}
	else
	{
		sourcepart->hide();
		is_mounteds=false;
	}
	
	return false;
}

bool gui::updatedsrcpart(void*)
{
	if (operationlock==false && partnumbsrc->get_text()!="")
	{
		Glib::ustring sum=sharedir()+"/sh/mountscript.sh mount \""+src->get_text()+"\" p"+partnumbsrc->get_text()+" \""+syncdir()+"\"/src";
		if ( system(sum.c_str())==0)
			is_mounteds=true;
	}
	return false;
}

bool gui::updateddest(void*)
{
	if (operationlock==false && dest->get_text()!="")
	{
		if (system2(sharedir()+"/sh/mountscript.sh needpart \""+dest->get_text()+"\"")=="false")
		{
			destpart->hide();
			Glib::ustring sum=sharedir()+"/sh/mountscript.sh mount \""+dest->get_text()+"\" \""+syncdir()+"\"/dest";
			if ( system(sum.c_str())==0)
				is_mountedd=true;
		}else
		{
			destpart->show();
			partnumbdest->set_text("");
			is_mountedd=false;
		}
	}
	else
	{
		destpart->hide();
		is_mountedd=false;
	}
	return false;
}



bool gui::updateddestpart(void*)
{
	if (operationlock==false && partnumbdest->get_text()!="")
	{
		Glib::ustring sum=sharedir()+"/sh/mountscript.sh mount \""+dest->get_text()+"\" p"+partnumbdest->get_text()+" \""+syncdir()+"\"/dest";
		if ( system(sum.c_str())==0)
			is_mountedd=true;
	}
	return false;
}

gui::gui(int argc, char** argv): kitdeprecated(argc,argv),filechoosesrc(),filechoosedest()//
{
	//initialize syncdir
	if (system((sharedir()+"/sh/prepsyncscript.sh \""+syncdir()+"\"\n").c_str())!=0)
		throw (-1);
	if (setpidlock(syncdir()+"/cloneme.pid")==false)
		throw (-1);
	is_mountedd=false;
	is_mounteds=false;
	threadpart=0;
	//kit=Gtk::Application::create(argc, argv,"org.gtkmm.cloneme.main");
	
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
			                           0, //Environment // use environ instead?
			                           (GSpawnFlags)(G_SPAWN_DO_NOT_REAP_CHILD | G_SPAWN_SEARCH_PATH),  //Spawnflags
			                           0,
			                           0,
			                           0,
		                               0);
	if (!test)
	{
		std::cerr << "Terminal child didn't start.\n";
	}
	vte_terminal_set_scrollback_lines(VTE_TERMINAL(vteterm), -1);
	
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
	//src:
	src=transform_to_rptr<Gtk::Entry>(builder->get_object("src"));
	//src->set_text("/");
	partnumbsrc=transform_to_rptr<Gtk::Entry>(builder->get_object("partnumbsrc"));
	sourcepart=transform_to_rptr<Gtk::Grid>(builder->get_object("sourcepart"));
	//use icon release for opening filechooser dialog
	src->signal_icon_release().connect(sigc::mem_fun(*this,&gui::choosesrc));
	//use unfocus for mount
	src->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updatedsrc));
	partnumbsrc->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updatedsrcpart));
	
	//dest:
	dest=transform_to_rptr<Gtk::Entry>(builder->get_object("dest"));
	//dest->set_text("/dev/sdb1");
	destpart=transform_to_rptr<Gtk::Grid>(builder->get_object("destpart"));
	partnumbdest=transform_to_rptr<Gtk::Entry>(builder->get_object("partnumbdest"));
	//use icon release for opening filechooser dialog
	dest->signal_icon_release().connect(sigc::mem_fun(*this,&gui::choosedest));
	//use unfocus for mount
	dest->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updateddest));
	partnumbdest->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updateddestpart));
	
	//editor
	useeditor=transform_to_rptr<Gtk::CheckButton>(builder->get_object("useeditor"));
	useeditor->signal_toggled ().connect(sigc::mem_fun(*this,&gui::useeditorf));
	editortouse=transform_to_rptr<Gtk::Entry>(builder->get_object("editortouse"));

	//updatedsrc(0);
	//updateddest(0);
	
	main_win->show_all_children();
	if (main_win!=0)
	{
		kitdeprecated.run(*main_win.operator->());
		//kit->run(*main_win.operator->(), argc, argv);
	}
}

gui::~gui()
{
	//cleanup
	unsetpidlock(syncdir()+"/guilock.pid");
	if (unsetpidlock(syncdir()+"/cloneme.pid"))
		system((sharedir()+"/sh/umountsyncscript.sh \""+syncdir()+"\"\n").c_str());
	if (threadpart!=0)
		threadpart->join();
}
