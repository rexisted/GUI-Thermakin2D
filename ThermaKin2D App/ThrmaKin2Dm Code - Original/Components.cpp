#include "Components.h"

void Comps::load(std::istringstream& comps)
{
	NUM_CMP=NUM_RXN=0; MIXload=false;
	activ=0; inactiv=1;
	
	std::string buf, err;
	
	while(comps>>buf)
	{
		if(buf=="COMPONENT:")
		{
			if(NUM_CMP>=Consts::MAX_CMP) { err="too many components"; break; }
			else if(CMP[NUM_CMP].load(comps)) { ++NUM_CMP; }
			else { err="cannot read component description"; break; }
		}
		else if(buf=="REACTION:")
		{
			if(NUM_RXN>=Consts::MAX_RXN) { err="too many reactions"; break; }
			else if(RXN[NUM_RXN].load(comps)) { ++NUM_RXN; }
			else { err="cannot read reaction description"; break; }
		}
		else if(buf=="MIXTURES")
		{
			MIXload=MIX.load(comps);
			if(!MIXload) { err="cannot read description of mixtures"; break; }
		}
	}
	
	for(int r=0; r<NUM_RXN; r++)
	{
		RXN[r].asign_indx_r(1,-1); RXN[r].asign_indx_r(2,-1);
		RXN[r].asign_indx_p(1,-1); RXN[r].asign_indx_p(2,-1);
		
		for(int c=0; c<NUM_CMP; c++)
		{
			if(RXN[r].name_r(1)==CMP[c].name()) { RXN[r].asign_indx_r(1,c); }
			if(RXN[r].name_r(2)==CMP[c].name()) { RXN[r].asign_indx_r(2,c); }
			if(RXN[r].name_p(1)==CMP[c].name()) { RXN[r].asign_indx_p(1,c); }
			if(RXN[r].name_p(2)==CMP[c].name()) { RXN[r].asign_indx_p(2,c); }
		}
	}
	
	if(!err.empty()) { throw loadErr(err); }
	else if(!NUM_CMP) { throw loadErr("no component description is found"); }
}

double Comps::volume(const Elem& E,bool buf_der)
{
	double T=E.massT[NUM_CMP];
	
	buf[activ].Svol=0.0; buf[activ].Lvol=0.0; double Gvol=0.0;
	
	if(buf_der)
	{
		double d_Svol_dT=0.0; double d_Lvol_dT=0.0; double d_Gvol_dT=0.0;
		
		for(int c=0; c<NUM_CMP; c++)
		{
			buf[activ].one_vs_dns[c]=1.0/CMP[c].dens(T);
			buf[activ].m_vs_dns[c]=buf[activ].one_vs_dns[c]*E.massT[c];
			buf[activ].d_m_vs_dns_dT[c]=-buf[activ].m_vs_dns[c]*buf[activ].one_vs_dns[c]*
				                         CMP[c].d_dens_dT(T);
			
			switch(CMP[c].state())
			{
				case 'S': d_Svol_dT+=buf[activ].d_m_vs_dns_dT[c];
					      buf[activ].Svol+=buf[activ].m_vs_dns[c]; break;
				case 'G': d_Gvol_dT+=buf[activ].d_m_vs_dns_dT[c];
					      Gvol+=buf[activ].m_vs_dns[c]; break;
				default: d_Lvol_dT+=buf[activ].d_m_vs_dns_dT[c];
					     buf[activ].Lvol+=buf[activ].m_vs_dns[c]; break;
			}
		}
		
		buf[activ].swl=MIX.swell(buf[activ].Svol,buf[activ].Lvol,Gvol);
		double d_swl_dSvol=MIX.d_swell_dSvol();
		double d_swl_dLvol=MIX.d_swell_dLvol();
		double d_swl_dGvol=MIX.d_swell_dGvol();
		
		for(int c=0; c<NUM_CMP; c++)
		{
			switch(CMP[c].state())
			{
				case 'S': buf[activ].d_swl_dm[c]=d_swl_dSvol*buf[activ].one_vs_dns[c];
					      buf[activ].d_vol_dm[c]=buf[activ].one_vs_dns[c]+
							                     buf[activ].d_swl_dm[c]*Gvol; break;
				case 'G': buf[activ].d_swl_dm[c]=d_swl_dGvol*buf[activ].one_vs_dns[c];
					      buf[activ].d_vol_dm[c]=buf[activ].swl*buf[activ].one_vs_dns[c]+
							                     buf[activ].d_swl_dm[c]*Gvol; break;
				default: buf[activ].d_swl_dm[c]=d_swl_dLvol*buf[activ].one_vs_dns[c];
					     buf[activ].d_vol_dm[c]=buf[activ].one_vs_dns[c]+
							                    buf[activ].d_swl_dm[c]*Gvol; break;
			}
		}
		
		buf[activ].d_swl_dT=d_swl_dSvol*d_Svol_dT+d_swl_dLvol*d_Lvol_dT+
			                d_swl_dGvol*d_Gvol_dT;
		buf[activ].d_vol_dT=d_Svol_dT+d_Lvol_dT+buf[activ].d_swl_dT*Gvol+
			                buf[activ].swl*d_Gvol_dT;
		buf[activ].vol=buf[activ].Svol+buf[activ].Lvol+buf[activ].swl*Gvol;
	}
	else
	{
		for(int c=0; c<NUM_CMP; c++)
		{
			buf[activ].one_vs_dns[c]=1.0/CMP[c].dens(T);
			buf[activ].m_vs_dns[c]=E.massT[c]*buf[activ].one_vs_dns[c];
			
			switch(CMP[c].state())
			{
				case 'S': buf[activ].Svol+=buf[activ].m_vs_dns[c]; break;
				case 'G': Gvol+=buf[activ].m_vs_dns[c]; break;
				default: buf[activ].Lvol+=buf[activ].m_vs_dns[c]; break;
			}
		}
		
		buf[activ].swl=MIX.swell(buf[activ].Svol,buf[activ].Lvol,Gvol);
		buf[activ].vol=buf[activ].Svol+buf[activ].Lvol+buf[activ].swl*Gvol;
	}
	
	return buf[activ].vol;
}

char Comps::state(double vol_fr_threshold)
{
	double Svol_fr=buf[activ].Svol/buf[activ].vol;
	double Lvol_fr=buf[activ].Lvol/buf[activ].vol;
	double Gvol_fr=1.0-Svol_fr-Lvol_fr;
	
	if(Gvol_fr>Lvol_fr)
	{
		if(Gvol_fr>Svol_fr)
		{
			if(Gvol_fr>vol_fr_threshold) { return 'G'; } else { return 'M'; }
		}
		else
		{
			if(Svol_fr>vol_fr_threshold) { return 'S'; } else { return 'M'; }
		}
	}
	else if(Svol_fr>Lvol_fr)
	{
		if(Svol_fr>vol_fr_threshold) { return 'S'; } else { return 'M'; }
	}
	else
	{
		if(Lvol_fr>vol_fr_threshold) { return 'L'; } else { return 'M'; }
	}
}

double Comps::heat_cap(const Elem& E,bool buf_der)
{
	double T=E.massT[NUM_CMP];
	
	buf[activ].hcap=0.0;
	
	if(buf_der)
	{
		buf[activ].d_hcap_dT=0.0;
		
		for(int c=0; c<NUM_CMP; c++)
		{
			buf[activ].d_hcap_dm[c]=CMP[c].hcap(T);
			buf[activ].hcap+=buf[activ].d_hcap_dm[c]*E.massT[c];
			buf[activ].d_hcap_dT+=CMP[c].d_hcap_dT(T)*E.massT[c];
		}
	}
	else
	{
		for(int c=0; c<NUM_CMP; c++)
		{
			buf[activ].d_hcap_dm[c]=CMP[c].hcap(T);
			buf[activ].hcap+=buf[activ].d_hcap_dm[c]*E.massT[c];
		}
	}
	
	return buf[activ].hcap;
}

double Comps::therm_cond(const Elem& E,bool buf_der)
{
	double T=E.massT[NUM_CMP];
	
	if(buf_der)
	{
		double ccnd[Consts::MAX_CMP];
		double pcnd=0.0; double scnd; double tscnd=0.0;
		double d_pcnd_dT=0.0; double d_scnd_dT=0.0;
		double Gpcnd=0.0; double Gscnd=0.0;
		double d_Gpcnd_dT=0.0; double d_Gscnd_dT=0.0;
		
		double d_ccnd_dT;
		for(int c=0; c<NUM_CMP; c++)
		{
			ccnd[c]=CMP[c].cond(T);
			d_ccnd_dT=CMP[c].d_cond_dT(T);
			
			if(CMP[c].state()!='G')
			{
				pcnd+=buf[activ].m_vs_dns[c]*ccnd[c];
				scnd=buf[activ].m_vs_dns[c]/ccnd[c]; tscnd+=scnd;
				d_pcnd_dT+=buf[activ].d_m_vs_dns_dT[c]*ccnd[c]+
					       buf[activ].m_vs_dns[c]*d_ccnd_dT;
				d_scnd_dT+=(buf[activ].d_m_vs_dns_dT[c]-scnd*d_ccnd_dT)/ccnd[c];
			}
			else
			{
				Gpcnd+=buf[activ].m_vs_dns[c]*ccnd[c];
				scnd=buf[activ].m_vs_dns[c]/ccnd[c]; Gscnd+=scnd;
				d_Gpcnd_dT+=buf[activ].d_m_vs_dns_dT[c]*ccnd[c]+
					        buf[activ].m_vs_dns[c]*d_ccnd_dT;
				d_Gscnd_dT+=(buf[activ].d_m_vs_dns_dT[c]-scnd*d_ccnd_dT)/ccnd[c];
			}
		}
		
		pcnd+=buf[activ].swl*Gpcnd; pcnd/=buf[activ].vol;
		tscnd+=buf[activ].swl*Gscnd; scnd=buf[activ].vol/tscnd;
		buf[activ].cond=MIX.par_cond()*pcnd+MIX.ser_cond()*scnd;
		
		double MIXpar_vs_vol=MIX.par_cond()/buf[activ].vol;
		double MIXser_vs_tscnd=MIX.ser_cond()/tscnd;
		double vs_dns;
		for(int c=0; c<NUM_CMP; c++)
		{
			if(CMP[c].state()!='G') { vs_dns=buf[activ].one_vs_dns[c]; }
			else { vs_dns=buf[activ].one_vs_dns[c]*buf[activ].swl; }
			
			buf[activ].d_cond_dm[c]=MIXpar_vs_vol*(buf[activ].d_swl_dm[c]*Gpcnd-
				                    buf[activ].d_vol_dm[c]*pcnd+vs_dns*ccnd[c])+
									MIXser_vs_tscnd*(buf[activ].d_vol_dm[c]-
									scnd*(buf[activ].d_swl_dm[c]*Gscnd+vs_dns/ccnd[c]));
		}
		buf[activ].d_cond_dT=MIXpar_vs_vol*(d_pcnd_dT-buf[activ].d_vol_dT*pcnd+
			                 buf[activ].d_swl_dT*Gpcnd+buf[activ].swl*d_Gpcnd_dT)+
							 MIXser_vs_tscnd*(buf[activ].d_vol_dT-scnd*(d_scnd_dT+
							 buf[activ].d_swl_dT*Gscnd+buf[activ].swl*d_Gscnd_dT));
	}
	else
	{
		double pcnd=0.0; double scnd=0.0;
		double Gpcnd=0.0; double Gscnd=0.0;
		
		double ccnd;
		for(int c=0; c<NUM_CMP; c++)
		{
			ccnd=CMP[c].cond(T);
			
			if(CMP[c].state()!='G')
			{
				pcnd+=buf[activ].m_vs_dns[c]*ccnd;
				scnd+=buf[activ].m_vs_dns[c]/ccnd;
			}
			else
			{
				Gpcnd+=buf[activ].m_vs_dns[c]*ccnd;
				Gscnd+=buf[activ].m_vs_dns[c]/ccnd;
			}
		}
		
		buf[activ].cond=MIX.par_cond()*(pcnd+buf[activ].swl*Gpcnd)/buf[activ].vol+
			            MIX.ser_cond()*buf[activ].vol/(scnd+buf[activ].swl*Gscnd);
	}
	
	return buf[activ].cond;
}

