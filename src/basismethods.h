
#include <string>
#include <gtkmm.h>
#include <iostream>


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

#endif // _BASISMETHODS_H_