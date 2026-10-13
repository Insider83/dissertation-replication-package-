/*******************************************************************************
This while will analyse Compliers of C9 on Education

	Author: Sebastian Vogler
	
Compliers are:
Hauptschulabschluss und wegen der Reform mer als 8 Jahre
Dann Non-Complier und Vergleich der Mittelwerte

/*
Variables of Interest:
hs1 = Highest Degree Of Schooling
YOS_Sum = Years of Schooling
*/
	
	Version: 1.0, 	created: 2024 - 03 - 10
*******************************************************************************/ 
************************************************
* define globals
************************************************
global results_Compliance "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Compliance"


global family_new_Complier p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New_Complier D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2
global RuralVariable_Complier RuralNEPSMZ

************************************************
*	New: School-Type Attendance at age 10 and age 14
*	-> New Complier Definition
************************************************
* Year and Month of Birth
use "$data\SC6_Basics_R_13-0-0.dta", clear
keep ID_t t70000m t70000y
rename (t70000m t70000y) (mob yob)
gen bdate =ym(yob, mob)
format *date* %tm
lab var bdate "date of birth"
save "$results_Compliance\yob_mob.dta", replace

* Bibliography with Timing and form of School
use "$data\SC6_Biography_R_13-0-0.dta", clear
tab sptype

*Identifier if school-spells are not consecutively following
bysort ID_t: gen Consec = (sptype[_n] == sptype[_n-1])
bysort ID_t: replace Consec = 1 if _n == 1

*Drop not school-spells
keep if sptype == 22
drop if Consec == 0
drop Consec

* Merge with info on schooling-spells
* relevant dates: ts1111m (Startdate month) ts1111y (startdate year) ts1112m (end month) ts1112y (end year)
joinby ID_t splink using "$data\SC6_spSchool_R_13-0-0.dta"

* Recode periods of schooling
drop if subspell != 0

* Two Different School Type Questionaires:
recode ts11204 (-99/0 = 0) (. = 0) (1 = 1) (3 4 6 = 2) ( 5 = 3 ) ( 7 8 9 = 4) ( 2 9 10 11 12 13 14 = 5 ), gen(School1) 
replace School1 = 2 if ts11225 == 1
recode ts11204_v1 (-99/0 = 0) (. = 0) (1 = 1) (2 = 2) ( 3 = 3 ) ( 6 = 4) ( 4 5 7 8 9 = 5 ), gen(School2) 
replace School2 = 2 if ts11225 == 1

* Combine These Two Above
clonevar School = School1
replace School = 1 if School2 == 1 & School == 0
replace School = 2 if School2 == 2 & School == 0
replace School = 3 if School2 == 3 & School == 0
replace School = 4 if School2 == 4 & School == 0
replace School = 5 if School2 == 5 & School == 0


* define date 
gen start_date = ym(starty, startm)  
gen end_date = ym(endy, endm)
format *date* %tm
lab var start_date "date of starting episode"
lab var end_date "date of ending episode"

* Combine With Yob and Mob
joinby ID_t using "$results_Compliance\yob_mob.dta", unmatched(both)
drop _merge

* gen age at 14 for school at age 14 and/or school at age 10
gen Age_Start = (start_date - bdate)/12
gen Age_End = (end_date - bdate)/12

* Gen School at Age 10 and Age 14
sort ID_t splink

*** Spells are often very imprecise, so lets stay within a certain age range
* Starting Age
gen School_Age10_ = School if inrange(Age_Start, 9, 15)
bysort ID_t: egen School_Age10 = max(School_Age10_)
tab School_Age10, m

*** Replace Missings of School At Age 9 - 15
* With First Info After Elementary School
*recode School-Types
recode ts11204_ha (-99/0 = 0) (. = 0) (1 = 1) (2 3 4 7 8 = 2) ( 5 = 3 ), gen(School_Rise)
bysort ID_t: gen Rise_Sch = ( School_Rise[_n] == 1  & School_Rise[_n+1] > 1 ) // Dummy for first school after elementary school

bysort ID_t: replace School_Age10 = School_Rise[_n+1] if School_Age10 == . & Rise_Sch == 1
bysort ID_t: replace School_Age10 = School_Rise[_n+1] if School_Age10 == 0 & Rise_Sch == 1

