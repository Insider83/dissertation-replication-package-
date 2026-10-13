/**************************************************
This Do-File will produce the overall TWFE regressions for the first draft of the school closure paper

-> This File will do the robustness tests
-> This inlcudes baseline as reference point
-> We take the uncontrolled versions as baseline!
-> This file will do the last Closure

Robustness-Checks in this Do-File:
0) Baseline
i) Only East- or West-Germany
ii) Only Municipalities with selected Population
iii) Weight by Population
iv) Randomized Treatment Groups
v) Remove Neighboured Municipalities
vi) Matched DiD/TWFE
vii) Alternative Voting Definition: Remove DIE LINKE from EAST-Germany LEFT, NO AFD in RIGHT
viii) Actively disentangle elementary and grammar school closures (might be entangeled)
ix) Intensity instead of binary Treatment-Dummy

	
	* For a better overview, we use uncontrolled TWFE-Results
	* We will include this in one graph!
	
	Author: Sebastian Vogler
	
	Version: 1.0, Created: 2026-07-01
***************************************************/
clear all

*** Make dir ***
capture mkdir "$RobustnessMechanisms" 

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***  
*** *** *** Elementary Schools *** *** ***
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 

* Use Final Data-Set
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
sort AGS2020 Year

*Set Panel
destring AGS2020, replace
xtset AGS2020 Year

* Generate a unique identifier for the first occurrence of each unit
bysort AGS2020: gen unique_id = _n == 1
count if unique_id
local num_distinct_units = r(N)
drop unique_id

* Gen East - West - Dummies (Exclude Berlin)
gen East = (State > 10)
gen West = (State < 10)

* Gen Max Population
bysort AGS2020: egen MaxPopulation = max(Population)


*******************
*** 0) Baseline ***
*******************
foreach var in $Mechanism {	

preserve
reghdfe `var' DummyOnlyClosure_ES, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_ES"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Baseline"
save "$RobustnessMechanisms\L_ES_Robust0_`var'.dta", replace
restore
}
   
*************************************
*** i) Only East- or West-Germany ***
*************************************
* East 
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_ES if East == 1, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_ES"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Only East-Germany"
save "$RobustnessMechanisms\L_ES_Robust11_`var'.dta", replace
restore
}
* West
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_ES if East == 0, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_ES"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Only West-Germany"
save "$RobustnessMechanisms\L_ES_Robust12_`var'.dta", replace
restore
}

********************************************************
*** ii) Keep Only Municipalities $\leq$ n Population ***
********************************************************
* ii.1) Keep Only Municipalities $\leq$ 50.000 Population MaxPopulation <= 50000
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_ES if MaxPopulation <= 50000, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_ES"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Population <= 50000"
save "$RobustnessMechanisms\L_ES_Robust21_`var'.dta", replace
restore
}

* ii.2) Keep Only Municipalities $\leq$ 10.000 Population
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_ES if MaxPopulation <= 10000, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_ES"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Population <= 10000"
save "$RobustnessMechanisms\L_ES_Robust22_`var'.dta", replace
restore
}


*********************************
*** iii) Weight by Population ***
*********************************
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_ES [aweight=Population], absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_ES"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Weight By Population"
save "$RobustnessMechanisms\L_ES_Robust3_`var'.dta", replace
restore
}

***************************************
*** iv) Randomized Treatment Groups ***
*** Same as First Closure 20_Robustness_Checks_Voting.do"
***************************************
foreach var in $Mechanism {	
	
preserve
bysort AGS2020: gen RandomYearClosureES__ = 2000 + floor((2019-2000)*runiform())
bysort AGS2020: gen Dummy = 1 if _n == 1
clonevar RandomYearClosureES_ = RandomYearClosureES__ if Dummy == 1
bysort AGS2020: egen RandomYearClosureES = max(RandomYearClosureES_)
bysort AGS2020: gen RandomDummyClosureES = (Year >= RandomYearClosureES)
bysort AGS2020: replace RandomDummyClosureES = 0 if RandomYearClosureES == 2000


reghdfe `var' RandomDummyClosureES, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "RandomDummyClosureES"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Randomized Treatment"
save "$RobustnessMechanisms\L_ES_Robust4_`var'.dta", replace

restore
}