double Comps::gas_transp(const Elem& E,bool buf_der)
{
	double T=E.massT[NUM_CMP];
	
	if(buf_der)
	{
		double ctrn[Consts::MAX_CMP];
		double ptrn=0.0; double strn; double tstrn=0.0;
		double d_ptrn_dT=0.0; double d_strn_dT=0.0;
		double Gptrn=0.0; double Gstrn=0.0;
		double d_Gptrn_dT=0.0; double d_Gstrn_dT=0.0;
		
		double d_ctrn_dT;
		for(int c=0; c<NUM_CMP; c++)
		{
			ctrn[c]=CMP[c].trns(T);
			d_ctrn_dT=CMP[c].d_trns_dT(T);
			
			if(CMP[c].state()!='G')
			{
				ptrn+=buf[activ].m_vs_dns[c]*ctrn[c];
				strn=buf[activ].m_vs_dns[c]/ctrn[c]; tstrn+=strn;
				d_ptrn_dT+=buf[activ].d_m_vs_dns_dT[c]*ctrn[c]+
					       buf[activ].m_vs_dns[c]*d_ctrn_dT;
				d_strn_dT+=(buf[activ].d_m_vs_dns_dT[c]-strn*d_ctrn_dT)/ctrn[c];
			}
			else
			{
				Gptrn+=buf[activ].m_vs_dns[c]*ctrn[c];
				strn=buf[activ].m_vs_dns[c]/ctrn[c]; Gstrn+=strn;
				d_Gptrn_dT+=buf[activ].d_m_vs_dns_dT[c]*ctrn[c]+
					        buf[activ].m_vs_dns[c]*d_ctrn_dT;
				d_Gstrn_dT+=(buf[activ].d_m_vs_dns_dT[c]-strn*d_ctrn_dT)/ctrn[c];
			}
		}
		
		ptrn+=buf[activ].swl*Gptrn; ptrn/=buf[activ].vol;
		tstrn+=buf[activ].swl*Gstrn; strn=buf[activ].vol/tstrn;
		buf[activ].trns=MIX.par_trns()*ptrn+MIX.ser_trns()*strn;
		
		double MIXpar_vs_vol=MIX.par_trns()/buf[activ].vol;
		double MIXser_vs_tstrn=MIX.ser_trns()/tstrn;
		double vs_dns;
		for(int c=0; c<NUM_CMP; c++)
		{
			if(CMP[c].state()!='G') { vs_dns=buf[activ].one_vs_dns[c]; }
			else { vs_dns=buf[activ].one_vs_dns[c]*buf[activ].swl; }
			
			buf[activ].d_trns_dm[c]=MIXpar_vs_vol*(buf[activ].d_swl_dm[c]*Gptrn-
				                    buf[activ].d_vol_dm[c]*ptrn+vs_dns*ctrn[c])+
									MIXser_vs_tstrn*(buf[activ].d_vol_dm[c]-
									strn*(buf[activ].d_swl_dm[c]*Gstrn+vs_dns/ctrn[c]));
		}
		buf[activ].d_trns_dT=MIXpar_vs_vol*(d_ptrn_dT-buf[activ].d_vol_dT*ptrn+
			                 buf[activ].d_swl_dT*Gptrn+buf[activ].swl*d_Gptrn_dT)+
							 MIXser_vs_tstrn*(buf[activ].d_vol_dT-strn*(d_strn_dT+
							 buf[activ].d_swl_dT*Gstrn+buf[activ].swl*d_Gstrn_dT));
	}
	else
	{
		double ptrn=0.0; double strn=0.0;
		double Gptrn=0.0; double Gstrn=0.0;
		
		double ctrn;
		for(int c=0; c<NUM_CMP; c++)
		{
			ctrn=CMP[c].trns(T);
			
			if(CMP[c].state()!='G')
			{
				ptrn+=buf[activ].m_vs_dns[c]*ctrn;
				strn+=buf[activ].m_vs_dns[c]/ctrn;
			}
			else
			{
				Gptrn+=buf[activ].m_vs_dns[c]*ctrn;
				Gstrn+=buf[activ].m_vs_dns[c]/ctrn;
			}
		}
		
		buf[activ].trns=MIX.par_trns()*(ptrn+buf[activ].swl*Gptrn)/buf[activ].vol+
			            MIX.ser_trns()*buf[activ].vol/(strn+buf[activ].swl*Gstrn);
	}
	
	return buf[activ].trns;
}

double Comps::emissivity()
{
	double ems=0.0;
	double Gems=0.0;
	
	for(int c=0; c<NUM_CMP; c++)
	{
		if(CMP[c].state()!='G') { ems+=CMP[c].emis()*buf[activ].m_vs_dns[c]; }
		else { Gems+=CMP[c].emis()*buf[activ].m_vs_dns[c]; }
	}
	
	return ((ems+Gems*buf[activ].swl)/buf[activ].vol);
}

double Comps::absorption(const Elem& E)
{
	double abs=0.0;
	for(int c=0; c<NUM_CMP; c++) { abs+=CMP[c].absr()*E.massT[c]; }
	
	return abs;
}

void Comps::export_buf(Elem& E)
{
	for(int c=0; c<NUM_CMP; c++)
	{
		E.properts->one_vs_dns[c]=buf[activ].one_vs_dns[c];
		E.properts->m_vs_dns[c]=buf[activ].m_vs_dns[c];
		E.properts->d_m_vs_dns_dT[c]=buf[activ].d_m_vs_dns_dT[c];
		E.properts->d_swl_dm[c]=buf[activ].d_swl_dm[c];
		E.properts->d_vol_dm[c]=buf[activ].d_vol_dm[c];
		E.properts->d_hcap_dm[c]=buf[activ].d_hcap_dm[c];
		E.properts->d_cond_dm[c]=buf[activ].d_cond_dm[c];
		E.properts->d_trns_dm[c]=buf[activ].d_trns_dm[c];
	}
	E.properts->Svol=buf[activ].Svol;
	E.properts->Lvol=buf[activ].Lvol;
	E.properts->swl=buf[activ].swl;
	E.properts->d_swl_dT=buf[activ].d_swl_dT;
	E.properts->vol=buf[activ].vol;
	E.properts->d_vol_dT=buf[activ].d_vol_dT;
	E.properts->hcap=buf[activ].hcap;
	E.properts->d_hcap_dT=buf[activ].d_hcap_dT;
	E.properts->cond=buf[activ].cond;
	E.properts->d_cond_dT=buf[activ].d_cond_dT;
	E.properts->trns=buf[activ].trns;
	E.properts->d_trns_dT=buf[activ].d_trns_dT;
}

void Comps::import_buf(const Elem& E)
{
	for(int c=0; c<NUM_CMP; c++)
	{
		buf[activ].one_vs_dns[c]=E.properts->one_vs_dns[c];
		buf[activ].m_vs_dns[c]=E.properts->m_vs_dns[c];
		buf[activ].d_m_vs_dns_dT[c]=E.properts->d_m_vs_dns_dT[c];
		buf[activ].d_swl_dm[c]=E.properts->d_swl_dm[c];
		buf[activ].d_vol_dm[c]=E.properts->d_vol_dm[c];
		buf[activ].d_hcap_dm[c]=E.properts->d_hcap_dm[c];
		buf[activ].d_cond_dm[c]=E.properts->d_cond_dm[c];
		buf[activ].d_trns_dm[c]=E.properts->d_trns_dm[c];
	}
	buf[activ].Svol=E.properts->Svol;
	buf[activ].Lvol=E.properts->Lvol;
	buf[activ].swl=E.properts->swl;
	buf[activ].d_swl_dT=E.properts->d_swl_dT;
	buf[activ].vol=E.properts->vol;
	buf[activ].d_vol_dT=E.properts->d_vol_dT;
	buf[activ].hcap=E.properts->hcap;
	buf[activ].d_hcap_dT=E.properts->d_hcap_dT;
	buf[activ].cond=E.properts->cond;
	buf[activ].d_cond_dT=E.properts->d_cond_dT;
	buf[activ].trns=E.properts->trns;
	buf[activ].d_trns_dT=E.properts->d_trns_dT;
}

