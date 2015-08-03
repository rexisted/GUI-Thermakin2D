#include "Boundary2D.h"

void Bound2D::zero()
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
	
	ign_pos=-1.0; totl_IGN=0.0;
	
	surf=absr=NULL;
	surf_pos=surf_area=0.0;
	rand_absr=false;
	T_back=hF_back=hF_absr=hF_left=0.0;
	
	EhF1_tbeg=EhF1_tend=EhF2_tbeg=EhF2_tend=EhF3_tbeg=EhF3_tend=0.0;
	EhF1_ramp=EhF2_ramp=EhF3_ramp='H';
	
	for(int i=0; i<3; i++)
	{
		EhF1_pos[i]=EhF1_val[i]=EhF1_chg[i]=0.0;
		EhF2_pos[i]=EhF2_val[i]=EhF2_chg[i]=0.0;
		EhF3_pos[i]=EhF3_val[i]=EhF3_chg[i]=0.0;
	}
	
	EhF1_coef=EhF2_coef=EhF3_coef=0.0;
	
	fL_val=fL_fct=0.0; fL_pow=1.0;
	fhFins_pos=fhFins_val[0]=fhFins_val[1]=0.0;
	fhFbel=fhFabv_fct[0]=fhFabv_fct[1]=fhFabv_pow=0.0;
	fhFabv_ad=1.0;
	fhF_coef=0.0;
	
	totl_area=totl_hF=0.0;
}

