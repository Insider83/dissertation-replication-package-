* Davit Adunts, Truc Nguyen, Sebastian Vogler
*********************



            **************************
			* Cleaning - IAB
            **************************

			
/* Clean once, drop unneccessary to have smaller sample
--------------------------------------------------------


use "$data/...",clear

* Individual id, year, spell
clonevar pid= prs_id 

* Generate month-year variable 
gen  month = month(ieb_beg_orig) 
gen  year = year(ieb_beg_orig) 
*gen  month_year = year + (month/100)

order pid year
label var year "Year"

* gender
clonevar sex=sex_id
replace sex=. if sex>2
gen male = (sex==1) if sex!=.
lab var male "Male"

* Birth month/year
gen birth_y= year(geb_dat_ano)
gen birth_m= month(geb_dat_ano)
	
lab var birth_y "Year of birth"
lab var birth_m "Month of birth"

gen age= year - birth_y

* Temp sample restriction
keep if year>=2010 //2012
drop if age>50
drop if sex==.

save "$file/temp_ieb",replace
----------------------------------------------------------------------------*/


                     *** Merge final sample ***

use "$file/temp_ieb",clear
merge m:1 pid using "$file/arrival_clean"

bys _merge: tab arr_year,m
keep if _merge==3
drop _merge

save "$file/merged",replace

*----------------------------------------------------------------------------

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	SIAB Preparation
	
	Split episodes that span over one year (only relevant for the sources LeH and LHG)
	
	Modifies the variables:
		- ieb_beg_orig: splitted version of ieb_beg_orig
		- endepi: splitted version of endepi
		- jahr: year
		- age: age, measured in years
		
	Generates the variables:
		- begepi_orig: original version of ieb_beg_orig
		- endepi_orig: original version of endepi
	
	Note: This do-file splits only the variables listed above. Other variables,  
	such as alo_beg and alo_dau are not split!
	
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

********************************************************************************
* Save original begin and end date of episodes
********************************************************************************

use "$file/merged",clear


*clonevar spell= ieb_konto_zeile
bysort pid: gen spell = _n

order pid spell

gen int begepi = ieb_beg_orig
gen int endepi = ieb_end_orig


label var ieb_beg_orig "Episode start date; episodes might be > 1 year"
label var ieb_end_orig "Episode end date; episodes might be > 1 year"

format begepi endepi %td

********************************************************************************
* Number of calendar years one spell spans over
********************************************************************************

gen byte span_year = year(endepi) - year(begepi) + 1
label var span_year "Number of years spanned by the spell"

********************************************************************************
* n-plicate observations that span over n>1 calendar years
********************************************************************************
expand span_year, gen(is_clone)


********************************************************************************
* Cut the original spell at end of year
********************************************************************************
replace endepi = mdy(12, 31, year(begepi)) if span_year > 1 & is_clone == 0


********************************************************************************
* Set the begin date of all clones to January 1st and increase the year
********************************************************************************
bysort pid spell (is_clone): replace begepi = mdy(1, 1, year(begepi[_n-1]) + 1) if is_clone == 1


********************************************************************************
* For all clone spell except the last of the clone group: set the end date to 31.12. 
********************************************************************************
by pid spell (is_clone): replace endepi = mdy(12, 31, year(endepi[_n-1]) + 1) if is_clone == 1 & _n < _N


********************************************************************************
* Update the variables 'jahr' and age
********************************************************************************
replace year = year(begepi)
replace age = year - birth_y
lab var age "Age"

********************************************************************************
* Clean up
********************************************************************************
drop is_clone span_year



* Tech Merkmal
clonevar quelle= ieb_quellverf_id
	

* Citizenship
clonevar citizenship_ba= ieb_staat_num
replace citizenship_ba=. if citizenship_ba>900 | citizenship_ba<0
lab var citizenship_ba "Citizenship"

sort pid citizenship_ba
bys pid: egen cit_ba_1= max(citizenship_ba)

gen cit_ba_2= citizenship_ba-cit_ba_1
replace cit_ba_2= 0 if citizenship_ba==0
replace cit_ba_2= citizenship_ba if cit_ba_2!=0 & citizenship_ba!=0
replace cit_ba_2=1 if cit_ba_2!=0 & cit_ba_2!=.
tab cit_ba_2,m
lab var cit_ba_2 "Having 2nd non-German citizenship"

clonevar wo_kreis= b_krs_schl_wo_akt_num //district
replace wo_kreis=. if wo_kreis<0 | wo_kreis==20000

