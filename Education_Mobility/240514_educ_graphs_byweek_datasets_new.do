*****************Create datasets of education outcomes by week******************
use "$results\ssa_panel_obs1_new.dta", clear

********************************************************************************
* 	full_weighted
********************************************************************************

estimates drop _all


cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_twfe run_week i.after_week#c.run_week i.female i.bula6 i.yob 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_twfe run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 

centile(aase), centile(0.5, 99.5)
gen aase_05 =  r(c_1)
gen aase_995 = r(c_2)

label var aase "SSA (orig)"

clonevar aase_2 = aase
replace aase_2 = . if (aase_2 < aase_05) | (aase_2 > aase_995)
label var aase_2 "SSA (without half percentile from bottom/top of distribution)"

clonevar aase_3 = aase
replace aase_3 = aase_05 if (aase_3 < aase_05) 
replace aase_3 = aase_995 if (aase_3 > aase_995) 
label var aase_3 "SSA (half percentile from bottom/top replaced with value of percentile)"

* old for grade
gen entry_year_act = year(start_sp1)
gen older = entry_year_act >= yob +7 & entry_year_act != .
label var older "Old for grade"

* enrollment year as expected
gen compliers = year(start_sp1) == year(entry_6) // year of actual enrolment = year of expected enrolment
label var compliers "Enrolment year as expected"


centile(YOS_Sum), centile(0.5, 99.5)
gen YOS_Sum_05 =  r(c_1)
gen YOS_Sum_995 = r(c_2)

label var YOS_Sum "YOS (Sebastian)"
clonevar YOS1_Sum = YOS_Sum

clonevar YOS2_Sum = YOS_Sum
replace YOS2_Sum = . if (YOS2_Sum < YOS_Sum_05) | (YOS2_Sum > YOS_Sum_995)
label var YOS2_Sum "YOS (Sebastian; without half percentile)"


clonevar YOS3_Sum = YOS_Sum
replace YOS3_Sum = YOS_Sum_05 if (YOS3_Sum < YOS_Sum_05) 
replace YOS3_Sum = YOS_Sum_995 if (YOS3_Sum > YOS_Sum_995) 
label var YOS3_Sum "YOS (Sebastian; half percentile replaced )"

*recode lower education wrt to C9
recode yos_max (8 = 9) if C9_14 == 1

recode yoe (8 = 9) if C9_14 == 1
clonevar yoe_yrs = yoe

recode yoe_grade (8 = 9) if C9_14 == 1


* create one dataset per educ variable
foreach var of varlist aase aase_2 aase_3 older compliers acadt acadt_filled abi_sectrack abi_sectrack_max  hs1 rs1 abi YOS1_Sum YOS2_Sum YOS3_Sum yos_max uni yoe_yrs yoe_grade {
preserve
keep if inrange(yob,1945,1964)
keep if `var' != .
drop if `var' == -99
gen N=1 
local lab: variable label `var' 

reg `var' run_week [aw=w_t4_cal] if inrange(run_week,-24,0)
predict fit0_`var', xb
predict se0_`var', stdp
reg `var' run_week [aw=w_t4_cal] if inrange(run_week,1,25)
predict fit1_`var', xb
predict se1_`var', stdp

collapse (mean) `var' fit0_`var' fit1_`var' se0_`var' se1_`var' (count) N [aw=w_t4_cal], by(run_week)
label var `var' "`lab'"
gen ci0_hi_`var' = fit0_`var' + 1.96*se0_`var'
gen ci0_lo_`var' = fit0_`var' - 1.96*se0_`var' 

gen ci1_hi_`var' = fit1_`var' + 1.96*se1_`var' 
gen ci1_lo_`var' = fit1_`var' - 1.96*se1_`var' 

gen samp_`var' = 1

save "${results}\temp\educ_by_week_full_`var'.dta", replace
restore
}

use "${results}\temp\educ_by_week_full_aase.dta", clear
local datasets "aase_2 aase_3 older compliers acadt acadt_filled abi_sectrack abi_sectrack_max hs1 rs1 abi YOS1_Sum YOS2_Sum YOS3_Sum yos_max uni yoe_yrs yoe_grade"
foreach x of local datasets {
	merge 1:1 run_week using "${results}\temp\educ_by_week_full_`x'.dta"
	drop _merge
}
save "${results}\educ_by_week_full_weighted_new.dta", replace
export excel using "$results\educ_by_week_full_weighted_new.xls", firstrow(variables) replace


