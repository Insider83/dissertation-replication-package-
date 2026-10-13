/*******************************************************************************
This file will produce TWFE - Estimations for C9 Effects over the lifetime

This file will regress, save and then visualize the coefficients

Age: 7 - 64
Author: Sebastian Vogler
Version: 1.0, created 2024 - 08 - 06
*******************************************************************************/

************************************************
* define globals
************************************************
global results_Lifecycle Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Life Cycle

global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ

*** Load .dta ***
use "$results\C9_Combined_Full_Panel_final.dta", clear // From "231030_Combine_C9.do"
keep if inrange(yob, 1945, 1964)

foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}


************************************************
* TWFE on Migration
************************************************
*** Mig_Stock Bula***
est drop _all
cap erase 

foreach num of numlist 5(1)65 {

	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' mig_stock C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if age == `num', cluster(ID_t) absorb(cohort)
	eststo mig_stock_`num'
	qui sum mig_stock [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	preserve
	parmest, es(N) saving("$results_Lifecycle\mig_stock_`num'.dta", replace) idnum(`num')
	restore
	
	}
	
*Save Results
esttab mig_stock_* using "$results_Lifecycle\Lifecycle_mig_stock.csv", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility Stock - State Life Cycle)")

*** *** Create Dataset for export *** ***
preserve
use "$results_Lifecycle\mig_stock_5.dta", clear
foreach num of numlist 6(1)65 {
	append using "$results_Lifecycle\mig_stock_`num'.dta"
	cap erase "$results_Lifecycle\mig_stock_`num'.dta"
}
export excel using "$results_Lifecycle\mig_stock_ALL.xls", firstrow(variables) replace
save "$results_Lifecycle\Lifecycle_mig_stock_ALL.dta", replace
capture erase "$results_Lifecycle\mig_stock_5.dta"
restore

*** Mig_Stock Kreis ***
est drop _all
cap erase 

foreach num of numlist 5(1)65 {

	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' mig_stock_kr C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if age == `num', cluster(ID_t) absorb(cohort)
	eststo mig_stock_kr_`num'
	qui sum mig_stock_kr [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	preserve
	parmest, es(N) saving("$results_Lifecycle\mig_stock_kr_`num'.dta", replace) idnum(`num')
	restore
	
	}
	
*Save Results
esttab mig_stock_kr_* using "$results_Lifecycle\Lifecycle_mig_stock_kr.csv", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility Stock - County Life Cycle)")

*** *** Create Dataset for export *** ***
preserve
use "$results_Lifecycle\mig_stock_kr_5.dta", clear
foreach num of numlist 6(1)65 {
	append using "$results_Lifecycle\mig_stock_kr_`num'.dta"
	cap erase "$results_Lifecycle\mig_stock_kr_`num'.dta"
}
export excel using "$results_Lifecycle\mig_stock_kr_ALL.xls", firstrow(variables) replace
save "$results_Lifecycle\Lifecycle_mig_stock_kr_ALL.dta", replace
capture erase "$results_Lifecycle\mig_stock_kr_5.dta"
restore

*** Mig_Flow 1 Bula ***
est drop _all
cap erase 

foreach num of numlist 5(1)65 {

	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' mig_flow1 C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if age == `num', cluster(ID_t) absorb(cohort)
	eststo mig_flow1_`num'
	qui sum mig_flow1 [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	preserve
	parmest, es(N) saving("$results_Lifecycle\mig_flow1_`num'.dta", replace) idnum(`num')
	restore
	
	}
	
*Save Results
esttab mig_flow1_* using "$results_Lifecycle\Lifecycle_mig_flow1.csv", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility Flow 1 Yr - State Life Cycle)")

*** *** Create Dataset for export *** ***
preserve
use "$results_Lifecycle\mig_flow1_5.dta", clear
foreach num of numlist 6(1)65 {
	append using "$results_Lifecycle\mig_flow1_`num'.dta"
	cap erase "$results_Lifecycle\mig_flow1_`num'.dta"
}
export excel using "$results_Lifecycle\mig_flow1_ALL.xls", firstrow(variables) replace
save "$results_Lifecycle\Lifecycle_mig_flow1_ALL.dta", replace
capture erase "$results_Lifecycle\mig_flow1_5.dta"
restore

