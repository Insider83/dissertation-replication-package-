/**************************************************
    Compute all relevant variables to visualize Mobility on a map of Germany
	Then, visualize results on a map
	
	*Important: We distinguish between two final cohorts:
	Descriptives Cohort: 1944 - 1986 
	Causal Cohort: 1945 - 1964
	
	We concentrate on Age 25- 55 (To be inline with regressions)
	
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2023-05-2
	Version: 2.0 (Update for final Maps), First Created: 205-04-13
***************************************************/

*Install Packages
*ssc install spmap
*ssc install shp2dta
*ssc install mif2dta

*New Globals
global COORDS "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\Geo-Coordinates for Maps\neps.nu004901_2023-5-10_11-45-30\nuts5000_12-31.gk3.shape(1)\nuts5000_12-31.gk3.shape\nuts5000" //WD with Shapefiles of NUT2-Level

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*** *** Full Cohort 1944 - 86 *** ***
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

*Load final data set (Must include Kreise and Bula)
use "$results\0_basicpanel_final.dta", clear

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
	*collapse (mean) `var', by (bula)
	collapse (mean) `var' [aweight = w_t4_cal], by (bl_birth)
	rename bl_birth bula
	save "$results\temp\graph_mean_`var'_bula_4486.dta", replace
	restore
	
}

*combine all migs to one dataset
use "$results\temp\graph_mean_mig_stock_bula_4486.dta", clear
foreach var in mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
 merge 1:1 bula using "$results\temp\graph_mean_`var'_bula_4486.dta"
 drop _merge
 *replace `var' = 0 if `var' == .
 erase "$results\temp\graph_mean_`var'_bula_4486.dta"
}

*Drop Ausland and create Merge_Variable
drop if bula == 0
drop if bula == 99
clonevar Bula_merge = bula 

*save final data set
save "$results\temp\graph_mean_mig_bula_4486.dta", replace


************************************************
*** Part ii): Data Preparation (Coordinates and Labels) for the Data-Visualization ***
************************************************
*** *** Cohorts 1944 - 1986 *** ***
*** create .dta with coordinates. We then need a variable to merge coordinates with dataset of migration
** three steps: i) transform shape-files into datasets and coordinates. ii) enrich data-set of bulas (With Coords) with data created above (e.g. percentage of individuals migrating) iii) merge all files to use as a proper visualization
cd "$COORDS\"
shp2dta using NUTS5000_N1, database(BL_Database) coordinates(BL_COORD) genid(Bula_merge) replace
* You need to modify your .dta dataset to use the same location coding as that used in the map. Call that variable id
* Merge on id the translated .dbf

*merge with geo-files
use "$COORDS\BL_Database.dta", clear
recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
sort Bula_merge
merge 1:1 Bula_merge using "$results\temp\graph_mean_mig_bula_4486.dta"
drop _merge


save "$COORDS\BL_Database_4486.dta", replace


************************************************
*** Prepare Labels
************************************************
use "BL_COORD.dta", clear
bysort _ID: egen X_centroid = mean(_X)
bysort _ID: egen Y_centroid = mean(_Y)
duplicates drop _ID, force
clonevar Bula_merge = _ID
recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
drop _ID _X _Y
save "$COORDS\BL_Centroids.dta", replace

** Merge with data on Migration
use "$COORDS\BL_Database_4486.dta", clear
joinby Bula_merge using "$COORDS\BL_Centroids.dta"

input str3 Bula_merge_String
"SH"
"HH"
"NS"
"HB"
"NRW"
"HE"
"RPF"
"BW"
"BY"
"SL"
"BER"
"BB"
"MVP"
"SN"
"ST"
"TH" 


generate label1 = string(mig_stock, "%12.3f")
gen label = Bula_merge_String + "," + " " + label1 
* gen label2 = Bula_merge_String

* label change  for aestetics 
replace Y_centroid = 5968445 if Bula_merge_String == "HH" 
replace Y_centroid = 5905611 if Bula_merge_String == "HB" 
replace Y_centroid = 5855000 if Bula_merge_String == "BB" 
replace Y_centroid = 5805000 if Bula_merge_String == "BER" 
replace X_centroid = 3700000 if Bula_merge_String == "BY"

