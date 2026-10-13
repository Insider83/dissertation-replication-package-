/*******************************************************************************
This file will recode, prepare and regress cognitive skills to investigate any 
connection between educational reforms and skills

	Author: Sebastian Vogler
	
	Version: 1.0, 	created: 2024 - 03 - 03
	Version: 1.1, 	created: 2024 - 06 - 11
*******************************************************************************/ 

/* Overview of nomenclature and possible variables of interest:
General available cognitive skills:

Domain-General Cognitive Functions (DGCF): Cognitive Basic Skills:												2014/15 [Wave 7]
Reading Competence														2010/11 [Wave 3]	2012/13 [Wave 5]						2016/17 [Wave 9]
Reading Speed															2010/11 [Wave 3]	2012/13 [Wave 5]
Vocabulary: Listening Comprehension																				2014/15 [Wave 7]
Mathematical Competence 												2010/11 [Wave 3]											2016/17 [Wave 9]
Scientific Competence																		2012/13 [Wave 5]
ICT Literacy 																				2012/13 [Wave 5]											(2021/22 [Wave 14])

Important nomenclatures:
NEPS- Competences use Item-Response-Theory, combining several Test via Sum or Maximum Likelihood Estimation into one final Variable. Distinguish between main suffixes:
_sc1 (Weighted Likelihood Estimates)
_sc3 (Sum Score)
_sc6 (Proportion Correct Score)

Therefore, main investigations lie on the following variables:
 [WLE]
Reading: 	rea3_sc1 rea5_sc1 rea9_sc1 
Science: 	sca5_sc1 
Math: 		maa3_sc1 maa9_sc1 
Computer:	ica5_sc1 

[Score]
Reading Speed:	rsa3_sc3 rsa5_sc3 
Vocabulary: 	voa7_sc3 
DGCF:			dga7_sc3b dga7_sc3a 

[Meta-Cognition - Self Assesment: {[No(Self-Guessed Correct Answers) - No (Actual Correct Guessed Answers)] / No (Total Questions)}]
Reading: 	mpa3re_sc6 mpa5re_sc6  mpa9re_sc6
Math: 		mpa3ma_sc6 mpa9ma_sc6 
Science:	mpa5sc_sc6
Computer:	mpa5ic_sc6 
Vocabulary:	mpa7vo_sc6 

Important: Individuals could decide to participate or not, meaning we have less obs. for competencies than for mobility-analysis. 
	-> Sample has been split: Wave 3: 50% of sample got reading, reading speed and and math, the other 50% got reading speed and math OR reading speed and reading [p.22/Data Manual SC 6 Wave 14]
	[SKIPPED] -> We also exclude some individuals age-wise. We restrict our sample to age 25 - 55, while some individuals have been asked at ages beyond 55
	-> Wave 5: Individuals from original sample were tested on science and ICT, while refreshed individuals were tested on reading and reading speed. 
	-> Wave 9: Individuals from original sample were tested on math and reading , while refreshment individuals were tested on reading only
Also: Data is stored as cross-sectional, meaning we have to extract year of obervation, if necessary!
*/

************************************************
* define globals
************************************************
global results_Cognitive "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Cognitive Skills"

global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global Rural RuralNEPSMZ


********************************************************************************
* Step 1: Prepare Original Data- Set, Standardize and Mean there and Later Merge it on RDD and C9 - Samples
********************************************************************************
*** Open Competencies ***
use "$data\SC6_xTargetCompetencies_R_13-0-0.dta", clear

*** Check Variables ***
*** WLE
sum *_sc1
foreach var in rea3_sc1 rea5_sc1 rea9_sc1 sca5_sc1 maa3_sc1 maa9_sc1 ica5_sc1 {
	recode `var' (-56 = .) (-55 = .)
}

*** Score
sum *_sc3*
foreach var in rsa3_sc3 rsa5_sc3 voa7_sc3 dga7_sc3b dga7_sc3a {
	recode `var' (-97 = .) (-91 = .) (-55 = .) (-56 = .)
}

