/**************************************************
    Compute all relevant variables to visualize Mobility on a map of Germany
	Then, visualize results on a map
	-> This file will process County Level!
	
	We concentrate on Age 25- 55 (To be inline with regressions)
	
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2023-05-2
	Version: 2.0 (Update for final Maps), First Created: 2023-11-07
***************************************************/

*Install Packages
*ssc install spmap
*ssc install shp2dta
*ssc install mif2dta

*New Globals
global COORDS "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\Geo-Coordinates for Maps\neps.nu004901_2023-12-19_17-23-1\2023 12 19\vg5000_ebenen_1231" //WD with Shapefiles of NUT3-Level

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*** *** Full Cohort 1944 - 86 *** ***
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*Load final data set (Must include Kreise and Bula)
use "$results\0_basicpanel_new.dta", clear

*Use font Times New Roman
graph set window fontface "Times New Roman"

*Clean Data Set
keep if inrange(age, 25, 55) // We agreed on this
keep if inrange(yob, 1944, 1986)
drop if bl_birth == 0

*drop unreasonable numbers (such as 99)
foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	replace `var' = . if `var' == 99
	drop if `var' == .
}

*create means
foreach var in mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
	preserve
	collapse (mean) `var', by (kr_birth)
	rename kr_birth kreis
	save "$results\temp\graph_mean_`var'_kreis_4486.dta", replace
	restore
}

*combine all migs to one dataset
use "$results\temp\graph_mean_mig_stock_kreis_4486.dta", clear
foreach var in mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
 merge 1:1 kreis using "$results\temp\graph_mean_`var'_kreis_4486.dta"
 drop _merge
 *replace `var' = 0 if `var' == .
 erase "$results\temp\graph_mean_`var'_kreis_4486.dta"
}

*Drop Ausland and create Merge_Variable
drop if kreis == .
clonevar Kreis_merge = kreis 

*save final data set
save "$results\temp\graph_mean_mig_kreis_4486.dta", replace
use "$results\temp\graph_mean_mig_kreis_4486.dta", clear

************************************************
*** Part ii): Data Preparation (Coordinates and Labels) for the Data-Visualization ***
************************************************
*** *** Cohorts 1944 - 1986 *** ***
*** create .dta with coordinates. We then need a variable to merge coordinates with dataset of migration
** three steps: i) transform shape-files into datasets and coordinates. ii) enrich data-set of bulas (With Coords) with data created above (e.g. percentage of individuals migrating) iii) merge all files to use as a proper visualization
cd "$COORDS\"
shp2dta using VG5000_KRS, database(Kreis_Database) coordinates(Kreis_COORD) genid(Kreis_ID) replace

*Prepare Correct AGS
use "$COORDS\Kreis_Database.dta", clear
destring AGS, gen(Kreis_merge)
save "$COORDS\Kreis_Database.dta", replace

*merge with geo-files
use "$COORDS\Kreis_Database.dta", clear
*recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
joinby Kreis_merge using "$results\temp\graph_mean_mig_kreis_4486.dta"
*drop _merge
save "$COORDS\Kreis_Database_4486.dta", replace

************************************************
*** Actual Maps ***
************************************************
*** Cohorts 1944 - 1986 ***
use "$COORDS\Kreis_Database_4486.dta", clear

spmap mig_stock using Kreis_COORD, id(Kreis_ID) fcolor(Blues) clm(custom) clbreaks(.0 .20 0.25 0.30 0.35 .40 0.45 .50 1) title("Cohorts 1944-1986", size(medsmall)) saving(Map_Y4486_County.gph, replace) legtitle("Percentage Of" "Population") // legend(off)  clbreaks(.0 (0.1) 0.9)

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
*** *** Post-War 1945- 1964 *** ***
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*Load final data set (Must include Kreise and Bula)
use "$results\0_basicpanel_new.dta", clear

*Clean Data Set
keep if inrange(age, 25, 55) // We agreed on this
keep if inrange(yob, 1945, 1964)
drop if bl_birth == 0

