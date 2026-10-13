/*******************************************************************************
This file will produce TWFE - Estimations for C9 on two additional mechanisms: 
	- Locus of Controll
	- Risk Affinity

We use the same standardized procedure than in Cognitive Skills.do (meaning double standardized variables)
We produce cross-sectional variables!

	Author: Sebastian Vogler
	
	Version: 1.0, 	created: 2024 - 08 - 06
*******************************************************************************/ 

*** Globals ****
global results_RiskLOC "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\LOC and Risk Aversion"
global RuralVariable i.RuralNEPSMZ

********************************************************************************
* Step 1: Prepare Data
********************************************************************************
*** Prepare pTarget
use "$data\SC6_pTarget_R_13-0-0.dta", clear

*** Risk-Aversion and Locus of Controll *** 
* Risk Aversion: t515052 t515053 t515054 t515051
recode t515052 (-99/-1 = .), gen(RiskAffMoney)
recode t515053 (-99/-1 = .), gen(RiskAffHobbySport)
recode t515054 (-99/-1 = .), gen(RiskAffJob)
recode t515051 (-99/-1 = .), gen(RiskAffGeneral)

* Locus Of Controll: t67010a t67010a_g1 t67010b t67010b_g1 t67010c t67010d
* Internal Locus of Controll
recode t67010a_g1 (-99/0 = .), gen(LOCinternal)
recode t67010a (-99/0 = .), gen(LOCOwnDestiny)
recode t67010c (-99/0 = .), gen(LOCSucessWithWork)

* External Locus of Controll
recode t67010b_g1 (-99/0 = .), gen(LOCexternal)
recode t67010b (-99/0 = .), gen(LOCDestinyUnfair)
recode t67010d (-99/0 = .), gen(LOCLifeDestOther)

* keep and make beautifull panel
keep ID_t wave LOC* RiskAff*
sort ID_t wave

* clean for later merge
drop if RiskAffGeneral == . & LOCinternal == . & LOCexternal == .

* Reshape Data
reshape wide RiskAffGeneral RiskAffMoney RiskAffHobbySport RiskAffJob LOCinternal LOCOwnDestiny LOCSucessWithWork LOCexternal LOCDestinyUnfair LOCLifeDestOther, i(ID_t) j(wave)

* Clean Risk Affinity
drop RiskAffMoney6 RiskAffMoney7 RiskAffMoney10 RiskAffMoney12 RiskAffMoney13
drop RiskAffHobbySport6 RiskAffHobbySport7 RiskAffHobbySport10 RiskAffHobbySport12 RiskAffHobbySport13
drop RiskAffJob6 RiskAffJob7 RiskAffJob10 RiskAffJob12 RiskAffJob13
drop RiskAffGeneral6

* Clean LOC
drop LOCinternal7 LOCinternal8 LOCinternal10 LOCinternal12
drop LOCSucessWithWork7 LOCSucessWithWork8 LOCSucessWithWork10 LOCSucessWithWork12
drop LOCOwnDestiny7 LOCOwnDestiny8 LOCOwnDestiny10 LOCOwnDestiny12
drop LOCexternal7 LOCexternal8 LOCexternal10 LOCexternal12
drop LOCLifeDestOther7 LOCLifeDestOther8 LOCLifeDestOther10 LOCLifeDestOther12
drop LOCDestinyUnfair7 LOCDestinyUnfair8 LOCDestinyUnfair10 LOCDestinyUnfair12

* Order
order ID_t Risk* LOC*

