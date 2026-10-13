/**************************************************
    Generate weights
	
	Author: A. Barabasch
	
	Version: 1.0, Created: 2023-03-01	
***************************************************/

************************************************
*    load weight data of SC6
************************************************
use "$data\SC6_Weights_R_13-0-0.dta", clear


keep ID_t sample subsample tx80101 w_t2_cal-w_t13_cal
rename tx80101 bl_strata

save "$results\temp_weights.dta", replace

