/**************************************************
This file will do the TWFE the C9 (Compulsory School Reform)
	i) Classic TWFE of Migration on C9
	ii) TWFE of Education on C9 (Infos on Education taken from "230905_educ_prep.do)
	
	*Important: We distinguish between only one cohorts and one sample:
	i)1945-64
	ii) Age 25-55
	iii) West - Germany
	
	* We also merge our Urban-Rural Panel from "251104_basicpanel_outcomes.do"
		
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2023-09-08
***************************************************/

************************************************
* define globals
************************************************
global results_UrbanRural "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\RuralUrban" 

global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ

************************************************
* Make directory
************************************************
capture mkdir $results_UrbanRural

************************************************
* Load and Clean
************************************************
clear all
use "$results\C9_Combined_Utilized_Panel_final.dta", clear // From "250413_Combine_C9_final.do"

keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)

foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}

************************************************
* Joinby with data from Rural and Urban
************************************************
count // 189,519
joinby ID_t age using "$results\0_Panel_Migration_Urban_Rural_Municipality_Merge.dta",  unmatched(master) // From "251111_basicpanel_outcomes.do"
drop _merge
count // 189,519
sum mig_stock_RR mig_stock_UU mig_stock_RU mig_stock_UR mig_stock_mun mig_stock_kr mig_stock

************************************************
* TWFE on Migration
************************************************
foreach var of varlist mig_stock_RR mig_stock_UU mig_stock_RU mig_stock_UR mig_flow1_RR mig_flow1_UU mig_flow1_RU mig_flow1_UR mig_flow5_RR mig_flow5_UU mig_flow5_RU mig_flow5_UR {
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	}
	
*Estout
*W/o Bula
esttab pooled_* using "$results_UrbanRural\TWFE_URbanRural_Full_new_final.csv", keep(C9) cells(b(fmt(5) star) se(par fmt(5)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Baseline") replace // scalar(mig_mean) drop(*.bula)
eststo clear


*** Female ***

foreach var of varlist mig_stock_RR mig_stock_UU mig_stock_RU mig_stock_UR mig_flow1_RR mig_flow1_UU mig_flow1_RU mig_flow1_UR mig_flow5_RR mig_flow5_UU mig_flow5_RU mig_flow5_UR {
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal] if female == 1, cluster(ID_t) absorb(cohort)
	eststo pooled_c2_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if female == 1, cluster(ID_t) absorb(cohort)
	eststo pooled_c3_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	}
	
*Estout
*W/o Bula
esttab pooled_* using "$results_UrbanRural\TWFE_URbanRural_Full_new_final.csv", keep(C9) cells(b(fmt(5) star) se(par fmt(5)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Female Only") append // scalar(mig_mean) drop(*.bula)
eststo clear

*** Male ***

foreach var of varlist mig_stock_RR mig_stock_UU mig_stock_RU mig_stock_UR mig_flow1_RR mig_flow1_UU mig_flow1_RU mig_flow1_UR mig_flow5_RR mig_flow5_UU mig_flow5_RU mig_flow5_UR {
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal] if female == 0, cluster(ID_t) absorb(cohort)
	eststo pooled_c4_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if female == 0, cluster(ID_t) absorb(cohort)
	eststo pooled_c5_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	}
	
*Estout
*W/o Bula
esttab pooled_* using "$results_UrbanRural\TWFE_URbanRural_Full_new_final.csv", keep(C9) cells(b(fmt(5) star) se(par fmt(5)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Male Only") append // scalar(mig_mean) drop(*.bula)
eststo clear

*** Born Rural ***

foreach var of varlist mig_stock_RR mig_stock_UU mig_stock_RU mig_stock_UR mig_flow1_RR mig_flow1_UU mig_flow1_RU mig_flow1_UR mig_flow5_RR mig_flow5_UU mig_flow5_RU mig_flow5_UR {
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal] if RuralNEPSMZ == 1, cluster(ID_t) absorb(cohort)
	eststo pooled_c6_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if RuralNEPSMZ == 1, cluster(ID_t) absorb(cohort)
	eststo pooled_c7_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	}
	
*Estout
*W/o Bula
esttab pooled_* using "$results_UrbanRural\TWFE_URbanRural_Full_new_final.csv", keep(C9) cells(b(fmt(5) star) se(par fmt(5)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Born Rural") append // scalar(mig_mean) drop(*.bula)
eststo clear

*** Born Urban ***
foreach var of varlist mig_stock_RR mig_stock_UU mig_stock_RU mig_stock_UR mig_flow1_RR mig_flow1_UU mig_flow1_RU mig_flow1_UR mig_flow5_RR mig_flow5_UU mig_flow5_RU mig_flow5_UR {
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal] if RuralNEPSMZ == 0, cluster(ID_t) absorb(cohort)
	eststo pooled_c8_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if RuralNEPSMZ == 0, cluster(ID_t) absorb(cohort)
	eststo pooled_c9_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	}
	
*Estout
*W/o Bula
esttab pooled_* using "$results_UrbanRural\TWFE_URbanRural_Full_new_final.csv", keep(C9) cells(b(fmt(5) star) se(par fmt(5)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Born Urban") append // scalar(mig_mean) drop(*.bula)
eststo clear

