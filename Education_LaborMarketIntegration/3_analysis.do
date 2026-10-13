* Davit Adunts, Truc Nguyen, Sebastian Vogler 
*********************



				********************************
					* Analysis
				********************************

*clear all
set more off
use "$file/final_1",clear
mdesc $outcome_educ $outcome_labor //$outcome_jobqual


*** Polynomial and rdrobust
***************************

foreach v in $outcome_educ $outcome_jobqual $outcome_labor { //
	foreach i in 5 8 { //

	* Spec1: No control
	reg `v'_`i' v_over1 v_minus1 i.year2 if age>=18 & year_de==`i' & inrange(cont,-24,24), vce(cluster state)
	est sto `v'_`i'_spec1
	estadd scalar Obs = e(N), replace
	estadd scalar BW = 24, replace
	estadd local FE_year "Yes", replace
	sum `v' if year_de==`i' & inrange(cont,-24,24)
	estadd scalar y_mean = r(mean),replace
	
	* Spec2: With control
	reghdfe `v'_`i' v_over1 v_minus1 male age birth_m if age>=18 & year_de==`i' & inrange(cont,-24,24), ///
	a(state country_ref year2) vce(cluster state)
	est sto `v'_`i'_spec2
	estadd scalar Obs = e(N),replace
	estadd scalar BW = 24, replace	
	sum `v' if year_de==`i' & inrange(cont,-24,24)
	estadd scalar y_mean = r(mean),replace
	estadd local FE_year "Yes", replace
	estadd local control "Yes", replace	

	}
}



*** Export
**********

foreach filename in csv tex{
	foreach i in 5 8 { //
// Education  ///haupt_cer mittler_cer ausbildung educ_qua

local title "The effects of schooling on refugees' integration"

esttab haupt_cer_`i'_spec1 haupt_cer_`i'_spec2 ///
	mittler_cer_`i'_spec1 mittler_cer_`i'_spec2 ///
	ausbildung_`i'_spec1 ausbildung_`i'_spec2 ///
	using "$output/RKD_`i'_education.`filename'",  replace ///
	keep(v_over1) b(%8.3f) se(%8.3f) ///
	stats(Obs y_mean BW FE_year control, ///
	l("Observations" "Mean" "Bandwidth(months)" "Year FE" "Controls") ///
		fmt(a3 %8.3f a3 %fmt %fmt)) ///
	title(Table 1. `title') ///
	mgroups("Highest degree: Lower Secondary" "Highest degree: Intermediate" "Ever enroll: Apprenticeship",pattern(1 0 1 0 1 0)) ///
	star(* .10 ** .05 *** .01) ///
	addn(Dummy outcomes. Standard errors in parentheses are clustered at the state level) ///
	noconstant nomtitles label nogaps nonotes noobs
	   


// Labor  ///employed employed_full employed_part

local title "The effects of schooling on refugees' integration"

esttab employed_`i'_spec1 employed_`i'_spec2 ///
	employed_full_`i'_spec1 employed_full_`i'_spec2 ///
	employed_part_`i'_spec1 employed_part_`i'_spec2 ///
	using "$output/RKD_`i'_labor.`filename'",  replace ///
	keep(v_over1) b(%8.3f) se(%8.3f) ///
	stats(Obs y_mean BW FE_year control, ///
	l("Observations" "Mean" "Bandwidth(months)" "Year FE" "Controls") ///
		fmt(a3 %8.3f a3 %fmt %fmt)) ///
	title(Table 1. `title') ///
	mgroups("Being Employed" "Employed: Full-time" "Employed: Part-time",pattern(1 0 1 0 1 0)) ///
	star(* .10 ** .05 *** .01) ///
	addn(Dummy outcomes. Standard errors in parentheses are clustered at the state level) ///
	noconstant nomtitles label nogaps nonotes noobs	   

  
	   
// Job quality 

local title "The effects of schooling on refugees' integration"

esttab entgelt_`i'_spec1 entgelt_`i'_spec2 ///
	year_days_emp_`i'_spec1 year_days_emp_`i'_spec2 ///
	year_days_benefits_`i'_spec1 year_days_benefits_`i'_spec2 ///
	using "$output/RKD_`i'_jobqual.`filename'",  replace ///
	keep(v_over1) b(%8.3f) se(%8.3f) ///
	stats(Obs y_mean BW FE_year control, ///
	l("Observations" "Mean" "Bandwidth(months)" "Year FE" "Controls") ///
		fmt(a3 %8.3f a3 %fmt %fmt)) ///
	title(Table 1. `title') ///
	mgroups("Daily Salary (euro)" "Days Employed" "Days on Benefit",pattern(1 0 1 0 1 0)) ///
	star(* .10 ** .05 *** .01) ///
	addn(Dummy outcomes. Standard errors in parentheses are clustered at the state level) ///
	noconstant nomtitles label nogaps nonotes noobs	   
	   	   
}
}

**********************************************
******************** RKD graphs - outcomes ***
**********************************************
use "$file/final_1",clear


local educ_qua "Recently completed education and training"
local mittler_cer "With at least intermediate certficate"
local ausbildung "Currently in VET"
local haupt_cer "With at least secondary (Hauptschulabschluss) certficate"
local employed "Being employed"
local employed_full  "Being employed full-time"
local employed_part "Being employed part-time"


foreach v in $outcome_educ $outcome_labor $outcome_jobqual{
foreach i in 5 8 {
	
	binscatter `v'_`i' cont if age>=18 & year_de==`i' & inrange(cont,-24,24), ///
			rd(0) n(24) mc(black) lc(maroon) xscale(range(-24,24)) ///
	xlabel(-24(4)24,nogrid) xtitle("Relative Month at Arrival") ytitle("(mean)") /*yscale(range(0.75,0.9)) ylabel(0.75(0.05)0.9)*/
	
	gr export "$graph/rkd_`v'_`i'.png",replace
}
}