bool Bound2D::load(std::istringstream& boundpar,std::string name)
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
		} while(buf!="EXTERNAL");
	}
	else
	{
		do { if(!(boundpar>>buf)) { return false; } } while(buf!="EXTERNAL");
	}
	
	if(!((boundpar>>buf)&&(buf=="HEAT")&&(boundpar>>buf)&&(buf=="FLUX")&&(boundpar>>buf)&&
		 (buf=="1:")&&(boundpar>>buf))) { return false; }
	
	if(buf=="YES")
	{
		if(!((boundpar>>buf)&&(buf=="START")&&(boundpar>>buf)&&(buf=="&")&&(boundpar>>buf)&&
			 (buf=="END")&&(boundpar>>buf)&&(buf=="TIMES:")&&(boundpar>>EhF1_tbeg)&&
			 (boundpar>>EhF1_tend)&&(boundpar>>buf)&&(buf=="RAMP:")&&(boundpar>>buf)))
		     { return false; }
		
		if(buf=="UP") { EhF1_ramp='U'; } else if (buf=="DOWN") { EhF1_ramp='D'; }
		
		if(!((boundpar>>buf)&&(buf=="MODE:")&&(boundpar>>buf))) { return false; }
		
		if(buf=="CONV")
		{
			if(!((boundpar>>buf)&&(buf=="CONVECTION")&&(boundpar>>buf)&&(buf=="COEFF:")&&
				 (boundpar>>EhF1_coef))) { return false; }
		}
		
		if(!((boundpar>>buf)&&(buf=="POSITION")&&(boundpar>>buf)&&(buf=="DEPEND1:")&&
			 (boundpar>>EhF1_val[0])&&(boundpar>>EhF1_chg[0])&&(boundpar>>EhF1_pos[0])&&
			 (boundpar>>buf)&&(buf=="POSITION")&&(boundpar>>buf)&&(buf=="DEPEND2:")&&
			 (boundpar>>EhF1_val[1])&&(boundpar>>EhF1_chg[1])&&(boundpar>>EhF1_pos[1])&&
			 (boundpar>>buf)&&(buf=="POSITION")&&(boundpar>>buf)&&(buf=="DEPEND3:")&&
			 (boundpar>>EhF1_val[2])&&(boundpar>>EhF1_chg[2])&&(boundpar>>EhF1_pos[2])&&
			 (boundpar>>buf)&&(buf=="EXTERNAL"))) { return false; }
	}
	else
	{
		do { if(!(boundpar>>buf)) { return false; } } while(buf!="EXTERNAL");
	}
	
	if(!((boundpar>>buf)&&(buf=="HEAT")&&(boundpar>>buf)&&(buf=="FLUX")&&(boundpar>>buf)&&
		 (buf=="2:")&&(boundpar>>buf))) { return false; }
	
	if(buf=="YES")
	{
		if(!((boundpar>>buf)&&(buf=="START")&&(boundpar>>buf)&&(buf=="&")&&(boundpar>>buf)&&
			 (buf=="END")&&(boundpar>>buf)&&(buf=="TIMES:")&&(boundpar>>EhF2_tbeg)&&
			 (boundpar>>EhF2_tend)&&(boundpar>>buf)&&(buf=="RAMP:")&&(boundpar>>buf)))
		     { return false; }
		
		if(buf=="UP") { EhF2_ramp='U'; } else if (buf=="DOWN") { EhF2_ramp='D'; }
		
		if(!((boundpar>>buf)&&(buf=="MODE:")&&(boundpar>>buf))) { return false; }
		
		if(buf=="CONV")
		{
			if(!((boundpar>>buf)&&(buf=="CONVECTION")&&(boundpar>>buf)&&(buf=="COEFF:")&&
				 (boundpar>>EhF2_coef))) { return false; }
		}
		
		if(!((boundpar>>buf)&&(buf=="POSITION")&&(boundpar>>buf)&&(buf=="DEPEND1:")&&
			 (boundpar>>EhF2_val[0])&&(boundpar>>EhF2_chg[0])&&(boundpar>>EhF2_pos[0])&&
			 (boundpar>>buf)&&(buf=="POSITION")&&(boundpar>>buf)&&(buf=="DEPEND2:")&&
			 (boundpar>>EhF2_val[1])&&(boundpar>>EhF2_chg[1])&&(boundpar>>EhF2_pos[1])&&
			 (boundpar>>buf)&&(buf=="POSITION")&&(boundpar>>buf)&&(buf=="DEPEND3:")&&
			 (boundpar>>EhF2_val[2])&&(boundpar>>EhF2_chg[2])&&(boundpar>>EhF2_pos[2])&&
			 (boundpar>>buf)&&(buf=="EXTERNAL"))) { return false; }
	}
	else
	{
		do { if(!(boundpar>>buf)) { return false; } } while(buf!="EXTERNAL");
	}
	
	if(!((boundpar>>buf)&&(buf=="HEAT")&&(boundpar>>buf)&&(buf=="FLUX")&&(boundpar>>buf)&&
		 (buf=="3:")&&(boundpar>>buf))) { return false; }
	
	if(buf=="YES")
	{
		if(!((boundpar>>buf)&&(buf=="START")&&(boundpar>>buf)&&(buf=="&")&&(boundpar>>buf)&&
			 (buf=="END")&&(boundpar>>buf)&&(buf=="TIMES:")&&(boundpar>>EhF3_tbeg)&&
			 (boundpar>>EhF3_tend)&&(boundpar>>buf)&&(buf=="RAMP:")&&(boundpar>>buf)))
		     { return false; }
		
		if(buf=="UP") { EhF3_ramp='U'; } else if (buf=="DOWN") { EhF3_ramp='D'; }
		
		if(!((boundpar>>buf)&&(buf=="MODE:")&&(boundpar>>buf))) { return false; }
		
		if(buf=="CONV")
		{
			if(!((boundpar>>buf)&&(buf=="CONVECTION")&&(boundpar>>buf)&&(buf=="COEFF:")&&
				 (boundpar>>EhF3_coef))) { return false; }
		}
		
		if(!((boundpar>>buf)&&(buf=="POSITION")&&(boundpar>>buf)&&(buf=="DEPEND1:")&&
			 (boundpar>>EhF3_val[0])&&(boundpar>>EhF3_chg[0])&&(boundpar>>EhF3_pos[0])&&
			 (boundpar>>buf)&&(buf=="POSITION")&&(boundpar>>buf)&&(buf=="DEPEND2:")&&
			 (boundpar>>EhF3_val[1])&&(boundpar>>EhF3_chg[1])&&(boundpar>>EhF3_pos[1])&&
			 (boundpar>>buf)&&(buf=="POSITION")&&(boundpar>>buf)&&(buf=="DEPEND3:")&&
			 (boundpar>>EhF3_val[2])&&(boundpar>>EhF3_chg[2])&&(boundpar>>EhF3_pos[2])&&
			 (boundpar>>buf)&&(buf=="FLAME:"))) { return false; }
	}
	else
	{
		do { if(!(boundpar>>buf)) { return false; } } while(buf!="FLAME:");
	}
	
	if(!(boundpar>>buf)) { return false; }
	
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
		} while(buf!="FLAME");
		
		if(!((boundpar>>buf)&&(buf=="LENGTH:")&&(boundpar>>fL_val)&&(boundpar>>fL_fct)&&
			 (boundpar>>fL_pow)&&(boundpar>>buf)&&(buf=="HEAT")&&(boundpar>>buf)&&
			 (buf=="FLUX")&&(boundpar>>buf)&&(buf=="MODE:")&&
			 (boundpar>>buf))) { return false; }
		
		if(buf=="CONV")
		{
			if(!((boundpar>>buf)&&(buf=="CONVECTION")&&(boundpar>>buf)&&(buf=="COEFF:")&&
				 (boundpar>>fhF_coef))) { return false; }
		}
		
		if(!((boundpar>>buf)&&(buf=="HEAT")&&(boundpar>>buf)&&(buf=="FLUX")&&
			 (boundpar>>buf)&&(buf=="INSIDE:")&&(boundpar>>fhFins_val[0])&&
			 (boundpar>>fhFins_pos)&&(boundpar>>fhFins_val[1])&&(boundpar>>buf)&&
			 (buf=="HEAT")&&(boundpar>>buf)&&(buf=="FLUX")&&(boundpar>>buf)&&
			 (buf=="BELOW:")&&(boundpar>>fhFbel)&&(boundpar>>buf)&&(buf=="HEAT")&&
			 (boundpar>>buf)&&(buf=="FLUX")&&(boundpar>>buf)&&(buf=="ABOVE:")&&
			 (boundpar>>fhFabv_fct[0])&&(boundpar>>fhFabv_pow)&&(boundpar>>fhFabv_ad)&&
			 (boundpar>>buf)&&(buf=="BACKGROUND"))) { return false; }
	}
	else
	{
		do { if(!(boundpar>>buf)) { return false; } } while(buf!="BACKGROUND");
	}
	
	if(!((boundpar>>buf)&&(buf=="TEMP:")&&(boundpar>>T_back)&&(boundpar>>buf)&&
		 (buf=="RADIAT")&&(boundpar>>buf)&&(buf=="ABSORPT")&&(boundpar>>buf)&&
		 (buf=="MODE:")&&(boundpar>>buf))) { return false; }
	
	fhFabv_fct[1]=fhFabv_fct[0]; fhFabv_fct[0]*=fhFins_val[0]; fhFabv_fct[1]*=fhFins_val[1];
	hF_back=Consts::SIGMA*pow(T_back,4);
	if(buf=="RAND") { rand_absr=true; srand((unsigned)time(NULL)); }
	
	return true;
}

