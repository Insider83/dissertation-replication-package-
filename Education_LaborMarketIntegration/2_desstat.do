* Davit Adunts, Truc Nguyen, Sebastian Vogler
*********************



						********************************
						* Descriptive statistics
						********************************



* Whole sample				
use "$file/final_1",clear

keep if inrange(cont,-24,24)


global control_des male age birth_m country1 country2 country3 ///
	country4 country5 country6 country7 country8 ///
	state1 state2 state3 state4 state5 state6 state7 state8 state9 ///
	state10 state11 state12 state13 state14 state15 state16

eststo whole_d: quietly estpost sum $outcome_labor_5 $outcome_jobqual_5 $outcome_labor_8 $outcome_jobqual_8 $control_des

eststo d_1: quietly estpost sum $outcome_labor_5 $outcome_jobqual_5 $outcome_labor_8 $outcome_jobqual_8 $control_des if d_lucky==1 
	
	
eststo d_0: quietly estpost sum $outcome_labor_5 $outcome_jobqual_5 $outcome_labor_8 $outcome_jobqual_8 $control_des if d_lucky==0
	
foreach filename in csv tex{
	esttab whole_d d_1 d_0 using "$output/summary/0_summary.`filename'", ///
	cells("mean(pattern(1 1 1) fmt(2)) sd(pattern(1 1 1) fmt(4)) count(pattern(1 1 1) fmt(0))") label ///
	se compress mtitles("Whole sample" "School exposure" "Control") ///
	wide replace title(Summary statistics)
}


// Sum
eststo whole_d: quietly estpost sum $outcome_labor_5 $outcome_jobqual_5 $outcome_labor_8 $outcome_jobqual_8 $control_des

foreach filename in csv tex{
esttab whole_d using "$output/summary/0_summary_covs.`filename'",  ///
	cells("count(fmt(a2)) mean(fmt(2)) min(fmt(2)) max(fmt(2)) sd(fmt(2))") label ///
	wide replace ///
    title(Summary statistics)
}


* Balance test - rkd reg for covs
*** Covariates
est clear

foreach v in $control_des{ //urban
	reg `v' v_over1 v_minus1 i.year2 if year_de==5 & inrange(cont,-24,24) & age>=18, vce(cluster state)

	est sto `v'
	qui testparm v_over1
	estadd scalar p_value = r(p), replace
	estadd scalar r_square = e(r2), replace
	sum `v' //if d_lucky==0
}

local title2 "Regression analysis"

foreach filename in csv tex{
esttab $control_des ///
	using "$output/summary/Table 2_balance_test.`filename'",  append ///
	keep(v_over1) b(%8.3f) se(%8.3f) ///
	stats(p_value r_square N,l("p-value" "R-square" "Observations") ///
	fmt(%8.3f %8.3f a3)) ///
	title(Table A1. `title2') nostar ///
	addn(We estimate the relationship between treatment status - arriving before 16 years old in Germany - and pre-determined characteristics measured at the arrival time using ordinary least squares. These include gender, reside in urban area, country of origin, and year immigrated to Germany. In addition, regressions also include state, years in Germany, cohort, and survey year fixed-effects. Standard errors in parentheses are clustered at the state level. *** 1\% ** 5\% and * 10\% level of significant. Data source: SOEP 2016-2022, own calculation.) ///
	noconstant label nogaps nonotes noobs long
}

local male "Male"
local age "Age"
local birth_m "Month of birth"
local country1 "Afghanistan"
local country2 "Pakistan"
local country3 "Iran"
local country4 "Iraq"
local country5 "Syria"
local country6 "Eritrea"
local country7 "Somalia"
local country8 "Ukraine"
local immiyear1 "Immigrant year 1999-2013"
local immiyear2 "Immigrant year 2014"
local immiyear3 "Immigrant year 2015"
local immiyear4 "Immigrant year 2016"
local immiyear5 "Immigrant year 2017-2019"
local immiyear6 "Immigrant year 2020-2023"
local state1 "Schleswig-Holstein"
local state2 "Hamburg"
local state3 "Lower Saxony"
local state4 "Bremen"
local state5 "Nordrhein-Westfalen"
local state6 "Hessen"
local state7 "Rhineland-Palatinate"
local state8 "Baden-Wuerttemberg"
local state9 "Bavaria"
local state10 "Saarland"
local state11 "Berlin"
local state12 "Brandenburg"
local state13 "Mecklenburg-Vorpommern"
local state14 "Saxony"
local state15 "Saxony-Anhalt"
local state16 "Thueringen"


foreach filename in csv tex{
	foreach v in $control_des{
	if "`v'"=="male"{
	esttab  `v' ///
	using "$output/summary/Table 2_balance_test.`filename'", wide replace ///
	keep(v_over1) b(%8.3f) se(%8.3f) coef(v_over1 ``v'') ///
	noconstant nomtitles nolabel nogaps nonotes noobs long
	}
	
	else {
	esttab  `v' ///
	using "$output/summary/Table 2_balance_test.`filename'", wide append ///
	keep(v_over1) b(%8.3f) se(%8.3f) coef(v_over1 ``v'') ///
	noconstant nomtitles nonumbers nolabel nogaps nonotes noobs long
	}
	}
}

	






















