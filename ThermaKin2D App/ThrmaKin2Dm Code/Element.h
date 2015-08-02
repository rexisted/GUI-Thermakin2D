#ifndef Element_DEFINED
#define Element_DEFINED

#include <valarray>
#include <string>
#include <vector>
#include <sstream>
#include "Constants.h"

struct rateEq
	/* This structure is used to express the rate of change of component mass or 
	   temperature in a given element of an object as a linear function of component 
	   masses and temperatures in the given and adjacent elements. */
{
	rateEq() { }
	
	void setup(int Ndim,int NmT) { rt0=0.0; if(Ndim>0) { thisElem.resize(NmT,0.0);
	                                                     XminusElem.resize(NmT,0.0);
														 XplusElem.resize(NmT,0.0);
											if(Ndim>1) { YminusElem.resize(NmT,0.0);
											             YplusElem.resize(NmT,0.0);
											if(Ndim>2) { ZminusElem.resize(NmT,0.0);
											             ZplusElem.resize(NmT,0.0); } } } }
	
	void zero(int Ndim,int NmT) { rt0=0.0; if(Ndim>0) { for(int c=0; c<NmT; c++) {
		                                                        thisElem[c]=0.0;
																XminusElem[c]=0.0;
																XplusElem[c]=0.0; }
	                                       if(Ndim>1) { for(int c=0; c<NmT; c++) {
											                    YminusElem[c]=0.0;
																YplusElem[c]=0.0; }
										   if(Ndim>2) { for(int c=0; c<NmT; c++) {
											                    ZminusElem[c]=0.0;
																ZplusElem[c]=0.0; } } } } }
	
	double rt0;
	std::valarray<double> thisElem;
	std::valarray<double> XminusElem, XplusElem;
	std::valarray<double> YminusElem, YplusElem;
	std::valarray<double> ZminusElem, ZplusElem;
};

struct prop_buf
	/* This structure contains element properties (and derivatives of the properties with 
	   respect to component masses and temperature), which are calculated by functions of 
	   the Comps class. This structure is used to store a copy of an internal buffer (buf) 
	   of an object of this class. */
{
	prop_buf(int Nm): one_vs_dns(Nm),m_vs_dns(Nm),d_m_vs_dns_dT(Nm),d_swl_dm(Nm),
		              d_vol_dm(Nm),d_hcap_dm(Nm),d_cond_dm(Nm),d_trns_dm(Nm) { }
	
	std::valarray<double> one_vs_dns, m_vs_dns;
	std::valarray<double> d_m_vs_dns_dT;
	double Svol, Lvol;
	
	double swl;
	std::valarray<double> d_swl_dm;
	double d_swl_dT;
	
	double vol;
	std::valarray<double> d_vol_dm;
	double d_vol_dT;
	
	double hcap;
	std::valarray<double> d_hcap_dm;
	double d_hcap_dT;
	
	double cond;
	std::valarray<double> d_cond_dm;
	double  d_cond_dT;
	
	double trns;
	std::valarray<double> d_trns_dm;
	double d_trns_dT;
};

struct Elem
	/* This structure contains masses of components, temperature, and dimensions for a 
	   rectangular element of a 1, 2, or 3-dimensional object. This structure stores 
	   expressions for the rates of change of the masses and temperature and the state of 
	   the element. This structure can also store element properties. */
{
	static void set(int Ncomps) { NmT=Ncomps+1; }
	
	Elem(int Ndimens=0): massT(NmT),massT_rate(NmT) { Ndim=Ndimens;
	                                                  for(int c=0; c<NmT; c++) {
													  massT_rate[c].setup(Ndimens,NmT); }
													  Xdim=Ydim=Zdim=1.0; state='N';
													  properts=NULL; }
	~Elem() { delete properts; }
	
	int Ndimens() { return Ndim; }
	void zero_rates() { for(int c=0; c<NmT; c++) { massT_rate[c].zero(Ndim,NmT); } }
	void setup_prop_buf() { properts=new prop_buf(NmT-1); }
	
	std::string output();
	
	std::valarray<double> massT;
	std::vector<rateEq> massT_rate;
	
	double Xdim, Ydim, Zdim;
	
	char state;
	
	prop_buf* properts;

private:
	
	int Ndim;
	static int NmT;
};

#endif