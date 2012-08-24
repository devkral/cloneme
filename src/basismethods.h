
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
