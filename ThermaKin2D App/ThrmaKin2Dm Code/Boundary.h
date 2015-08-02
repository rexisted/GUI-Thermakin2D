#ifndef Bound_DEFINED
#define Bound_DEFINED

#include <ctime>
#include "Components.h"

class Bound
   /* This class calculates mass and heat flows through a surface of an object. Mass flux 
      [kg/(s*m^2)] of a given component out of a surface element is expressed as 
	  par0*(m/v-par1*d), where m is component mass [kg], d is component density [kg/m^3], 
	  and v is element volume [m^3] or as par0*exp(-par1/(R*T)), where R is the gas 
	  constant [J/(mol*K)] and T is element temperature [K]. Convective heat flux [W/m^2] 
	  into a surface element is specified as cnv*(outT-T), where cnv is convection 
	  coefficient and outT is outside temperature, which is defined by a time [s] dependent 
	  heating rate. Specification of external radiation flux [W/m^2] consists of a sequence 
	  of two linear dependencies of the heat flux on time. This sequence can be repeated. 
	  When absorption mode is set to MAX, all radiative heat flux is input into one element 
	  that, according to the Beer’s law, absorbs most energy. When absorption mode is set 
	  to RAND, radiative heat is input into an element selected at random using the Beer’s 
	  law fraction of absorbed energy as a probability distribution. Ignition is simulated 
	  using ignition criterion that is equal to the sum of ratios of current and ignition 
	  (critical) mass fluxes. When this criterion reaches 1, a constant radiative heat flux 
	  is added and cnv and outT convection parameters are substituted by the corresponding 
	  constant parameters describing flaming conditions. Above-zero time step input into 
	  inp_surfaceElem function signals the beginning of a new boundary condition 
	  calculation for the next time step. Zero time step indicates that the same conditions 
	  are applied to another surface element. Current mass and heat flows are added up for 
	  all surface elements and reported by report function. inp_indepthElem function 
	  returns false after all radiation is absorbed. Calculate function uses the results of 
	  volume calculation stored in the properts buffer of a surface element. When properts 
	  buffer is defined for the radiation absorbing element, calculate function also uses 
	  the results of volume calculation stored in that buffer. */
{
public:
	
	Bound() { zero(); }
	
	bool load(std::istringstream& boundpar,std::string name="DEFAULT");
	
	int massFlux_Num() { return mF_Num; }
	int Ign_massFlux_Num() { return ign_mF_Num; }
	bool extRadiation_On() { return ((hF1_0!=0.0)||(hF1_rt!=0.0)||(hF2_0!=0.0)||
		                             (hF2_rt!=0.0)); }
	
	void inp_surfaceElem(Elem* surface,char surf_axis='X',double tmestep=0.0);
	bool inp_indepthElem(Elem* indepth);
	void mark_absorbElem(char state) { if(absr) { absr->state=state; } }
	void calculate(bool calc_der=false);
	
	void report(std::ostream& output,bool header=true);
	
	void reset_tme(double to=0.0) { tm=to; }

private:
	
	void zero();
	
	std::string id;
	
	int mF_Num;
	int mF_cInd[Consts::MAX_CMP];
	bool mF_expf[Consts::MAX_CMP];
	double mF_par0[Consts::MAX_CMP];
	double mF_par1[Consts::MAX_CMP];
	
	double outT_0;
	double outT_rt[4];
	double cnv_coef;
	
	double hF1_0, hF1_rt, hF1_tm;
	double hF2_0, hF2_rt, hF2_tm;
	bool hF_redo;
	bool rand_absr;
	
	int ign_mF_Num;
	int ign_mF_cInd[Consts::MAX_CMP];
	double ign_mF[Consts::MAX_CMP];
	
	double flm_outT;
	double flm_cnv_coef;
	double flm_hF;
	
	double tm;
	double outT[3];
	double hF[2];
	
	Elem* surf;
	double surf_area;
	
	Elem* absr;
	double hF_absr, hF_left;
	double rand_val;
	
	double mF[Consts::MAX_CMP];
	double totl_mF[Consts::MAX_CMP];
	double totl_hF, totl_area;
};

#endif