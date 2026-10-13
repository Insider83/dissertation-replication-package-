/**************************************************
This file will do the TWFE of the C9 (Compulsory School Reform)
	i) First Stage TWFE of Education on C9 (Infos on Education taken from "230905_educ_prep.do)
	
	*Important: For TWFE, we distinguish between only one cohorts and one sample:
	i) 1945-64
	ii) Age 25-55
	iii) West - Germany
		
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2023-12-12
***************************************************/

************************************************
* define globals
************************************************
global results_FirstStage "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\First Stage C9"

global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

************************************************
*    load final panel
************************************************
*use "$results_Des\Balancing_C9_CrossSectional.dta", clear  
use "$results\C9_Combined_Utilized_CS_final.dta", clear

* Make it cross-sectional 
duplicates drop ID_t, force

sort ID_t age
xtset ID_t age

************************************************
* Limit Data-Set
************************************************
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)

************************************************
* First Stage, Genereally Use Three Main Distinctions - YOS, YOS_Harmonized and YOS without Outliers
************************************************
foreach var of varlist YOS_Sum  { // YOS_Harmonized YOS_NoOutlier
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar C9_Mean = r(mean)
	qui estadd scalar C9_Mean
}

esttab pooled_c0_* using "$results_FirstStage\Educ_TWFE_FirstStage.csv", keep(C9) stats(N, fmt(0 5 5) labels("Indiv.")) mtitle("YOS - All Perc. " "YOS - 0.5 & 99.5 Replaced" "YOS - 0.5 & 99.5 Perc. Removed") cells(b(fmt(5) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("C9 Regression on Education (First Stage) - No Controls") addnotes("") replace // cells(b(fmt(5)) se(fmt(5))) b(%4.6g) 

foreach var of varlist YOS_Sum { // YOS_Harmonized YOS_NoOutlier
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar C9_Mean = r(mean)
	qui estadd scalar C9_Mean
}

esttab pooled_c1_* using "$results_FirstStage\Educ_TWFE_FirstStage.csv", keep(C9) stats(N, fmt(0 5 5) labels("Indiv.")) mtitle("Full Spec. YOS - All Perc. " " Full Spec. YOS - 0.5 & 99.5 Replaced" "Full Spec. YOS - 0.5 & 99.5 Perc. Removed") cells(b(fmt(5) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("C9 Regression on Education (First Stage) - Full Controls") addnotes("") append // cells(b(fmt(5)) se(fmt(5)))
eststo clear
