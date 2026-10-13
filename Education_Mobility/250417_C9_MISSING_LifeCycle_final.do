/**************************************************
This file will do the TWFE-Regressions for Individuals that dropped out of our sample

	
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2025-31-03
***************************************************/

************************************************
* define globals
************************************************
global results_LifeCycleMissing "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Missing Cycle"

* DiD-Imputation Packages does not like i. - prefix, therefore define new globals
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ


************************************************
* Create New Panel for Lifetime Check 
************************************************

*** From Basic Panel ***
* use "$results\0_basicpanel.dta", clear // new from 2024 / 06 / 07
use "$results\0_basicpanel_final.dta", clear
sort ID_t date
xtset ID_t date

* Constistent Cleaning of Dataset
* Only Born in West-Germany (excluding Berlin)
keep if inrange(bl_birth, 1, 10)
drop if age > 70

************************************************
* Age for C9 == 14 [As agreed upon]
************************************************
sort ID_t date
*define state for treatment assignment (C9): Age 14
global age_T 14
rename bula bula_T
gen bula_= bula_T if bdate + $age_T *12 == date // We assign Treatment-Bula to age 14*12 = 14; Will later be filled via egen(max) bula_ = bula at age 14
*br ID_t bdate date bula_
bysort ID_t: egen bula = max(bula_) // bula: Bundesland where I have been at 14 (Static)
lab val bula de1619
keep if inrange(bula, 1, 10) // Berlin and East-Germany excluded // distinct ID_t // 11497

*merge with schooling_laws (contains C9-variable)
joinby yob mob bula using "$results\schooling_laws_all.dta" 
*drop _merge
*4 Bula without Control/Always-Treated: 1SH, 2HH, 4BR, 10SA

*Generate Cohort (as time-variable) and Time of Treatment for Estimators (*S* ist es ok die jetzt schon zu machen?)
sort ID_t bdate date
egen cohort = group(bdate)
bysort bula: egen Ei_ = min(cohort) if C9 == 1 //create oldest cohorts when first C9 happens in for every state
bysort bula: egen Ei_T$age_T = min(Ei_) //copy this oldest cohort of C9 to every bula
drop Ei_

*Check Constistence, Migration and Education
tab C9, m // Looks Good
distinct ID_t if inrange(yob, 1945, 1964) //  6299
distinct ID_t if inrange(yob, 1945, 1964) & inrange(age, 25, 55) //  6299

* IMPORTANT FOR MISSING
*recode mig* (99=.)
recode mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr (99=.)


*** Educ ***
*recode Education
tab abi_sectrack
recode abi_sectrack (-99 = .)

*create YOS - Outlier and Harmonizations
*Mark and save 0.5% percentile
centile(YOS_Sum), centile(0.5, 99.5)
gen yos_outlier = ( YOS_Sum < r(c_1) | YOS_Sum > r(c_2) )
label var yos_outlier "outliers (years of schooling)"
*drop if ( YOS_Sum < r(c_1) | YOS_Sum > r(c_2) )

centile(YOS_Sum), centile(0.5, 99.5)
gen yos_outlier_005 = ( YOS_Sum < r(c_1) )
centile(YOS_Sum), centile(0.5, 99.5)
gen yos_outlier_995 = ( YOS_Sum > r(c_2) )
egen p005 = pctile(YOS_Sum), p(0.5)
egen p995 = pctile(YOS_Sum), p(99.5)

*Gen Variable No 0.5% and 99.5% Quantiles
gen YOS_NoOutlier = .
replace YOS_NoOutlier = YOS_Sum
replace YOS_NoOutlier = . if yos_outlier == 1

*Also: New YOS, where we replace the YOS_Sum outlier with values from the 0.5 and 99.5th percentile (Save Observations)
gen YOS_Harmonized = .
replace YOS_Harmonized = YOS_Sum
replace YOS_Harmonized = p005 if yos_outlier_005 == 1 & YOS_Sum != .
replace YOS_Harmonized = p995 if yos_outlier_995 == 1 & YOS_Sum != .

label var YOS_NoOutlier "Years of schooling (C9 first stage). P05 and P995 removed."
label var YOS_Harmonized "Years of schooling (C9 first stage). P05 and P995 replaced."

drop p005 p995 yos_outlier_005 yos_outlier_995
sum YOS_Sum YOS_NoOutlier YOS_Harmonized [aweight=w_t4_cal], d

* Create School Startin Age from Antons file 
merge m:1 ID_t using "$results\schoolentry.dta", keepusing(sbula_1 start_p start_sp1) // .dta from Anton
keep if _merge == 3
drop _merge
gen bdate_SSA = mdy(mob,14,yob)
format %tdD_m_CY start_p bdate_SSA
gen aase = round(((start_sp1 - bdate_SSA)/365),.01)
label var aase "age at school entry"

