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

class gui;

#ifndef _COPYUSER_H_
#define _COPYUSER_H_

class copyuser
{
public:
	copyuser(int argc, char* argv[]);

protected:

private:
	Gtk::Main kitcopy;
	Glib::RefPtr<Gtk::Builder> builder;
	Glib::RefPtr<Gtk::Window> copyuser_win,explaination;
	Glib::RefPtr<Gtk::Alignment> pactions;
	Glib::RefPtr<Gtk::Grid> userexist,usernotexist;
	
	Glib::RefPtr<Gtk::Button> copy, synch;
	Glib::RefPtr<Gtk::Button> empty, createempty;
	Glib::RefPtr<Gtk::Button> explain;
	Glib::RefPtr<Gtk::Button> nocopy, ignoreuser;
	Glib::RefPtr<Gtk::Button> cleaner;
	Glib::RefPtr<Gtk::Label> username;
	Glib::RefPtr<Gtk::CheckButton> cleantargetsys;

	bool user_exist;

	//little helper
	
	void setactionspace(Gtk::Widget &actionbar);
	
	void cleanuser();
	void copysynchf();
	void cleanf();
	void ignoref();
	void emptyf();
	void createemptyf();
	void explainf();
	
	std::string src, dest;
	std::string name;

};

#endif // _COPYUSER_H_