*** Meta-Cognition ( Self - Assesment )
sum mpa3re_sc6 mpa5re_sc6  mpa9re_sc6 mpa3ma_sc6 mpa9ma_sc6 mpa5sc_sc6 mpa5ic_sc6 mpa7vo_sc6
foreach var in mpa3re_sc6 mpa5re_sc6  mpa9re_sc6 mpa3ma_sc6 mpa9ma_sc6 mpa5sc_sc6 mpa5ic_sc6 mpa7vo_sc6 {
	recode `var' (-97 = .) (-95 = .) (-94 = .) (-90 = .) (-56 = .) (-55 = .) (-54 = .)
}

* Rename Variables
rename (rea3_sc1 rea5_sc1 rea9_sc1 sca5_sc1 maa3_sc1 maa9_sc1 ica5_sc1) (Reading3 Reading5 Reading9 Science5 Math3 Math9 Computer5)
rename (rsa3_sc3 rsa5_sc3 voa7_sc3 dga7_sc3b dga7_sc3a) (ReadSpeed3 ReadSpeed5 Vocabulary7 CogConclude7 CogAwareness7)
rename (mpa3re_sc6 mpa5re_sc6  mpa9re_sc6 mpa3ma_sc6 mpa9ma_sc6 mpa5sc_sc6 mpa5ic_sc6 mpa7vo_sc6) (SelfRead3 SelfRead5 SelfRead9 SelfMath3 SelfMath9 SelfScience5 SelfComputer5 SelfVocabulary7)

*** Keep and Further Prepare
keep ID_t Reading3 Reading5 Reading9 Science5 Math3 Math9 Computer5 ReadSpeed3 ReadSpeed5 Vocabulary7 CogConclude7 CogAwareness7 SelfRead3 SelfRead5 SelfRead9 SelfMath3 SelfMath9 SelfScience5 SelfComputer5 SelfVocabulary7 wave_w3 wave_w5 wave_w7 wave_w9 

********************************************************************************
* Step 2: Prepare Wave Specific Z - Scores and THEN take mean from these Z - Scores
********************************************************************************
*** Wave Specific z- Score
foreach var in Reading3 Reading5 Reading9 Science5 Math3 Math9 Computer5 ReadSpeed3 ReadSpeed5 Vocabulary7 SelfVocabulary7 CogConclude7 CogAwareness7 SelfRead3 SelfRead5 SelfRead9 SelfMath3 SelfMath9 SelfScience5 SelfComputer5 {
	center `var', generate(z`var') standardize // No Weight So far
	drop `var'
}

*** Mean From all Wave - Specific z-Scores
egen zmReading = rowmean(zReading3 zReading5 zReading9)
egen zmMath = rowmean(zMath3 zMath9)
egen zmReadSpeed = rowmean(zReadSpeed3 zReadSpeed5)
egen zmSelfRead = rowmean(zSelfRead3 zSelfRead5 zSelfRead9)
egen zmSelfMath = rowmean(zSelfMath3 zSelfMath9)

********************************************************************************
* Step 3: New Label and Export
********************************************************************************
label var zReading3 "WLE No. Corr. Answ. Text Compreh. Standard. Within Wave 3."
label var zReading5 "WLE No. Corr. Answ. Text Compreh. Standard. Within Wave 5."
label var zReading9 "WLE No. Corr. Answ. Text Compreh. Standard. Within Wave 9."
label var zScience5 "WLE No. Corr. Answ. Science Questions. Standard. Within Wave 5."
label var zMath3 "WLE No. Corr. Answ. Science Questions. Standard. Within Wave 3."
label var zMath9 "WLE No. Corr. Answ. Science Questions. Standard. Within Wave 9."
label var zComputer5 "WLE No. Corr. Answ. ICT Questions. Standard. Within Wave 9."
label var zReadSpeed3 "Score Reading Speed. Standard. Within Wave 3."
label var zReadSpeed5 "Score Reading Speed. Standard. Within Wave 9."
label var zVocabulary7 "Score Vocabulary Depth. Standard. Within Wave 3."
label var zSelfVocabulary7 "Self-Assed Share of Corr. Answ. Vocabulary Depth. Stand. With. Wave 7"
label var zCogConclude7 "WLE No. Corr. Answ. Logic Test. Standard. Within Wave 7."
label var zCogAwareness7 "WLE No. Corr. Answ. Awareness Test. Standard. Within Wave 7."
label var zSelfRead3 "Self-Assed Share of Corr. Answ. Text Compreh. Standard. Within Wave 3."
label var zSelfRead5 "Self-Assed Share of Corr. Answ. Text Compreh. Standard. Within Wave 5."
label var zSelfRead9 "Self-Assed Share of Corr. Answ. Text Compreh. Standard. Within Wave 9."
label var zSelfMath3 "Self-Assed Share of Corr. Answ. Math. Standard. Within Wave 3."
label var zSelfMath9 "Self-Assed Share of Corr. Answ. Math. Standard. Within Wave 9."
label var zSelfScience5 "Self-Assed Share of Corr. Answ. Science. Standard. Within Wave 5."
label var zSelfComputer5 "Self-Assed Share of Corr. Answ. ICT. Standard. Within Wave 5."
label var zmReading "Mean of all avail. waves Reading Competence."
label var zmMath "Mean of all avail. waves Math Competence."
label var zmReadSpeed "Mean of all avail. waves Reading Speed Competence."
label var zmSelfRead "Mean of all avail. waves Self-Asses. Reading Competence."
label var zmSelfMath "Mean of all avail. waves Self-Asses. Math Competence."


*************************
* gen First Observation per Individual
*************************
egen first_Reading = rowfirst( zReading3 zReading5 zReading9 ) // 
egen first_Science = rowfirst( zScience5 ) // 
egen first_Math = rowfirst( zMath3 zMath9 ) // 
egen first_Computer = rowfirst( zComputer5 ) // 
egen first_ReadSpeed = rowfirst( zReadSpeed3 zReadSpeed5 ) // 
egen first_Vocabulary = rowfirst( zVocabulary7 ) // 
egen first_CogConclude = rowfirst( zCogConclude7 ) // 
egen first_CogAwareness = rowfirst( zCogAwareness7 ) // 
egen first_SelfRead = rowfirst( zSelfRead3 zSelfRead5 zSelfRead9 ) // 
egen first_SelfMath = rowfirst( zSelfMath3 zSelfMath9 ) // 
egen first_SelfScience = rowfirst( zSelfScience5 ) // 
egen first_SelfComputer = rowfirst( zSelfComputer5 ) // 
egen first_SelfVocabulary = rowfirst( zSelfVocabulary7 )

*************************
*** Gen Wave Fixed Effect
*************************
*** Make Categorical Variables for our Means: When was the First Participation? ***
*** Define Earliest Participation ***
gen FirstWave_Reading = 0
replace FirstWave_Reading = 9 if zReading9 != .
replace FirstWave_Reading = 5 if zReading5 != .
replace FirstWave_Reading = 3 if zReading3 != .

gen FirstWave_Math = 0
replace FirstWave_Math = 9 if zMath9 != .
replace FirstWave_Math = 3 if zMath3 != .

gen FirstWave_ReadingSpeed = 0
replace FirstWave_ReadingSpeed = 5 if zReadSpeed5 != .
replace FirstWave_ReadingSpeed = 3 if zReadSpeed3 != .

gen FirstWave_SelfRead = 0
replace FirstWave_SelfRead = 9 if zSelfRead9 != .
replace FirstWave_SelfRead = 5 if zSelfRead5 != .
replace FirstWave_SelfRead = 3 if zSelfRead3 != .


gen FirstWave_SelfMath = 0
replace FirstWave_SelfMath = 9 if zSelfMath9 != .
replace FirstWave_SelfMath = 3 if zSelfMath3 != .

*** Export
save "$results_Cognitive/CognitiveSkills_new.dta", replace

********************************************************************************
* Step 4: Merge with CS - Data of C9 and RDD
********************************************************************************
*** C9 *** New: NO Age Restrictions!
use "$results\C9_Combined_Full_Panel_final.dta", clear
keep if inrange(yob, 1945, 1964)

* 2025 / 02 / 21
keep if inrange(age, 25, 55)

* Make it Cross - Sectional Again
duplicates drop ID_t, force

*** joinby
joinby ID_t using "$results_Cognitive/CognitiveSkills_new.dta", unmatched(both) 
tab _merge
gen missing = _merge ==1 // for later regression on Missings
drop if _merge == 2 
count if w_t4_cal != 0 // 5,260 obs.
count if w_t4_cal != 0 & missing != 1 // 4,411 obs.

*************************
*** Gen Age At Testing / Age first participation
*************************
*** Gen Age At Testing
* wave 3: 2010 2011
* wave 5: 2012 2013
* wave 7: 2014 2015
* wave 9: 2016 2017

bysort ID_t: gen AgeW3 = 2011 - yob
bysort ID_t: gen AgeW5 = 2013 - yob
bysort ID_t: gen AgeW7 = 2015 - yob
bysort ID_t: gen AgeW9 = 2017 - yob

****
*  Age At Testing, If Not Missing
****
gen Age_Reading3 = AgeW3 if zReading3 != .
gen Age_Reading5 = AgeW5 if zReading5 != .
gen Age_Reading9 = AgeW9 if zReading9 != .
gen Age_Science5 = AgeW5 if zScience5 != .
gen Age_Math3 = AgeW3 if zMath3 != .
gen Age_Math9 = AgeW9 if zMath9 != .
gen Age_Computer5 = AgeW5 if zComputer5 != .
gen Age_ReadSpeed3 = AgeW3 if zReadSpeed3 != .
gen Age_ReadSpeed5 = AgeW5 if zReadSpeed5 != .
gen Age_Vocabulary7 = AgeW7 if zVocabulary7 != .
gen Age_CogConclude7 = AgeW7 if zCogConclude7 != .
gen Age_CogAwareness7 = AgeW7 if zCogAwareness7 != .
gen Age_SelfRead3 = AgeW3 if zSelfRead3 != .
gen Age_SelfRead5 = AgeW5 if zSelfRead5 != .
gen Age_SelfRead9 = AgeW9 if zSelfRead9 != .
gen Age_SelfMath3 = AgeW3 if zSelfMath3 != .
gen Age_SelfMath9 = AgeW9 if zSelfMath9 != .
gen Age_SelfScience5 = AgeW5 if zSelfScience5 != .
gen Age_SelfComputer5 = AgeW5 if zSelfComputer5 != .
gen Age_SelfVocabulary7 = AgeW7 if zSelfVocabulary7 != .

****
*  Age First Participation
****
egen first_Reading_Age = rowfirst( Age_Reading3 Age_Reading5 Age_Reading9 ) // zReading3 zReading5 zReading9
egen first_Science_Age = rowfirst( Age_Science5 ) // zScience5
egen first_Math_Age = rowfirst( Age_Math3 Age_Math9 ) // zMath3 zMath9
egen first_Computer_Age = rowfirst( Age_Computer5 ) // zComputer5
egen first_ReadSpeed_Age = rowfirst( Age_ReadSpeed3 Age_ReadSpeed5 ) // zReadSpeed3 zReadSpeed5
egen first_Vocabulary_Age = rowfirst( Age_Vocabulary7 ) // zVocabulary7 zSelfVocabulary7
egen first_CogConclude_Age = rowfirst( Age_CogConclude7 ) // zCogConclude7
egen first_CogAwareness_Age = rowfirst( Age_CogAwareness7 ) // zCogAwareness7
egen first_SelfRead_Age = rowfirst( Age_SelfRead3 Age_SelfRead5 Age_SelfRead9 ) // zSelfRead3 zSelfRead5 zSelfRead9
egen first_SelfMath_Age = rowfirst( Age_SelfMath3 Age_SelfMath9 ) // zSelfMath3 zSelfMath9
egen first_SelfScience_Age = rowfirst( Age_SelfScience5 ) // zSelfScience5
egen first_SelfComputer_Age = rowfirst( Age_SelfComputer5 ) // zSelfComputer5
egen first_SelfVocabulary_Age = rowfirst( Age_SelfVocabulary7 ) // zSelfVocabulary7

* Gen Mean Age 
egen MeanAgemReading = rowmean(Age_Reading3 Age_Reading5 Age_Reading9)
egen MeanAgemMath = rowmean(Age_Math3 Age_Math9)
egen MeanAgemReadSpeed = rowmean(Age_ReadSpeed3 Age_ReadSpeed5 )
egen MeanAgemSelfRead = rowmean(Age_SelfRead3 Age_SelfRead5 Age_SelfRead9)
egen MeanAgemSelfMath = rowmean(Age_SelfMath3 Age_SelfMath9)

* Squared Values 
foreach var in first_Reading first_Science first_Math first_Computer first_ReadSpeed first_Vocabulary first_CogConclude first_CogAwareness first_SelfRead first_SelfMath first_SelfScience first_SelfComputer first_SelfVocabulary FirstWave_Reading FirstWave_Math FirstWave_ReadingSpeed FirstWave_SelfRead FirstWave_SelfMath first_Reading_Age first_Science_Age first_Math_Age first_Computer_Age first_ReadSpeed_Age first_Vocabulary_Age first_CogConclude_Age first_CogAwareness_Age first_SelfRead_Age first_SelfMath_Age first_SelfScience_Age first_SelfComputer_Age first_SelfVocabulary_Age {
	gen `var'_SQRD = (`var')^2
}

