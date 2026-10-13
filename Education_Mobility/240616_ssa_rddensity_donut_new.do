*******************RD density test*******************************


**********************one obs
use "$results\ssa_panel_obs1_new.dta", clear		// one observation per individual



**************donut sample 
preserve

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0
drop if inlist(run_week,-1,0,1,2)


putexcel set "$results\rddensity_donut_new.xlsx", replace


** Rd density for donut sample 
putexcel A1 = "RD density - donut (one observation)"

putexcel B3 = "Left of cutoff"
putexcel C3 = "Right of cutoff"
putexcel A4 = "Number of observations"
putexcel A5 = "Effective number of observations"
putexcel A6 = "p-value"

rddensity run_week, c(1)
matrix density = e(N_l) , e(N_r) \ e(N_h_l) , e(N_h_r) \ e(pv_q), . 
putexcel B4 = matrix(density)
restore


** Rd density for donut sample with corrected running variable 

preserve
keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0
drop if inlist(run_week,-1,0,1,2)
replace run_week = run_week +2 if run_week < 0
replace run_week = run_week -2 if run_week > 0


putexcel H1 = "RD density - donut (one observation, corrected runningvar)"

putexcel I3 = "Left of cutoff"
putexcel J3 = "Right of cutoff"


rddensity run_week, c(1) 
matrix density = e(N_l) , e(N_r) \ e(N_h_l) , e(N_h_r) \ e(pv_q), . 
putexcel I4 = matrix(density)
restore



** Rd density for uncorrected running variable
preserve
keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0

rddensity run_week, c(1) 


restore









