#include "1D_Model.h"

void OneD_model::zero()
{
	LES.init_setup(0,0);
	NmT3=NmT3min1=0;
	
	object.clear();
	Elem_setSize=Elem_minSize=Elem_maxSize=0.0;
	Num_Elem=0;
	
	topB_minSize=topB_maxSize=0.0;
	
	tm=0;
	tme=tmestep=tmstp_vs2=tmelimit=0.0;
	
	outfreq_Elem=outfreq_tme=1;
}

void OneD_model::load(std::istringstream& conds)
{
	zero();
	
	bool topB_load=false;
	bool botB_load=false;
	bool intP_load=false;
	
	bool read=true;
	std::string buf;
	extern Comps mat;
	while(read)
	{
		if((buf=="OBJECT")&&(conds>>buf))
		{
			if((buf=="STRUCTURE")&&(conds>>buf))
			{
				do
				{
					if(buf=="THICKNESS:")
					{
						object.push_back(1); ++Num_Elem;
						if(Num_Elem>Consts::MAX_ELEM)
						{
							throw loadErr("too many object elements");
						}
						
						for(int c=0; c<mat.Ncomps(); c++) { object.rbegin()->massT[c]=0.0; }
						
						if(!((conds>>object.rbegin()->Xdim)&&
							 (conds>>buf)&&(buf=="TEMPERATURE:")&&
							 (conds>>object.rbegin()->massT[mat.Ncomps()])&&
							 (conds>>buf)&&(buf=="MASS")&&
							 (conds>>buf)&&(buf=="FRACTIONS:")&&
							 (conds>>buf)&&(mat.comp_indx(buf)>=0)&&
							 (conds>>object.rbegin()->massT[mat.comp_indx(buf)])))
						{
							throw loadErr("cannot read description of object structure");
						}
						
						while((conds>>buf)&&(mat.comp_indx(buf)>=0))
						{
							if(!(conds>>object.rbegin()->massT[mat.comp_indx(buf)]))
							{
								throw loadErr("cannot read description of object structure");
							}
						}
					}
					else if(!(conds>>buf)) { read=false; break; }
				} while((buf!="OBJECT")&&(buf!="INTEGRATION"));
			}
			else if((buf=="BOUNDARIES")&&(conds>>buf))
			{
				do
				{
					if((buf=="TOP")&&(conds>>buf)&&(buf=="BOUNDARY"))
					{
						if(!topB.load(conds,"TOP     "))
						{
							throw loadErr("cannot read description of top boundary");
						}
						else { topB_load=true; }
					}
					else if((buf=="BOTTOM")&&(conds>>buf)&&(buf=="BOUNDARY"))
					{
						if(!botB.load(conds,"BOTTOM  "))
						{
							throw loadErr("cannot read description of bottom boundary");
						}
						else { botB_load=true; }
					}
				} while((buf!="OBJECT")&&(buf!="INTEGRATION")&&(conds>>buf));
			}
			else { if(!(conds>>buf)) { read=false; } }
		}
		else if((buf=="INTEGRATION")&&(conds>>buf)&&(buf=="PARAMETERS")&&(conds>>buf))
		{
			do
			{
				if((buf=="ELEMENT")&&(conds>>buf)&&(buf=="SIZE:"))
				{
					if(!((conds>>Elem_setSize)&&
						 (conds>>buf)&&(buf=="TIME")&&(conds>>buf)&&(buf=="STEP:")&&
						 (conds>>tmestep)&&
						 (conds>>buf)&&(buf=="DURATION:")&&(conds>>tmelimit)&&
						 (conds>>buf)&&(buf=="OUTPUT")&&(conds>>buf)&&(buf=="FREQUENCY:")&&
						 (conds>>buf)&&(buf=="ELEMENTS:")&&(conds>>outfreq_Elem)&&
						 (conds>>buf)&&(buf=="TIME")&&(conds>>buf)&&(buf=="STEPS:")&&
						 (conds>>outfreq_tme)))
					{
						throw loadErr("cannot read description of integration parameters");
					}
					else { tmstp_vs2=tmestep/2.0; intP_load=true; }
				}
			} while((buf!="OBJECT")&&(buf!="INTEGRATION")&&(conds>>buf));
		}
		else { if(!(conds>>buf)) { read=false; } }
	}
	
	if(!Num_Elem) { throw loadErr("cannot find description of object structure"); }
	if(!topB_load) { throw loadErr("cannot find description of top boundary"); }
	if(!botB_load) { throw loadErr("cannot find description of bottom boundary"); }
	if(!intP_load) { throw loadErr("cannot find description of integration parameters"); }
	
	double m_coef;
	for(std::list<Elem>::iterator E=object.begin(); E!=object.end(); E++)
	{
		m_coef=E->Xdim/mat.volume(*E);
		for(int c=0; c<mat.Ncomps(); c++) { E->massT[c]*=m_coef; }
	}
	
	double size_tol=Elem_setSize/double(Consts::MAX_ELEM_COLM*10);
	Elem_minSize=Elem_setSize-size_tol;
	Elem_maxSize=Elem_setSize+size_tol;
	
	topB_minSize=Elem_setSize*Consts::MIN_BOUND_ELEM_SIZE;
	topB_maxSize=Elem_setSize+topB_minSize;
}

