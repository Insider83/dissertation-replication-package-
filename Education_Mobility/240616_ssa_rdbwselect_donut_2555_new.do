*******************RD bandwidth select*******************************

use "$results\ssa_panel_all_new.dta", clear


**************Donut sample (weighted)
preserve

keep if inrange(age,25,55)
keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0
drop if inlist(run_week,-1,0,1,2)
keep if mig_samp == 1

*weighted
putexcel set "$results\rdbwselect_donut_weighted_new.xlsx", replace

putexcel A1 = "RD bandwidth selection - donut (weighted)"
putexcel A4 = "Migstock"
putexcel A5 = "Migstock Kreis"
putexcel A6 = "Migflow1"
putexcel A7 = "Migflow1 Kreis"
putexcel A8 = "Migflow5"
putexcel A9 = "Migflow5 Kreis"
putexcel B3 = "Cutoff left (one common bandwith selector)"
putexcel C3 = "Cutoff right (one common bandwith selector)"
putexcel D3 = "Cutoff left (two different bandwith selectors)"
putexcel E3 = "Cutoff right (two different bandwith selectors)"

local n = 4
foreach var of varlist migstock migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr {
	rdbwselect `var' run_week, c(1) weights(w_t4_cal) masspoints(adjust) all 
	matrix bandwidth_`n' =  e(h_mserd) , e(b_mserd) , e(h_msetwo_l) , e(h_msetwo_r)
	putexcel B`n' = matrix(bandwidth_`n')
	putexcel B`n':E`n', nformat(0.000) overwritefmt
	local n = `n'+1
}
restore


/**************Donut sample (unweighted)
preserve

keep if inrange(age,25,55)
keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0
drop if inlist(run_week,-1,0,1,2)
keep if mig_samp == 1



putexcel H1 = "RD bandwidth selection - donut (unweighted)"
putexcel I3 = "Cutoff left (one common bandwith selector)"
putexcel J3 = "Cutoff right (one common bandwith selector)"
putexcel K3 = "Cutoff left (two different bandwith selectors)"
putexcel L3 = "Cutoff right (two different bandwith selectors)"

local n = 4
foreach var of varlist migstock migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr {
	rdbwselect `var' run_week, c(1) masspoints(adjust) all 
	matrix bandwidth_`n' =  e(h_mserd) , e(b_mserd) , e(h_msetwo_l) , e(h_msetwo_r)
	putexcel I`n' = matrix(bandwidth_`n')
	putexcel I`n':L`n', nformat(0.000) overwritefmt
	local n = `n'+1
}
restore
*/


**************Donut sample - corrected running variable and weighted
preserve

keep if inrange(age,25,55)
keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0
drop if inlist(run_week,-1,0,1,2)
keep if mig_samp == 1
replace run_week = run_week +2 if run_week < 0
replace run_week = run_week -2 if run_week >= 0

*weighted
putexcel A12 = "RD bandwidth selection - donut (corrected running variable and weighted)"
putexcel A15 = "Migstock"
putexcel A16 = "Migstock Kreis"
putexcel A17 = "Migflow1"
putexcel A18 = "Migflow1 Kreis"
putexcel A19 = "Migflow5"
putexcel A20 = "Migflow5 Kreis"
putexcel B14 = "Cutoff left (one common bandwith selector)"
putexcel C14 = "Cutoff right (one common bandwith selector)"
putexcel D14 = "Cutoff left (two different bandwith selectors)"
putexcel E14 = "Cutoff right (two different bandwith selectors)"

local n = 15
foreach var of varlist migstock migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr {
	rdbwselect `var' run_week, c(1) weights(w_t4_cal) masspoints(adjust) all 
	matrix bandwidth_`n' =  e(h_mserd) , e(b_mserd) , e(h_msetwo_l) , e(h_msetwo_r)
	putexcel B`n' = matrix(bandwidth_`n')
	putexcel B`n':E`n', nformat(0.000) overwritefmt
	local n = `n'+1
}
restore