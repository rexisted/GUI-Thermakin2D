#ifndef Comps_DEFINED
#define Comps_DEFINED

#include "Properties.h"
#include "Reaction.h"
#include "Mixtures.h"
#include "Element.h"

class Comps
   /* This class contains description of components of material, including chemical and 
      physical interactions between components. Member functions of this class are used to 
	  calculate properties of elements of an object (the elements are defined by Elem 
	  structure), rates of chemical changes within the elements, and fluxes of energy and 
	  matter between the elements. A two-section buffer (buf) is used to share calculation 
	  results between the member functions. The functions that require a single element 
	  for an input store and retrieve information from the active (activ) section of the 
	  buffer. The functions that require two elements use the active section for the first 
	  (plus) and inactive (inactiv) section for the second (minus) element. swich_buf 
	  function switches active and inactive sections. export_buf and import_buf functions 
	  copy the active section of the buffer to/from elements. A single object of this 
	  class, mat (declared in Components.cpp), is used in the ThermaKin program. */
{
public:
	
	Comps() { NUM_CMP=0; NUM_RXN=0; MIXload=false; activ=0; inactiv=1; }
	
	void load(std::istringstream& comps);
	struct loadErr { loadErr(std::string msg) { message=msg; } std::string message; };
	
	int Ncomps() { return NUM_CMP; }
	int Nrxns() { return NUM_RXN; }
	bool mixts_loaded() { return MIXload; }
	
	std::string comp_name(int indx) { return CMP[indx].name(); }
	int comp_indx(std::string name) { int i=-1; for (int c=0; c<NUM_CMP; c++) {
		                              if(CMP[c].name()==name) { i=c; } } return i; }
	double d_comp_dens_dT(int indx, double T) { return CMP[indx].d_dens_dT(T); }
	
	double volume(const Elem& E,bool buf_der=false);
	char state(double vol_fr_threshold=0.5); // uses results of volume
	double heat_cap(const Elem& E,bool buf_der=false);
	double therm_cond(const Elem& E,bool buf_der=false); // uses results of volume
	double gas_transp(const Elem& E,bool buf_der=false); // uses results of volume
	double emissivity(); // uses results of volume
	double absorption(const Elem& E);
	
	void swich_buf() { inactiv=activ; activ=(activ)? 0 : 1; }
	void export_buf(Elem& E);
	void import_buf(const Elem& E);
	
	void reactions_rates(Elem& E,bool calc_der=false); // uses results of volume
	void conduction_rates(Elem& Eplus,Elem& Eminus,char comm_axis='X',char expans_axis='X',
		                  bool calc_der=false); // uses results of volume & therm_cond
	void gas_transp_rates(Elem& Eplus,Elem& Eminus,char comm_axis='X',char expans_axis='X',
		                  bool calc_der=false); /* uses results of volume, heat_cap, &
												                            gas_transp */
	
	void move_contents(Elem& Efrom,Elem& Eto,bool gases_only=false);
	void heat_rate_to_temp_rate(Elem& E,bool calc_der=false); // uses results of heat_cap

private:
	
	Props CMP[Consts::MAX_CMP];
	int NUM_CMP;
	
	React RXN[Consts::MAX_RXN];
	int NUM_RXN;
	
	Mixrules MIX;
	bool MIXload;
	
	struct ElemProps { double one_vs_dns[Consts::MAX_CMP], m_vs_dns[Consts::MAX_CMP],
		                      d_m_vs_dns_dT[Consts::MAX_CMP], Svol, Lvol,
							  swl, d_swl_dm[Consts::MAX_CMP], d_swl_dT,
							  vol, d_vol_dm[Consts::MAX_CMP], d_vol_dT,
							  hcap, d_hcap_dm[Consts::MAX_CMP], d_hcap_dT,
							  cond, d_cond_dm[Consts::MAX_CMP], d_cond_dT,
							  trns, d_trns_dm[Consts::MAX_CMP], d_trns_dT;
	                 } buf[2]; int activ, inactiv;
};

#endif