********************************************
*** v) Remove Neighboured Municipalities ***
********************************************
* overall idea: Check Neighbours. If Neighbour to treated municipality, remove controll group to ensure no spill-over; Partly Taken from "Blesse and Diegman (2020)"

* Merge With Dataset(s) on Neighboured Municipalities
sort AGS2020 Year
joinby AGS2020 using "$master\Neigbours\Final_Neighbours_2020.dta", unmatched(master) // This is simply the neighborhood list of every municipality harmonized for terretorial level 2020
drop _merge 

*** *** Begin: Generate Dataset with only the Closure Of the municipality *** *** 
preserve

* Create Data-Set: Neighboured Municipality Experienced School Closure
keep AGS2020 minYear_ES minYear_GYM Year_OnlyClosure_ES Year_OnlyClosure_GYM

forvalues num = 1(1)29 {
	
	clonevar AGS_`num' = AGS2020
	clonevar MYES_`num' = minYear_ES if minYear_ES != 0
	clonevar MYGYM_`num' = minYear_GYM if minYear_GYM != 0
	clonevar YOES_`num' = Year_OnlyClosure_ES if Year_OnlyClosure_ES != 0
	clonevar YOGYM_`num' = Year_OnlyClosure_GYM if Year_OnlyClosure_GYM != 0
	
}

duplicates drop AGS2020, force 
compress
* Save Dataset 
save "$master\Neigbours\Neighbours_Closure_2020.dta", replace // Now I have a dataset with each closure-timing of the neighboured municipality
restore
*** *** End: Generate Dataset with only the Closure Of the municipality *** *** 


*** Joinby List  From Newly Created Nataset 
joinby AGS_1 using "$master\Neigbours\Neighbours_Closure_2020.dta", unmatched(master)
drop _merge
forvalues num = 29(-1) 1 {
order AGS2020 AGS2020_ Year Unit2020 AGS_`num' GEN_`num' BEZ_`num' MYES_`num' MYGYM_`num' YOES_`num' YOGYM_`num'
}

* Now: Remove If I am Treated, but my Neighbour is not! -> Leaves us with Dataset with Only Treated Units and Untreated Without Direct Neighbourhood
egen NeighbourTreat_ES = rowmin(YOES_*)
drop if Year_OnlyClosure_ES == 0 & Year >= NeighbourTreat_ES & NeighbourTreat_ES != .

* Now: Actual TWFE With Updated Dataset 
foreach var in $Mechanism {	
	
preserve

reghdfe `var' DummyOnlyClosure_ES, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_ES"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Excl. Treated Neighb."
save "$RobustnessMechanisms\L_ES_Robust5_`var'.dta", replace

restore
}

****************************
*** vi) Matched DiD/TWFE ***
****************************
* Matching Algorithm itself taken from Blesse And Diegmann (2020), See "17_Matching.do" 

* Load Data-Set
use "$master\Daten Schulschließung Marcel\MatchingSampleRegress_ES.dta", clear

*** *** Xtset (Attention: Because of matching with replacement, we can have certain municipalities as controll multiple times, therefore, xt set is not AGSxYear but MatchIDxYear) *** ***
xtset MatchID Year

* Due to matching 4 Years before Closure - Drop everything before Year 2005
drop if Year < 2005

