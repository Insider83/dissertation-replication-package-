* * Davit Adunts, Truc Nguyen, Sebastian Vogler
*********************

clear 
set more off 
clear matrix
clear mata
set maxvar 11000


use "$data/...", clear

            **************************
			* Cleaning - SHZ
            **************************			
			

* Individual info
clonevar pid= prs_id


* time frame - 2005 till 2023
clonevar beg_shz= shz_beg_dat
gen year= year(beg_shz)

*keep if inlist(year, 2015, 2016)
clonevar end_shz= shz_end_dat


* Refugee - residence status: flught
clonevar refugee= jan_id_flucht
replace refugee=. if refugee>=9990 //9997 includes those did not submit applications

clonevar re_status= bad_id
tab re_status
lab var re_status "Residence status"


* asylum application submit
clonevar asyl_app= asyl_antrag_dat
lab var asyl_app "Asylum application date"

	
* Date of entry of applicants with special legal status (asylum seekers)
// asylum application reply - only available after 2017
clonevar asyl_reply= asyl_bescheid_dat


// arrival status - many missing
clonevar arr_status= sta_id
replace arr_status=. if arr_status==9997
lab var arr_status "Arrival status"



* Migration back ground - many missing, only available from July 2020 onward in SHZ and SHZ_XSoz.
clonevar migback= mgk_id //many missing
*keep if inlist(migback,3,4,5) //with own migration experience

* citizenship - can change overtime
clonevar citizenship_shz= stt_ba_schl_num
replace citizenship_shz=. if citizenship_shz<0 | citizenship_shz>900
lab var citizenship_shz "Citizenship"

bys pid: egen x_max= max(citizenship_shz)
replace citizenship_shz= x_max if citizenship_shz==0 & x_max!=0 //133,337 obs
drop x_max

* Third-country citizenship
clonevar citizen_for=jan_id_drittstaat
lab var citizen_for "Third country citizenship"
	
* Work permit in Germany
clonevar work_permit= vae_id
replace work_permit= 1 if inrange(work_permit,1,4)
replace work_permit= 0 if inrange(work_permit,6,8)
replace work_permit=. if work_permit==9997
lab var work_permit "Work permit"
	
clonevar work_limit= vob_id
replace work_limit= 0 if work_limit==1
replace work_limit=1 if inrange(work_limit,2,4)
replace work_limit=. if work_limit==97
lab var work_limit "Work limit"

* Generate month-year variable 
gen  shz_beg_month = month(shz_beg_dat)
gen  shz_beg_year = year(shz_beg_dat) 
gen  var_month_year = shz_beg_year + (shz_beg_month/100)

* Tabulate 
*mdesc var_month_year

* Drop missing pid
drop if pid==. | var_month_year==.


* Arrival time
clonevar arrival=bewa_einreise_dat

// Replace arrival date the same for each person
gen yr = mofd(arrival)
bys pid: egen x_min= min(yr)
bys pid: egen x_max= max(yr)
gen x_diff= x_min - x_max
tab x_diff,m

bys pid: egen arrival_min= min(arrival)
replace arrival= arrival_min if arrival==. & x_diff==0

*drop x_* *_max

* Arrival year and month

gen arr_month= month(arrival)
lab var arr_month "Month of arrival"

gen arr_year= year(arrival)
lab var arr_year "Year of arrival"

* re-order
order pid year beg_shz end_shz arr*


* keep only one arrival day for each individual

duplicates drop pid arr_year arr_month,force
keep if x_diff==0

sort pid arrival
save "$file/shz_clean",replace

* Drop outlier years
drop if arr_year>2023
keep pid arr* citi*

save "$file/arrival_clean",replace


