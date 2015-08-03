#include <list>
#include <iostream>
#include "Solver.h"
#include "Boundary.h"

class OneD_model
   /* This class is used to perform a simulation of 1-dimensional object exposed to 
      external heat and/or mass fluxes. Run function calculates changes of the 
	  position-dependent composition and temperature in time and outputs this information 
	  (together with the state of the boundaries) to the output stream. */
{
public:
	
	OneD_model() { zero(); }
	
	void load(std::istringstream& conds);
	struct loadErr { loadErr(std::string msg) { message=msg; } std::string message; };
	
	int Num_layers() { return Num_Elem; }
	bool topBound_radiation() { return topB.extRadiation_On(); }
	bool botBound_radiation() { return botB.extRadiation_On(); }
	bool topBound_massflow() { return (topB.massFlux_Num()? true : false); }
	bool botBound_massflow() { return (botB.massFlux_Num()? true : false); }
	bool topBound_ignition() { return (topB.Ign_massFlux_Num()? true : false); }
	bool botBound_ignition() { return (botB.Ign_massFlux_Num()? true : false); }
	
	void run(std::ostream& output)
	{
		grid_and_rates(); report(output);
		
		extern Comps mat;
		LES.init_setup(mat.Ncomps(),Num_Elem);
		NmT3=3*mat.Ncomps()+3; NmT3min1=NmT3-1;
		
		int sc=0;
		while((tme<tmelimit)&&Num_Elem)
		{
			integrate(); ++tm; tme=tmestep*tm; grid_and_rates(); ++sc;
			if(sc==outfreq_tme) { report(output); std::cout<<'.'; sc=0; }
		}
		if(sc!=0) { report(output); }
	}
	struct runErr { runErr(std::string msg) { message=msg; } std::string message; };
	
	void zero();

private:
	
	void report(std::ostream& output);
	
	void grid_and_rates();
	Elem tmpEfr, tmpEto, tmpEtr;
	
	void integrate();
	LinEqSolver LES;
	int NmT3, NmT3min1;
	
	std::list<Elem> object;
	double Elem_setSize;
	double Elem_minSize;
	double Elem_maxSize;
	int Num_Elem;
	
	Bound topB;
	Bound botB;
	double topB_minSize;
	double topB_maxSize;
	
	int tm;
	double tme;
	double tmestep;
	double tmstp_vs2;
	double tmelimit;
	
	int outfreq_Elem;
	int outfreq_tme;
};