** Save Labels
save "$COORDS\BL_Labels_Short.dta", replace

** Merge with data on Migration
use "$COORDS\BL_Database_4486.dta", clear
joinby Bula_merge using "$COORDS\BL_Centroids.dta"

input str50 Bula_merge_String
"Schleswig- Holstein"
"Hamburg"
"Lower Saxony"
"Bremen"
"North Rhine- Westpalia"
"Hesse"
"Rhineland- Palatinate"
"Baden- Württemberg"
"Bavaria"
"Saarland"
"Berlin"
"Brandenburg"
"Mecklenburg-Western Pomerania"
"Saxony"
"Saxony- Anhalt"
"Thuringia" 

keep Y_centroid X_centroid bula Bula_merge Bula_merge_String

* Change Label to multiple lines
clonevar reglabel = Bula_merge_String
split reglabel if length(reglabel) > 16
replace reglabel1 = reglabel if missing(reglabel1)

* Manually change label for North Rhine - Westpalia
replace reglabel1 = "North Rhine" if Bula_merge_String == "North Rhine- Westpalia"
replace reglabel2 = "Westpalia" if Bula_merge_String == "North Rhine- Westpalia"
replace reglabel3 = "" if Bula_merge_String == "North Rhine- Westpalia"

drop reglabel
reshape long reglabel, i(Y_centroid X_centroid bula Bula_merge Bula_merge_String) j(num)
drop if missing(reglabel)

*generate label1 = string(mig_stock, "%12.3f")
*gen label2 = Bula_merge_String + "," + " " + "P=" + label1 
*gen label = Bula_merge_String1 + " " + Bula_merge_String2

* label change  for aestetics 
replace Y_centroid = 5968445 if Bula_merge_String == "Hamburg" 
replace Y_centroid = 5905611 if Bula_merge_String == "Bremen" 
replace Y_centroid = 5855000 if Bula_merge_String == "Brandenburg" 
replace X_centroid = 3700000 if Bula_merge_String == "Bavaria"

** Save Labels
save "$COORDS\BL_Labels_Long.dta", replace

*** *** Actual Maps *** ***
*** Cohorts 1944 - 1986 ***
use "$COORDS\BL_Database_4486.dta", clear

 recode Bula_merge  (1 = 15)  (2 = 6) (3 = 9) (4 = 5) (5 = 10) (6 = 7) (7 = 11) (8 = 1) (9 = 2) (10 = 12) (11 = 3) (12 = 4) (13= 8) (14 = 13) (15 = 14) (16 = 16), gen(Bula_Original) // Actual Original

spmap mig_stock using BL_COORD, id(Bula_Original) fcolor(Blues) clm(custom) clbreaks(.0 0.15 .20 0.25 0.30 0.35 .40 0.45 .5 0.55) label(data(BL_Labels_Short) xcoord(X_centroid) ycoord(Y_centroid) label(label) size(*0.60 ..) pos(0 6) length(100)) title("1944-1986", size(medsmall)) saving(Map_Y4486.gph, replace) legtitle(" ") // De-Comment for Label_Short! // fcolor(Blues)


*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
*** *** Causal Cohort 1945- 1964 *** ***
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

*Load final data set (Must include Kreise and Bula)
use "$results\0_basicpanel_final.dta", clear

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
	*collapse (mean) `var', by (bula)
	collapse (mean) `var' [aweight = w_t4_cal], by (bl_birth)
	rename bl_birth bula
	save "$results\temp\graph_mean_`var'_bula_4564.dta", replace
	restore
	
}

*combine all migs to one dataset
use "$results\temp\graph_mean_mig_stock_bula_4564.dta", clear
foreach var in mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
 merge 1:1 bula using "$results\temp\graph_mean_`var'_bula_4564.dta"
 drop _merge
 *replace `var' = 0 if `var' == .
 erase "$results\temp\graph_mean_`var'_bula_4564.dta"
}

*Drop Ausland and create Merge_Variable
drop if bula == 0
drop if bula == 99
clonevar Bula_merge = bula 

