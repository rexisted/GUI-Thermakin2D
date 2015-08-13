#include "Boundary.h"

void Bound::zero()
{
	id="---";
	mF_Num=ign_mF_Num=0;
	
	for(int c=0; c<Consts::MAX_CMP; c++)
	{
		mF_cInd[c]=ign_mF_cInd[c]=-1;
		mF_expf[c]=false;
		mF_par0[c]=mF_par1[c]=ign_mF[c]=0.0;
		
		mF[c]=totl_mF[c]=0.0;
	}
	
	outT_0=cnv_coef=0.0;
	outT_rt[0]=outT_rt[1]=outT_rt[2]=outT_rt[3]=0.0;
	hF1_0=hF1_rt=hF1_tm=0.0;
	hF2_0=hF2_rt=hF2_tm=0.0;
	hF_redo=rand_absr=false;
	flm_outT=flm_cnv_coef=flm_hF=0.0;
	
	tm=0.0;
	outT[0]=outT[1]=outT[2]=0.0;
	hF[0]=hF[1]=0.0;
	surf=absr=NULL;
	surf_area=totl_area=0.0;
	hF_absr=hF_left=totl_hF=0.0;
}

bool Bound::load(std::istringstream& boundpar,std::string name)
{
	zero();
	id=name;
	
	std::string buf;
	if(!((boundpar>>buf)&&(buf=="MASS")&&(boundpar>>buf)&&(buf=="TRANSPORT:")&&
		 (boundpar>>buf))) { return false; }
	
	extern Comps mat;
	if(buf=="YES")
	{
		if(!(boundpar>>buf)) { return false; }
		do
		{
			if(mF_Num>=Consts::MAX_CMP) { return false; }
			
			mF_cInd[mF_Num]=mat.comp_indx(buf);
			
			if(boundpar>>buf) { if(buf=="EXP") { mF_expf[mF_Num]=true; } }
			else { return false; }
			
			if(!((boundpar>>mF_par0[mF_Num])&&(boundpar>>mF_par1[mF_Num])&&
				 (boundpar>>buf))) { return false; }
			
			if(mF_cInd[mF_Num]>=0) { ++mF_Num; }
		} while(buf!="OUTSIDE");
	}
	else
	{
		do { if(!(boundpar>>buf)) { return false; } } while(buf!="OUTSIDE");
	}
	
	if(!((boundpar>>buf)&&(buf=="INIT")&&(boundpar>>buf)&&(buf=="TEMP:")&&
		 (boundpar>>outT_0)&&(boundpar>>buf)&&(buf=="OUTSIDE")&&(boundpar>>buf)&&
		 (buf=="HEAT")&&(boundpar>>buf)&&(buf=="RATE:")&&(boundpar>>outT_rt[0])&&
		 (boundpar>>outT_rt[1])&&(boundpar>>outT_rt[2])&&(boundpar>>outT_rt[3])&&
		 (boundpar>>buf)&&(buf=="CONVECTION")&&(boundpar>>buf)&&(buf=="COEFF:")&&
		 (boundpar>>cnv_coef)&&(boundpar>>buf)&&(buf=="EXTERNAL")&&(boundpar>>buf)&&
		 (buf=="RADIATION:")&&(boundpar>>buf))) { return false; }
	
	if(buf=="YES")
	{
		if(!((boundpar>>buf)&&(buf=="TIME")&&(boundpar>>buf)&&(buf=="PROG1:")&&
			 (boundpar>>hF1_0)&&(boundpar>>hF1_rt)&&(boundpar>>hF1_tm)&&(boundpar>>buf)&&
			 (buf=="TIME")&&(boundpar>>buf)&&(buf=="PROG2:")&&(boundpar>>hF2_0)&&
			 (boundpar>>hF2_rt)&&(boundpar>>hF2_tm)&&(boundpar>>buf)&&(buf=="REPEAT:")&&
			 (boundpar>>buf))) { return false; }
		
		if(extRadiation_On())
		{
			hF2_tm+=hF1_tm;
			if((buf=="YES")&&(hF2_tm>0.0)) { hF_redo=true; }
		}
		else { hF1_tm=hF2_tm=0.0; }
		
		if(!((boundpar>>buf)&&(buf=="ABSORPTION")&&(boundpar>>buf)&&(buf=="MODE:")&&
			 (boundpar>>buf))) { return false; }
		
		if(buf=="RAND") { rand_absr=true; srand((unsigned)time(NULL)); }
		
		if(!((boundpar>>buf)&&(buf=="FLAME:")&&(boundpar>>buf))) { return false; }
	}
	else
	{
		do { if(!(boundpar>>buf)) { return false; } } while(buf!="FLAME:");
		if(!(boundpar>>buf)) { return false; }
	}
	
	if(buf=="YES")
	{
		if(!((boundpar>>buf)&&(buf=="IGNITION")&&(boundpar>>buf)&&(buf=="MASS")&&
			 (boundpar>>buf)&&(buf=="FLUXES:")&&(boundpar>>buf))) { return false; }
		do
		{
			if(ign_mF_Num>=Consts::MAX_CMP) { return false; }
			
			ign_mF_cInd[ign_mF_Num]=mat.comp_indx(buf);
			
			if(!((boundpar>>ign_mF[ign_mF_Num])&&(boundpar>>buf))) { return false; }
			
			if(ign_mF_cInd[ign_mF_Num]>=0) { ++ign_mF_Num; }
		} while(buf!="OUTSIDE");
		
		if(!((boundpar>>buf)&&(buf=="TEMP:")&&(boundpar>>flm_outT)&&(boundpar>>buf)&&
			 (buf=="CONVECTION")&&(boundpar>>buf)&&(buf=="COEFF:")&&
			 (boundpar>>flm_cnv_coef)&&(boundpar>>buf)&&(buf=="RADIATION:")&&
			 (boundpar>>flm_hF))) { return false; }
	}
	
	return true;
}