*drop unreasonable numbers (such as 99)
foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	replace `var' = . if `var' == 99
	drop if `var' == .
}

*create means
foreach var in mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
	preserve
	collapse (mean) `var', by (kr_birth)
	rename kr_birth kreis
	save "$results\temp\graph_mean_`var'_kreis_4564.dta", replace
	restore
}

*combine all migs to one dataset
use "$results\temp\graph_mean_mig_stock_kreis_4564.dta", clear
foreach var in mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
 merge 1:1 kreis using "$results\temp\graph_mean_`var'_kreis_4564.dta"
 drop _merge
 *replace `var' = 0 if `var' == .
 erase "$results\temp\graph_mean_`var'_kreis_4564.dta"
}

*Drop Ausland and create Merge_Variable
drop if kreis == .
clonevar Kreis_merge = kreis 

*save final data set
save "$results\temp\graph_mean_mig_kreis_4564.dta", replace
use "$results\temp\graph_mean_mig_kreis_4564.dta", clear

************************************************
*** Part ii): Data Preparation (Coordinates and Labels) for the Data-Visualization ***
************************************************
*** *** Cohorts 1945 - 1964 *** ***
*** create .dta with coordinates. We then need a variable to merge coordinates with dataset of migration
** three steps: i) transform shape-files into datasets and coordinates. ii) enrich data-set of bulas (With Coords) with data created above (e.g. percentage of individuals migrating) iii) merge all files to use as a proper visualization
cd "$COORDS\"
shp2dta using VG5000_KRS, database(Kreis_Database) coordinates(Kreis_COORD) genid(Kreis_ID) replace

*Prepare Correct AGS
use "$COORDS\Kreis_Database.dta", clear
destring AGS, gen(Kreis_merge)
save "$COORDS\Kreis_Database.dta", replace

*merge with geo-files
use "$COORDS\Kreis_Database.dta", clear
*recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
joinby Kreis_merge using "$results\temp\graph_mean_mig_kreis_4464.dta"
*drop _merge
save "$COORDS\Kreis_Database_4564.dta", replace

************************************************
*** Actual Maps ***
************************************************
*** Cohorts 1945 - 1964 ***
use "$COORDS\Kreis_Database_4564.dta", clear

spmap mig_stock using Kreis_COORD, id(Kreis_ID) fcolor(Blues) clm(custom) clbreaks(.0 .20 0.25 0.30 0.35 .40 0.45 .50 1) title("Cohorts 1945-1964", size(medsmall)) saving(Map_Y4564_County.gph, replace) legtitle("Percentage Of" "Population") // legend(off)  clbreaks(.0 (0.1) 0.9)

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
*** *** Baby Boomer 1944 - 1965 *** ***
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*Load final data set (Must include Kreise and Bula)
use "$results\0_basicpanel_new.dta", clear

*Clean Data Set
keep if inrange(age, 25, 55) // We agreed on this
keep if inrange(yob, 1944, 1965)
drop if bl_birth == 0

*drop unreasonable numbers (such as 99)
foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	replace `var' = . if `var' == 99
	drop if `var' == .
}

*create means
foreach var in mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
	preserve
	collapse (mean) `var', by (kr_birth)
	rename kr_birth kreis
	save "$results\temp\graph_mean_`var'_kreis_4465.dta", replace
	restore
}

*combine all migs to one dataset
use "$results\temp\graph_mean_mig_stock_kreis_4465.dta", clear
foreach var in mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
 merge 1:1 kreis using "$results\temp\graph_mean_`var'_kreis_4465.dta"
 drop _merge
 *replace `var' = 0 if `var' == .
 erase "$results\temp\graph_mean_`var'_kreis_4465.dta"
}

*Drop Ausland and create Merge_Variable
drop if kreis == .
clonevar Kreis_merge = kreis 

*save final data set
save "$results\temp\graph_mean_mig_kreis_4465.dta", replace
use "$results\temp\graph_mean_mig_kreis_4465.dta", clear

