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
#include <iostream>
#include <unistd.h>


#ifndef _BASISMETHODS_H_
#define _BASISMETHODS_H_

template< class T_CppObject > Glib::RefPtr<T_CppObject>
transform_to_rptr(const Glib::RefPtr< Glib::Object >& p)
{
	if (p==0)
		std::cerr << "Error: object empty";
	return Glib::RefPtr<T_CppObject>::cast_dynamic(p);
}

Glib::ustring system2(Glib::ustring _tcommand);

inline Glib::ustring sharedir()
{
	if (access(PACKAGE_DATA_DIR,F_OK)==0)
	{
		std::string tempt=(std::string)PACKAGE_DATA_DIR;
		if (tempt[tempt.length()-1]=='/')
			tempt.erase(tempt.length()-1);
		return tempt;
	}
	else
		return (Glib::ustring)"./src/share";
}
inline Glib::ustring bindir()
{
	if (access(PACKAGE_BIN_DIR,F_OK)==0)
		return (Glib::ustring)PACKAGE_BIN_DIR;
	else
		return (Glib::ustring)"./src";
}

inline Glib::ustring syncdir()
{
	return "/run/syncdir";
	//return system2(bindir()+"/clonemecmd.sh syncdir\n");
}
/**
inline Glib::ustring mypidfile()
{
	return syncdir()+"/cloneme.pid";
}*/



#endif // _BASISMETHODS_H_
