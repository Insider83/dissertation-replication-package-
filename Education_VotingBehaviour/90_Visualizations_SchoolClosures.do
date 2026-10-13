/*******************************************************
This File will do all Visualizations for the School-Closure Paper

This Do-File will produce all graphs and figures
Graphs Include:
	* Merges/Dissolvments of Municipalities
	* Closures of Schools

	Author: Sebastian Vogler
	Version: 1.0, Created: 2023-10-10

*******************************************************/
********************************************************************************
 *** *** *** *** *** School Closures *** *** *** *** *** *** *** *** *** *** *** 
********************************************************************************
********************************************************************************
* Produce Bar-Plot for number of Schools and School Closures
********************************************************************************
use "$results\Panel\ClosureAndOpenMunicipality_Descriptives.dta", clear // From "11_PrepareSchoolClosureToPanel.do"
duplicates drop AGS2020, force

*** Number of Schools in Germany *** IMPORTANT: SINCE 2000 !!!
egen SumSchool_All = sum(NumberSchools )
egen SumSchool_ES = sum(NumberSchools_ES )
egen SumSchool_SS = sum(NumberSchools_SS )
egen SumSchool_GYM = sum(NumberSchools_GYM)

*** All Schools ***
graph bar SumSchool_All SumSchool_ES SumSchool_SS SumSchool_GYM,  ///
   blabel(bar, size(tiny) position(outside) format(%9.0fc)) ///
    ylabel(0(10000)30000, labsize(tiny))  ///
	legend(order(1 "All Schools" 2 "Elementary Schools" 3 "Secondary Schools" 4 "Grammar Schools") ///
           position(8) ring(0) col(1)) ///
	ytitle("Number of Total Schools", size(small)) 
graph export "$results\Visualisierungen\NumberOfSchoolsTotal.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\NumberOfSchoolsTotal.gph", replace

*** All Schools By Type ***
* Umbenennen der Kategorien in TypeSchool
label define type_school_label 1 "Elementary School" 2 "Grammar School"  3 "Secondary School"
label values TypeSchool type_school_label

* Gruppiertes Balkendiagramm erstellen
graph bar (sum) NumberSchools, ///
    over(TypeSchool, label(labsize(tiny)))  ///
    blabel(bar, size(tiny) position(outside) format(%9.0fc)) legend(off) ///
    ylabel(0(6000)18000, labsize(tiny)) ///
    ytitle("Total Number of Schools", size(small)) 
graph export "$results\Visualisierungen\NumberOfSchoolsByType.pdf",  as(pdf) replace
graph save "Graph" "$results\Visualisierungen\NumberOfSchoolsByType.gph", replace

*** East West ***  // BERLIN CONSIDERED AS WEST
label define type_EastWest_label 0 "West-Germany" 1 "East-Germany"  
label values DummyEast type_EastWest_label

graph bar (sum) NumberSchools, over(DummyEast, label(labsize(tiny))) /// 
  over(TypeSchool, label(labsize(tiny)))  ///
    blabel(bar, size(tiny) position(outside) format(%9.0fc)) legend(off) ///
    ylabel(0(4000)12000, labsize(tiny))  ///
    ytitle("Total Number of Schools", size(small))
graph export "$results\Visualisierungen\NumberOfSchoolsByTypeEastWest.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\NumberOfSchoolsByTypeEastWest.gph", replace

*** Closure Type Of School ***
*** All Schools ***
egen SumSchoolClosures_All = sum(NumberClosures) 
egen SumSchoolClosures_ES = sum(NumberClosures_ES)
egen SumSchoolClosures_SS = sum(NumberClosures_SS)
egen SumSchoolClosures_GYM = sum(NumberClosures_GYM) 

graph bar SumSchoolClosures_All SumSchoolClosures_ES SumSchoolClosures_SS SumSchoolClosures_GYM,  ///
   blabel(bar, size(tiny) position(outside) format(%9.0fc)) ///
    ylabel(0(1000)4000, labsize(tiny))  ///
	legend(order(1 "All Schools" 2 "Elementary Schools" 3 "Secondary Schools" 4 "Grammar Schools") ///
           position(8) ring(0) col(1)) ///
    ytitle("Number of Total School Closures", size(small))
graph export "$results\Visualisierungen\NumberOfSchoolClosuresTotal.pdf",  as(pdf) replace
graph save "Graph" "$results\Visualisierungen\NumberOfSchoolClosuresTotal.gph", replace

