#include "Properties.h"

Props::Props(std::string name,char state,
			 double dens0,double dens1,double dens2,double dens3,
			 double hcap0,double hcap1,double hcap2,double hcap3,
			 double cond0,double cond1,double cond2,double cond3,
			 double trns0,double trns1,double trns2,double trns3,
			 double emiss,double absrp)
{
	id=name; st=state;
	dns[0]=dens0; dns[1]=dens1; dns[2]=dens2; dns[3]=dens3;
	hcp[0]=hcap0; hcp[1]=hcap1; hcp[2]=hcap2; hcp[3]=hcap3;
	cnd[0]=cond0; cnd[1]=cond1; cnd[2]=cond2; cnd[3]=cond3;
	trn[0]=trns0; trn[1]=trns1; trn[2]=trns2; trn[3]=trns3;
	ems=emiss; abs=absrp;
}

bool Props::load(std::istringstream& comprop)
{
	std::string buf;
	
	if((comprop>>id)&&(comprop>>buf)&&(buf=="STATE:")&&(comprop>>st)&&
	   (comprop>>buf)&&(buf=="DENSITY:")&&
	   (comprop>>dns[0])&&(comprop>>dns[1])&&(comprop>>dns[2])&&(comprop>>dns[3])&&
	   (comprop>>buf)&&(buf=="HEAT")&&(comprop>>buf)&&(buf=="CAPACITY:")&&
	   (comprop>>hcp[0])&&(comprop>>hcp[1])&&(comprop>>hcp[2])&&(comprop>>hcp[3])&&
	   (comprop>>buf)&&(buf=="CONDUCTIVITY:")&&
	   (comprop>>cnd[0])&&(comprop>>cnd[1])&&(comprop>>cnd[2])&&(comprop>>cnd[3])&&
	   (comprop>>buf)&&(buf=="TRANSPORT:")&&
	   (comprop>>trn[0])&&(comprop>>trn[1])&&(comprop>>trn[2])&&(comprop>>trn[3])&&
	   (comprop>>buf)&&(buf=="EMISSIVITY")&&(comprop>>buf)&&(buf=="&")&&
	   (comprop>>buf)&&(buf=="ABSORPTION:")&&
	   (comprop>>ems)&&(comprop>>abs))
	{ return true; }
	else
	{ return false; }
}