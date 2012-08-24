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


bool setpidlock()
{ 
	if (access((syncdir()+"/cloneme.pid").c_str(),F_OK)==0)
	{
		std::ifstream pidread((syncdir()+"/cloneme.pid").c_str());
		char extract[25];
		pidread.getline(extract,25);
		std::string tempof="/proc/";
		tempof+=extract;
		std::cerr << "Debug: " << tempof << std::endl;
		if (access(tempof.c_str(),F_OK)==0)
		{
			std::cerr << "cloneme gui runs already. abort\n";
			return false;
		}
	}
	//elsewise set pid and return true
	std::ofstream pidwrite((syncdir()+"/cloneme.pid").c_str());
	pidwrite << getpid();
	pidwrite.close();
	return true;
}

bool unsetpidlock()
{

	if (access((syncdir()+"/cloneme.pid").c_str(),F_OK)==0)
	{
		std::ifstream pidread((syncdir()+"/cloneme.pid").c_str());
		char extract[25];
		pidread.getline(extract,25);

		if ((int)getpid()==atoi(extract))
		{
			if(remove((syncdir()+"/cloneme.pid").c_str()) != 0 )
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


//void execparted(gui *refback)
void gui::execparted()
{
	std::cerr << system2("gpartedbin");
	//refback->gpartmut.unlock();
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
	if (lockoperation()==true && partready()==true);
	{
		std::string sum="";
		sum+=sharedir()+"/sh/rsyncci.sh ";
		sum+="--mode update ";
		sum+="--src "+syncdir()+"/src ";
		sum+="--dest "+syncdir()+"/dest\n";
		vte_terminal_feed_child (VTE_TERMINAL(vteterm),sum.c_str(),sum.length());
		unlockoperation();
	}
}

void gui::install()
{
	if (lockoperation()==true && partready()==true);
	{
		std::string sum="";
		sum+=sharedir()+"/sh/rsyncci.sh ";
		sum+="--mode install ";
		sum+="--src "+syncdir()+"/src ";
		sum+="--dest "+syncdir()+"/dest ";
		sum+="--copyuser \""+bindir()+"/cloneme --copyuser\"\n";
		sum+="--installinstaller \""+sharedir()+"/sh/install-installer.sh "+bindir()+" $(dirname "+sharedir()+")/applications/ "+syncdir()+"/dest\" ";
		sum+="--bootloader \""+sharedir()+"/sh/grub-installer_phase_1.sh "+bindir()+"/cloneme --createuser\"\n";
		vte_terminal_feed_child (VTE_TERMINAL(vteterm),sum.c_str(),sum.length());
		unlockoperation();
	}
}

void gui::choosesrc()
{
	filechoosesrc.run(src);
	updatedsrc(0);
		
}


void gui::choosedest()
{
	filechoosedest.run(dest);
	updateddest(0);		
}

//is src and dest mounted
bool gui::partready()
{
	if (is_mounteds==false || is_mountedd==false)
		return false;
	return true;
}

bool gui::updatedsrc(void*)
{
	if (operationlock==false && src->get_text()!="")
	{
		if (system2(sharedir()+"/sh/mountscript.sh needpart "+src->get_text())=="false")
		{
			sourcepart->hide();
			std::string sum=sharedir()+"/sh/mountscript.sh mount "+src->get_text()+" "+syncdir()+"/src";
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
		std::string sum=sharedir()+"/sh/mountscript.sh mount "+src->get_text()+" p"+partnumbsrc->get_text()+" "+syncdir()+"/src";
		if ( system(sum.c_str())==0)
			is_mounteds=true;
	}
	return false;
}

bool gui::updateddest(void*)
{
	if (operationlock==false && dest->get_text()!="")
	{
		if (system2(sharedir()+"/sh/mountscript.sh needpart "+dest->get_text())=="false")
		{
			destpart->hide();
			std::string sum=sharedir()+"/sh/mountscript.sh mount "+dest->get_text()+" "+syncdir()+"/dest";
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
		std::string sum=sharedir()+"/sh/mountscript.sh mount "+dest->get_text()+" p"+partnumbdest->get_text()+" "+syncdir()+"/dest";
		if ( system(sum.c_str())==0)
			is_mountedd=true;
	}
	return false;
}

gui::gui(int argc, char** argv): kitdeprecated(argc,argv),filechoosesrc(),filechoosedest()//
{
	//initialize syncdir
	std::cerr << system2(sharedir()+"/sh/prepsyncscript.sh "+syncdir()+"\n");
	if (setpidlock()==false)
		exit(1);
	is_mountedd=false;
	is_mounteds=false;
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
	//src->set_text("/");
	sourcepart=transform_to_rptr<Gtk::Grid>(builder->get_object("sourcepart"));
	partnumbsrc=transform_to_rptr<Gtk::Entry>(builder->get_object("partnumbsrc"));
	srcselect=transform_to_rptr<Gtk::Button>(builder->get_object("srcselect"));
	srcselect->signal_clicked ().connect(sigc::mem_fun(*this,&gui::choosesrc));
	//use unfocus
	src->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updatedsrc));
	partnumbsrc->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updatedsrcpart));

	
	dest=transform_to_rptr<Gtk::Entry>(builder->get_object("dest"));
	//dest->set_text("/dev/sdb1");
	destselect=transform_to_rptr<Gtk::Button>(builder->get_object("destselect"));
	destselect->signal_clicked ().connect(sigc::mem_fun(*this,&gui::choosedest));
	destpart=transform_to_rptr<Gtk::Grid>(builder->get_object("destpart"));
	partnumbdest=transform_to_rptr<Gtk::Entry>(builder->get_object("partnumbdest"));
	//use unfocus
	dest->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updateddest));
	partnumbdest->signal_focus_out_event( ).connect(sigc::mem_fun(*this,&gui::updateddestpart));
	


	graphicaleditor=transform_to_rptr<Gtk::CheckButton>(builder->get_object("graphicaleditor"));
	graphicaleditor->signal_toggled ().connect(sigc::mem_fun(*this,&gui::chooseeditor));

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
	if (unsetpidlock())
		std::cerr << system2(sharedir()+"/sh/umountsyncscript.sh "+syncdir()+"\n");
	if (threadpart!=0)
		threadpart->join();
}
