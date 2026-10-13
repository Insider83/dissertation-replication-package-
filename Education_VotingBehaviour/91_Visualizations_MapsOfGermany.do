/**************************************************
   This Fill Will Create All Visualizations of School Closures and Numbers and project them on a Map of Germany
   
	
	Author: Sebastian Vogler
	
	Version: 2.0, Created: 2023-01-18	
***************************************************/
*** Install Packages *** 
* ssc install spmap
* ssc install shp2dta
* ssc install mif2dta

********************************************************************************
* Produce Graph for number of School Closures on Map of Germany
********************************************************************************
********************************************************************************
* i) Prepare Shape Files (Shape order and Coordinates)
********************************************************************************
*Create Coordinates from the SHAPE-Files
*.shp: contains the coordinates for the vector layer (e.g. boundaries of countries)
*.dbf: contains the attributes and variabes of each map element (e.g. population or GDP of each country)

cd "E:\Dokumente\School-Closing\Auxiliary Data\Shape-Files\2022\vg250_01-01.gk3.shape.ebenen\vg250_ebenen_0101" //necessary step!
shp2dta using VG250_GEM, database(Gemeinden_Database) coordinates(Gemeinden_Coord) genid(_ID) replace

********************************************************************************
* ii)  Merge _ID with the AGS of My Main Panel Of Interest so I can actually Plot Data
********************************************************************************
use  "$results\Panel\ClosureAndOpenMunicipality_Descriptives.dta", clear // From 11_PrepareSchoolCLosuresToPanel.do
bysort AGS2020: keep if _n == 1
rename AGS2020 AGS // Necessary for merge

*** Joinby with shape-file  created above 
joinby AGS using Gemeinden_Database.dta, unmatched(both) 
drop if _merge == 1
drop _merge

*** Gen Dummy No School in Municipality ***
recode NumberSchools NumberSchools_ES NumberSchools_SS NumberSchools_GYM NumberClosures NumberClosures_ES NumberClosures_SS NumberClosures_GYM (. = -1)