void Comps::reactions_rates(Elem& E,bool calc_der)
{
	double T=E.massT[NUM_CMP];
	int r1, r2, p1, p2;
	
	if(calc_der)
	{
		double k, rt, d_rt_dT, ht;
		for(int x=0; x<NUM_RXN; x++)
		{
			if(RXN[x].on(T))
			{
				r1=RXN[x].indx_r(1); r2=RXN[x].indx_r(2);
				p1=RXN[x].indx_p(1); p2=RXN[x].indx_p(2);
				
				if((r1>=0)&&(r2>=0))
				{
					k=RXN[x].k(T);
					double k_vs_vol=k/buf[activ].vol;
					double mass_mass=E.massT[r1]*E.massT[r2];
					rt=k_vs_vol*mass_mass;
					double rt_vs_vol=rt/buf[activ].vol;
					d_rt_dT=RXN[x].d_k_dT(k,T)*mass_mass/buf[activ].vol-
						                   buf[activ].d_vol_dT*rt_vs_vol;
					ht=RXN[x].heat(T);
					
					E.massT_rate[r1].rt0-=RXN[x].stoich_r(1)*rt;
					E.massT_rate[r1].thisElem[NUM_CMP]-=RXN[x].stoich_r(1)*d_rt_dT;
					E.massT_rate[r2].rt0-=RXN[x].stoich_r(2)*rt;
					E.massT_rate[r2].thisElem[NUM_CMP]-=RXN[x].stoich_r(2)*d_rt_dT;
					if(p1>=0)
					{
						E.massT_rate[p1].rt0+=RXN[x].stoich_p(1)*rt;
						E.massT_rate[p1].thisElem[NUM_CMP]+=RXN[x].stoich_p(1)*d_rt_dT;
					}
					if(p2>=0)
					{
						E.massT_rate[p2].rt0+=RXN[x].stoich_p(2)*rt;
						E.massT_rate[p2].thisElem[NUM_CMP]+=RXN[x].stoich_p(2)*d_rt_dT;
					}
					E.massT_rate[NUM_CMP].rt0+=ht*rt;
					E.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=ht*d_rt_dT+
						                                     RXN[x].d_heat_dT(T)*rt;
					
					double d_rt_dm;
					for(int c=0; c<NUM_CMP; c++)
					{
						d_rt_dm=-buf[activ].d_vol_dm[c]*rt_vs_vol;
						if(c==r1) { d_rt_dm+=k_vs_vol*E.massT[r2]; }
						if(c==r2) { d_rt_dm+=k_vs_vol*E.massT[r1]; }
						
						E.massT_rate[r1].thisElem[c]-=RXN[x].stoich_r(1)*d_rt_dm;
						E.massT_rate[r2].thisElem[c]-=RXN[x].stoich_r(2)*d_rt_dm;
						if(p1>=0)
						{
							E.massT_rate[p1].thisElem[c]+=RXN[x].stoich_p(1)*d_rt_dm;
						}
						if(p2>=0)
						{
							E.massT_rate[p2].thisElem[c]+=RXN[x].stoich_p(2)*d_rt_dm;
						}
						E.massT_rate[NUM_CMP].thisElem[c]+=ht*d_rt_dm;
					}
				}
				else if(r1>=0)
				{
					k=RXN[x].k(T);
					rt=k*E.massT[r1];
					d_rt_dT=RXN[x].d_k_dT(k,T)*E.massT[r1];
					ht=RXN[x].heat(T);
					
					E.massT_rate[r1].rt0-=RXN[x].stoich_r(1)*rt;
					E.massT_rate[r1].thisElem[r1]-=RXN[x].stoich_r(1)*k;
					E.massT_rate[r1].thisElem[NUM_CMP]-=RXN[x].stoich_r(1)*d_rt_dT;
					if(p1>=0)
					{
						E.massT_rate[p1].rt0+=RXN[x].stoich_p(1)*rt;
						E.massT_rate[p1].thisElem[r1]+=RXN[x].stoich_p(1)*k;
						E.massT_rate[p1].thisElem[NUM_CMP]+=RXN[x].stoich_p(1)*d_rt_dT;
					}
					if(p2>=0)
					{
						E.massT_rate[p2].rt0+=RXN[x].stoich_p(2)*rt;
						E.massT_rate[p2].thisElem[r1]+=RXN[x].stoich_p(2)*k;
						E.massT_rate[p2].thisElem[NUM_CMP]+=RXN[x].stoich_p(2)*d_rt_dT;
					}
					E.massT_rate[NUM_CMP].rt0+=ht*rt;
					E.massT_rate[NUM_CMP].thisElem[r1]+=ht*k;
					E.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=ht*d_rt_dT+
						                                     RXN[x].d_heat_dT(T)*rt;
				}
				else if(r2>=0)
				{
					k=RXN[x].k(T);
					rt=k*E.massT[r2];
					d_rt_dT=RXN[x].d_k_dT(k,T)*E.massT[r2];
					ht=RXN[x].heat(T);
					
					E.massT_rate[r2].rt0-=RXN[x].stoich_r(2)*rt;
					E.massT_rate[r2].thisElem[r2]-=RXN[x].stoich_r(2)*k;
					E.massT_rate[r2].thisElem[NUM_CMP]-=RXN[x].stoich_r(2)*d_rt_dT;
					if(p1>=0)
					{
						E.massT_rate[p1].rt0+=RXN[x].stoich_p(1)*rt;
						E.massT_rate[p1].thisElem[r2]+=RXN[x].stoich_p(1)*k;
						E.massT_rate[p1].thisElem[NUM_CMP]+=RXN[x].stoich_p(1)*d_rt_dT;
					}
					if(p2>=0)
					{
						E.massT_rate[p2].rt0+=RXN[x].stoich_p(2)*rt;
						E.massT_rate[p2].thisElem[r2]+=RXN[x].stoich_p(2)*k;
						E.massT_rate[p2].thisElem[NUM_CMP]+=RXN[x].stoich_p(2)*d_rt_dT;
					}
					E.massT_rate[NUM_CMP].rt0+=ht*rt;
					E.massT_rate[NUM_CMP].thisElem[r2]+=ht*k;
					E.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=ht*d_rt_dT+
						                                     RXN[x].d_heat_dT(T)*rt;
				}
			}
		}
	}
	else
	{
		double rt;
		for(int x=0; x<NUM_RXN; x++)
		{
			if(RXN[x].on(T))
			{
				r1=RXN[x].indx_r(1); r2=RXN[x].indx_r(2);
				p1=RXN[x].indx_p(1); p2=RXN[x].indx_p(2);
				
				if((r1>=0)&&(r2>=0))
				{
					rt=RXN[x].k(T)*E.massT[r1]*E.massT[r2]/buf[activ].vol;
					
					E.massT_rate[r1].rt0-=RXN[x].stoich_r(1)*rt;
					E.massT_rate[r2].rt0-=RXN[x].stoich_r(2)*rt;
					if(p1>=0) { E.massT_rate[p1].rt0+=RXN[x].stoich_p(1)*rt; }
					if(p2>=0) { E.massT_rate[p2].rt0+=RXN[x].stoich_p(2)*rt; }
					E.massT_rate[NUM_CMP].rt0+=RXN[x].heat(T)*rt;
				}
				else if(r1>=0)
				{
					rt=RXN[x].k(T)*E.massT[r1];
					
					E.massT_rate[r1].rt0-=RXN[x].stoich_r(1)*rt;
					if(p1>=0) { E.massT_rate[p1].rt0+=RXN[x].stoich_p(1)*rt; }
					if(p2>=0) { E.massT_rate[p2].rt0+=RXN[x].stoich_p(2)*rt; }
					E.massT_rate[NUM_CMP].rt0+=RXN[x].heat(T)*rt;
				}
				else if(r2>=0)
				{
					rt=RXN[x].k(T)*E.massT[r2];
					
					E.massT_rate[r2].rt0-=RXN[x].stoich_r(2)*rt;
					if(p1>=0) { E.massT_rate[p1].rt0+=RXN[x].stoich_p(1)*rt; }
					if(p2>=0) { E.massT_rate[p2].rt0+=RXN[x].stoich_p(2)*rt; }
					E.massT_rate[NUM_CMP].rt0+=RXN[x].heat(T)*rt;
				}
			}
		}
	}
}

