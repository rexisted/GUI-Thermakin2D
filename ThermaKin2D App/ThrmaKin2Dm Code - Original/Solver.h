#ifndef LinEqSolver_DEFINED
#define LinEqSolver_DEFINED

#include <valarray>
#include <vector>
#include "Constants.h"

class LinEqSolver
   /* This class is used to solve a block tridiagonal system of linear equations. The 
      equation coefficients and corresponding constant terms are input into eq vector of 
	  arrays. See Solver.inp for detailed input instructions. solve function generates a 
	  solution, which is output into sol array. If a singularity is encountered during the 
	  solution process, solve function returns false. improve function attempts to improve 
	  the solution. improve function uses intermediate results of solve calculations 
	  (stored in eq) and requires input of new constant terms that are equal to the 
	  difference between the results of multiplication of equation coefficients by the 
	  solution and original constant terms. improve function corrects the solution (stored 
	  in sol). */
{
public:
	
	LinEqSolver() { Neq=mxNeq=0; NmT=NmT2=NmT3=0; }
	
	void init_setup(int Ncomps=1,int Nelems=1);
	void setup(int Nelems=1);
	
	struct equation { std::valarray<double> tr; };
	std::vector<equation> eq;
	std::valarray<double> sol;
	
	bool solve();
	void improve();

private:
	
	int Neq, mxNeq;
	int NmT, NmT2, NmT3;
	
	int e, en, p, pn, t, tn;
	std::valarray<bool> subst;
};

#endif