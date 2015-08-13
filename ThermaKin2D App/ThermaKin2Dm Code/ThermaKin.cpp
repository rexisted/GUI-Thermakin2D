#include "InOutput.h"
#include "1D_Model.h"
#include "2D_Model.h"

int main()
{
	extern InOut IO;
	if(IO.read_files())
	{
		extern Comps mat;
		try
		{
			std::istringstream m_inp(IO.mat_inp);
			mat.load(m_inp);
		}
		catch(Comps::loadErr err)
		{
			IO.out<<"Number of components:  "<<mat.Ncomps()
				  <<"\nNumber of reactions:  "<<mat.Nrxns()
				  <<"\nMixture rules assigned:  "<<(mat.mixts_loaded()? "yes" : "no")
				  <<"\n\n";
			
			IO.report_err(err.message);
			return 0;
		}
		
		IO.mat_inp.clear();
		IO.out<<"Number of components:  "<<mat.Ncomps()
			  <<"\nNumber of reactions:  "<<mat.Nrxns()
			  <<"\nMixture rules assigned:  "<<(mat.mixts_loaded()? "yes" : "no")
			  <<"\n\n";
		
		Elem::set(mat.Ncomps());
		
		std::string model;
		{
			std::istringstream c_inp(IO.cond_inp);
			while(c_inp>>model)
			{
				if((model=="OBJECT")&&(c_inp>>model)&&(model=="TYPE:"))
				{ c_inp>>model; break; }
				else
				{ model.clear(); }
			}
		}
		
		if(model=="1D")
		{
			OneD_model OneD;
			
			try
			{
				std::istringstream c_inp(IO.cond_inp);
				OneD.load(c_inp);
			}
			catch(OneD_model::loadErr err)
			{
				IO.out<<"Object type:  1D"
					  <<"\n\nTop Boundary"
					  <<"\nExternal radiation:  "<<(OneD.topBound_radiation()? "on" : "off")
					  <<"\nMass transport:  "<<(OneD.topBound_massflow()? "on" : "off")
					  <<"\nIgnition:  "<<(OneD.topBound_ignition()? "on" : "off")
					  <<"\n\nBottom Boundary"
					  <<"\nExternal radiation:  "<<(OneD.botBound_radiation()? "on" : "off")
					  <<"\nMass transport:  "<<(OneD.botBound_massflow()? "on" : "off")
					  <<"\nIgnition:  "<<(OneD.botBound_ignition()? "on" : "off")<<"\n\n";
				
				OneD.zero();
				IO.report_err(err.message);
				return 0;
			}
			
			IO.cond_inp.clear();
			IO.out<<"Object type:  1D"
				  <<"\n\nTop Boundary"
				  <<"\nExternal radiation:  "<<(OneD.topBound_radiation()? "on" : "off")
				  <<"\nMass transport:  "<<(OneD.topBound_massflow()? "on" : "off")
				  <<"\nIgnition:  "<<(OneD.topBound_ignition()? "on" : "off")
				  <<"\n\nBottom Boundary"
				  <<"\nExternal radiation:  "<<(OneD.botBound_radiation()? "on" : "off")
				  <<"\nMass transport:  "<<(OneD.botBound_massflow()? "on" : "off")
				  <<"\nIgnition:  "<<(OneD.botBound_ignition()? "on" : "off")<<"\n\n";
			
			try
			{
				IO.beg_msg();
				OneD.run(IO.out);
			}
			catch(OneD_model::runErr err)
			{
				OneD.zero();
				std::cout<<"\n\n";
				IO.report_err(err.message);
				return 0;
			}
			
			OneD.zero();
			IO.end_msg();
		}
		else if(model=="2D")
		{
			TwoD_model TwoD;
			
			try
			{
				std::istringstream c_inp(IO.cond_inp);
				TwoD.load(c_inp);
			}
			catch(TwoD_model::loadErr err)
			{
				IO.out<<"Object type:  2D"
					  <<"\nNumber of layers:  "<<TwoD.Num_layers()
					  <<"\n\nFront Boundary"
					  <<"\nExternal heating:  "<<(TwoD.frntBound_extHeat()? "on" : "off")
					  <<"\nMass transport:  "<<(TwoD.frntBound_massflow()? "on" : "off")
					  <<"\nIgnition:  "<<(TwoD.frntBound_ignition()? "on" : "off")
					  <<"\n\nBack Boundary"
					  <<"\nExternal heating:  "<<(TwoD.backBound_extHeat()? "on" : "off")
					  <<"\nMass transport:  "<<(TwoD.backBound_massflow()? "on" : "off")
					  <<"\nIgnition:  "<<(TwoD.backBound_ignition()? "on" : "off")<<"\n\n";
				
				TwoD.zero();
				IO.report_err(err.message);
				return 0;
			}
			
			IO.cond_inp.clear();
			IO.out<<"Object type:  2D"
				  <<"\nNumber of layers:  "<<TwoD.Num_layers()
				  <<"\n\nFront Boundary"
				  <<"\nExternal heating:  "<<(TwoD.frntBound_extHeat()? "on" : "off")
				  <<"\nMass transport:  "<<(TwoD.frntBound_massflow()? "on" : "off")
				  <<"\nIgnition:  "<<(TwoD.frntBound_ignition()? "on" : "off")
				  <<"\n\nBack Boundary"
				  <<"\nExternal heating:  "<<(TwoD.backBound_extHeat()? "on" : "off")
				  <<"\nMass transport:  "<<(TwoD.backBound_massflow()? "on" : "off")
				  <<"\nIgnition:  "<<(TwoD.backBound_ignition()? "on" : "off")<<"\n\n";
			
			try
			{
				IO.beg_msg();
				TwoD.run(IO.out);
			}
			catch(TwoD_model::runErr err)
			{
				TwoD.zero();
				std::cout<<"\n\n";
				IO.report_err(err.message);
				return 0;
			}
			catch(std::bad_alloc)
			{
				TwoD.zero();
				std::cout<<"\n\n";
				IO.report_err("object data size exceeds available memory");
				return 0;
			}
			
			TwoD.zero();
			IO.end_msg();
		}
		else
		{
			IO.report_err("no identifiable object type is specified");
		}
	}
	
	return 0;
}