*** All Schools By Type ***
graph bar (sum) NumberClosures, ///
    over(TypeSchool, label(labsize(tiny)))  ///
    blabel(bar, size(tiny) position(outside) format(%9.0fc)) legend(off) ///
    ylabel(0(1000)3000, labsize(tiny)) ///
    ytitle("Number of Total School Closures", size(small))
graph export "$results\Visualisierungen\NumberOfSchoolClosuresByType.pdf",  as(pdf) replace
graph save "Graph" "$results\Visualisierungen\NumberOfSchoolClosuresByType.gph", replace

*** Closure Bar East-/West ***
graph bar (sum) NumberClosures, over(DummyEast, label(labsize(tiny))) /// 
	over(TypeSchool, label(labsize(tiny)))  ///
    blabel(bar, size(tiny) position(outside) format(%9.0fc)) legend(off) ///
    ylabel(0(500)1500, labsize(tiny))  ///
    ytitle("Number of Total School Closures", size(small))
graph export "$results\Visualisierungen\NumberOfSchoolClosuresByTypeEastWest.pdf",  as(pdf) replace
graph save "Graph" "$results\Visualisierungen\NumberOfSchoolClosuresByTypeEastWest.gph", replace

*** Combine Closure and Total Number of Schools
*** Schools By Type
graph combine "$results\Visualisierungen\NumberOfSchoolsByType.gph"	"$results\Visualisierungen\NumberOfSchoolClosuresByType.gph",  // ycommon col(1)
graph export "$results\Visualisierungen\CombinedNumberOfSchoolsAndClosureByType.pdf",  as(pdf) replace

*** Schools By East West
graph combine "$results\Visualisierungen\NumberOfSchoolsByTypeEastWest.gph" "$results\Visualisierungen\NumberOfSchoolClosuresByTypeEastWest.gph",  // ycommon col(1)
graph export "$results\Visualisierungen\CombinedNumberOfSchoolsAndClosureByTypeEastWest.pdf",  as(pdf) replace

*** Closures By Year ***
use "$results\Panel\ClosureAndOpenMunicipality_Descriptives.dta", clear // From "11_PrepareSchoolClosureToPanel.do"

* Berechne die Summe der Werte
collapse (sum) ClosureDummy, by(MaxYear TypeSchool)

drop if MaxYear == 2019
drop if MaxYear == 0

* Umbenennen der Kategorien in TypeSchool
label define type_school_label 1 "Elementary School" 2 "Grammar School" 3  "Secondary School"
label values TypeSchool type_school_label

* Gruppiertes Balkendiagramm erstellen
graph bar (sum) ClosureDummy, over(MaxYear, label(labsize(tiny) noticks nolabel)) ///
    over(TypeSchool, label(labsize(tiny)))  ///
    blabel(bar, size(tiny) position(outside) format(%9.0fc)) legend(off) ///
    ytitle("Number of School Closures", size(small)) ///
    ylabel(0(50)200, labsize(tiny))
	
graph export "$results\Visualisierungen\NumberOfSchoolsTotal.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\SchoolClosureByYearType.gph", replace

	
********************************************************************************
 *** *** *** Last School Closure In A Municipalitiy *** *** *** *** *** *** ***  
********************************************************************************

********************************************************************************
* Number per Year and Introduction of Reform
********************************************************************************
use "$results\Panel\Descriptives_ClosureByYearStateType.dta", clear	

* Clean Dataset
drop if Bundesland == 2 // HH
drop if Bundesland == 4 // HB
drop if Bundesland == 9 // BY
drop if Bundesland == 11 // BE
drop if MaxYear == 0
drop if MaxYear == 2019

* Collapse to Total 
collapse (sum) ClosureDummy, by (MaxYear Bundesland)
sort Bundesland MaxYear
xtset Bundesland MaxYear
tsfill
replace ClosureDummy = 0 if ClosureDummy == .

********************************************************************************
* Beautiful now!
* All School Closures (Total School, First School And Last Schools) And Total Schools in one Graph
********************************************************************************
*** *** All Schools *** ***
*** Build Stacks: Closures: All, First, Last By Calendar Year ***
use "$results\Panel\ClosureAndOpenMunicipality_Descriptives.dta", clear // From "11_PrepareSchoolClosureToPanel.do"
* distinct SchoolIdentifier -> I got 30223 distinct Schools; Sample With All Schools

* Create ClosureDummy ClosureDummyFirst ClosureDummyOnly For Collapse (Sum)
gen ClosureDummyFirst = (minYear == MaxYear)
gen ClosureDummyOnly = (Year_OnlyClosure == MaxYear)

