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

//using namespace std;
/**
#ifdef test_an
#undef PACKAGE_DATA_DIR
#define PACKAGE_DATA_DIR "src"
#endif
*/



#include <gtkmm.h>
#include <string>
#include <thread>
#include <mutex>



struct srcdest
{
	std::string src;
	std::string dest;
};


#ifndef _GUI_H_
#define _GUI_H_

class gui
{
public:
	gui(int argc, char** argv);
	std::mutex gpartmut;
protected:

private:
	Gtk::Main kit;
	std::thread gpartthread;
	GtkWidget* vteterm;
	Glib::RefPtr<Gtk::Alignment> terminal;
	void update();
	//copyuser copydialog;
	//createuser createdialog;
	//void *execparted();
	Glib::RefPtr<Gtk::Builder> builder;
	Glib::RefPtr<Gtk::Window> main_win;
	Glib::RefPtr<Gtk::Button> gparted,cloneme;
	Glib::RefPtr<Gtk::Entry> src, dest;
	srcdest srcdestobject;
	Glib::RefPtr<Gtk::FileChooserButton> srcb, destb;
	void opengparted();

};

#endif // _GUI_H_
