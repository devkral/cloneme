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

#include <gtkmm.h>
#include <string>

#ifndef _MYFILECHOOSER_H_
#define _MYFILECHOOSER_H_

class myfilechooser
{
public:
	myfilechooser ();
	//myfilechooser (Glib::RefPtr<Gtk::Entry> &temp);
	//~myfilechooser ();
	//shows window
	void run(Glib::RefPtr<Gtk::Entry> &temp);
	//usage:
protected:

private:
	//build window
	Glib::RefPtr<Gtk::Builder> builder2;
	bool waitfinish;
	//Window
	Glib::RefPtr<Gtk::Window> fcdialog;
	//intern predefined widget for filechoosing
	Glib::RefPtr<Gtk::FileChooserWidget> fcwidget;
	//added special buttons
	Glib::RefPtr<Gtk::Button>selectedfile,currentfolder,cancelchoose;
	
	Glib::RefPtr<Gio::File> path;
	//ease the life
	//Glib::ustring lastdir;

	//adopted entry
	Glib::RefPtr<Gtk::Entry> adopedentry;
	//
	void selectedfilef();
	void currentfolderf();
	void cancelchoosef();
	
	
	
};

#endif // _MYFILECHOOSER_H_