*save final data set
save "$results\temp\graph_mean_mig_bula_4564.dta", replace
*use "$results\temp\graph_mean_mig_bula_4564.dta", clear

************************************************
*** Part ii): Data Preparation (Coordinates and Labels) for the Data-Visualization ***
************************************************
*** *** Cohorts 1944 - 1986 *** ***
*** create .dta with coordinates. We then need a variable to merge coordinates with dataset of migration
** three steps: i) transform shape-files into datasets and coordinates. ii) enrich data-set of bulas (With Coords) with data created above (e.g. percentage of individuals migrating) iii) merge all files to use as a proper visualization
cd "$COORDS\"
shp2dta using NUTS5000_N1, database(BL_Database) coordinates(BL_COORD) genid(Bula_merge) replace
* You need to modify your .dta dataset to use the same location coding as that used in the map. Call that variable id
* Merge on id the translated .dbf

*merge with geo-files
use "$COORDS\BL_Database.dta", clear
recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
merge 1:1 Bula_merge using "$results\temp\graph_mean_mig_bula_4564.dta"
drop _merge
save "$COORDS\BL_Database_4564.dta", replace

*** *** Cohorts 1944 - 1986 *** ***
*** create .dta with coordinates. We then need a variable to merge coordinates with dataset of migration
** three steps: i) transform shape-files into datasets and coordinates. ii) enrich data-set of bulas with data created above (e.g. percentage of individuals migrating) iii) merge all files to use as a proper visualization
cd "$COORDS\"
shp2dta using NUTS5000_N1, database(BL_Database) coordinates(BL_COORD) genid(Bula_merge) replace
* You need to modify your .dta dataset to use the same location coding as that used in the map. Call that variable id
* Merge on id the translated .dbf
* We need to use Bula_Original as the order of Display is fixed in the "Bl_Coord-File"

************************************************
*** Prepare Labels
************************************************
use "BL_COORD.dta", clear
bysort _ID: egen X_centroid = mean(_X)
bysort _ID: egen Y_centroid = mean(_Y)
duplicates drop _ID, force
clonevar Bula_merge = _ID
recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
drop _ID _X _Y
save "$COORDS\BL_Centroids.dta", replace

** Merge with data on Migration
use "$COORDS\BL_Database_4564.dta", clear
joinby Bula_merge using "$COORDS\BL_Centroids.dta"

input str3 Bula_merge_String
"SH"
"HH"
"NS"
"HB"
"NRW"
"HE"
"RPF"
"BW"
"BY"
"SL"
"BER"
"BB"
"MVP"
"SN"
"ST"
"TH" 


generate label1 = string(mig_stock, "%12.3f")
gen label = Bula_merge_String + "," + " " + label1 
* gen label2 = Bula_merge_String

* label change  for aestetics 
replace Y_centroid = 5968445 if Bula_merge_String == "HH" 
replace Y_centroid = 5905611 if Bula_merge_String == "HB" 
replace Y_centroid = 5855000 if Bula_merge_String == "BB" 
replace Y_centroid = 5805000 if Bula_merge_String == "BER" 
replace X_centroid = 3700000 if Bula_merge_String == "BY"

** Save Labels
save "$COORDS\BL_Labels_Short.dta", replace

** Merge with data on Migration
use "$COORDS\BL_Database_4564.dta", clear
joinby Bula_merge using "$COORDS\BL_Centroids.dta"

input str50 Bula_merge_String
"Schleswig- Holstein"
"Hamburg"
"Lower Saxony"
"Bremen"
"North Rhine- Westpalia"
"Hesse"
"Rhineland- Palatinate"
"Baden- Württemberg"
"Bavaria"
"Saarland"
"Berlin"
"Brandenburg"
"Mecklenburg-Western Pomerania"
"Saxony"
"Saxony- Anhalt"
"Thuringia" 

keep Y_centroid X_centroid bula Bula_merge Bula_merge_String

* Change Label to multiple lines
clonevar reglabel = Bula_merge_String
split reglabel if length(reglabel) > 16
replace reglabel1 = reglabel if missing(reglabel1)