foreach var in  NumberSchools NumberSchools_ES NumberSchools_SS NumberSchools_GYM  NumberClosures NumberClosures_ES NumberClosures_SS NumberClosures_GYM  { // NumberClosures_
   count if missing(`var')
}


********************************************************************************
* iii) Number of Schools per Municipality
********************************************************************************
*** All Schools
sum NumberSchools, d //  min -1 max 441
spmap NumberSchools using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom)  clbreaks(-1 0 5 10 20 30 40 50 100 500) mosize(vvthin) 
graph export "$results\Visualisierungen\GermanMapTotalSchools.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalSchools.gph", replace

*** Elementary Schools 
sum NumberSchools_ES, d // min -1 max 229 
spmap NumberSchools_ES using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom)  clbreaks(-1 0 5 10 20 50 100 500) mosize(vvthin) 
graph export "$results\Visualisierungen\GermanMapTotalSchools_ES.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalSchools_ES.gph", replace

*** Secondary Schools 
sum NumberSchools_SS, d // min -1 max  96 
spmap NumberSchools_SS using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom)  clbreaks(-1 0 5 10 20 50 100 500) mosize(vvthin) 
graph export "$results\Visualisierungen\GermanMapTotalSchools_SS.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalSchools_SS.gph", replace

*** Gymnasiums 
sum NumberSchools_GYM, d //  min -1 max 116
spmap NumberSchools_GYM using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom)  clbreaks(-1 0 5 10 20 50 100 500) mosize(vvthin) 
graph export "$results\Visualisierungen\GermanMapTotalSchools_GYM.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalSchools_GYM.gph", replace


********************************************************************************
* iii) Number of School Closures per Municipality
********************************************************************************
*** All Schools
sum NumberClosures, d //  min -1 max 441
spmap NumberClosures using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom) clbreaks(-1 0 1 2 3 4 5 6 7 8 9 15) mosize(vvthin) 
graph export "$results\Visualisierungen\GermanMapTotalClosures.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalClosures.gph", replace

*** Elementary Schools 
sum  NumberClosures_ES , d // min -1 max 229 
spmap NumberClosures_ES using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom) clbreaks(-1 0 1 2 3 4 5 6 7 8 9 15) mosize(vvthin) 
graph export "$results\Visualisierungen\GermanMapTotalClosures_ES.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalClosures_ES.gph", replace

*** Secondary Schools 
sum NumberClosures_SS, d // min -1 max  96 
spmap NumberClosures_SS using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom) clbreaks(-1 0 1 2 3 4 5 6 7 8 9 15) mosize(vvthin) 
graph export "$results\Visualisierungen\GermanMapTotalClosures_SS.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalClosures_SS.gph", replace

*** Gymnasiums 
sum NumberClosures_GYM, d //  min -1 max 116
spmap NumberClosures_GYM using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom) clbreaks(-1 0 1 2 3 4 5 6 7 8 9 15) mosize(vvthin) 
graph export "$results\Visualisierungen\GermanMapTotalClosures_GYM.pdf", as(pdf) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalClosures_GYM.gph", replace


*** Combine German Map Of Closure And Schools
graph combine "$results\Visualisierungen\GermanMapTotalSchools.gph"	"$results\Visualisierungen\GermanMapTotalClosures.gph"  // ycommon col(1)
graph export "$results\Visualisierungen\CombinedGermanMapClosureNumber.png",  as(png) replace

********************************************************************************
* iV) Number of School (Closures) per Municipality PER CAPITA
********************************************************************************
*** Merge With Infos on Population *** 
gen Year = 2000
gen AGS2020 = AGS
count
joinby AGS2020 Year using "$master\Daten Schulschließung Marcel\SchoolClosureFinal.dta", unmatched(Master) 
count

* Gen School Per Capita
gen NumberSchoolPerCap = NumberSchools/Population if NumberSchools != -1 // -1 == No School!
replace NumberSchoolPerCap = -1 if NumberSchools == -1
* Gen School Closure Per Capita
gen NumberClosuresPerCap = NumberClosures/Population if NumberSchools != -1 // -1 == No School!
replace NumberClosuresPerCap = -1 if NumberSchools == -1
* Quality
sum NumberSchoolPerCap NumberClosuresPerCap
br if NumberSchoolPerCap == -1 & NumberClosuresPerCap != -1

*** Numbers Per Capita ***
sum NumberSchoolPerCap if NumberSchools != -1, d //  min .00004 max .3333333 [Hallig in the North with 7 Inhabitants]
spmap NumberSchoolPerCap using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom) clbreaks(-1 0 0.00025 0.0005 0.00075 0.001 0.00125 0.0015 0.00175 0.002 01) mosize(vvvthin) // title("Total Numbers of School Closures" "in Germany by Municipality since 2000") caption("Note: Total Numbers of Schools In Germany by Municipality between 2000 and 2019. These Numbers also Include Closed Schools." "Data has been provided by all State Ministries of Education from all German States.", size(tiny)) 
graph export "$results\Visualisierungen\GermanMapTotalNumbersPerCapita.jpg", as(jpg) name("Graph") quality(100) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalNumbersPerCapita.gph", replace

*** Closures Per Capita ***
sum NumberClosuresPerCap if NumberSchools != -1, d //  min 0 max .3333333 
spmap NumberClosuresPerCap using Gemeinden_Coord, id(_ID) fcolor(Rainbow) legend(position(11)) clm(custom) clbreaks(-1 0 0.00015 0.0003 0.00045 0.0006 0.00075 0.00090 0.0015 01) mosize(vvvthin) // title("Total Numbers of School Closures" "in Germany by Municipality since 2000") caption("Note: Total Numbers of Schools In Germany by Municipality between 2000 and 2019. These Numbers also Include Closed Schools." "Data has been provided by all State Ministries of Education from all German States.", size(tiny)) 
graph export "$results\Visualisierungen\GermanMapTotalClosuresPerCapita.jpg", as(jpg) name("Graph") quality(100) replace
graph save "Graph" "$results\Visualisierungen\GermanMapTotalClosuresPerCapita.gph", replace

*** Graph Combine Map Of Closure And Schools Per Capita ***
graph combine "$results\Visualisierungen\GermanMapTotalNumbersPerCapita.gph" "$results\Visualisierungen\GermanMapTotalClosuresPerCapita.gph"  // ycommon col(1)
graph export "$results\Visualisierungen\CombinedGermanMapClosureNumberPerCapita.png",  as(png) replace