************************************************
*** Part ii): Data Preparation (Coordinates and Labels) for the Data-Visualization ***
************************************************
*** *** Cohorts 1944 - 1965 *** ***
*** create .dta with coordinates. We then need a variable to merge coordinates with dataset of migration
** three steps: i) transform shape-files into datasets and coordinates. ii) enrich data-set of bulas (With Coords) with data created above (e.g. percentage of individuals migrating) iii) merge all files to use as a proper visualization
cd "$COORDS\"
shp2dta using VG5000_KRS, database(Kreis_Database) coordinates(Kreis_COORD) genid(Kreis_ID) replace

*Prepare Correct AGS
use "$COORDS\Kreis_Database.dta", clear
destring AGS, gen(Kreis_merge)
save "$COORDS\Kreis_Database.dta", replace

*merge with geo-files
use "$COORDS\Kreis_Database.dta", clear
*recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
joinby Kreis_merge using "$results\temp\graph_mean_mig_kreis_4465.dta"
*drop _merge
save "$COORDS\Kreis_Database_4465.dta", replace

************************************************
*** Actual Maps ***
************************************************
*** Cohorts 1944 - 1965 ***
use "$COORDS\Kreis_Database_4465.dta", clear

spmap mig_stock using Kreis_COORD, id(Kreis_ID) fcolor(Blues) clm(custom) clbreaks(.0 .20 0.25 0.30 0.35 .40 0.45 .50 1) title("Cohorts 1944-1965", size(medsmall)) saving(Map_Y4465_County.gph, replace) legtitle("Percentage Of" "Population") // legend(off)  clbreaks(.0 (0.1) 0.9)

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*** *** Youngest Cohort 1965-86 *** ***
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*Load final data set (Must include Kreise and Bula)
use "$results\0_basicpanel_new.dta", clear

*Clean Data Set
keep if inrange(age, 25, 55) // We agreed on this
keep if inrange(yob, 1965, 1986)
drop if bl_birth == 0

*drop unreasonable numbers (such as 99)
foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	replace `var' = . if `var' == 99
	drop if `var' == .
}

*create means
foreach var in mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
	preserve
	collapse (mean) `var', by (kr_birth)
	rename kr_birth kreis
	save "$results\temp\graph_mean_`var'_kreis_6586.dta", replace
	restore
}

*combine all migs to one dataset
use "$results\temp\graph_mean_mig_stock_kreis_6586.dta", clear
foreach var in mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
 merge 1:1 kreis using "$results\temp\graph_mean_`var'_kreis_6586.dta"
 drop _merge
 *replace `var' = 0 if `var' == .
 erase "$results\temp\graph_mean_`var'_kreis_6586.dta"
}

*Drop Ausland and create Merge_Variable
drop if kreis == .
clonevar Kreis_merge = kreis 

*save final data set
save "$results\temp\graph_mean_mig_kreis_6586.dta", replace
use "$results\temp\graph_mean_mig_kreis_6586.dta", clear

************************************************
*** Part ii): Data Preparation (Coordinates and Labels) for the Data-Visualization ***
************************************************
*** *** Cohorts 1965 - 1986 *** ***
*** create .dta with coordinates. We then need a variable to merge coordinates with dataset of migration
** three steps: i) transform shape-files into datasets and coordinates. ii) enrich data-set of bulas (With Coords) with data created above (e.g. percentage of individuals migrating) iii) merge all files to use as a proper visualization
cd "$COORDS\"
shp2dta using VG5000_KRS, database(Kreis_Database) coordinates(Kreis_COORD) genid(Kreis_ID) replace

*Prepare Correct AGS
use "$COORDS\Kreis_Database.dta", clear
destring AGS, gen(Kreis_merge)
save "$COORDS\Kreis_Database.dta", replace

*merge with geo-files
use "$COORDS\Kreis_Database.dta", clear
*recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
joinby Kreis_merge using "$results\temp\graph_mean_mig_kreis_6586.dta"
*drop _merge
save "$COORDS\Kreis_Database_6586.dta", replace

************************************************
*** Actual Maps ***
************************************************
*** Cohorts 1965 -86 ***
use "$COORDS\Kreis_Database_6586.dta", clear

