/**************************************************
This file will do an Overview of virtually all available DiD-Estimators
	
	-> We concentrate on Age 25- 55 (To be inline with regressions)
	
	
	Author: Sebastian Vogler
	
	Version: 1.0, First Created: 2024-12-18
***************************************************/

*Install Packages
*ssc install did_imputation

************************************************
* define globals
************************************************
global results_AllDiD "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\DiD\Wildcards"

* Some DiD-Packages do not like i. - prefix, therefore define new globals
global family_new_DiD p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New_DiD JoinedKita_T2 OlderSibling_T2
global RuralVariable_IMP RuralNEPSMZ


************************************************
*    load final panel
************************************************
use "$results\C9_Combined_Utilized_Panel_final.dta", clear
sort ID_t age
xtset ID_t age


************************************************
* Limit Data-Set
************************************************
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)


************************************************ ************************************************
*** *** *** wooldid *** *** ***
************************************************ ************************************************

*** *** Not Aggregated *** ***
*** Weighted
foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	display("`var'")
	wooldid `var' bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) att safety(off) // automatically drops AT! // Safety Off necessary for using aweights!
	eststo e_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
}

esttab e_* using "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\DiD\Wildcards\C9_WoolDiD.csv", cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Wooldridge (2021) Estimator Used. Weighted!") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace

esttab e_* using "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\DiD\Wildcards\C9_AllCombined.csv", cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Wooldridge (2021) Estimator Used. Weighted!") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") append

eststo clear

foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	display("`var'")
	wooldid `var' bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off)  makeplots espre(50) espost(50) // automatically drops AT! // Safety Off necessary for using aweights!

	graph export "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\DiD\Wildcards\Event_`var'.pdf", as(pdf) name("att_fullmodel") replace
}

*** Graph Manipulation ***
wooldid mig_stock bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off) espre(25) espost(25)
ereturn list
matrix wool_b =  e(b)
matrix wool_v =  e(V)

event_plot wool_b#wool_v, ///
	stub_lag(pre1) ///
	stub_lead(post1)
	
	event_plot e(b)#e(V), ///
	stub_lag(pre1) ///
	stub_lead(post1)

* a)
matrix list e(b)
matrix list e(V)

coefplot wool_b
coefplot matrix(e(b))
coefplot b*

coefplot matrix(e(b)), vertical ci yline(0) xline(0)


*b )
wooldid mig_stock bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off) espre(25) espost(25)
ereturn list

svmat e(b), names(b)
svmat e(V), names(V)

gen se = squrt(V)
gen ub = b1 + 1.96*se
gen lb = b1 - 1.96*se
gen event = _n - 11



