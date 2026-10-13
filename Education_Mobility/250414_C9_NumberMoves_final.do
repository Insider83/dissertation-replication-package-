/**************************************************
This file will do the TWFE-Regressions for Number of Total Moves, inlcuding two additional settings:

* Two Additional Settings:
* 1) Aggregated Dummy: Ever Moved at all
* 2) Sample Restriction: Only Individuals that moved at least once (Drop Zeros)
	
	
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2024-11-05
	Version: 2.0, 2025-02-21
***************************************************/

************************************************
* define globals
************************************************
global results_NumberMoves "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Number Movements"

* DiD-Imputation Packages does not like i. - prefix, therefore define new globals
global family_new_DiD p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New_DiD JoinedKita_T2 OlderSibling_T2
global RuralVariable_IMP RuralNEPSMZ

************************************************
*    load final panel
************************************************
use "$results\C9_Combined_Utilized_Panel.dta", clear
sort ID_t age
* xtset ID_t age

*** Gen Single Person Dummy
gen n1 = 1 if age == 40 

************************************************
* Two Additional Settings:
* 1) Aggregated Dummy: Ever Moved at all
* 2) Sample Restriction: Only Individuals that moved at least once (Drop Zeros)
************************************************
* Prepare 1) and 2)
gen DummyMovedEverOnce_bl = (mig_number_2555 > 0)
gen DummyMovedEverOnce_kr = (mig_number_kr_2555 > 0)


************************************************
* Limit Data-Set
************************************************
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)


***********************************************
*
***********************************************

* histogram if moved at least once
hist mig_number_2555 if DummyMovedEverOnce_bl == 1, percent
hist mig_number_kr_2555 if DummyMovedEverOnce_kr == 1, percent


* create/transform Moved-Variables via ln(y+1)
foreach var of varlist mig_number_2555 mig_number_kr_2555 {
cap drop `var'1 `var'_ln

gen `var'1 = `var'+1
gen `var'_ln1 = ln(`var'1)
drop `var'1 

gen `var'1 = `var'+1 if `var' > 0
gen `var'_ln = ln(`var'1)
drop `var'1 
}

************************************************
* Regress 
************************************************

	** Bula **
foreach var of varlist mig_number_2555 {
	
	*i) Dummy i) If Ever Moved: No additional Controls
	areg DummyMovedEverOnce_bl C9 i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c3_`var'_
	qui sum DummyMovedEverOnce_bl [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*i) Dummy i) If Ever Moved: Baseline Regression (With Optimized Vars from Balancing Tests)
	areg DummyMovedEverOnce_bl C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c4_`var'_
	qui sum DummyMovedEverOnce_bl [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*ii) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c1_`var'_
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*ii) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c2_`var'_
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	
	*iii) Dummy ii) Remove Zero Sample (Never Moved): No additional Controls [If Ever Moved]
	areg `var' C9 i.bula [aweight = w_t4_cal] if n1 == 1 & DummyMovedEverOnce_bl == 1, cluster(ID_t) absorb(cohort)
	eststo c5_`var'_
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*iii) Dummy ii) Remove Zero Sample (Never Moved): Baseline Regression (With Optimized Vars from Balancing Tests) [If Ever Moved]
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1 & DummyMovedEverOnce_bl == 1, cluster(ID_t) absorb(cohort)
	eststo c6_`var'_
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*iv) Log(Moved): No additional Controls [If Ever Moved]
	areg mig_number_2555_ln  C9 i.bula [aweight = w_t4_cal] if n1 == 1 & DummyMovedEverOnce_bl == 1, cluster(ID_t) absorb(cohort)
	eststo c7_mig_number_2555_ln_
	qui sum mig_number_2555_ln [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*iv) Log(Moved): Baseline Regression (With Optimized Vars from Balancing Tests) [If Ever Moved]
	areg mig_number_2555_ln C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1 & DummyMovedEverOnce_bl == 1, cluster(ID_t) absorb(cohort)
	eststo c8_mig_number_2555_ln_
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*v) Log(Moved)+1: No additional Controls [If Ever Moved]
	areg mig_number_2555_ln1 C9 i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c9_mig_number_2555_ln1_
	qui sum mig_number_2555_ln1 [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*v) Log(Moved)+1: Baseline Regression (With Optimized Vars from Balancing Tests) [If Ever Moved]
	areg mig_number_2555_ln1 C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c10_mig_number_2555_ln1_
	qui sum mig_number_2555_ln1 [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	}
	
*Estout
esttab c* using "$results_NumberMoves\TWFE_NumberMoves_2555_Full_new.csv", keep(C9) cells(b(fmt(3) star) se(par) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`var'") addnotes("") replace // scalar(mig_mean) drop(*.bula)
eststo clear

	
	** Kreis **
foreach var of varlist mig_number_kr_2555 { // mig_number_age mig_number_kr_age
	
	* i) Dummy i) If Ever Moved: No additional Controls
	areg DummyMovedEverOnce_kr C9 i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c3_`var'_
	qui sum DummyMovedEverOnce_kr [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	* i) Dummy i) If Ever Moved: Baseline Regression (With Optimized Vars from Balancing Tests)
	areg DummyMovedEverOnce_kr C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c4_`var'_
	qui sum DummyMovedEverOnce_kr [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	* ii) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c1_`var'_
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	* ii) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c2_`var'_
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	* iii) Dummy ii) Remove Zero Sample (Never Moved): No additional Controls [If Ever Moved]
	areg `var' C9 i.bula [aweight = w_t4_cal] if n1 == 1 & DummyMovedEverOnce_kr == 1, cluster(ID_t) absorb(cohort)
	eststo c5_`var'_
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	* iii) Dummy ii) Remove Zero Sample (Never Moved): Baseline Regression (With Optimized Vars from Balancing Tests) [If Ever Moved]
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1 & DummyMovedEverOnce_kr == 1, cluster(ID_t) absorb(cohort)
	eststo c6_`var'_
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*iv) Log(Moved): No additional Controls [If Ever Moved]
	areg mig_number_kr_2555_ln C9  i.bula [aweight = w_t4_cal] if n1 == 1 & DummyMovedEverOnce_kr == 1, cluster(ID_t) absorb(cohort)
	eststo c7_mig_number_kr_2555_ln_
	qui sum mig_number_kr_2555_ln [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*iv) Log(Moved): Baseline Regression (With Optimized Vars from Balancing Tests) [If Ever Moved]
	areg mig_number_kr_2555_ln C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c8_mig_number_kr_2555_ln_
	qui sum mig_number_kr_2555_ln [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*v) Log(Moved)+1: No additional Controls [If Ever Moved]
	areg mig_number_kr_2555_ln1 C9 i.bula [aweight = w_t4_cal] if n1 == 1 & DummyMovedEverOnce_kr == 1, cluster(ID_t) absorb(cohort)
	eststo c9_mig_number_kr_2555_ln1_
	qui sum mig_number_kr_2555_ln1 [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*v) Log(Moved)+1: Baseline Regression (With Optimized Vars from Balancing Tests) [If Ever Moved]
	areg mig_number_kr_2555_ln1 C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if n1 == 1, cluster(ID_t) absorb(cohort)
	eststo c10_mig_number_kr_2555_ln1_
	qui sum mig_number_kr_2555_ln1 [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	}	
	
*Estout
esttab c* using "$results_NumberMoves\TWFE_NumberMoves_2555_Full_new.csv", keep(C9) cells(b(fmt(3) star) se(par) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`var'") addnotes("") append // scalar(mig_mean) drop(*.bula)
eststo clear