********************************************************************************
* Step 2: Prepare Wave Specific Z - Scores and THEN take mean from these Z - Scores
********************************************************************************
*** Wave Specific z- Score
foreach var in RiskAffGeneral7 RiskAffGeneral8 RiskAffGeneral10 RiskAffGeneral12 RiskAffGeneral13 RiskAffMoney8 RiskAffHobbySport8 RiskAffJob8 LOCinternal6 LOCOwnDestiny6 LOCSucessWithWork6 LOCexternal6 LOCDestinyUnfair6 LOCLifeDestOther6 LOCinternal13 LOCOwnDestiny13 LOCSucessWithWork13 LOCexternal13 LOCDestinyUnfair13 LOCLifeDestOther13 {
	center `var', generate(z`var') standardize // No Weight So far
	drop `var'
}

*** Mean From all Wave - Specific z-Scores
*** Risk Affinity 
egen zmRiskAffGeneral = rowmean(zRiskAffGeneral7 zRiskAffGeneral8 zRiskAffGeneral10 zRiskAffGeneral12 zRiskAffGeneral13)
egen zmLOCinternal = rowmean(zLOCinternal6 zLOCinternal13)
egen zmLOCOwnDestiny = rowmean(zLOCOwnDestiny6 zLOCOwnDestiny13)
egen zmLOCSucessWithWork = rowmean(zLOCSucessWithWork6 zLOCSucessWithWork13)
egen zmLOCexternal = rowmean(zLOCexternal6 zLOCexternal13)
egen zmLOCDestinyUnfair = rowmean(zLOCDestinyUnfair6 zLOCDestinyUnfair13)
egen zmLOCLifeDestOther = rowmean(zLOCLifeDestOther6 zLOCLifeDestOther13)

*************************
* gen First Observation per Individual
*************************
*** Risk Affinity 
egen first_RiskAffGeneral = rowfirst(  zRiskAffGeneral7 zRiskAffGeneral8 zRiskAffGeneral10 zRiskAffGeneral12 zRiskAffGeneral13)  // 

*** LOC
egen first_LOCinternal = rowfirst( zLOCinternal6 zLOCinternal13 ) // 
egen first_LOCOwnDestiny = rowfirst( zLOCOwnDestiny6 zLOCOwnDestiny13 ) // 
egen first_LOCSucessWithWork = rowfirst( zLOCSucessWithWork6 zLOCSucessWithWork13 ) // 
egen first_LOCexternal = rowfirst( zLOCexternal6 zLOCexternal13 ) // 
egen first_LOCDestinyUnfair = rowfirst( zLOCDestinyUnfair6 zLOCDestinyUnfair13 ) // 
egen first_LOCLifeDestOther = rowfirst( zLOCLifeDestOther6 zLOCLifeDestOther13 ) // 

*************************
*** Gen Wave Fixed Effect
*************************
*** Make Categorical Variables for our Means: When was the First Participation? ***
*** Define Earliest Participation ***
*** Risk Affinity 
gen FirstWave_RiskAffGeneral = 0
replace FirstWave_RiskAffGeneral = 13 if zRiskAffGeneral13 != .
replace FirstWave_RiskAffGeneral = 12 if zRiskAffGeneral12 != .
replace FirstWave_RiskAffGeneral = 10 if zRiskAffGeneral10 != .
replace FirstWave_RiskAffGeneral = 8 if zRiskAffGeneral8 != .
replace FirstWave_RiskAffGeneral = 7 if zRiskAffGeneral7 != .

*** LOC
gen FirstWave_LOCinternal = 0
replace FirstWave_LOCinternal = 13 if zLOCinternal13 != .
replace FirstWave_LOCinternal = 6 if zLOCinternal6 != .

gen FirstWave_LOCSucessWithWork = 0
replace FirstWave_LOCSucessWithWork = 13 if zLOCSucessWithWork13 != .
replace FirstWave_LOCSucessWithWork = 6 if zLOCSucessWithWork6 != .

gen FirstWave_LOCexternal = 0
replace FirstWave_LOCexternal = 13 if zLOCexternal13 != .
replace FirstWave_LOCexternal = 6 if zLOCexternal6 != .

gen FirstWave_LOCDestinyUnfair = 0
replace FirstWave_LOCDestinyUnfair = 13 if zLOCDestinyUnfair13 != .
replace FirstWave_LOCDestinyUnfair = 6 if zLOCDestinyUnfair6 != .

gen FirstWave_LOCLifeDestOther = 0
replace FirstWave_LOCLifeDestOther = 13 if zLOCLifeDestOther13 != .
replace FirstWave_LOCLifeDestOther = 6 if zLOCLifeDestOther6 != .

*** Save for later Merge
save "$results_RiskLOC\RiskAndLocus.dta", replace

********************************************************************************
* Step 4: Merge with CS - Data of C9 and RDD
********************************************************************************
*** C9 *** New: NO Age Restrictions!
use "$results\C9_Combined_Full_Panel_final.dta", clear
keep if inrange(yob, 1945, 1964)

* Make it Cross - Sectional Again
duplicates drop ID_t, force

*** joinby
joinby ID_t using "$results_RiskLOC/RiskAndLocus.dta", unmatched(both) 
tab _merge
gen missing = _merge ==1 // for later regression on Missings
drop if _merge == 2 
count if w_t4_cal != 0 // 5,259 obs.
count if w_t4_cal != 0 & missing != 1 // 4,147 obs.

*************************
*** Gen Age At Testing / Age first participation
*************************
*** Gen Age At Testing
* wave 3: 2010 2011
* wave 5: 2012 2013
* wave 6: 2013 2014
* wave 7: 2014 2015
* wave 8: 2015 2016
* wave 9: 2016 2017
* wave 10: 2017 2018
* wave 12: 2019 2020
* wave 13: 2020 2021

bysort ID_t: gen AgeW3 = 2011 - yob
bysort ID_t: gen AgeW5 = 2013 - yob
bysort ID_t: gen AgeW6 = 2014 - yob
bysort ID_t: gen AgeW7 = 2015 - yob
bysort ID_t: gen AgeW8 = 2016 - yob
bysort ID_t: gen AgeW9 = 2017 - yob
bysort ID_t: gen AgeW10 = 2018 - yob
bysort ID_t: gen AgeW12 = 2020 - yob
bysort ID_t: gen AgeW13 = 2021 - yob

****
*  Age At Testing, If Not Missing
****
*** Risk Affinity zRiskAffGeneral7 zRiskAffGeneral8 zRiskAffGeneral10 zRiskAffGeneral12 zRiskAffGeneral13 zRiskAffMoney8 zRiskAffHobbySport8 zRiskAffJob8
gen Age_zRiskAffGeneral7 = AgeW7 if zRiskAffGeneral7 != .
gen Age_zRiskAffGeneral8 = AgeW8 if zRiskAffGeneral8 != .
gen Age_zRiskAffGeneral10 = AgeW10 if zRiskAffGeneral10 != .
gen Age_zRiskAffGeneral12 = AgeW12 if zRiskAffGeneral12 != .
gen Age_zRiskAffGeneral13 = AgeW13 if zRiskAffGeneral13 != .

gen Age_zRiskAffMoney8 = AgeW8 if zRiskAffMoney8 != .
gen Age_zRiskAffHobbySport8 = AgeW8 if zRiskAffHobbySport8 != .
gen Age_zRiskAffJob8 = AgeW8 if zRiskAffJob8 != .

*** LOC zLOCinternal6 zLOCOwnDestiny6 zLOCSucessWithWork6 zLOCexternal6 zLOCDestinyUnfair6 zLOCLifeDestOther6 zLOCinternal13 zLOCOwnDestiny13 zLOCSucessWithWork13 zLOCexternal13 zLOCDestinyUnfair13 zLOCLifeDestOther13
gen Age_zLOCinternal6 = AgeW6 if zLOCinternal6 != .
gen Age_zLOCinternal13 = AgeW13 if zLOCinternal13 != .
gen Age_zLOCOwnDestiny6 = AgeW6 if zLOCOwnDestiny6 != .
gen Age_zLOCOwnDestiny13 = AgeW13 if zLOCOwnDestiny13 != .
gen Age_zLOCSucessWithWork6 = AgeW6 if zLOCSucessWithWork6 != .
gen Age_zLOCSucessWithWork13 = AgeW13 if zLOCSucessWithWork13 != .
gen Age_zLOCexternal6 = AgeW6 if zLOCexternal6 != .
gen Age_zLOCexternal13 = AgeW13 if zLOCexternal13 != .
gen Age_zLOCDestinyUnfair6 = AgeW6 if zLOCDestinyUnfair6 != .
gen Age_zLOCDestinyUnfair13 = AgeW13 if zLOCDestinyUnfair13 != .
gen Age_zLOCLifeDestOther6 = AgeW6 if zLOCLifeDestOther6 != .
gen Age_zLOCLifeDestOther13 = AgeW13 if zLOCLifeDestOther13 != .

****
*  Age First Participation
****
egen first_zRiskAffGeneral_Age = rowfirst( Age_zRiskAffGeneral7 Age_zRiskAffGeneral8 Age_zRiskAffGeneral10 Age_zRiskAffGeneral12 Age_zRiskAffGeneral13 ) // 
egen first_zLOCinternal_Age = rowfirst( Age_zLOCinternal6 Age_zLOCinternal13 ) // 
egen first_zLOCOwnDestiny_Age = rowfirst(Age_zLOCinternal6 Age_zLOCinternal13 ) // 
egen first_zLOCSucessWithWork_Age = rowfirst( Age_zLOCSucessWithWork6 Age_zLOCSucessWithWork13 ) // 
egen first_zLOCexternal_Age = rowfirst( Age_zLOCexternal6 Age_zLOCexternal13 ) // 
egen first_zLOCDestinyUnfair_Age = rowfirst( Age_zLOCDestinyUnfair6 Age_zLOCDestinyUnfair13 ) // 
egen first_zLOCLifeDestOther_Age = rowfirst( Age_zLOCLifeDestOther6 Age_zLOCLifeDestOther13 ) // 

* Gen Mean Age  // zmRiskAffGeneral zmLOCinternal zmLOCOwnDestiny zmLOCSucessWithWork zmLOCexternal zmLOCDestinyUnfair zmLOCLifeDestOther
egen MeanAgeRiskAffGeneral = rowmean( Age_zRiskAffGeneral7 Age_zRiskAffGeneral8 Age_zRiskAffGeneral10 Age_zRiskAffGeneral12 Age_zRiskAffGeneral13 )
egen MeanAgeLOCinternal = rowmean( Age_zLOCinternal6 Age_zLOCinternal13 )
egen MeanAgeLOCOwnDestiny = rowmean( Age_zLOCOwnDestiny6 Age_zLOCOwnDestiny13 )
egen MeanAgeLOCSucessWithWork = rowmean( Age_zLOCSucessWithWork6 Age_zLOCSucessWithWork13 )
egen MeanAgeLOCexternal = rowmean( Age_zLOCexternal6 Age_zLOCexternal13 )
egen MeanAgeLOCDestinyUnfair = rowmean( Age_zLOCDestinyUnfair6 Age_zLOCDestinyUnfair13 )
egen MeanAgeLOCLifeDestOther = rowmean( Age_zLOCLifeDestOther6 Age_zLOCLifeDestOther13 )

* Squared Values
foreach var in first_RiskAffGeneral first_LOCinternal first_LOCOwnDestiny first_LOCSucessWithWork first_LOCexternal first_LOCDestinyUnfair first_LOCLifeDestOther first_zRiskAffGeneral_Age first_zLOCinternal_Age first_zLOCOwnDestiny_Age first_zLOCSucessWithWork_Age first_zLOCexternal_Age first_zLOCDestinyUnfair_Age first_zLOCLifeDestOther_Age {
	gen `var'_2 = (`var')^2
}

