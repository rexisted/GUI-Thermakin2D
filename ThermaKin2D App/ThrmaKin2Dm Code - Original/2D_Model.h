#include <list>
#include <iostream>
#include "Solver.h"
#include "Boundary2D.h"

class TwoD_model
   /* This class is used to perform a simulation of 2-dimensional object exposed to 
      external heat and/or mass fluxes. Run function calculates changes of the 
	  position-dependent composition and temperature in time and outputs this information 
	  (together with the state of the boundaries) to the output stream. Note that the 
	  2-dimensional mass transport is on only when the front and back mass flux boundaries 
	  are operational (i.e., mF_Num>0 for both boundaries). */
{
public:
	
	TwoD_model() { zero(); }
	
	void load(std::istringstream& conds);
	struct loadErr { loadErr(std::string msg) { message=msg; } std::string message; };
	
	int Num_layers() { return Num_Colm; }
	bool frntBound_extHeat() { return frntB.extHeat_On(); }
	bool backBound_extHeat() { return backB.extHeat_On(); }
	bool frntBound_massflow() { return (frntB.massFlux_Num()? true : false); }
	bool backBound_massflow() { return (backB.massFlux_Num()? true : false); }
	bool frntBound_ignition() { return (frntB.Ign_massFlux_Num()? true : false); }
	bool backBound_ignition() { return (backB.Ign_massFlux_Num()? true : false); }
	
	void run(std::ostream& output)
	{
		grid_and_rates(); report(output);
		
		int max_Num_Elem=0;
		for(int cl=0; cl<Num_Colm; cl++)
		{
			if(Num_Elem[cl]>max_Num_Elem) { max_Num_Elem=Num_Elem[cl]; }
		}
		extern Comps mat;
		LES.init_setup(mat.Ncomps(),max_Num_Elem);
		NmT3=3*mat.Ncomps()+3; NmT3min1=NmT3-1;
		
		int sc=0;
		while(novoid&&(tme<tmelimit))
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
	bool novoid;
	
	void integrate();
	LinEqSolver LES;
	int NmT3, NmT3min1;
	
	std::vector<std::list<Elem>> object2D;
	int Num_Colm;
	double Colm_Size;
	double Totl_Size;
	int Num_Elem[Consts::MAX_COLM];
	double Colm_pos[Consts::MAX_COLM];
	double Elem_setSize;
	double Elem_minSize;
	double Elem_maxSize;
	
	Bound2D frntB;
	Bound2D backB;
	double frntB_minSize;
	double frntB_maxSize;
	double frntB_hF[Consts::MAX_COLM];
	double backB_hF[Consts::MAX_COLM];
	
	int tm;
	double tme;
	double tmestep;
	double tmstp_vs2;
	double tmelimit;
	
	int outfreq_Colm;
	int outfreq_Elem;
	int outfreq_tme;
};