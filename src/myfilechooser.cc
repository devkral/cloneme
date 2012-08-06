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

#include "myfilechooser.h"
#include "basismethods.h"
//#include <iostream> //not needed basismethods


void myfilechooser::usefile()
{
	myfilechoose->hide();
	path=filechooserwidget1->get_preview_filename();
	kit.quit();
}

void myfilechooser::usefolder()
{
	myfilechoose->hide();
	path=filechooserwidget1->get_current_folder ();
	kit.quit();
}

void myfilechooser::cancelpath()
{
	myfilechoose->hide();
	path="";
	kit.quit();
}

std::string myfilechooser::run()
{
	myfilechoose->show();
	kit.run(*myfilechoose.operator->());
	return path;
}

myfilechooser::myfilechooser()
{
	path="";
	builder = Gtk::Builder::create();
	try
	{
		builder->add_from_file(sharedir()+"/ui/myfiledialog.ui");
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
	myfilechoose=transform_to_rptr<Gtk::Window>(builder->get_object("myfilechoose"));
	filechooserwidget1=transform_to_rptr<Gtk::FileChooserWidget>(builder->get_object("filechooserwidget1"));
	selectfile=transform_to_rptr<Gtk::Button>(builder->get_object("selectfile"));
	selectfile->signal_clicked ().connect(sigc::mem_fun(*this,&myfilechooser::usefile));
	currentfold=transform_to_rptr<Gtk::Button>(builder->get_object("currentfold"));
	currentfold->signal_clicked ().connect(sigc::mem_fun(*this,&myfilechooser::usefolder));
	canceldialog=transform_to_rptr<Gtk::Button>(builder->get_object("canceldialog"));
	canceldialog->signal_clicked ().connect(sigc::mem_fun(*this,&myfilechooser::cancelpath));
};



