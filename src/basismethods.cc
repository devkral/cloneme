#include "basismethods.h"
#include <cstdio>

std::string system2(std::string _tcommand)
{
   FILE * proc;
   std::string temp;

   proc = popen (_tcommand.c_str() , "r");
   if (proc == NULL)
		{
			perror ("Error opening command");
			return NULL;
		}
   else 
		{
			while (!feof(proc))
				{
					temp+=fgetc (proc);
				}
			fclose (proc);
			temp.erase(temp.length()-2, temp.length()-1);
			return temp;
		}
}