void OneD_model::report(std::ostream& output)
{
	output<<"**************************************************************************"
		  <<"\n\nTime [s] =\t"<<tme<<"\n\n";
	
	topB.report(output,true);
	botB.report(output,false);
	
	int c;
	extern Comps mat;
	output<<"\nFROM TOP [m]\tTEMPERATURE [K]   \tCONCENTRATION [kg/m^3]:";
	for(c=0; c<mat.Ncomps(); c++) { output<<"\t"<<mat.comp_name(c); }
	
	double tot_thik=0.0;
	double tot_mass=0.0;
	int Ec=outfreq_Elem;
	std::list<Elem>::iterator E=object.begin();
	while(E!=object.end())
	{
		tot_thik+=E->Xdim;
		for(c=0; c<mat.Ncomps(); c++) { tot_mass+=E->massT[c]; }
		
		if(Ec==outfreq_Elem)
		{
			output<<"\n"<<(tot_thik-(E->Xdim/2.0))<<"\t"<<E->massT[mat.Ncomps()]<<"\t";
			for(c=0; c<mat.Ncomps(); c++) { output<<"\t"<<(E->massT[c]/E->Xdim); }
			Ec=0;
		}
		
		++Ec; ++E;
	}
	
	if((Ec!=1)&&Num_Elem)
	{
		--E;
		output<<"\n"<<(tot_thik-(E->Xdim/2.0))<<"\t"<<E->massT[mat.Ncomps()]<<"\t";
		for(c=0; c<mat.Ncomps(); c++) { output<<"\t"<<(E->massT[c]/E->Xdim); }
	}
	
	output<<"\n\nTotal thickness [m] =\t"<<tot_thik
		  <<"\nTotal mass [kg/m^2] =\t"<<tot_mass<<"\n\n";
}

