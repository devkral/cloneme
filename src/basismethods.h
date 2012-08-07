
#include <string>
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

std::string system2(std::string _tcommand);

inline std::string sharedir()
{
	if (access(PACKAGE_DATA_DIR,F_OK)==0)
	{
		std::string tempt=(std::string)PACKAGE_DATA_DIR;
		if (tempt[tempt.length()-1]=='/')
			tempt.erase(tempt.length()-1);
		return tempt;
	}
	else
		return (std::string)"./src/share";
}
inline std::string bindir()
{
	if (access(PACKAGE_BIN_DIR,F_OK)==0)
		return (std::string)PACKAGE_BIN_DIR;
	else
		return (std::string)"./src";
}

inline std::string syncdir()
{
	if (access(PACKAGE_BIN_DIR,F_OK)==0)
		return system2(bindir()+"/clonemecmd.sh syncdir");
	else
		return (std::string)"/run/syndir";
}

#endif // _BASISMETHODS_H_