**************SSA - 1st stage************************************************
use "$results\ssa_panel_obs1_new.dta", clear



estimates drop _all


cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6 i.RuralNEPS_0_20
global lin_early run_week i.after_week#c.run_week i.kann_6
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 i.RuralNEPS_0_20


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 

** create different aase variables (1 = original; 2 = w/o half percentile; 3 replacement of half percentile with percentile value)

centile(aase), centile(0.5, 99.5)
gen aase_05 =  r(c_1)
gen aase_995 = r(c_2)

label var aase "SSA (orig)"

clonevar aase_2 = aase
replace aase_2 = . if (aase_2 < aase_05) | (aase_2 > aase_995)
label var aase_2 "SSA (without half percentile from bottom/top of distribution)"

clonevar aase_3 = aase
replace aase_3 = aase_05 if (aase_3 < aase_05) 
replace aase_3 = aase_995 if (aase_3 > aase_995) 
label var aase_3 "SSA (half percentile from bottom/top replaced with value of percentile)"

* old for grade
gen entry_year_act = year(start_sp1)
gen older = entry_year_act >= yob +7 & entry_year_act != .
label var older "Old for grade"

* enrollment year as expected
gen compliers = year(start_sp1) == year(entry_6) // year of actual enrolment = year of expected enrolment
label var compliers "Enrolment year as expected"

**** 1st Stage results - all
cap erase "${results}\ssa_1ststage_full_new_$date.csv"
foreach var of varlist aase aase_2 aase_3 older compliers { //
estimates drop _all
preserve
keep if `var' != .

qui ivreg2 `var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  //  2011 weighted
estimates store lin_plain_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $lin_full [aw=w_t4_cal],  robust partial($lin_full)  //  2011 weighted
estimates store lin_full_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $lin_early [aw=w_t4_cal],  robust partial($lin_early)  //  2011 weighted
estimates store lin_early_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $quad_plain [aw=w_t4_cal],  robust partial($quad_plain)  //  2011 weighted
estimates store quad_plain_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 


qui ivreg2 `var' $instr $quad_full [aw=w_t4_cal],  robust partial($quad_full)  //  2011 weighted
estimates store quad_full_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

eststo rdrobust_`var': 	rdrobust `var' run_week , c(1) p(1) weights(w_t4_cal) vce(hc0) masspoints(check)
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
*scalar F_value = e(F)
qui estadd scalar y_mean 
*qui estadd scalar F_value 


local name: variable label `var'
esttab lin_* quad_* rdrobust_* using "$results\ssa_1ststage_full_new_$date", append scsv keep(1.after_week RD_Estimate) cells(b(fmt(3) star) se(par) p) scalar(y_mean F_value) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`name'") nodepvars mtitle("linear plain" "linear full spec" "linear plain with early enrollment" "quadratic plain" "quadratic full spec" "rdrobust") 
restore
}

foreach var of varlist abi_sectrack abi_sectrack_max acadt acadt_filled { //
estimates drop _all
preserve
keep if `var' != .

qui ivreg2 `var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  //  2011 weighted
estimates store lin_plain_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $lin_full [aw=w_t4_cal],  robust partial($lin_full)  //  2011 weighted
estimates store lin_full_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $lin_early [aw=w_t4_cal],  robust partial($lin_early)  //  2011 weighted
estimates store lin_early_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $quad_plain [aw=w_t4_cal],  robust partial($quad_plain)  //  2011 weighted
estimates store quad_plain_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 


qui ivreg2 `var' $instr $quad_full [aw=w_t4_cal],  robust partial($quad_full)  //  2011 weighted
estimates store quad_full_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

eststo rdrobust_`var': 	rdrobust `var' run_week , c(1) p(1) weights(w_t4_cal) vce(hc0) masspoints(check)
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
*scalar F_value = e(F)
qui estadd scalar y_mean 
*qui estadd scalar F_value 

local name: variable label `var'
esttab lin_* quad_* rdrobust_* using "$results\ssa_1ststage_full_new_$date", append scsv keep(1.after_week RD_Estimate) cells(b(fmt(3) star) se(par) p) scalar(y_mean F_value) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`name'") nodepvars mtitle("linear plain" "linear full spec" "linear plain with early enrollment" "quadratic plain" "quadratic full spec" "rdrobust")  
restore
}

**** 1st Stage results - maintable
cap erase "${results}\ssa_1ststage_maintable_full_new_$date.csv"
estimates drop _all
foreach var of varlist aase older compliers acadt_filled { //

qui ivreg2 `var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  //  2011 weighted
estimates store lin_plain_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $lin_full [aw=w_t4_cal],  robust partial($lin_full)  //  2011 weighted
estimates store lin_full_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value
}
*local name: variable label `var'
esttab lin_plain_* using "$results\ssa_1ststage_maintable_full_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean F_value) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("RDD regression without controls") nodepvars mtitle("School starting age" "Old for grade" "Enrollment year as expected" "Academic track") 

esttab lin_full_* using "$results\ssa_1ststage_maintable_full_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean F_value) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("RDD regression without controls") nodepvars mtitle("School starting age" "Old for grade" "Enrollment year as expected" "Academic track")



