********************************************************************************
*			pooled estimations
********************************************************************************
use "$results\ssa_panel_all.dta", clear
est drop _all

cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6
global lin_early run_week i.after_week#c.run_week i.kann_6
global lin_student run_week i.after_week#c.run_week t_wo_lehrer
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2



keep if w_t4_cal != 0
duplicates drop ID_t, force


gen year_act = year(start_sp1)
gen year_entry = year(entry_6)
gen complier = year_act ==  year_entry


recode p_gerborn_ha_new (-1 = .)
recode NumberOfOlderSibs (0=0) (1/17 = 1), gen(OlderSibsDummy)

tab p_yos2_T2, gen(p_yos2_T2_)

recode m_ageb4_T2 (0 = 0) (10/19 = 1) (20/29=2) (30/39=3) (40/50= 4), gen(mage_birth_cat)
label def mage_birth_cat 0 "missings" 1 "10-19" 2 "20-29" 3 "30-39" 4 ">= 40"
label val mage_birth_cat mage_birth_cat
label var mage_birth_cat "mothers age at birth (cat.)"
tab mage_birth_cat, gen(mage_birth_cat_)

label var female "female"

putexcel set "$results/ssa_compliers_full_angrist_$date.xlsx", replace

local i = 4
foreach var of varlist female p_yos2_T2_1 p_yos2_T2_2 p_yos2_T2_3 p_yos2_T2_4 p_gerborn_ha_new p_gerborn_ha_new_m mage_birth_cat_1 mage_birth_cat_2 mage_birth_cat_3 mage_birth_cat_4 mage_birth_cat_5 OlderSibsDummy NumberOfOlderSibs_m JoinedKita JoinedKita_m  SSY__6 {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

putexcel A1 = "Complier characteristics", bold

putexcel B3 = "P[x_i = 1]"
putexcel C3 = "P[x_i = 1| D_1i > D_0i]"
putexcel D3 = "P[x_i = 1| D_1i > D_0i] / P[x_i = 1]"
putexcel E3 = "SE"
putexcel G3 = "Coef."
putexcel H3 = "p-val"



local i = 4
foreach var of varlist female p_yos2_T2_1  p_yos2_T2_2 p_yos2_T2_3 p_yos2_T2_4 p_gerborn_ha_new p_gerborn_ha_new_m mage_birth_cat_1 mage_birth_cat_2 mage_birth_cat_3 mage_birth_cat_4 mage_birth_cat_5 OlderSibsDummy NumberOfOlderSibs_m JoinedKita JoinedKita_m  SSY__6  { 

reg `var' [aweight=w_t4_cal], robust
predict `var'_all, xb
reg `var' complier [aweight=w_t4_cal], robust
predict `var'_complier, xb

sum `var'_all 
matrix define A_`i' = `r(mean)'
sum `var'_complier
matrix define B_`i' = `r(mean)'
ratio SSY_ratio_`var': `var'_complier/`var'_all // [pweight=w_t4_cal]

*mat define table_`i' = r(table)
matrix define C_`i' = (r(table)[1,1] , r(table)[2,1])
mat list C_`i'
mat define full_`i' = A_`i', B_`i', C_`i'
	
local i = `++i'	
}

foreach num of numlist 4(1)20 {
	putexcel B`num' = matrix(full_`num'), nformat(#.###)
}


cap erase "$results\ssa_compliers_full_kuehnle_$date.csv"
local i = 4
foreach var of varlist female p_yos2_T2_1 p_yos2_T2_2 p_yos2_T2_3 p_yos2_T2_4 p_gerborn_ha_new p_gerborn_ha_new_m mage_birth_cat_1 mage_birth_cat_2 mage_birth_cat_3 mage_birth_cat_4 mage_birth_cat_5 OlderSibsDummy NumberOfOlderSibs_m JoinedKita JoinedKita_m  SSY__6  {
preserve
ivreg2 complier $instr $lin_plain i.after_week#i.`var' i.`var' [aw=w_t4_cal],  robust partial($lin_plain)  //  2011 weighted
estimates store comp_`var'


local name: variable label `var'
esttab comp_`var' using "$results\ssa_compliers_full_kuehnle_$date", append scsv keep(1.after_week#1.`var')  b(3)  p(3) nomtitles nodepvars noobs nonotes noparentheses wide plain // cells(b(fmt(3) star) se(par) p)
restore
}