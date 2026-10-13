/**************************************************
This file will do the Balancing Test for the C9 -Variables on C9 itself
(We will check whether some variables systematically differ in comparison with C9)

	As agreed on we use the sample:
	YOB (1945, 1963)
	Age (25, 55)
	West Germany
	-> We do the analyses for C9 assigned at  age 14 (Before Compulsory Should have an effect)
	
	Data-Set Used has been Created in Do-File "230712_C9_Descriptive_Robustness"
	
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2023-07-12
***************************************************/

************************************************
* define globals
************************************************
global results_Des "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Descriptive Analysis"

global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralDummy RuralNEPSMZ 

************************************************
*    load panel: Taken from Master - Panel (as we re-define C9 Treatment)
************************************************
*use "$results_Des\Balancing_C9_CrossSectional.dta", clear
use "$results\C9_Combined_Utilized_CS_final.dta", clear // From 231030_Combine_C9.do
sort ID_t age
xtset ID_t age

** Final Restrictions
keep if inrange(yob, 1945, 1964)
tab yob
tab age
duplicates drop ID_t, force
count // 6,456 *S* Warum hier jetzt so viele wenn vorher 5xxx ?! Vs. 5386 Gewichte von t4_cal ;)

* Now: Beautiful Names
label var female "Women"
label var yob "Year of Birth"
label var bula "Federal state of school entry at Age 14"
label var p_yos_mean "Parental years of schooling (avg.)"
label var p_yos_mean_m "Parental years of schooling (avg.): Missing"
label var m_ageb4_T2 "Mother Age at Birth"
label var m_ageb4_T2_m "Mother Age at Birth: Missing"
label var D_JoinedKita_T0 "Joined Kita: Missing"
label var D_JoinedKita_T1 "Joined Kita: No"
label var D_JoinedKita_T2 "Joined Kita: Yes"
label var p_gerborn_ha_new "German parent(s)"
label var p_gerborn_ha_new_m  "German parent(s): missing"
label var D_OlderSibling_T0 "At least one older sibling: Missing"
label var D_OlderSibling_T1 "At least one older sibling: No"
label var D_OlderSibling_T2 "At least one older sibling: Yes"
label var SSY_ "Schort School Year"
label var RuralNEPSMZ "Born in Rural Municipality"

***
* Test: Recode Sibling
***
recode D_OlderSibling_T1 (1 = 2)
recode D_OlderSibling_T2 (2 = 1)

************************************************
*    Balancing Tests
************************************************
preserve
	
	*Female Parental Cohort Bula FE
	areg C9 female p_yos_mean p_yos_mean_m i.bula [aweight = w_t4_cal], robust absorb(cohort)
	estimate store Balance1
	testparm female p_yos_mean p_yos_mean_m
	estadd scalar p_value = r(p)
	estadd scalar F_value = r(F)
	
	* Other Parental BG Sibl Kita Migration 
	areg C9 female $family_new $Siblings_Kita_New $RuralDummy i.bula [aweight = w_t4_cal], robust absorb(cohort)
	estimate store Balance2
	testparm female $family_new $Siblings_Kita_New $RuralNEPSMZ
	estadd scalar p_value = r(p)
	estadd scalar F_value = r(F)
	
	*SSY
	areg C9 female $family_new $Siblings_Kita_New $RuralDummy SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	estimate store Balance3
	testparm $family_new $Siblings_Kita_New $RuralNEPSMZ SSY_
	estadd scalar p_value = r(p)
	estadd scalar F_value = r(F)
	
	
esttab Balance1 Balance2 Balance3 using "$results_Des\BalancingTest_final.csv", cells(b(fmt(3) star) se(par) p) stats(F_value p_value N, fmt(3 3 0) labels("F-Test" "P-Value" "Indiv.")) mtitle("M1" "M2" "M3") label starlevels(* 0.1 ** 0.05 *** 0.01) drop(*.bula _cons) title("Balancing Test - Dependend Variable: C9") scalar(F_value p_value) stardetach note("Placeholder") replace //stats(F p_value N, labels("F-Test" "P-Value" "Indiv.") fmt(3 0)) using "$results_Des\BalancingTest.xlsx"
eststo clear


restore

********************
* Bi-Variate Correlations
********************
preserve

*Bi-Variate CV
	foreach var of varlist female p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 RuralNEPSMZ SSY_ {
		
		est drop _all
		
		areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
		estimate store Bi10_`var'	
		qui sum `var' [aweight = w_t4_cal] if e(sample)
		*scalar y_mean = r(mean)
		*qui estadd scalar y_mean
		
		local name: variable label `var'
		esttab Bi10_* using "$results_Des\BalancingTest_final.csv", cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) keep(C9) coef(C9 "`name'") append nomtitle nonumbers noobs stardetach
		*append stats(N y_mean, fmt(0 3))
		
	}

restore

