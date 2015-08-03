#include <string>
#include <sstream>
#include <cmath>
#include "Constants.h"

class React
   /* This class contains parameters of reaction r1+r2->p1+p2. The reaction rate 
      [kg/(s*m^3)] is calculated as k*{r1}*{r2}, where {r1} and {r2} are reactant 
	  concentrations [kg/m^3]. k is the rate constant that is defined as A*exp(-E/RT), 
	  where A is the pre-exponential factor, E is the activation energy [J/mol], R is 
	  the gas constant, and T is temperature [K]. The rate of consumption/formation of 
	  a reactant/product (the rate is never negative) is calculated by multiplying the 
	  reaction rate by the corresponding dimensionless stoichiometric coefficient. The 
	  rate of heat release (which is negative when reaction is endothermic) is calculated 
	  by multiplying the reaction rate by the reaction heat [J/kg], which is expressed as 
	  h0+h1*T+h2*T^h3. The reaction is "on" when the temperature is above the lower (L) or 
	  below the upper (U) temperature limit. */
{
public:
	
	React(std::string name_r1="DEFAULT",std::string name_r2="DEFAULT",
		  std::string name_p1="DEFAULT",std::string name_p2="DEFAULT",
		  double stoich_r1=1.0,double stoich_r2=1.0,
		  double stoich_p1=1.0,double stoich_p2=1.0,
		  double Af=1.0,double Ea=0.0,
		  double heat0=1.0,double heat1=0.0,double heat2=0.0,double heat3=0.0,
		  char lim='L',double Tlim=0.0);
	
	bool load(std::istringstream& reacpar);
	
	void asign_indx_r(int n,int indx) { ixr[n-1]=indx; }
	void asign_indx_p(int n,int indx) { ixp[n-1]=indx; }
	
	std::string name_r(int n) { return nmr[n-1]; }
	std::string name_p(int n) { return nmp[n-1]; }
	
	int indx_r(int n) { return ixr[n-1]; }
	int indx_p(int n) { return ixp[n-1]; }
	
	double stoich_r(int n) { return str[n-1]; }
	double stoich_p(int n) { return stp[n-1]; }
	
	double k(double T) { return (A*exp(-E/(Consts::R*T))); }
	double d_k_dT(double T) { return (A*E*exp(-E/(Consts::R*T))/(Consts::R*T*T)); }
	double d_k_dT(double k,double T) { return (k*E/(Consts::R*T*T)); }
	
	double heat(double T) { return (h[0]+h[1]*T+h[2]*pow(T,h[3])); }
	double d_heat_dT(double T) { return (h[1]+h[2]*h[3]*pow(T,(h[3]-1.0))); }
	
	bool on(double T) { if(lm=='L') { return (T>Tlm); } else if(lm=='U') { return (T<Tlm); }
	                    else { return false; } }

private:
	
	std::string nmr[2];
	std::string nmp[2];
	
	int ixr[2];
	int ixp[2];
	
	double str[2];
	double stp[2];
	
	double A, E;
	double h[4];
	
	char lm;
	double Tlm;
};