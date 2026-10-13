/**************************************************
This file will do the estimates of the the weights attached to the two-way fixed effects regressions studied in de Chaisemartin & D'Haultfoeuille (2020a),
 as well as summary measures of these regressions' robustness to heterogeneous treatment effect
		
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2025-12-12
***************************************************/

************************************************
* Globals and Mkdir
************************************************
capture mkdir "$DiDWeights"

************************************************
* Load and Clean
************************************************
 * use "$results\C9_Combined_Utilized_Panel.dta", clear // From "231030_Combine_C9.do"
 use "$results\C9_Combined_Utilized_Panel_final.dta", clear // From "250413_Combine_C9_final.do"

keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)

foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}


*** Regressions ***
foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {

	estimates drop _all
	twowayfeweights `var' bula cohort C9, type(feTR) controls() weight(w_t4_cal) summary_measures //path("$DiDWeights/`var'_0")
}


*** Collapse ***
foreach var in mig_stock_0 mig_flow1_0 mig_flow5_0 mig_stock_kr_0 mig_flow1_kr_0 mig_flow5_kr_0 mig_stock_1 mig_flow1_1 mig_flow5_1 mig_stock_kr_1 mig_flow1_kr_1 mig_flow5_kr_1 mig_stock_2 mig_flow1_2 mig_flow5_2 mig_stock_kr_2 mig_flow1_kr_2 mig_flow5_kr_2 {
	
use "$DiDWeights/`var'.dta", clear

gen PositiveWeight = (weight > 0)
gen One = 1
replace One = 0 if weight == .

collapse (sum) SumWeight = weight Nobs=One, by(PositiveWeight)
gen Variable = "`var'"

save "$DiDWeights/`var'_append.dta", replace
erase "$DiDWeights/`var'.dta"
}

*** Append ***
use "$DiDWeights/mig_stock_0_append.dta", clear

foreach var in mig_flow1_0 mig_flow5_0 mig_stock_kr_0 mig_flow1_kr_0 mig_flow5_kr_0 mig_stock_1 mig_flow1_1 mig_flow5_1 mig_stock_kr_1 mig_flow1_kr_1 mig_flow5_kr_1 mig_stock_2 mig_flow1_2 mig_flow5_2 mig_stock_kr_2 mig_flow1_kr_2 mig_flow5_kr_2 {
	append using "$DiDWeights/`var'_append.dta"
}

*** Save ***
sort PositiveWeight Variable
save "$DiDWeights/DiDAllWeights.dta", replace