void Comps::conduction_rates(Elem& Eplus,Elem& Eminus,char comm_axis,char expans_axis,
							 bool calc_der)
{
	if(calc_der)
	{
		if(comm_axis==expans_axis)
		{
			switch(comm_axis)
			{
			case 'X':
				{
					double dim_cond_pls=Eplus.Xdim/buf[activ].cond;
					double dim_cond_mns=Eminus.Xdim/buf[inactiv].cond;
					double dim_cond=dim_cond_pls+dim_cond_mns;
					double heat_vs_dT=(buf[activ].vol/Eplus.Xdim+
						               buf[inactiv].vol/Eminus.Xdim)/dim_cond;
					double heat=heat_vs_dT*(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP]);
					Eplus.massT_rate[NUM_CMP].rt0+=heat;
					Eminus.massT_rate[NUM_CMP].rt0-=heat;
					
					dim_cond_pls*=heat/dim_cond;
					dim_cond_mns*=heat/dim_cond;
					double ht_dm_cnd_cnd_pls=dim_cond_pls/buf[activ].cond;
					double ht_dm_cnd_vol_pls=dim_cond_pls/buf[activ].vol;
					double ht_dm_cnd_cnd_mns=dim_cond_mns/buf[inactiv].cond;
					double ht_dm_cnd_vol_mns=dim_cond_mns/buf[inactiv].vol;
					double d_heat;
					for(int c=0; c<NUM_CMP; c++)
					{
						d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dm[c]-
							   ht_dm_cnd_vol_pls*buf[activ].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].XplusElem[c]-=d_heat;
						
						d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dm[c]-
							   ht_dm_cnd_vol_mns*buf[inactiv].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].XminusElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].thisElem[c]-=d_heat;
					}
					
					d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dT-
						   ht_dm_cnd_vol_pls*buf[activ].d_vol_dT-heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].XplusElem[NUM_CMP]-=d_heat;
					
					d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dT-
						   ht_dm_cnd_vol_mns*buf[inactiv].d_vol_dT+heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].XminusElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]-=d_heat;
				}
				break;
			case 'Y':
				{
					double dim_cond_pls=Eplus.Ydim/buf[activ].cond;
					double dim_cond_mns=Eminus.Ydim/buf[inactiv].cond;
					double dim_cond=dim_cond_pls+dim_cond_mns;
					double heat_vs_dT=(buf[activ].vol/Eplus.Ydim+
						               buf[inactiv].vol/Eminus.Ydim)/dim_cond;
					double heat=heat_vs_dT*(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP]);
					Eplus.massT_rate[NUM_CMP].rt0+=heat;
					Eminus.massT_rate[NUM_CMP].rt0-=heat;
					
					dim_cond_pls*=heat/dim_cond;
					dim_cond_mns*=heat/dim_cond;
					double ht_dm_cnd_cnd_pls=dim_cond_pls/buf[activ].cond;
					double ht_dm_cnd_vol_pls=dim_cond_pls/buf[activ].vol;
					double ht_dm_cnd_cnd_mns=dim_cond_mns/buf[inactiv].cond;
					double ht_dm_cnd_vol_mns=dim_cond_mns/buf[inactiv].vol;
					double d_heat;
					for(int c=0; c<NUM_CMP; c++)
					{
						d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dm[c]-
							   ht_dm_cnd_vol_pls*buf[activ].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].YplusElem[c]-=d_heat;
						
						d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dm[c]-
							   ht_dm_cnd_vol_mns*buf[inactiv].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].YminusElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].thisElem[c]-=d_heat;
					}
					
					d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dT-
						   ht_dm_cnd_vol_pls*buf[activ].d_vol_dT-heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].YplusElem[NUM_CMP]-=d_heat;
					
					d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dT-
						   ht_dm_cnd_vol_mns*buf[inactiv].d_vol_dT+heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].YminusElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]-=d_heat;
				}
				break;
			case 'Z':
				{
					double dim_cond_pls=Eplus.Zdim/buf[activ].cond;
					double dim_cond_mns=Eminus.Zdim/buf[inactiv].cond;
					double dim_cond=dim_cond_pls+dim_cond_mns;
					double heat_vs_dT=(buf[activ].vol/Eplus.Zdim+
						               buf[inactiv].vol/Eminus.Zdim)/dim_cond;
					double heat=heat_vs_dT*(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP]);
					Eplus.massT_rate[NUM_CMP].rt0+=heat;
					Eminus.massT_rate[NUM_CMP].rt0-=heat;
					
					dim_cond_pls*=heat/dim_cond;
					dim_cond_mns*=heat/dim_cond;
					double ht_dm_cnd_cnd_pls=dim_cond_pls/buf[activ].cond;
					double ht_dm_cnd_vol_pls=dim_cond_pls/buf[activ].vol;
					double ht_dm_cnd_cnd_mns=dim_cond_mns/buf[inactiv].cond;
					double ht_dm_cnd_vol_mns=dim_cond_mns/buf[inactiv].vol;
					double d_heat;
					for(int c=0; c<NUM_CMP; c++)
					{
						d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dm[c]-
							   ht_dm_cnd_vol_pls*buf[activ].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].ZplusElem[c]-=d_heat;
						
						d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dm[c]-
							   ht_dm_cnd_vol_mns*buf[inactiv].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].ZminusElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].thisElem[c]-=d_heat;
					}
					
					d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dT-
						   ht_dm_cnd_vol_pls*buf[activ].d_vol_dT-heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].ZplusElem[NUM_CMP]-=d_heat;
					
					d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dT-
						   ht_dm_cnd_vol_mns*buf[inactiv].d_vol_dT+heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].ZminusElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]-=d_heat;
				}
			}
		}
		else
		{
			switch(comm_axis)
			{
			case 'X':
				{
					double dT=Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP];
					double dim_cond_pls=Eplus.Xdim/buf[activ].cond;
					double dim_cond_mns=Eminus.Xdim/buf[inactiv].cond;
					double heat_vs_area2=dT/(dim_cond_pls+dim_cond_mns);
					double heat=heat_vs_area2*(buf[activ].vol/Eplus.Xdim+
						                       buf[inactiv].vol/Eminus.Xdim);
					Eplus.massT_rate[NUM_CMP].rt0+=heat;
					Eminus.massT_rate[NUM_CMP].rt0-=heat;
					
					double heat_vs_dT=heat/dT;
					double heat_vs_dm_cnd=heat_vs_area2*heat_vs_dT;
					double ht_dm_cnd_cnd_pls=heat_vs_dm_cnd*dim_cond_pls/buf[activ].cond;
					double ht_ar_dm_pls=heat_vs_area2/Eplus.Xdim;
					double ht_dm_cnd_cnd_mns=heat_vs_dm_cnd*dim_cond_mns/buf[inactiv].cond;
					double ht_ar_dm_mns=heat_vs_area2/Eminus.Xdim;
					double d_heat;
					for(int c=0; c<NUM_CMP; c++)
					{
						d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dm[c]+
							   ht_ar_dm_pls*buf[activ].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].XplusElem[c]-=d_heat;
						
						d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dm[c]+
							   ht_ar_dm_mns*buf[inactiv].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].XminusElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].thisElem[c]-=d_heat;
					}
					
					d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dT+
						   ht_ar_dm_pls*buf[activ].d_vol_dT-heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].XplusElem[NUM_CMP]-=d_heat;
					
					d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dT+
						   ht_ar_dm_mns*buf[inactiv].d_vol_dT+heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].XminusElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]-=d_heat;
				}
				break;
			case 'Y':
				{
					double dT=Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP];
					double dim_cond_pls=Eplus.Ydim/buf[activ].cond;
					double dim_cond_mns=Eminus.Ydim/buf[inactiv].cond;
					double heat_vs_area2=dT/(dim_cond_pls+dim_cond_mns);
					double heat=heat_vs_area2*(buf[activ].vol/Eplus.Ydim+
						                       buf[inactiv].vol/Eminus.Ydim);
					Eplus.massT_rate[NUM_CMP].rt0+=heat;
					Eminus.massT_rate[NUM_CMP].rt0-=heat;
					
					double heat_vs_dT=heat/dT;
					double heat_vs_dm_cnd=heat_vs_area2*heat_vs_dT;
					double ht_dm_cnd_cnd_pls=heat_vs_dm_cnd*dim_cond_pls/buf[activ].cond;
					double ht_ar_dm_pls=heat_vs_area2/Eplus.Ydim;
					double ht_dm_cnd_cnd_mns=heat_vs_dm_cnd*dim_cond_mns/buf[inactiv].cond;
					double ht_ar_dm_mns=heat_vs_area2/Eminus.Ydim;
					double d_heat;
					for(int c=0; c<NUM_CMP; c++)
					{
						d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dm[c]+
							   ht_ar_dm_pls*buf[activ].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].YplusElem[c]-=d_heat;
						
						d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dm[c]+
							   ht_ar_dm_mns*buf[inactiv].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].YminusElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].thisElem[c]-=d_heat;
					}
					
					d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dT+
						   ht_ar_dm_pls*buf[activ].d_vol_dT-heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].YplusElem[NUM_CMP]-=d_heat;
					
					d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dT+
						   ht_ar_dm_mns*buf[inactiv].d_vol_dT+heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].YminusElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]-=d_heat;
				}
				break;
			case 'Z':
				{
					double dT=Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP];
					double dim_cond_pls=Eplus.Zdim/buf[activ].cond;
					double dim_cond_mns=Eminus.Zdim/buf[inactiv].cond;
					double heat_vs_area2=dT/(dim_cond_pls+dim_cond_mns);
					double heat=heat_vs_area2*(buf[activ].vol/Eplus.Zdim+
						                       buf[inactiv].vol/Eminus.Zdim);
					Eplus.massT_rate[NUM_CMP].rt0+=heat;
					Eminus.massT_rate[NUM_CMP].rt0-=heat;
					
					double heat_vs_dT=heat/dT;
					double heat_vs_dm_cnd=heat_vs_area2*heat_vs_dT;
					double ht_dm_cnd_cnd_pls=heat_vs_dm_cnd*dim_cond_pls/buf[activ].cond;
					double ht_ar_dm_pls=heat_vs_area2/Eplus.Zdim;
					double ht_dm_cnd_cnd_mns=heat_vs_dm_cnd*dim_cond_mns/buf[inactiv].cond;
					double ht_ar_dm_mns=heat_vs_area2/Eminus.Zdim;
					double d_heat;
					for(int c=0; c<NUM_CMP; c++)
					{
						d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dm[c]+
							   ht_ar_dm_pls*buf[activ].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].ZplusElem[c]-=d_heat;
						
						d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dm[c]+
							   ht_ar_dm_mns*buf[inactiv].d_vol_dm[c];
						Eplus.massT_rate[NUM_CMP].ZminusElem[c]+=d_heat;
						Eminus.massT_rate[NUM_CMP].thisElem[c]-=d_heat;
					}
					
					d_heat=ht_dm_cnd_cnd_pls*buf[activ].d_cond_dT+
						   ht_ar_dm_pls*buf[activ].d_vol_dT-heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].ZplusElem[NUM_CMP]-=d_heat;
					
					d_heat=ht_dm_cnd_cnd_mns*buf[inactiv].d_cond_dT+
						   ht_ar_dm_mns*buf[inactiv].d_vol_dT+heat_vs_dT;
					Eplus.massT_rate[NUM_CMP].ZminusElem[NUM_CMP]+=d_heat;
					Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]-=d_heat;
				}
			}
		}
	}
	else
	{
		switch(comm_axis)
		{
		case 'X':
			{
				double heat=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])*
					        (buf[activ].vol/Eplus.Xdim+buf[inactiv].vol/Eminus.Xdim)/
							(Eplus.Xdim/buf[activ].cond+Eminus.Xdim/buf[inactiv].cond);
				Eplus.massT_rate[NUM_CMP].rt0+=heat;
				Eminus.massT_rate[NUM_CMP].rt0-=heat;
			}
			break;
		case 'Y':
			{
				double heat=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])*
					        (buf[activ].vol/Eplus.Ydim+buf[inactiv].vol/Eminus.Ydim)/
							(Eplus.Ydim/buf[activ].cond+Eminus.Ydim/buf[inactiv].cond);
				Eplus.massT_rate[NUM_CMP].rt0+=heat;
				Eminus.massT_rate[NUM_CMP].rt0-=heat;
			}
			break;
		case 'Z':
			{
				double heat=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])*
					        (buf[activ].vol/Eplus.Zdim+buf[inactiv].vol/Eminus.Zdim)/
							(Eplus.Zdim/buf[activ].cond+Eminus.Zdim/buf[inactiv].cond);
				Eplus.massT_rate[NUM_CMP].rt0+=heat;
				Eminus.massT_rate[NUM_CMP].rt0-=heat;
			}
		}
	}
}

