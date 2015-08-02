#include "2D_Model.h"

void TwoD_model::zero()
{
	novoid=true;
	LES.init_setup(0,0);
	NmT3=NmT3min1=0;
	
	object2D.clear();
	Num_Colm=0;
	for(int c=0; c<Consts::MAX_COLM; c++)
	{
		Num_Elem[c]=0;
		Colm_pos[c]=frntB_hF[c]=backB_hF[c]=0.0;
	}
	Colm_Size=Totl_Size=Elem_setSize=Elem_minSize=Elem_maxSize=0.0;
	frntB_minSize=frntB_maxSize=0.0;
	
	tm=0;
	tme=tmestep=tmstp_vs2=tmelimit=0.0;
	
	outfreq_Colm=outfreq_Elem=outfreq_tme=1;
}

void TwoD_model::load(std::istringstream& conds)
{
	zero();
	
	int cl=Consts::MAX_COLM;
	double LW;
	object2D.resize(Consts::MAX_COLM);
	
	bool frntB_load=false;
	bool backB_load=false;
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
				while(read&&(buf!="OBJECT")&&(buf!="INTEGRATION"))
				{
					if((buf=="FROM")&&(conds>>buf)&&(buf=="BOTTOM:")&&(conds>>buf))
					{
						cl=Consts::MAX_COLM;
						while(read&&(buf!="OBJECT")&&(buf!="INTEGRATION"))
						{
							if((buf=="LAYER")&&(conds>>buf)&&(buf=="LENGTH:")&&(conds>>LW))
							{
								if(!((conds>>buf)&&(buf=="FROM")&&(conds>>buf)&&(buf=="FRONT:")&&(conds>>buf)))
								{
									throw loadErr("cannot read description of object structure");
								}
								
								--cl;
								if(cl<1) { Num_Colm=Consts::MAX_COLM; throw loadErr("too many object layers"); }
								object2D[cl].clear(); Num_Elem[cl]=0;
								while(read&&(buf!="OBJECT")&&(buf!="INTEGRATION")&&(buf!="LAYER"))
								{
									if(buf=="THICKNESS:")
									{
										++Num_Elem[cl];
										if(Num_Elem[cl]>Consts::MAX_ELEM_COLM) { throw loadErr("too many elements in layer"); }
										object2D[cl].push_back(1);
										
										object2D[cl].rbegin()->Ydim=LW;
										for(int c=0; c<mat.Ncomps(); c++) { object2D[cl].rbegin()->massT[c]=0.0; }
										if(!((conds>>object2D[cl].rbegin()->Xdim)&&(conds>>buf)&&(buf=="TEMPERATURE:")&&
											 (conds>>object2D[cl].rbegin()->massT[mat.Ncomps()])&&(conds>>buf)&&
											 (buf=="MASS")&&(conds>>buf)&&(buf=="FRACTIONS:")&&(conds>>buf)&&
											 (mat.comp_indx(buf)>=0)&&(conds>>object2D[cl].rbegin()->massT[mat.comp_indx(buf)])))
										{
											throw loadErr("cannot read description of object structure");
										}
										while((conds>>buf)&&(mat.comp_indx(buf)>=0))
										{
											if(!(conds>>object2D[cl].rbegin()->massT[mat.comp_indx(buf)]))
											{
												throw loadErr("cannot read description of object structure");
											}
										}
									}
									else if(!(conds>>buf)) { read=false; }
								}
							}
							else if(!(conds>>buf)) { read=false; }
						}
					}
					else if(!(conds>>buf)) { read=false; }
				}
			}
			else if((buf=="BOUNDARIES")&&(conds>>buf))
			{
				while(read&&(buf!="OBJECT")&&(buf!="INTEGRATION"))
				{
					if((buf=="FRONT")&&(conds>>buf)&&(buf=="BOUNDARY"))
					{
						if(!frntB.load(conds,"FRONT   "))
						{
							throw loadErr("cannot read description of front boundary");
						}
						else { frntB_load=true; }
					}
					else if((buf=="BACK")&&(conds>>buf)&&(buf=="BOUNDARY"))
					{
						if(!backB.load(conds,"BACK    "))
						{
							throw loadErr("cannot read description of back boundary");
						}
						else { backB_load=true; }
					}
					else { if(!(conds>>buf)) { read=false; } }
				}
			}
			else { if(!(conds>>buf)) { read=false; } }
		}
		else if((buf=="INTEGRATION")&&(conds>>buf)&&(buf=="PARAMETERS")&&(conds>>buf))
		{
			while(read&&(buf!="OBJECT")&&(buf!="INTEGRATION"))
			{
				if((buf=="LAYER")&&(conds>>buf)&&(buf=="SIZE:"))
				{
					if(!((conds>>Colm_Size)&&
						 (conds>>buf)&&(buf=="ELEMENT")&&(conds>>buf)&&(buf=="SIZE:")&&
						 (conds>>Elem_setSize)&&
						 (conds>>buf)&&(buf=="TIME")&&(conds>>buf)&&(buf=="STEP:")&&
						 (conds>>tmestep)&&
						 (conds>>buf)&&(buf=="DURATION:")&&(conds>>tmelimit)&&
						 (conds>>buf)&&(buf=="OUTPUT")&&(conds>>buf)&&(buf=="FREQUENCY:")&&
						 (conds>>buf)&&(buf=="LAYERS:")&&(conds>>outfreq_Colm)&&
						 (conds>>buf)&&(buf=="ELEMENTS:")&&(conds>>outfreq_Elem)&&
						 (conds>>buf)&&(buf=="TIME")&&(conds>>buf)&&(buf=="STEPS:")&&
						 (conds>>outfreq_tme)))
					{
						throw loadErr("cannot read description of integration parameters");
					}
					else { tmstp_vs2=tmestep/2.0; intP_load=true; }
				}
				else if(!(conds>>buf)) { read=false; }
			}
		}
		else { if(!(conds>>buf)) { read=false; } }
	}
	
	if(!(cl<Consts::MAX_COLM)) { throw loadErr("cannot find description of object structure"); }
	if(!frntB_load) { throw loadErr("cannot find description of front boundary"); }
	if(!backB_load) { throw loadErr("cannot find description of back boundary"); }
	if(!intP_load) { throw loadErr("cannot find description of integration parameters"); }
	
	double m_coef;
	double Colm_Size_Limt=Colm_Size*(1.0+Consts::MIN_BOUND_ELEM_SIZE);
	for(int b=(Consts::MAX_COLM-1); b>=cl; b--)
	{
		if(Num_Elem[b])
		{
			while(object2D[b].begin()->Ydim>0.0)
			{
				if(Num_Colm<cl)
				{
					if(object2D[b].begin()->Ydim<Colm_Size_Limt)
					{
						if(object2D[b].begin()->Ydim<(Colm_Size_Limt-Colm_Size)) { throw loadErr("gridded layer is too thin"); }
						LW=object2D[b].begin()->Ydim; object2D[b].begin()->Ydim=0.0;
					}
					else
					{
						LW=Colm_Size; object2D[b].begin()->Ydim-=Colm_Size;
					}
					
					object2D[Num_Colm].clear();
					for(std::list<Elem>::iterator E=object2D[b].begin(); E!=object2D[b].end(); E++)
					{
						object2D[Num_Colm].push_back(1);
						
						m_coef=(E->Xdim*LW)/mat.volume(*E);
						for(int c=0; c<mat.Ncomps(); c++) { object2D[Num_Colm].rbegin()->massT[c]=E->massT[c]*m_coef; }
						object2D[Num_Colm].rbegin()->massT[mat.Ncomps()]=E->massT[mat.Ncomps()];
						object2D[Num_Colm].rbegin()->Xdim=E->Xdim; object2D[Num_Colm].rbegin()->Ydim=LW;
					}
					Num_Elem[Num_Colm]=Num_Elem[b];
				}
				else { Num_Colm=Consts::MAX_COLM; throw loadErr("too many object layers"); }
				++Num_Colm;
			}
			Num_Elem[b]=0;
		}
	}
	object2D.erase(object2D.begin()+Num_Colm,object2D.end());
	
	for(cl=0; cl<Num_Colm; cl++)
	{
		Totl_Size+=object2D[cl].begin()->Ydim;
		Colm_pos[cl]=Totl_Size-object2D[cl].begin()->Ydim/2.0;
	}
	
	double size_tol=Elem_setSize/double(Consts::MAX_ELEM_COLM*10);
	Elem_minSize=Elem_setSize-size_tol;
	Elem_maxSize=Elem_setSize+size_tol;
	
	frntB_minSize=Elem_setSize*Consts::MIN_BOUND_ELEM_SIZE;
	frntB_maxSize=Elem_setSize+frntB_minSize;
}