********************************************************************************
* Step 5: One Last z-Standardization within our merged sample
********************************************************************************
* Standardize Variables for better interpretation 
foreach var in zReading3 zReading5 zReading9 zScience5 zMath3 zMath9 zComputer5 zReadSpeed3 zReadSpeed5 zVocabulary7 zSelfVocabulary7 zCogConclude7 zCogAwareness7 zSelfRead3 zSelfRead5 zSelfRead9 zSelfMath3 zSelfMath9 zSelfScience5 zSelfComputer5 zmReading zmMath zmReadSpeed zmSelfRead zmSelfMath first_Reading first_Science first_Math first_Computer first_ReadSpeed first_Vocabulary first_CogConclude first_CogAwareness first_SelfRead first_SelfMath first_SelfScience first_SelfComputer {
	center `var' [aw=w_t4_cal], generate(z`var') standardize
	drop `var'
}

********************************************************************************
* Step 6: Regress C9 on Cognitive Skills
********************************************************************************
foreach var of varlist zzmReading zzmReadSpeed zzmSelfRead zzmMath zzmSelfMath  zzReading3 zzReading5 zzReading9 zzScience5 zzMath3 zzMath9 zzComputer5 zzReadSpeed3 zzReadSpeed5 zzVocabulary7 zzSelfVocabulary7 zzCogConclude7 zzCogAwareness7 zzSelfRead3 zzSelfRead5 zzSelfRead9 zzSelfMath3 zzSelfMath9 zzSelfScience5 zzSelfComputer5 { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab c0_* using "$results_Cognitive\C9_Cognitive.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions CognitiveSkills on C9 - Without Controlls") nodepvars replace // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear

foreach var of varlist zzmReading zzmReadSpeed zzmSelfRead zzmMath zzmSelfMath zzReading3 zzReading5 zzReading9 zzScience5 zzMath3 zzMath9 zzComputer5 zzReadSpeed3 zzReadSpeed5 zzVocabulary7 zzSelfVocabulary7 zzCogConclude7 zzCogAwareness7 zzSelfRead3 zzSelfRead5 zzSelfRead9 zzSelfMath3 zzSelfMath9 zzSelfScience5 zzSelfComputer5 { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c1_* using "$results_Cognitive\C9_Cognitive.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions CognitiveSkills on C9 - Full Controlls") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear

* FirstWave_Reading FirstWave_Math FirstWave_ReadingSpeed FirstWave_SelfRead FirstWave_SelfMath
foreach var of varlist zzmReading { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ i.FirstWave_Reading i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zzmReadSpeed { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.FirstWave_Math i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zzmSelfRead { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.FirstWave_ReadingSpeed i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zzmMath { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.FirstWave_SelfRead i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zzmSelfMath { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.FirstWave_SelfMath i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c2_* using "$results_Cognitive\C9_Cognitive.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions CognitiveSkills on C9 - Include First Wave Effect") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear


********************************************************************************
* Step 7: Regress C9 on Missing of Cognitive Skills
********************************************************************************
*** Create Variable and Check for Systematic Missings
foreach var of varlist zzReading3 zzReading5 zzReading9 zzScience5 zzMath3 zzMath9 zzComputer5 zzReadSpeed3 zzReadSpeed5 zzVocabulary7 zzSelfVocabulary7 zzCogConclude7 zzCogAwareness7 zzSelfRead3 zzSelfRead5 zzSelfRead9 zzSelfMath3 zzSelfMath9 zzSelfScience5 zzSelfComputer5 zzmReading zzmReadSpeed zzmSelfRead zzmMath zzmSelfMath { 
	
	gen missing_`var' = ( `var' == . )
	
	areg missing_`var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo miss_`var'
	qui sum missing_`var' if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab miss_* using "$results_Cognitive\C9_Cognitive_Miss.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Missing CognitiveSkills on C9 - Without Controlls") nodepvars replace 
esttab miss_* using "$results_Cognitive\C9_Cognitive_Miss.xls", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Missing CognitiveSkills on C9 - Without Controlls") nodepvars replace 
eststo clear

foreach var of varlist zzReading3 zzReading5 zzReading9 zzScience5 zzMath3 zzMath9 zzComputer5 zzReadSpeed3 zzReadSpeed5 zzVocabulary7 zzSelfVocabulary7 zzCogConclude7 zzCogAwareness7 zzSelfRead3 zzSelfRead5 zzSelfRead9 zzSelfMath3 zzSelfMath9 zzSelfScience5 zzSelfComputer5 zzmReading zzmReadSpeed zzmSelfRead zzmMath zzmSelfMath { 
	
	areg missing_`var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo miss_`var'
	qui sum missing_`var' if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
	drop missing_`var'
}
esttab miss_* using "$results_Cognitive\C9_Cognitive_Miss.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Missing CognitiveSkills on C9 - Full Controlls") nodepvars append
esttab miss_* using "$results_Cognitive\C9_Cognitive_Miss.xls", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Missing CognitiveSkills on C9 - Full Controlls") nodepvars append  
eststo clear

********************************************************************************
* Step 9: Regress C9 on First Available Cognitiv Skill for each Competency
* Namely: rea3_sc1 sca5_sc1 maa3_sc1 ica5_sc1 rsa3_sc3 voa7_sc3 dga7_sc3 bmpa3 re_sc6 mpa3ma_sc6 mpa5ic_sc6 mpa5sc_sc6 mpa7vo_sc6
********************************************************************************
 
*Regress
foreach var of varlist zfirst_Reading zfirst_Math zfirst_ReadSpeed zfirst_SelfRead zfirst_SelfMath zfirst_Science zfirst_Computer zfirst_Vocabulary zfirst_CogConclude zfirst_CogAwareness zfirst_SelfScience zfirst_SelfComputer { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab c0_* using "$results_Cognitive\C9_Cognitive_FirstObservation.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions CognitiveSkills on C9 - Without Controlls") nodepvars replace // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear

foreach var of varlist zfirst_Reading zfirst_Math zfirst_ReadSpeed zfirst_SelfRead zfirst_SelfMath zfirst_Science zfirst_Computer zfirst_Vocabulary zfirst_CogConclude zfirst_CogAwareness zfirst_SelfScience zfirst_SelfComputer { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab c1_* using "$results_Cognitive\C9_Cognitive_FirstObservation.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions CognitiveSkills on C9 - Full Controlls") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear

*** We have 5 Possible Variables with more than one obervation *** FirstWave_Reading FirstWave_Math FirstWave_ReadingSpeed FirstWave_SelfRead FirstWave_SelfMath
foreach var of varlist zfirst_Reading { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.FirstWave_Reading i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_Math  { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.FirstWave_Math i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_ReadSpeed { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.FirstWave_ReadingSpeed i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_SelfRead { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.FirstWave_SelfRead i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_SelfMath { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.FirstWave_SelfMath i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c2_* using "$results_Cognitive\C9_Cognitive_FirstObservation.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions CognitiveSkills on C9 - Include Wave Effect") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear


********************************************************************************
* Step 10: Additional Controlls (Age at Testing) -> Makes No Sense for C9, as we already control for cohort, meaning it perfectl. Collinear With Age!
********************************************************************************
* Regress
* FirstWave_Reading FirstWave_Math FirstWave_ReadingSpeed FirstWave_SelfRead FirstWave_SelfMath
foreach var of varlist zfirst_Reading { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_Math { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_ReadSpeed { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_SelfRead { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_SelfMath { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c1_* using "$results_Cognitive\C9_Cognitive_FirstObservation_AgeControll.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions First Observation Cognitive Skill on C9 - Full Controlls") nodepvars replace // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear

* FirstWave_Reading FirstWave_Math FirstWave_ReadingSpeed FirstWave_SelfRead FirstWave_SelfMath
foreach var of varlist zfirst_Reading { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ first_Reading_Age first_Reading_Age_SQRD i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_Math { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ first_Math_Age first_Math_Age_SQRD i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_ReadSpeed { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ first_ReadSpeed_Age first_ReadSpeed_Age_SQRD i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_SelfRead { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ first_SelfRead_Age first_SelfRead_Age_SQRD i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_SelfMath { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $Rural SSY_ first_SelfMath_Age first_SelfMath_Age_SQRD i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c2_* using "$results_Cognitive\C9_Cognitive_FirstObservation_AgeControll.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions First Observation Cognitive Skill on C9 - Include Age at First Interview as Controll ") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)") keep(C9 *_Age) 
eststo clear

/*
* FirstWave_Reading FirstWave_Math FirstWave_ReadingSpeed FirstWave_SelfRead FirstWave_SelfMath
foreach var of varlist zfirst_Reading { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ first_Reading_Age i.FirstWave_Reading i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_Math { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ first_Math_Age i.FirstWave_Math i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_ReadSpeed { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ first_ReadSpeed_Age i.FirstWave_ReadingSpeed i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_SelfRead { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ first_SelfRead_Age i.FirstWave_SelfRead  i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

foreach var of varlist zfirst_SelfMath { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ first_SelfMath_Age i.FirstWave_SelfMath i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c3_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c3_* using "$results_Cognitive\C9_Cognitive_FirstObservation_AgeControll.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions First Observation Cognitive Skill on C9 - Include Age at First Interview and First Wave as Controll ") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)") keep(C9 *_Age) 
eststo clear
*/






*Spielwiese and Protocoll
/*

** Excurse: Weird Coefficient Reading5
areg zReading5 C9 [aweight = w_t4_cal], robust absorb(cohort)
areg zReading5 C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
areg zReading5 C9 female i.bula [aweight = w_t4_cal], robust absorb(cohort)
areg zReading5 C9 female SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort) // "relatively robust until C9"
areg zReading5 C9 female $Siblings_Kita_New SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
areg zReading5 C9 female $family_new $Siblings_Kita_New SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort) // Hard Drop when including Family

* Check Family // family: p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
areg zReading5 C9 female $Siblings_Kita_New SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
areg zReading5 C9 female $Siblings_Kita_New p_yos_mean p_yos_mean_m SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort) // p_yos are the culprits!
areg zReading5 C9 female $Siblings_Kita_New p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort) // new hard drop here!
areg zReading5 C9 female $Siblings_Kita_New p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
areg zReading5 C9 female $family_new $Siblings_Kita_New SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort) // Hard Drop when including Family



 Do the Variables make sense?

foreach var in Reading3 Reading5 Reading9 Science5 Math3 Math9 Computer5 ReadSpeed3 ReadSpeed5 Vocabulary3 CogConclude7 CogAwareness7 {
	sum z`var'
}
br ID_t zReading3 zReading5 zReading9 wave_w3 wave_w5 wave_w7 wave_w9 // Reading3 Reading5 Reading9 Science5 Math3 Math9 Computer5 ReadSpeed3 ReadSpeed5 Vocabulary3 CogConclude7 CogAwareness
br ID_t zReading3 zReading5 zReading9 zScience5 zMath3 zMath9 zComputer5 zReadSpeed3 zReadSpeed5 zVocabulary3 zCogConclude7 zCogAwareness7 wave_w3 wave_w5 wave_w7 wave_w9 // 