*** Keep Relevant Variable for merge
keep ID_t School_Age10
duplicates drop ID_t, force
save "$results_Compliance\Age_Schooling.dta", replace

************************************************
*    load final panel
************************************************
use "$results\C9_Combined_Utilized_Panel_final.dta", clear
sort ID_t age
xtset ID_t age

* Something Weird Here
recode p_gerborn_ha_new (0 = 1) (1 = 0)

************************************************
* Limit Data-Set
************************************************
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)


***********************************************
* Merge With YOS Infos (From 2311207_educ_prep.do)
***********************************************
joinby ID_t using "$results\yos_seb_temp.dta"

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
replace YOS_Harmonized = p005 if yos_outlier_005 == 1
replace YOS_Harmonized = p995 if yos_outlier_995 == 1

label var YOS_NoOutlier "Years of schooling (C9 first stage). P05 and P995 removed."
label var YOS_Harmonized "Years of schooling (C9 first stage). P05 and P995 replaced."


***********************************************
* Merge With School at age 10-14
***********************************************
joinby ID_t using "$results_Compliance\Age_Schooling.dta"

* Replace Variable School_Age10 with highest Educational Outcome as last resort
replace dgr_max = dgr_max + 1 if dgr_max != 0 // We need to change it bc above dgr 2 = HS and here its Realschule

replace School_Age10 = dgr_max if School_Age10 == .
replace School_Age10 = dgr_max if School_Age10 == 0
replace School_Age10 = 2 if School_Age10 == . & hs1 == 1
replace School_Age10 = 2 if School_Age10 == 0 & hs1 == 1
replace School_Age10 = 3 if School_Age10 == . & rs1 == 1
replace School_Age10 = 3 if School_Age10 == 0 & rs1 == 1
replace School_Age10 = 4 if School_Age10 == . & abi == 1
replace School_Age10 = 4 if School_Age10 == 0 & abi == 1

***
* Recode parents
***
recode p_gerborn_ha_new (0 = 1) (1 = 0)

***********************************************
* Beautiful Labels for Export
***********************************************
tab bula, gen(bula_d)

label var female "Women"

label var mob "Month of birth"
label var yob "Year of birth"

label var bula "Federal state of school entry"
label var bula_d1 "State: Schleswig-Holstein"
label var bula_d2 "State: Hamburg"
label var bula_d3 "State: Lower Saxony"
label var bula_d4 "State: Bremen"
label var bula_d5 "State: Northrhine-Westphalia"
label var bula_d6 "State: Hesse"
label var bula_d7 "State: Rhineland Palatinate"
label var bula_d8 "State: Baden-Wuerttemberg"
label var bula_d9 "State: Bavaria"
label var bula_d10 "State: Saarland"

label var p_yos_mean "Parental education (in yrs)"
label var p_yos_mean_m "Parental education: missing"
label var p_gerborn_ha_new "Non-German parents (0/1)"
label var p_gerborn_ha_new_m  "German parents: missing"
label var m_ageb4_T2 "Maternal age at birth (in yrs)"
label var m_ageb4_T2_m "Maternal age at birth: missing"

label var D_OlderSibling_T0 "First Born: Missing"
label var D_OlderSibling_T1 "First Born: No"
label var D_OlderSibling_T2 "First Born: Yes"

label var D_JoinedKita_T0 "Joined Kita: Missing"
label var D_JoinedKita_T1 "Joined Kita: No"
label var D_JoinedKita_T2 "Joined Kita: Yes"

label var RuralNEPSMZ "Born in rural municipality"

label var C9 "Exposed to compulsory schooling reform (0(1))"
label var SSY_ "Exposed to short school years (0(1))"

*** Keep Only positive Weight ***
drop if w_t4_cal == 0

STOP

********************************************************************************
* Four Different Complier:
* i) School at age ]10-14[ was Hauptschule, Affected By C9 and >8.33 Years of Schooling (But not more/ignore Not Affected)
* ii) Individuals who were affected by the reform & achieved only basic schooling degree
* iii) Individuals who were affected by the reform & attended more than 8 years of schooling 
* vi) Some above but remove Individuals not affected by C9 in general
********************************************************************************

*** i) ***
gen Complier1 = 0
replace Complier1 = 1 if School_Age10 == 2 & C9 == 1 & YOS_Harmonized > 8.33