********************************************************************************
* 	full - unweighted
********************************************************************************
use "$results\ssa_panel_obs1_new.dta", clear

estimates drop _all


cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_twfe run_week i.after_week#c.run_week i.female i.bula6 i.yob 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_twfe run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 

centile(aase), centile(0.5, 99.5)
gen aase_05 =  r(c_1)
gen aase_995 = r(c_2)

label var aase "SSA (orig)"

clonevar aase_2 = aase
replace aase_2 = . if (aase_2 < aase_05) | (aase_2 > aase_995)
label var aase_2 "SSA (without half percentile from bottom/top of distribution)"

clonevar aase_3 = aase
replace aase_3 = aase_05 if (aase_3 < aase_05) 
replace aase_3 = aase_995 if (aase_3 > aase_995) 
label var aase_3 "SSA (half percentile from bottom/top replaced with value of percentile)"

* old for grade
gen entry_year_act = year(start_sp1)
gen older = entry_year_act >= yob +7 & entry_year_act != .
label var older "Old for grade"

* enrollment year as expected
gen compliers = year(start_sp1) == year(entry_6) // year of actual enrolment = year of expected enrolment
label var compliers "Enrolment year as expected"


centile(YOS_Sum), centile(0.5, 99.5)
gen YOS_Sum_05 =  r(c_1)
gen YOS_Sum_995 = r(c_2)

label var YOS_Sum "YOS (Sebastian)"
clonevar YOS1_Sum = YOS_Sum

clonevar YOS2_Sum = YOS_Sum
replace YOS2_Sum = . if (YOS2_Sum < YOS_Sum_05) | (YOS2_Sum > YOS_Sum_995)
label var YOS2_Sum "YOS (Sebastian; without half percentile)"


clonevar YOS3_Sum = YOS_Sum
replace YOS3_Sum = YOS_Sum_05 if (YOS3_Sum < YOS_Sum_05) 
replace YOS3_Sum = YOS_Sum_995 if (YOS3_Sum > YOS_Sum_995) 
label var YOS3_Sum "YOS (Sebastian; half percentile replaced )"

*recode lower education wrt to C9
recode yos_max (8 = 9) if C9_14 == 1

recode yoe (8 = 9) if C9_14 == 1
clonevar yoe_yrs = yoe

recode yoe_grade (8 = 9) if C9_14 == 1


* create one dataset per educ variable
foreach var of varlist aase aase_2 aase_3 older compliers acadt acadt_filled abi_sectrack abi_sectrack_max  hs1 rs1 abi YOS1_Sum YOS2_Sum YOS3_Sum yos_max uni yoe_yrs yoe_grade {
preserve
keep if inrange(yob,1945,1964)
keep if `var' != .
drop if `var' == -99
gen N=1 
local lab: variable label `var' 

reg `var' run_week if inrange(run_week,-24,0)
predict fit0_`var', xb
predict se0_`var', stdp
reg `var' run_week  if inrange(run_week,1,25)
predict fit1_`var', xb
predict se1_`var', stdp

collapse (mean) `var' fit0_`var' fit1_`var' se0_`var' se1_`var' (count) N, by(run_week)
label var `var' "`lab'"
gen ci0_hi_`var' = fit0_`var' + 1.96*se0_`var'
gen ci0_lo_`var' = fit0_`var' - 1.96*se0_`var' 

gen ci1_hi_`var' = fit1_`var' + 1.96*se1_`var' 
gen ci1_lo_`var' = fit1_`var' - 1.96*se1_`var' 

gen samp_`var' = 1

save "${results}\temp\educ_by_week_full_unweighted_`var'.dta", replace
restore
}

use "${results}\temp\educ_by_week_full_unweighted_aase.dta", clear
local datasets "aase_2 aase_3 older compliers acadt acadt_filled abi_sectrack abi_sectrack_max hs1 rs1 abi YOS1_Sum YOS2_Sum YOS3_Sum yos_max uni yoe_yrs yoe_grade"
foreach x of local datasets {
	merge 1:1 run_week using "${results}\temp\educ_by_week_full_unweighted_`x'.dta"
	drop _merge
}
save "${results}\educ_by_week_full_unweighted_new.dta", replace
export excel using "$results\educ_by_week_full_unweighted_new.xls", firstrow(variables) replace


