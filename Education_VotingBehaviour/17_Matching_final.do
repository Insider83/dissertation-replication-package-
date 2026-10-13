
/********************************************************************************
 This File Will Do the Mahalanobis Distance Matching and matching to find optimal pairs of Treatment and Controll Municipalities to conduct a causal (matched) Difference- In- Differences Analyses
 
	Author: Sebastian Vogler
	
	Version: 1.0, Created: 2024-07-04	
*******************************************************************************/
/*******************************************************************************

* Important: All Code and Matching Alogrithms have been taken from the replication package of the paper
* "The place-based effects of police stations on crime: Evidence from station closures" by Sebastian Blesse And André Diegmann

*******************************************************************************/


* Create Directory
capture mkdir "$Matching"

******************************************************************************** ********************************************************************************
* Begin Matching Algorithm:
* Elementary Schools
******************************************************************************** ********************************************************************************
*** Loop for Years ***
forvalues LoopYear = 2005 (1) 2018 { 

***
* Open and Clear Data Set
***
clear all
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
sort AGS2020 Year
destring AGS2020, replace
keep $KeepMahalanobis // Less Disk-Space required

forvalues t = 1 (1) 4 {
		sort AGS2020 Year
			foreach var in $Controls_Default $Controls_ES $Controls_GYM {
				by AGS2020 (Year): gen lag`t'`var' = `var'[_n-`t']
		}
	}


*** Gen Treatment-Dummy: Treatment happened in this year!
bysort AGS2020: gen treat_ES = (Year == minYear_ES) // treat_ES = Dummy, when exactly the year where school closure happened

foreach var in $Mechanism {
	display "`var'"
	drop if `var' == .
}

foreach var in $Controls_Default {
	display "`var'"
	drop if `var' == .
}

foreach var in $Controls_ES $Controls_GYM {
	display "`var'"
	drop if `var' == .
}


********************************************************************************
********************************************************************************
* Compute relative year (distance to treatment)
gen rel_year_help_ES = Year - minYear_ES
replace rel_year_help_ES = . if minYear_ES == 0
tab rel_year_help_ES

* local for years with treatment
sum treat_ES if Year == `LoopYear' & treat_ES == 1
local y`q' = r(N) // Generate local of total units treated in year 2006 

**** New Help to drop multi-Year 
keep if Year == `LoopYear' // We can keep only one year as we already defined pre-treatment via lag above! 
keep if minYear_ES == `LoopYear' | minYear_ES == 0 // Keep Sample of Closure or never treated (controll)! 
drop if treat_ES == 0 & minYear_ES > Year // to ensure we remove future treated

********************************************************************************
********************************************************************************
bysort treat_ES: gen thelp = _n if treat_ES == 1 // thelp = total units (_n = number row) threated 
egen g = group(thelp)
sum g 
loc maxg = r(max) // Use the max treted to define local "max g (maximum treated)"
levels g, local(gr) // every single municipality ever treated // we use this to drop donors from donor pool 
replace g = `maxg' + 1 if g == . // total treated +1 for the loop because 1 will be the first actually treated while max + 1 will be all untreated. We then can do "keep if g == n | g == max +1" to always keep municipality of interest and ALL untreated donors
sum g
loc maxg = r(max) // max g so we can loop through treated units 

********************************************************************************
********************************************************************************
*** merge neighborhood list
sort AGS2020 Year
joinby AGS2020 using "$master\Neigbours\Final_Neighbours_2020.dta", unmatched(master) // This is simply the neighborhood list of every municipality harmonized for terretorial level 2020
drop _merge 

********************************************************************************
********************************************************************************
	
	foreach j of local gr {
		
	preserve
	
	qui: sum g
	loc maxg = r(max)
	keep if g == `j' | g == `maxg'  // this will simply compute the total number of neighborhoods per municipality
	
		forvalues t = 1 (1) 29 { // For all 29 Maximal Neighbourhood in German Municipalities 
	
			gen n`t' = AGS_`t' if treat_ES == 1 // gen n1 = AGS_1 meaning copy variable of first neighbor of treat unit
			egen max_n`t' = max(n`t') // now copy this unit as a complete column
			drop if AGS2020 == max_n`t' // now drop the municipality from the sample that has the same AGS than column n1 - basically the neighbor of the treated unit
			drop n`t' max_n`t' // drop auxiliary variables 
	
	}
	
	
	bysort treat_ES: gen help = _N if treat_ES == 1 // help == mumber of total treated municipalites by year
	egen help2 = max(help) // copy help to a whole column
	
	
	expand 2 if treat_ES == 1 & help == 1 // now this will lead to a panel where I have my treated units two times, important as we then replace the second obs with its partner
	psmatch2 treat_ES, mahal(lag1ShareMaleUnemployed lag2ShareMaleUnemployed lag3ShareMaleUnemployed lag4ShareMaleUnemployed lag1TaxRevenue lag2TaxRevenue lag3TaxRevenue lag4TaxRevenue   ///
	lag1PopulationY6575 lag2PopulationY6575 lag3PopulationY6575 lag4PopulationY6575 lag1NetDeathBirth lag2NetDeathBirth lag3NetDeathBirth lag4NetDeathBirth  ///
	lag1TaxCapacity lag2TaxCapacity lag3TaxCapacity lag4TaxCapacity  ///
	lag1DummyUrban lag2DummyUrban lag3DummyUrban lag4DummyUrban )
	
	gen partner = _id // copies _id, psmatch2 package always makes a new _id 
	replace partner = _n1 if _treated == 1 // so we know which (matched) partner belongs to whom 

	sort partner
	bysort partner: gen vhlp = AGS2020 if _treated == 0 // copy original AGS // missing for my actual treated unit
	bysort partner: egen partner_ags = max(vhlp) // as treated unit has no vhlp, the partner will have the ags (remember that we have bysort partner)
	drop partner
	
	replace _id = (10000 * `LoopYear') + _id  // unique _id defier (important later for controll and treatment cohorts) // it is Year + ID, so its already unique for up to 999 merged!
	replace _n1 = (10000 * `LoopYear') + _n1   // unique _n1 defier (important later for controll and treatment cohorts) // it is Year + ID, so its already unique for up to 999 merged!

	
	bysort treat_ES: drop if help == 1 & _n == 2 // keep only our matched pair!
	recode _weight (2=1) if help2 == 1 & treat_ES == 0

********************************************************************************
********************************************************************************
	drop if _weight != 1 // now we have two-pair with controll-treatment
	
	gen match = .
	replace match = _n1 // replace match with id of actual matched controll- municipality for treated
	replace match = _id if treat_ES ==0 // replace conroll for match with id of actual treated - municipality for controll
	// Now we have a match-variable with 2 times the same value: namely the semi-unique _id from the treated unit thats shared between the
	
	* I skiped stuff: See Matching_Einzeln


********************************************************************************	
********************************************************************************


	keep AGS2020 AGS2020_ Year State minYear_ES minYear_GYM treat_ES _id _n1 match // _id_2 _n1_2
	
	save "$Matching\matched_`LoopYear'_`j'_ES.dta", replace
	
	restore
	}

} // End of Year - Loop 


********************************************************************************
********************************************************************************
*** Brute Force Append via capture ;) I Start with 2005
use "$Matching\matched_2005_1_ES.dta", clear
drop if _n==1 // To ensure we do not use first pair two times
drop if _n==1 // To ensure we do not use first pair two times

forvalues year = 2005(1)2018 {
	forvalues num = 1(1)199 {
		capture append using "$Matching\matched_`year'_`num'_ES" 
		}
	}
		
duplicates report _id // not unique
egen MatchID = group(_id AGS2020) 
duplicates report MatchID // unique!	
label var MatchID "UniqueID MATCHING Identifer"
xtset MatchID Year
		
*** Save Dataset ***
tostring AGS2020, replace
replace AGS2020 = string(real(AGS2020),"%08.0f")
save "$Matching\matched_All_Pairs_ES.dta", replace
		

********************************************************************************
* Next: Erase all smaller pairwise datasets to save space
********************************************************************************
forvalues year = 2005(1)2018 {
	forvalues num = 1(1)199 {
		capture erase "$Matching\matched_`year'_`num'_ES.dta" 
		}
	}
		
********************************************************************************
********************************************************************************
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear

joinby AGS2020 using "$Matching\matched_All_Pairs_ES.dta", unmatched(both)  
* tab _merge
keep if _merge == 3
drop _merge

xtset MatchID Year // Works, we have unique Identifier!
duplicates report MatchID Year // Looks Good!
tab treat_ES // not perfectly 50:50, but simply because I have some missings due to missings controll variables

********************************************************************************
* Finally: Compress final Dataset and Export for analysis
********************************************************************************
compress
save "$master\Daten Schulschließung Marcel\MatchingSampleRegress_ES.dta", replace // From "17_MatchingFinal.do"
		

******************************************************************************** ********************************************************************************
* Begin Matching Algorithm:
* Grammar Schools 
******************************************************************************** ********************************************************************************
*** Loop for Years ***
forvalues LoopYear = 2005 (1) 2018 { 

***
* Open and Clear Data Set
***
clear all
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
sort AGS2020 Year
destring AGS2020, replace
keep $KeepMahalanobis // Less Disk-Space required

****
****
forvalues t = 1 (1) 6 {
		sort AGS2020 Year
			foreach var in $Controls_Default $Controls_ES $Controls_GYM {
				by AGS2020 (Year): gen lag`t'`var' = `var'[_n-`t']
		}
	}


*** Gen Treatment-Dummy: Treatment happened in this year!
bysort AGS2020: gen treat_GYM = (Year == minYear_GYM) // treat_GYM = Dummy, when exactly the year where school closure happened

foreach var in $Mechanism {
	display "`var'"
	drop if `var' == .
}

foreach var in $Controls_Default {
	display "`var'"
	drop if `var' == .
}

foreach var in $Controls_ES $Controls_GYM {
	display "`var'"
	drop if `var' == .
}


********************************************************************************
********************************************************************************
* Compute relative year (distance to treatment)
gen rel_year_help_GYM = Year - minYear_GYM
replace rel_year_help_GYM = . if minYear_GYM == 0
tab rel_year_help_GYM

* local for years with treatment
sum treat_GYM if Year == `LoopYear' & treat_GYM == 1
local y`q' = r(N) // Generate local of total units treated in year 2006 

**** New Help to drop multi-Year 
keep if Year == `LoopYear' // We can keep only one year as we already defined pre-treatment via lag above! 
keep if minYear_GYM == `LoopYear' | minYear_GYM == 0 // Keep Sample of Closure or never treated (controll)! 
drop if treat_GYM == 0 & minYear_GYM > Year // to ensure we remove future treated

********************************************************************************
********************************************************************************
bysort treat_GYM: gen thelp = _n if treat_GYM == 1 // thelp = total units (_n = number row) threated 
egen g = group(thelp)
sum g 
loc maxg = r(max) // Use the max treted to define local "max g (maximum treated)"
levels g, local(gr) // every single municipality ever treated // we use this to drop donors from donor pool 
replace g = `maxg' + 1 if g == . // total treated +1 for the loop because 1 will be the first actually treated while max + 1 will be all untreated. We then can do "keep if g == n | g == max +1" to always keep municipality of interest and ALL untreated donors
sum g
loc maxg = r(max) // max g so we can loop through treated units 

********************************************************************************
********************************************************************************
*** merge neighborhood list
sort AGS2020 Year
joinby AGS2020 using "$master\Neigbours\Final_Neighbours_2020.dta", unmatched(master) // This is simply the neighborhood list of every municipality harmonized for terretorial level 2020
drop _merge 

********************************************************************************
********************************************************************************

	foreach j of local gr {
		
	preserve
	
	qui: sum g
	loc maxg = r(max)
	keep if g == `j' | g == `maxg'  // this will simply compute the total number of neighborhoods per municipality
	
		forvalues t = 1 (1) 29 { // For all 29 Maximal Neighbourhood in German Municipalities 
	
			gen n`t' = AGS_`t' if treat_GYM == 1 // gen n1 = AGS_1 meaning copy variable of first neighbor of treat unit
			egen max_n`t' = max(n`t') // now copy this unit as a complete column
			drop if AGS2020 == max_n`t' // now drop the municipality from the sample that has the same AGS than column n1 - basically the neighbor of the treated unit
			drop n`t' max_n`t' // drop auxiliary variables 
	
	}
	
	
	bysort treat_GYM: gen help = _N if treat_GYM == 1 // help == mumber of total treated municipalites by year
	egen help2 = max(help) // copy help to a whole column
	
	
	expand 2 if treat_GYM == 1 & help == 1 // now this will lead to a panel where I have my treated units two times, important as we then replace the second obs with its partner
	psmatch2 treat_GYM, mahal(lag1ShareMaleUnemployed lag2ShareMaleUnemployed lag3ShareMaleUnemployed lag4ShareMaleUnemployed lag1TaxRevenue lag2TaxRevenue lag3TaxRevenue lag4TaxRevenue   ///
	lag1PopulationY6575 lag2PopulationY6575 lag3PopulationY6575 lag4PopulationY6575 lag1NetDeathBirth lag2NetDeathBirth lag3NetDeathBirth lag4NetDeathBirth ///
	lag1TaxCapacity lag2TaxCapacity lag3TaxCapacity lag4TaxCapacity ///
	lag1DummyUrban lag2DummyUrban lag3DummyUrban lag4DummyUrban )
	
	
	gen partner = _id // copies _id, psmatch2 package always makes a new _id 
	replace partner = _n1 if _treated == 1 // so we know which (matched) partner belongs to whom 

	sort partner
	bysort partner: gen vhlp = AGS2020 if _treated == 0 // copy original AGS // missing for my actual treated unit
	bysort partner: egen partner_ags = max(vhlp) // as treated unit has no vhlp, the partner will have the ags (remember that we have bysort partner)
	drop partner
	
	replace _id = (10000 * `LoopYear') + _id  // unique _id defier (important later for controll and treatment cohorts) // it is Year + ID, so its already unique for up to 999 merged!
	replace _n1 = (10000 * `LoopYear') + _n1   // unique _n1 defier (important later for controll and treatment cohorts) // it is Year + ID, so its already unique for up to 999 merged!

	
	bysort treat_GYM: drop if help == 1 & _n == 2 // keep only our matched pair!
	recode _weight (2=1) if help2 == 1 & treat_GYM == 0

********************************************************************************
********************************************************************************
	drop if _weight != 1 // now we have two-pair with controll-treatment
	
	gen match = .
	replace match = _n1 // replace match with id of actual matched controll- municipality for treated
	replace match = _id if treat_GYM ==0 // replace conroll for match with id of actual treated - municipality for controll
	// Now we have a match-variable with 2 times the same value: namely the semi-unique _id from the treated unit thats shared between the
	
	* I skiped stuff: See Matching_Einzeln


********************************************************************************	
********************************************************************************


	keep AGS2020 AGS2020_ Year State minYear_ES minYear_GYM treat_GYM _id _n1 match // _id_2 _n1_2
	
	save "$Matching\matched_`LoopYear'_`j'_GYM.dta", replace
	
	restore
	}

} // End of Year - Loop 


********************************************************************************
********************************************************************************
*** Brute Force Append via capture ;) I Start with 2005
use "$Matching\matched_2005_1_GYM.dta", clear
drop if _n==1 // To ensure we do not use first pair two times
drop if _n==1 // To ensure we do not use first pair two times

forvalues year = 2005(1)2018 {
	forvalues num = 1(1)199 {
		capture append using "$Matching\matched_`year'_`num'_GYM" 
		}
	}
		
duplicates report _id // not unique
egen MatchID = group(_id AGS2020) 
duplicates report MatchID // unique!	
label var MatchID "UniqueID MATCHING Identifer"
xtset MatchID Year
		
*** Save Dataset ***
tostring AGS2020, replace
replace AGS2020 = string(real(AGS2020),"%08.0f")
save "$Matching\matched_All_Pairs_GYM.dta", replace
		

********************************************************************************
********************************************************************************
forvalues year = 2005(1)2018 {
	forvalues num = 1(1)199 {
		capture erase "$Matching\matched_`year'_`num'_GYM.dta" 
		}
	}
		
********************************************************************************
********************************************************************************
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear

joinby AGS2020 using "$Matching\matched_All_Pairs_GYM.dta", unmatched(both)  
* tab _merge
keep if _merge == 3
drop _merge

xtset MatchID Year // Works, we have unique Identifier!
duplicates report MatchID Year // Looks Good!
tab treat_GYM // not perfectly 50:50, but simply because I have some missings due to missings controll variables

********************************************************************************
********************************************************************************
compress
save "$master\Daten Schulschließung Marcel\MatchingSampleRegress_GYM.dta", replace // From "17_MatchingFinal.do"