********************************************************************************
* Step 5: One Last z-Standardization within our merged sample
********************************************************************************
* Standardize Variables for better interpretation 
foreach var in zRiskAffGeneral7 zRiskAffGeneral8 zRiskAffGeneral10 zRiskAffGeneral12 zRiskAffGeneral13 zRiskAffMoney8 zRiskAffHobbySport8 zRiskAffJob8 zLOCinternal6 zLOCOwnDestiny6 zLOCSucessWithWork6 zLOCexternal6 zLOCDestinyUnfair6 zLOCLifeDestOther6 zLOCinternal13 zLOCOwnDestiny13 zLOCSucessWithWork13 zLOCexternal13 zLOCDestinyUnfair13 zLOCLifeDestOther13 zmRiskAffGeneral zmLOCinternal zmLOCOwnDestiny zmLOCSucessWithWork zmLOCexternal zmLOCDestinyUnfair zmLOCLifeDestOther first_RiskAffGeneral first_LOCinternal first_LOCOwnDestiny first_LOCSucessWithWork first_LOCexternal first_LOCDestinyUnfair first_LOCLifeDestOther {
	center `var' [aw=w_t4_cal], generate(z`var') standardize
	drop `var'
}

********************************************************************************
* Regressions
********************************************************************************
********************************************************************************
* Means and Single Items
********************************************************************************
foreach var of varlist zzmRiskAffGeneral zzmLOCinternal zzmLOCexternal zzmLOCOwnDestiny zzmLOCSucessWithWork zzmLOCDestinyUnfair zzmLOCLifeDestOther zzRiskAffGeneral7 zzRiskAffGeneral8 zzRiskAffGeneral10 zzRiskAffGeneral12 zzRiskAffGeneral13 zzRiskAffMoney8 zzRiskAffHobbySport8 zzRiskAffJob8 zzLOCinternal6 zzLOCOwnDestiny6 zzLOCSucessWithWork6 zzLOCexternal6 zzLOCDestinyUnfair6 zzLOCLifeDestOther6 zzLOCinternal13 zzLOCOwnDestiny13 zzLOCSucessWithWork13 zzLOCexternal13 zzLOCDestinyUnfair13 zzLOCLifeDestOther13 { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab c0_* using "$results_RiskLOC\C9_RiskAndLOC.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk and LOC on C9 - Without Controlls") nodepvars replace // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear

foreach var of varlist zzmRiskAffGeneral zzmLOCinternal zzmLOCexternal zzmLOCOwnDestiny zzmLOCSucessWithWork zzmLOCDestinyUnfair zzmLOCLifeDestOther zzRiskAffGeneral7 zzRiskAffGeneral8 zzRiskAffGeneral10 zzRiskAffGeneral12 zzRiskAffGeneral13 zzRiskAffMoney8 zzRiskAffHobbySport8 zzRiskAffJob8 zzLOCinternal6 zzLOCOwnDestiny6 zzLOCSucessWithWork6 zzLOCexternal6 zzLOCDestinyUnfair6 zzLOCLifeDestOther6 zzLOCinternal13 zzLOCOwnDestiny13 zzLOCSucessWithWork13 zzLOCexternal13 zzLOCDestinyUnfair13 zzLOCLifeDestOther13 { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $RuralVariable $family_new $Siblings_Kita_New SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c1_* using "$results_RiskLOC\C9_RiskAndLOC.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk and LOC on C9 - Full Controlls") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear


********************************************************************************
* First Observation
********************************************************************************
foreach var of varlist zfirst_RiskAffGeneral { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCinternal { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCexternal { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCOwnDestiny { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCSucessWithWork { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCDestinyUnfair { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCLifeDestOther { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c1_* using "$results_RiskLOC\C9_RiskAndLOC_FirstObs.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk and LOC on C9 - Without Controlls") nodepvars replace // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear

foreach var of varlist zfirst_RiskAffGeneral { 
	*i) No additional Controls
	areg `var' female $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCinternal { 
	*i) No additional Controls
	areg `var' female $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCexternal { 
	*i) No additional Controls
	areg `var' female $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCOwnDestiny { 
	*i) No additional Controls
	areg `var' female $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCSucessWithWork { 
	*i) No additional Controls
	areg `var' female $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}


