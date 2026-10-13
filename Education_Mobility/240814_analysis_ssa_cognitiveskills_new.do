use "$results\ssa_panel_obs1_new.dta", clear

********************************************************************************
* 	Cognitive skills
********************************************************************************

estimates drop _all


cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6
global lin_early run_week i.after_week#c.run_week i.kann_6
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

global results_Cognitive "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\Cognitive Skills"


*********************Donut sample***********************************************

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 
drop if inlist(run_week,-1,0,1,2)



/*******************************************************************************
	STEP 1 - merge cognitive skills data set (prepared by Sebastian)			
*******************************************************************************/
joinby ID_t using "$results_Cognitive/CognitiveSkills_new.dta", unmatched(master) 

order ID_t - run_week2 zReading3 zReading5 zReading9 zScience5 zMath3 zMath9 zComputer5 zReadSpeed3 zReadSpeed5 zVocabulary7 zSelfVocabulary7 zCogConclude7 zCogAwareness7 zSelfRead3 zSelfRead5 zSelfRead9 zSelfMath3 zSelfMath9 zSelfScience5 zSelfComputer5 zmReading zmMath zmReadSpeed zmSelfRead zmSelfMath


/*******************************************************************************
	STEP 2 - Gen Age At Testing / Age first participation (code from Sebastian)		
*******************************************************************************/


bysort ID_t: gen AgeW3 = 2011 - yob
bysort ID_t: gen AgeW5 = 2013 - yob
bysort ID_t: gen AgeW7 = 2015 - yob
bysort ID_t: gen AgeW9 = 2017 - yob

****
*  Age At Testing, If Not Missing
****
gen zReading3_age = AgeW3 if zReading3 != .
gen zReading5_age = AgeW5 if zReading5 != .
gen zReading9_age = AgeW9 if zReading9 != .
gen zScience5_age = AgeW5 if zScience5 != .
gen zMath3_age = AgeW3 if zMath3 != .
gen zMath9_age = AgeW9 if zMath9 != .
gen zComputer5_age = AgeW5 if zComputer5 != .
gen zReadSpeed3_age = AgeW3 if zReadSpeed3 != .
gen zReadSpeed5_age = AgeW5 if zReadSpeed5 != .
gen zVocabulary7_age = AgeW7 if zVocabulary7 != .
gen zCogConclude7_age = AgeW7 if zCogConclude7 != .
gen zCogAwareness7_age = AgeW7 if zCogAwareness7 != .
gen zSelfRead3_age = AgeW3 if zSelfRead3 != .
gen zSelfRead5_age = AgeW5 if zSelfRead5 != .
gen zSelfRead9_age = AgeW9 if zSelfRead9 != .
gen zSelfMath3_age = AgeW3 if zSelfMath3 != .
gen zSelfMath9_age = AgeW9 if zSelfMath9 != .
gen zSelfScience5_age = AgeW5 if zSelfScience5 != .
gen zSelfComputer5_age = AgeW5 if zSelfComputer5 != .
gen zSelfVocabulary7_age = AgeW7 if zSelfVocabulary7 != .

****
*  Age First Participation
****
egen first_Reading_Age = rowfirst( zReading3_age zReading5_age zReading9_age) // zReading3 zReading5 zReading9
egen first_Science_Age = rowfirst( zScience5_age ) // zScience5
egen first_Math_Age = rowfirst( zMath3_age zMath9_age ) // zMath3 zMath9
egen first_Computer_Age = rowfirst( zComputer5_age ) // zComputer5
egen first_ReadSpeed_Age = rowfirst( zReadSpeed3_age zReadSpeed5_age ) // zReadSpeed3 zReadSpeed5
egen first_Vocabulary_Age = rowfirst( zVocabulary7_age ) // zVocabulary7 zSelfVocabulary7
egen first_CogConclude_Age = rowfirst( zCogConclude7_age ) // zCogConclude7
egen first_CogAwareness_Age = rowfirst( zCogAwareness7_age ) // zCogAwareness7
egen first_SelfRead_Age = rowfirst( zSelfRead3_age zSelfRead5_age zSelfRead9_age ) // zSelfRead3 zSelfRead5 zSelfRead9
egen first_SelfMath_Age = rowfirst( zSelfMath3_age zSelfMath9_age ) // zSelfMath3 zSelfMath9
egen first_SelfScience_Age = rowfirst( zSelfScience5_age ) // zSelfScience5
egen first_SelfComputer_Age = rowfirst( zSelfComputer5_age ) // zSelfComputer5
egen first_SelfVocabulary_Age = rowfirst( zSelfVocabulary7_age ) // zSelfVocabulary7