********************************************************************************
* 	donut - weighted
********************************************************************************
use "$results\ssa_panel_obs1_new.dta", clear

estimates drop _all


cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_twfe run_week i.after_week#c.run_week i.female i.bula6 i.yob 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_twfe run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 

centile(aase), centile(0.5, 99.5)
gen aase_05 =  r(c_1)
gen aase_995 = r(c_2)

label var aase "SSA (orig)"

clonevar aase_2 = aase
replace aase_2 = . if (aase_2 < aase_05) | (aase_2 > aase_995)
label var aase_2 "SSA (without half percentile from bottom/top of distribution)"

clonevar aase_3 = aase
replace aase_3 = aase_05 if (aase_3 < aase_05) 
replace aase_3 = aase_995 if (aase_3 > aase_995) 
label var aase_3 "SSA (half percentile from bottom/top replaced with value of percentile)"

* old for grade
gen entry_year_act = year(start_sp1)
gen older = entry_year_act >= yob +7 & entry_year_act != .
label var older "Old for grade"

* enrollment year as expected
gen compliers = year(start_sp1) == year(entry_6) // year of actual enrolment = year of expected enrolment
label var compliers "Enrolment year as expected"


centile(YOS_Sum), centile(0.5, 99.5)
gen YOS_Sum_05 =  r(c_1)
gen YOS_Sum_995 = r(c_2)

label var YOS_Sum "YOS (Sebastian)"
clonevar YOS1_Sum = YOS_Sum

clonevar YOS2_Sum = YOS_Sum
replace YOS2_Sum = . if (YOS2_Sum < YOS_Sum_05) | (YOS2_Sum > YOS_Sum_995)
label var YOS2_Sum "YOS (Sebastian; without half percentile)"


clonevar YOS3_Sum = YOS_Sum
replace YOS3_Sum = YOS_Sum_05 if (YOS3_Sum < YOS_Sum_05) 
replace YOS3_Sum = YOS_Sum_995 if (YOS3_Sum > YOS_Sum_995) 
label var YOS3_Sum "YOS (Sebastian; half percentile replaced )"

*recode lower education wrt to C9
recode yos_max (8 = 9) if C9_14 == 1

recode yoe (8 = 9) if C9_14 == 1
clonevar yoe_yrs = yoe

recode yoe_grade (8 = 9) if C9_14 == 1



*school entry age (1st stage)
drop if inlist(run_week,-1,0,1,2)
foreach var of varlist aase aase_2 aase_3 older compliers acadt acadt_filled abi_sectrack abi_sectrack_max  hs1 rs1 abi YOS1_Sum YOS2_Sum YOS3_Sum yos_max uni yoe_yrs yoe_grade {
preserve
keep if inrange(yob,1945,1964)
keep if `var' != .
drop if `var' == -99
gen N=1 
local lab: variable label `var' 

reg `var' run_week [aw=w_t4_cal] if inrange(run_week,-24,-2)
predict fit0_`var', xb
predict se0_`var', stdp
reg `var' run_week [aw=w_t4_cal] if inrange(run_week,3,25)
predict fit1_`var', xb
predict se1_`var', stdp

collapse (mean) `var' fit0_`var' fit1_`var' se0_`var' se1_`var' (count) N [aw=w_t4_cal], by(run_week)
label var `var' "`lab'"
gen ci0_hi_`var' = fit0_`var' + 1.96*se0_`var'
gen ci0_lo_`var' = fit0_`var' - 1.96*se0_`var' 

gen ci1_hi_`var' = fit1_`var' + 1.96*se1_`var' 
gen ci1_lo_`var' = fit1_`var' - 1.96*se1_`var' 

gen samp_`var' = 1

save "${results}\temp\educ_by_week_donut_`var'.dta", replace
restore
}

use "${results}\temp\educ_by_week_donut_aase.dta", clear
local datasets "aase_2 aase_3 older compliers acadt acadt_filled abi_sectrack abi_sectrack_max hs1 rs1 abi YOS1_Sum YOS2_Sum YOS3_Sum yos_max uni yoe_yrs yoe_grade"
foreach x of local datasets {
	merge 1:1 run_week using "${results}\temp\educ_by_week_donut_`x'.dta"
	drop _merge
}
save "${results}\educ_by_week_donut_weighted_new.dta", replace
export excel using "$results\educ_by_week_donut_weighted_new.xls", firstrow(variables) replace


