/**************************************************
This Do-File will produce the tables for the combination of TWFE and Event-Study Estimations (Using Sun And Abraham)
	
	Author: Sebastian Vogler
	
	Version: 1.0, Created: 2026-06-18	
***************************************************/

* Use Final Data-Set
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
sort AGS2020 Year

*Set Panel
destring AGS2020, replace
xtset AGS2020 Year

* Generate a unique identifier for the first occurrence of each unit
bysort AGS2020: gen unique_id = _n == 1
count if unique_id
local num_distinct_units = r(N)
drop unique_id

********************************************************************************
* Clean Data-Set: 
********************************************************************************
foreach var in $Mechanism {
	display "`var'"
	drop if `var' == .
}

foreach var in $Controls_Default {
	display "`var'"
	drop if `var' == .
}

foreach var in $Controls_ES $Controls_GYM {
	display "`var'"
	drop if `var' == .
}


*** Actual Regressions ***
foreach var in $Regress_BW $Regress_LW $Regress_KW {

*** *** Elementary School *** ***
*** TWFE
* No Controlls
eststo `var'_C0: reghdfe `var' DummyOnlyClosure_ES, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

 * With Controlls 
eststo `var'_C1: reghdfe `var' DummyOnlyClosure_ES $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

*** Event-Study
* No Controlls
eventstudyinteract `var' lead_OC_ES* lag_OC_ES*, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(Year_OnlyClosure_ES) control_cohort(NeverTreated_ES)
matrix sa_b = e(b_iw) 
matrix sa_v = e(V_iw)
 
ereturn post sa_b sa_v
lincomest  (lag_OC_ES0 + lag_OC_ES1 + lag_OC_ES2 + lag_OC_ES3 +  lag_OC_ES4 + lag_OC_ES5 + lag_OC_ES6 + lag_OC_ES7 + lag_OC_ES8 + lag_OC_ES9 + lag_OC_ES10 + lag_OC_ES11 + lag_OC_ES12 + lag_OC_ES13 + lag_OC_ES14 + lag_OC_ES15 + lag_OC_ES16 + lag_OC_ES17 + lag_OC_ES18 + lag_OC_ES19)/20
eststo `var'_C2

* With Controlls 
 eventstudyinteract `var' lead_OC_ES* lag_OC_ES* $Controls_Default, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(Year_OnlyClosure_ES) control_cohort(NeverTreated_ES)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)
 
 ereturn post sa_b sa_v
 lincomest (lag_OC_ES0 + lag_OC_ES1 + lag_OC_ES2 + lag_OC_ES3 +  lag_OC_ES4 + lag_OC_ES5 + lag_OC_ES6 + lag_OC_ES7 + lag_OC_ES8 + lag_OC_ES9 + lag_OC_ES10 + lag_OC_ES11 + lag_OC_ES12 + lag_OC_ES13 + lag_OC_ES14 + lag_OC_ES15 + lag_OC_ES16 + lag_OC_ES17 + lag_OC_ES18 + lag_OC_ES19)/20
 eststo `var'_C3
 
 *** *** Grammar School *** ***
 * No Controlls
eststo `var'_C4: reghdfe `var' DummyOnlyClosure_GYM, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

 * With Controlls 
eststo `var'_C5: reghdfe `var' DummyOnlyClosure_GYM $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

*** Event-Study
* No Controlls
eventstudyinteract `var' lead_OC_GYM* lag_OC_GYM*, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(Year_OnlyClosure_GYM) control_cohort(NeverTreated_GYM)
matrix sa_b = e(b_iw) 
matrix sa_v = e(V_iw)
 
ereturn post sa_b sa_v
lincomest  (lag_OC_GYM0 + lag_OC_GYM1 + lag_OC_GYM2 + lag_OC_GYM3 +  lag_OC_GYM4 + lag_OC_GYM5 + lag_OC_GYM6 + lag_OC_GYM7 + lag_OC_GYM8 + lag_OC_GYM9 + lag_OC_GYM10 + lag_OC_GYM11 + lag_OC_GYM12 + lag_OC_GYM13 + lag_OC_GYM14 + lag_OC_GYM15 + lag_OC_GYM16 + lag_OC_GYM17 + lag_OC_GYM18 + lag_OC_GYM19 )/20
eststo `var'_C6

* With Controlls 
 eventstudyinteract `var' lead_OC_GYM* lag_OC_GYM* $Controls_Default, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(Year_OnlyClosure_GYM) control_cohort(NeverTreated_GYM)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)
 
  ereturn post sa_b sa_v
 lincomest (lag_OC_GYM0 + lag_OC_GYM1 + lag_OC_GYM2 + lag_OC_GYM3 +  lag_OC_GYM4 + lag_OC_GYM5 + lag_OC_GYM6 + lag_OC_GYM7 + lag_OC_GYM8 + lag_OC_GYM9 + lag_OC_GYM10 + lag_OC_GYM11 + lag_OC_GYM12 + lag_OC_GYM13 + lag_OC_GYM14 + lag_OC_GYM15 + lag_OC_GYM16 + lag_OC_GYM17 + lag_OC_GYM18 + lag_OC_GYM19 )/20
 eststo `var'_C7
 
 *** Est-Out
 esttab `var'_* using  "$Results_VotingBehaviour_TWFE/VotingBehaviour_TWFEEvent_`var'_OnlyClosure.tex", replace rename((1) "`var'" DummyOnlyClosure_ES "`var'" DummyOnlyClosure_GYM "`var'") keep("`var'") b(%9.4f) se(%9.4f)  star(* 0.10 ** 0.05 *** 0.01)  
 esttab `var'_* using  "$Results_VotingBehaviour_TWFE/VotingBehaviour_TWFEEvent_`var'_OnlyClosure.xls", replace rename((1) "`var'" DummyOnlyClosure_ES "`var'" DummyOnlyClosure_GYM "`var'") keep("`var'") b(%9.4f) se(%9.4f)  star(* 0.10 ** 0.05 *** 0.01) 
 eststo clear
} 