gen state= int(wo_kreis/1000) //NA in data report, but available in data
lab var state "State"
    
	#delimit;

    label define state
        1 "1-Schleswig-Holstein" 
        2 "2-Hamburg" 
        3 "3-Niedersachsen" 
        4 "4-Bremen"
        5 "5-Nordrhein-Westfalen" 
        6 "6-Hessen" 
        7 "7-Rheinlandpfalz" 
        8 "8-Baden-Württemberg" 
        9 "9-Bayern"
        10 "10-Saarland"
        11 "11-Berlin"
        12 "12-Brandenburg"
        13 "13-Mecklenburg-Vorpommern"
        14 "14-Sachsen" 
        15 "15-Sachsen-Anhalt" 
        16 "16-Thüringen"; 
    
    #delimit cr

    label values state state

/* Education cleaning:
	isb_id: detailed school qualification, not available for LeH and LGH (unemployed)
	ieb_dba_id: not available for LeH and LGH (unemployed), 


*/
// Hauptschulabschluss: 9.
* Mittlerer Bildungsabschluss: 10.
clonevar school_des=isb_id //Hauptschulabschluss: https://web.arbeitsagentur.de/berufenet/bba/bildungssystem/schulabschluesse/hauptschulabschluss
replace school_des=. if school_des>=9990


* Educ qualification
clonevar educ_des=ieb_dba_id
replace educ_des=. if educ_des>=999
	
//no educ
gen educ_qua= (educ_des!=1) if educ_des!=.
lab var educ_qua "Recently completed education and training"

* Labor market status detailed // important to check for detailed, Azubi etc.
clonevar emp_status_des=ieb_erw_stat 
lab var emp_status_des "Employment status detail"
replace emp_status_des=. if ieb_erw_stat> 99000

* Currently doing ausbildung
gen ausbildung= inlist(emp_status_des,102,121,122,141,144) if emp_status_des!=.
lab var ausbildung "Currently in VET"

* employment status
clonevar emp_status= berufstellg_imp
replace emp_status=. if emp_status<0
lab var emp_status "Employment status"

*bys pid month_year: egen emp_max= max(emp_status)
	
gen employed_full= inlist(emp_status,20) if emp_status!=.
replace employed_full=0 if employed_full==. & emp_status_des!=.
lab var employed_full "Being employed full-time"


gen employed_part= inlist(emp_status,21) if emp_status!=.
replace employed_part=0 if employed_part==. & emp_status_des!=.
lab var employed_part "Being employed part-time"


* Being employed
gen employed=.
replace employed= 1 if emp_status!=.
replace employed= 0 if employed==. & emp_status_des!=.
lab var employed "Being employed"
 
* Daily salary
clonevar entgelt= ieb_tag_entg
lab var entgelt "Daily salary(euro)"

* Drop missing pid
drop if pid==.
drop if year==.

sort pid year


*keep in 1/500
save "$file/test",replace