void TwoD_model::report(std::ostream& output)
{
	output<<"**************************************************************************"
		  <<"\n\nTime [s] =\t"<<tme<<"\n\n";
	
	frntB.report(output,true);
	backB.report(output,false);
	
	extern Comps mat;
	int clo=outfreq_Colm;
	double tot_mass=0.0;
	double mass, thick, bk_dist;
	int c, Eo;
	std::list<Elem>::iterator E;
	for(int cl=0; cl<Num_Colm; cl++)
	{
		if(Num_Elem[cl])
		{
			mass=0.0;
			for(E=object2D[cl].begin(); E!=object2D[cl].end(); E++)
			{
				for(c=0; c<mat.Ncomps(); c++) { mass+=E->massT[c]; }
			}
			tot_mass+=mass;
			
			if((clo==outfreq_Colm)||(cl==(Num_Colm-1)))
			{
				clo=0;
				
				if(fabs(frntB_hF[cl])<1.0e-10) { frntB_hF[cl]=0.0; }
				if(fabs(backB_hF[cl])<1.0e-10) { backB_hF[cl]=0.0; }
				
				output<<"\nFROM BOTTOM [m] =\t"<<Colm_pos[cl]
					  <<"\nFRONT HEAT FLUX IN [W/m^2] =\t"<<frntB_hF[cl]
					  <<"\nBACK HEAT FLUX IN [W/m^2] =\t"<<backB_hF[cl]
					  <<"\n-------------------------------------"
					  <<"\nFROM BACK [m]\tTEMPERATURE [K]   \tCONCENTRATION [kg/m^3]:";
				for(c=0; c<mat.Ncomps(); c++) { output<<"\t"<<mat.comp_name(c); }
				
				thick=0.0;
				for(E=object2D[cl].begin(); E!=object2D[cl].end(); E++) { thick+=E->Xdim; }
				
				Eo=outfreq_Elem;
				bk_dist=thick;
				E=object2D[cl].begin();
				while(E!=object2D[cl].end())
				{
					bk_dist-=E->Xdim;
					
					if(Eo==outfreq_Elem)
					{
						Eo=0;
						output<<"\n"<<(bk_dist+(E->Xdim/2.0))<<"\t"<<E->massT[mat.Ncomps()]<<"\t";
						for(c=0; c<mat.Ncomps(); c++) { output<<"\t"<<(E->massT[c]/(E->Xdim*E->Ydim)); }
					}
					
					++Eo; ++E;
				}
				
				if(Eo!=1)
				{
					--E;
					output<<"\n"<<(E->Xdim/2.0)<<"\t"<<E->massT[mat.Ncomps()]<<"\t";
					for(c=0; c<mat.Ncomps(); c++) { output<<"\t"<<(E->massT[c]/(E->Xdim*E->Ydim)); }
				}
				
				output<<"\n-----------------------------\nThickness [m] =\t"<<thick
					  <<"\nMass [kg/m^2] =\t"<<(mass/object2D[cl].begin()->Ydim)<<"\n";
			}
			
			++clo;
		}
		else
		{
			output<<"\nFROM BOTTOM [m] =\t"<<Colm_pos[cl]
			      <<"\n-------------------------------------\n"
				  <<"            EMPTY LAYER\n"
				  <<"-------------------------------------\n";
		}
	}
	
	output<<"\nTotal length [m]  =\t"<<Totl_Size
		  <<"\nTotal mass [kg/m] =\t"<<tot_mass<<"\n\n";
}

