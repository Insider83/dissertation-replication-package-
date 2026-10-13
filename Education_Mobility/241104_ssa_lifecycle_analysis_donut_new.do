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
cap erase "$results\lifecycle_stock_bl_donut_new_$date.csv"
cap erase "$results\lifecycle_stock_kr_donut_new_$date.csv"

keep if inrange(yob,1945,1964)
drop if inlist(run_week,-1,0,1,2)
*estimations
foreach num of numlist 1(1)64 {
	ivreg2 migstock $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & inlist(migstock_kr_max,0,1)	, robust partial($contr)	
	eststo stock_bl_`num' 	
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\bl_stock_cycle_donut_`num'.dta", replace) idnum(`num')
	restore
	
	ivreg2 migstock_kr $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & inlist(migstock_kr_max,0,1)	, robust partial($contr)	
	eststo stock_kr_`num' 	
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\kr_stock_cycle_donut_`num'.dta", replace) idnum(`num')
	restore	
}


*results
esttab stock_bl_* using "$results\lifecycle_stock_bl_donut_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility stock - BL life cycle)")
esttab stock_kr_* using "$results\lifecycle_stock_kr_donut_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility stock - KR life cycle)")

*****create dataset for export
*BL
use "$results\temp\bl_stock_cycle_donut_1.dta", clear
foreach num of numlist 2(1)64 {
	append using "$results\temp\bl_stock_cycle_donut_`num'.dta"
	cap erase "$results\temp\bl_stock_cycle_donut_`num'.dta"
}
export excel using "$results\temp\bl_stock_cycle_donut_weighted_new.xls", firstrow(variables) replace
save "$results\temp\bl_stock_cycle_donut_weighted_new.dta", replace
cap erase "$results\temp\bl_stock_cycle_donut_1.dta"

*KR
use "$results\temp\kr_stock_cycle_donut_1.dta", clear
foreach num of numlist 2(1)64 {
	append using "$results\temp\kr_stock_cycle_donut_`num'.dta"
	cap erase "$results\temp\kr_stock_cycle_donut_`num'.dta"
}
export excel using "$results\temp\kr_stock_cycle_donut_weighted_new.xls", firstrow(variables) replace
save "$results\temp\kr_stock_cycle_donut_weighted_new.dta", replace
cap erase "$results\temp\kr_stock_cycle_donut_1.dta"


	
	
*************Mobility flow1
use "$results\ssa_panel_all_new.dta", clear
est drop _all

cap drop run_week2 
gen run_week2 = run_week*run_week

cap erase "$results\lifecycle_flow1_bl_donut_new_$date.csv"
cap erase "$results\lifecycle_flow1_kr_donut_new_$date.csv"

keep if inrange(yob,1945,1964)
drop if inlist(run_week,-1,0,1,2)
*estimations
foreach num of numlist 1(1)64 {
	ivreg2 migflow1 $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & inlist(migflow1_kr_max,0,1)	, robust partial($contr)	
	eststo flow1_bl_`num' 	
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\bl_flow1_cycle_donut_`num'.dta", replace) idnum(`num')
	restore
	
	ivreg2 migflow1_kr $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & inlist(migflow1_kr_max,0,1)	, robust partial($contr)	
	eststo flow1_kr_`num' 	
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\kr_flow1_cycle_donut_`num'.dta", replace) idnum(`num')
	restore	
}


*results
esttab flow1_bl_* using "$results\lifecycle_flow1_bl_donut_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility flow1 - BL life cycle)")
esttab flow1_kr_* using "$results\lifecycle_flow1_kr_donut_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility flow1 - KR life cycle)")

*****create dataset for export
*BL
use "$results\temp\bl_flow1_cycle_donut_1.dta", clear
foreach num of numlist 2(1)64 {
	append using "$results\temp\bl_flow1_cycle_donut_`num'.dta"
	cap erase "$results\temp\bl_flow1_cycle_donut_`num'.dta"
}
save "$results\temp\bl_flow1_cycle_donut_weighted_new.dta", replace
export excel using "$results\temp\bl_flow1_cycle_donut_weighted_new.xls", firstrow(variables) replace
cap erase "$results\temp\bl_flow1_cycle_donut_1.dta"

*KR
use "$results\temp\kr_flow1_cycle_donut_1.dta", clear
foreach num of numlist 2(1)64 {
	append using "$results\temp\kr_flow1_cycle_donut_`num'.dta"
	cap erase "$results\temp\kr_flow1_cycle_donut_`num'.dta"
}
save "$results\temp\kr_flow1_cycle_donut_weighted_new.dta", replace
export excel using "$results\temp\kr_flow1_cycle_donut_weighted_new.xls", firstrow(variables) replace
cap erase "$results\temp\kr_flow1_cycle_donut_1.dta"




	


*************Mobility flow5
use "$results\ssa_panel_all_new.dta", clear
est drop _all

cap drop run_week2 
gen run_week2 = run_week*run_week

cap erase "$results\lifecycle_flow5_bl_donut_new_$date.csv"
cap erase "$results\lifecycle_flow5_kr_donut_new_$date.csv"

keep if inrange(yob,1945,1964)
drop if inlist(run_week,-1,0,1,2)
*estimations
foreach num of numlist 5(1)64 {
	ivreg2 migflow5 $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & inlist(migflow5_kr_max,0,1)	, robust partial($contr)	
	eststo flow5_bl_`num' 	
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\bl_flow5_cycle_donut_`num'.dta", replace) idnum(`num')
	restore
	
	ivreg2 migflow5_kr $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & inlist(migflow5_kr_max,0,1)	, robust partial($contr)	
	eststo flow5_kr_`num' 	
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\kr_flow5_cycle_donut_`num'.dta", replace) idnum(`num')
	restore	
}


*results
esttab flow5_bl_* using "$results\lifecycle_flow5_bl_donut_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility flow5 - BL life cycle)")
esttab flow5_kr_* using "$results\lifecycle_flow5_kr_donut_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility flow5 - KR life cycle)")

*****create dataset for export
*BL
use "$results\temp\bl_flow5_cycle_donut_5.dta", clear
foreach num of numlist 6(1)64 {
	append using "$results\temp\bl_flow5_cycle_donut_`num'.dta"
	cap erase "$results\temp\bl_flow5_cycle_donut_`num'.dta"
}
save "$results\temp\bl_flow5_cycle_donut_weighted_new.dta", replace
export excel using "$results\temp\bl_flow5_cycle_donut_weighted_new.xls", firstrow(variables) replace
cap erase "$results\temp\bl_flow5_cycle_donut_1.dta"

*KR
use "$results\temp\kr_flow5_cycle_donut_5.dta", clear
foreach num of numlist 6(1)64 {
	append using "$results\temp\kr_flow5_cycle_donut_`num'.dta"
	cap erase "$results\temp\kr_flow5_cycle_donut_`num'.dta"
}
save "$results\temp\kr_flow5_cycle_donut_weighted_new.dta", replace
export excel using "$results\temp\kr_flow5_cycle_donut_weighted_new.xls", firstrow(variables) replace
cap erase "$results\temp\kr_flow5_cycle_donut_1.dta"



	
	