********************************************************************************
********************************************************************************
*
*    _                               _             _     _                 
*   (_)                             | |           | |   (_)                
*    _   _ __ ___    _ __    _   _  | |_    __ _  | |_   _    ___    _ __  
*   | | | '_ ` _ \  | '_ \  | | | | | __|  / _` | | __| | |  / _ \  | '_ \ 
*   | | | | | | | | | |_) | | |_| | | |_  | (_| | | |_  | | | (_) | | | | |
*   |_| |_| |_| |_| | .__/   \__,_|  \__|  \__,_|  \__| |_|  \___/  |_| |_|
*                   | |                                                    
*                   |_|                                                    
*
********************************************************************************
********************************************************************************


* Imputation/Cleanup: Education
********************************************************************************

* following Chapter 3.2 Imputation Procedure 1 in Fitzenberger et al. (2006)
* http://www.empiwifo.uni-freiburg.de/discussion-papers/fitzenberger/fitzen_osik_voel_revision2.pdf 



    * Berechnung des Geburtsjahres (mbl: needed for variable degree) 
    ****************************************************************************
		*drop age
	    *gen age =  (begepi - geb_dat)/365
		*replace age = int(age)
		

* Replace missing values for education qualifications. Later year is highest for previous years

	//impute forward
	sort pid year quelle begepi //prioritize BeH
            
	#delimit;
		by pid: replace school_des = school_des[_n-1]
		if ( school_des==. | school_des<school_des[_n-1] ) & school_des[_n-1]!=.;
	#delimit cr //13,063,845 obs

	
	// impute backward - do not do for school of refugees
		
	gsort pid -year quelle -begepi //prioritize BeH
            
	#delimit;
		by pid: replace school_des = 1
		if ( school_des==.) & school_des[_n-1]==1;
	#delimit cr //1,505,219

    egen school_des_max = max(school_des), by(pid begepi)
    replace school_des = school_des_max
    drop school_des_max	
	
	
	// Hauptschulabschluss: 9.
	gen haupt_cer= (school_des!=1) if school_des!=.
	lab var haupt_cer "With at least secondary (Hauptschulabschluss) certficate"

	// Mittlerer Abschluss: 10
	gen mittler_cer= (school_des>=6) if school_des!=.
	lab var mittler_cer "With at least intermediate certficate"

	
********************************************************************************
* Generate information of possibly parallel UI benefits (parallel_benefits)
********************************************************************************
gen tmp_benefits = inlist(quelle,2)		// indicator for recipience of UI benefits
bys pid begepi: egen parallel_benefits = max(tmp_benefits)		// attach indicator for recipience of UI benefits to all parallel episodes
label variable parallel_benefits "Total UI benefits per episode" 

drop tmp_benefits

br pid year *benefit* quelle 


	gen beg_m_epi= month(ieb_beg_orig)
	gen beg_y_epi= year(ieb_beg_orig)


********************************************************************************
********************************************************************************
* Handling and deletion episodes
*
*                   _                     _              
*                  (_)                   | |             
*     ___   _ __    _   ___    ___     __| |   ___   ___ 
*    / _ \ | '_ \  | | / __|  / _ \   / _` |  / _ \ / __|
*   |  __/ | |_) | | | \__ \ | (_) | | (_| | |  __/ \__ \
*    \___| | .__/  |_| |___/  \___/   \__,_|  \___| |___/
*          | |                                           
*          |_|                                                      
*             
********************************************************************************
********************************************************************************

   * Eliminate parallel spells
    ****************************************************************************

    * 1. quelle: Behalte dominierenden Erwerbszustand: Hierzu Annahme: BeH (1)
    * dominiert LeH (2) dominiert LHG (4) dominiert ASU (8).

    * 2. erw_az: perfer vz over tz_2 over tz_1

    * 3. -spell_dur = endepi - begepi
    
    * 4. entgelt_nonmis: prefer nonmisisng values if possible (however, entgelt
    * seems to be never missing for quelle==1 spells)

    * 5. -entgelt: Behalte von parallelen Spells aus einer Quelle diejenige mit
    * dem höchsten Entgelt.

        gen erw_az = .

        label var erw_az "Erwerbsstatus nach Arbeitszeit"

            replace erw_az = 1 if emp_status == 20
            replace erw_az = 2 if emp_status == 21
            *replace erw_az = 3 if ( erwstat == 1 | erwstat == 3 ) & stib==9	
	
    * Create Dummys	
        gen vz   = ( erw_az == 1 ) if !missing(erw_az)
        gen tz_1 = ( erw_az == 2 ) if !missing(erw_az)
        *gen tz_2 = ( erw_az == 3 ) if !missing(erw_az)
		
		
        gen erw_az_prio = erw_az
        *recode erw_az_prio 2=3 3=2

        gen spell_dur = endepi- begepi 

        gen entgelt_prio = entgelt
        recode entgelt_prio .=-1

        gsort pid year quelle erw_az_prio -spell_dur -entgelt_prio // sort by year, longest duration spell
		
        by pid year: gen level = _n

		
        drop if level > 1

        drop entgelt_prio level //spell_dur
	
drop if year>=	2024

********************************************************************************
* Aggregate (employment) outcomes: days employed, labor earnings, days benefits
********************************************************************************

*Durations of episodes
sort pid year begepi endepi quelle
by pid year begepi endepi: gen dur_emp = endepi-begepi + 1 if quelle == 1
by pid year begepi endepi: gen dur_benefits = endepi-begepi + 1 if inlist(quelle,2,4) //| parallel_benefits == 1

*Total time working, total time receiving UI benefits
by pid year: egen year_days_emp=total(dur_emp)
by pid year: egen year_days_benefits=total(dur_benefits)

lab var year_days_emp "Total days employed per calendar year"
lab var year_days_benefits "Total days benefit recipience per calendar year"

	
save "$file/merged_1",replace