foreach var in zReading3 zReading5 zReading9 zScience5 zMath3 zMath9 zComputer5 zReadSpeed3 zReadSpeed5 zVocabulary3 SelfVocabulary7 zCogConclude7 zCogAwareness7 SelfRead3 SelfRead5 SelfRead9 SelfMath3 SelfMath9 SelfScience5 SelfComputer5 {
	replace `var' = -99 if `var' == .
}

foreach var in zReading3 zReading5 zReading9 zScience5 zMath3 zMath9 zComputer5 zReadSpeed3 zReadSpeed5 zVocabulary3 SelfVocabulary7 zCogConclude7 zCogAwareness7 SelfRead3 SelfRead5 SelfRead9 SelfMath3 SelfMath9 SelfScience5 SelfComputer5 {
	tab `var' if `var' == -99
}

* Test
bysort ID_t: replace zReading3 = zReading5 if zReading3 == - 99
bysort ID_t: replace zReading3 = zReading9 if zReading3 == - 99

-> We have a lot of missing variables! If we would drop anything, so it is harmonized, than we have no observations left
-> Also: E.g. wave 3 st

/*S* New: Age at Testing - > Collinear With Cohort!
* Wave 3
foreach var of varlist zzReading3 zzMath3 zzReadSpeed3 zzSelfRead3 zzSelfMath3  { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New AgeW3 SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

* Wave 5
foreach var of varlist zzReading5 zzScience5 zzComputer5 zzReadSpeed5 zzSelfRead5 zzSelfScience5 zzSelfComputer5 { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New AgeW5 SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

* Wave 7
foreach var of varlist zzVocabulary7 zzSelfVocabulary7 zzCogConclude7 zzCogAwareness7 { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New AgeW7 SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

* Wave 9
foreach var of varlist zzReading9 zzMath9 zzSelfRead9 zzSelfMath9 { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New AgeW9 SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

* Cognitive Means over all waves - Reading and SelfRead
foreach var of varlist zzmReading zzmSelfRead  { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New MeanAgemReading SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

* Cognitive Means over all waves - Math and SelfMath
foreach var of varlist zzmMath zzmSelfMath { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New MeanAgemMath SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

* Cognitive Means over all waves - Reading Speed
foreach var of varlist zzmReadSpeed { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New MeanAgemReadSpeed SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}


esttab c2_* using "$results_Cognitive\C9_Cognitive.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions CognitiveSkills on C9 - With Age At Testing") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear
*/

