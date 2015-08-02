#include <string>
#include <sstream>
#include <cmath>

class Props
   /* This class calculates physical properties of a component of material. The component 
      can be in solid (S), liquid (L), or gaseous (G) state. Density [kg/m^3], heat 
	  capacity [J/(kg*K)], thermal conductivity [W/(m*K)], and gas transport coefficient 
	  [m^2/s] are expressed as p0+p1*T+p2*T^p3, where p0, p1, p2, and p3 are 
	  property-specific parameters and T is temperature [K]. Emissivity [dimensionless] 
	  and absorption coefficient [m^2/kg] do not depend on temperature. */
{
public:
	
	Props(std::string name="DEFAULT",char state='L',
		  double dens0=1.0,double dens1=0.0,double dens2=0.0,double dens3=0.0,
		  double hcap0=1.0,double hcap1=0.0,double hcap2=0.0,double hcap3=0.0,
		  double cond0=1.0,double cond1=0.0,double cond2=0.0,double cond3=0.0,
		  double trns0=1.0,double trns1=0.0,double trns2=0.0,double trns3=0.0,
		  double emiss=1.0,double absrp=1.0);
	
	bool load(std::istringstream& comprop);
	
	std::string name() { return id; }
	char state() { return st; }
	
	double dens(double T) { return (dns[0]+dns[1]*T+dns[2]*pow(T,dns[3])); }
	double hcap(double T) { return (hcp[0]+hcp[1]*T+hcp[2]*pow(T,hcp[3])); }
	double cond(double T) { return (cnd[0]+cnd[1]*T+cnd[2]*pow(T,cnd[3])); }
	double trns(double T) { return (trn[0]+trn[1]*T+trn[2]*pow(T,trn[3])); }
	double emis() { return ems; }
	double absr() { return abs; }
	
	double d_dens_dT(double T) { return (dns[1]+dns[2]*dns[3]*pow(T,(dns[3]-1.0))); }
	double d_hcap_dT(double T) { return (hcp[1]+hcp[2]*hcp[3]*pow(T,(hcp[3]-1.0))); }
	double d_cond_dT(double T) { return (cnd[1]+cnd[2]*cnd[3]*pow(T,(cnd[3]-1.0))); }
	double d_trns_dT(double T) { return (trn[1]+trn[2]*trn[3]*pow(T,(trn[3]-1.0))); }

private:
	
	std::string id;
	char st;
	
	double dns[4];
	double hcp[4];
	double cnd[4];
	double trn[4];
	double ems;
	double abs;
};