foreach var in $Mechanism {	
	
preserve
eventstudyinteract `var' lead_OC_ES* lag_OC_ES*, vce(cluster MatchID) absorb(MatchID Year) cohort(Year_OnlyClosure_ES) control_cohort(NeverTreated_ES)
matrix sa_b = e(b_iw) 
matrix sa_v = e(V_iw)
ereturn post sa_b sa_v
lincomest  (lag_OC_ES0 + lag_OC_ES1 + lag_OC_ES2 + lag_OC_ES3 +  lag_OC_ES4 + lag_OC_ES5 + lag_OC_ES6 + lag_OC_ES7 )/8
parmest, norestore
keep if parm == "(1)"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Matched DiD"
save "$RobustnessMechanisms\L_ES_Robust6_`var'.dta", replace
restore
}

***********************************************************************************************
*** viii) Actively disentangle elementary and grammar school closures (might be entangeled) ***
***********************************************************************************************
*** Use Final Data-Set
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
sort AGS2020 Year

* Set Panel
destring AGS2020, replace
xtset AGS2020 Year

* Generate a unique identifier for the first occurrence of each unit
bysort AGS2020: gen unique_id = _n == 1
count if unique_id
local num_distinct_units = r(N)
drop unique_id

* Gen East - West - Dummies (Exclude Berlin)
gen East = (State > 10)
gen West = (State < 10)

* Include only Dummies where we have only Elementary or Grammar, not both simultaneously !
bysort AGS2020: gen DummyBothClosures = ((Year_OnlyClosure_ES == Year_OnlyClosure_GYM) & Year_OnlyClosure_ES != 0 & Year_OnlyClosure_GYM != 0 )

foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_ES if DummyBothClosures != 1, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_ES"
gen Variable = "`var'"
gen School = "Elementary"
gen Robust = "Excl. Simult. Closure"
save "$RobustnessMechanisms\L_ES_Robust7_`var'.dta", replace
restore

}

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
*** *** *** Grammar Schools *** *** ***
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 

* Use Final Data-Set
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
sort AGS2020 Year

*Set Panel
destring AGS2020, replace
xtset AGS2020 Year

* Generate a unique identifier for the first occurrence of each unit
bysort AGS2020: gen unique_id = _n == 1
count if unique_id
local num_distinct_units = r(N)
drop unique_id

* Gen East - West - Dummies (Exclude Berlin)
gen East = (State > 10)
gen West = (State < 10)

* Gen Max Population
bysort AGS2020: egen MaxPopulation = max(Population)


*******************
*** 0) Baseline ***
*******************
foreach var in $Mechanism {	

preserve
reghdfe `var' DummyOnlyClosure_GYM, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_GYM"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Baseline"
save "$RobustnessMechanisms\L_GYM_Robust0_`var'.dta", replace
restore
}

*************************************
*** i) Only East- or West-Germany ***
*************************************
* East 
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_GYM if East == 1, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_GYM"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Only East-Germany"
save "$RobustnessMechanisms\L_GYM_Robust11_`var'.dta", replace
restore
}
* West
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_GYM if East == 0, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_GYM"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Only West-Germany"
save "$RobustnessMechanisms\L_GYM_Robust12_`var'.dta", replace
restore
}

********************************************************
*** ii) Keep Only Municipalities $\leq$ n Population ***
********************************************************
* ii.1) Keep Only Municipalities $\leq$ 50.000 Population MaxPopulation <= 50000
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_GYM if MaxPopulation <= 50000, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_GYM"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Population <= 50000"
save "$RobustnessMechanisms\L_GYM_Robust21_`var'.dta", replace
restore
}

* ii.2) Keep Only Municipalities $\leq$ 10.000 Population
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_GYM if MaxPopulation <= 10000, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_GYM"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Population <= 10000"
save "$RobustnessMechanisms\L_GYM_Robust22_`var'.dta", replace
restore
}

*********************************
*** iii) Weight by Population ***
*********************************
foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_GYM [aweight=Population], absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_GYM"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Weight By Population"
save "$RobustnessMechanisms\L_GYM_Robust3_`var'.dta", replace
restore
}