void Bound2D::massflow(Elem* surface,char surf_axis,double position,bool calc_der)
{
	switch(surf_axis)
	{
		case 'X': surf_area=surface->Ydim*surface->Zdim; break;
		case 'Y': surf_area=surface->Xdim*surface->Zdim; break;
		case 'Z': surf_area=surface->Xdim*surface->Ydim; break;
		default: surf_area=1.0;
	}
	totl_area+=surf_area;
	
	extern Comps mat;
	double IGN=0.0;
	for(int F=0; F<mF_Num; F++)
	{
		if(mF_expf[F])
		{
			mF[F]=mF_par0[F]*exp(-mF_par1[F]/(Consts::R*surface->massT[mat.Ncomps()]));
		}
		else
		{
			mF[F]=mF_par0[F]*(surface->massT[mF_cInd[F]]/surface->properts->vol-mF_par1[F]/
				              surface->properts->one_vs_dns[mF_cInd[F]]);
		}
		
		if(mF[F]>0.0)
		{
			for(int iF=0; iF<ign_mF_Num; iF++)
			{
				if(ign_mF_cInd[iF]==mF_cInd[F]) { IGN+=mF[F]/ign_mF[iF]; }
			}
		}
		
		mF[F]*=surf_area;
		surface->massT_rate[mF_cInd[F]].rt0-=mF[F];
		totl_mF[mF_cInd[F]]+=mF[F];
	}
	
	if((ign_pos<0.0)&&(IGN>=1.0)) { ign_pos=position; }
	totl_IGN+=IGN*surf_area;
	
	if(calc_der)
	{
		for(int F=0; F<mF_Num; F++)
		{
			if(mF_expf[F])
			{
				surface->massT_rate[mF_cInd[F]].thisElem[mat.Ncomps()]-=mF[F]*mF_par1[F]/
					                                            (Consts::R*
																 surface->massT[mat.Ncomps()]*
																 surface->massT[mat.Ncomps()]);
			}
			else
			{
				double par0_area=mF_par0[F]*surf_area;
				double m_vs_vol2=surface->massT[mF_cInd[F]]/surface->properts->vol/
					                                        surface->properts->vol;
				
				for(int c=0; c<mat.Ncomps(); c++)
				{
					if(mF_cInd[F]==c)
					{
						surface->massT_rate[mF_cInd[F]].thisElem[c]-=par0_area*
							                             (1.0/surface->properts->vol-m_vs_vol2*
														  surface->properts->d_vol_dm[c]);
					}
					else
					{
						surface->massT_rate[mF_cInd[F]].thisElem[c]+=par0_area*m_vs_vol2*
							                                    surface->properts->d_vol_dm[c];
					}
				}
				surface->massT_rate[mF_cInd[F]].thisElem[mat.Ncomps()]+=par0_area*
					            (m_vs_vol2*surface->properts->d_vol_dT+mF_par1[F]*
								 mat.d_comp_dens_dT(mF_cInd[F],surface->massT[mat.Ncomps()]));
			}
		}
	}
}