void Bound::inp_surfaceElem(Elem* surface,char surf_axis,double tmestep)
{
	surf=surface;
	switch(surf_axis)
	{
		case 'X': surf_area=surf->Ydim*surf->Zdim; break;
		case 'Y': surf_area=surf->Xdim*surf->Zdim; break;
		case 'Z': surf_area=surf->Xdim*surf->Ydim; break;
		default: surf_area=1.0;
	}
	
	extern Comps mat;
	if(tmestep>0.0)
	{
		for(int c=0; c<mat.Ncomps(); c++) { totl_mF[c]=0.0; }
		totl_hF=totl_area=0.0;
		
		double tmstp_vs2=tmestep/2.0;
		if(outT_rt[0]==0.0) { outT[0]=outT[1]=outT_0; }
		else
		{
			double outT_ch=outT_rt[2]*(tm+tmstp_vs2);
			outT_ch=outT_rt[0]*(1.0-exp(-outT_rt[1]*(tm+tmstp_vs2))*
				                    (cos(outT_ch)+outT_rt[3]*sin(outT_ch)));
			outT_ch*=tmstp_vs2;
			if(tm==0.0) { outT[0]=outT_0; } else { outT[0]=outT[2]; }
			outT[1]=outT[0]+outT_ch; outT[2]=outT[1]+outT_ch;
		}
		
		double hF_tm=tm;
		if(hF_redo)
		{
			while(hF_tm>hF2_tm) { hF_tm-=hF2_tm; }
			if(hF_tm<=hF1_tm) { hF[0]=hF1_0+hF1_rt*hF_tm; }
			else { hF[0]=hF2_0+hF2_rt*(hF_tm-hF1_tm); }
			
			hF_tm+=tmstp_vs2;
			
			while(hF_tm>hF2_tm) { hF_tm-=hF2_tm; }
			if(hF_tm<=hF1_tm) { hF[1]=hF1_0+hF1_rt*hF_tm; }
			else { hF[1]=hF2_0+hF2_rt*(hF_tm-hF1_tm); }
		}
		else
		{
			if(hF_tm>hF2_tm) { hF[0]=hF[1]=hF2_0+hF2_rt*(hF2_tm-hF1_tm); }
			else
			{
				if(hF_tm<=hF1_tm) { hF[0]=hF1_0+hF1_rt*hF_tm; }
				else { hF[0]=hF2_0+hF2_rt*(hF_tm-hF1_tm); }
				
				hF_tm+=tmstp_vs2;
				
				if(hF_tm<=hF1_tm) { hF[1]=hF1_0+hF1_rt*hF_tm; }
				else if(hF_tm<=hF2_tm) { hF[1]=hF2_0+hF2_rt*(hF_tm-hF1_tm); }
				else { hF[1]=hF2_0+hF2_rt*(hF2_tm-hF1_tm); }
			}
		}
		
		tm+=tmestep;
	}
	
	if(surf)
	{
		absr=surf;
		hF_absr=mat.absorption(*absr)/surf_area;
		
		if(rand_absr)
		{
			rand_val=rand()/(RAND_MAX+1.0);
			hF_left=((hF_absr>=rand_val) ? 0.0 : 1.0);
		}
		else { hF_left=1.0-hF_absr; }
	}
}

