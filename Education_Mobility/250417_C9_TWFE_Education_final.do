/**************************************************
This file will do the TWFE of the C9 (Compulsory School Reform) on Educational Outcomes
TWFE of Education on C9 (Infos on Education taken from "230905_educ_prep.do)
	
	*Important: For TWFE, we distinguish between only one cohorts and one sample:
	i)1945-64
	ii) Age 25-55
	iii) West - Germany
	
			
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2023-09-08
***************************************************/
************************************************
* define globals
************************************************
global results_EducationalOutcomes "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Educational Outcomes"

global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ

************************************************
*    load final panel
************************************************
*use "$results_Des\Balancing_C9_CrossSectional.dta", clear  
use "$results\C9_Combined_Utilized_CS_final.dta", clear
sort ID_t age
xtset ID_t age

************************************************
* Limit Data-Set
************************************************
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)
*replace YOS_Sum = 10.02648 if YOS_Sum == . // Here we lose one observation!
drop if YOS_Sum == .

*Recode abi_sectrack
replace abi_sectrack = . if abi_sectrack == -99
* replace yoe_yrs = 8 if yoe_yrs < 8
replace yoe = 8 if yoe < 8

***********************************************
* Produce new Variable more than 8 Years of Schooling
* With all 3 Main YOS Variables of Interest
***********************************************
clonevar YOS_Sum_r = YOS_Sum
replace YOS_Sum_r = round(YOS_Sum_r,0.1)
gen MoreThan8 = (YOS_Sum_r > 8) 

************************************************
* Create Info on School Starting Age
************************************************
merge m:1 ID_t using "$results\schoolentry.dta", keepusing(sbula_1 start_p start_sp1) // .dta from Anton
keep if _merge == 3
drop _merge
gen bdate_SSA = mdy(mob,14,yob)
format %tdD_m_CY start_p bdate_SSA
gen aase = round(((start_sp1 - bdate_SSA)/365),.01)
label var aase "age at school entry"

drop YOS_Sum_r // YOS_Harmonized_r YOS_NoOutlier_r

************************************************
* Cross Section
************************************************
/************************************************
* TWFE on Educational Outcomes
 abi_sectrack Tracking to Gymnasium (Anton) Achtung: Kategorial!
 acadt Tracking to Gymnasium (Kamila)
 sch_ausland 
 start_foreign 
 dgr_max Höchster Abschluss (nicht benötigt, haben Dummies)
 abi Abitur/Gymnasium 
 rs1 Realschule
 hs1 Hauptschule + Kein Abschluss
 uni Uni-Abschluss 
 yoe Years of Education (Aus Casmin)
 Berufsschulabschluss
************************************************/
foreach var of varlist hs1 rs1 abi yos_max uni profes { // rs_abi
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab pooled_c0_* using "$results_EducationalOutcomes\Educ_TWFE_Full.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Education on C9 - Without Controlls") nodepvars mtitle("Basic degree" "Middle degree" "High school" "More than basic degree" "Years of schooling (grades)" "University degree" "Job Qualification") replace
eststo clear

foreach var of varlist hs1 rs1 abi yos_max uni profes { // rs_abi
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab pooled_c1_* using "$results_EducationalOutcomes\Educ_TWFE_Full.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Education on C9 - Full Controlls") nodepvars mtitle("Basic degree" "Middle degree" "High school" "More than basic degree" "Years of schooling (grades)" "University degree" "Job Qualification") append
eststo clear
	
***
* Compliance (Duration of School, More than 8 Years of School, Years of Education in Grades, SSA)
***
foreach var of varlist YOS_Sum MoreThan8 yoe_grade yoe aase {  // YOS_Harmonized YOS_NoOutlier MoreThan8_Harm MoreThan8_NoOutl
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab pooled_c0_* using "$results_EducationalOutcomes\Compliance_Educ_TWFE.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Education on C9 - Without Controlls") nodepvars mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)") replace
eststo clear

foreach var of varlist YOS_Sum MoreThan8 yoe_grade yoe aase { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab pooled_c1_* using "$results_EducationalOutcomes\Compliance_Educ_TWFE.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Education on C9 - Full Controlls") nodepvars mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)") append
eststo clear

***
* Additional Descriptives
***

* Percentage Middle, Upper, Gym according to yob
* Total Sample (1944 - 1986, East, West, Only BORN in Germany)
************************************************
*    load panel: Taken from Master - Panel
************************************************
use "$results\0_basicpanel_final.dta", clear
sort ID_t date
xtset ID_t date

*Only Born in Germany:
tab bl_birth
keep if inrange(bl_birth, 1, 16) //drops Unkown and Foreign

*Duplicates drop (faster)
duplicates drop ID_t, force

*Merge with infos on school
joinby ID_t using "$results\educ_final.dta"

*Clear faulty school entries
foreach var of varlist abi rs1 hs1 {
	sum `var'
} // Looks good!


* PERCENTAGE
preserve

*collapse (sum) abi rs1 hs1 [aw=w_t4_cal], by(yob) //
collapse (sum) SumAbi = abi SumReal = rs1  SumHaupt = hs1 (mean) MeanAbi = abi MeanReal = rs1 MeanHaupt = hs1 [aw=w_t4_cal], by(yob) 
save "$results\Percentage_Schooltype_C9_FullSample_Weighted.dta", replace

restore