void OneD_model::grid_and_rates()
{
	int c;
	bool NOmass;
	extern Comps mat;
	std::list<Elem>::iterator E=object.begin();
	while(E!=object.end())
	{
		NOmass=true;
		for(c=0; c<mat.Ncomps(); c++)
		{
			if(!(fabs(E->massT[c])<=Consts::MAX_MASS))
			{
				throw runErr("integration diverged");
			}
			else if(E->massT[c]<0.0) { E->massT[c]=0.0; }
			
			if(E->massT[c]>=Consts::MIN_MASS) { NOmass=false; }
		}
		
		if(NOmass) { E=object.erase(E); --Num_Elem; }
		else
		{
			if(!(fabs(E->massT[mat.Ncomps()])<=Consts::MAX_TEMP))
			{
				throw runErr("integration diverged");
			}
			else if(E->massT[mat.Ncomps()]<Consts::MIN_TEMP)
			{
				E->massT[mat.Ncomps()]=Consts::MIN_TEMP;
			}
			
			E->zero_rates();
			
			++E;
		}
	}
	
	if(Num_Elem)
	{
		--E;
		E->Xdim=mat.volume(*E);
		std::list<Elem>::iterator En;
		double m_coef;
		while(E!=object.begin())
		{
			if(E->Xdim<Elem_minSize)
			{
				En=E; --En;
				
				m_coef=1.0;
				for(c=0; c<=mat.Ncomps(); c++)
				{
					tmpEfr.massT[c]=En->massT[c];
					tmpEto.massT[c]=E->massT[c];
				}
				
				mat.move_contents(tmpEfr,tmpEto);
				
				tmpEto.Xdim=mat.volume(tmpEto);
				if(tmpEto.Xdim>Elem_maxSize)
				{
					int esc=0;
					do
					{
						m_coef*=(Elem_setSize-E->Xdim)/(tmpEto.Xdim-E->Xdim);
						for(c=0; c<mat.Ncomps(); c++)
						{
							tmpEfr.massT[c]=tmpEtr.massT[c]=m_coef*En->massT[c];
							tmpEto.massT[c]=E->massT[c];
						}
						tmpEfr.massT[mat.Ncomps()]=En->massT[mat.Ncomps()];
						tmpEto.massT[mat.Ncomps()]=E->massT[mat.Ncomps()];
						
						mat.move_contents(tmpEfr,tmpEto);
						
						tmpEto.Xdim=mat.volume(tmpEto);
						++esc;
					} while((tmpEto.Xdim>Elem_maxSize)&&(esc<3));
					
					for(c=0; c<mat.Ncomps(); c++)
					{
						En->massT[c]-=tmpEtr.massT[c];
						E->massT[c]=tmpEto.massT[c];
					}
					E->massT[mat.Ncomps()]=tmpEto.massT[mat.Ncomps()];
				}
				else
				{
					object.erase(En); --Num_Elem;
					for(c=0; c<=mat.Ncomps(); c++) { E->massT[c]=tmpEto.massT[c]; }
				}
				
				E->Xdim=tmpEto.Xdim;
			}
			else if(E->Xdim>Elem_maxSize)
			{
				if(Num_Elem<Consts::MAX_ELEM)
				{
					En=object.insert(E,1); ++Num_Elem;
					
					m_coef=1.0-Elem_setSize/E->Xdim;
					for(c=0; c<mat.Ncomps(); c++)
					{
						En->massT[c]=m_coef*E->massT[c];
						E->massT[c]-=En->massT[c];
					}
					En->massT[mat.Ncomps()]=E->massT[mat.Ncomps()];
					
					En->Xdim=m_coef*E->Xdim;
					
					E=En;
				}
				else { ++Num_Elem; throw runErr("too many object elements"); }
			}
			else
			{
				--E;
				E->Xdim=mat.volume(*E);
			}
		}
		
		while((E->Xdim<topB_minSize)&&(Num_Elem>1))
		{
			En=E; ++E;
			mat.move_contents(*En,*E);
			object.erase(En); --Num_Elem;
			
			E->Xdim=mat.volume(*E);
		}
		
		while(E->Xdim>=topB_maxSize)
		{
			if(Num_Elem<Consts::MAX_ELEM)
			{
				En=object.insert(E,1); ++Num_Elem;
				
				m_coef=1.0-Elem_setSize/E->Xdim;
				for(c=0; c<mat.Ncomps(); c++)
				{
					En->massT[c]=m_coef*E->massT[c];
					E->massT[c]-=En->massT[c];
				}
				En->massT[mat.Ncomps()]=E->massT[mat.Ncomps()];
				
				En->Xdim=m_coef*E->Xdim;
				
				En->properts=E->properts; E->properts=NULL;
				
				E=En;
			}
			else { ++Num_Elem; throw runErr("too many object elements"); }
		}
		
		if(Num_Elem>1)
		{
			object.front().Xdim=mat.volume(object.front(),true);
			if(!object.front().properts) { object.front().setup_prop_buf(); }
			mat.export_buf(object.front());
			
			object.back().Xdim=mat.volume(object.back(),true);
			if(!object.back().properts) { object.back().setup_prop_buf(); }
			mat.export_buf(object.back());
			
			topB.inp_surfaceElem(&object.front(),'N',tmestep);
			
			do { ++E; } while((E!=object.end())&&topB.inp_indepthElem(&(*E)));
			
			topB.calculate(true);
			
			botB.inp_surfaceElem(&object.back(),'N',tmestep);
			
			E=object.end(); --E;
			do { --E; } while(botB.inp_indepthElem(&(*E))&&(E!=object.begin()));
			
			botB.calculate(true);
			
			if(topB.massFlux_Num()||botB.massFlux_Num())
			{
				mat.import_buf(object.back());
				mat.heat_cap(object.back(),true);
				mat.therm_cond(object.back(),true);
				mat.gas_transp(object.back(),true);
				
				mat.reactions_rates(object.back(),true);
				
				mat.swich_buf();
				
				E=object.end(); --E; En=E; --En;
				while(En!=object.begin())
				{
					En->Xdim=mat.volume(*En,true);
					mat.heat_cap(*En,true);
					mat.therm_cond(*En,true);
					mat.gas_transp(*En,true);
					
					mat.reactions_rates(*En,true);
					mat.conduction_rates(*En,*E,'X','X',true);
					mat.gas_transp_rates(*En,*E,'X','X',true);
					
					mat.swich_buf();
					
					mat.heat_rate_to_temp_rate(*E,true);
					
					E=En; --En;
				}
				
				mat.import_buf(object.front());
				mat.heat_cap(object.front(),true);
				mat.therm_cond(object.front(),true);
				mat.gas_transp(object.front(),true);
				
				mat.reactions_rates(object.front(),true);
				mat.conduction_rates(object.front(),*E,'X','X',true);
				mat.gas_transp_rates(object.front(),*E,'X','X',true);
				
				mat.heat_rate_to_temp_rate(object.front(),true);
				
				mat.swich_buf();
				
				mat.heat_rate_to_temp_rate(*E,true);
			}
			else
			{
				mat.import_buf(object.back());
				mat.heat_cap(object.back(),true);
				mat.therm_cond(object.back(),true);
				
				mat.reactions_rates(object.back(),true);
				
				mat.swich_buf();
				
				E=object.end(); --E; En=E; --En;
				while(En!=object.begin())
				{
					En->Xdim=mat.volume(*En,true);
					mat.heat_cap(*En,true);
					mat.therm_cond(*En,true);
					
					mat.reactions_rates(*En,true);
					mat.conduction_rates(*En,*E,'X','X',true);
					
					mat.swich_buf();
					
					mat.heat_rate_to_temp_rate(*E,true);
					
					E=En; --En;
				}
				
				mat.import_buf(object.front());
				mat.heat_cap(object.front(),true);
				mat.therm_cond(object.front(),true);
				
				mat.reactions_rates(object.front(),true);
				mat.conduction_rates(object.front(),*E,'X','X',true);
				
				mat.heat_rate_to_temp_rate(object.front(),true);
				
				mat.swich_buf();
				
				mat.heat_rate_to_temp_rate(*E,true);
			}
		}
		else
		{
			object.front().Xdim=mat.volume(object.front(),true);
			if(!object.front().properts) { object.front().setup_prop_buf(); }
			mat.export_buf(object.front());
			
			topB.inp_surfaceElem(&object.front(),'N',tmestep);
			topB.calculate(true);
			
			botB.inp_surfaceElem(&object.front(),'N',tmestep);
			botB.calculate(true);
			
			mat.heat_cap(object.front(),true);
			
			mat.reactions_rates(object.front(),true);
			
			mat.heat_rate_to_temp_rate(object.front(),true);
		}
	}
	else
	{
		topB.inp_surfaceElem(NULL,'N',tmestep);
		botB.inp_surfaceElem(NULL,'N',tmestep);
	}
}