***************************************
*** iv) Randomized Treatment Groups ***
***************************************
foreach var in $Mechanism {	
	
preserve
bysort AGS2020: gen RandomYearClosureGYM__ = 2000 + floor((2019-2000)*runiform())
bysort AGS2020: gen Dummy = 1 if _n == 1
clonevar RandomYearClosureGYM_ = RandomYearClosureGYM__ if Dummy == 1
bysort AGS2020: egen RandomYearClosureGYM = max(RandomYearClosureGYM_)
bysort AGS2020: gen RandomDummyClosureGYM = (Year >= RandomYearClosureGYM)
bysort AGS2020: replace RandomDummyClosureGYM = 0 if RandomYearClosureGYM == 2000


reghdfe `var' RandomDummyClosureGYM, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "RandomDummyClosureGYM"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Random. Treatment"
save "$RobustnessMechanisms\L_GYM_Robust4_`var'.dta", replace

restore
}

********************************************
*** v) Remove Neighboured Municipalities ***
********************************************
* overall idea: Check Neighbours. If Neighbour to treated municipality, remove controll group to ensure no spill-over; Partly Taken from "Blesse and Diegman (2020)"

* Merge With Dataset(s) on Neighboured Municipalities
sort AGS2020 Year
joinby AGS2020 using "$master\Neigbours\Final_Neighbours_2020.dta", unmatched(master) // This is simply the neighborhood list of every municipality harmonized for terretorial level 2020
drop _merge 

*** *** Begin: Generate Dataset with only the Closure Of the municipality *** *** 
preserve

* Create Data-Set: Neighboured Municipality Experienced School Closure
keep AGS2020 minYear_ES minYear_GYM Year_OnlyClosure_ES Year_OnlyClosure_GYM

forvalues num = 1(1)29 {
	
	clonevar AGS_`num' = AGS2020
	clonevar MYES_`num' = minYear_ES if minYear_ES != 0
	clonevar MYGYM_`num' = minYear_GYM if minYear_GYM != 0
	clonevar YOES_`num' = Year_OnlyClosure_ES if Year_OnlyClosure_ES != 0
	clonevar YOGYM_`num' = Year_OnlyClosure_GYM if Year_OnlyClosure_GYM != 0
	
}

duplicates drop AGS2020, force 
compress
* Save Dataset 
save "$master\Neigbours\Neighbours_Closure_2020.dta", replace // Now I have a dataset with each closure-timing of the neighboured municipality
restore
*** *** End: Generate Dataset with only the Closure Of the municipality *** *** 


*** Joinby List  From Newly Created Nataset 
joinby AGS_1 using "$master\Neigbours\Neighbours_Closure_2020.dta", unmatched(master)
drop _merge
forvalues num = 29(-1) 1 {
order AGS2020 AGS2020_ Year Unit2020 AGS_`num' GEN_`num' BEZ_`num' MYES_`num' MYGYM_`num' YOES_`num' YOGYM_`num'
}

* Now: Remove If I am Treated, but my Neighbour is not! -> Leaves us with Dataset with Only Treated Units and Untreated Without Direct Neighbourhood
egen NeighbourTreat_GYM = rowmin(YOGYM_*)
drop if Year_OnlyClosure_GYM == 0 & Year >= NeighbourTreat_GYM & NeighbourTreat_GYM != .

* Now: Actual TWFE With Updated Dataset 
foreach var in $Mechanism {	
	
preserve

reghdfe `var' DummyOnlyClosure_GYM, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_GYM"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Excl. Treated Meighbours"
save "$RobustnessMechanisms\L_GYM_Robust5_`var'.dta", replace

restore
}

****************************
*** vi) Matched DiD/TWFE ***
****************************
* Matching Algorithm itself taken from Blesse And Diegmann (2020), See "17_Matching.do" 

* Load Data-Set
use "$master\Daten Schulschließung Marcel\MatchingSampleRegress_GYM.dta", clear

*** *** Xtset (Attention: Because of matching with replacement, we can have certain municipalities as controll multiple times, therefore, xt set is not AGSxYear but MatchIDxYear) *** ***
xtset MatchID Year

