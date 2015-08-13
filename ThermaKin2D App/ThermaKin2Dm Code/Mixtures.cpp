#include "Mixtures.h"

Mixrules::Mixrules(double Sswell,double Lswell,double Gswell_lmt,
				   double par_cond,double par_trns)
{
	Sswl=Sswell; Lswl=Lswell; Gswl_lm=Gswell_lmt;
	swl_den=1.0; swl=1.0;
	p_cond=par_cond; s_cond=1.0-p_cond;
	p_trns=par_trns; s_trns=1.0-p_trns;
}

bool Mixrules::load(std::istringstream& mixprops)
{
	std::string buf;
	
	if((mixprops>>buf)&&(buf=="S")&&(mixprops>>buf)&&(buf=="SWELLING:")&&
	   (mixprops>>Sswl)&&
	   (mixprops>>buf)&&(buf=="L")&&(mixprops>>buf)&&(buf=="SWELLING:")&&
	   (mixprops>>Lswl)&&
	   (mixprops>>buf)&&(buf=="G")&&(mixprops>>buf)&&(buf=="SWELLING")&&
	   (mixprops>>buf)&&(buf=="LIMIT:")&&
	   (mixprops>>Gswl_lm)&&
	   (mixprops>>buf)&&(buf=="PARALL")&&(mixprops>>buf)&&(buf=="CONDUCTIVITY:")&&
	   (mixprops>>p_cond)&&
	   (mixprops>>buf)&&(buf=="PARALL")&&(mixprops>>buf)&&(buf=="TRANSPORT:")&&
	   (mixprops>>p_trns))
	{ s_cond=1.0-p_cond; s_trns=1.0-p_trns; return true; }
	else
	{ s_cond=1.0-p_cond; return false; }
}