* Create "New" School Variables (Adjust for C9 Modifications)
recode yos_max (8 = 9) if C9 == 1

recode yoe (8 = 9) if C9 == 1
clonevar yoe_yrs = yoe
recode yoe_grade (8 = 9) if C9 == 1

cap drop hs1 abi rs1
gen hs1 = inlist(dgr_max,0,1,.)
label var hs1 "Basic degree"
gen rs1 = inlist(dgr_max,2)
label var rs1 "Middle degree"
gen abi = inlist(dgr_max,3)
label var abi "High school"

gen rs_abi = inlist(dgr_max,2,3)
label var rs_abi "More than basic degree"


* Manually Drop Individuals with no Info on Education
drop if ID_t == 8002143| ID_t == 8011382 | ID_t == 8002692| ID_t == 8004579 | ID_t == 8007719 | ID_t == 8015414

*Save .dta
save "$results\C9_Combined_Cycle.dta", replace
use "$results\C9_Combined_Cycle.dta", clear

* *all with mobility outcomes
keep if inrange(bl_birth,1,10)
keep if inrange(yob,1945,1964)
* keep if inrange(bl_birth,1,10) 


********************************************************************************
* Prepare Variable
********************************************************************************
gen mig_samp = inlist(migstock_kr_max,0,1) & inlist(migflow1_kr_max,0,1) & inlist(migflow5_kr_max,0,1)

*** Duplicates Drop ***
duplicates drop ID_t age, force 

*** True Age Ratio ***
keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0
keep if inrange(age,25,55)

gen missing = mig_samp == 0 
tab missing, m


* Betrachtte, wie viele Missings es überhaupt gibt -> hier: 1-2 Missings bis 34
bys age: tab missing 
* We have missings from 25 - 34 and  48 - 55

* Generiere Variable, um Altersjahre zu kennzeichnen, in denen ein Missing vorliegtIdentifiziere Altersjahre, in denen überhaupt mindestens eine Person ein Missing hat
bys age: egen mig_samp_mean = mean(mig_samp) 

* Zeige an, in welchen Altersjahren überhaupt missings vorliegen
tab age if mig_samp_mean < 1

*** 
* Save .dta
*** 
save "$results\C9_Combined_Cycle.dta", replace
use "$results\C9_Combined_Cycle.dta", clear

********************************************************************************
*age-specific estimations 
********************************************************************************


*estimations
foreach num of numlist 25(1)34 48(1)55 {
	
	
	* i) No additional Controls
	areg missing C9 i.bula [aweight = w_t4_cal] if age == `num' & mig_samp_mean < 1, robust absorb(cohort)
	eststo c0_m_`num'
	qui sum missing [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
	preserve
	parmest, es(N) saving ("$results_LifeCycleMissing\C9_missing_NC_`num'.dta", replace) idnum(`num')
	restore
	
	* ii) No additional Controls
	areg missing C9 $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula  [aweight = w_t4_cal] if age == `num' & mig_samp_mean < 1, robust absorb(cohort)
	eststo c1_m_`num'
	qui sum missing [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
	preserve
	parmest, es(N) saving ("$results_LifeCycleMissing\C9_missing_FC_`num'.dta", replace) idnum(`num')
	restore
	
}

*results
esttab c0_m_* using "$results_LifeCycleMissing\lifecycle_missing_C9", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility C9 missings - no control)") mtitle
esttab c1_m_* using "$results_LifeCycleMissing\lifecycle_missing_C9", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility C9 missings - full control)") mtitle

*****create dataset for export
* Uncontrolled
use "$results_LifeCycleMissing\C9_missing_NC_25.dta", clear
foreach num of numlist 26(1)34 48(1)55 {
	append using "$results_LifeCycleMissing\C9_missing_NC_`num'.dta"
	cap erase "$results_LifeCycleMissing\C9_missing_NC_`num'.dta"
}
export excel using "$results_LifeCycleMissing\C9_missing_NC.xls", firstrow(variables) replace
save "$results_LifeCycleMissing\C9_missing_NC.dta", replace
cap erase "$results_LifeCycleMissing\C9_missing_NC_25.dta"

* Fully Controlled
use "$results_LifeCycleMissing\C9_missing_FC_25.dta", clear
foreach num of numlist 26(1)34 48(1)55 {
	append using "$results_LifeCycleMissing\C9_missing_FC_`num'.dta"
	cap erase "$results_LifeCycleMissing\C9_missing_FC_`num'.dta"
}
export excel using "$results_LifeCycleMissing\C9_missing_FC.xls", firstrow(variables) replace
save "$results_LifeCycleMissing\C9_missing_FC.dta", replace
cap erase "$results_LifeCycleMissing\C9_missing_FC_25.dta"
	