* Due to matching 4 Years before Closure - Drop everything before Year 2005
drop if Year < 2005

foreach var in $Mechanism {	
	
preserve
eventstudyinteract `var' lead_OC_GYM* lag_OC_GYM*, vce(cluster MatchID) absorb(MatchID Year) cohort(Year_OnlyClosure_GYM) control_cohort(NeverTreated_GYM)
matrix sa_b = e(b_iw) 
matrix sa_v = e(V_iw)
ereturn post sa_b sa_v
lincomest  (lag_OC_GYM0 + lag_OC_GYM1 + lag_OC_GYM2 + lag_OC_GYM3 +  lag_OC_GYM4 + lag_OC_GYM5 + lag_OC_GYM6 + lag_OC_GYM7 )/8
parmest, norestore
keep if parm == "(1)"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Matched DiD"
save "$RobustnessMechanisms\L_GYM_Robust6_`var'.dta", replace
restore
}

***********************************************************************************************
*** viii) Actively disentangle elementary and grammar school closures (might be entangeled) ***
***********************************************************************************************
*** Use Final Data-Set
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
sort AGS2020 Year

* Set Panel
destring AGS2020, replace
xtset AGS2020 Year

* Generate a unique identifier for the first occurrence of each unit
bysort AGS2020: gen unique_id = _n == 1
count if unique_id
local num_distinct_units = r(N)
drop unique_id

* Gen East - West - Dummies (Exclude Berlin)
gen East = (State > 10)
gen West = (State < 10)

* Include only Dummies where we have only Elementary or Grammar, not both simultaneously !
bysort AGS2020: gen DummyBothClosures = ((Year_OnlyClosure_ES == Year_OnlyClosure_GYM) & Year_OnlyClosure_ES != 0 & Year_OnlyClosure_GYM != 0 )

foreach var in $Mechanism {	
	
preserve
reghdfe `var' DummyOnlyClosure_GYM if DummyBothClosures != 1, absorb(AGS2020 Year) vce(cluster AGS2020)
parmest, norestore
keep if parm == "DummyOnlyClosure_GYM"
gen Variable = "`var'"
gen School = "Grammar"
gen Robust = "Excl. Both Simultaneous"
save "$RobustnessMechanisms\L_GYM_Robust7_`var'.dta", replace
restore

}

*********************************************************
* Now: Combine Elementary And Gymnasium to one Coeff-Plot
********************************************************* 
***  ShareUnemployedAge25   ***
foreach var in ShareUnemployedAge25  {
	
	* Baseline 
use "$RobustnessMechanisms\L_ES_Robust0_`var'.dta", clear

	* Elementary Schools
append using "$RobustnessMechanisms\L_ES_Robust11_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust12_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust21_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust22_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust3_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust4_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust5_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust6_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust7_`var'.dta"

	* Grammar Schools
append using "$RobustnessMechanisms\GYM_Robust0_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust11_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust12_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust21_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust22_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust3_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust4_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust5_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust6_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust7_`var'.dta" 

* Gen SchoolType For Jitter
egen SchoolType = group(School)
bysort SchoolType: gen Order = _n
replace Order = Order + 0.1 if SchoolType == 1   // For Jitter
replace Order = Order - 0.1 if SchoolType == 2   // For Jitter

* Two-Way
twoway ///
(rcap min95 max95 Order if SchoolType==1, horizontal lcolor(gs1)) ///
(scatter Order estimate if SchoolType==1, ///
    msymbol(Dh) mcolor(gs1) lwidth(vthin) msize(small) mlabel(Robust) mlabsize(vsmall) mlabposition(12)) /// // Right needs to be mlabposition(1)!
(rcap min95 max95 Order if SchoolType==2, horizontal lcolor(gs6)) ///
(scatter Order estimate if SchoolType==2, ///
    msymbol(Oh) mcolor(gs7) lwidth(vthin) msize(small)), ///
xline(0, lpattern(dash) lcolor(gs10)) ///
xlabel(,labsize(tiny)) ///
yscale(range(1  10) noextend) ///
ytitle("") ///
title("Share Youth Unemployment", size(vsmall)) ///
ylabel(1(1)10, angle(0) nogrid) ///
yscale(off) ///
graphregion(color(white)) plotregion(color(white)) ///
legend(order(2 "Last Elementary School Closure" 4 "Last Grammar School Closure"))

* Graph Save
graph save "Graph" "$RobustnessMechanisms/L_`var'.gph", replace
graph export "$RobustnessMechanisms/L_`var'.pdf", as(pdf) name("Graph") replace
}

