/**************************************************
This Do-File will produce the tables for the combination of TWFE and Event-Study Estimations (Using Sun And Abraham) [Table A6]
	
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
eststo `var'_C0: reghdfe `var' DummyFirstClosure_ES, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

 * With Controlls 
eststo `var'_C1: reghdfe `var' DummyFirstClosure_ES $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

*** Event-Study
* No Controlls
eventstudyinteract `var' lead_ES* lag_ES*, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_ES) control_cohort(NeverTreated_ES)
matrix sa_b = e(b_iw) 
matrix sa_v = e(V_iw)
 
ereturn post sa_b sa_v
lincomest  (lag_ES0 + lag_ES1 + lag_ES2 + lag_ES3 +  lag_ES4 + lag_ES5 + lag_ES6 + lag_ES7 + lag_ES8 + lag_ES9 + lag_ES10 + lag_ES11 + lag_ES12 + lag_ES13 + lag_ES14 + lag_ES15 + lag_ES16 + lag_ES17 + lag_ES18 + lag_ES19 )/20
eststo `var'_C2

* With Controlls 
 eventstudyinteract `var' lead_ES* lag_ES* $Controls_Default, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_ES) control_cohort(NeverTreated_ES)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)
 
 ereturn post sa_b sa_v
 lincomest (lag_ES0 + lag_ES1 + lag_ES2 + lag_ES3 +  lag_ES4 + lag_ES5 + lag_ES6 + lag_ES7 + lag_ES8 + lag_ES9 + lag_ES10 + lag_ES11 + lag_ES12 + lag_ES13 + lag_ES14 + lag_ES15 + lag_ES16 + lag_ES17 + lag_ES18 + lag_ES19 )/20
 eststo `var'_C3
 
 *** *** Grammar School *** ***
 * No Controlls
eststo `var'_C4: reghdfe `var' DummyFirstClosure_GYM, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

 * With Controlls 
eststo `var'_C5: reghdfe `var' DummyFirstClosure_GYM $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

*** Event-Study
* No Controlls
eventstudyinteract `var' lead_GYM* lag_GYM*, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_GYM) control_cohort(NeverTreated_GYM)
matrix sa_b = e(b_iw) 
matrix sa_v = e(V_iw)
 
ereturn post sa_b sa_v
lincomest  (lag_GYM0 + lag_GYM1 + lag_GYM2 + lag_GYM3 +  lag_GYM4 + lag_GYM5 + lag_GYM6 + lag_GYM7 + lag_GYM8 + lag_GYM9 + lag_GYM10 + lag_GYM11 + lag_GYM12 + lag_GYM13 + lag_GYM14 + lag_GYM15 + lag_GYM16 + lag_GYM17 + lag_GYM18 + lag_GYM19 )/20
eststo `var'_C6

* With Controlls 
 eventstudyinteract `var' lead_GYM* lag_GYM* $Controls_Default, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_GYM) control_cohort(NeverTreated_GYM)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)
 
  ereturn post sa_b sa_v
 lincomest (lag_GYM0 + lag_GYM1 + lag_GYM2 + lag_GYM3 +  lag_GYM4 + lag_GYM5 + lag_GYM6 + lag_GYM7 + lag_GYM8 + lag_GYM9 + lag_GYM10 + lag_GYM11 + lag_GYM12 + lag_GYM13 + lag_GYM14 + lag_GYM15 + lag_GYM16 + lag_GYM17 + lag_GYM18 + lag_GYM19 )/20
 eststo `var'_C7
 
 *** Est-Out
 esttab `var'_* using  "$Results_VotingBehaviour_TWFE/VotingBehaviour_TWFEEvent_`var'_FirstClosure.tex", replace rename((1) "`var'" DummyFirstClosure_ES "`var'" DummyFirstClosure_GYM "`var'") keep("`var'") b(%9.4f) se(%9.4f)  star(* 0.10 ** 0.05 *** 0.01) 
 esttab `var'_* using  "$Results_VotingBehaviour_TWFE/VotingBehaviour_TWFEEvent_`var'_FirstClosure.xls", replace rename((1) "`var'" DummyFirstClosure_ES "`var'" DummyFirstClosure_GYM "`var'") keep("`var'") b(%9.4f) se(%9.4f)  star(* 0.10 ** 0.05 *** 0.01) 
 eststo clear
} 
