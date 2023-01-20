// Needed for the ffem structures
#include "ff++.hpp"
#include "AFunction_ext.hpp"

// Load cell model C code

#include "gray_pathmanathan_2016.h"

// Wrappers for calling
int ffinitConsts( KN< double > *const &CONSTANTS,
		  KN< double > *const &RATES,
		  KN< double > *const &STATES
		  )
{

  initConsts(CONSTANTS[0], RATES[0], STATES[0]);
  return 0;
}
int ffcomputeRates( const double &VOI,
		    KN< double > *const &CONSTANTS,
		    KN< double > *const &RATES,
		    KN< double > *const &STATES,
		    KN< double > *const &ALGEBRAIC
		    )
{
  computeRates(VOI, CONSTANTS[0], RATES[0], STATES[0], ALGEBRAIC[0]);
  return 0;
}
int ffcomputeVariables( const double &VOI,
			KN< double > *const &CONSTANTS,
			KN< double > *const &RATES,
			KN< double > *const &STATES,
			KN< double > *const &ALGEBRAIC
			)
{
  computeVariables(VOI, CONSTANTS[0], RATES[0], STATES[0], ALGEBRAIC[0]);
  return 0;
}

static void InitFF( ) {
Global.Add(
    "ffinitConsts", "(",
    new OneOperator3_< int, KN< double > *, KN< double > *, KN< double > * >(ffinitConsts));
Global.Add(
    "ffcomputeRates", "(",
    new OneOperator5_< int, double, KN< double > *, KN< double > *, KN< double > *, KN< double > * >(ffcomputeRates));
Global.Add(
    "ffcomputeVariables", "(",
    new OneOperator5_< int, double, KN< double > *, KN< double > *, KN< double > *, KN< double > * >(ffcomputeVariables));
}

LOADFUNC(InitFF)
