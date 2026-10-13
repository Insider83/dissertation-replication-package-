********************************************************************************
*			compliers
********************************************************************************
use "$results\ssa_panel_all_new.dta", clear // one observation per individual
drop if inlist(run_week,-1,0,1,2)

keep if w_t4_cal != 0
keep if edgeweek == 0
keep if inrange(yob,1945,1964)
duplicates drop ID_t, force



*complier defintiion
gen year_act = year(start_sp1)
gen year_entry = year(entry_6)
gen complier = year_act ==  year_entry



****Sociodemographics
replace p_yos_mean = . if p_yos_mean == 0
replace m_ageb4_T2 = . if m_ageb4_T2 == 0
replace p_gerborn_ha_new = 0 if p_gerborn_ha_new == -1

cap drop west
gen west = inrange(bl_birth,1,10)

tab bula6, gen(bula6_d)

label var mob "Month of birth"
label var female "Women"
label var yob "Year of birth"
label var west "Born in West-Germany"
label var bula6 "Federal state of school entry"
label var bula6_d1 "State: Schleswig-Holstein"
label var bula6_d2 "State: Hamburg"
label var bula6_d3 "State: Lower Saxony"
label var bula6_d4 "State: Bremen"
label var bula6_d5 "State: Northrhine-Westphalia"
label var bula6_d6 "State: Hesse"
label var bula6_d7 "State: Rhineland Palatinate"
label var bula6_d8 "State: Baden-Wuerttemberg"
label var bula6_d9 "State: Bavaria"
label var bula6_d10 "State: Saarland"
label var p_yos_mean "Parental education (in yrs)"
label var p_yos_mean_m "Parental education: missing"
label var p_gerborn_ha_new "German parent (0/1)"
label var p_gerborn_ha_new_m  "German parent: missing"
label var m_ageb4_T2 "Maternal age at birth (in yrs)"
label var m_ageb4_T2_m "Maternal age at birth: missing"
label var D_OlderSibling_T2 "First born (0/1)"
label var D_OlderSibling_T0 "First born: missing"
label var D_JoinedKita_T2_2 "Kindergarten attendance (0/1)"
label var D_JoinedKita_T2_0 "Kindergarten attendance: missing"
label var C9_6 "Exposed to compulsory schooling reform (0(1))"
label var SSY__6 "Exposed to short school years (0(1))"
label var RuralNEPS_0_20 "Born in rural area (< 20k)"



putexcel set "$results/ssa_compliers_$date.xlsx", replace

putexcel A1 = "Complier characteristics", bold
putexcel B3 = "Compliers (regular enrolment)"
putexcel C3 = "Non-compliers (early/late enrolment)"
putexcel D3 = "Difference"


order yob mob female west bula6_d1 - bula6_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2_2  D_JoinedKita_T2_0 C9_6 SSY__6 RuralNEPS_0_20
local i = 4
foreach var of varlist yob - RuralNEPS_0_20 {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}


local i = 4
foreach var of varlist yob mob female west bula6_d1 - bula6_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2_2  D_JoinedKita_T2_0 C9_6 SSY__6 RuralNEPS_0_20  { 

sum `var' [aweight=w_t4_cal] if complier == 1 
matrix define A_`i' = `r(mean)'
sum `var' [aweight=w_t4_cal] if complier == 0
matrix define B_`i' = `r(mean)'
matrix define C_`i' = A_`i'[1,1] - B_`i'[1,1]

*mat define table_`i' = r(table)
mat define full_`i' = A_`i', B_`i', C_`i'
	
local i = `++i'	
}

foreach num of numlist 4(1)30 {
	putexcel B`num' = matrix(full_`num'), nformat(#.##)
}


**** Educ Outcomes
putexcel set "$results/ssa_compliers_$date.xlsx", modify

label var aase "School starting age"
label var acadt_filled "Tracked to gymnasium (Kamila, missings coded as zero)"
label var YOS_Sum "Years of schooling"
label var hs1 "Highest school degree: basic"
label var rs1 "Highest school degree: middle"
label var abi "Highest school degree: high school"
label var uni "College/university degree"



order aase acadt_filled YOS_Sum hs1 rs1 abi uni
local i = 31
foreach var of varlist aase - uni {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}


local i = 31
foreach var of varlist aase acadt_filled YOS_Sum hs1 rs1 abi uni  { 

sum `var' [aweight=w_t4_cal] if complier == 1 
matrix define A_`i' = `r(mean)'
sum `var' [aweight=w_t4_cal] if complier == 0
matrix define B_`i' = `r(mean)'
matrix define C_`i' = A_`i'[1,1] - B_`i'[1,1]

*mat define table_`i' = r(table)
mat define full_`i' = A_`i', B_`i', C_`i'
	
local i = `++i'	
}

foreach num of numlist 31(1)37 {
	putexcel B`num' = matrix(full_`num'), nformat(#.##)
}