void TwoD_model::grid_and_rates()
{
	extern Comps mat;
	std::list<Elem>::iterator E, En, Enl;
	
	frntB.zero_flows();
	backB.zero_flows();
	
	int c;
	bool NOmass;
	double m_coef;
	for(int cl=0; cl<Num_Colm; cl++)
	{
		E=object2D[cl].begin();
		while(E!=object2D[cl].end())
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
			
			if(NOmass) { E=object2D[cl].erase(E); --Num_Elem[cl]; }
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
		
		if(Num_Elem[cl])
		{
			--E;
			E->Xdim=mat.volume(*E)/E->Ydim;
			while(E!=object2D[cl].begin())
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
					
					tmpEto.Xdim=mat.volume(tmpEto)/E->Ydim;
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
							
							tmpEto.Xdim=mat.volume(tmpEto)/E->Ydim;
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
						object2D[cl].erase(En); --Num_Elem[cl];
						for(c=0; c<=mat.Ncomps(); c++) { E->massT[c]=tmpEto.massT[c]; }
					}
					
					E->Xdim=tmpEto.Xdim;
				}
				else if(E->Xdim>Elem_maxSize)
				{
					if(Num_Elem[cl]<Consts::MAX_ELEM_COLM)
					{
						En=object2D[cl].insert(E,1); ++Num_Elem[cl];
						
						m_coef=1.0-Elem_setSize/E->Xdim;
						for(c=0; c<mat.Ncomps(); c++)
						{
							En->massT[c]=m_coef*E->massT[c];
							E->massT[c]-=En->massT[c];
						}
						En->massT[mat.Ncomps()]=E->massT[mat.Ncomps()];
						
						En->Xdim=m_coef*E->Xdim;
						En->Ydim=E->Ydim;
						
						E=En;
					}
					else { ++Num_Elem[cl]; throw runErr("too many elements in layer"); }
				}
				else
				{
					--E;
					E->Xdim=mat.volume(*E)/E->Ydim;
				}
			}
			
			while((E->Xdim<frntB_minSize)&&(Num_Elem[cl]>1))
			{
				En=E; ++E;
				mat.move_contents(*En,*E);
				object2D[cl].erase(En); --Num_Elem[cl];
				
				E->Xdim=mat.volume(*E)/E->Ydim;
			}
			
			while(E->Xdim>=frntB_maxSize)
			{
				if(Num_Elem[cl]<Consts::MAX_ELEM_COLM)
				{
					En=object2D[cl].insert(E,1); ++Num_Elem[cl];
					
					m_coef=1.0-Elem_setSize/E->Xdim;
					for(c=0; c<mat.Ncomps(); c++)
					{
						En->massT[c]=m_coef*E->massT[c];
						E->massT[c]-=En->massT[c];
					}
					En->massT[mat.Ncomps()]=E->massT[mat.Ncomps()];
					
					En->Xdim=m_coef*E->Xdim;
					En->Ydim=E->Ydim;
					
					En->properts=E->properts; E->properts=NULL;
					
					E=En;
				}
				else { ++Num_Elem[cl]; throw runErr("too many elements in layer"); }
			}
			
			object2D[cl].front().Xdim=mat.volume(object2D[cl].front(),true)/object2D[cl].front().Ydim;
			if(!object2D[cl].front().properts) { object2D[cl].front().setup_prop_buf(); }
			mat.export_buf(object2D[cl].front());
			frntB.massflow(&object2D[cl].front(),'X',(Colm_pos[cl]-object2D[cl].front().Ydim/2.0),true);
			
			object2D[cl].back().Xdim=mat.volume(object2D[cl].back(),true)/object2D[cl].back().Ydim;
			if(!object2D[cl].back().properts) { object2D[cl].back().setup_prop_buf(); }
			mat.export_buf(object2D[cl].back());
			backB.massflow(&object2D[cl].back(),'X',(Colm_pos[cl]-object2D[cl].back().Ydim/2.0),true);
		}
	}
	
	for(int cl=0; cl<Num_Colm; cl++)
	{
		if(Num_Elem[cl]>1)
		{
			frntB.inp_surfElem(&object2D[cl].front(),'X',Colm_pos[cl]);
			E=object2D[cl].begin();
			do { ++E; } while((E!=object2D[cl].end())&&frntB.inp_indpElem(&(*E)));
			frntB_hF[cl]=frntB.heatflow(tme,true);
			
			backB.inp_surfElem(&object2D[cl].back(),'X',Colm_pos[cl]);
			E=object2D[cl].end(); --E;
			do { --E; } while(backB.inp_indpElem(&(*E))&&(E!=object2D[cl].begin()));
			backB_hF[cl]=backB.heatflow(tme,true);
			
			if(frntB.massFlux_Num()||backB.massFlux_Num())
			{
				bool twoDtransp=(frntB.massFlux_Num()&&backB.massFlux_Num());
				
				mat.import_buf(object2D[cl].back());
				mat.heat_cap(object2D[cl].back(),true);
				mat.therm_cond(object2D[cl].back(),true);
				mat.gas_transp(object2D[cl].back(),true);
				
				mat.reactions_rates(object2D[cl].back(),true);
				
				mat.swich_buf();
				
				E=object2D[cl].end(); --E; En=E; --En;
				bool nl=true;
				int clnl=cl+1;
				if((clnl<Num_Colm)&&(Num_Elem[clnl])) { Enl=object2D[clnl].end(); --Enl; }
				else { nl=false; }
				while(En!=object2D[cl].begin())
				{
					if(nl)
					{
						mat.volume(*Enl);
						mat.therm_cond(*Enl);
						
						mat.conduction_rates(*Enl,*E,'Y','X');
						
						if(twoDtransp)
						{
							mat.heat_cap(*Enl);
							mat.gas_transp(*Enl);
							
							mat.gas_transp_rates(*Enl,*E,'Y','X');
						}
						
						if(Enl!=object2D[clnl].begin()) { --Enl; } else { nl=false; }
					}
					
					En->Xdim=mat.volume(*En,true)/En->Ydim;
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
				
				if(nl)
				{
					mat.volume(*Enl);
					mat.therm_cond(*Enl);
					
					mat.conduction_rates(*Enl,*E,'Y','X');
					
					if(twoDtransp)
					{
						mat.heat_cap(*Enl);
						mat.gas_transp(*Enl);
						
						mat.gas_transp_rates(*Enl,*E,'Y','X');
					}
					
					if(Enl!=object2D[clnl].begin()) { --Enl; } else { nl=false; }
				}
				
				mat.import_buf(object2D[cl].front());
				mat.heat_cap(object2D[cl].front(),true);
				mat.therm_cond(object2D[cl].front(),true);
				mat.gas_transp(object2D[cl].front(),true);
				
				mat.reactions_rates(object2D[cl].front(),true);
				mat.conduction_rates(object2D[cl].front(),*E,'X','X',true);
				mat.gas_transp_rates(object2D[cl].front(),*E,'X','X',true);
				
				mat.swich_buf();
				
				mat.heat_rate_to_temp_rate(*E,true);
				
				if(nl)
				{
					mat.volume(*Enl);
					mat.therm_cond(*Enl);
					
					mat.conduction_rates(*Enl,object2D[cl].front(),'Y','X');
					
					if(twoDtransp)
					{
						mat.heat_cap(*Enl);
						mat.gas_transp(*Enl);
						
						mat.gas_transp_rates(*Enl,object2D[cl].front(),'Y','X');
					}
				}
				
				mat.swich_buf();
				
				mat.heat_rate_to_temp_rate(object2D[cl].front(),true);
			}
			else
			{
				mat.import_buf(object2D[cl].back());
				mat.heat_cap(object2D[cl].back(),true);
				mat.therm_cond(object2D[cl].back(),true);
				
				mat.reactions_rates(object2D[cl].back(),true);
				
				mat.swich_buf();
				
				E=object2D[cl].end(); --E; En=E; --En;
				bool nl=true;
				int clnl=cl+1;
				if((clnl<Num_Colm)&&(Num_Elem[clnl])) { Enl=object2D[clnl].end(); --Enl; }
				else { nl=false; }
				while(En!=object2D[cl].begin())
				{
					if(nl)
					{
						mat.volume(*Enl);
						mat.therm_cond(*Enl);
						
						mat.conduction_rates(*Enl,*E,'Y','X');
						
						if(Enl!=object2D[clnl].begin()) { --Enl; } else { nl=false; }
					}
					
					En->Xdim=mat.volume(*En,true)/En->Ydim;
					mat.heat_cap(*En,true);
					mat.therm_cond(*En,true);
					
					mat.reactions_rates(*En,true);
					mat.conduction_rates(*En,*E,'X','X',true);
					
					mat.swich_buf();
					
					mat.heat_rate_to_temp_rate(*E,true);
					
					E=En; --En;
				}
				
				if(nl)
				{
					mat.volume(*Enl);
					mat.therm_cond(*Enl);
					
					mat.conduction_rates(*Enl,*E,'Y','X');
					
					if(Enl!=object2D[clnl].begin()) { --Enl; } else { nl=false; }
				}
				
				mat.import_buf(object2D[cl].front());
				mat.heat_cap(object2D[cl].front(),true);
				mat.therm_cond(object2D[cl].front(),true);
				
				mat.reactions_rates(object2D[cl].front(),true);
				mat.conduction_rates(object2D[cl].front(),*E,'X','X',true);
				
				mat.swich_buf();
				
				mat.heat_rate_to_temp_rate(*E,true);
				
				if(nl)
				{
					mat.volume(*Enl);
					mat.therm_cond(*Enl);
					
					mat.conduction_rates(*Enl,object2D[cl].front(),'Y','X');
				}
				
				mat.swich_buf();
				
				mat.heat_rate_to_temp_rate(object2D[cl].front(),true);
			}
		}
		else if(Num_Elem[cl]>0)
		{
			frntB.inp_surfElem(&object2D[cl].front(),'X',Colm_pos[cl]);
			frntB_hF[cl]=frntB.heatflow(tme,true);
			
			backB.inp_surfElem(&object2D[cl].front(),'X',Colm_pos[cl]);
			backB_hF[cl]=backB.heatflow(tme,true);
			
			mat.import_buf(object2D[cl].front());
			mat.heat_cap(object2D[cl].front(),true);
			
			mat.reactions_rates(object2D[cl].front(),true);
			
			int clnl=cl+1;
			if((clnl<Num_Colm)&&(Num_Elem[clnl]))
			{
				mat.therm_cond(object2D[cl].front());
				mat.gas_transp(object2D[cl].front());
				
				mat.swich_buf();
				
				mat.volume(object2D[clnl].back());
				mat.heat_cap(object2D[clnl].back());
				mat.therm_cond(object2D[clnl].back());
				mat.gas_transp(object2D[clnl].back());
				
				mat.conduction_rates(object2D[clnl].back(),object2D[cl].front(),'Y','X');
				mat.gas_transp_rates(object2D[clnl].back(),object2D[cl].front(),'Y','X');
				
				mat.swich_buf();
			}
			
			mat.heat_rate_to_temp_rate(object2D[cl].front(),true);
		}
		else { novoid=false; }
	}
}

