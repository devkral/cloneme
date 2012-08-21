#include "basismethods.h"
#include <cstdio>

std::string system2(std::string _tcommand)
{
   FILE * proc;
   std::string temp="";

   proc = popen (_tcommand.c_str() , "r");
   if (proc == NULL)
		{
			std::cerr << "Error opening command";
			return NULL;
		}
   else 
		{
			while (!feof(proc))
				{
					temp+=fgetc (proc);
				}
			fclose (proc);
			//some errors in the logic I fix via safeguards
			int begin=temp.length()-2;
			if (begin<0)
				begin=0;
			int end=temp.length()-1;
			if (end<=0)
				end=1;
			temp.erase(begin, end);
			return temp;
		}
}