void OneD_model::integrate()
{
	LES.setup(Num_Elem);
	
	extern Comps mat;
	if(Num_Elem>1)
	{
		std::list<Elem>::iterator E=object.begin();
		std::list<Elem>::iterator Ep=E;
		std::list<Elem>::iterator Em=E; ++Em;
		
		int m=mat.Ncomps();
		
		int e=0;
		LES.sol[e]=E->massT[m]+E->massT_rate[m].rt0*tmestep;
		E->massT_rate[m].rt0=-LES.sol[e];
		
		int t=0;
		LES.eq[e].tr[t]=0.0;
		while(t<m) { ++t; LES.eq[e].tr[t]=0.0; }
		
		++t;
		LES.eq[e].tr[t]=E->massT_rate[m].thisElem[m]*tmstp_vs2;
		E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[m];
		LES.eq[e].tr[t]-=1.0;
		E->massT_rate[m].thisElem[m]=LES.eq[e].tr[t];
		
		int c=0;
		for(; c<m; c++)
		{
			++t;
			LES.eq[e].tr[t]=E->massT_rate[m].thisElem[c]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[c];
			E->massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
		}
		
		++t;
		LES.eq[e].tr[t]=E->massT_rate[m].XminusElem[m]*tmstp_vs2;
		E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Em->massT[m];
		E->massT_rate[m].XminusElem[m]=LES.eq[e].tr[t];
		
		for(c=0; c<m; c++)
		{
			++t;
			LES.eq[e].tr[t]=E->massT_rate[m].XminusElem[c]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Em->massT[c];
			E->massT_rate[m].XminusElem[c]=LES.eq[e].tr[t];
		}
		
		LES.eq[e].tr[NmT3]=E->massT_rate[m].rt0;
		
		for(m=0; m<mat.Ncomps(); m++)
		{
			++e;
			LES.sol[e]=E->massT[m]+E->massT_rate[m].rt0*tmestep;
			E->massT_rate[m].rt0=-LES.sol[e];
			
			t=0;
			LES.eq[e].tr[t]=0.0;
			while(t<mat.Ncomps()) { ++t; LES.eq[e].tr[t]=0.0; }
			
			++t;
			LES.eq[e].tr[t]=E->massT_rate[m].thisElem[mat.Ncomps()]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[mat.Ncomps()];
			E->massT_rate[m].thisElem[mat.Ncomps()]=LES.eq[e].tr[t];
			
			for(c=0; c<mat.Ncomps(); c++)
			{
				++t;
				LES.eq[e].tr[t]=E->massT_rate[m].thisElem[c]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[c];
				if(m==c) { LES.eq[e].tr[t]-=1.0; }
				E->massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
			}
			
			++t;
			LES.eq[e].tr[t]=E->massT_rate[m].XminusElem[mat.Ncomps()]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Em->massT[mat.Ncomps()];
			E->massT_rate[m].XminusElem[mat.Ncomps()]=LES.eq[e].tr[t];
			
			for(c=0; c<mat.Ncomps(); c++)
			{
				++t;
				LES.eq[e].tr[t]=E->massT_rate[m].XminusElem[c]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Em->massT[c];
				E->massT_rate[m].XminusElem[c]=LES.eq[e].tr[t];
			}
			
			LES.eq[e].tr[NmT3]=E->massT_rate[m].rt0;
		}
		
		++E; ++Em;
		while(Em!=object.end())
		{
			m=mat.Ncomps();
			
			++e;
			LES.sol[e]=E->massT[m]+E->massT_rate[m].rt0*tmestep;
			E->massT_rate[m].rt0=-LES.sol[e];
			
			t=0;
			LES.eq[e].tr[t]=E->massT_rate[m].XplusElem[m]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Ep->massT[m];
			E->massT_rate[m].XplusElem[m]=LES.eq[e].tr[t];
			
			for(c=0; c<m; c++)
			{
				++t;
				LES.eq[e].tr[t]=E->massT_rate[m].XplusElem[c]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Ep->massT[c];
				E->massT_rate[m].XplusElem[c]=LES.eq[e].tr[t];
			}
			
			++t;
			LES.eq[e].tr[t]=E->massT_rate[m].thisElem[m]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[m];
			LES.eq[e].tr[t]-=1.0;
			E->massT_rate[m].thisElem[m]=LES.eq[e].tr[t];
			
			for(c=0; c<m; c++)
			{
				++t;
				LES.eq[e].tr[t]=E->massT_rate[m].thisElem[c]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[c];
				E->massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
			}
			
			++t;
			LES.eq[e].tr[t]=E->massT_rate[m].XminusElem[m]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Em->massT[m];
			E->massT_rate[m].XminusElem[m]=LES.eq[e].tr[t];
			
			for(c=0; c<m; c++)
			{
				++t;
				LES.eq[e].tr[t]=E->massT_rate[m].XminusElem[c]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Em->massT[c];
				E->massT_rate[m].XminusElem[c]=LES.eq[e].tr[t];
			}
			
			LES.eq[e].tr[NmT3]=E->massT_rate[m].rt0;
			
			for(m=0; m<mat.Ncomps(); m++)
			{
				++e;
				LES.sol[e]=E->massT[m]+E->massT_rate[m].rt0*tmestep;
				E->massT_rate[m].rt0=-LES.sol[e];
				
				t=0;
				LES.eq[e].tr[t]=E->massT_rate[m].XplusElem[mat.Ncomps()]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Ep->massT[mat.Ncomps()];
				E->massT_rate[m].XplusElem[mat.Ncomps()]=LES.eq[e].tr[t];
				
				for(c=0; c<mat.Ncomps(); c++)
				{
					++t;
					LES.eq[e].tr[t]=E->massT_rate[m].XplusElem[c]*tmstp_vs2;
					E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Ep->massT[c];
					E->massT_rate[m].XplusElem[c]=LES.eq[e].tr[t];
				}
				
				++t;
				LES.eq[e].tr[t]=E->massT_rate[m].thisElem[mat.Ncomps()]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[mat.Ncomps()];
				E->massT_rate[m].thisElem[mat.Ncomps()]=LES.eq[e].tr[t];
				
				for(c=0; c<mat.Ncomps(); c++)
				{
					++t;
					LES.eq[e].tr[t]=E->massT_rate[m].thisElem[c]*tmstp_vs2;
					E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[c];
					if(m==c) { LES.eq[e].tr[t]-=1.0; }
					E->massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
				}
				
				++t;
				LES.eq[e].tr[t]=E->massT_rate[m].XminusElem[mat.Ncomps()]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Em->massT[mat.Ncomps()];
				E->massT_rate[m].XminusElem[mat.Ncomps()]=LES.eq[e].tr[t];
				
				for(c=0; c<mat.Ncomps(); c++)
				{
					++t;
					LES.eq[e].tr[t]=E->massT_rate[m].XminusElem[c]*tmstp_vs2;
					E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Em->massT[c];
					E->massT_rate[m].XminusElem[c]=LES.eq[e].tr[t];
				}
				
				LES.eq[e].tr[NmT3]=E->massT_rate[m].rt0;
			}
			
			++Ep; ++E; ++Em;
		}
		
		m=mat.Ncomps();
		
		++e;
		LES.sol[e]=E->massT[m]+E->massT_rate[m].rt0*tmestep;
		E->massT_rate[m].rt0=-LES.sol[e];
		
		t=0;
		LES.eq[e].tr[t]=E->massT_rate[m].XplusElem[m]*tmstp_vs2;
		E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Ep->massT[m];
		E->massT_rate[m].XplusElem[m]=LES.eq[e].tr[t];
		
		for(c=0; c<m; c++)
		{
			++t;
			LES.eq[e].tr[t]=E->massT_rate[m].XplusElem[c]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Ep->massT[c];
			E->massT_rate[m].XplusElem[c]=LES.eq[e].tr[t];
		}
		
		++t;
		LES.eq[e].tr[t]=E->massT_rate[m].thisElem[m]*tmstp_vs2;
		E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[m];
		LES.eq[e].tr[t]-=1.0;
		E->massT_rate[m].thisElem[m]=LES.eq[e].tr[t];
		
		for(c=0; c<m; c++)
		{
			++t;
			LES.eq[e].tr[t]=E->massT_rate[m].thisElem[c]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[c];
			E->massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
		}
		
		while(t<NmT3min1) { ++t; LES.eq[e].tr[t]=0.0; }
		
		LES.eq[e].tr[NmT3]=E->massT_rate[m].rt0;
		
		for(m=0; m<mat.Ncomps(); m++)
		{
			++e;
			LES.sol[e]=E->massT[m]+E->massT_rate[m].rt0*tmestep;
			E->massT_rate[m].rt0=-LES.sol[e];
			
			t=0;
			LES.eq[e].tr[t]=E->massT_rate[m].XplusElem[mat.Ncomps()]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Ep->massT[mat.Ncomps()];
			E->massT_rate[m].XplusElem[mat.Ncomps()]=LES.eq[e].tr[t];
			
			for(c=0; c<mat.Ncomps(); c++)
			{
				++t;
				LES.eq[e].tr[t]=E->massT_rate[m].XplusElem[c]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*Ep->massT[c];
				E->massT_rate[m].XplusElem[c]=LES.eq[e].tr[t];
			}
			
			++t;
			LES.eq[e].tr[t]=E->massT_rate[m].thisElem[mat.Ncomps()]*tmstp_vs2;
			E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[mat.Ncomps()];
			E->massT_rate[m].thisElem[mat.Ncomps()]=LES.eq[e].tr[t];
			
			for(c=0; c<mat.Ncomps(); c++)
			{
				++t;
				LES.eq[e].tr[t]=E->massT_rate[m].thisElem[c]*tmstp_vs2;
				E->massT_rate[m].rt0+=LES.eq[e].tr[t]*E->massT[c];
				if(m==c) { LES.eq[e].tr[t]-=1.0; }
				E->massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
			}
			
			while(t<NmT3min1) { ++t; LES.eq[e].tr[t]=0.0; }
			
			LES.eq[e].tr[NmT3]=E->massT_rate[m].rt0;
		}
		
		if(LES.solve())
		{
			Em=E; E=object.begin();
			
			m=mat.Ncomps();
			
			e=0; t=0;
			E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[m]*LES.sol[t];
			for(c=0; c<m; c++)
			{
				++t;
				E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[c]*LES.sol[t];
			}
			
			++t;
			E->massT_rate[m].rt0-=E->massT_rate[m].XminusElem[m]*LES.sol[t];
			for(c=0; c<m; c++)
			{
				++t;
				E->massT_rate[m].rt0-=E->massT_rate[m].XminusElem[c]*LES.sol[t];
			}
			
			LES.eq[e].tr[NmT3]=-E->massT_rate[m].rt0;
			
			for(m=0; m<mat.Ncomps(); m++)
			{
				++e; t=0;
				E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[mat.Ncomps()]*LES.sol[t];
				for(c=0; c<mat.Ncomps(); c++)
				{
					++t;
					E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[c]*LES.sol[t];
				}
				
				++t;
				E->massT_rate[m].rt0-=E->massT_rate[m].XminusElem[mat.Ncomps()]*LES.sol[t];
				for(c=0; c<mat.Ncomps(); c++)
				{
					++t;
					E->massT_rate[m].rt0-=E->massT_rate[m].XminusElem[c]*LES.sol[t];
				}
				
				LES.eq[e].tr[NmT3]=-E->massT_rate[m].rt0;
			}
			
			++E;
			int tb=0;
			while(E!=Em)
			{
				m=mat.Ncomps();
				
				++e; t=tb;
				E->massT_rate[m].rt0-=E->massT_rate[m].XplusElem[m]*LES.sol[t];
				for(c=0; c<m; c++)
				{
					++t;
					E->massT_rate[m].rt0-=E->massT_rate[m].XplusElem[c]*LES.sol[t];
				}
				
				++t;
				E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[m]*LES.sol[t];
				for(c=0; c<m; c++)
				{
					++t;
					E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[c]*LES.sol[t];
				}
				
				++t;
				E->massT_rate[m].rt0-=E->massT_rate[m].XminusElem[m]*LES.sol[t];
				for(c=0; c<m; c++)
				{
					++t;
					E->massT_rate[m].rt0-=E->massT_rate[m].XminusElem[c]*LES.sol[t];
				}
				
				LES.eq[e].tr[NmT3]=-E->massT_rate[m].rt0;
				
				for(m=0; m<mat.Ncomps(); m++)
				{
					++e; t=tb;
					E->massT_rate[m].rt0-=E->massT_rate[m].XplusElem[mat.Ncomps()]*
						                  LES.sol[t];
					for(c=0; c<mat.Ncomps(); c++)
					{
						++t;
						E->massT_rate[m].rt0-=E->massT_rate[m].XplusElem[c]*LES.sol[t];
					}
					
					++t;
					E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[mat.Ncomps()]*
						                  LES.sol[t];
					for(c=0; c<mat.Ncomps(); c++)
					{
						++t;
						E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[c]*LES.sol[t];
					}
					
					++t;
					E->massT_rate[m].rt0-=E->massT_rate[m].XminusElem[mat.Ncomps()]*
						                  LES.sol[t];
					for(c=0; c<mat.Ncomps(); c++)
					{
						++t;
						E->massT_rate[m].rt0-=E->massT_rate[m].XminusElem[c]*LES.sol[t];
					}
					
					LES.eq[e].tr[NmT3]=-E->massT_rate[m].rt0;
				}
				
				tb+=mat.Ncomps()+1;
				++E;
			}
			
			m=mat.Ncomps();
			
			++e; t=tb;
			E->massT_rate[m].rt0-=E->massT_rate[m].XplusElem[m]*LES.sol[t];
			for(c=0; c<m; c++)
			{
				++t;
				E->massT_rate[m].rt0-=E->massT_rate[m].XplusElem[c]*LES.sol[t];
			}
			
			++t;
			E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[m]*LES.sol[t];
			for(c=0; c<m; c++)
			{
				++t;
				E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[c]*LES.sol[t];
			}
			
			LES.eq[e].tr[NmT3]=-E->massT_rate[m].rt0;
			
			for(m=0; m<mat.Ncomps(); m++)
			{
				++e; t=tb;
				E->massT_rate[m].rt0-=E->massT_rate[m].XplusElem[mat.Ncomps()]*LES.sol[t];
				for(c=0; c<mat.Ncomps(); c++)
				{
					++t;
					E->massT_rate[m].rt0-=E->massT_rate[m].XplusElem[c]*LES.sol[t];
				}
				
				++t;
				E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[mat.Ncomps()]*LES.sol[t];
				for(c=0; c<mat.Ncomps(); c++)
				{
					++t;
					E->massT_rate[m].rt0-=E->massT_rate[m].thisElem[c]*LES.sol[t];
				}
				
				LES.eq[e].tr[NmT3]=-E->massT_rate[m].rt0;
			}
			
			LES.improve();
		}
		
		e=0;
		for(E=object.begin();E!=object.end(); E++)
		{
			E->massT[mat.Ncomps()]=LES.sol[e]; ++e;
			for(c=0; c<mat.Ncomps(); c++) { E->massT[c]=LES.sol[e]; ++e; }
		}
	}
	else
	{
		int m=mat.Ncomps();
		
		int e=0;
		LES.sol[e]=object.front().massT[m]+object.front().massT_rate[m].rt0*tmestep;
		object.front().massT_rate[m].rt0=-LES.sol[e];
		
		int t=0;
		LES.eq[e].tr[t]=0.0;
		while(t<m) { ++t; LES.eq[e].tr[t]=0.0; }
		
		++t;
		LES.eq[e].tr[t]=object.front().massT_rate[m].thisElem[m]*tmstp_vs2;
		object.front().massT_rate[m].rt0+=LES.eq[e].tr[t]*object.front().massT[m];
		LES.eq[e].tr[t]-=1.0;
		object.front().massT_rate[m].thisElem[m]=LES.eq[e].tr[t];
		
		int c=0;
		for(; c<m; c++)
		{
			++t;
			LES.eq[e].tr[t]=object.front().massT_rate[m].thisElem[c]*tmstp_vs2;
			object.front().massT_rate[m].rt0+=LES.eq[e].tr[t]*object.front().massT[c];
			object.front().massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
		}
		
		while(t<NmT3min1) { ++t; LES.eq[e].tr[t]=0.0; }
		
		LES.eq[e].tr[NmT3]=object.front().massT_rate[m].rt0;
		
		for(m=0; m<mat.Ncomps(); m++)
		{
			++e;
			LES.sol[e]=object.front().massT[m]+object.front().massT_rate[m].rt0*tmestep;
			object.front().massT_rate[m].rt0=-LES.sol[e];
			
			t=0;
			LES.eq[e].tr[t]=0.0;
			while(t<mat.Ncomps()) { ++t; LES.eq[e].tr[t]=0.0; }
			
			++t;
			LES.eq[e].tr[t]=object.front().massT_rate[m].thisElem[mat.Ncomps()]*tmstp_vs2;
			object.front().massT_rate[m].rt0+=LES.eq[e].tr[t]*
				                              object.front().massT[mat.Ncomps()];
			object.front().massT_rate[m].thisElem[mat.Ncomps()]=LES.eq[e].tr[t];
			
			for(c=0; c<mat.Ncomps(); c++)
			{
				++t;
				LES.eq[e].tr[t]=object.front().massT_rate[m].thisElem[c]*tmstp_vs2;
				object.front().massT_rate[m].rt0+=LES.eq[e].tr[t]*object.front().massT[c];
				if(m==c) { LES.eq[e].tr[t]-=1.0; }
				object.front().massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
			}
			
			while(t<NmT3min1) { ++t; LES.eq[e].tr[t]=0.0; }
			
			LES.eq[e].tr[NmT3]=object.front().massT_rate[m].rt0;
		}
		
		if(LES.solve())
		{
			m=mat.Ncomps();
			
			e=0; t=0;
			object.front().massT_rate[m].rt0-=object.front().massT_rate[m].thisElem[m]*
				                              LES.sol[t];
			
			for(c=0; c<m; c++)
			{
				++t;
				object.front().massT_rate[m].rt0-=object.front().massT_rate[m].thisElem[c]*
					                              LES.sol[t];
			}
			
			LES.eq[e].tr[NmT3]=-object.front().massT_rate[m].rt0;
			
			for(m=0; m<mat.Ncomps(); m++)
			{
				++e; t=0;
				object.front().massT_rate[m].rt0-=
					   object.front().massT_rate[m].thisElem[mat.Ncomps()]*LES.sol[t];
				for(c=0; c<mat.Ncomps(); c++)
				{
					++t;
					object.front().massT_rate[m].rt0-=
						   object.front().massT_rate[m].thisElem[c]*LES.sol[t];
				}
				
				LES.eq[e].tr[NmT3]=-object.front().massT_rate[m].rt0;
			}
			
			LES.improve();
		}
		
		e=0;
		object.front().massT[mat.Ncomps()]=LES.sol[e];
		for(c=0; c<mat.Ncomps(); c++) { ++e; object.front().massT[c]=LES.sol[e]; }
	}
}