void TwoD_model::integrate()
{
	extern Comps mat;
	for(int cl=0; cl<Num_Colm; cl++)
	{
		LES.setup(Num_Elem[cl]);
		
		if(Num_Elem[cl]>1)
		{
			std::list<Elem>::iterator E=object2D[cl].begin();
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
			while(Em!=object2D[cl].end())
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
				Em=E; E=object2D[cl].begin();
				
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
						
						++t;
						E->massT_rate[m].rt0-=E->massT_rate[m].XminusElem[mat.Ncomps()]*LES.sol[t];
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
			for(E=object2D[cl].begin();E!=object2D[cl].end(); E++)
			{
				E->massT[mat.Ncomps()]=LES.sol[e]; ++e;
				for(c=0; c<mat.Ncomps(); c++) { E->massT[c]=LES.sol[e]; ++e; }
			}
		}
		else if(Num_Elem[cl]>0)
		{
			int m=mat.Ncomps();
			
			int e=0;
			LES.sol[e]=object2D[cl].front().massT[m]+object2D[cl].front().massT_rate[m].rt0*tmestep;
			object2D[cl].front().massT_rate[m].rt0=-LES.sol[e];
			
			int t=0;
			LES.eq[e].tr[t]=0.0;
			while(t<m) { ++t; LES.eq[e].tr[t]=0.0; }
			
			++t;
			LES.eq[e].tr[t]=object2D[cl].front().massT_rate[m].thisElem[m]*tmstp_vs2;
			object2D[cl].front().massT_rate[m].rt0+=LES.eq[e].tr[t]*object2D[cl].front().massT[m];
			LES.eq[e].tr[t]-=1.0;
			object2D[cl].front().massT_rate[m].thisElem[m]=LES.eq[e].tr[t];
			
			int c=0;
			for(; c<m; c++)
			{
				++t;
				LES.eq[e].tr[t]=object2D[cl].front().massT_rate[m].thisElem[c]*tmstp_vs2;
				object2D[cl].front().massT_rate[m].rt0+=LES.eq[e].tr[t]*object2D[cl].front().massT[c];
				object2D[cl].front().massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
			}
			
			while(t<NmT3min1) { ++t; LES.eq[e].tr[t]=0.0; }
			
			LES.eq[e].tr[NmT3]=object2D[cl].front().massT_rate[m].rt0;
			
			for(m=0; m<mat.Ncomps(); m++)
			{
				++e;
				LES.sol[e]=object2D[cl].front().massT[m]+object2D[cl].front().massT_rate[m].rt0*tmestep;
				object2D[cl].front().massT_rate[m].rt0=-LES.sol[e];
				
				t=0;
				LES.eq[e].tr[t]=0.0;
				while(t<mat.Ncomps()) { ++t; LES.eq[e].tr[t]=0.0; }
				
				++t;
				LES.eq[e].tr[t]=object2D[cl].front().massT_rate[m].thisElem[mat.Ncomps()]*tmstp_vs2;
				object2D[cl].front().massT_rate[m].rt0+=LES.eq[e].tr[t]*object2D[cl].front().massT[mat.Ncomps()];
				object2D[cl].front().massT_rate[m].thisElem[mat.Ncomps()]=LES.eq[e].tr[t];
				
				for(c=0; c<mat.Ncomps(); c++)
				{
					++t;
					LES.eq[e].tr[t]=object2D[cl].front().massT_rate[m].thisElem[c]*tmstp_vs2;
					object2D[cl].front().massT_rate[m].rt0+=LES.eq[e].tr[t]*object2D[cl].front().massT[c];
					if(m==c) { LES.eq[e].tr[t]-=1.0; }
					object2D[cl].front().massT_rate[m].thisElem[c]=LES.eq[e].tr[t];
				}
				
				while(t<NmT3min1) { ++t; LES.eq[e].tr[t]=0.0; }
				
				LES.eq[e].tr[NmT3]=object2D[cl].front().massT_rate[m].rt0;
			}
			
			if(LES.solve())
			{
				m=mat.Ncomps();
				
				e=0; t=0;
				object2D[cl].front().massT_rate[m].rt0-=object2D[cl].front().massT_rate[m].thisElem[m]*LES.sol[t];
				
				for(c=0; c<m; c++)
				{
					++t;
					object2D[cl].front().massT_rate[m].rt0-=object2D[cl].front().massT_rate[m].thisElem[c]*LES.sol[t];
				}
				
				LES.eq[e].tr[NmT3]=-object2D[cl].front().massT_rate[m].rt0;
				
				for(m=0; m<mat.Ncomps(); m++)
				{
					++e; t=0;
					object2D[cl].front().massT_rate[m].rt0-=object2D[cl].front().massT_rate[m].thisElem[mat.Ncomps()]*LES.sol[t];
					for(c=0; c<mat.Ncomps(); c++)
					{
						++t;
						object2D[cl].front().massT_rate[m].rt0-=object2D[cl].front().massT_rate[m].thisElem[c]*LES.sol[t];
					}
					
					LES.eq[e].tr[NmT3]=-object2D[cl].front().massT_rate[m].rt0;
				}
				
				LES.improve();
			}
			
			e=0;
			object2D[cl].front().massT[mat.Ncomps()]=LES.sol[e];
			for(c=0; c<mat.Ncomps(); c++) { ++e; object2D[cl].front().massT[c]=LES.sol[e]; }
		}
	}
}