* Gen Mean Age 
egen MeanAgemReading = rowmean(zReading3_age zReading5_age zReading9_age)
egen MeanAgemMath = rowmean(zMath3_age zMath9_age)
egen MeanAgemReadSpeed = rowmean(zReadSpeed3_age zReadSpeed5_age)
egen MeanAgemSelfRead = rowmean(zSelfRead3_age zSelfRead5_age zSelfRead9_age)
egen MeanAgemSelfMath = rowmean(zSelfMath3_age zSelfMath9_age)

/*******************************************************************************
	STEP 3 - standardize skills within estimation sample(code from Sebastian)	
*******************************************************************************/
foreach var in zReading3 zReading5 zReading9 zScience5 zMath3 zMath9 zComputer5 zReadSpeed3 zReadSpeed5 zVocabulary7 zSelfVocabulary7 zCogConclude7 zCogAwareness7 zSelfRead3 zSelfRead5 zSelfRead9 zSelfMath3 zSelfMath9 zSelfScience5 zSelfComputer5 zmReading zmMath zmReadSpeed zmSelfRead zmSelfMath first_Reading first_Science first_Math first_Computer first_ReadSpeed first_Vocabulary first_CogConclude first_CogAwareness first_SelfRead first_SelfMath first_SelfScience first_SelfComputer {
	center `var' [aw=w_t4_cal], generate(z`var') standardize
	*drop `var'
}


/*******************************************************************************
	STEP 4 - produce estimation results	
*******************************************************************************/
cap erase "${results}\ssa_cognitiveskills_new_$date.csv"


foreach var of varlist zzmReading zzmReadSpeed zzmSelfRead zzmMath zzmSelfMath  zzReading3 zzReading5 zzReading9 zfirst_Reading zzReadSpeed3 zzReadSpeed5 zfirst_ReadSpeed zzSelfRead3 zzSelfRead5 zzSelfRead9 zfirst_SelfRead zzMath3 zzMath9 zfirst_Math zzSelfMath3 zzSelfMath9 zfirst_SelfMath zzScience5 zzSelfScience5 zzComputer5 zzSelfComputer5 zzVocabulary7 zzSelfVocabulary7 zzCogConclude7 zzCogAwareness7  { 

gen missing_`var' = `var'== .

qui ivreg2 `var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  
estimates store r_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
qui estadd scalar y_mean   

qui ivreg2 missing_`var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  
estimates store m_`var'
qui sum missing_`var' if e(sample) // [aw=w_t4_cal]
scalar y_mean=r(mean) 
qui estadd scalar y_mean    
 
}

esttab r_*  using "${results}\ssa_cognitiveskills_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut - main results") nodepvars

esttab m_*  using "${results}\ssa_cognitiveskills_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut - selection into participation") nodepvars

est drop _all
local skill "Reading ReadSpeed SelfRead Math SelfMath"
foreach x of local skill {
	qui ivreg2 zzm`x' $instr $lin_plain c.first_`x'_Age##c.first_`x'_Age [aw=w_t4_cal],  robust partial($lin_plain)  
	estimates store zzmage_`x'
	qui sum zzm`x' [aw=w_t4_cal] if e(sample)
	scalar y_mean=r(mean) 
	qui estadd scalar y_mean   
}	

local skill "_Reading _ReadSpeed _SelfRead _Math _SelfMath"
foreach x of local skill {
	qui ivreg2 zfirst`x' $instr $lin_plain c.first`x'_Age##c.first`x'_Age [aw=w_t4_cal],  robust partial($lin_plain)  
	estimates store zfirstage_`x'
	qui sum zfirst`x' [aw=w_t4_cal] if e(sample)
	scalar y_mean=r(mean) 
	qui estadd scalar y_mean    
}	

esttab zzmage_* zfirstage_*  using "${results}\ssa_cognitiveskills_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut - main results - age FE (age at first participation)") nodepvars

