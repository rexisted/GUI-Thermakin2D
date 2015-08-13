#ifndef Consts_DEFINED
#define Consts_DEFINED

namespace Consts
{
	const int VERSION=4; // Version of the ThermaKin program
	
	const double R=8.31447; // Gas constant in J/(mol*K)
	const double SIGMA=5.67040e-8; // Stefan-Boltzmann constant in W/(m^2*K^4)
	
	const double MAX_VAL=1.0e308; // Maximum absolute numerical value allowed
	const double MAX_MASS=1.0e7; // Maximum mass of element in kg
	const double MIN_MASS=1.0e-30; // Minimum mass of element in kg
	const double MAX_TEMP=1.0e7; // Maximum temperature allowed in K
	const double MIN_TEMP=1.0e-10; // Minimum temperature allowed in K
	
	const double MIN_BOUND_ELEM_SIZE=0.2; // Minimum fractional boundary element or column size
	const int MAX_ELEM=50000; // Maximum number of elements in 1D object
	const int MAX_ELEM_COLM=1501; // Maximum number of elements in column of 2D object
	const int MAX_COLM=1501; // Maximum number of columns
	
	const int MAX_CMP=30; // Maximum number of components
	const int MAX_RXN=30; // Maximum number of reactions
	
	const int MAX_CHR=30000; // Maximum number of characters in input file
	const int OUT_PREC=6; // Number of digits after decimal point in output
}

#endif