void Bound2D::inp_surfElem(Elem* surface,char surf_axis,double position)
{
	surf=surface;
	absr=surface;
	surf_pos=position;
	
	switch(surf_axis)
	{
		case 'X': surf_area=surf->Ydim*surf->Zdim; break;
		case 'Y': surf_area=surf->Xdim*surf->Zdim; break;
		case 'Z': surf_area=surf->Xdim*surf->Ydim; break;
		default: surf_area=1.0;
	}
	
	extern Comps mat;
	hF_absr=mat.absorption(*absr)/surf_area;
	if(rand_absr)
	{
		rand_val=rand()/(RAND_MAX+1.0);
		hF_left=((hF_absr>=rand_val) ? 0.0 : 1.0);
	}
	else { hF_left=1.0-hF_absr; }
}

bool Bound2D::inp_indpElem(Elem* indepth)
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

double Bound2D::heatflow(double tme,bool calc_der)
{
	double totl_hF_old=totl_hF;
	
	extern Comps mat;
	if(absr->properts) { mat.import_buf(*absr); }
	else { mat.volume(*absr); }
	double emis_area=mat.emissivity()*surf_area;
	if(hF_left>1.0e-3) { emis_area*=1.0-hF_left; }
	
	double heat=emis_area*Consts::SIGMA*pow(absr->massT[mat.Ncomps()],4);
	if(calc_der)
	{
		absr->massT_rate[mat.Ncomps()].thisElem[mat.Ncomps()]-=4.0*heat/absr->massT[mat.Ncomps()];
	}
	heat-=emis_area*hF_back;
	absr->massT_rate[mat.Ncomps()].rt0-=heat;
	totl_hF-=heat;
	
	if((tme>=EhF1_tbeg)&&(tme<EhF1_tend))
	{
		bool yesheat=true;
		if(surf_pos<EhF1_pos[0]) { heat=EhF1_val[0]+EhF1_chg[0]*surf_pos; }
		else if(surf_pos<EhF1_pos[1]) { heat=EhF1_val[1]+EhF1_chg[1]*surf_pos; }
		else if(surf_pos<EhF1_pos[2]) { heat=EhF1_val[2]+EhF1_chg[2]*surf_pos; }
		else { yesheat=false; }
		
		if(yesheat)
		{
			if(EhF1_coef!=0.0)
			{
				heat+=T_back;
				heat-=surf->massT[mat.Ncomps()];
				double coef_area=EhF1_coef*surf_area;
				if(EhF1_ramp=='U') { coef_area*=(tme-EhF1_tbeg)/(EhF1_tend-EhF1_tbeg); }
				else if(EhF1_ramp=='D') { coef_area*=(EhF1_tend-tme)/(EhF1_tend-EhF1_tbeg); }
				heat*=coef_area;
				
				surf->massT_rate[mat.Ncomps()].rt0+=heat;
				if(calc_der) { surf->massT_rate[mat.Ncomps()].thisElem[mat.Ncomps()]-=coef_area; }
				totl_hF+=heat;
			}
			else
			{
				heat*=emis_area;
				if(EhF1_ramp=='U') { heat*=(tme-EhF1_tbeg)/(EhF1_tend-EhF1_tbeg); }
				else if(EhF1_ramp=='D') { heat*=(EhF1_tend-tme)/(EhF1_tend-EhF1_tbeg); }
				absr->massT_rate[mat.Ncomps()].rt0+=heat;
				totl_hF+=heat;
			}
		}
	}
	
	if((tme>=EhF2_tbeg)&&(tme<EhF2_tend))
	{
		bool yesheat=true;
		if(surf_pos<EhF2_pos[0]) { heat=EhF2_val[0]+EhF2_chg[0]*surf_pos; }
		else if(surf_pos<EhF2_pos[1]) { heat=EhF2_val[1]+EhF2_chg[1]*surf_pos; }
		else if(surf_pos<EhF2_pos[2]) { heat=EhF2_val[2]+EhF2_chg[2]*surf_pos; }
		else { yesheat=false; }
		
		if(yesheat)
		{
			if(EhF2_coef!=0.0)
			{
				heat+=T_back;
				heat-=surf->massT[mat.Ncomps()];
				double coef_area=EhF2_coef*surf_area;
				if(EhF2_ramp=='U') { coef_area*=(tme-EhF2_tbeg)/(EhF2_tend-EhF2_tbeg); }
				else if(EhF2_ramp=='D') { coef_area*=(EhF2_tend-tme)/(EhF2_tend-EhF2_tbeg); }
				heat*=coef_area;
				
				surf->massT_rate[mat.Ncomps()].rt0+=heat;
				if(calc_der) { surf->massT_rate[mat.Ncomps()].thisElem[mat.Ncomps()]-=coef_area; }
				totl_hF+=heat;
			}
			else
			{
				heat*=emis_area;
				if(EhF2_ramp=='U') { heat*=(tme-EhF2_tbeg)/(EhF2_tend-EhF2_tbeg); }
				else if(EhF2_ramp=='D') { heat*=(EhF2_tend-tme)/(EhF2_tend-EhF2_tbeg); }
				absr->massT_rate[mat.Ncomps()].rt0+=heat;
				totl_hF+=heat;
			}
		}
	}
	
	if((tme>=EhF3_tbeg)&&(tme<EhF3_tend))
	{
		bool yesheat=true;
		if(surf_pos<EhF3_pos[0]) { heat=EhF3_val[0]+EhF3_chg[0]*surf_pos; }
		else if(surf_pos<EhF3_pos[1]) { heat=EhF3_val[1]+EhF3_chg[1]*surf_pos; }
		else if(surf_pos<EhF3_pos[2]) { heat=EhF3_val[2]+EhF3_chg[2]*surf_pos; }
		else { yesheat=false; }
		
		if(yesheat)
		{
			if(EhF3_coef!=0.0)
			{
				heat+=T_back;
				heat-=surf->massT[mat.Ncomps()];
				double coef_area=EhF3_coef*surf_area;
				if(EhF3_ramp=='U') { coef_area*=(tme-EhF3_tbeg)/(EhF3_tend-EhF3_tbeg); }
				else if(EhF3_ramp=='D') { coef_area*=(EhF3_tend-tme)/(EhF3_tend-EhF3_tbeg); }
				heat*=coef_area;
				
				surf->massT_rate[mat.Ncomps()].rt0+=heat;
				if(calc_der) { surf->massT_rate[mat.Ncomps()].thisElem[mat.Ncomps()]-=coef_area; }
				totl_hF+=heat;
			}
			else
			{
				heat*=emis_area;
				if(EhF3_ramp=='U') { heat*=(tme-EhF3_tbeg)/(EhF3_tend-EhF3_tbeg); }
				else if(EhF3_ramp=='D') { heat*=(EhF3_tend-tme)/(EhF3_tend-EhF3_tbeg); }
				absr->massT_rate[mat.Ncomps()].rt0+=heat;
				totl_hF+=heat;
			}
		}
	}
	
	if(ign_pos>=0.0)
	{
		double sfpos=surf_pos-ign_pos;
		double flhgt=fL_val+fL_fct*std::pow(totl_IGN,fL_pow);
		
		if(flhgt>0.0)
		{
			if(sfpos<0.0) { heat=fhFins_val[0]*std::exp(-fhFbel*std::pow(sfpos,2)); }
			else if(sfpos<flhgt) { heat=((sfpos<fhFins_pos) ? fhFins_val[0] : fhFins_val[1]); }
			else
			{
				if(sfpos<fhFins_pos) { heat=fhFabv_fct[0]*std::exp(-fhFabv_pow*
					                           std::pow((sfpos+fhFabv_ad)/(flhgt+fhFabv_ad),2)); }
				else { heat=fhFabv_fct[1]*std::exp(-fhFabv_pow*
					                           std::pow((sfpos+fhFabv_ad)/(flhgt+fhFabv_ad),2)); }
			}
			
			if(fhF_coef!=0.0)
			{
				heat+=T_back;
				heat-=surf->massT[mat.Ncomps()];
				double coef_area=fhF_coef*surf_area;
				heat*=coef_area;
				
				surf->massT_rate[mat.Ncomps()].rt0+=heat;
				if(calc_der) { surf->massT_rate[mat.Ncomps()].thisElem[mat.Ncomps()]-=coef_area; }
				totl_hF+=heat;
			}
			else
			{
				heat*=emis_area;
				absr->massT_rate[mat.Ncomps()].rt0+=heat;
				totl_hF+=heat;
			}
		}
		else { ign_pos=-1.0; }
	}
	
	return ((totl_hF-totl_hF_old)/surf_area);
}

void Bound2D::report(std::ostream& output,bool header)
{
	extern Comps mat;
	if(header)
	{
		output<<"BOUNDARY\tAREA [m^2]   \tFLAME POS [m]\tHEAT FLOW IN [J/s]\tMASS FLOW OUT [kg/s]:";
		for(int c=0; c<mat.Ncomps(); c++) { output<<"\t"<<mat.comp_name(c); }
		output<<"\n";
	}
	
	if(fabs(totl_hF)<1.0e-11) { totl_hF=0.0; }
	
	output<<id<<"\t"<<totl_area<<"\t";
	if(ign_pos<0.0) { output<<"- No Flame --"; } else { output <<ign_pos; }
	output<<"\t"<<totl_hF<<"\t";
	for(int c=0; c<mat.Ncomps(); c++) { output<<"\t"<<totl_mF[c]; }
	output<<"\n";
}