* Sum Number of Schools Per Year as Line-Chart
collapse (sum) ClosureDummy ClosureDummyFirst ClosureDummyOnly, by (MaxYear)
drop if MaxYear == 0
drop if MaxYear == 2019

* Save Stack
save "$results\Visualisierungen\AuxiliaryAllClosures.dta", replace

*** Build Stacks: Number of Schools Every Calendar Year ***
use "$results\Panel\ClosureAndOpenMunicipality_Descriptives.dta", clear 

*** Gen Variable Total Number of _ School
preserve
duplicates drop AGS2020, force
egen SumSchool_All = sum(NumberSchools)

* local save Number of Schools
sum SumSchool_All
local total = r(max)

restore

* Distinct Numbers And Closures per Year
collapse (sum) ClosureDummy, by(MaxYear)
gen TotalSchools = `total'
sort MaxYear

gen SchoolsRemain = .
replace SchoolsRemain = TotalSchools if _n == 1
replace SchoolsRemain = SchoolsRemain[_n-1] - ClosureDummy[_n-1] if _n > 1
*replace SchoolsRemain = SchoolsRemain[_n-1] - ClosureDummy if _n > 1
drop if MaxYear == 0
drop if MaxYear == 2019

* Save Stack
save "$results\Visualisierungen\AuxiliarySchoolOverTime.dta", replace

*** Combine And Beautiful Graph
use "$results\Visualisierungen\AuxiliaryAllClosures.dta", clear
joinby MaxYear using "$results\Visualisierungen\AuxiliarySchoolOverTime.dta" // Could have made in one file, but nevermind for now

*** Graph 
gen MaxYear_left  = MaxYear - 0.2
gen MaxYear_mid   = MaxYear
gen MaxYear_right = MaxYear + 0.2

twoway ///
    (bar ClosureDummy 		MaxYear_left,  barwidth(0.2) yaxis(2) color(gs0)) ///
    (bar ClosureDummyFirst  MaxYear_mid,   barwidth(0.2) yaxis(2) color(gs4)) ///
    (bar ClosureDummyOnly   MaxYear_right, barwidth(0.2) yaxis(2) color(gs8)) ///
	///
	(scatter ClosureDummy      MaxYear_left,  mlabel(ClosureDummy)      ///
    msymbol(none) mlabangle(45) mlabsize(vsmall) mlabposition(1) yaxis(2)) ///
    (scatter ClosureDummyFirst MaxYear_mid,   mlabel(ClosureDummyFirst) ///
    msymbol(none) mlabangle(45) mlabsize(vsmall) mlabposition(1) yaxis(2)) ///
    (scatter ClosureDummyOnly  MaxYear_right, mlabel(ClosureDummyOnly)  ///
    msymbol(none) mlabangle(45) mlabsize(vsmall) mlabposition(1) yaxis(2)) ///
    (line SchoolsRemain MaxYear, yaxis(1) lwidth(medthin) color(blue) ), ///
	///
	ytitle("No. Remaining Schools", axis(1) size(small)) ///
    ytitle("No. School Closures", axis(2) size(small)) ///
    xtitle("") ///
	xlabel(2000(1)2018.2, labsize(tiny)) ///
	ylabel(, labsize(vsmall) axis(1)) ///
	ylabel(, labsize(vsmall) axis(2)) ///
	legend(order(1 "No. Closures" 2 "No. First Closures" 3 "No. Last Closures" 7 "No. Remaining Schools") size(small))
	
*** Save Graph 
graph save "Graph" "$results\Visualisierungen\AllSchoolsAllClosures.gph", replace
graph export "$results\Visualisierungen\AllSchoolsAllClosures.pdf", as(pdf) replace
graph export "$results\Visualisierungen\AllSchoolsAllClosures.png", as(png) replace


*** *** Elementary Schools *** ***
*** Build Stacks: Closures: All, First, Last By Calendar Year ***
use "$results\Panel\ClosureAndOpenMunicipality_Descriptives.dta", clear // From "11_PrepareSchoolClosureToPanel.do"

* Create ClosureDummy ClosureDummyFirst ClosureDummyOnly For Collapse (Sum)
gen ClosureDummy_ES = (ClosureDummy == 1 & TypeSchool == 1)
gen ClosureDummyFirst_ES = ( (minYear_ES == MaxYear) & (TypeSchool == 1) )
gen ClosureDummyOnly_ES = ( (Year_OnlyClosure_ES == MaxYear) & (TypeSchool == 1))

* Sum Number of Schools Per Year as Line-Chart
collapse (sum) ClosureDummy_ES ClosureDummyFirst_ES ClosureDummyOnly_ES, by (MaxYear)
drop if MaxYear == 0
drop if MaxYear == 2019

* Save Stack
save "$results\Visualisierungen\AuxiliaryAllClosures_ES.dta", replace

*** Build Stacks: Number of Schools Every Calendar Year ***
use "$results\Panel\ClosureAndOpenMunicipality_Descriptives.dta", clear 
gen ClosureDummy_ES = (ClosureDummy == 1 & TypeSchool == 1)

*** Gen Variable Total Number of _ School
preserve
duplicates drop AGS2020, force
egen SumSchool_ES = sum(NumberSchools_ES)

* local save Number of Schools
sum SumSchool_ES
local total = r(max)

restore

* Distinct Numbers And Closures per Year
collapse (sum) ClosureDummy_ES, by(MaxYear)
gen TotalSchools_ES = `total'
sort MaxYear

