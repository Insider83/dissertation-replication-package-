/**************************************************
This file will perform the Balancing Test for the SSA analysis
*/

********************************************************************************
*    load ssa sample with only one observation per individual
********************************************************************************
use "$results\ssa_panel_obs1_new.dta", clear // one observation per individual
keep if inrange(yob,1945,1964)

cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_twfe run_week i.after_week#c.run_week i.female i.bula6 i.yob 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6 RuralNEPS_0_20
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_twfe run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 RuralNEPS_0_20

label var female "Women"
label var yob "Year of Birth"
label var bula6 "Federal state of school entry"
label var p_yos_mean "Parental years of schooling (avg.)"
label var p_yos_mean_m "Parental years of schooling (avg.): Missing"
label var D_JoinedKita_T2_0 "Joined Kita: Missing"
label var D_JoinedKita_T2_1 "Joined Kita: No"
label var D_JoinedKita_T2_2 "Joined Kita: Yes"
label var p_gerborn_ha_new "German parent(s)"
label var p_gerborn_ha_new_m  "German parent(s): missing"
label var D_OlderSibling_T0 "At least one older sibling: Missing"
label var D_OlderSibling_T1 "At least one older sibling: No"
label var D_OlderSibling_T2 "At least one older sibling: Yes"
label var SSY__6 "SSY"
label var RuralNEPS_0_20 "Born in rural area (< 20k)"


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
tab bula6, gen(bula6_d)
foreach var of varlist bula6_d1 - bula6_d10 {
	local old_lab: var lab `var'
	local new_lab = subinstr(`"`old_lab'"', "bula6==", "",1)
	label var `var' `"- `new_lab'"'
}
tab yob, gen(yob_d)
keep if w_t4_cal != 0

************************************************
*    Balancing Tests
************************************************
cap erase "$results\SSA_BalancingTest_new_$date.csv"
preserve

	*lin - fem + parents
	reg after_week $lin_plain female p_yos_mean p_yos_mean_m [aweight = w_t4_cal], robust // partial($lin_plain)
	estimate store m1
	testparm female p_yos_mean p_yos_mean_m
	estadd scalar p_value = r(p)
	estadd scalar F_value = r(F)

	*lin full
	reg after_week $lin_plain female p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_JoinedKita_T2_2 D_JoinedKita_T2_0 D_OlderSibling_T2 D_OlderSibling_T0 RuralNEPS_0_20 [aweight = w_t4_cal], robust // partial($lin_plain)
	estimate store m2
	test female p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_JoinedKita_T2_2 D_JoinedKita_T2_0 D_OlderSibling_T2 D_OlderSibling_T0 RuralNEPS_0_20
	estadd scalar p_value = r(p)
	estadd scalar F_value = r(F)	

	*lin full
	reg after_week $lin_plain female p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_JoinedKita_T2_2 D_JoinedKita_T2_0 D_OlderSibling_T2 D_OlderSibling_T0 RuralNEPS_0_20 SSY__6  [aweight = w_t4_cal], robust // partial($lin_plain)
	estimate store m3
	test female p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_JoinedKita_T2_2 D_JoinedKita_T2_0 D_OlderSibling_T2 D_OlderSibling_T0 RuralNEPS_0_20 SSY__6 
	estadd scalar p_value = r(p)
	estadd scalar F_value = r(F)		
	
esttab m1 m2 m3 using "$results\SSA_BalancingTest_new_$date.csv", cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) title("Balancing Test - Dependend Variable: after") drop(_cons run_week 0.after_week#c.run_week 1.after_week#c.run_week) stats(F_value p_value N, fmt(3 3 0) labels("F-Test" "P-Value" "Indiv.")) mtitle("M1" "M2" "M3") label stardetach refcat(bula6_d1 "Federal states (Ref: NRW)"  D_JoinedKita_T2_2 "Joining Kita (Ref: No)" D_OlderSibling_T2 "Having older siblings (Ref: No)", nolabel)  replace //stats(F p_value N, labels("F-Test" "P-Value" "Indiv.") fmt(3 0)) using "$results_Des\BalancingTest.xlsx"
eststo clear

restore

********************
* Bi-Variate Correlations
********************
cap erase "$results\SSA_Bivariate_new_$date.csv"
preserve
est drop _all

recode p_gerborn_ha_new (-1 = .)
recode m_ageb4_T2(0 50 = .)


	foreach var of varlist female p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_JoinedKita_T2_1 D_JoinedKita_T2_2 D_JoinedKita_T2_0 D_OlderSibling_T1 D_OlderSibling_T2 D_OlderSibling_T0 RuralNEPS_0_20 SSY__6  {
		reg `var' i.after_week $lin_plain [aweight = w_t4_cal], robust // partial($lin_plain)
		estimate store lin_`var'
		qui sum `var' [aweight = w_t4_cal] if e(sample)
		scalar y_mean = r(mean)
		qui estadd scalar y_mean
		}

esttab lin_* using "$results\SSA_Bivariate_new_$date.csv", cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) keep(1.after_week) stats(N y_mean, fmt(0 3)) title("Balancing Test - linear specification") stardetach append 
restore

	
cap erase "$results\SSA_Bivariate_long_new_$date.csv"
preserve

recode p_gerborn_ha_new (-1 = .)
recode m_ageb4_T2(0 50 = .)


	foreach var of varlist female p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_JoinedKita_T2_1 D_JoinedKita_T2_2 D_JoinedKita_T2_0 D_OlderSibling_T1 D_OlderSibling_T2 D_OlderSibling_T0 RuralNEPS_0_20 SSY__6   { // 
		est drop _all
	
		reg `var' i.after_week $lin_plain [aweight = w_t4_cal], robust // partial($lin_plain)
		estimate store lin_`var'

		
*		reg `var' i.after_week $quad_plain [aweight = w_t4_cal], robust // partial($quad_plain)
*		estimate store quad_`var'
	
		local name: variable label `var'		
		esttab lin_*  using "$results\SSA_Bivariate_long_new_$date.csv", cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) keep(1.after_week) coef(1.after_week "`name'")  nomtitle nonumbers noobs stardetach append 
	}

restore