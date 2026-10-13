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

*** Mig_stock
wooldid mig_stock bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off) espre(50) espost(50)

preserve
ereturn list
svmat e(b), names(b)
svmat e(V), names(V)

forvalues num = 1/84 {
	*display `num'
	rename V`num' V`num'_
	egen V`num' = max(V`num'_)
}

keep if _n == 1
keep b* V*
drop bdate bula bl_birth V*_

* Reshape
gen ID = 1
reshape long b V, i(ID) j(Time)

* Make SE
gen se = sqrt(V)
gen ub = b + 1.96*se
gen lb = b - 1.96*se
gen event = _n - 42

* Beautiful final touch
keep if inrange(event, -25, 25) // here: Decide final range of cohorts!
replace b = . if event == -1
replace se = . if event == -1
replace ub = . if event == -1
replace lb = . if event == -1

* Graph
twoway ///
	(rcap ub lb event, lcolor(gs8)) ///
	(scatter b event, mcolor(black) msymbol(0)), ///
	yline(0, lwidth(thin) lpattern(dash) ) xline(-1, lwidth(thin) lpattern(dash) ) ///
	xtitle("Event Time (Reform)") ///
	ytitle("ATT") ylab(,nogrid) xlab(,nogrid) ///
	title("Lifetime Mobility: State") ///
	legend(off) 

* Save Graph
graph save "Graph" "$results_AllDiD\Event_mig_stock.gph", replace
graph export "$results_AllDiD\Event_mig_stock.pdf", as(pdf) name("Graph") replace
gen var = "mig_stock_Wool"
save "$results_AllDiD\Dataset_Event_mig_stock.gph", replace
restore

*** mig_flow1 
wooldid mig_flow1 bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off) espre(50) espost(50)

preserve
ereturn list
svmat e(b), names(b)
svmat e(V), names(V)

forvalues num = 1/84 {
	*display `num'
	rename V`num' V`num'_
	egen V`num' = max(V`num'_)
}

keep if _n == 1
keep b* V*
drop bdate bula bl_birth V*_

* Reshape
gen ID = 1
reshape long b V, i(ID) j(Time)

* Make SE
gen se = sqrt(V)
gen ub = b + 1.96*se
gen lb = b - 1.96*se
gen event = _n - 42

* Beautiful final touch
keep if inrange(event, -25, 25) // here: Decide final range of cohorts!
replace b = . if event == -1
replace se = . if event == -1
replace ub = . if event == -1
replace lb = . if event == -1

* Graph
twoway ///
	(rcap ub lb event, lcolor(gs8)) ///
	(scatter b event, mcolor(black) msymbol(0)), ///
	yline(0, lwidth(thin) lpattern(dash) ) xline(-1, lwidth(thin) lpattern(dash) ) ///
	xtitle("Event Time (Reform)") ///
	ytitle("ATT") ylab(,nogrid) xlab(,nogrid) ///
	title("1-Year Mobility: State") ///
	legend(off) 

* Save Graph
graph save "Graph" "$results_AllDiD\Event_mig_flow1.gph", replace
graph export "$results_AllDiD\Event_mig_flow1.pdf", as(pdf) name("Graph") replace
gen var = "mig_flow1_Wool"
save "$results_AllDiD\Dataset_Event_mig_flow1.gph", replace
restore

*** mig_flow5 
wooldid mig_flow5 bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off) espre(50) espost(50)

preserve
ereturn list
svmat e(b), names(b)
svmat e(V), names(V)

forvalues num = 1/84 {
	*display `num'
	rename V`num' V`num'_
	egen V`num' = max(V`num'_)
}

keep if _n == 1
keep b* V*
drop bdate bula bl_birth V*_

* Reshape
gen ID = 1
reshape long b V, i(ID) j(Time)

* Make SE
gen se = sqrt(V)
gen ub = b + 1.96*se
gen lb = b - 1.96*se
gen event = _n - 42

* Beautiful final touch
keep if inrange(event, -25, 25) // here: Decide final range of cohorts!
replace b = . if event == -1
replace se = . if event == -1
replace ub = . if event == -1
replace lb = . if event == -1

* Graph
twoway ///
	(rcap ub lb event, lcolor(gs8)) ///
	(scatter b event, mcolor(black) msymbol(0)), ///
	yline(0, lwidth(thin) lpattern(dash) ) xline(-1, lwidth(thin) lpattern(dash) ) ///
	xtitle("Event Time (Reform)") ///
	ytitle("ATT") ylab(,nogrid) xlab(,nogrid) ///
	title("5-Year Mobility: State") ///
	legend(off)

* Save Graph
graph save "Graph" "$results_AllDiD\Event_mig_flow5.gph", replace
graph export "$results_AllDiD\Event_mig_flow5.pdf", as(pdf) name("Graph") replace
gen var = "mig_flow5_Wool"
save "$results_AllDiD\Dataset_Event_mig_flow5.gph", replace
restore

*** mig_stock_kr 
wooldid mig_stock_kr bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off) espre(50) espost(50)

preserve
ereturn list
svmat e(b), names(b)
svmat e(V), names(V)

forvalues num = 1/84 {
	*display `num'
	rename V`num' V`num'_
	egen V`num' = max(V`num'_)
}