*** ii) ***
gen Complier2 = 0
replace Complier2 = 1 if C9 == 1 & hs1 == 1

*** iii) ***
gen Complier3 = 0
replace Complier3 = 1 if C9 == 1 & YOS_Harmonized > 8.33

* Check Nobs Complier
tab Complier1
tab Complier2
tab Complier3

***********************************************************
* i) School at age ]10-14[ was Hauptschule, Affected By C9 and >8.33 Years of Schooling (But not more/ignore Not Affected)
***********************************************************
***********************************************************
* Produce Excel
***********************************************************
putexcel set "$results_Compliance/C9_Compliance1.xlsx", replace

putexcel A1 = "Complier characteristics", bold
putexcel B3 = "Compliers"
putexcel C3 = "Non-Compliers"
putexcel D3 = "Difference"


order yob mob female bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9 SSY_ RuralNEPSMZ
local i = 4
foreach var of varlist yob - RuralNEPSMZ {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

local i = 4
foreach var of varlist yob mob female bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9 SSY_ RuralNEPSMZ  { 

sum `var' [aweight=w_t4_cal] if Complier1 == 1 
matrix define A_`i' = `r(mean)'
sum `var' [aweight=w_t4_cal] if Complier1 == 0
matrix define B_`i' = `r(mean)'
matrix define C_`i' = A_`i'[1,1] - B_`i'[1,1]

*mat define table_`i' = r(table)
mat define full_`i' = A_`i', B_`i', C_`i'
	
local i = `++i'	
}

foreach num of numlist 4(1)30 {
	capture putexcel B`num' = matrix(full_`num'), nformat(#.###)
}

***********************************************************
* Bi-Variate Regressions 
***********************************************************
est drop _all
foreach var of varlist yob mob female bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9 SSY_ RuralNEPSMZ  {  
	eststo Cp1_`var': reg `var' Complier1 [aweight=w_t4_cal], robust
}

esttab Cp1_* using "$results_Compliance/C9_Bivariate_Compliance1", replace scsv keep(Complier1) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Bi-Variate") nodepvars
	

***********************************************************
* Romano-Wolf stepdown p-values for multiple hypothesis testing
***********************************************************
* help rwolf2
* rwolf2 (method1 depvar1 varlist1 [if] [in] [weight] [, options1]) // We have cross-section, therefore reg with robust is enough, no xtreg or cluster(ID)

#delimit ;	
rwolf2 	(regress yob Complier1 [aweight=w_t4_cal], robust)	
		(regress mob Complier1 [aweight=w_t4_cal], robust)
		(regress female Complier1 [aweight=w_t4_cal], robust)
		(regress bula_d1 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d2 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d3 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d4 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d5 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d6 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d7 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d8 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d9 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d10 Complier1 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean Complier1 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean_m Complier1 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new Complier1 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new_m Complier1 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2 Complier1 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2_m Complier1 [aweight=w_t4_cal], robust)				
		(regress D_OlderSibling_T2 Complier1 [aweight=w_t4_cal], robust)	
		(regress D_OlderSibling_T0 Complier1 [aweight=w_t4_cal], robust)			
		(regress D_JoinedKita_T2  Complier1 [aweight=w_t4_cal], robust)	
		(regress D_JoinedKita_T0  Complier1 [aweight=w_t4_cal], robust)	
		(regress C9 Complier1 [aweight=w_t4_cal], robust)	
		(regress SSY_ Complier1 [aweight=w_t4_cal], robust)	
		(regress RuralNEPSMZ Complier1 [aweight=w_t4_cal], robust), ///
		indepvars(Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1) usevalid reps(1000) seed(256874);	

#delimit cr


***********************************************************
* Finally: How Many Nobs?
***********************************************************
distinct ID_t if Complier1 == 0 // 4094
distinct ID_t if Complier1 == 1 // 1165


***********************************************************
* ii) Individuals who were affected by the reform & achieved only basic schooling degree
***********************************************************
***********************************************************
* Produce Excel
***********************************************************
putexcel set "$results_Compliance/C9_Compliance2.xlsx", replace

putexcel A1 = "Complier characteristics", bold
putexcel B3 = "Compliers"
putexcel C3 = "Non-Compliers"
putexcel D3 = "Difference"


order yob mob female bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9 SSY_ RuralNEPSMZ
local i = 4
foreach var of varlist yob - RuralNEPSMZ {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}


local i = 4
foreach var of varlist yob mob female bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9 SSY_ RuralNEPSMZ  { 

sum `var' [aweight=w_t4_cal] if Complier2 == 1 
matrix define A_`i' = `r(mean)'
sum `var' [aweight=w_t4_cal] if Complier2 == 0
matrix define B_`i' = `r(mean)'
matrix define C_`i' = A_`i'[1,1] - B_`i'[1,1]

*mat define table_`i' = r(table)
mat define full_`i' = A_`i', B_`i', C_`i'
	
local i = `++i'	
}

foreach num of numlist 4(1)30 {
	capture putexcel B`num' = matrix(full_`num'), nformat(#.###)
}

***********************************************************
* Romano-Wolf stepdown p-values for multiple hypothesis testing
***********************************************************

#delimit ;	
rwolf2 	(regress yob Complier2 [aweight=w_t4_cal], robust)	
		(regress mob Complier2 [aweight=w_t4_cal], robust)
		(regress female Complier2 [aweight=w_t4_cal], robust)
		(regress west Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d1 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d2 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d3 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d4 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d5 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d6 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d7 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d8 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d9 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d10 Complier2 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean Complier2 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean_m Complier2 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new Complier2 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new_m Complier2 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2 Complier2 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2_m Complier2 [aweight=w_t4_cal], robust)				
		(regress D_OlderSibling_T2 Complier2 [aweight=w_t4_cal], robust)	
		(regress D_OlderSibling_T0 Complier2 [aweight=w_t4_cal], robust)			
		(regress D_JoinedKita_T2  Complier2 [aweight=w_t4_cal], robust)	
		(regress D_JoinedKita_T0  Complier2 [aweight=w_t4_cal], robust)	
		(regress C9 Complier2 [aweight=w_t4_cal], robust)	
		(regress SSY_ Complier2 [aweight=w_t4_cal], robust)	
		(regress RuralNEPSMZ Complier2 [aweight=w_t4_cal], robust)	, indepvars(Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2) usevalid reps(1000) seed(256874);	

#delimit cr

***********************************************************
* Finally: How Many Nobs?
***********************************************************
distinct ID_t if Complier2 == 0 // 3579
distinct ID_t if Complier2 == 1 // 1681


***********************************************************
* iii) Individuals who were affected by the reform & attended more than 8 years of schooling 
***********************************************************
***********************************************************
* Produce Excel
***********************************************************
putexcel set "$results_Compliance/C9_Compliance3.xlsx", replace