bool Bound::inp_indepthElem(Elem* indepth)
{
	if(hF_left>1.0e-3)
	{
		extern Comps mat;
		if(rand_absr)
		{
			hF_absr+=(1.0-hF_absr)*mat.absorption(*indepth)/surf_area;
			if(hF_absr>=rand_val) { absr=indepth; hF_left=0.0; }
		}
		else
		{
			double n_hF_absr=hF_left*mat.absorption(*indepth)/surf_area;
			if((n_hF_absr>=hF_absr)&&(hF_left>=hF_absr))
			{
				absr=indepth; hF_absr=n_hF_absr;
			}
			hF_left-=n_hF_absr;
		}
		
		return true;
	}
	else { return false; }
}

void Bound::calculate(bool calc_der)
{
	extern Comps mat;
	double IGN=0.0;
	for(int F=0; F<mF_Num; F++)
	{
		if(mF_expf[F])
		{
			mF[F]=mF_par0[F]*exp(-mF_par1[F]/(Consts::R*surf->massT[mat.Ncomps()]));
		}
		else
		{
			mF[F]=mF_par0[F]*(surf->massT[mF_cInd[F]]/surf->properts->vol-mF_par1[F]/
				              surf->properts->one_vs_dns[mF_cInd[F]]);
		}
		
		if(mF[F]>0.0)
		{
			for(int iF=0; iF<ign_mF_Num; iF++)
			{
				if(ign_mF_cInd[iF]==mF_cInd[F]) { IGN+=mF[F]/ign_mF[iF]; }
			}
		}
		
		mF[F]*=surf_area;
		surf->massT_rate[mF_cInd[F]].rt0-=mF[F];
		totl_mF[mF_cInd[F]]+=mF[F];
	}
	
	if(calc_der)
	{
		for(int F=0; F<mF_Num; F++)
		{
			if(mF_expf[F])
			{
				surf->massT_rate[mF_cInd[F]].thisElem[mat.Ncomps()]-=mF[F]*mF_par1[F]/
					                                            (Consts::R*
																 surf->massT[mat.Ncomps()]*
																 surf->massT[mat.Ncomps()]);
			}
			else
			{
				double par0_area=mF_par0[F]*surf_area;
				double m_vs_vol2=surf->massT[mF_cInd[F]]/surf->properts->vol/
					                                     surf->properts->vol;
				
				for(int c=0; c<mat.Ncomps(); c++)
				{
					if(mF_cInd[F]==c)
					{
						surf->massT_rate[mF_cInd[F]].thisElem[c]-=par0_area*
							                             (1.0/surf->properts->vol-m_vs_vol2*
														  surf->properts->d_vol_dm[c]);
					}
					else
					{
						surf->massT_rate[mF_cInd[F]].thisElem[c]+=par0_area*m_vs_vol2*
							                                    surf->properts->d_vol_dm[c];
					}
				}
				surf->massT_rate[mF_cInd[F]].thisElem[mat.Ncomps()]+=par0_area*
					            (m_vs_vol2*surf->properts->d_vol_dT+mF_par1[F]*
								 mat.d_comp_dens_dT(mF_cInd[F],surf->massT[mat.Ncomps()]));
			}
		}
		
		double heat;
		if(IGN>=1.0)
		{
			heat=flm_cnv_coef*surf_area;
			
			surf->massT_rate[mat.Ncomps()].thisElem[mat.Ncomps()]-=heat;
			
			heat*=flm_outT-surf->massT[mat.Ncomps()];
			surf->massT_rate[mat.Ncomps()].rt0+=heat;
			totl_hF+=heat;
		}
		else
		{
			heat=cnv_coef*surf_area;
			
			surf->massT_rate[mat.Ncomps()].thisElem[mat.Ncomps()]-=heat;
			
			surf->massT_rate[mat.Ncomps()].rt0+=heat*(outT[1]-surf->massT[mat.Ncomps()]);
			totl_hF+=heat*(outT[0]-surf->massT[mat.Ncomps()]);
		}
		
		if(absr->properts) { mat.import_buf(*absr); }
		else { mat.volume(*absr); }
		double emis_area=mat.emissivity()*surf_area;
		if(hF_left>1.0e-3) { emis_area*=1.0-hF_left; }
		heat=Consts::SIGMA*pow(absr->massT[mat.Ncomps()],4);
		
		absr->massT_rate[mat.Ncomps()].thisElem[mat.Ncomps()]-=4.0*emis_area*heat/
			                                                   absr->massT[mat.Ncomps()];
		
		if(IGN>=1.0) { heat-=flm_hF; }
		absr->massT_rate[mat.Ncomps()].rt0+=(hF[1]-heat)*emis_area;
		totl_hF+=(hF[0]-heat)*emis_area;
	}
	else
	{
		double heat;
		if(IGN>=1.0) { heat=flm_cnv_coef*(flm_outT-surf->massT[mat.Ncomps()]); }
		else { heat=cnv_coef*(outT[0]-surf->massT[mat.Ncomps()]); }
		
		heat*=surf_area;
		surf->massT_rate[mat.Ncomps()].rt0+=heat;
		totl_hF+=heat;
		
		heat=hF[0]-Consts::SIGMA*pow(absr->massT[mat.Ncomps()],4);
		if(IGN>=1.0) { heat+=flm_hF; }
		if(absr->properts) { mat.import_buf(*absr); }
		else { mat.volume(*absr); }
		heat*=mat.emissivity();
		if(hF_left>1.0e-3) { heat*=1.0-hF_left; }
		
		heat*=surf_area;
		absr->massT_rate[mat.Ncomps()].rt0+=heat;
		totl_hF+=heat;
	}
	
	totl_area+=surf_area;
}

void Bound::report(std::ostream& output,bool header)
{
	extern Comps mat;
	if(header)
	{
		output<<"BOUNDARY\tAREA [m^2]   \tHEAT FLOW IN [J/s]\tMASS FLOW OUT [kg/s]:";
		for(int c=0; c<mat.Ncomps(); c++) { output<<"\t"<<mat.comp_name(c); }
		output<<"\n";
	}
	
	output<<id<<"\t"<<totl_area<<"\t"<<totl_hF<<"\t";
	for(int c=0; c<mat.Ncomps(); c++) { output<<"\t"<<totl_mF[c]; }
	output<<"\n";
}