void Comps::gas_transp_rates(Elem& Eplus,Elem& Eminus,char comm_axis,char expans_axis,
							 bool calc_der)
{
	if(calc_der)
	{
		if(comm_axis==expans_axis)
		{
			switch(comm_axis)
			{
			case 'X':
				{
					double dim_trns_pls=Eplus.Xdim/buf[activ].trns;
					double dim_trns_mns=Eminus.Xdim/buf[inactiv].trns;
					double dim_trns=dim_trns_pls+dim_trns_mns;
					double arr_vs_dim_trns=0.5*(buf[activ].vol/Eplus.Xdim+
						                        buf[inactiv].vol/Eminus.Xdim)/dim_trns;
					
					dim_trns_pls/=dim_trns;
					dim_trns_mns/=dim_trns;
					double dim_trns_trns_pls=dim_trns_pls/buf[activ].trns;
					double dim_trns_trns_mns=dim_trns_mns/buf[inactiv].trns;
					double dim_trns_vol_pls=dim_trns_pls/buf[activ].vol;
					double dim_trns_vol_mns=dim_trns_mns/buf[inactiv].vol;
					double d_dim_trns_pls_dm[Consts::MAX_CMP],
						   d_dim_trns_mns_dm[Consts::MAX_CMP];
					for(int c=0; c<NUM_CMP; c++)
					{
						d_dim_trns_pls_dm[c]=buf[activ].d_trns_dm[c]*dim_trns_trns_pls-
							                 buf[activ].d_vol_dm[c]*dim_trns_vol_pls;
						d_dim_trns_mns_dm[c]=buf[inactiv].d_trns_dm[c]*dim_trns_trns_mns-
							                 buf[inactiv].d_vol_dm[c]*dim_trns_vol_mns;
					}
					double d_dim_trns_pls_dT=buf[activ].d_trns_dT*dim_trns_trns_pls-
						                     buf[activ].d_vol_dT*dim_trns_vol_pls;
					double d_dim_trns_mns_dT=buf[inactiv].d_trns_dT*dim_trns_trns_mns-
						                     buf[inactiv].d_vol_dT*dim_trns_vol_mns;
					
					double dTvs4=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])/4.0;
					
					double g_frn_pls, g_frn_mns, g_frn_dlt, Jg_vs, Jg_vol_pls, Jg_vol_mns,
						   Jg_vol_frn_pls, Jg_vol_frn_mns, Jg, dHgvs2, Jg_heat, d_Jg_pls,
						   d_Jg_mns;
					for(int g=0; g<NUM_CMP; g++){
					if(CMP[g].state()=='G'){
						
						g_frn_pls=buf[activ].m_vs_dns[g]/buf[activ].vol;
						g_frn_mns=buf[inactiv].m_vs_dns[g]/buf[inactiv].vol;
						g_frn_dlt=g_frn_mns-g_frn_pls;
						Jg_vs=arr_vs_dim_trns/buf[activ].one_vs_dns[g]+
							  arr_vs_dim_trns/buf[inactiv].one_vs_dns[g];
						Jg_vol_pls=Jg_vs/buf[activ].vol;
						Jg_vol_mns=Jg_vs/buf[inactiv].vol;
						Jg_vol_frn_pls=Jg_vol_pls*g_frn_pls;
						Jg_vol_frn_mns=Jg_vol_mns*g_frn_mns;
						Jg=Jg_vs*g_frn_dlt;
						Eplus.massT_rate[g].rt0+=Jg;
						Eminus.massT_rate[g].rt0-=Jg;
						
						dHgvs2=(buf[activ].d_hcap_dm[g]+buf[inactiv].d_hcap_dm[g])*dTvs4;
						Jg_heat=Jg*dHgvs2;
						Eplus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						Eminus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						
						for(int c=0; c<NUM_CMP; c++)
						{
							d_Jg_pls=Jg*d_dim_trns_pls_dm[c]+
								     Jg_vol_frn_pls*buf[activ].d_vol_dm[c];
							d_Jg_mns=Jg*d_dim_trns_mns_dm[c]-
								     Jg_vol_frn_mns*buf[inactiv].d_vol_dm[c];
							if(c==g)
							{
								d_Jg_pls-=Jg_vol_pls*buf[activ].one_vs_dns[g];
								d_Jg_mns+=Jg_vol_mns*buf[inactiv].one_vs_dns[g];
							}
							Eplus.massT_rate[g].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[g].XminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[g].XplusElem[c]-=d_Jg_pls;
							Eminus.massT_rate[g].thisElem[c]-=d_Jg_mns;
							
							d_Jg_pls*=dHgvs2;
							d_Jg_mns*=dHgvs2;
							Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[NUM_CMP].XminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[NUM_CMP].XplusElem[c]+=d_Jg_pls;
							Eminus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_mns;
						}
						
						Jg_vs=arr_vs_dim_trns*g_frn_dlt;
						d_Jg_pls=Jg*d_dim_trns_pls_dT+
							     Jg_vol_frn_pls*buf[activ].d_vol_dT-
								 Jg_vol_pls*buf[activ].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eplus.massT[NUM_CMP]);
						d_Jg_mns=Jg*d_dim_trns_mns_dT-
							     Jg_vol_frn_mns*buf[inactiv].d_vol_dT+
								 Jg_vol_mns*buf[inactiv].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eminus.massT[NUM_CMP]);
						Eplus.massT_rate[g].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[g].XminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[g].XplusElem[NUM_CMP]-=d_Jg_pls;
						Eminus.massT_rate[g].thisElem[NUM_CMP]-=d_Jg_mns;
						
						Jg_vs=Jg/2.0;
						d_Jg_pls*=dHgvs2;
						d_Jg_mns*=dHgvs2;
						d_Jg_pls-=Jg_vs*buf[activ].d_hcap_dm[g];
						d_Jg_mns+=Jg_vs*buf[inactiv].d_hcap_dm[g];
						Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[NUM_CMP].XminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[NUM_CMP].XplusElem[NUM_CMP]+=d_Jg_pls;
						Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_mns;
					}}
				}
				break;
			case 'Y':
				{
					double dim_trns_pls=Eplus.Ydim/buf[activ].trns;
					double dim_trns_mns=Eminus.Ydim/buf[inactiv].trns;
					double dim_trns=dim_trns_pls+dim_trns_mns;
					double arr_vs_dim_trns=0.5*(buf[activ].vol/Eplus.Ydim+
						                        buf[inactiv].vol/Eminus.Ydim)/dim_trns;
					
					dim_trns_pls/=dim_trns;
					dim_trns_mns/=dim_trns;
					double dim_trns_trns_pls=dim_trns_pls/buf[activ].trns;
					double dim_trns_trns_mns=dim_trns_mns/buf[inactiv].trns;
					double dim_trns_vol_pls=dim_trns_pls/buf[activ].vol;
					double dim_trns_vol_mns=dim_trns_mns/buf[inactiv].vol;
					double d_dim_trns_pls_dm[Consts::MAX_CMP],
						   d_dim_trns_mns_dm[Consts::MAX_CMP];
					for(int c=0; c<NUM_CMP; c++)
					{
						d_dim_trns_pls_dm[c]=buf[activ].d_trns_dm[c]*dim_trns_trns_pls-
							                 buf[activ].d_vol_dm[c]*dim_trns_vol_pls;
						d_dim_trns_mns_dm[c]=buf[inactiv].d_trns_dm[c]*dim_trns_trns_mns-
							                 buf[inactiv].d_vol_dm[c]*dim_trns_vol_mns;
					}
					double d_dim_trns_pls_dT=buf[activ].d_trns_dT*dim_trns_trns_pls-
						                     buf[activ].d_vol_dT*dim_trns_vol_pls;
					double d_dim_trns_mns_dT=buf[inactiv].d_trns_dT*dim_trns_trns_mns-
						                     buf[inactiv].d_vol_dT*dim_trns_vol_mns;
					
					double dTvs4=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])/4.0;
					
					double g_frn_pls, g_frn_mns, g_frn_dlt, Jg_vs, Jg_vol_pls, Jg_vol_mns,
						   Jg_vol_frn_pls, Jg_vol_frn_mns, Jg, dHgvs2, Jg_heat, d_Jg_pls,
						   d_Jg_mns;
					for(int g=0; g<NUM_CMP; g++){
					if(CMP[g].state()=='G'){
						
						g_frn_pls=buf[activ].m_vs_dns[g]/buf[activ].vol;
						g_frn_mns=buf[inactiv].m_vs_dns[g]/buf[inactiv].vol;
						g_frn_dlt=g_frn_mns-g_frn_pls;
						Jg_vs=arr_vs_dim_trns/buf[activ].one_vs_dns[g]+
							  arr_vs_dim_trns/buf[inactiv].one_vs_dns[g];
						Jg_vol_pls=Jg_vs/buf[activ].vol;
						Jg_vol_mns=Jg_vs/buf[inactiv].vol;
						Jg_vol_frn_pls=Jg_vol_pls*g_frn_pls;
						Jg_vol_frn_mns=Jg_vol_mns*g_frn_mns;
						Jg=Jg_vs*g_frn_dlt;
						Eplus.massT_rate[g].rt0+=Jg;
						Eminus.massT_rate[g].rt0-=Jg;
						
						dHgvs2=(buf[activ].d_hcap_dm[g]+buf[inactiv].d_hcap_dm[g])*dTvs4;
						Jg_heat=Jg*dHgvs2;
						Eplus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						Eminus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						
						for(int c=0; c<NUM_CMP; c++)
						{
							d_Jg_pls=Jg*d_dim_trns_pls_dm[c]+
								     Jg_vol_frn_pls*buf[activ].d_vol_dm[c];
							d_Jg_mns=Jg*d_dim_trns_mns_dm[c]-
								     Jg_vol_frn_mns*buf[inactiv].d_vol_dm[c];
							if(c==g)
							{
								d_Jg_pls-=Jg_vol_pls*buf[activ].one_vs_dns[g];
								d_Jg_mns+=Jg_vol_mns*buf[inactiv].one_vs_dns[g];
							}
							Eplus.massT_rate[g].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[g].YminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[g].YplusElem[c]-=d_Jg_pls;
							Eminus.massT_rate[g].thisElem[c]-=d_Jg_mns;
							
							d_Jg_pls*=dHgvs2;
							d_Jg_mns*=dHgvs2;
							Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[NUM_CMP].YminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[NUM_CMP].YplusElem[c]+=d_Jg_pls;
							Eminus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_mns;
						}
						
						Jg_vs=arr_vs_dim_trns*g_frn_dlt;
						d_Jg_pls=Jg*d_dim_trns_pls_dT+
							     Jg_vol_frn_pls*buf[activ].d_vol_dT-
								 Jg_vol_pls*buf[activ].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eplus.massT[NUM_CMP]);
						d_Jg_mns=Jg*d_dim_trns_mns_dT-
							     Jg_vol_frn_mns*buf[inactiv].d_vol_dT+
								 Jg_vol_mns*buf[inactiv].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eminus.massT[NUM_CMP]);
						Eplus.massT_rate[g].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[g].YminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[g].YplusElem[NUM_CMP]-=d_Jg_pls;
						Eminus.massT_rate[g].thisElem[NUM_CMP]-=d_Jg_mns;
						
						Jg_vs=Jg/2.0;
						d_Jg_pls*=dHgvs2;
						d_Jg_mns*=dHgvs2;
						d_Jg_pls-=Jg_vs*buf[activ].d_hcap_dm[g];
						d_Jg_mns+=Jg_vs*buf[inactiv].d_hcap_dm[g];
						Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[NUM_CMP].YminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[NUM_CMP].YplusElem[NUM_CMP]+=d_Jg_pls;
						Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_mns;
					}}
				}
				break;
			case 'Z':
				{
					double dim_trns_pls=Eplus.Zdim/buf[activ].trns;
					double dim_trns_mns=Eminus.Zdim/buf[inactiv].trns;
					double dim_trns=dim_trns_pls+dim_trns_mns;
					double arr_vs_dim_trns=0.5*(buf[activ].vol/Eplus.Zdim+
						                        buf[inactiv].vol/Eminus.Zdim)/dim_trns;
					
					dim_trns_pls/=dim_trns;
					dim_trns_mns/=dim_trns;
					double dim_trns_trns_pls=dim_trns_pls/buf[activ].trns;
					double dim_trns_trns_mns=dim_trns_mns/buf[inactiv].trns;
					double dim_trns_vol_pls=dim_trns_pls/buf[activ].vol;
					double dim_trns_vol_mns=dim_trns_mns/buf[inactiv].vol;
					double d_dim_trns_pls_dm[Consts::MAX_CMP],
						   d_dim_trns_mns_dm[Consts::MAX_CMP];
					for(int c=0; c<NUM_CMP; c++)
					{
						d_dim_trns_pls_dm[c]=buf[activ].d_trns_dm[c]*dim_trns_trns_pls-
							                 buf[activ].d_vol_dm[c]*dim_trns_vol_pls;
						d_dim_trns_mns_dm[c]=buf[inactiv].d_trns_dm[c]*dim_trns_trns_mns-
							                 buf[inactiv].d_vol_dm[c]*dim_trns_vol_mns;
					}
					double d_dim_trns_pls_dT=buf[activ].d_trns_dT*dim_trns_trns_pls-
						                     buf[activ].d_vol_dT*dim_trns_vol_pls;
					double d_dim_trns_mns_dT=buf[inactiv].d_trns_dT*dim_trns_trns_mns-
						                     buf[inactiv].d_vol_dT*dim_trns_vol_mns;
					
					double dTvs4=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])/4.0;
					
					double g_frn_pls, g_frn_mns, g_frn_dlt, Jg_vs, Jg_vol_pls, Jg_vol_mns,
						   Jg_vol_frn_pls, Jg_vol_frn_mns, Jg, dHgvs2, Jg_heat, d_Jg_pls,
						   d_Jg_mns;
					for(int g=0; g<NUM_CMP; g++){
					if(CMP[g].state()=='G'){
						
						g_frn_pls=buf[activ].m_vs_dns[g]/buf[activ].vol;
						g_frn_mns=buf[inactiv].m_vs_dns[g]/buf[inactiv].vol;
						g_frn_dlt=g_frn_mns-g_frn_pls;
						Jg_vs=arr_vs_dim_trns/buf[activ].one_vs_dns[g]+
							  arr_vs_dim_trns/buf[inactiv].one_vs_dns[g];
						Jg_vol_pls=Jg_vs/buf[activ].vol;
						Jg_vol_mns=Jg_vs/buf[inactiv].vol;
						Jg_vol_frn_pls=Jg_vol_pls*g_frn_pls;
						Jg_vol_frn_mns=Jg_vol_mns*g_frn_mns;
						Jg=Jg_vs*g_frn_dlt;
						Eplus.massT_rate[g].rt0+=Jg;
						Eminus.massT_rate[g].rt0-=Jg;
						
						dHgvs2=(buf[activ].d_hcap_dm[g]+buf[inactiv].d_hcap_dm[g])*dTvs4;
						Jg_heat=Jg*dHgvs2;
						Eplus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						Eminus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						
						for(int c=0; c<NUM_CMP; c++)
						{
							d_Jg_pls=Jg*d_dim_trns_pls_dm[c]+
								     Jg_vol_frn_pls*buf[activ].d_vol_dm[c];
							d_Jg_mns=Jg*d_dim_trns_mns_dm[c]-
								     Jg_vol_frn_mns*buf[inactiv].d_vol_dm[c];
							if(c==g)
							{
								d_Jg_pls-=Jg_vol_pls*buf[activ].one_vs_dns[g];
								d_Jg_mns+=Jg_vol_mns*buf[inactiv].one_vs_dns[g];
							}
							Eplus.massT_rate[g].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[g].ZminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[g].ZplusElem[c]-=d_Jg_pls;
							Eminus.massT_rate[g].thisElem[c]-=d_Jg_mns;
							
							d_Jg_pls*=dHgvs2;
							d_Jg_mns*=dHgvs2;
							Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[NUM_CMP].ZminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[NUM_CMP].ZplusElem[c]+=d_Jg_pls;
							Eminus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_mns;
						}
						
						Jg_vs=arr_vs_dim_trns*g_frn_dlt;
						d_Jg_pls=Jg*d_dim_trns_pls_dT+
							     Jg_vol_frn_pls*buf[activ].d_vol_dT-
								 Jg_vol_pls*buf[activ].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eplus.massT[NUM_CMP]);
						d_Jg_mns=Jg*d_dim_trns_mns_dT-
							     Jg_vol_frn_mns*buf[inactiv].d_vol_dT+
								 Jg_vol_mns*buf[inactiv].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eminus.massT[NUM_CMP]);
						Eplus.massT_rate[g].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[g].ZminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[g].ZplusElem[NUM_CMP]-=d_Jg_pls;
						Eminus.massT_rate[g].thisElem[NUM_CMP]-=d_Jg_mns;
						
						Jg_vs=Jg/2.0;
						d_Jg_pls*=dHgvs2;
						d_Jg_mns*=dHgvs2;
						d_Jg_pls-=Jg_vs*buf[activ].d_hcap_dm[g];
						d_Jg_mns+=Jg_vs*buf[inactiv].d_hcap_dm[g];
						Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[NUM_CMP].ZminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[NUM_CMP].ZplusElem[NUM_CMP]+=d_Jg_pls;
						Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_mns;
					}}
				}
			}
		}
		else
		{
			switch(comm_axis)
			{
			case 'X':
				{
					double dim_trns_pls=Eplus.Xdim/buf[activ].trns;
					double dim_trns_mns=Eminus.Xdim/buf[inactiv].trns;
					double dim_trns=dim_trns_pls+dim_trns_mns;
					double arrea2=buf[activ].vol/Eplus.Xdim+buf[inactiv].vol/Eminus.Xdim;
					double arr_vs_dim_trns=0.5*arrea2/dim_trns;
					
					dim_trns_pls/=dim_trns;
					dim_trns_mns/=dim_trns;
					double dim_trns_trns_pls=dim_trns_pls/buf[activ].trns;
					double dim_trns_trns_mns=dim_trns_mns/buf[inactiv].trns;
					double arr2_dim_pls=arrea2*Eplus.Xdim;
					double arr2_dim_mns=arrea2*Eminus.Xdim;
					double d_arr2_trns_pls_dm[Consts::MAX_CMP],
						   d_arr2_trns_mns_dm[Consts::MAX_CMP];
					for(int c=0; c<NUM_CMP; c++)
					{
						d_arr2_trns_pls_dm[c]=buf[activ].d_trns_dm[c]*dim_trns_trns_pls+
							                  buf[activ].d_vol_dm[c]/arr2_dim_pls;
						d_arr2_trns_mns_dm[c]=buf[inactiv].d_trns_dm[c]*dim_trns_trns_mns+
							                  buf[inactiv].d_vol_dm[c]/arr2_dim_mns;
					}
					double d_arr2_trns_pls_dT=buf[activ].d_trns_dT*dim_trns_trns_pls+
						                      buf[activ].d_vol_dT/arr2_dim_pls;
					double d_arr2_trns_mns_dT=buf[inactiv].d_trns_dT*dim_trns_trns_mns+
						                      buf[inactiv].d_vol_dT/arr2_dim_mns;
					
					double dTvs4=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])/4.0;
					
					double g_frn_pls, g_frn_mns, g_frn_dlt, Jg_vs, Jg_vol_pls, Jg_vol_mns,
						   Jg_vol_frn_pls, Jg_vol_frn_mns, Jg, dHgvs2, Jg_heat, d_Jg_pls,
						   d_Jg_mns;
					for(int g=0; g<NUM_CMP; g++){
					if(CMP[g].state()=='G'){
						
						g_frn_pls=buf[activ].m_vs_dns[g]/buf[activ].vol;
						g_frn_mns=buf[inactiv].m_vs_dns[g]/buf[inactiv].vol;
						g_frn_dlt=g_frn_mns-g_frn_pls;
						Jg_vs=arr_vs_dim_trns/buf[activ].one_vs_dns[g]+
							  arr_vs_dim_trns/buf[inactiv].one_vs_dns[g];
						Jg_vol_pls=Jg_vs/buf[activ].vol;
						Jg_vol_mns=Jg_vs/buf[inactiv].vol;
						Jg_vol_frn_pls=Jg_vol_pls*g_frn_pls;
						Jg_vol_frn_mns=Jg_vol_mns*g_frn_mns;
						Jg=Jg_vs*g_frn_dlt;
						Eplus.massT_rate[g].rt0+=Jg;
						Eminus.massT_rate[g].rt0-=Jg;
						
						dHgvs2=(buf[activ].d_hcap_dm[g]+buf[inactiv].d_hcap_dm[g])*dTvs4;
						Jg_heat=Jg*dHgvs2;
						Eplus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						Eminus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						
						for(int c=0; c<NUM_CMP; c++)
						{
							d_Jg_pls=Jg*d_arr2_trns_pls_dm[c]+
								     Jg_vol_frn_pls*buf[activ].d_vol_dm[c];
							d_Jg_mns=Jg*d_arr2_trns_mns_dm[c]-
								     Jg_vol_frn_mns*buf[inactiv].d_vol_dm[c];
							if(c==g)
							{
								d_Jg_pls-=Jg_vol_pls*buf[activ].one_vs_dns[g];
								d_Jg_mns+=Jg_vol_mns*buf[inactiv].one_vs_dns[g];
							}
							Eplus.massT_rate[g].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[g].XminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[g].XplusElem[c]-=d_Jg_pls;
							Eminus.massT_rate[g].thisElem[c]-=d_Jg_mns;
							
							d_Jg_pls*=dHgvs2;
							d_Jg_mns*=dHgvs2;
							Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[NUM_CMP].XminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[NUM_CMP].XplusElem[c]+=d_Jg_pls;
							Eminus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_mns;
						}
						
						Jg_vs=arr_vs_dim_trns*g_frn_dlt;
						d_Jg_pls=Jg*d_arr2_trns_pls_dT+
							     Jg_vol_frn_pls*buf[activ].d_vol_dT-
								 Jg_vol_pls*buf[activ].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eplus.massT[NUM_CMP]);
						d_Jg_mns=Jg*d_arr2_trns_mns_dT-
							     Jg_vol_frn_mns*buf[inactiv].d_vol_dT+
								 Jg_vol_mns*buf[inactiv].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eminus.massT[NUM_CMP]);
						Eplus.massT_rate[g].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[g].XminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[g].XplusElem[NUM_CMP]-=d_Jg_pls;
						Eminus.massT_rate[g].thisElem[NUM_CMP]-=d_Jg_mns;
						
						Jg_vs=Jg/2.0;
						d_Jg_pls*=dHgvs2;
						d_Jg_mns*=dHgvs2;
						d_Jg_pls-=Jg_vs*buf[activ].d_hcap_dm[g];
						d_Jg_mns+=Jg_vs*buf[inactiv].d_hcap_dm[g];
						Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[NUM_CMP].XminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[NUM_CMP].XplusElem[NUM_CMP]+=d_Jg_pls;
						Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_mns;
					}}
				}
				break;
			case 'Y':
				{
					double dim_trns_pls=Eplus.Ydim/buf[activ].trns;
					double dim_trns_mns=Eminus.Ydim/buf[inactiv].trns;
					double dim_trns=dim_trns_pls+dim_trns_mns;
					double arrea2=buf[activ].vol/Eplus.Ydim+buf[inactiv].vol/Eminus.Ydim;
					double arr_vs_dim_trns=0.5*arrea2/dim_trns;
					
					dim_trns_pls/=dim_trns;
					dim_trns_mns/=dim_trns;
					double dim_trns_trns_pls=dim_trns_pls/buf[activ].trns;
					double dim_trns_trns_mns=dim_trns_mns/buf[inactiv].trns;
					double arr2_dim_pls=arrea2*Eplus.Ydim;
					double arr2_dim_mns=arrea2*Eminus.Ydim;
					double d_arr2_trns_pls_dm[Consts::MAX_CMP],
						   d_arr2_trns_mns_dm[Consts::MAX_CMP];
					for(int c=0; c<NUM_CMP; c++)
					{
						d_arr2_trns_pls_dm[c]=buf[activ].d_trns_dm[c]*dim_trns_trns_pls+
							                  buf[activ].d_vol_dm[c]/arr2_dim_pls;
						d_arr2_trns_mns_dm[c]=buf[inactiv].d_trns_dm[c]*dim_trns_trns_mns+
							                  buf[inactiv].d_vol_dm[c]/arr2_dim_mns;
					}
					double d_arr2_trns_pls_dT=buf[activ].d_trns_dT*dim_trns_trns_pls+
						                      buf[activ].d_vol_dT/arr2_dim_pls;
					double d_arr2_trns_mns_dT=buf[inactiv].d_trns_dT*dim_trns_trns_mns+
						                      buf[inactiv].d_vol_dT/arr2_dim_mns;
					
					double dTvs4=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])/4.0;
					
					double g_frn_pls, g_frn_mns, g_frn_dlt, Jg_vs, Jg_vol_pls, Jg_vol_mns,
						   Jg_vol_frn_pls, Jg_vol_frn_mns, Jg, dHgvs2, Jg_heat, d_Jg_pls,
						   d_Jg_mns;
					for(int g=0; g<NUM_CMP; g++){
					if(CMP[g].state()=='G'){
						
						g_frn_pls=buf[activ].m_vs_dns[g]/buf[activ].vol;
						g_frn_mns=buf[inactiv].m_vs_dns[g]/buf[inactiv].vol;
						g_frn_dlt=g_frn_mns-g_frn_pls;
						Jg_vs=arr_vs_dim_trns/buf[activ].one_vs_dns[g]+
							  arr_vs_dim_trns/buf[inactiv].one_vs_dns[g];
						Jg_vol_pls=Jg_vs/buf[activ].vol;
						Jg_vol_mns=Jg_vs/buf[inactiv].vol;
						Jg_vol_frn_pls=Jg_vol_pls*g_frn_pls;
						Jg_vol_frn_mns=Jg_vol_mns*g_frn_mns;
						Jg=Jg_vs*g_frn_dlt;
						Eplus.massT_rate[g].rt0+=Jg;
						Eminus.massT_rate[g].rt0-=Jg;
						
						dHgvs2=(buf[activ].d_hcap_dm[g]+buf[inactiv].d_hcap_dm[g])*dTvs4;
						Jg_heat=Jg*dHgvs2;
						Eplus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						Eminus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						
						for(int c=0; c<NUM_CMP; c++)
						{
							d_Jg_pls=Jg*d_arr2_trns_pls_dm[c]+
								     Jg_vol_frn_pls*buf[activ].d_vol_dm[c];
							d_Jg_mns=Jg*d_arr2_trns_mns_dm[c]-
								     Jg_vol_frn_mns*buf[inactiv].d_vol_dm[c];
							if(c==g)
							{
								d_Jg_pls-=Jg_vol_pls*buf[activ].one_vs_dns[g];
								d_Jg_mns+=Jg_vol_mns*buf[inactiv].one_vs_dns[g];
							}
							Eplus.massT_rate[g].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[g].YminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[g].YplusElem[c]-=d_Jg_pls;
							Eminus.massT_rate[g].thisElem[c]-=d_Jg_mns;
							
							d_Jg_pls*=dHgvs2;
							d_Jg_mns*=dHgvs2;
							Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[NUM_CMP].YminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[NUM_CMP].YplusElem[c]+=d_Jg_pls;
							Eminus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_mns;
						}
						
						Jg_vs=arr_vs_dim_trns*g_frn_dlt;
						d_Jg_pls=Jg*d_arr2_trns_pls_dT+
							     Jg_vol_frn_pls*buf[activ].d_vol_dT-
								 Jg_vol_pls*buf[activ].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eplus.massT[NUM_CMP]);
						d_Jg_mns=Jg*d_arr2_trns_mns_dT-
							     Jg_vol_frn_mns*buf[inactiv].d_vol_dT+
								 Jg_vol_mns*buf[inactiv].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eminus.massT[NUM_CMP]);
						Eplus.massT_rate[g].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[g].YminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[g].YplusElem[NUM_CMP]-=d_Jg_pls;
						Eminus.massT_rate[g].thisElem[NUM_CMP]-=d_Jg_mns;
						
						Jg_vs=Jg/2.0;
						d_Jg_pls*=dHgvs2;
						d_Jg_mns*=dHgvs2;
						d_Jg_pls-=Jg_vs*buf[activ].d_hcap_dm[g];
						d_Jg_mns+=Jg_vs*buf[inactiv].d_hcap_dm[g];
						Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[NUM_CMP].YminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[NUM_CMP].YplusElem[NUM_CMP]+=d_Jg_pls;
						Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_mns;
					}}
				}
				break;
			case 'Z':
				{
					double dim_trns_pls=Eplus.Zdim/buf[activ].trns;
					double dim_trns_mns=Eminus.Zdim/buf[inactiv].trns;
					double dim_trns=dim_trns_pls+dim_trns_mns;
					double arrea2=buf[activ].vol/Eplus.Zdim+buf[inactiv].vol/Eminus.Zdim;
					double arr_vs_dim_trns=0.5*arrea2/dim_trns;
					
					dim_trns_pls/=dim_trns;
					dim_trns_mns/=dim_trns;
					double dim_trns_trns_pls=dim_trns_pls/buf[activ].trns;
					double dim_trns_trns_mns=dim_trns_mns/buf[inactiv].trns;
					double arr2_dim_pls=arrea2*Eplus.Zdim;
					double arr2_dim_mns=arrea2*Eminus.Zdim;
					double d_arr2_trns_pls_dm[Consts::MAX_CMP],
						   d_arr2_trns_mns_dm[Consts::MAX_CMP];
					for(int c=0; c<NUM_CMP; c++)
					{
						d_arr2_trns_pls_dm[c]=buf[activ].d_trns_dm[c]*dim_trns_trns_pls+
							                  buf[activ].d_vol_dm[c]/arr2_dim_pls;
						d_arr2_trns_mns_dm[c]=buf[inactiv].d_trns_dm[c]*dim_trns_trns_mns+
							                  buf[inactiv].d_vol_dm[c]/arr2_dim_mns;
					}
					double d_arr2_trns_pls_dT=buf[activ].d_trns_dT*dim_trns_trns_pls+
						                      buf[activ].d_vol_dT/arr2_dim_pls;
					double d_arr2_trns_mns_dT=buf[inactiv].d_trns_dT*dim_trns_trns_mns+
						                      buf[inactiv].d_vol_dT/arr2_dim_mns;
					
					double dTvs4=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])/4.0;
					
					double g_frn_pls, g_frn_mns, g_frn_dlt, Jg_vs, Jg_vol_pls, Jg_vol_mns,
						   Jg_vol_frn_pls, Jg_vol_frn_mns, Jg, dHgvs2, Jg_heat, d_Jg_pls,
						   d_Jg_mns;
					for(int g=0; g<NUM_CMP; g++){
					if(CMP[g].state()=='G'){
						
						g_frn_pls=buf[activ].m_vs_dns[g]/buf[activ].vol;
						g_frn_mns=buf[inactiv].m_vs_dns[g]/buf[inactiv].vol;
						g_frn_dlt=g_frn_mns-g_frn_pls;
						Jg_vs=arr_vs_dim_trns/buf[activ].one_vs_dns[g]+
							  arr_vs_dim_trns/buf[inactiv].one_vs_dns[g];
						Jg_vol_pls=Jg_vs/buf[activ].vol;
						Jg_vol_mns=Jg_vs/buf[inactiv].vol;
						Jg_vol_frn_pls=Jg_vol_pls*g_frn_pls;
						Jg_vol_frn_mns=Jg_vol_mns*g_frn_mns;
						Jg=Jg_vs*g_frn_dlt;
						Eplus.massT_rate[g].rt0+=Jg;
						Eminus.massT_rate[g].rt0-=Jg;
						
						dHgvs2=(buf[activ].d_hcap_dm[g]+buf[inactiv].d_hcap_dm[g])*dTvs4;
						Jg_heat=Jg*dHgvs2;
						Eplus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						Eminus.massT_rate[NUM_CMP].rt0+=Jg_heat;
						
						for(int c=0; c<NUM_CMP; c++)
						{
							d_Jg_pls=Jg*d_arr2_trns_pls_dm[c]+
								     Jg_vol_frn_pls*buf[activ].d_vol_dm[c];
							d_Jg_mns=Jg*d_arr2_trns_mns_dm[c]-
								     Jg_vol_frn_mns*buf[inactiv].d_vol_dm[c];
							if(c==g)
							{
								d_Jg_pls-=Jg_vol_pls*buf[activ].one_vs_dns[g];
								d_Jg_mns+=Jg_vol_mns*buf[inactiv].one_vs_dns[g];
							}
							Eplus.massT_rate[g].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[g].ZminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[g].ZplusElem[c]-=d_Jg_pls;
							Eminus.massT_rate[g].thisElem[c]-=d_Jg_mns;
							
							d_Jg_pls*=dHgvs2;
							d_Jg_mns*=dHgvs2;
							Eplus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_pls;
							Eplus.massT_rate[NUM_CMP].ZminusElem[c]+=d_Jg_mns;
							Eminus.massT_rate[NUM_CMP].ZplusElem[c]+=d_Jg_pls;
							Eminus.massT_rate[NUM_CMP].thisElem[c]+=d_Jg_mns;
						}
						
						Jg_vs=arr_vs_dim_trns*g_frn_dlt;
						d_Jg_pls=Jg*d_arr2_trns_pls_dT+
							     Jg_vol_frn_pls*buf[activ].d_vol_dT-
								 Jg_vol_pls*buf[activ].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eplus.massT[NUM_CMP]);
						d_Jg_mns=Jg*d_arr2_trns_mns_dT-
							     Jg_vol_frn_mns*buf[inactiv].d_vol_dT+
								 Jg_vol_mns*buf[inactiv].d_m_vs_dns_dT[g]+
								 Jg_vs*CMP[g].d_dens_dT(Eminus.massT[NUM_CMP]);
						Eplus.massT_rate[g].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[g].ZminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[g].ZplusElem[NUM_CMP]-=d_Jg_pls;
						Eminus.massT_rate[g].thisElem[NUM_CMP]-=d_Jg_mns;
						
						Jg_vs=Jg/2.0;
						d_Jg_pls*=dHgvs2;
						d_Jg_mns*=dHgvs2;
						d_Jg_pls-=Jg_vs*buf[activ].d_hcap_dm[g];
						d_Jg_mns+=Jg_vs*buf[inactiv].d_hcap_dm[g];
						Eplus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_pls;
						Eplus.massT_rate[NUM_CMP].ZminusElem[NUM_CMP]+=d_Jg_mns;
						Eminus.massT_rate[NUM_CMP].ZplusElem[NUM_CMP]+=d_Jg_pls;
						Eminus.massT_rate[NUM_CMP].thisElem[NUM_CMP]+=d_Jg_mns;
					}}
				}
			}
		}
	}
	else
	{
		switch(comm_axis)
		{
		case 'X':
			{
				double arr_vs_dim_trns=0.5*(buf[activ].vol/Eplus.Xdim+
					                        buf[inactiv].vol/Eminus.Xdim)/
										   (Eplus.Xdim/buf[activ].trns+
										    Eminus.Xdim/buf[inactiv].trns);
				
				double dTvs4=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])/4.0;
				
				double Jg, Jg_heat;
				for(int g=0; g<NUM_CMP; g++){
				if(CMP[g].state()=='G'){
					
					Jg=(arr_vs_dim_trns/buf[activ].one_vs_dns[g]+
						arr_vs_dim_trns/buf[inactiv].one_vs_dns[g])*
					   (buf[inactiv].m_vs_dns[g]/buf[inactiv].vol-
					    buf[activ].m_vs_dns[g]/buf[activ].vol);
					Eplus.massT_rate[g].rt0+=Jg;
					Eminus.massT_rate[g].rt0-=Jg;
					
					Jg_heat=Jg*(buf[activ].d_hcap_dm[g]+buf[inactiv].d_hcap_dm[g])*dTvs4;
					Eplus.massT_rate[NUM_CMP].rt0+=Jg_heat;
					Eminus.massT_rate[NUM_CMP].rt0+=Jg_heat;
				}}
			}
			break;
		case 'Y':
			{
				double arr_vs_dim_trns=0.5*(buf[activ].vol/Eplus.Ydim+
					                        buf[inactiv].vol/Eminus.Ydim)/
										   (Eplus.Ydim/buf[activ].trns+
										    Eminus.Ydim/buf[inactiv].trns);
				
				double dTvs4=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])/4.0;
				
				double Jg, Jg_heat;
				for(int g=0; g<NUM_CMP; g++){
				if(CMP[g].state()=='G'){
					
					Jg=(arr_vs_dim_trns/buf[activ].one_vs_dns[g]+
						arr_vs_dim_trns/buf[inactiv].one_vs_dns[g])*
					   (buf[inactiv].m_vs_dns[g]/buf[inactiv].vol-
					    buf[activ].m_vs_dns[g]/buf[activ].vol);
					Eplus.massT_rate[g].rt0+=Jg;
					Eminus.massT_rate[g].rt0-=Jg;
					
					Jg_heat=Jg*(buf[activ].d_hcap_dm[g]+buf[inactiv].d_hcap_dm[g])*dTvs4;
					Eplus.massT_rate[NUM_CMP].rt0+=Jg_heat;
					Eminus.massT_rate[NUM_CMP].rt0+=Jg_heat;
				}}
			}
			break;
		case 'Z':
			{
				double arr_vs_dim_trns=0.5*(buf[activ].vol/Eplus.Zdim+
					                        buf[inactiv].vol/Eminus.Zdim)/
										   (Eplus.Zdim/buf[activ].trns+
										    Eminus.Zdim/buf[inactiv].trns);
				
				double dTvs4=(Eminus.massT[NUM_CMP]-Eplus.massT[NUM_CMP])/4.0;
				
				double Jg, Jg_heat;
				for(int g=0; g<NUM_CMP; g++){
				if(CMP[g].state()=='G'){
					
					Jg=(arr_vs_dim_trns/buf[activ].one_vs_dns[g]+
						arr_vs_dim_trns/buf[inactiv].one_vs_dns[g])*
					   (buf[inactiv].m_vs_dns[g]/buf[inactiv].vol-
					    buf[activ].m_vs_dns[g]/buf[activ].vol);
					Eplus.massT_rate[g].rt0+=Jg;
					Eminus.massT_rate[g].rt0-=Jg;
					
					Jg_heat=Jg*(buf[activ].d_hcap_dm[g]+buf[inactiv].d_hcap_dm[g])*dTvs4;
					Eplus.massT_rate[NUM_CMP].rt0+=Jg_heat;
					Eminus.massT_rate[NUM_CMP].rt0+=Jg_heat;
				}}
			}
		}
	}
}