putexcel A1 = "Complier characteristics", bold
putexcel B3 = "Compliers"
putexcel C3 = "Non-Compliers"
putexcel D3 = "Difference"


order yob mob female bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9 SSY_ RuralNEPSMZ
local i = 4
foreach var of varlist yob - RuralNEPSMZ {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}


local i = 4
foreach var of varlist yob mob female bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9 SSY_ RuralNEPSMZ  { 

sum `var' [aweight=w_t4_cal] if Complier3 == 1 
matrix define A_`i' = `r(mean)'
sum `var' [aweight=w_t4_cal] if Complier3 == 0
matrix define B_`i' = `r(mean)'
matrix define C_`i' = A_`i'[1,1] - B_`i'[1,1]

*mat define table_`i' = r(table)
mat define full_`i' = A_`i', B_`i', C_`i'
	
local i = `++i'	
}

foreach num of numlist 4(1)30 {
	capture putexcel B`num' = matrix(full_`num'), nformat(#.###)
}

***********************************************************
* Romano-Wolf stepdown p-values for multiple hypothesis testing
***********************************************************
* help rwolf2
* rwolf2 (method1 depvar1 varlist1 [if] [in] [weight] [, options1]) // We have cross-section, therefore reg with robust is enough, no xtreg or cluster(ID)

