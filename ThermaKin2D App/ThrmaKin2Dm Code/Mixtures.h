#include <sstream>
#include <string>

class Mixrules
   /* This class describes properties of mixtures of components. The class defines swelling 
      coefficient, swell, that is used to calculate volume: volume=Svol+Lvol+swell*Gvol, 
	  where Svol, Lvol, and Gvol are volumes of solids, liquids, and gases determined from 
	  component densities. The class also specifies what fractions of thermal conductivity 
	  and gas transport coefficients are calculated by a parallel-type averaging (sum of 
	  component coefficients weighted by component volume fractions) and what fractions are 
	  calculated by a series-type averaging (reciprocal of the sum of reciprocal component 
	  coefficients weighted by component volume fractions). */
{
public:
	
	Mixrules(double Sswell=1.0,double Lswell=1.0,double Gswell_lmt=1.0e-5,
		     double par_cond=0.5,double par_trns=0.5);
	
	bool load(std::istringstream& mixprops);
	
	double swell(double Svol,double Lvol,double Gvol) { double Gt=Gswl_lm*Gvol;
	                                                    swl_den=Svol+Lvol+Gt;
														swl=(Sswl*Svol+Lswl*Lvol+Gt)/
															swl_den;
														return swl; }
	double d_swell_dSvol() { return ((Sswl-swl)/swl_den); } // uses results of swell
	double d_swell_dLvol() { return ((Lswl-swl)/swl_den); } // uses results of swell
	double d_swell_dGvol() { return ((1.0-swl)*Gswl_lm/swl_den); } // uses results of swell
	
	double par_cond() { return p_cond; }
	double ser_cond() { return s_cond; }
	
	double par_trns() { return p_trns; }
	double ser_trns() { return s_trns; }

private:
	
	double Sswl, Lswl, Gswl_lm;
	double swl_den, swl;
	
	double p_cond, s_cond;
	
	double p_trns, s_trns;
};