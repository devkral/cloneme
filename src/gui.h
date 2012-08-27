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

#include <gtkmm.h>
#include <string>
//#include <thread>
//#include <mutex>
#include "myfilechooser.h"

#ifndef _GUI_H_
#define _GUI_H_

class gui
{
public:
	gui(int argc, char** argv);
	~gui();
	//std::mutex gpartmut;
	Glib::Threads::Mutex gparted_mutex;
	
protected:

private:
	//base
	Gtk::Main kitdeprecated;
	Glib::RefPtr<Gtk::Builder> builder;
	Glib::RefPtr<Gtk::Window> main_win;
	
	//Terminal
	GtkWidget* vteterm;
	Glib::RefPtr<Gtk::Alignment> terminal;	

	//gparted
	Glib::Threads::Thread *threadpart;
	//std::thread gpartthread;
	Glib::RefPtr<Gtk::Button> gparted;
	void execparted();
	void opengparted();
	//install update
	Glib::RefPtr<Gtk::Button> installb,updateb;
	void install();
	void update();
	
	//src, dest
	Glib::RefPtr<Gtk::Entry> src, dest;
	Glib::RefPtr<Gtk::Entry> partnumbsrc, partnumbdest;
	Glib::RefPtr<Gtk::Grid> sourcepart, destpart;
	bool updatedsrc(void*), updateddest(void*), updatedsrcpart(void*), updateddestpart(void*);
	//filechooser
	void choosesrc(Gtk::EntryIconPosition pos, const GdkEventButton* event);
	void choosedest(Gtk::EntryIconPosition pos, const GdkEventButton* event);

	//src, dest safeguards,threads,elements
	//Glib::Threads::Thread *threadsrc;
	//Glib::Threads::Mutex srclock;
	myfilechooser filechoosesrc;

	//Glib::Threads::Thread *threaddest;
	//Glib::Threads::Mutex destlock;
	myfilechooser filechoosedest;
	
	//mounted, unmounted source and dest
	bool is_mounteds,is_mountedd;
	
	//safeguards
	bool operationlock;
	bool partready();
	//bool islocked();
	//bool lockoperation(),unlockoperation(),;

	//directs to program file
	Glib::ustring home_path;

	//choose editor
	Glib::RefPtr<Gtk::CheckButton> useeditor;
	Glib::RefPtr<Gtk::Entry> editortouse;
	void useeditorf();	
};

#endif // _GUI_H_