void Comps::move_contents(Elem& Efrom,Elem& Eto,bool gases_only)
{
	double Tfrom=Efrom.massT[NUM_CMP];
	double Tto=Eto.massT[NUM_CMP];
	double hcap_from=0.0;
	double hcap_to=0.0;
	
	if(gases_only)
	{
		for(int c=0; c<NUM_CMP; c++)
		{
			if(CMP[c].state()=='G') { hcap_from+=CMP[c].hcap(Tfrom)*Efrom.massT[c]; }
			hcap_to+=CMP[c].hcap(Tto)*Eto.massT[c];
		}
		
		double T=(hcap_from*Tfrom+hcap_to*Tto)/(hcap_from+hcap_to);
		
		Tfrom+=T; Tfrom/=2.0;
		Tto+=T; Tto/=2.0;
		hcap_from=0.0;
		hcap_to=0.0;
		
		for(int c=0; c<NUM_CMP; c++)
		{
			hcap_to+=CMP[c].hcap(Tto)*Eto.massT[c];
			
			if(CMP[c].state()=='G')
			{
				hcap_from+=CMP[c].hcap(Tfrom)*Efrom.massT[c];
				Eto.massT[c]+=Efrom.massT[c];
				Efrom.massT[c]=0.0;
			}
		}
		
		Eto.massT[NUM_CMP]=(hcap_from*Efrom.massT[NUM_CMP]+hcap_to*Eto.massT[NUM_CMP])/
			               (hcap_from+hcap_to);
	}
	else
	{
		for(int c=0; c<NUM_CMP; c++)
		{
			hcap_from+=CMP[c].hcap(Tfrom)*Efrom.massT[c];
			hcap_to+=CMP[c].hcap(Tto)*Eto.massT[c];
		}
		
		double T=(hcap_from*Tfrom+hcap_to*Tto)/(hcap_from+hcap_to);
		
		Tfrom+=T; Tfrom/=2.0;
		Tto+=T; Tto/=2.0;
		hcap_from=0.0;
		hcap_to=0.0;
		
		for(int c=0; c<NUM_CMP; c++)
		{
			hcap_from+=CMP[c].hcap(Tfrom)*Efrom.massT[c];
			hcap_to+=CMP[c].hcap(Tto)*Eto.massT[c];
			
			Eto.massT[c]+=Efrom.massT[c];
			Efrom.massT[c]=0.0;
		}
		
		Eto.massT[NUM_CMP]=(hcap_from*Efrom.massT[NUM_CMP]+hcap_to*Eto.massT[NUM_CMP])/
			               (hcap_from+hcap_to);
		Efrom.massT[NUM_CMP]=0.0;
	}
}