***  LTUnemp    ***
foreach var in LTUnemp  {
	
	* Baseline 
use "$RobustnessMechanisms\L_ES_Robust0_`var'.dta", clear

	* Elementary Schools
append using "$RobustnessMechanisms\L_ES_Robust11_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust12_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust21_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust22_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust3_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust4_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust5_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust6_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust7_`var'.dta"

	* Grammar Schools
append using "$RobustnessMechanisms\GYM_Robust0_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust11_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust12_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust21_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust22_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust3_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust4_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust5_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust6_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust7_`var'.dta" 

* Gen SchoolType For Jitter
egen SchoolType = group(School)
bysort SchoolType: gen Order = _n
replace Order = Order + 0.1 if SchoolType == 1   // For Jitter
replace Order = Order - 0.1 if SchoolType == 2   // For Jitter

* Two-Way
twoway ///
(rcap min95 max95 Order if SchoolType==1, horizontal lcolor(gs1)) ///
(scatter Order estimate if SchoolType==1, ///
    msymbol(Dh) mcolor(gs1) lwidth(vthin) msize(small) mlabel(Robust) mlabsize(vsmall) mlabposition(12)) /// // Right needs to be mlabposition(1)!
(rcap min95 max95 Order if SchoolType==2, horizontal lcolor(gs6)) ///
(scatter Order estimate if SchoolType==2, ///
    msymbol(Oh) mcolor(gs7) lwidth(vthin) msize(small)), ///
xline(0, lpattern(dash) lcolor(gs10)) ///
xlabel(,labsize(tiny)) ///
yscale(range(1  10) noextend) ///
ytitle("") ///
title("Longterm Unemployment", size(vsmall)) ///
ylabel(1(1)10, angle(0) nogrid) ///
yscale(off) ///
graphregion(color(white)) plotregion(color(white)) ///
legend(order(2 "Last Elementary School Closure" 4 "Last Grammar School Closure"))

* Graph Save
graph save "Graph" "$RobustnessMechanisms/L_`var'.gph", replace
graph export "$RobustnessMechanisms/L_`var'.pdf", as(pdf) name("Graph") replace
}