#delimit ;	
rwolf2 	(regress yob Complier3 [aweight=w_t4_cal], robust)	
		(regress mob Complier3 [aweight=w_t4_cal], robust)
		(regress female Complier3 [aweight=w_t4_cal], robust)	
		(regress bula_d1 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d2 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d3 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d4 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d5 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d6 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d7 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d8 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d9 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d10 Complier3 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean Complier3 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean_m Complier3 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new Complier3 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new_m Complier3 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2 Complier3 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2_m Complier3 [aweight=w_t4_cal], robust)				
		(regress D_OlderSibling_T2 Complier3 [aweight=w_t4_cal], robust)	
		(regress D_OlderSibling_T0 Complier3 [aweight=w_t4_cal], robust)			
		(regress D_JoinedKita_T2  Complier3 [aweight=w_t4_cal], robust)	
		(regress D_JoinedKita_T0  Complier3 [aweight=w_t4_cal], robust)	
		(regress C9 Complier3 [aweight=w_t4_cal], robust)	
		(regress SSY_ Complier3 [aweight=w_t4_cal], robust)	
		(regress RuralNEPSMZ Complier3 [aweight=w_t4_cal], robust)	, indepvars(Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3) usevalid reps(1000) seed(256874);	

#delimit cr

***********************************************************
* Produce Excel
***********************************************************
putexcel set "$results_Compliance/C9_Compliance.xlsx", replace

putexcel A1 = "Complier characteristics", bold
putexcel B3 = "Compliers"
putexcel C3 = "Non-Compliers"
putexcel D3 = "Difference"


order yob mob female bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9 SSY_ RuralNEPSMZ
local i = 4
foreach var of varlist yob - RuralNEPSMZ {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}


local i = 4
foreach var of varlist yob mob female bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9 SSY_ RuralNEPSMZ  { 

sum `var' [aweight=w_t4_cal] if Complier == 1 
matrix define A_`i' = `r(mean)'
sum `var' [aweight=w_t4_cal] if Complier == 0
matrix define B_`i' = `r(mean)'
matrix define C_`i' = A_`i'[1,1] - B_`i'[1,1]

*mat define table_`i' = r(table)
mat define full_`i' = A_`i', B_`i', C_`i'
	
local i = `++i'	
}

foreach num of numlist 4(1)30 {
	capture putexcel B`num' = matrix(full_`num'), nformat(#.###)
}

***********************************************************
* Romano-Wolf stepdown p-values for multiple hypothesis testing
***********************************************************
* help rwolf2
* rwolf2 (method1 depvar1 varlist1 [if] [in] [weight] [, options1]) // We have cross-section, therefore reg with robust is enough, no xtreg or cluster(ID)