/*S* New: Wave Dummy
* Wave 3
foreach var of varlist zzReading3 zzMath3 zzReadSpeed3 zzSelfRead3 zzSelfMath3  { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ DummyWave3 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

* Wave 5
foreach var of varlist zzReading5 zzScience5 zzComputer5 zzReadSpeed5 zzSelfRead5 zzSelfScience5 zzSelfComputer5 { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ DummyWave5 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

* Wave 7
foreach var of varlist zzVocabulary7 zzSelfVocabulary7 zzCogConclude7 zzCogAwareness7 { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ DummyWave7 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

* Wave 9
foreach var of varlist zzReading9 zzMath9 zzSelfRead9 zzSelfMath9 { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New SSY_ DummyWave9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c2_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}

esttab c2_* using "$results_Cognitive\C9_Cognitive.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions CognitiveSkills on C9 - Include Wave Effect") nodepvars append // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")
eststo clear
*/

****
* Skip Age for now because we have perfect Collinearity with cohort-fe 
***

*** Gen Age At Testing
* wave 3: 2010 2011
* wave 5: 2012 2013
* wave 7: 2014 2015
* wave 9: 2016 2017

bysort ID_t: gen AgeW3 = 2011 - yob
bysort ID_t: gen AgeW5 = 2013 - yob
bysort ID_t: gen AgeW7 = 2015 - yob
bysort ID_t: gen AgeW9 = 2017 - yob