void Comps::heat_rate_to_temp_rate(Elem& E,bool calc_der)
{
	E.massT_rate[NUM_CMP].rt0/=buf[activ].hcap;
	
	if(calc_der)
	{
		for(int c=0; c<NUM_CMP; c++)
		{
			E.massT_rate[NUM_CMP].thisElem[c]-=E.massT_rate[NUM_CMP].rt0*buf[activ].d_hcap_dm[c];
			E.massT_rate[NUM_CMP].thisElem[c]/=buf[activ].hcap;
			E.massT_rate[NUM_CMP].XplusElem[c]/=buf[activ].hcap;
			E.massT_rate[NUM_CMP].XminusElem[c]/=buf[activ].hcap;
		}
		E.massT_rate[NUM_CMP].thisElem[NUM_CMP]-=E.massT_rate[NUM_CMP].rt0*buf[activ].d_hcap_dT;
		E.massT_rate[NUM_CMP].thisElem[NUM_CMP]/=buf[activ].hcap;
		E.massT_rate[NUM_CMP].XplusElem[NUM_CMP]/=buf[activ].hcap;
		E.massT_rate[NUM_CMP].XminusElem[NUM_CMP]/=buf[activ].hcap;
		
		if(E.Ndimens()>1)
		{
			for(int c=0; c<=NUM_CMP; c++)
			{
				E.massT_rate[NUM_CMP].YplusElem[c]/=buf[activ].hcap;
				E.massT_rate[NUM_CMP].YminusElem[c]/=buf[activ].hcap;
			}
			
			if(E.Ndimens()>2)
			{
				for(int c=0; c<=NUM_CMP; c++)
				{
					E.massT_rate[NUM_CMP].ZplusElem[c]/=buf[activ].hcap;
					E.massT_rate[NUM_CMP].ZminusElem[c]/=buf[activ].hcap;
				}
			}
		}
	}
}

Comps mat;