*#delimit ;	
rwolf2 	(regress yob complier [aweight=w_t4_cal], robust)	
		(regress mob complier [aweight=w_t4_cal], robust)
		(regress female complier [aweight=w_t4_cal], robust)	
		(regress bula_d1 complier [aweight=w_t4_cal], robust)		
		(regress bula_d2 complier [aweight=w_t4_cal], robust)		
		(regress bula_d3 complier [aweight=w_t4_cal], robust)		
		(regress bula_d4 complier [aweight=w_t4_cal], robust)		
		(regress bula_d5 complier [aweight=w_t4_cal], robust)		
		(regress bula_d6 complier [aweight=w_t4_cal], robust)		
		(regress bula_d7 complier [aweight=w_t4_cal], robust)		
		(regress bula_d8 complier [aweight=w_t4_cal], robust)		
		(regress bula_d9 complier [aweight=w_t4_cal], robust)		
		(regress bula_d10 complier [aweight=w_t4_cal], robust)		
		(regress p_yos_mean complier [aweight=w_t4_cal], robust)		
		(regress p_yos_mean_m complier [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new complier [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new_m complier [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2 complier [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2_m complier [aweight=w_t4_cal], robust)				
		(regress D_OlderSibling_T2 complier [aweight=w_t4_cal], robust)	
		(regress D_OlderSibling_T0 complier [aweight=w_t4_cal], robust)			
		(regress D_JoinedKita_T2  complier [aweight=w_t4_cal], robust)	
		(regress D_JoinedKita_T0  complier [aweight=w_t4_cal], robust)	
		(regress C9 complier [aweight=w_t4_cal], robust)	
		(regress SSY complier [aweight=w_t4_cal], robust)	
		(regress RuralNEPSMZ complier [aweight=w_t4_cal], robust)	, indepvars(complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier) usevalid reps(1000) seed(256874);	


*** *** ALL Hypothestings *** ***

*** 1 
#delimit ;	
rwolf2 	(regress yob Complier1 [aweight=w_t4_cal], robust)	
		(regress mob Complier1 [aweight=w_t4_cal], robust)
		(regress female Complier1 [aweight=w_t4_cal], robust)
		(regress bula_d1 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d2 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d3 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d4 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d5 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d6 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d7 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d8 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d9 Complier1 [aweight=w_t4_cal], robust)		
		(regress bula_d10 Complier1 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean Complier1 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean_m Complier1 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new Complier1 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new_m Complier1 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2 Complier1 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2_m Complier1 [aweight=w_t4_cal], robust)				
		(regress D_OlderSibling_T2 Complier1 [aweight=w_t4_cal], robust)	
		(regress D_OlderSibling_T0 Complier1 [aweight=w_t4_cal], robust)			
		(regress D_JoinedKita_T2  Complier1 [aweight=w_t4_cal], robust)	
		(regress D_JoinedKita_T0  Complier1 [aweight=w_t4_cal], robust)	
		(regress C9 Complier1 [aweight=w_t4_cal], robust)	
		(regress SSY_ Complier1 [aweight=w_t4_cal], robust)	
		(regress RuralNEPSMZ Complier1 [aweight=w_t4_cal], robust), ///
		indepvars(Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1, Complier1) usevalid reps(1000) seed(256874);	

#delimit cr

*** 2 
#delimit ;	
rwolf2 	(regress yob Complier2 [aweight=w_t4_cal], robust)	
		(regress mob Complier2 [aweight=w_t4_cal], robust)
		(regress female Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d1 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d2 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d3 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d4 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d5 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d6 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d7 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d8 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d9 Complier2 [aweight=w_t4_cal], robust)		
		(regress bula_d10 Complier2 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean Complier2 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean_m Complier2 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new Complier2 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new_m Complier2 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2 Complier2 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2_m Complier2 [aweight=w_t4_cal], robust)				
		(regress D_OlderSibling_T2 Complier2 [aweight=w_t4_cal], robust)	
		(regress D_OlderSibling_T0 Complier2 [aweight=w_t4_cal], robust)			
		(regress D_JoinedKita_T2  Complier2 [aweight=w_t4_cal], robust)	
		(regress D_JoinedKita_T0  Complier2 [aweight=w_t4_cal], robust)	
		(regress C9 Complier2 [aweight=w_t4_cal], robust)	
		(regress SSY_ Complier2 [aweight=w_t4_cal], robust)	
		(regress RuralNEPSMZ Complier2 [aweight=w_t4_cal], robust)	, indepvars(Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2, Complier2) usevalid reps(1000) seed(256874);	
#delimit cr


*** 3
#delimit ;	
rwolf2 	(regress yob Complier3 [aweight=w_t4_cal], robust)	
		(regress mob Complier3 [aweight=w_t4_cal], robust)
		(regress female Complier3 [aweight=w_t4_cal], robust)	
		(regress bula_d1 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d2 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d3 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d4 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d5 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d6 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d7 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d8 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d9 Complier3 [aweight=w_t4_cal], robust)		
		(regress bula_d10 Complier3 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean Complier3 [aweight=w_t4_cal], robust)		
		(regress p_yos_mean_m Complier3 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new Complier3 [aweight=w_t4_cal], robust)
		(regress p_gerborn_ha_new_m Complier3 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2 Complier3 [aweight=w_t4_cal], robust)		
		(regress m_ageb4_T2_m Complier3 [aweight=w_t4_cal], robust)				
		(regress D_OlderSibling_T2 Complier3 [aweight=w_t4_cal], robust)	
		(regress D_OlderSibling_T0 Complier3 [aweight=w_t4_cal], robust)			
		(regress D_JoinedKita_T2  Complier3 [aweight=w_t4_cal], robust)	
		(regress D_JoinedKita_T0  Complier3 [aweight=w_t4_cal], robust)	
		(regress C9 Complier3 [aweight=w_t4_cal], robust)	
		(regress SSY_ Complier3 [aweight=w_t4_cal], robust)	
		(regress RuralNEPSMZ Complier3 [aweight=w_t4_cal], robust)	, indepvars(Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3, Complier3) usevalid reps(1000) seed(256874);	
#delimit cr
