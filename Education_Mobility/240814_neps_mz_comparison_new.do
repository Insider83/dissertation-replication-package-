/**************************************************
    Compute 1 year mobility 
	
	Author: A. Barabasch
	
	Version: 1.0, Created: 2024-10-01	
***************************************************/


****************************weighting with 2011 weights*************************


use "$results\0_basicpanel_new.dta", clear

keep if inrange(age,30,49)
drop if w_t4_cal == 0

recode mig_flow1 (99=.) (0=0) (1=1), gen(migflow1)
label val migflow1 mig_def
label var migflow1 "1-year mobility (vs. 12 months prior)"

keep if migflow1 != .


merge m:1 ID_t using "$results\educ_final.dta", keepusing(abi)
drop if _merge == 2
drop _merge
replace abi = 0 if inrange(casmin,0,4) & abi == .
replace abi = 1 if inrange(casmin,5,8) & abi == .


save "$results\migflow1_vergleich_new.dta", replace
*/

use "$results\migflow1_vergleich_new.dta", clear

gen N=1
collapse (count) N (mean) migflow1 age  mob abi female [aweight=w_t4_cal], by(year) 
replace migflow1 = migflow1*100

export excel using "$results\migflow1_timeseries_new.xls", firstrow(variables) replace


twoway line migflow1 year if inrange(year,1991,2020)