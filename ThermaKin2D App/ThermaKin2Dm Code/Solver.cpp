#include "Solver.h"

void LinEqSolver::init_setup(int Ncomps,int Nelems)
{
	NmT=Ncomps+1;
	
	mxNeq=NmT*(Nelems+Nelems);
	eq.resize(mxNeq); sol.resize(mxNeq); subst.resize(mxNeq);
	
	NmT2=NmT+NmT; NmT3=NmT2+NmT+1;
	for(e=0; e<mxNeq; e++) { eq[e].tr.resize(NmT3); }
	--NmT3;
}

void LinEqSolver::setup(int Nelems)
{
	Neq=NmT*Nelems;
	
	if(Neq>mxNeq)
	{
		mxNeq=Neq+Neq;
		eq.resize(mxNeq); sol.resize(mxNeq); subst.resize(mxNeq);
		
		++NmT3;
		for(e=0; e<mxNeq; e++) { eq[e].tr.resize(NmT3); }
		--NmT3;
	}
}

bool LinEqSolver::solve()
{
	bool no_singulrs=true;
	
	double mx_t, mx_p;
	int eq1_cbk=0;
	int eq1_nbk=NmT;
	int eq1_nnbk=NmT2;
	if(NmT2>Neq) { eq1_nnbk=NmT; }
	while(eq1_cbk<Neq)
	{
		for(e=eq1_cbk, p=NmT, pn=0; e<eq1_nbk; e++, p++, pn++)
		{
			mx_t=fabs(eq[e].tr[NmT3]);
			for(t=p; t<NmT3; t++)
			{
				if(mx_t<fabs(eq[e].tr[t])) { mx_t=fabs(eq[e].tr[t]); }
			}
			
			mx_p=0.0;
			for(en=e+1; en<eq1_nbk; en++)
			{
				if(mx_p<fabs(eq[en].tr[p])) { mx_p=fabs(eq[en].tr[p]); }
			}
			for(en=eq1_nbk; en<eq1_nnbk; en++)
			{
				if(mx_p<fabs(eq[en].tr[pn])) { mx_p=fabs(eq[en].tr[pn]); }
			}
			
			if(fabs((mx_p/eq[e].tr[p])*mx_t)<=Consts::MAX_VAL)
			{
				subst[e]=true;
				
				for(en=e+1; en<eq1_nbk; en++)
				{
					eq[en].tr[p]/=eq[e].tr[p];
					for(t=p+1; t<=NmT3; t++)
					{
						eq[en].tr[t]-=eq[en].tr[p]*eq[e].tr[t];
					}
				}
				for(en=eq1_nbk; en<eq1_nnbk; en++)
				{
					eq[en].tr[pn]/=eq[e].tr[p];
					for(tn=pn+1, t=p+1; tn<NmT2; tn++, t++)
					{
						eq[en].tr[tn]-=eq[en].tr[pn]*eq[e].tr[t];
					}
					eq[en].tr[NmT3]-=eq[en].tr[pn]*eq[e].tr[NmT3];
				}
			}
			else
			{
				subst[e]=false; no_singulrs=false;
				
				for(en=e+1; en<eq1_nbk; en++)
				{
					eq[en].tr[NmT3]-=eq[en].tr[p]*sol[e];
				}
				for(en=eq1_nbk; en<eq1_nnbk; en++)
				{
					eq[en].tr[NmT3]-=eq[en].tr[pn]*sol[e];
				}
			}
		}
		
		eq1_cbk+=NmT; eq1_nbk+=NmT;
		if(eq1_nbk<Neq) { eq1_nnbk+=NmT; } else { eq1_nnbk=eq1_nbk; }
	}
	
	p=NmT2;
	en=Neq-NmT;
	for(e=Neq-1; e>=0; e--)
	{
		if(p>NmT) { --p; } else { p=NmT2-1; }
		
		if(subst[e])
		{
			if(e<en)
			{
				for(t=p+1, tn=e+1; t<NmT3; t++, tn++)
				{
					eq[e].tr[NmT3]-=eq[e].tr[t]*sol[tn];
				}
			}
			else
			{
				for(t=p+1, tn=e+1; tn<Neq; t++, tn++)
				{
					eq[e].tr[NmT3]-=eq[e].tr[t]*sol[tn];
				}
			}
			eq[e].tr[NmT3]/=eq[e].tr[p];
			
			if(fabs(eq[e].tr[NmT3])<=Consts::MAX_VAL) { sol[e]=eq[e].tr[NmT3]; }
			else { no_singulrs=false; }
		}
	}
	
	return no_singulrs;
}

void LinEqSolver::improve()
{
	int eq1_cbk=0;
	int eq1_nbk=NmT;
	int eq1_nnbk=NmT2;
	if(NmT2>Neq) { eq1_nnbk=NmT; }
	while(eq1_cbk<Neq)
	{
		for(e=eq1_cbk, p=NmT, pn=0; e<eq1_nbk; e++, p++, pn++)
		{
			if(subst[e])
			{
				for(en=e+1; en<eq1_nbk; en++)
				{
					eq[en].tr[NmT3]-=eq[en].tr[p]*eq[e].tr[NmT3];
				}
				for(en=eq1_nbk; en<eq1_nnbk; en++)
				{
					eq[en].tr[NmT3]-=eq[en].tr[pn]*eq[e].tr[NmT3];
				}
			}
		}
		
		eq1_cbk+=NmT; eq1_nbk+=NmT;
		if(eq1_nbk<Neq) { eq1_nnbk+=NmT; } else { eq1_nnbk=eq1_nbk; }
	}
	
	p=NmT2;
	en=Neq-NmT;
	for(e=Neq-1; e>=0; e--)
	{
		if(p>NmT) { --p; } else { p=NmT2-1; }
		
		if(e<en)
		{
			for(t=p+1, tn=e+1; t<NmT3; t++, tn++)
			{
				eq[e].tr[NmT3]-=eq[e].tr[t]*eq[tn].tr[NmT3];
			}
		}
		else
		{
			for(t=p+1, tn=e+1; tn<Neq; t++, tn++)
			{
				eq[e].tr[NmT3]-=eq[e].tr[t]*eq[tn].tr[NmT3];
			}
		}
		eq[e].tr[NmT3]/=eq[e].tr[p];
		
		if(fabs(eq[e].tr[NmT3])<=Consts::MAX_VAL) { sol[e]-=eq[e].tr[NmT3]; }
		else { eq[e].tr[NmT3]=0.0; }
	}
}