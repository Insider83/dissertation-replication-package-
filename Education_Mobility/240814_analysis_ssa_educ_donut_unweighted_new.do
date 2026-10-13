use "$results\ssa_panel_obs1_new.dta", clear

********************************************************************************
* 	RF educ estimations
********************************************************************************

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
drop if inlist(run_week,-1,0,1,2)

centile(YOS_Sum), centile(0.5, 99.5)
gen YOS_Sum_05 =  r(c_1)
gen YOS_Sum_995 = r(c_2)

label var YOS_Sum "YOS (Sebastian)"
clonevar YOS1_Sum = YOS_Sum

clonevar YOS2_Sum = YOS_Sum
replace YOS2_Sum = . if (YOS2_Sum < YOS_Sum_05) | (YOS2_Sum > YOS_Sum_995)
label var YOS2_Sum "YOS (Sebastian; without half percentile)"


clonevar YOS3_Sum = YOS_Sum
replace YOS3_Sum = YOS_Sum_05 if (YOS3_Sum < YOS_Sum_05) 
replace YOS3_Sum = YOS_Sum_995 if (YOS3_Sum > YOS_Sum_995) 
label var YOS3_Sum "YOS (Sebastian; half percentile replaced )"

*recode lower education wrt to C9
recode yos_max (8 = 9) if C9_14 == 1

recode yoe (8 = 9) if C9_14 == 1
clonevar yoe_yrs = yoe

recode yoe_grade (8 = 9) if C9_14 == 1

gen rs_abi = inlist(dgr_max,2,3)
label var rs_abi "More than basic degree"


** donut estimation - without run_week -1,0,1,2
**** all
cap erase "${results}\educ_all_donut_unweighted_new_$date.csv"
foreach var of varlist hs1 rs1 abi rs_abi YOS1_Sum YOS2_Sum YOS3_Sum yos_max uni yoe_yrs yoe_grade { //
preserve
estimates drop _all
keep if inrange(yob,1945,1964)
keep if `var' != .
drop if `var' == -99

qui ivreg2 `var' $instr $lin_plain ,  robust partial($lin_plain)  //  2011 weighted
estimates store lin_plain_`var'
qui sum `var'  if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $lin_full ,  robust partial($lin_full)  //  2011 weighted
estimates store lin_full_`var'
qui sum `var'  if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $lin_early ,  robust partial($lin_early)  //  2011 weighted
estimates store lin_early_`var'
qui sum `var'  if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $quad_plain ,  robust partial($quad_plain)  //  2011 weighted
estimates store quad_plain_`var'
qui sum `var'  if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 


qui ivreg2 `var' $instr $quad_full ,  robust partial($quad_full)  //  2011 weighted
estimates store quad_full_`var'
qui sum `var'  if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value


cap drop donut
gen donut = inlist(run_week,-1,0,1,2)
eststo rdrobust_`var': 	rdrobust `var' run_week if donut == 0, c(1) p(1) weights(w_t4_cal) vce(hc0) masspoints(check)
qui sum `var'  if e(sample) & donut == 0
scalar y_mean=r(mean) 
*scalar F_value = e(F)
qui estadd scalar y_mean 
*qui estadd scalar F_value 



local name: variable label `var'
esttab lin_* quad_* rdrobust_* using "$results\educ_all_donut_unweighted_new_$date", append scsv keep(1.after_week RD_Estimate) cells(b(fmt(3) star) se(par) p) scalar(y_mean F_value) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`name'") nodepvars mtitle("linear plain" "linear full spec" "linear plain with early enrollment" "quadratic plain" "quadratic full spec" "rdrobust") 
restore
}

**** maintable
cap erase "${results}\educ_maintable_donut_unweighted_new_$date.csv"
estimates drop _all
foreach var of varlist hs1 rs1 abi rs_abi yos_max uni { //

qui ivreg2 `var' $instr $lin_plain ,  robust partial($lin_plain)  //  2011 weighted
estimates store lin_plain_`var'
qui sum `var'  if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $lin_full ,  robust partial($lin_full)  //  2011 weighted
estimates store lin_full_`var'
qui sum `var'  if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 
}

esttab lin_plain_* using "$results\educ_maintable_donut_unweighted_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean F_value) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("RDD regression without controls") nodepvars mtitle("Basic degree" "Middle degree" "High school" "More than basic degree" "Years of schooling (grades)" "University degree")

esttab lin_full_* using "$results\educ_maintable_donut_unweighted_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean F_value) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("RDD regression with controls") nodepvars mtitle("Basic degree" "Middle degree" "High school" "More than basic degree" "Years of schooling (grades)" "University degree")