***  AvrgAgePop    ***
foreach var in AvrgAgePop  {
	
	* Baseline 
use "$RobustnessMechanisms\L_ES_Robust0_`var'.dta", clear

	* Elementary Schools
append using "$RobustnessMechanisms\L_ES_Robust11_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust12_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust21_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust22_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust3_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust4_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust5_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust6_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust7_`var'.dta"

	* Grammar Schools
append using "$RobustnessMechanisms\GYM_Robust0_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust11_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust12_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust21_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust22_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust3_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust4_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust5_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust6_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust7_`var'.dta" 

* Gen SchoolType For Jitter
egen SchoolType = group(School)
bysort SchoolType: gen Order = _n
replace Order = Order + 0.1 if SchoolType == 1   // For Jitter
replace Order = Order - 0.1 if SchoolType == 2   // For Jitter

* Two-Way
twoway ///
(rcap min95 max95 Order if SchoolType==1, horizontal lcolor(gs1)) ///
(scatter Order estimate if SchoolType==1, ///
    msymbol(Dh) mcolor(gs1) lwidth(vthin) msize(small) mlabel(Robust) mlabsize(vsmall) mlabposition(12)) /// // Right needs to be mlabposition(1)!
(rcap min95 max95 Order if SchoolType==2, horizontal lcolor(gs6)) ///
(scatter Order estimate if SchoolType==2, ///
    msymbol(Oh) mcolor(gs7) lwidth(vthin) msize(small)), ///
xline(0, lpattern(dash) lcolor(gs10)) ///
xlabel(,labsize(tiny)) ///
yscale(range(1  10) noextend) ///
ytitle("") ///
title("Population Age", size(small)) ///
ylabel(1(1)10, angle(0) nogrid) ///
yscale(off) ///
graphregion(color(white)) plotregion(color(white)) ///
legend(order(2 "Last Elementary School Closure" 4 "Last Grammar School Closure"))

* Graph Save
graph save "Graph" "$RobustnessMechanisms/L_`var'.gph", replace
graph export "$RobustnessMechanisms/L_`var'.pdf", as(pdf) name("Graph") replace
}

***  GenderRatio   ***
foreach var in GenderRatio  {
	
	* Baseline 
use "$RobustnessMechanisms\L_ES_Robust0_`var'.dta", clear

	* Elementary Schools
append using "$RobustnessMechanisms\L_ES_Robust11_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust12_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust21_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust22_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust3_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust4_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust5_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust6_`var'.dta"
append using "$RobustnessMechanisms\L_ES_Robust7_`var'.dta"

	* Grammar Schools
append using "$RobustnessMechanisms\GYM_Robust0_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust11_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust12_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust21_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust22_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust3_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust4_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust5_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust6_`var'.dta"
append using "$RobustnessMechanisms\GYM_Robust7_`var'.dta" 


* Gen SchoolType For Jitter
egen SchoolType = group(School)
bysort SchoolType: gen Order = _n
replace Order = Order + 0.1 if SchoolType == 1   // For Jitter
replace Order = Order - 0.1 if SchoolType == 2   // For Jitter

* Two-Way
twoway ///
(rcap min95 max95 Order if SchoolType==1, horizontal lcolor(gs1)) ///
(scatter Order estimate if SchoolType==1, ///
    msymbol(Dh) mcolor(gs1) lwidth(vthin) msize(small) mlabel(Robust) mlabsize(vsmall) mlabposition(12)) /// // Right needs to be mlabposition(1)!
(rcap min95 max95 Order if SchoolType==2, horizontal lcolor(gs6)) ///
(scatter Order estimate if SchoolType==2, ///
    msymbol(Oh) mcolor(gs7) lwidth(vthin) msize(small)), ///
xline(0, lpattern(dash) lcolor(gs10)) ///
xlabel(,labsize(tiny)) ///
yscale(range(1  10) noextend) ///
ytitle("") ///
title("Gender Ratio", size(small)) ///
ylabel(1(1)10, angle(0) nogrid) ///
yscale(off) ///
graphregion(color(white)) plotregion(color(white)) ///
legend(order(2 "Last Elementary School Closure" 4 "Last Grammar School Closure"))

* Graph Save
graph save "Graph" "$RobustnessMechanisms/L_`var'.gph", replace
graph export "$RobustnessMechanisms/L_`var'.pdf", as(pdf) name("Graph") replace
}


*** Graph Combine ***
cd "$RobustnessMechanisms/"

*** Federal Elections ***
grc1leg2 L_ShareUnemployedAge25.gph L_LTUnemp.gph L_AvrgAgePop.gph L_NetCommuter.gph L_GenderRatio.gph, col(6)  // L_NetMigration.gph
graph save "Graph" "$RobustnessMechanisms/Mechanisms_Combined_Last.gph", replace
graph export "$RobustnessMechanisms/Mechanisms_Combined_Last.pdf", as(pdf) name("Graph") replace


 