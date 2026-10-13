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



*********************Donut sample***********************************************

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 
drop if inlist(run_week,-1,0,1,2)


/*******************************************************************************
	STEP 1 - merge Risk and LOC data set (prepared by Sebastian)			
*******************************************************************************/

joinby ID_t using "$results\RiskandLocus.dta", unmatched(both) 
drop if _merge == 2 

/*******************************************************************************
	STEP 2 - Gen Age At Testing / Age first participation (code from Sebastian)		
*******************************************************************************/


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


/*******************************************************************************
	STEP 3 - standardize skills within estimation sample(code from Sebastian)	
*******************************************************************************/


foreach var in zRiskAffGeneral7 zRiskAffGeneral8 zRiskAffGeneral10 zRiskAffGeneral12 zRiskAffGeneral13 zRiskAffMoney8 zRiskAffHobbySport8 zRiskAffJob8 zLOCinternal6 zLOCOwnDestiny6 zLOCSucessWithWork6 zLOCexternal6 zLOCDestinyUnfair6 zLOCLifeDestOther6 zLOCinternal13 zLOCOwnDestiny13 zLOCSucessWithWork13 zLOCexternal13 zLOCDestinyUnfair13 zLOCLifeDestOther13 zmRiskAffGeneral zmLOCinternal zmLOCOwnDestiny zmLOCSucessWithWork zmLOCexternal zmLOCDestinyUnfair zmLOCLifeDestOther first_RiskAffGeneral first_LOCinternal first_LOCOwnDestiny first_LOCSucessWithWork first_LOCexternal first_LOCDestinyUnfair first_LOCLifeDestOther {
	center `var' [aw=w_t4_cal], generate(z`var') standardize
	drop `var'
}


cap erase "${results}\ssa_locrisk_new_$date.csv"




/*******************************************************************************
	STEP 4 - produce estimation results	
*******************************************************************************/
foreach var of varlist zzmRiskAffGeneral zzmLOCinternal zzmLOCexternal zzmLOCOwnDestiny zzmLOCSucessWithWork zzmLOCDestinyUnfair zzmLOCLifeDestOther zzRiskAffGeneral7 zzRiskAffGeneral8 zzRiskAffGeneral10 zzRiskAffGeneral12 zzRiskAffGeneral13 zzRiskAffMoney8 zzRiskAffHobbySport8 zzRiskAffJob8 zzLOCinternal6 zzLOCOwnDestiny6 zzLOCSucessWithWork6 zzLOCexternal6 zzLOCDestinyUnfair6 zzLOCLifeDestOther6 zzLOCinternal13 zzLOCOwnDestiny13 zzLOCSucessWithWork13 zzLOCexternal13 zzLOCDestinyUnfair13 zzLOCLifeDestOther13  { 

gen missing_`var' = `var'== .

qui ivreg2 `var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  
estimates store r_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
qui estadd scalar y_mean   

qui ivreg2 missing_`var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  
estimates store m_`var'
qui sum missing_`var' if e(sample)
scalar y_mean=r(mean) 
qui estadd scalar y_mean    
 
}

esttab r_*  using "${results}\ssa_locrisk_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut - main results") nodepvars

esttab m_*  using "${results}\ssa_locrisk_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut - selection into participation") nodepvars



est drop _all
local skill "RiskAffGeneral LOCinternal LOCexternal LOCOwnDestiny LOCSucessWithWork LOCDestinyUnfair LOCLifeDestOther"
foreach x of local skill {
	qui ivreg2 zzm`x' $instr $lin_plain c.first_z`x'_Age##c.first_z`x'_Age [aw=w_t4_cal],  robust partial($lin_plain)  
	estimates store zzm_`x'
	qui sum zzm`x' [aw=w_t4_cal] if e(sample)
	scalar y_mean=r(mean) 
	qui estadd scalar y_mean   
}	

local skill "RiskAffGeneral LOCinternal LOCexternal LOCOwnDestiny LOCSucessWithWork LOCDestinyUnfair LOCLifeDestOther"
foreach x of local skill {
	clonevar zfirst`x' = zfirst_`x'
	qui ivreg2 zfirst`x' $instr $lin_plain c.first_z`x'_Age##c.first_z`x'_Age [aw=w_t4_cal],  robust partial($lin_plain)  
	estimates store zfirstage_`x'
	qui sum zfirst`x' [aw=w_t4_cal] if e(sample)
	scalar y_mean=r(mean) 
	qui estadd scalar y_mean    
}	

esttab zzm*  using "${results}\ssa_locrisk_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut - main results - means with age FE (age at first participation)") nodepvars

esttab zfirstage_*  using "${results}\ssa_locrisk_new_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut - main results - first obs with age FE (age at first participation)") nodepvars