foreach var of varlist zfirst_LOCDestinyUnfair { 
	*i) No additional Controls
	areg `var' female $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCLifeDestOther { 
	*i) No additional Controls
	areg `var' female $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c2_* using "$results_RiskLOC\C9_RiskAndLOC_FirstObs.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk and LOC on C9 - Full Controlls") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear

foreach var of varlist zfirst_RiskAffGeneral { 
	*i) No additional Controls
	areg `var' female first_zRiskAffGeneral_Age first_zRiskAffGeneral_Age_2 $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCinternal { 
	*i) No additional Controls
	areg `var' female first_zLOCinternal_Age first_zLOCinternal_Age_2 $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCexternal { 
	*i) No additional Controls
	areg `var' female first_zLOCexternal_Age first_zLOCexternal_Age_2 $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCOwnDestiny { 
	*i) No additional Controls
	areg `var' female first_zLOCOwnDestiny_Age first_zLOCOwnDestiny_Age_2 $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCSucessWithWork { 
	*i) No additional Controls
	areg `var' female first_zLOCSucessWithWork_Age first_zLOCSucessWithWork_Age_2 $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCDestinyUnfair { 
	*i) No additional Controls
	areg `var' female first_zLOCDestinyUnfair_Age first_zLOCDestinyUnfair_Age_2 $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_LOCLifeDestOther { 
	*i) No additional Controls
	areg `var' female first_zLOCLifeDestOther_Age first_zLOCLifeDestOther_Age_2 $RuralVariable $family_new $Siblings_Kita_New  C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c3_* using "$results_RiskLOC\C9_RiskAndLOC_FirstObs.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk and LOC on C9 - Full Controlls And Age Controlls ") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear


********************************************************************************
* Regress C9 on Missing of LOC and Risk Aversion
********************************************************************************
*** Create Variable and Check for Systematic Missings
foreach var of varlist zzRiskAffGeneral7 zzRiskAffGeneral8 zzRiskAffGeneral10 zzRiskAffGeneral12 zzRiskAffGeneral13 zzRiskAffMoney8 zzRiskAffHobbySport8 zzRiskAffJob8 zzLOCinternal6 zzLOCOwnDestiny6 zzLOCSucessWithWork6 zzLOCexternal6 zzLOCDestinyUnfair6 zzLOCLifeDestOther6 zzLOCinternal13 zzLOCOwnDestiny13 zzLOCSucessWithWork13 zzLOCexternal13 zzLOCDestinyUnfair13 zzLOCLifeDestOther13 zzmRiskAffGeneral zzmLOCinternal zzmLOCOwnDestiny zzmLOCSucessWithWork zzmLOCexternal zzmLOCDestinyUnfair zzmLOCLifeDestOther { 
	
	capture gen missing_`var' = ( `var' == . )
	
	areg missing_`var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo miss_`var'
	qui sum missing_`var' if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab miss_* using "$results_RiskLOC\C9_RiskAndLOC_Missing.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk and LOC on C9 - Full Controlls And Age Controlls ") nodepvars replace 
esttab miss_* using "$results_RiskLOC\C9_RiskAndLOC_Missing.xlsx", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk and LOC on C9 - Full Controlls And Age Controlls ") nodepvars replace 
eststo clear

foreach var of varlist zzRiskAffGeneral7 zzRiskAffGeneral8 zzRiskAffGeneral10 zzRiskAffGeneral12 zzRiskAffGeneral13 zzRiskAffMoney8 zzRiskAffHobbySport8 zzRiskAffJob8 zzLOCinternal6 zzLOCOwnDestiny6 zzLOCSucessWithWork6 zzLOCexternal6 zzLOCDestinyUnfair6 zzLOCLifeDestOther6 zzLOCinternal13 zzLOCOwnDestiny13 zzLOCSucessWithWork13 zzLOCexternal13 zzLOCDestinyUnfair13 zzLOCLifeDestOther13 zzmRiskAffGeneral zzmLOCinternal zzmLOCOwnDestiny zzmLOCSucessWithWork zzmLOCexternal zzmLOCDestinyUnfair zzmLOCLifeDestOther { 
	
	areg missing_`var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo miss_`var'
	qui sum missing_`var' if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
	drop missing_`var'
}

esttab miss_* using "$results_RiskLOC\C9_RiskAndLOC_Missing.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk and LOC on C9 - Full Controlls And Age Controlls ") nodepvars append 
esttab miss_* using "$results_RiskLOC\C9_RiskAndLOC_Missing.xlsx", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk and LOC on C9 - Full Controlls And Age Controlls ") nodepvars append 
eststo clear
