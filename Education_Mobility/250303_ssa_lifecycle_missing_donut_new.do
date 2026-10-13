********************************************************************************
*			life-cycle estimations
********************************************************************************
use "$results\ssa_panel_all_new.dta", clear
est drop _all


cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_twfe run_week i.after_week#c.run_week i.female i.bula6 i.yob 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_twfe run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2


********************************************************************************
*age-specific estimations 
********************************************************************************

*************Mobility stock
est drop _all
cap erase "$results\lifecycle_missing_donut_new_$date.csv"

keep if inrange(yob,1945,1964)
drop if inlist(run_week,-1,0,1,2)
keep if w_t4_cal != 0
keep if inrange(age,25,55)

* Generiere Missingindikator -> = 1, wenn in einem Jahr die Migrationsoutcomes nicht komplett beobachtet werden
gen missing = mig_samp == 0 // mig_samp ist 1, wenn für alle sechs Outcomes (3 auf Bula- und 3 auf Kreisebene) valide Beobachtungen vorliegen; ansonsten 0

* Betrachtte, wie viele Missings es überhaupt gibt -> hier: 1-2 Missings bis 34
bys age: tab missing 

* Generiere Variable, um Altersjahre zu kennzeichnen, in denen ein Missing vorliegtIdentifiziere Altersjahre, in denen überhaupt mindestens eine Person ein Missing hat
bys age: egen mig_samp_mean = mean(mig_samp) 

* Zeige an, in welchen Altersjahren überhaupt missings vorliegen
tab age if mig_samp_mean < 1



*estimations
foreach num of numlist 25(1)34 47(1)55 {
	ivreg2 missing $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & mig_samp_mean < 1 , robust partial($lin_plain)	
	eststo missing_lin_`num' 	
	qui sum missing [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\ssa_missing_lin_`num'.dta", replace) idnum(`num')
	restore
	
	ivreg2 missing $instr $lin_full  [aw=w_t4_cal] 	if age == `num' & mig_samp_mean < 1 , robust partial($lin_full)	
	eststo missing_full_`num' 	 	
	qui sum missing [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\ssa_missing_full_`num'.dta", replace) idnum(`num')
	restore
}


*results
esttab missing_lin_* using "$results\lifecycle_missing_donut_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility missings - no control)") mtitle
esttab missing_full_* using "$results\lifecycle_missing_donut_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility missings - full control)") mtitle

*****create dataset for export
*lin
use "$results\temp\ssa_missing_lin_25.dta", clear
foreach num of numlist 26(1)34 47(1)55 {
	append using "$results\temp\ssa_missing_lin_`num'.dta"
	cap erase "$results\temp\ssa_missing_lin_`num'.dta"
}
export excel using "$results\ssa_missing_lin.xls", firstrow(variables) replace
save "$results\temp\ssa_missing_lin.dta", replace
cap erase "$results\temp\ssa_missing_lin_1.dta"

*full
use "$results\temp\ssa_missing_full_25.dta", clear
foreach num of numlist 26(1)34 47(1)55 {
	append using "$results\temp\ssa_missing_full_`num'.dta"
	cap erase "$results\temp\ssa_missing_full_`num'.dta"
}
export excel using "$results\ssa_missing_full.xls", firstrow(variables) replace
save "$results\temp\ssa_missing_full.dta", replace
cap erase "$results\temp\ssa_missing_full_1.dta"


	
	
	