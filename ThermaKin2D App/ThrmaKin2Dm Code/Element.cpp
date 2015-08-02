#include "Element.h"

std::string Elem::output()
{
	std::ostringstream out;
	out.precision(Consts::OUT_PREC);
	
	for(unsigned int c=0; c<massT.size(); c++)
	{
		out<<"massT ["<<c<<"] =  "<<massT[c]
		   <<"\nmassT rate:  "<<massT_rate[c].rt0
		   <<"\n             thisElem:";
		for(unsigned int r=0; r<massT_rate[c].thisElem.size(); r++)
		{
			out<<"  "<<massT_rate[c].thisElem[r];
		}
		out<<"\n               X-Elem:";
		for(unsigned int r=0; r<massT_rate[c].XminusElem.size(); r++)
		{
			out<<"  "<<massT_rate[c].XminusElem[r];
		}
		out<<"\n               X+Elem:";
		for(unsigned int r=0; r<massT_rate[c].XplusElem.size(); r++)
		{
			out<<"  "<<massT_rate[c].XplusElem[r];
		}
		out<<"\n               Y-Elem:";
		for(unsigned int r=0; r<massT_rate[c].YminusElem.size(); r++)
		{
			out<<"  "<<massT_rate[c].YminusElem[r];
		}
		out<<"\n               Y+Elem:";
		for(unsigned int r=0; r<massT_rate[c].YplusElem.size(); r++)
		{
			out<<"  "<<massT_rate[c].YplusElem[r];
		}
		out<<"\n               Z-Elem:";
		for(unsigned int r=0; r<massT_rate[c].ZminusElem.size(); r++)
		{
			out<<"  "<<massT_rate[c].ZminusElem[r];
		}
		out<<"\n               Z+Elem:";
		for(unsigned int r=0; r<massT_rate[c].ZplusElem.size(); r++)
		{
			out<<"  "<<massT_rate[c].ZplusElem[r];
		}
		out<<"\n";
	}
	out<<"XYZ dimensions:  "<<Xdim<<"  "<<Ydim<<"  "<<Zdim<<"\n"
	   <<"state:  "<<state<<"\n";
	
	if(properts)
	{
		out<<"\n"<<"1/density:          ";
		for(unsigned int c=0; c<properts->one_vs_dns.size(); c++)
		{
			out<<"  "<<properts->one_vs_dns[c];
		}
		out<<"\n"<<"mass/density:       ";
		for(unsigned int c=0; c<properts->m_vs_dns.size(); c++)
		{
			out<<"  "<<properts->m_vs_dns[c];
		}
		out<<"\n"<<"d(mass/density)/dT: ";
		for(unsigned int c=0; c<properts->d_m_vs_dns_dT.size(); c++)
		{
			out<<"  "<<properts->d_m_vs_dns_dT[c];
		}
		out<<"\n"<<"S volume =            "<<properts->Svol
		   <<"\n"<<"L volume =            "<<properts->Lvol
		   <<"\n"<<"swell =               "<<properts->swl
		   <<"\n"<<"d(swell)/dm:        ";
		for(unsigned int c=0; c<properts->d_swl_dm.size(); c++)
		{
			out<<"  "<<properts->d_swl_dm[c];
		}
		out<<"\n"<<"d(swell)/dT =         "<<properts->d_swl_dT
		   <<"\n"<<"volume =              "<<properts->vol
		   <<"\n"<<"d(volume)/dm:       ";
		for(unsigned int c=0; c<properts->d_vol_dm.size(); c++)
		{
			out<<"  "<<properts->d_vol_dm[c];
		}
		out<<"\n"<<"d(volume)/dT =        "<<properts->d_vol_dT
		   <<"\n"<<"heat cap =            "<<properts->hcap
		   <<"\n"<<"d(heat cap)/dm:     ";
		for(unsigned int c=0; c<properts->d_hcap_dm.size(); c++)
		{
			out<<"  "<<properts->d_hcap_dm[c];
		}
		out<<"\n"<<"d(heat cap)/dT =      "<<properts->d_hcap_dT
		   <<"\n"<<"conductivity =        "<<properts->cond
		   <<"\n"<<"d(conductivity)/dm: ";
		for(unsigned int c=0; c<properts->d_cond_dm.size(); c++)
		{
			out<<"  "<<properts->d_cond_dm[c];
		}
		out<<"\n"<<"d(conductivity)/dT =  "<<properts->d_cond_dT
		   <<"\n"<<"transport =           "<<properts->trns
		   <<"\n"<<"d(transport)/dm:    ";
		for(unsigned int c=0; c<properts->d_trns_dm.size(); c++)
		{
			out<<"  "<<properts->d_trns_dm[c];
		}
		out<<"\n"<<"d(transport)/dT =     "<<properts->d_trns_dT<<"\n";
	}
	
	return out.str();
}

int Elem::NmT=2;