********************************************************************************
*			pooled estimations
********************************************************************************
use "$results\ssa_panel_all_new.dta", clear
est drop _all
cap erase "$results\SSA_commuting_donut_new_$date.csv"

cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6 i.RuralNEPS_0_20
global lin_early run_week i.after_week#c.run_week i.kann_6
global lin_student run_week i.after_week#c.run_week t_wo_lehrer
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 i.RuralNEPS_0_20


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

keep if w_t4_cal != 0

*donut
drop if inlist(run_week,-1,0,1,2)


*estimations - plain specification (linear)
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	
	ivreg2 pendel_br_cond $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_plain)	
	eststo pendel_br_cond		
	qui sum pendel_br_cond [aw=w_t4_cal]	 if e(sample)	
	scalar commute_mean = r(mean)
	qui estadd scalar commute_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 pendel_br_uncond $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo pendel_br_uncond		
	qui sum pendel_br_uncond [aw=w_t4_cal]	 if e(sample)	
	scalar commute_mean = r(mean)
	qui estadd scalar commute_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 pendel_kr_cond $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo pendel_kr_cond		
	qui sum pendel_kr_cond [aw=w_t4_cal]	 if e(sample)	
	scalar commute_mean = r(mean)
	qui estadd scalar commute_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 pendel_kr_uncond $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_plain)	
	eststo pendel_kr_uncond	
	qui sum pendel_kr_uncond [aw=w_t4_cal]	 if e(sample)	
	scalar commute_mean = r(mean)
	qui estadd scalar commute_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	
	esttab pendel_br_* pendel_kr_* using "$results\SSA_commuting_donut_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv commute_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Commuting (main specification)") nodepvars mtitle("Commuting across states (missings dropped)" "Commuting across states (missings as zero)" "Commuting across counties (missings dropped)" "Commuting across counties (missings as zero)")	

	restore	