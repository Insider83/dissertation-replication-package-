********************************************************************************
*			Attrition estimations
********************************************************************************
use "$results\C9_Combined_Full_Panel_final.dta", clear
est drop _all


************************************************
* define globals
************************************************
global results_Attrition "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Attrition" 

global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ


*** Clean sample ***
keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0
keep if inrange(age,25,55)
* keep if mig_samp == 1

bys ID_t (age): egen last_age = max(age)  
gen age55 = last_age == 55

duplicates drop ID_t, force

********************************************************************************
* Last Age Regression
********************************************************************************

************************************************
* TWFE on Migration
************************************************
foreach var of varlist last_age age55 {
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
esttab pooled_* using "$results_Attrition\TWFE_Attrition_final.csv", drop(*.bula) cells(b(fmt(3) star) se(par) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`var'") addnotes("") replace // scalar(mig_mean)


	
	
	