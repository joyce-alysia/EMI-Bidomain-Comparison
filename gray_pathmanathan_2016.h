/*
   There are a total of 7 entries in the algebraic variable array.
   There are a total of 3 entries in each of the rate and state variable arrays.
   There are a total of 17 entries in the constant variable array.
 */
/*
* VOI is time in component membrane (millisecond)
* STATES[0] is V in component membrane (mV)
* CONSTANTS[0] is g_Na (mS/mm^2)
* CONSTANTS[1] is E_Na (mV)
* CONSTANTS[2] is E_K (mV)
* CONSTANTS[3] is E_h (mV)
* CONSTANTS[4] is E_m (mV)
* CONSTANTS[5] is k_m (mV)
* CONSTANTS[6] is k_r (mV)
* CONSTANTS[7] is k_h (mV)
* CONSTANTS[8] is tau_m (ms)
* CONSTANTS[9] is tau_ho (ms)
* CONSTANTS[10] is delta_h (dimensionless)
* CONSTANTS[11] is g_K (mS/mm^2)
* CONSTANTS[12] is C_m (uF/mm^2)
* CONSTANTS[13] is stim_start (ms)
* CONSTANTS[14] is stim_period (ms)
* CONSTANTS[15] is stim_duration (ms)
* CONSTANTS[16] is stim_amplitude (uA/uF)
* STATES[1] is m (dimensionless)
* STATES[2] is h (dimensionless)
* RATES[0] is d/dt V (mV/ms)
* RATES[1] is d/dt m (1/ms)
* RATES[2] is d/dt h (1/ms)
* ALGEBRAIC[0] is m_inf (dimensionless)
* ALGEBRAIC[1] is h_inf (dimensionless)
* ALGEBRAIC[2] is tau_h (ms)
* ALGEBRAIC[3] is i_na (uA/mm^2)
* ALGEBRAIC[4] is i_k (uA/mm^2)
* ALGEBRAIC[5] is i_tot (uA/mm^2)
* ALGEBRAIC[6] is i_Stim (uA/uF)
*/

void initConsts(double* CONSTANTS, double* RATES, double *STATES)
{
STATES[0] = -83.000;
CONSTANTS[0] = 0.11;
CONSTANTS[1] = 65.000;
CONSTANTS[2] = -83.000;
CONSTANTS[3] = -74.700;
CONSTANTS[4] = -41.000;
CONSTANTS[5] = -4.00000;
CONSTANTS[6] = 21.280;
CONSTANTS[7] = 4.4000;
CONSTANTS[8] = 0.12000;
CONSTANTS[9] = 6.80738;
CONSTANTS[10] = 0.799163;
CONSTANTS[11] = 0.003;
CONSTANTS[12] = 0.01;
CONSTANTS[13] = 10.0000;
CONSTANTS[14] = 1000.00;
CONSTANTS[15] = 1.00000;
CONSTANTS[16] = 80.0000; 
STATES[1] = 1.00000/(1.00000 + exp(((STATES[0]-CONSTANTS[4]))/CONSTANTS[5])); //m_init = m_inf(V_init)
STATES[2] = 1.00000/(1.00000 + exp(((STATES[0]-CONSTANTS[3]))/CONSTANTS[7])); //h_init = h_inf(V_init)
}

void computeRates(double VOI, double* CONSTANTS, double* RATES, double* STATES, double* ALGEBRAIC)
{
ALGEBRAIC[0] = 1.00000/(1.00000 + exp(((STATES[0]-CONSTANTS[4]))/CONSTANTS[5]));
ALGEBRAIC[1] = 1.00000/(1.00000 + exp(((STATES[0]-CONSTANTS[3]))/CONSTANTS[7]));
ALGEBRAIC[2] = (2.00000*CONSTANTS[9]*exp((CONSTANTS[10]*(STATES[0]-CONSTANTS[3]))/CONSTANTS[7]))/(1.00000 + exp((STATES[0]-CONSTANTS[3])/CONSTANTS[7]));
RATES[1] = (ALGEBRAIC[0] - STATES[1])/CONSTANTS[8];
RATES[2] = (ALGEBRAIC[1] - STATES[2])/ALGEBRAIC[2];
ALGEBRAIC[3] = CONSTANTS[0]*pow(STATES[1],3.00000)*STATES[2]*(STATES[0]-CONSTANTS[1]);
ALGEBRAIC[4] = CONSTANTS[11]*(STATES[0]-CONSTANTS[2])*exp((-(STATES[0]-CONSTANTS[2]))/CONSTANTS[6]);
ALGEBRAIC[5] = ALGEBRAIC[3] + ALGEBRAIC[4];
ALGEBRAIC[6] = (VOI-floor(VOI/CONSTANTS[14])*CONSTANTS[14]>=CONSTANTS[13]&&VOI-floor(VOI/CONSTANTS[14])*CONSTANTS[14]<=CONSTANTS[13]+CONSTANTS[15] ? - CONSTANTS[16] : 0.00000);
RATES[0] = -ALGEBRAIC[5]/CONSTANTS[12] - ALGEBRAIC[6];
}

void computeVariables(double VOI, double* CONSTANTS, double* RATES, double* STATES, double* ALGEBRAIC)
{
ALGEBRAIC[0] = 1.00000/(1.00000 + exp(((STATES[0]-CONSTANTS[4]))/CONSTANTS[5]));
ALGEBRAIC[1] = 1.00000/(1.00000 + exp(((STATES[0]-CONSTANTS[3]))/CONSTANTS[7]));
ALGEBRAIC[2] = (2.00000*CONSTANTS[9]*exp((CONSTANTS[10]*(STATES[0]-CONSTANTS[3]))/CONSTANTS[7]))/(1.00000 + exp((STATES[0]-CONSTANTS[3])/CONSTANTS[7]));
ALGEBRAIC[3] = CONSTANTS[0]*pow(STATES[1],3.00000)*STATES[2]*(STATES[0]-CONSTANTS[1]);
ALGEBRAIC[4] = CONSTANTS[11]*(STATES[0]-CONSTANTS[2])*exp((-(STATES[0]-CONSTANTS[2]))/CONSTANTS[6]);
ALGEBRAIC[5] = ALGEBRAIC[3] + ALGEBRAIC[4];
ALGEBRAIC[6] = (VOI-floor(VOI/CONSTANTS[14])*CONSTANTS[14]>=CONSTANTS[13]&&VOI-floor(VOI/CONSTANTS[14])*CONSTANTS[14]<=CONSTANTS[13]+CONSTANTS[15] ? - CONSTANTS[16] : 0.00000);
}