spmap mig_stock using Kreis_COORD, id(Kreis_ID) fcolor(Blues) clm(custom) clbreaks(.0 .20 0.25 0.30 0.35 .40 0.45 .50 1) title("Cohorts 1944-1964", size(medsmall)) saving(Map_Y6586_County.gph, replace) legtitle("Percentage Of" "Population") // legend(off)  clbreaks(.0 (0.1) 0.9)


************************************************
*** Finally: Graph Combine ***
************************************************
*W/O label
grc1leg2 Map_Y4486_County.gph Map_Y4564_County.gph Map_Y4465_County.gph Map_Y6586_County.gph, pos(4) saving("Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\graphs\Map_Combined_County", replace) scheme(s1color) 
graph export "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\graphs\Map_Combined_County.jpg", as(jpg) name("Graph") quality(100) replace
graph export "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\graphs\Map_Combined_County.pdf", as(pdf) name("Graph") replace


************************************************
*** Utilized RDD and C9 Sample ***
************************************************
*Load final data set (Must include Kreise and Bula)
use "$results\0_basicpanel_new.dta", clear

*Clean Data Set
keep if inrange(age, 25, 55) // We agreed on this
keep if inrange(yob, 1945, 1964)
drop if bl_birth == 0

*drop unreasonable numbers (such as 99)
foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	replace `var' = . if `var' == 99
	drop if `var' == .
}

*create means
foreach var in mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
	preserve
	collapse (mean) `var', by (kr_birth)
	rename kr_birth kreis
	save "$results\temp\graph_mean_`var'_kreis_4564.dta", replace
	restore
}

*combine all migs to one dataset
use "$results\temp\graph_mean_mig_stock_kreis_4564.dta", clear
foreach var in mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
 merge 1:1 kreis using "$results\temp\graph_mean_`var'_kreis_4564.dta"
 drop _merge
 *replace `var' = 0 if `var' == .
 erase "$results\temp\graph_mean_`var'_kreis_4564.dta"
}

*Drop Ausland and create Merge_Variable
drop if kreis == .
clonevar Kreis_merge = kreis 

*save final data set
save "$results\temp\graph_mean_mig_kreis_4564.dta", replace
use "$results\temp\graph_mean_mig_kreis_4564.dta", clear

************************************************
*** Part ii): Data Preparation (Coordinates and Labels) for the Data-Visualization ***
************************************************
*** *** Cohorts 1945 - 64 *** ***
*** create .dta with coordinates. We then need a variable to merge coordinates with dataset of migration
** three steps: i) transform shape-files into datasets and coordinates. ii) enrich data-set of bulas (With Coords) with data created above (e.g. percentage of individuals migrating) iii) merge all files to use as a proper visualization
cd "$COORDS\"
shp2dta using VG5000_KRS, database(Kreis_Database) coordinates(Kreis_COORD) genid(Kreis_ID) replace

*Prepare Correct AGS
use "$COORDS\Kreis_Database.dta", clear
destring AGS, gen(Kreis_merge)
save "$COORDS\Kreis_Database.dta", replace

*merge with geo-files
use "$COORDS\Kreis_Database.dta", clear
*recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
joinby Kreis_merge using "$results\temp\graph_mean_mig_kreis_4564.dta"
*drop _merge
save "$COORDS\Kreis_Database_4564.dta", replace

************************************************
*** Actual Maps ***
************************************************
*** Cohorts 1945 - 64 ***
use "$COORDS\Kreis_Database_4564.dta", clear

spmap mig_stock using Kreis_COORD, id(Kreis_ID) fcolor(Blues) clm(custom) clbreaks(.0 .20 0.25 0.30 0.35 .40 0.45 .50 1) title("Cohorts 1945 - 1964", size(medsmall)) saving(Map_Y6586_County.gph, replace) legtitle("Percentage Of" "Population") // legend(off)  clbreaks(.0 (0.1) 0.9) note("Map of lifetime cross-state mobility for individuals born 1945 - 1964. Age restricted to 25 - 55.", size(tiny))
graph export "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\graphs\Map_4564_County.pdf", as(pdf) name("Graph") replace
