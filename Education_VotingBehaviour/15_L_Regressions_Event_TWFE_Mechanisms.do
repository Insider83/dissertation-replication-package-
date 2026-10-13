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
foreach var in $Mechanism {

*** *** Elementary School *** ***
*** TWFE
* No Controlls
eststo m1_`var': reghdfe `var' DummyOnlyClosure_ES, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

 * With Controlls 
eststo m2_`var': reghdfe `var' DummyOnlyClosure_ES $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)
 
 * Un- Controlled 
csdid `var', ivar(AGS2020) time(Year) gvar(Year_OnlyClosure_ES) notyet // saverif("`var'_1", replace)
estat event, window(-12 12) estore(m3_ES_UC6)
	
* Controlled 
csdid `var' $Controls_Default, ivar(AGS2020) time(Year) gvar(Year_OnlyClosure_ES) notyet // saverif("`var'_2")
estat event, window(-12 12) estore(m4_ES_CON6)

 
 *** *** Grammar School *** ***
 * No Controlls
eststo m5_`var': reghdfe `var' DummyOnlyClosure_GYM, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

 * With Controlls 
eststo m6_`var': reghdfe `var' DummyOnlyClosure_GYM $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

  * Un- Controlled 
csdid `var', ivar(AGS2020) time(Year) gvar(Year_OnlyClosure_GYM) notyet // saverif("`var'_1", replace)
estat event, window(-12 12) estore(m7_ES_UC6)
	
* Controlled 
csdid `var' $Controls_Default, ivar(AGS2020) time(Year) gvar(Year_OnlyClosure_GYM) notyet // saverif("`var'_2")
estat event, window(-12 12) estore(m8_ES_CON6)
 
 *** Est-Out
 esttab m* using  "$Results_Mechanism_TWFE/Mechanism_TWFEEvent_`var'_OnlyClosure.tex", replace rename((1) "`var'" Post_avg "`var'" DummyOnlyClosure_ES "`var'" DummyOnlyClosure_GYM "`var'") keep("`var'") b(%9.4f) se(%9.4f)  star(* 0.10 ** 0.05 *** 0.01) 
 esttab m* using  "$Results_Mechanism_TWFE/Mechanism_TWFEEvent_`var'_OnlyClosure.xls", replace rename((1) "`var'" Post_avg "`var'" DummyOnlyClosure_ES "`var'" DummyOnlyClosure_GYM "`var'") keep("`var'") b(%9.4f) se(%9.4f)  star(* 0.10 ** 0.05 *** 0.01) 
 eststo clear 
} 