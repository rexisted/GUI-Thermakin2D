#include <string>
#include <fstream>
#include <ctime>
#include <iostream>
#include "Constants.h"

struct InOut
	/* This structure handles communications with a user and input from and output to 
	   files. A single object of this structure, IO (declared in InOutput.cpp), is used in 
	   the ThermaKin program. */
{
	InOut() { }
	
	bool read_files();
	void report_err(std::string err_msg);
	
	void beg_msg();
	void end_msg();
	
	std::string mat_inp;
	std::string cond_inp;
	
	std::ofstream out;

private:
	
	time_t beg;
};