* Manually change label for North Rhine - Westpalia
replace reglabel1 = "North Rhine" if Bula_merge_String == "North Rhine- Westpalia"
replace reglabel2 = "Westpalia" if Bula_merge_String == "North Rhine- Westpalia"
replace reglabel3 = "" if Bula_merge_String == "North Rhine- Westpalia"

drop reglabel
reshape long reglabel, i(Y_centroid X_centroid bula Bula_merge Bula_merge_String) j(num)
drop if missing(reglabel)

*generate label1 = string(mig_stock, "%12.3f")
*gen label2 = Bula_merge_String + "," + " " + "P=" + label1 
*gen label = Bula_merge_String1 + " " + Bula_merge_String2

* label change  for aestetics 
replace Y_centroid = 5968445 if Bula_merge_String == "Hamburg" 
replace Y_centroid = 5905611 if Bula_merge_String == "Bremen" 
replace Y_centroid = 5855000 if Bula_merge_String == "Brandenburg" 
replace X_centroid = 3700000 if Bula_merge_String == "Bavaria"

** Save Labels
save "$COORDS\BL_Labels_Long.dta", replace

*** *** Actual Maps *** ***
*** Cohorts 1945 - 1964 ***
use "$COORDS\BL_Database_4564.dta", clear
recode Bula_merge (8 = 1) (9 = 2) (11 = 3) (12 = 4) (4 = 5) (2 = 6) (6 = 7) (13= 8) (3 = 9) (5 = 10) (7 = 11) (10 = 12) (14 = 13) (15 = 14) (1 = 15) (16 = 16), gen(Bula_Original)

spmap mig_stock using BL_COORD, id(Bula_Original) fcolor(Blues) clm(custom) clbreaks(.0 0.15 .20 0.25 0.30 0.35 .40 0.45 .50 0.55) label(data(BL_Labels_Short) xcoord(X_centroid) ycoord(Y_centroid) label(label) size(*0.60 ..) pos(0 6) length(100)) title("1945-1964", size(medsmall)) saving(Map_Y4564.gph, replace) legtitle(" ") // De-Comment for Label_Short ) 


*** *** *** ***  Finally: Graph Combine *** *** *** ***
******************************************************************
* Combine Needed Cohorts 
* Cohorts 1944- 86 und 1945 - 1964
******************************************************************
grc1leg2 Map_Y4564.gph Map_Y4486.gph, saving("Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\graphs\Map_Combined_Label_UTILIZED_1", replace) scheme(s1color) pos(4)  //  pos(1) 
graph export "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\graphs\Map_Combined_Label_UTILIZED_1.pdf", as(pdf) name("Graph") replace



******************************************************************
* Same for mig_stock_kr
******************************************************************
******************************************************************
* Cohorts 1944 - 86 
******************************************************************
************************************************
*** Prepare Labels
************************************************
use "BL_COORD.dta", clear
bysort _ID: egen X_centroid = mean(_X)
bysort _ID: egen Y_centroid = mean(_Y)
duplicates drop _ID, force
clonevar Bula_merge = _ID
recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
drop _ID _X _Y
save "$COORDS\BL_Centroids.dta", replace

** Merge with data on Migration
use "$COORDS\BL_Database_4486.dta", clear
joinby Bula_merge using "$COORDS\BL_Centroids.dta"

input str3 Bula_merge_String
"SH"
"HH"
"NS"
"HB"
"NRW"
"HE"
"RPF"
"BW"
"BY"
"SL"
"BER"
"BB"
"MVP"
"SN"
"ST"
"TH" 


generate label1 = string(mig_stock_kr, "%12.3f")
gen label = Bula_merge_String + "," + " " + label1 
* gen label2 = Bula_merge_String

* label change  for aestetics 
replace Y_centroid = 5968445 if Bula_merge_String == "HH" 
replace Y_centroid = 5905611 if Bula_merge_String == "HB" 
replace Y_centroid = 5855000 if Bula_merge_String == "BB" 
replace Y_centroid = 5805000 if Bula_merge_String == "BER" 
replace X_centroid = 3700000 if Bula_merge_String == "BY"

** Save Labels
save "$COORDS\BL_Labels_Short.dta", replace

