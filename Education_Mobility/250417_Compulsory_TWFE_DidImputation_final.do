/**************************************************
This file will do the TWFE in comparison to the DID Regressions for the C9 (Compulsory School Reform)
	
	-> We concentrate on Age 25- 55 (To be inline with regressions)
	-> This do-File uses the estimator of  Borusyak, Jaravel, and Spiess (April 2023)
	
	
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2023-07-05
				  Updated: 2023- 08- 18
***************************************************/

*Install Packages
*ssc install did_imputation

************************************************
* define globals
************************************************
global results_Robustness "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Robustness Checks"

* DiD-Imputation Packages does not like i. - prefix, therefore define new globals
global family_new_DiD p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New_DiD JoinedKita_T2 OlderSibling_T2
global RuralVariable_IMP RuralNEPSMZ

************************************************
*    load final panel
************************************************
use "$results\C9_Combined_Utilized_Panel_final.dta", clear
sort ID_t age
* xtset ID_t age

************************************************
* Limit Data-Set
************************************************
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)

************************************************
* DiD-Imputation
* did_imputation Y i t Ei [if] [in] [estimation weights] [, options]
* Where:
	*  Y       outcome variable
    *  i       variable for unique unit id
    *  t       variable for calendar period
    *  Ei      variable for unit-specific date of treatment (missing = never-treated) // same coeff and obs when we use Ei = .
* -> Slightly Bigger Coefficients, but still robust and small 
************************************************
* Drop Always Treated (Will be done automatially anyway)
drop if bula == 1
drop if bula == 2
drop if bula == 4
drop if bula == 10

* Drop if MZ-Weight is 0 anyway
drop if w_t4_cal == 0


*** DiD-Imputation
* Problem: Empty Cells in Bula x Cohort lead to exclusion of Individuals, therefore with fe() we can explizitely tell did_imputation what to include
foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) No additional Controls
	did_imputation `var' bula cohort Ei_T14 [aweight = w_t4_cal], autosample cluster(ID_t) delta(1) fe(bula cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
}
esttab pooled_c0_* using "$results_Robustness\C9_DiDImputation.csv", keep(tau) cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Without Controlls. DiD-Imputation by Borusyak et al. used.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace
eststo clear

foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	did_imputation `var' bula cohort Ei_T14 [aweight = w_t4_cal], autosample controls(female $family_new_DiD $Siblings_Kita_New_DiD $RuralVariable_IMP SSY_) cluster(ID_t) delta(1) fe(bula cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
}
esttab pooled_c1_* using "$results_Robustness\C9_DiDImputation.csv", keep(tau) cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Full Controlls. DiD-Imputation by Borusyak et al. used.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") append 
eststo clear 



*** Check Nobs and Inidv
preserve

capture drop if cannot_impute == 1
drop if w_t4_cal == 0
count // 143042       
distinct ID_t // 4711

restore


*** Interim: Check Problem With Tau ***
** DiD-Imputation
foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) No additional Controls
	did_imputation `var' bula cohort Ei_T14 [aweight = w_t4_cal], autosample cluster(ID_t) delta(1)
	eststo pooled_c90_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
}
esttab pooled_c90_* using "$results_Robustness\C9_DiDImputation.csv", keep(tau) cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Without Controlls. DiD-Imputation by Borusyak et al. used.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace
eststo clear

foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	did_imputation `var' bula cohort Ei_T14 [aweight = w_t4_cal], autosample controls(female $family_new_DiD $Siblings_Kita_New_DiD $RuralVariable_IMP SSY_) cluster(ID_t) delta(1)
	eststo pooled_c91_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
}
esttab pooled_c90_* pooled_c91_* using "$results_Robustness\C9_DiDImputation_Tau.csv", keep(tau) cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Full Controlls. DiD-Imputation by Borusyak et al. used.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") append 
eststo clear

* Problem With Tau?
tab2xl bula cannot_impute using "$results_Robustness\Excel_BulaTau.xlsx", replace col(2) row(2)
tab2xl cohort cannot_impute using "$results_Robustness\Excel_CohortTau.xlsx", replace col(2) row(2)
tab2xl cohort bula using "$results_Robustness\Excel_CohortBula.xlsx", replace col(2) row(2)

gen BulaXCohort = bula*cohort
tab2xl BulaXCohort cannot_impute using "$results_Robustness\Excel_CohortXBulaTau.xlsx", replace col(2) row(2)


** Now, Test Wether The Exact Sample from the Borusyak-Sample has nearly the same Coefficients as the the sample with TWFE (Remember: Borusyak actively removes sample that can not be matched)
* No. Obs used in Borusyak: 52411.000
* tab cannot_impute
preserve
drop if cannot_impute == 1

foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
}
esttab pooled_c0_* using "$results_Robustness\C9_DiDImputation.csv", keep(C9) cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv.")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Without Controlls. Sample of Borusyak et al. used.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") append
eststo clear

foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable_IMP SSY_ i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
}
esttab pooled_c1_* using "$results_Robustness\C9_DiDImputation.csv", keep(C9) cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv.")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Full Controlls. Sample of Borusyak et al. used.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") append 
eststo clear

restore

* Nobs
sum C9 [aweight = w_t4_cal]
drop if w_t4_cal == 0
distinct ID_t 

