#ifndef Bound2D_DEFINED
#define Bound2D_DEFINED

#include <ctime>
#include "Components.h"

class Bound2D
	/* This class calculates mass and heat flows through a surface of a 2D object. Mass flux 
      [kg/(s*m^2)] of a given component out of a surface element is expressed as 
	  par0*(m/v-par1*d), where m is component mass [kg], d is component density [kg/m^3] and v 
	  is element volume [m^3] or as par0*exp(-par1/(R*T)), where R is the gas constant 
	  [J/(mol*K)] and T is element temperature [K]. External heat flux [W/m^2] into the object 
	  can be radiative (RAD) or convective (CONV) in nature. Convective heat flux is specified 
	  as cnv*(outT-T), where cnv is convection coefficient and outT is outside temperature. 
	  outT (in the case of convection) or actual flux (in the case of radiation) is assumed to 
	  be position dependent. The dependence is a three-segment piecewise linear function with 
	  zero position at the object bottom. The position [m] is non-negative. Three external heat 
	  flux description modules are available to specify the fluxes at different periods of 
	  time [s]. The radiation is handled as follows: when absorption mode is set at MAX, all 
	  radiative heat flux is input into one surface or in-depth element that, according to the 
	  Beer’s law, absorbs most energy. When absorption mode is set at RAND, radiative heat is 
	  input into an element selected at random using the Beer’s law fraction of absorbed 
	  energy as a probability distribution. Ignition is simulated using ignition criterion 
	  that is equal to the sum of ratios of current and ignition (critical) mass fluxes. When 
	  this criterion reaches 1 for any surface element, flame heat flux, which can be either 
	  convective or radiative, is turned on. This heat flux (or outT, in the case of 
	  convection) depends on position with respect to flame bottom and total normalized 
	  burning rate of the boundary. Flame bottom position, fpos, is defined as that of ignited 
	  surface element closest to the object bottom. Total normalized burning rate [m] is 
	  defined as the sum of products of ignition criterions and lengths of all surface 
	  elements of the boundary. Inside flaming region, flame heat flux is defined by two 
	  constants, val0 and val1, which are heat fluxes (or outT) below and above specified 
	  distance from flame bottom. Below flaming region, the heat flux is expressed as Gaussian 
	  function of distance from flame bottom with the maximum value of val0. Length of flame, 
	  fhgt, is set to be equal to a constant plus factored power law function of total 
	  normalized burning rate. Above flaming region, at distance pos from the object bottom, 
	  the heat flux is equal to (val0 or val1)*fct*exp(-pow*((pos-fpos+ad)/(fhgt+ad))^2), 
	  where fct, pow and ad are constants. Constant background temperature value is added to 
	  outT describing external and flame convective heat fluxes. This value is also used to 
	  compute extra (background) radiative heat flux onto the object surface. massflow function 
	  uses results of volume calculation stored in the properts buffer of surface element; it 
	  should be applied to all surface elements of the boundary, from bottom to top, prior to 
	  heat flow calculations. inp_indpElem function returns false after all radiation is 
	  absorbed. When properts buffer is defined for the radiation absorbing element, heatflow 
	  function uses results of volume calculation stored in that buffer. The mass and heat 
	  flows (including re-radiation) are added up for all surface elements and reported by 
	  report function. A capability to ramp up or down the external heat fluxes by scaling them 
	  with a factor between 0 and 1, which is a linear function of time, has been added to this 
	  class. */
{
public:
	
	Bound2D() { zero(); }
	
	bool load(std::istringstream& boundpar,std::string name="DEFAULT");
	
	int massFlux_Num() { return mF_Num; }
	int Ign_massFlux_Num() { return ign_mF_Num; }
	bool extHeat_On() { return ((EhF1_tend>EhF1_tbeg)||(EhF2_tend>EhF2_tbeg)); }
	
	void zero_flows() { extern Comps mat;
	                    for(int c=0; c<mat.Ncomps(); c++) { totl_mF[c]=0.0; }
						totl_IGN=totl_hF=totl_area=0.0; ign_pos=-1.0; }
	
	void massflow(Elem* surface,char surf_axis='X',double position=0.0,bool calc_der=false);
	
	void inp_surfElem(Elem* surface,char surf_axis='X',double position=0.0);
	bool inp_indpElem(Elem* indepth);
	double heatflow(double tme=0.0,bool calc_der=false);
	
	void report(std::ostream& output,bool header=true);

private:
	
	void zero();
	
	std::string id;
	
	int mF_Num;
	int mF_cInd[Consts::MAX_CMP];
	bool mF_expf[Consts::MAX_CMP];
	double mF_par0[Consts::MAX_CMP];
	double mF_par1[Consts::MAX_CMP];
	
	double mF[Consts::MAX_CMP];
	double totl_mF[Consts::MAX_CMP];
	
	int ign_mF_Num;
	int ign_mF_cInd[Consts::MAX_CMP];
	double ign_mF[Consts::MAX_CMP];
	double ign_pos;
	double totl_IGN;
	
	Elem* surf;
	double surf_pos, surf_area;
	
	Elem* absr;
	bool rand_absr;
	double rand_val;
	double T_back, hF_back;
	double hF_absr, hF_left;
	
	double EhF1_tbeg, EhF1_tend;
	char EhF1_ramp;
	double EhF1_pos[3], EhF1_val[3], EhF1_chg[3];
	double EhF1_coef;
	
	double EhF2_tbeg, EhF2_tend;
	char EhF2_ramp;
	double EhF2_pos[3], EhF2_val[3], EhF2_chg[3];
	double EhF2_coef;
	
	double EhF3_tbeg, EhF3_tend;
	char EhF3_ramp;
	double EhF3_pos[3], EhF3_val[3], EhF3_chg[3];
	double EhF3_coef;
	
	double fL_val, fL_fct, fL_pow;
	double fhFins_pos, fhFins_val[2];
	double fhFbel;
	double fhFabv_fct[2], fhFabv_pow, fhFabv_ad;
	double fhF_coef;
	
	double totl_area, totl_hF;
};

#endif