*** Do Map ***
use "$COORDS\BL_Database_4486.dta", clear
recode Bula_merge (8 = 1) (9 = 2) (11 = 3) (12 = 4) (4 = 5) (2 = 6) (6 = 7) (13= 8) (3 = 9) (5 = 10) (7 = 11) (10 = 12) (14 = 13) (15 = 14) (1 = 15) (16 = 16), gen(Bula_Original)

spmap mig_stock_kr using BL_COORD, id(Bula_Original) fcolor(Blues) clm(custom) clbreaks(.0 0.35 0.4 0.45 0.5 0.55 0.6 0.7) label(data(BL_Labels_Short) xcoord(X_centroid) ycoord(Y_centroid) label(label) size(*0.60 ..) pos(0 6) length(100)) title("1944-1986", size(medsmall)) saving(Map_Y4486_kr.gph, replace) legtitle(" ") // De-Comment for Label_Short

******************************************************************
* Cohorts 1945 - 1964
******************************************************************
************************************************
*** Prepare Labels
************************************************
use "BL_COORD.dta", clear
bysort _ID: egen X_centroid = mean(_X)
bysort _ID: egen Y_centroid = mean(_Y)
duplicates drop _ID, force
clonevar Bula_merge = _ID
recode Bula_merge (1 = 8) (2 = 9) (3 = 11) (4 = 12) (5 = 4) (6 = 2) (7 = 6) (8 = 13) (9 = 3) (10 = 5) (11 = 7) (12 = 10) (13 = 14) (14 = 15) (15 = 1) (16 = 16)  // checked- Passt
drop _ID _X _Y
save "$COORDS\BL_Centroids.dta", replace

** Merge with data on Migration
use "$COORDS\BL_Database_4564.dta", clear
joinby Bula_merge using "$COORDS\BL_Centroids.dta"

input str3 Bula_merge_String
"SH"
"HH"
"NS"
"HB"
"NRW"
"HE"
"RPF"
"BW"
"BY"
"SL"
"BER"
"BB"
"MVP"
"SN"
"ST"
"TH" 


generate label1 = string(mig_stock_kr, "%12.3f")
gen label = Bula_merge_String + "," + " " + label1 
* gen label2 = Bula_merge_String

* label change  for aestetics 
replace Y_centroid = 5968445 if Bula_merge_String == "HH" 
replace Y_centroid = 5905611 if Bula_merge_String == "HB" 
replace Y_centroid = 5855000 if Bula_merge_String == "BB" 
replace Y_centroid = 5805000 if Bula_merge_String == "BER" 
replace X_centroid = 3700000 if Bula_merge_String == "BY"

** Save Labels
save "$COORDS\BL_Labels_Short.dta", replace

use "$COORDS\BL_Database_4564.dta", clear
recode Bula_merge (8 = 1) (9 = 2) (11 = 3) (12 = 4) (4 = 5) (2 = 6) (6 = 7) (13= 8) (3 = 9) (5 = 10) (7 = 11) (10 = 12) (14 = 13) (15 = 14) (1 = 15) (16 = 16), gen(Bula_Original)

spmap mig_stock_kr using BL_COORD, id(Bula_Original) fcolor(Blues) clm(custom) clbreaks(.0 0.35 0.4 0.45 0.5 0.55 0.6 0.7 1) label(data(BL_Labels_Long) xcoord(X_centroid) ycoord(Y_centroid) label(reglabel) by(num) size(*0.60 ..) pos(0 6) length(100)) title("1945-1964", size(medsmall)) saving(Map_Y4564_kr.gph, replace) legtitle(" ") // legend(off) 


*** *** *** ***  Finally: Graph Combine *** *** *** ***
******************************************************************
* Combine Needed Cohorts 
* Cohorts 1944- 86 und 1945 - 1964
******************************************************************
grc1leg2 Map_Y4564_kr.gph Map_Y4486_kr.gph, saving("Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\graphs\Map_Combined_Label_UTILIZED_kr", replace) scheme(s1color) pos(4)  //  pos(1) 
graph export "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\graphs\Map_Combined_Label_UTILIZED_kr.pdf", as(pdf) name("Graph") replace