*** Mig_Flow 1 Kreis ***
est drop _all
cap erase 

foreach num of numlist 5(1)65 {

	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' mig_flow1_kr C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if age == `num', cluster(ID_t) absorb(cohort)
	eststo mig_flow1_kr_`num'
	qui sum mig_flow1_kr [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	preserve
	parmest, es(N) saving("$results_Lifecycle\mig_flow1_kr_`num'.dta", replace) idnum(`num')
	restore
	
	}
	
*Save Results
esttab mig_flow1_kr_* using "$results_Lifecycle\Lifecycle_mig_flow1_kr.csv", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility Flow 1 Yr - County Life Cycle)")

*** *** Create Dataset for export *** ***
preserve
use "$results_Lifecycle\mig_flow1_kr_5.dta", clear
foreach num of numlist 6(1)65 {
	append using "$results_Lifecycle\mig_flow1_kr_`num'.dta"
	cap erase "$results_Lifecycle\mig_flow1_kr_`num'.dta"
}
export excel using "$results_Lifecycle\mig_flow1_kr_ALL.xls", firstrow(variables) replace
save "$results_Lifecycle\Lifecycle_mig_flow1_kr_ALL.dta", replace
capture erase "$results_Lifecycle\mig_flow1_kr_5.dta"
restore

*** Mig_Flow 5 Bula ***
est drop _all
cap erase 

foreach num of numlist 5(1)65 {

	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' mig_flow5 C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if age == `num', cluster(ID_t) absorb(cohort)
	eststo mig_flow5_`num'
	qui sum mig_flow5 [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	preserve
	parmest, es(N) saving("$results_Lifecycle\mig_flow5_`num'.dta", replace) idnum(`num')
	restore
	
	}
	
*Save Results
esttab mig_flow5_* using "$results_Lifecycle\Lifecycle_mig_flow5.csv", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility Flow 5 Yr - State Life Cycle)")

*** *** Create Dataset for export *** ***
preserve
use "$results_Lifecycle\mig_flow5_5.dta", clear
foreach num of numlist 6(1)65 {
	append using "$results_Lifecycle\mig_flow5_`num'.dta"
	cap erase "$results_Lifecycle\mig_flow5_`num'.dta"
}
export excel using "$results_Lifecycle\mig_flow5_ALL.xls", firstrow(variables) replace
save "$results_Lifecycle\Lifecycle_mig_flow5_ALL.dta", replace
capture erase "$results_Lifecycle\mig_flow5_5.dta"
restore

*** Mig_Flow 5 Kreis ***
est drop _all
cap erase 

foreach num of numlist 5(1)65 {

	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' mig_flow5_kr C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if age == `num', cluster(ID_t) absorb(cohort)
	eststo mig_flow5_kr_`num'
	qui sum mig_flow5_kr [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	preserve
	parmest, es(N) saving("$results_Lifecycle\mig_flow5_kr_`num'.dta", replace) idnum(`num')
	restore
	
	}
	
*Save Results
esttab mig_flow5_kr_* using "$results_Lifecycle\Lifecycle_mig_flow5_kr.csv", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility Flow 5 Yr - County Life Cycle)")

*** *** Create Dataset for export *** ***
preserve
use "$results_Lifecycle\mig_flow5_kr_5.dta", clear
foreach num of numlist 6(1)65 {
	append using "$results_Lifecycle\mig_flow5_kr_`num'.dta"
	cap erase "$results_Lifecycle\mig_flow5_kr_`num'.dta"
}
export excel using "$results_Lifecycle\mig_flow5_kr_ALL.xls", firstrow(variables) replace
save "$results_Lifecycle\Lifecycle_mig_flow5_kr_ALL.dta", replace
capture erase "$results_Lifecycle\mig_flow5_kr_5.dta"
restore


