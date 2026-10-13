*******************Create datasets for migration by week************************

********************** full - weighted
use "$results\ssa_panel_all_new.dta", clear
keep if w_t4_cal != 0
keep if inrange(age,25,55)
keep if inrange(yob,1945,1964)
keep if mig_samp == 1


foreach var of varlist migstock migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr {
preserve
gen N=1 

reg `var' run_week [aw=w_t4_cal] if inrange(run_week,-24,0)
predict fit0_`var', xb
predict se0_`var', stdp
reg `var' run_week [aw=w_t4_cal] if inrange(run_week,1,25)
predict fit1_`var', xb
predict se1_`var', stdp

collapse (mean) `var' fit0_`var' fit1_`var' se0_`var' se1_`var' (count) N [aw=w_t4_cal], by(run_week)
gen ci0_hi_`var' = fit0_`var' + 1.96*se0_`var'
gen ci0_lo_`var' = fit0_`var' - 1.96*se0_`var' 

gen ci1_hi_`var' = fit1_`var' + 1.96*se1_`var' 
gen ci1_lo_`var' = fit1_`var' - 1.96*se1_`var' 

gen samp_`var' = 1

save "${results}\temp\mig_by_week_full_`var'.dta", replace
restore
}

use "${results}\temp\mig_by_week_full_migstock.dta", clear
local datasets "migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr"
foreach x of local datasets {
	merge 1:1 run_week using "${results}\temp\mig_by_week_full_`x'.dta"
	drop _merge
}
save "${results}\mig_by_week_full_weighted_new.dta", replace
export excel using "$results\mig_by_week_full_weighted_new.xls", firstrow(variables) replace


********************** full - unweighted


use "$results\ssa_panel_all_new.dta", clear
keep if w_t4_cal != 0
keep if inrange(age,25,55)
keep if inrange(yob,1945,1964)
keep if mig_samp == 1
*drop if inlist(run_week,-1,0,1,2)

foreach var of varlist migstock migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr {
preserve
gen N=1 

reg `var' run_week  if inrange(run_week,-24,0)
predict fit0_`var', xb
predict se0_`var', stdp
reg `var' run_week if inrange(run_week,1,25)
predict fit1_`var', xb
predict se1_`var', stdp

collapse (mean) `var' fit0_`var' fit1_`var' se0_`var' se1_`var' (count) N [aw=w_t4_cal], by(run_week)
gen ci0_hi_`var' = fit0_`var' + 1.96*se0_`var'
gen ci0_lo_`var' = fit0_`var' - 1.96*se0_`var' 

gen ci1_hi_`var' = fit1_`var' + 1.96*se1_`var' 
gen ci1_lo_`var' = fit1_`var' - 1.96*se1_`var' 

gen samp_`var' = 1

save "${results}\temp\mig_by_week_full_unweighted_`var'.dta", replace
restore
}

use "${results}\temp\mig_by_week_full_unweighted_migstock.dta", clear
local datasets "migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr"
foreach x of local datasets {
	merge 1:1 run_week using "${results}\temp\mig_by_week_full_unweighted_`x'.dta"
	drop _merge
}
save "${results}\mig_by_week_full_unweighted_new.dta", replace
export excel using "$results\mig_by_week_full_unweighted_new.xls", firstrow(variables) replace




********************** donut - weighted 

use "$results\ssa_panel_all_new.dta", clear
keep if w_t4_cal != 0
keep if inrange(age,25,55)
keep if inrange(yob,1945,1964)
keep if mig_samp == 1
drop if inlist(run_week,-1,0,1,2)

foreach var of varlist migstock migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr {
preserve
gen N=1 

reg `var' run_week [aw=w_t4_cal] if inrange(run_week,-24,2)
predict fit0_`var', xb
predict se0_`var', stdp
reg `var' run_week [aw=w_t4_cal] if inrange(run_week,3,25)
predict fit1_`var', xb
predict se1_`var', stdp

collapse (mean) `var' fit0_`var' fit1_`var' se0_`var' se1_`var' (count) N [aw=w_t4_cal], by(run_week)
gen ci0_hi_`var' = fit0_`var' + 1.96*se0_`var'
gen ci0_lo_`var' = fit0_`var' - 1.96*se0_`var' 

gen ci1_hi_`var' = fit1_`var' + 1.96*se1_`var' 
gen ci1_lo_`var' = fit1_`var' - 1.96*se1_`var' 

gen samp_`var' = 1

save "${results}\temp\mig_by_week_donut_`var'.dta", replace
restore
}

use "${results}\temp\mig_by_week_donut_migstock.dta", clear
local datasets "migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr"
foreach x of local datasets {
	merge 1:1 run_week using "${results}\temp\mig_by_week_donut_`x'.dta"
	drop _merge
}
save "${results}\mig_by_week_donut_weighted_new.dta", replace
export excel using "$results\mig_by_week_donut_weighted_new.xls", firstrow(variables) replace


********************** donut - unweighted 

use "$results\ssa_panel_all_new.dta", clear
keep if w_t4_cal != 0
keep if inrange(age,25,55)
keep if inrange(yob,1945,1964)
keep if mig_samp == 1
drop if inlist(run_week,-1,0,1,2)

foreach var of varlist migstock migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr {
preserve
gen N=1 

reg `var' run_week [aw=w_t4_cal] if inrange(run_week,-24,2)
predict fit0_`var', xb
predict se0_`var', stdp
reg `var' run_week [aw=w_t4_cal] if inrange(run_week,3,25)
predict fit1_`var', xb
predict se1_`var', stdp

collapse (mean) `var' fit0_`var' fit1_`var' se0_`var' se1_`var' (count) N [aw=w_t4_cal], by(run_week)
gen ci0_hi_`var' = fit0_`var' + 1.96*se0_`var'
gen ci0_lo_`var' = fit0_`var' - 1.96*se0_`var' 

gen ci1_hi_`var' = fit1_`var' + 1.96*se1_`var' 
gen ci1_lo_`var' = fit1_`var' - 1.96*se1_`var' 

gen samp_`var' = 1

save "${results}\temp\mig_by_week_donut_unweighted_`var'.dta", replace
restore
}

use "${results}\temp\mig_by_week_donut_unweighted_migstock.dta", clear
local datasets "migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr"
foreach x of local datasets {
	merge 1:1 run_week using "${results}\temp\mig_by_week_donut_unweighted_`x'.dta"
	drop _merge
}
save "${results}\mig_by_week_donut_unweighted_new.dta", replace
export excel using "$results\mig_by_week_donut_unweighted_new.xls", firstrow(variables) replace




