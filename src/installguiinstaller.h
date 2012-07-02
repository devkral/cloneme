/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * cloneme
 * Copyright (C) 2012 alex <alex@archal>
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
#include <string>

#ifndef _INSTALLGUIINSTALLER_H_
#define _INSTALLGUIINSTALLER_H_

class installguiinstaller
{
public:
	installguiinstaller(int argc, char* argv[] );
protected:

private:
	std::string dest;
	std::string srcdata, destdata;
	std::string self, destbin;
	std::string srclinkdir,destlinkdir;
};

#endif // _INSTALLGUIINSTALLER_H_