****
*  First Age 
****
egen first_Reading_Age = rowfirst( AgeW3 AgeW5 AgeW9 ) // zReading3 zReading5 zReading9
egen first_Science_Age = rowfirst( AgeW5 ) // zScience5
egen first_Math_Age = rowfirst( AgeW3 AgeW9 ) // zMath3 zMath9
egen first_Computer_Age = rowfirst( AgeW5 ) // zComputer5
egen first_ReadSpeed_Age = rowfirst( AgeW3 AgeW5 ) // zReadSpeed3 zReadSpeed5
egen first_Vocabulary_Age = rowfirst( AgeW7 ) // zVocabulary7 zSelfVocabulary7
egen first_CogConclude_Age = rowfirst( AgeW7 ) // zCogConclude7
egen first_CogAwareness_Age = rowfirst( AgeW7 ) // zCogAwareness7
egen first_SelfRead_Age = rowfirst( AgeW3 AgeW5 AgeW9 ) // zSelfRead3 zSelfRead5 zSelfRead9
egen first_SelfMath_Age = rowfirst( AgeW3 AgeW9 ) // zSelfMath3 zSelfMath9
egen first_SelfScience_Age = rowfirst( AgeW5 ) // zSelfScience5
egen first_SelfComputer_Age = rowfirst( AgeW5 ) // zSelfComputer5

* Clean Age if no Info/Participation in wave n 
bysort ID_t: replace AgeW3 = . if zReading3 == . & zMath3 == . & zReadSpeed3 == . & zSelfRead3 == . & zSelfMath3 == .
bysort ID_t: replace AgeW5 = . if zReading5 == . & zScience5 == . & zComputer5 == . & zReadSpeed5 == . & zSelfRead5 == . & zSelfScience5 == . & zSelfComputer5 == .
bysort ID_t: replace AgeW7 = . if zVocabulary7 == . & zSelfVocabulary7 == . & zCogConclude7 == . & zCogAwareness7 == . 
bysort ID_t: replace AgeW9 = . if zReading9 == . & zMath9 == . & zSelfRead9 == . & zSelfMath9 == . 

* Gen Mean Age 
egen MeanAgemReading = rowmean(AgeW3 AgeW5 AgeW9)
egen MeanAgemMath = rowmean(AgeW3 AgeW9)
egen MeanAgemReadSpeed = rowmean(AgeW3 AgeW5)
egen MeanAgemSelfRead = rowmean(AgeW3 AgeW5 AgeW9)
egen MeanAgemSelfMath = rowmean(AgeW3 AgeW9)

*/
