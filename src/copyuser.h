/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * cloneme
 * Copyright (C) 2012 alex <devkral@web.de>
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
	//Glib::RefPtr<Gtk::Builder> builder;
	//Glib::RefPtr<Gtk::Window> copyuser_win;
	std::string src;
	std::string dest;
	std::string name;

};

#endif // _COPYUSER_H_