gen SchoolsRemain_ES = .
replace SchoolsRemain_ES = TotalSchools_ES if _n == 1
replace SchoolsRemain_ES = SchoolsRemain_ES[_n-1] - ClosureDummy_ES[_n-1] if _n > 1
drop if MaxYear == 0
drop if MaxYear == 2019

* Save Stack
save "$results\Visualisierungen\AuxiliarySchoolOverTime_ES.dta", replace

*** Combine And Beautiful Graph
use "$results\Visualisierungen\AuxiliaryAllClosures_ES.dta", clear
joinby MaxYear using "$results\Visualisierungen\AuxiliarySchoolOverTime_ES.dta" // Could have made in one file, but nevermind for now

*** Graph 
gen MaxYear_left  = MaxYear - 0.2
gen MaxYear_mid   = MaxYear
gen MaxYear_right = MaxYear + 0.2

twoway ///
    (bar ClosureDummy_ES 		MaxYear_left,  barwidth(0.2) yaxis(2) color(gs0)) ///
    (bar ClosureDummyFirst_ES  MaxYear_mid,   barwidth(0.2) yaxis(2) color(gs4)) ///
    (bar ClosureDummyOnly_ES   MaxYear_right, barwidth(0.2) yaxis(2) color(gs8)) ///
	///
	(scatter ClosureDummy_ES      MaxYear_left,  mlabel(ClosureDummy_ES)      ///
    msymbol(none) mlabangle(45) mlabsize(vsmall) mlabposition(1) yaxis(2)) ///
    (scatter ClosureDummyFirst_ES MaxYear_mid,   mlabel(ClosureDummyFirst_ES) ///
    msymbol(none) mlabangle(45) mlabsize(vsmall) mlabposition(1) yaxis(2)) ///
    (scatter ClosureDummyOnly_ES  MaxYear_right, mlabel(ClosureDummyOnly_ES)  ///
    msymbol(none) mlabangle(45) mlabsize(vsmall) mlabposition(1) yaxis(2)) ///
    (line SchoolsRemain MaxYear, yaxis(1) lwidth(medthin) color(green) ), ///
	///
	ytitle("No. Remaining Elementary Schools", axis(1) size(small)) ///
    ytitle("No. Elementary School Closures", axis(2) size(small)) ///
    xtitle("") ///
	xlabel(2000(1)2018.2, labsize(tiny)) ///
	ylabel(, labsize(vsmall) axis(1)) ///
	ylabel(, labsize(vsmall) axis(2)) ///
	legend(order(1 "No. Elem. Closures" 2 "No. First Elem. Closures" 3 "No. Last Elem. Closures" 7 "No. Remaining Elem. Schools") size(small))

*** Save Graph 
graph save "Graph" "$results\Visualisierungen\AllSchoolsAllClosures_ES.gph", replace
graph export "$results\Visualisierungen\AllSchoolsAllClosures_ES.pdf", as(pdf) replace
graph export "$results\Visualisierungen\AllSchoolsAllClosures_ES.png", as(png) replace


*** *** Grammar Schools *** ***
*** Build Stacks: Closures: All, First, Last By Calendar Year ***
use "$results\Panel\ClosureAndOpenMunicipality_Descriptives.dta", clear // From "11_PrepareSchoolClosureToPanel.do"