********************************************************************************
* 	donut - unweighted
********************************************************************************
use "$results\ssa_panel_obs1_new.dta", clear

estimates drop _all


cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_twfe run_week i.after_week#c.run_week i.female i.bula6 i.yob 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_twfe run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 

centile(aase), centile(0.5, 99.5)
gen aase_05 =  r(c_1)
gen aase_995 = r(c_2)

label var aase "SSA (orig)"

clonevar aase_2 = aase
replace aase_2 = . if (aase_2 < aase_05) | (aase_2 > aase_995)
label var aase_2 "SSA (without half percentile from bottom/top of distribution)"

clonevar aase_3 = aase
replace aase_3 = aase_05 if (aase_3 < aase_05) 
replace aase_3 = aase_995 if (aase_3 > aase_995) 
label var aase_3 "SSA (half percentile from bottom/top replaced with value of percentile)"

* old for grade
gen entry_year_act = year(start_sp1)
gen older = entry_year_act >= yob +7 & entry_year_act != .
label var older "Old for grade"

* enrollment year as expected
gen compliers = year(start_sp1) == year(entry_6) // year of actual enrolment = year of expected enrolment
label var compliers "Enrolment year as expected"


centile(YOS_Sum), centile(0.5, 99.5)
gen YOS_Sum_05 =  r(c_1)
gen YOS_Sum_995 = r(c_2)

label var YOS_Sum "YOS (Sebastian)"
clonevar YOS1_Sum = YOS_Sum

clonevar YOS2_Sum = YOS_Sum
replace YOS2_Sum = . if (YOS2_Sum < YOS_Sum_05) | (YOS2_Sum > YOS_Sum_995)
label var YOS2_Sum "YOS (Sebastian; without half percentile)"


clonevar YOS3_Sum = YOS_Sum
replace YOS3_Sum = YOS_Sum_05 if (YOS3_Sum < YOS_Sum_05) 
replace YOS3_Sum = YOS_Sum_995 if (YOS3_Sum > YOS_Sum_995) 
label var YOS3_Sum "YOS (Sebastian; half percentile replaced )"

*recode lower education wrt to C9
recode yos_max (8 = 9) if C9_14 == 1

recode yoe (8 = 9) if C9_14 == 1
clonevar yoe_yrs = yoe

recode yoe_grade (8 = 9) if C9_14 == 1



*school entry age (1st stage)
drop if inlist(run_week,-1,0,1,2)
foreach var of varlist aase aase_2 aase_3 older compliers acadt acadt_filled abi_sectrack abi_sectrack_max  hs1 rs1 abi YOS1_Sum YOS2_Sum YOS3_Sum yos_max uni yoe_yrs yoe_grade {
preserve
keep if inrange(yob,1945,1964)
keep if `var' != .
drop if `var' == -99
gen N=1 
local lab: variable label `var' 

reg `var' run_week if inrange(run_week,-24,-2)
predict fit0_`var', xb
predict se0_`var', stdp
reg `var' run_week if inrange(run_week,3,25)
predict fit1_`var', xb
predict se1_`var', stdp

collapse (mean) `var' fit0_`var' fit1_`var' se0_`var' se1_`var' (count) N, by(run_week)
label var `var' "`lab'"
gen ci0_hi_`var' = fit0_`var' + 1.96*se0_`var'
gen ci0_lo_`var' = fit0_`var' - 1.96*se0_`var' 

gen ci1_hi_`var' = fit1_`var' + 1.96*se1_`var' 
gen ci1_lo_`var' = fit1_`var' - 1.96*se1_`var' 

gen samp_`var' = 1

save "${results}\temp\educ_by_week_donut_unweighted_`var'.dta", replace
restore
}

use "${results}\temp\educ_by_week_donut_unweighted_aase.dta", clear
local datasets "aase_2 aase_3 older compliers acadt acadt_filled abi_sectrack abi_sectrack_max hs1 rs1 abi YOS1_Sum YOS2_Sum YOS3_Sum yos_max uni yoe_yrs yoe_grade"
foreach x of local datasets {
	merge 1:1 run_week using "${results}\temp\educ_by_week_donut_unweighted_`x'.dta"
	drop _merge
}
save "${results}\educ_by_week_donut_unweighted_new.dta", replace
export excel using "$results\educ_by_week_donut_unweighted_new.xls", firstrow(variables) replace