keep if _n == 1
keep b* V*
drop bdate bula bl_birth V*_

* Reshape
gen ID = 1
reshape long b V, i(ID) j(Time)

* Make SE
gen se = sqrt(V)
gen ub = b + 1.96*se
gen lb = b - 1.96*se
gen event = _n - 42

* Beautiful final touch
keep if inrange(event, -25, 25) // here: Decide final range of cohorts!
replace b = . if event == -1
replace se = . if event == -1
replace ub = . if event == -1
replace lb = . if event == -1

* Graph
twoway ///
	(rcap ub lb event, lcolor(gs8)) ///
	(scatter b event, mcolor(black) msymbol(0)), ///
	yline(0, lwidth(thin) lpattern(dash) ) xline(-1, lwidth(thin) lpattern(dash) ) ///
	xtitle("Event Time (Reform)") ///
	ytitle("ATT") ylab(,nogrid) xlab(,nogrid) ///
	title("Lifetime Mobility: County") ///
	legend(off)

* Save Graph
graph save "Graph" "$results_AllDiD\Event_mig_stock_kr.gph", replace
graph export "$results_AllDiD\Event_mig_stock_kr.pdf", as(pdf) name("Graph") replace
gen var = "mig_stock_kr_Wool"
save "$results_AllDiD\Dataset_Event_mig_stock_kr.gph", replace
restore

*** mig_flow1_kr 
wooldid mig_flow1_kr bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off) espre(50) espost(50)

preserve
ereturn list
svmat e(b), names(b)
svmat e(V), names(V)

forvalues num = 1/84 {
	*display `num'
	rename V`num' V`num'_
	egen V`num' = max(V`num'_)
}

keep if _n == 1
keep b* V*
drop bdate bula bl_birth V*_

* Reshape
gen ID = 1
reshape long b V, i(ID) j(Time)

* Make SE
gen se = sqrt(V)
gen ub = b + 1.96*se
gen lb = b - 1.96*se
gen event = _n - 42

* Beautiful final touch
keep if inrange(event, -25, 25) // here: Decide final range of cohorts!
replace b = . if event == -1
replace se = . if event == -1
replace ub = . if event == -1
replace lb = . if event == -1

* Graph
twoway ///
	(rcap ub lb event, lcolor(gs8)) ///
	(scatter b event, mcolor(black) msymbol(0)), ///
	yline(0, lwidth(thin) lpattern(dash) ) xline(-1, lwidth(thin) lpattern(dash) ) ///
	xtitle("Event Time (Reform)") ///
	ytitle("ATT") ylab(,nogrid) xlab(,nogrid) ///
	title("1-Year Mobility: County") ///
	legend(off)

* Save Graph
graph save "Graph" "$results_AllDiD\Event_mig_flow1_kr.gph", replace
graph export "$results_AllDiD\Event_mig_flow1_kr.pdf", as(pdf) name("Graph") replace
gen var = "mig_flow1_kr_Wool"
save "$results_AllDiD\Dataset_Event_mig_flow1_kr.gph", replace
restore

*** mig_flow5_kr
wooldid mig_flow5_kr bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off) espre(50) espost(50)

preserve
ereturn list
svmat e(b), names(b)
svmat e(V), names(V)

forvalues num = 1/84 {
	*display `num'
	rename V`num' V`num'_
	egen V`num' = max(V`num'_)
}

keep if _n == 1
keep b* V*
drop bdate bula bl_birth V*_

* Reshape
gen ID = 1
reshape long b V, i(ID) j(Time)

* Make SE
gen se = sqrt(V)
gen ub = b + 1.96*se
gen lb = b - 1.96*se
gen event = _n - 42

* Beautiful final touch
keep if inrange(event, -25, 25) // here: Decide final range of cohorts!
replace b = . if event == -1
replace se = . if event == -1
replace ub = . if event == -1
replace lb = . if event == -1

* Graph
twoway ///
	(rcap ub lb event, lcolor(gs8)) ///
	(scatter b event, mcolor(black) msymbol(0)), ///
	yline(0, lwidth(thin) lpattern(dash) ) xline(-1, lwidth(thin) lpattern(dash) ) ///
	xtitle("Event Time (Reform)") ///
	ytitle("ATT") ylab(,nogrid) xlab(,nogrid) ///
	title("5-Year Mobility: County") ///
	legend(off) 

* Save Graph
graph save "Graph" "$results_AllDiD\Event_mig_flow5_kr.gph", replace
graph export "$results_AllDiD\Event_mig_flow5_kr.pdf", as(pdf) name("Graph") replace
gen var = "mig_flow5_kr_Wool"
save "$results_AllDiD\Dataset_Event_mig_flow5_kr.gph", replace
restore

*** Graph Combine ***
graph combine "$results_AllDiD\Event_mig_flow1.gph" "$results_AllDiD\Event_mig_flow5.gph" "$results_AllDiD\Event_mig_stock.gph" /// 
	"$results_AllDiD\Event_mig_flow1_kr.gph" "$results_AllDiD\Event_mig_flow5_kr.gph" "$results_AllDiD\Event_mig_stock_kr.gph"