* Create ClosureDummy ClosureDummyFirst ClosureDummyOnly For Collapse (Sum)
gen ClosureDummy_GYM = (ClosureDummy == 1 & TypeSchool == 2)
gen ClosureDummyFirst_GYM = ( (minYear_GYM == MaxYear) & (TypeSchool == 2) )
gen ClosureDummyOnly_GYM = ( (Year_OnlyClosure_GYM == MaxYear) & (TypeSchool == 2))

* Sum Number of Schools Per Year as Line-Chart
collapse (sum) ClosureDummy_GYM ClosureDummyFirst_GYM ClosureDummyOnly_GYM, by (MaxYear)
drop if MaxYear == 0
drop if MaxYear == 2019

* Save Stack
save "$results\Visualisierungen\AuxiliaryAllClosures_GYM.dta", replace

*** Build Stacks: Number of Schools Every Calendar Year ***
use "$results\Panel\ClosureAndOpenMunicipality_Descriptives.dta", clear 
gen ClosureDummy_GYM = (ClosureDummy == 1 & TypeSchool == 2)

*** Gen Variable Total Number of _ School
preserve
duplicates drop AGS2020, force
egen SumSchool_GYM = sum(NumberSchools_GYM)

* local save Number of Schools
sum SumSchool_GYM
local total = r(max)

restore

* Distinct Numbers And Closures per Year
collapse (sum) ClosureDummy_GYM, by(MaxYear)
gen TotalSchools_GYM = `total'
sort MaxYear

gen SchoolsRemain_GYM = .
replace SchoolsRemain_GYM = TotalSchools_GYM if _n == 1
replace SchoolsRemain_GYM = SchoolsRemain_GYM[_n-1] - ClosureDummy_GYM[_n-1] if _n > 1
drop if MaxYear == 0
drop if MaxYear == 2019

* Save Stack
save "$results\Visualisierungen\AuxiliarySchoolOverTime_GYM.dta", replace

*** Combine And Beautiful Graph
use "$results\Visualisierungen\AuxiliaryAllClosures_GYM.dta", clear
joinby MaxYear using "$results\Visualisierungen\AuxiliarySchoolOverTime_GYM.dta" 

*** Graph 
gen MaxYear_left  = MaxYear - 0.2
gen MaxYear_mid   = MaxYear
gen MaxYear_right = MaxYear + 0.2

twoway ///
    (bar ClosureDummy_GYM 		MaxYear_left,  barwidth(0.2) yaxis(2) color(gs0)) ///
    (bar ClosureDummyFirst_GYM  MaxYear_mid,   barwidth(0.2) yaxis(2) color(gs4)) ///
    (bar ClosureDummyOnly_GYM   MaxYear_right, barwidth(0.2) yaxis(2) color(gs8)) ///
	///
	(scatter ClosureDummy_GYM      MaxYear_left,  mlabel(ClosureDummy_GYM)      ///
    msymbol(none) mlabangle(45) mlabsize(vsmall) mlabposition(1) yaxis(2)) ///
    (scatter ClosureDummyFirst_GYM MaxYear_mid,   mlabel(ClosureDummyFirst_GYM) ///
    msymbol(none) mlabangle(45) mlabsize(vsmall) mlabposition(1) yaxis(2)) ///
    (scatter ClosureDummyOnly_GYM  MaxYear_right, mlabel(ClosureDummyOnly_GYM)  ///
    msymbol(none) mlabangle(45) mlabsize(vsmall) mlabposition(1) yaxis(2)) ///
    (line SchoolsRemain MaxYear, yaxis(1) lwidth(medthin) color(red) ), ///
	///
	ytitle("No. Remaining Grammar Schools", axis(1) size(small)) ///
    ytitle("No. Grammar School Closures", axis(2) size(small)) ///
    xtitle("") ///
	xlabel(2000(1)2018.2, labsize(tiny)) ///
	ylabel(, labsize(vsmall) axis(1)) ///
	ylabel(, labsize(vsmall) axis(2)) ///
	legend(order(1 "No. Grammar Closures" 2 "No. First Grammar Closures" 3 "No. Last Grammar Closures" 7 "No. Remaining Grammar Schools") size(small))

*** Save Graph 
graph save "Graph" "$results\Visualisierungen\AllSchoolsAllClosures_GYM.gph", replace
graph export "$results\Visualisierungen\AllSchoolsAllClosures_GYM.pdf", as(pdf) replace
graph export "$results\Visualisierungen\AllSchoolsAllClosures_GYM.png", as(png) replace