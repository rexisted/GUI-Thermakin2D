#include "InOutput.h"

bool InOut::read_files()
{
	std::cout<<"ThermaKin Program Version "<<Consts::VERSION
		     <<"\n\nEnter name of components file:  ";
	std::string c_fname;
	std::cin>>c_fname;
	
	std::ifstream c_file(c_fname.c_str());
	if(!c_file)
	{
		std::cout<<"\nError:  cannot open "<<c_fname<<" file\n";
		std::cin.sync(); std::cin.ignore();
		return false;
	}
	
	size_t chc=0;
	std::string buf;
	mat_inp.clear();
	while((chc<Consts::MAX_CHR)&&(c_file>>buf))
	{
		mat_inp+=buf; mat_inp+=" ";
		chc+=buf.size();
	}
	c_file.close();
	
	std::cout<<"\nEnter name of conditions file:  ";
	std::string d_fname;
	std::cin>>d_fname;
	
	std::ifstream d_file(d_fname.c_str());
	if(!d_file)
	{
		std::cout<<"\nError:  cannot open "<<d_fname<<" file\n";
		std::cin.sync(); std::cin.ignore();
		return false;
	}
	
	chc=0;
	cond_inp.clear();
	while((chc<Consts::MAX_CHR)&&(d_file>>buf))
	{
		cond_inp+=buf; cond_inp+=" ";
		chc+=buf.size();
	}
	d_file.close();
	
	std::cout<<"\nEnter name of output file:  ";
	std::string o_fname;
	std::cin>>o_fname;
	
	std::ifstream o_file(o_fname.c_str());
	if(o_file)
	{
		o_file.close();
		std::cout<<"\nError:  "<<o_fname<<" file already exists\n";
		std::cin.sync(); std::cin.ignore();
		return false;
	}
	
	out.open(o_fname.c_str());
	if(!out)
	{
		std::cout<<"\nError:  cannot open "<<o_fname<<" file\n";
		std::cin.sync(); std::cin.ignore();
		return false;
	}
	
	out.setf(std::ios_base::scientific);
	out.precision(Consts::OUT_PREC);
	
	out<<"ThermaKin Program Version "<<Consts::VERSION
	   <<"\n\nComponents file:  "<<c_fname
	   <<"\nConditions file:  "<<d_fname<<"\n\n";
	
	std::cout<<"\n";
	return true;
}

void InOut::report_err(std::string err_msg)
{
	out<<"Error:  "<<err_msg<<"\n";
	out.close();
	
	std::cout<<"Error:  "<<err_msg<<"\n";
	std::cin.sync(); std::cin.ignore();
}

void InOut::beg_msg()
{
	time(&beg);
	struct tm tm_buf;
	char tm_out[32];
	localtime_s(&tm_buf,&beg);
	asctime_s(tm_out,32,&tm_buf);
	std::cout<<tm_out;
	std::cout<<"The program is running ";
	out<<"Started on:  "<<tm_out<<"\n";
}

void InOut::end_msg()
{
	time_t end; time(&end);
	out<<"Calculations are complete.\nTotal runtime [min]:  "
	   <<difftime(end,beg)/60.0<<"\n";
	out.close();
	
	std::cout<<"\n\nDone";
	std::cin.sync(); std::cin.ignore();
}

InOut IO;