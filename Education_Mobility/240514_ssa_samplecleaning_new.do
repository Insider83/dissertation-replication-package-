/*******************************************************************************
			Restrict datasets
*******************************************************************************/

use "$results\ssa_panel_new.dta", clear


preserve
duplicates drop ID_t, force 
save "$results\ssa_all_oneobs.dta", replace		// one observation per individual
restore


*******************one observaton per individual (for analysis of 1st stage and educational outcomes)
preserve
keep if edgeweek == 0
keep if inrange(bula6,1,10)
keep if inrange(yob,1945,1964)
duplicates drop ID_t, force 


save "$results\ssa_panel_obs1_new.dta", replace		// one observation per individual
restore


*******************all outcomes in one dataset
preserve
keep if edgeweek == 0
keep if inrange(bula6,1,10)
keep if inrange(yob,1945,1964)

*migstock
sort ID_t date
bysort ID_t age: egen migstock =mean(mig_stock) 

sort ID_t date
bysort ID_t age: egen migstock_kr =mean(mig_stock_kr)
bysort ID_t age: egen migstock_kr_max =max(mig_stock_kr)

*migflow1
sort ID_t date
bysort ID_t age: egen migflow1 =mean(mig_flow1) 

sort ID_t date
bysort ID_t age: egen migflow1_kr =mean(mig_flow1_kr)
bysort ID_t age: egen migflow1_kr_max =max(mig_flow1_kr)

*migflow5
sort ID_t date
bysort ID_t age: egen migflow5 =mean(mig_flow5) 

sort ID_t date
bysort ID_t age: egen migflow5_kr =mean(mig_flow5_kr)
bysort ID_t age: egen migflow5_kr_max =max(mig_flow5_kr)

gen mig_samp = inlist(migstock_kr_max,0,1) & inlist(migflow1_kr_max,0,1) & inlist(migflow5_kr_max,0,1)

duplicates drop ID_t age, force 


save "$results\ssa_panel_all_new.dta", replace		// one observation per individual
restore
