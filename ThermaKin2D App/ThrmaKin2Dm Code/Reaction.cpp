#include "Reaction.h"

React::React(std::string name_r1,std::string name_r2,
			 std::string name_p1,std::string name_p2,
			 double stoich_r1,double stoich_r2,
			 double stoich_p1,double stoich_p2,
			 double Af,double Ea,
			 double heat0,double heat1,double heat2,double heat3,
			 char lim,double Tlim)
{
	nmr[0]=name_r1; nmr[1]=name_r2; nmp[0]=name_p1; nmp[1]=name_p2;
	str[0]=stoich_r1; str[1]=stoich_r2; stp[0]=stoich_p1; stp[1]=stoich_p2;
	A=Af; E=Ea; h[0]=heat0; h[1]=heat1; h[2]=heat2; h[3]=heat3;
	lm=lim; Tlm=Tlim;
	ixr[0]=-1; ixr[1]=-1; ixp[0]=-1; ixp[1]=-1;
}

bool React::load(std::istringstream& reacpar)
{
	std::string buf;
	
	if((reacpar>>nmr[0])&&(reacpar>>buf)&&(buf=="+")&&(reacpar>>nmr[1])&&(reacpar>>buf)&&
	   (buf=="->")&&(reacpar>>nmp[0])&&(reacpar>>buf)&&(buf=="+")&&(reacpar>>nmp[1])&&
	   (reacpar>>buf)&&(buf=="STOICHIOMETRY:")&&
	   (reacpar>>str[0])&&(reacpar>>str[1])&&(reacpar>>stp[0])&&(reacpar>>stp[1])&&
	   (reacpar>>buf)&&(buf=="ARRHENIUS:")&&(reacpar>>A)&&(reacpar>>E)&&
	   (reacpar>>buf)&&(buf=="HEAT:")&&
	   (reacpar>>h[0])&&(reacpar>>h[1])&&(reacpar>>h[2])&&(reacpar>>h[3])&&
	   (reacpar>>buf)&&(buf=="TEMP")&&(reacpar>>buf)&&(buf=="LIMIT:")&&
	   (reacpar>>lm)&&(reacpar>>Tlm))
	{ return true; }
	else
	{ return false; }
}