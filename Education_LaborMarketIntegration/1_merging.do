* Davit Adunts, Truc Nguyen, Sebastian Vogler
*********************



********************************
* Additional cleaning
********************************
use "$file/merged_1",clear

keep if inrange(age,15,35)

* Drop irrelevant vars
drop prs_id ieb_konto_zeile ieb_end_plan ieb_quellverf_id ieb_erw_stat sex_id ieb_tag_entg isb_id ieb_dba_id berufstellg_imp ieb_fall_id b_krs_schl_ao_akt_num b_krs_schl_wo_akt_num b_gst_schl_ao_akt_num b_aa_schl_ao_akt_num ieb_beruf_num ieb_beruf_kons_num ieb_staat_num

* Keep major countries
recode citizenship_shz (423=1 "Afghanistan") (461=2 "Pakistan") (439=3 "Iran") (438=4 "Iraq") (475=5 "Syria") (224=6 "Eritrea") (273=7 "Somalia") (166=8 "Ukraine"),gen(country_ref)
replace country_ref=. if country_ref==0
replace country_ref=. if country_ref>10


* Relative month/age at arrival

gen age_arr= arr_year - birth_y
lab var age_arr "Age of arrival"
drop if age_arr<0


gen n_month= int((arrival- geb_dat_ano)/365*12)
lab var n_month "Month of arrival"


gen cont_month=.
replace cont_month= n_month - 15*12
replace cont_month=n_month-16*12 if inlist(state,8,11,12,4,6,13,5,10,16)
lab var cont_month "Relative Month at Arrival"
tab cont_month


* Define treatment ----- Month
gen cont= cont_month

* School starting delay adjustment - not for now
replace cont= cont + 7 if inlist(state,12,4,6,13,3,5,7,14,15)
replace cont= cont + 3 if inlist(state,9,16)
replace cont= cont + 6 if inlist(state,8)

* Gnerate treatment
gen d_lucky= (cont<=0) if cont!=.
lab var d_lucky "School exposure"

gen kink=0

g v_minus1= (cont-kink) 
g v_over1=(cont-kink)*d_lucky 
lab var v_over1 "School exposure*Relative MAR"

g v_minus2= (cont-kink)^2
g v_over2=((cont-kink)^2)*d_lucky

g v_minus3= (cont-kink)^3
g v_over3=((cont-kink)^3)*d_lucky

* years in Germany
gen year_de= year - arr_year

* Create dummies for covariates
tab country_ref,gen(country)
tab state,gen(state)
tab birth_m,gen(birth_m)

tab year,gen(year_)
clonevar year2= year
replace year2=2017 if year<=2017 & year!=.
lab def year2 2017 "<=2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023"
lab val year2 year2

tab year2,gen(year2_)


* Global controls
foreach v in male country_ref state birth_m year{
	drop if `v'==.
}


* Generate mean
keep if country_ref!=. // keep only countries of refugees

* years in Germany: ~2 years interval, more obs
drop if year_de<0 //

gen year_de2=.
replace year_de2= 1 if year_de<=2
replace year_de2= 2 if inrange(year_de,3,5)
replace year_de2= 3 if inrange(year_de,6,8)
replace year_de2= 4 if year_de>=9 & year_de!=.
tab year_de2,m

lab var year_de2 "Years in Germany"
lab def year_de2 1 "0-2" 2 "3-5" 3 "6-8" 4 ">= 9"
lab val year_de2 year_de2


* Grouping ages: 
tab age

gen age2=.
replace age2=1 if age<=17 & age!=.
replace age2=2 if inrange(age,18,21) & age!=.
replace age2=3 if inrange(age,22,25) & age!=.
replace age2=4 if inrange(age,26,35) & age!=.

tab age2,m

lab var age2 "Age groups"
lab def age2 1 "<=17" 2 "18-21" 3 "22-25" 4 "26-35"
lab val age2 age2

* Age groups for subsamples:
gen age_g = .
replace age_g = 1 if age==18
replace age_g = 2 if age==22
replace age_g = 3 if age==24

* Keep vars of interest

sort pid year quelle emp_status_des
order pid year quelle emp_status_des //begepi endepi 


drop if year_de>15 | year_de==.
keep if inrange(cont,-60,60)

* Generate variables for each year group
foreach v in $outcome_labor $outcome_jobqual{
foreach i in 5 8{ //3 
	gen `v'_`i'= `v'
}
}

foreach v in $outcome_educ{
foreach i in 5 8 { // 
	
	bys pid: egen x_`v'_`i'=max(`v') if year_de<=`i'
	gen `v'_`i'= x_`v'_`i'
	drop x_*
}
}

sort pid year


keep if age>=18 & age!=.


* Create mean by run var
foreach v in $control {
foreach i in 5 8{
	
bys cont: egen m_`v'_`i'= mean(`v') if year_de== `i'

}
}

// educ
lab var haupt_cer_5 "Highest degree: Lower Secondary"
lab var haupt_cer_8 "Highest degree: Lower Secondary"

lab var mittler_cer_5 "Highest degree: Intermediate"
lab var mittler_cer_8 "Highest degree: Intermediate"

lab var ausbildung_5 "Ever enroll: Apprenticeship"
lab var ausbildung_8 "Ever enroll: Apprenticeship"


//labor 
lab var employed_5 "Being employed"
lab var employed_8 "Being employed"

lab var employed_full_5 "Being employed: Full-time"
lab var employed_full_8 "Being employed: Full-time"

lab var employed_part_5 "Being employed: Part-time"
lab var employed_part_8 "Being employed: Part-time"

// job quality
lab var entgelt_5 "Daily Salary (euro)"
lab var entgelt_8 "Daily Salary (euro)"

lab var year_days_emp_5 "Days Employed" //"Total days employed per calendar year"
lab var year_days_emp_8 "Days Employed"

lab var year_days_benefits_5 "Days on Benefit" //"Total days benefit recipience per calendar year"
lab var year_days_benefits_8 "Days on Benefit"


// state
lab var state1 "Schleswig-Holstein" 
lab var state2 "Hamburg" 
lab var state3 "Lower Saxony" //"Niedersachsen" 
lab var state4 "Bremen"
lab var state5 "Nordrhein-Westfalen" 
lab var state6 "Hessen" 
lab var state7 "Rhineland-Palatinate" //"Rheinlandpfalz" 
lab var state8 "Baden-Wuerttemberg" 
lab var state9 "Bavaria" //"Bayern"
lab var state10 "Saarland"
lab var state11 "Berlin"
lab var state12 "Brandenburg"
lab var state13 "Mecklenburg-Vorpommern"
lab var state14 "Saxony" //"Sachsen" 
lab var state15 "Saxony-Anhalt" //"Sachsen-Anhalt" 
lab var state16 "Thueringen"

lab var country1 "Afghanistan"
lab var country2 "Pakistan"
lab var country3 "Iran"
lab var country4 "Iraq"
lab var country5 "Syria"
lab var country6 "Eritrea"
lab var country7 "Somalia"
lab var country8 "Ukraine"


save "$file/final_1",replace

