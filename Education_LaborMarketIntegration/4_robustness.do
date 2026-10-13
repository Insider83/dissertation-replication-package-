* Davit Adunts, Truc Nguyen, Sebastian Vogler
*********************


                  *********************
			      * Robustness checks
			      *********************
				  
************************************************
*	Smoothness covariates
************************************************

use "$file/final_1",clear

keep if inrange(cont,-24,24) & year_de== 5

foreach v in $control arr_year{
bys cont: egen m_`v'= mean(`v')

}


// other outcomes

foreach v in male country1 country2 country3 ///
	country4 country5 country6 country7 country8 ///
	state1 state2 state3 state4 state5 state6 state7 state8 state9 ///
	state10 state11 state12 state13 state14 state15 state16 ///
	year2_1 year2_2 year2_3 year2_4 year2_5 year2_6 year2_7 { // birth_m2 birth_m3 birth_m4 birth_m5 birth_m6 birth_m7 birth_m8 birth_m9 birth_m10 birth_m11 birth_m12 /// 
	
graph twoway lpolyci m_`v' cont if cont<=0, clw(medthick) clc(red)  xline(0) k(tri) deg(1) bw(10) lp(dash)  xscale(range(-24,24)) xlabel(-24(4)24,nogrid) yscale(range(0,1)) ylabel(0(0.1)1) ///
	|| 	lpolyci m_`v' cont if cont>=0, clw(medthick) clc(red)  xline(0) k(tri) deg(1) bw(10) lp(dash) ///
	|| scatter m_`v' cont, msymbol(o) msize(large) mlcolor(black) mfcolor(black) legend(off) graphr(color(white)) ti("") xtitle("Relative Month at Arrival") ytitle("(mean)") plotregion(style(none)) graphregion(style(none) color(white) lwidth(none))
	
	gr export "$graph/cov_`v'.png",replace
	}

// age
	
graph twoway lpolyci m_age cont if cont<=0, clw(medthick) clc(red)  xline(0) k(tri) deg(1) bw(10) lp(dash)  xscale(range(-24,24)) xlabel(-24(4)24,nogrid) yscale(range(15,23)) ylabel(15(1)23) ///
	|| 	lpolyci m_age cont if cont>=0, clw(medthick) clc(red)  xline(0) k(tri) deg(1) bw(10) lp(dash) ///
	|| scatter m_age cont, msymbol(o) msize(large) mlcolor(black) mfcolor(black) legend(off) graphr(color(white)) ti("") xtitle("Relative Month at Arrival") ytitle("(mean)") plotregion(style(none)) graphregion(style(none) color(white) lwidth(none))
	
	gr export "$graph/cov_age.png",replace
	
// immigration year
	
graph twoway lpolyci m_arr_year cont if cont<=0, clw(medthick) clc(red)  xline(0) k(tri) deg(1) bw(10) lp(dash)  xscale(range(-24,24)) xlabel(-24(4)24,nogrid) yscale(range(2013,2017)) ylabel(2013(1)2017) ///
	|| 	lpolyci m_arr_year cont if cont>=0, clw(medthick) clc(red)  xline(0) k(tri) deg(1) bw(10) lp(dash) ///
	|| scatter m_arr_year cont, msymbol(o) msize(large) mlcolor(black) mfcolor(black) legend(off) graphr(color(white)) ti("") xtitle("Relative Month at Arrival") ytitle("(mean)") plotregion(style(none)) graphregion(style(none) color(white) lwidth(none))
	
	gr export "$graph/cov_arr_year.png",replace


	
graph twoway lpolyci m_birth_m cont if cont<=0, clw(medthick) clc(red)  xline(0) k(tri) deg(1) bw(10) lp(dash)  xscale(range(-24,24)) xlabel(-24(4)24,nogrid) yscale(range(1,12)) ylabel(1(1)12) ///
	|| 	lpolyci m_birth_m cont if cont>=0, clw(medthick) clc(red)  xline(0) k(tri) deg(1) bw(10) lp(dash) ///
	|| scatter m_birth_m cont, msymbol(o) msize(large) mlcolor(black) mfcolor(black) legend(off) graphr(color(white)) ti("") xtitle("Relative Month at Arrival") ytitle("(mean)") plotregion(style(none)) graphregion(style(none) color(white) lwidth(none))
	
	gr export "$graph/cov_birth_m.png",replace
	
********************************************************************************
*********************** Polynomial order 2
********************************************************************************
est clear
estimates dir	

use "$file/final_1",clear


foreach y in $outcome_jobqual $outcome_labor { 
		foreach i in 5 8 {
	* RKD main analysis
	
		reghdfe `y'_`i' v_over1 v_minus1 male age birth_m if year_de==`i' & inrange(cont,-24,24), a(state country_ref year2) vce(cluster state)
		est sto `y'_`i'

	* RKD polynomial 2nd order
	
		reghdfe `y'_`i' v_over1 v_minus1 v_minus2 v_over2 male birth_m age if year_de==`i' & inrange(cont,-24,24), a(state country_ref year2) vce(cluster state)
		est sto `y'_`i'_v2
}
}

	
// labor market

	coefplot (employed_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_5) offset(0.15)) ///
	(employed_5_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_5) offset(-0.15)) ///
	(employed_full_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_full_5) offset(0.15)) ///
	(employed_full_5_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_full_5) offset(-0.15)) ///
	(employed_part_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_part_5) offset(0.15)) ///
	(employed_part_5_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_part_5) offset(-0.15)) ///
	(employed_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_8) offset(0.15)) ///
	(employed_8_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_8) offset(-0.15)) ///
	(employed_full_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_full_8) offset(0.15)) ///
	(employed_full_8_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_full_8) offset(-0.15)) ///
	(employed_part_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_part_8) offset(0.15)) ///
	(employed_part_8_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_part_8) offset(-0.15)) ///
	 , drop(_cons) norecycle ///
	 coeflabels(employed_5="Being Employed" employed_full_5="Being Employed: Full-time" employed_part_5="Being Employed: Part-time" employed_8 ="Being Employed" employed_full_8="Being Employed: Full-time" employed_part_8="Being Employed: Part-time", labsize(vsmall) labgap(0.3)) ///
	groups($outcome_labor_5= "{bf:Labor - 5 years}" $outcome_labor_8= "{bf:Labor - 8 years}",gap(0.5) angle(90)) ///
	ylab(,labsize(vsmall)) ysc(outergap(0)) ///	
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0,lwidth(thin)) grid(w) title(`title_`y'') ///
	xtitle("Treatment effect",size(vsmall)) ///
	legend(order(2 "Baseline" 4 "2nd-order polynomial") size(vsmall) rows(1) position(6)) omitted baselevels ///
	xscale(r(-0.01 -0.005 0.005 0.01)) xtick(-0.01(0.005)0.01) ///
	xlabel(-0.01 -0.005 0 0.005 0.01,labsize(vsmall))
	gr export "$graph/rkd_rb2_labor.png",replace




// job quality 


	coefplot (entgelt_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= entgelt_5) offset(0.15)) ///
	(entgelt_5_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= entgelt_5) offset(-0.15)) ///
	(year_days_emp_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_emp_5) offset(0.15)) ///
	(year_days_emp_5_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_emp_5) offset(-0.15)) ///
	(year_days_benefits_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_benefits_5) offset(0.15)) ///
	(year_days_benefits_5_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_benefits_5) offset(-0.15)) ///
	(entgelt_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= entgelt_8) offset(0.15)) ///
	(entgelt_8_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= entgelt_8) offset(-0.15)) ///
	(year_days_emp_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_emp_8) offset(0.15)) ///
	(year_days_emp_8_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_emp_8) offset(-0.15)) ///
	(year_days_benefits_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_benefits_8) offset(0.15)) ///
	(year_days_benefits_8_v2,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_benefits_8) offset(-0.15)) ///
	 , drop(_cons) norecycle ///
	 coeflabels(entgelt_5="Daily salary(euro)" year_days_emp_5="Days Employed" year_days_benefits_5="Days on Benefit" entgelt_8 ="Daily salary(euro)" year_days_emp_8="Days Employed" year_days_benefits_8="Days on Benefit", labsize(vsmall) labgap(0.3)) ///
	groups($outcome_jobqual_5= "{bf:Job quality - 5 years}" $outcome_jobqual_8= "{bf:Job quality - 8 years}",gap(0.5) angle(90)) ///
	ylab(,labsize(vsmall)) ysc(outergap(0)) ///	
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0,lwidth(thin)) grid(w) title(`title_`y'') ///
	xtitle("Treatment effect",size(vsmall)) ///
	legend(order(2 "Baseline" 4 "2nd-order polynomial") size(vsmall) rows(1) position(6)) omitted baselevels ///
	xscale(r(-2.5 2.5)) xtick(-2.5(0.5)2.5) ///
	xlabel(-2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5,labsize(vsmall))
	gr export "$graph/rkd_rb2_jobqual.png",replace
	
	
********************************************************************************
********** Insitutional setting - drop states with different waiting time
********************************************************************************	
est clear
estimates dir

capture drop v4 v3
gen v3=.
replace v3= 1 if inlist(state,12,4,6,13,3,5,7,14,15) //Robustness check for institutional variation
//Brandenburg, Bremen, Hesse, Mecklenburg-Western Pomerania, Lower Saxony, North Rhine-Westphalia, Rhineland-Palatinate, Saxony, and Saxony-Anhalt


foreach y in $outcome_jobqual $outcome_labor { 
		foreach i in 5 8 {
	* RKD main analysis
	
		reghdfe `y'_`i' v_over1 v_minus1 male age birth_m if year_de==`i' & inrange(cont,-24,24), a(state country_ref year2) vce(cluster state)
		est sto `y'_`i'

	* RKD institutional setting
	
		reghdfe `y'_`i' v_over1 v_minus1 male age birth_m if year_de==`i' & inrange(cont,-24,24) & v3==1, a(state country_ref year2) vce(cluster state)
		est sto `y'_`i'_v3
}
}



// labor market
	coefplot (employed_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_5) offset(0.15)) ///
	(employed_5_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_5) offset(-0.15)) ///
	(employed_full_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_full_5) offset(0.15)) ///
	(employed_full_5_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_full_5) offset(-0.15)) ///
	(employed_part_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_part_5) offset(0.15)) ///
	(employed_part_5_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_part_5) offset(-0.15)) ///
	(employed_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_8) offset(0.15)) ///
	(employed_8_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_8) offset(-0.15)) ///
	(employed_full_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_full_8) offset(0.15)) ///
	(employed_full_8_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_full_8) offset(-0.15)) ///
	(employed_part_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_part_8) offset(0.15)) ///
	(employed_part_8_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_part_8) offset(-0.15)) ///
	 , drop(_cons) norecycle ///
	 coeflabels(employed_5="Being Employed" employed_full_5="Being Employed: Full-time" employed_part_5="Being Employed: Part-time" employed_8 ="Being Employed" employed_full_8="Being Employed: Full-time" employed_part_8="Being Employed: Part-time", labsize(vsmall) labgap(0.3)) ///
	groups($outcome_labor_5= "{bf:Labor - 5 years}" $outcome_labor_8= "{bf:Labor - 8 years}",gap(0.5) angle(90)) ///
	ylab(,labsize(vsmall)) ysc(outergap(0)) ///	
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0,lwidth(thin)) grid(w) title(`title_`y'') ///
	xtitle("Treatment effect",size(vsmall)) ///
	legend(order(2 "Baseline" 4 "Institutional setting") size(vsmall) rows(1) position(6)) omitted baselevels ///
	xscale(r(-0.01 -0.005 0.005 0.01)) xtick(-0.01(0.005)0.01) ///
	xlabel(-0.01 -0.005 0 0.005 0.01,labsize(vsmall))
	gr export "$graph/rkd_rb3_labor.png",replace




// job quality 
	coefplot (entgelt_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= entgelt_5) offset(0.15)) ///
	(entgelt_5_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= entgelt_5) offset(-0.15)) ///
	(year_days_emp_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_emp_5) offset(0.15)) ///
	(year_days_emp_5_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_emp_5) offset(-0.15)) ///
	(year_days_benefits_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_benefits_5) offset(0.15)) ///
	(year_days_benefits_5_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_benefits_5) offset(-0.15)) ///
	(entgelt_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= entgelt_8) offset(0.15)) ///
	(entgelt_8_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= entgelt_8) offset(-0.15)) ///
	(year_days_emp_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_emp_8) offset(0.15)) ///
	(year_days_emp_8_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_emp_8) offset(-0.15)) ///
	(year_days_benefits_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_benefits_8) offset(0.15)) ///
	(year_days_benefits_8_v3,keep(v_over1) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_benefits_8) offset(-0.15)) ///
	 , drop(_cons) norecycle ///
	 coeflabels(entgelt_5="Daily salary(euro)" year_days_emp_5="Days Employed" year_days_benefits_5="Days on Benefit" entgelt_8 ="Daily salary(euro)" year_days_emp_8="Days Employed" year_days_benefits_8="Days on Benefit", labsize(vsmall) labgap(0.3)) ///
	groups($outcome_jobqual_5= "{bf:Job quality - 5 years}" $outcome_jobqual_8= "{bf:Job quality - 8 years}",gap(0.5) angle(90)) ///
	ylab(,labsize(vsmall)) ysc(outergap(0)) ///	
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0,lwidth(thin)) grid(w) title(`title_`y'') ///
	xtitle("Treatment effect",size(vsmall)) ///
	legend(order(2 "Baseline" 4 "Institutional setting") size(vsmall) rows(1) position(6)) omitted baselevels ///
	xscale(r(-2.5 2.5)) xtick(-2.5(0.5)2.5) ///
	xlabel(-2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5,labsize(vsmall))
	gr export "$graph/rkd_rb3_jobqual.png",replace

	
	
********************************************************************************
********** Cluster
********************************************************************************	
est clear
est dir


foreach y in $outcome_labor $outcome_jobqual { // 
		foreach i in 5 8 {

	* RKD main analysis
	
		reghdfe `y'_`i' v_over1 v_minus1 male age birth_m if year_de==`i' & inrange(cont,-24,24), a(state country_ref year2) vce(cluster state)
		est sto `y'_`i'
		
	* Cluster at the running variable level Lee and Card (2008)
	
		reghdfe `y'_`i' v_over1 v_minus1 male age birth_m if year_de==`i' & inrange(cont,-24,24), a(state country_ref year2) vce(cluster cont)
		est sto `y'_`i'_v2

	* Eicker-White-Huber cluster Kolesar and Rothe et al. (2019)
	
		areg `y'_`i' v_over1 v_minus1 male age birth_m i.state i.country_ref if year_de==`i' & inrange(cont,-24,24), a(year2) robust
		est sto `y'_`i'_v3
		
	* Wild bootstrap
	
*		areg `y' v_over1 v_minus1 i.age male birth_m i.country_ref, a(state) vce(cluster cont)
		mata : mata clear
		capture drop dist*

		areg `y'_`i' v_over1 v_minus1 male age birth_m i.state i.country_ref if year_de==`i' & inrange(cont,-24,24), a(year2) vce(cluster state)
		set seed 2309487 // for exact reproducibility of results
		boottest v_over1, reps (999) cluster(state) bootcluster(state) svmat nograph
		return list
		*display r(b)
		matrix ci= r(CI)
		matrix list ci
		scalar ci_1= ci[1,1]
		scalar ci_2= ci[1,2]
		matrix `y'_`i'_v4 = (r(b) \ ci_1 \ ci_2)
		matrix list `y'_`i'_v4

}	
}
	
	
// labor
	coefplot (employed_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_5) offset(0.3)) ///
	(employed_5_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= employed_5) offset(0.15)) ///
	(employed_5_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= employed_5) offset(0)) ///
	(matrix(employed_5_v4), ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_5) offset(-0.15)) 	///
	(employed_full_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_full_5) offset(0.3)) ///
	(employed_full_5_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= employed_full_5) offset(0.15)) ///
	(employed_full_5_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= employed_full_5) offset(0)) ///
	(matrix(employed_full_5_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_full_5) offset(-0.15)) ///
	(employed_part_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_part_5) offset(0.3)) ///
	(employed_part_5_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= employed_part_5) offset(0.15)) ///
	(employed_part_5_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= employed_part_5) offset(0)) ///
	(matrix(employed_part_5_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_part_5) offset(-0.15)) ///
	(employed_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_8) offset(0.3)) ///
	(employed_8_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= employed_8) offset(0.15)) ///
	(employed_8_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= employed_8) offset(0)) ///
	(matrix(employed_8_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_8) offset(-0.15)) ///
	(employed_full_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_full_8) offset(0.3)) ///
	(employed_full_8_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= employed_full_8) offset(0.15)) ///
	(employed_full_8_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= employed_full_8) offset(0)) ///
	(matrix(employed_full_8_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_full_8) offset(-0.15)) ///
	(employed_part_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_part_8) offset(0.3)) ///
	(employed_part_8_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= employed_part_8) offset(0.15)) ///
	(employed_part_8_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= employed_part_8) offset(0)) ///
	(matrix(employed_part_8_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= employed_part_8) offset(-0.15)) ///
	 , drop(_cons) norecycle  ///
	 coeflabels(employed_5="Being Employed" employed_full_5="Being Employed: Full-time" employed_part_5="Being Employed: Part-time" employed_8 ="Being Employed" employed_full_8="Being Employed: Full-time" employed_part_8="Being Employed: Part-time", labsize(vsmall) labgap(0.3)) ///
	groups($outcome_labor_5= "{bf:Labor - 5 years}" $outcome_labor_8= "{bf:Labor - 8 years}",gap(0.5) angle(90)) ///
	ylab(,labsize(vsmall)) ysc(outergap(0)) ///	
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0,lwidth(thin)) grid(w) title(`title_`y'') ///
	xtitle("Treatment effect",size(vsmall)) ///
	legend(order(2 "Baseline" 4 "CRV" 6 "EWH" 8 "WCB") size(vsmall) rows(2) position(6)) omitted baselevels ///
	xscale(r(-0.01 -0.005 0.005 0.01)) xtick(-0.01(0.005)0.01) ///
	xlabel(-0.01 -0.005 0 0.005 0.01,labsize(vsmall))
	gr export "$graph/rkd_rb4_labor.png",replace
	
	
// job quality
	coefplot (entgelt_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= entgelt_5) offset(0.3)) ///
	(entgelt_5_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= entgelt_5) offset(0.15)) ///
	(entgelt_5_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= entgelt_5) offset(0)) ///
	(matrix(entgelt_5_v4), ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= entgelt_5) offset(-0.15)) 	///
	(year_days_benefits_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_benefits_5) offset(0.3)) ///
	(year_days_benefits_5_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= year_days_benefits_5) offset(0.15)) ///
	(year_days_benefits_5_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= year_days_benefits_5) offset(0)) ///
	(matrix(year_days_benefits_5_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_benefits_5) offset(-0.15)) ///
	(year_days_emp_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_emp_5) offset(0.3)) ///
	(year_days_emp_5_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= year_days_emp_5) offset(0.15)) ///
	(year_days_emp_5_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= year_days_emp_5) offset(0)) ///
	(matrix(year_days_emp_5_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_emp_5) offset(-0.15)) ///
	(entgelt_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= entgelt_8) offset(0.3)) ///
	(entgelt_8_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= entgelt_8) offset(0.15)) ///
	(entgelt_8_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= entgelt_8) offset(0)) ///
	(matrix(entgelt_8_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= entgelt_8) offset(-0.15)) ///
	(year_days_benefits_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_benefits_8) offset(0.3)) ///
	(year_days_benefits_8_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= year_days_benefits_8) offset(0.15)) ///
	(year_days_benefits_8_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= year_days_benefits_8) offset(0)) ///
	(matrix(year_days_benefits_8_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_benefits_8) offset(-0.15)) ///
	(year_days_emp_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_emp_8) offset(0.3)) ///
	(year_days_emp_8_v2,keep(v_over1) msymbol(+) mcolor(dkgreen) ciopts(lcolor(dkgreen)) rename(v_over1= year_days_emp_8) offset(0.15)) ///
	(year_days_emp_8_v3,keep(v_over1) msymbol(o) mcolor(maroon) ciopts(lcolor(maroon)) rename(v_over1= year_days_emp_8) offset(0)) ///
	(matrix(year_days_emp_8_v4),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(v_over1= year_days_emp_8) offset(-0.15)) ///
	 , drop(_cons) norecycle  ///
	 coeflabels(entgelt_5="Daily salary(euro)" year_days_emp_5="Days Employed" year_days_benefits_5="Days on Benefit" entgelt_8 ="Daily salary(euro)" year_days_emp_8="Days Employed" year_days_benefits_8="Days on Benefit", labsize(vsmall) labgap(0.3)) ///
	groups($outcome_jobqual_5= "{bf:Job quality - 5 years}" $outcome_jobqual_8= "{bf:Job quality - 8 years}",gap(0.5) angle(90)) ///
	ylab(,labsize(vsmall)) ysc(outergap(0)) ///	
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0,lwidth(thin)) grid(w) title(`title_`y'') ///
	xtitle("Treatment effect",size(vsmall)) ///
	legend(order(2 "Baseline" 4 "CRV" 6 "EWH" 8 "WCB") size(vsmall) rows(2) position(6)) omitted baselevels ///
	xscale(r(-7 7)) xtick(-7(1)7) ///
	xlabel(-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7,labsize(vsmall))	
	gr export "$graph/rkd_rb4_jobqual.png",replace	

	
********************************************************************************
*********************** rd robust
********************************************************************************
est clear
estimates dir	

foreach y in $outcome_jobqual $outcome_labor { 
		foreach i in 5 8 {
	* RKD main analysis
	
		reghdfe `y'_`i' v_over1 v_minus1 male birth_m age if year_de==`i' & inrange(cont,-24,24), a(state country_ref year2) vce(cluster state)
		est sto `y'_`i'

	* RKD polynomial 2nd order
	
		rdrobust `y'_`i' cont cov($control) if year_de==`i' & inrange(cont,-60,60), deriv(1) bwselect(mserd) p(1) masspoints(check) vce(cluster state) c(0) kernel(triangular) all
		*est sto `y'_`i'_v5 //*e(tau_bc) , e(se_tau_rb), e(pv_rb), e(ci_l_rb), e(ci_r_rb)
		matrix `y'_`i'_v5 = (-e(tau_bc) \ -e(ci_r_rb)\ -e(ci_l_rb))
		matrix list `y'_`i'_v5
}
}

// labor market
	coefplot (employed_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_5) offset(0.15)) ///
	(matrix(employed_5_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= employed_5) offset(-0.15)) ///
	(employed_full_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_full_5) offset(0.15)) ///
	(matrix(employed_full_5_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= employed_full_5) offset(-0.15)) ///
	(employed_part_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_part_5) offset(0.15)) ///
	(matrix(employed_part_5_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= employed_part_5) offset(-0.15)) ///
	(employed_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_8) offset(0.15)) ///
	(matrix(employed_8_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= employed_8) offset(-0.15)) ///
	(employed_full_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_full_8) offset(0.15)) ///
	(matrix(employed_full_8_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= employed_full_8) offset(-0.15)) ///
	(employed_part_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= employed_part_8) offset(0.15)) ///
	(matrix(employed_part_8_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= employed_part_8) offset(-0.15)) ///
	 , drop(_cons) norecycle ///
	 coeflabels(employed_5="Being Employed" employed_full_5="Being Employed: Full-time" employed_part_5="Being Employed: Part-time" employed_8 ="Being Employed" employed_full_8="Being Employed: Full-time" employed_part_8="Being Employed: Part-time", labsize(vsmall) labgap(0.3)) ///
	groups($outcome_labor_5= "{bf:Labor - 5 years}" $outcome_labor_8= "{bf:Labor - 8 years}",gap(0.5) angle(90)) ///
	ylab(,labsize(vsmall)) ysc(outergap(0)) ///	
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0,lwidth(thin)) grid(w) title(`title_`y'') ///
	xtitle("Treatment effect",size(vsmall)) ///
	legend(order(2 "Baseline" 4 "Local linear regression") size(vsmall) rows(1) position(6)) omitted baselevels ///
	xscale(r(-0.015 -0.01 -0.005 0 0.005 0.01 0.015 0.02 0.025)) xtick(-0.015(0.005)0.025) ///
	xlabel(-0.015 -0.01 -0.005 0 0.005 0.01 0.015 0.02 0.025,labsize(vsmall))
	gr export "$graph/rkd_rb5_labor.png",replace


// job quality 
	coefplot (entgelt_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= entgelt_5) offset(0.15)) ///
	(matrix(entgelt_5_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= entgelt_5) offset(-0.15)) ///
	(year_days_emp_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_emp_5) offset(0.15)) ///
	(matrix(year_days_emp_5_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= year_days_emp_5) offset(-0.15)) ///
	(year_days_benefits_5,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_benefits_5) offset(0.15)) ///
	(matrix(year_days_benefits_5_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= year_days_benefits_5) offset(-0.15)) ///
	(entgelt_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= entgelt_8) offset(0.15)) ///
	(matrix(entgelt_8_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= entgelt_8) offset(-0.15)) ///
	(year_days_emp_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_emp_8) offset(0.15)) ///
	(matrix(year_days_emp_8_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= year_days_emp_8) offset(-0.15)) ///
	(year_days_benefits_8,keep(v_over1) msymbol(d) mcolor(black) ciopts(lcolor(black)) rename(v_over1= year_days_benefits_8) offset(0.15)) ///
	(matrix(year_days_benefits_8_v5),ci((2 3)) msymbol(t) mcolor(navy) ciopts(lcolor(navy)) rename(c1= year_days_benefits_8) offset(-0.15)) ///
	 , drop(_cons) norecycle ///
	 coeflabels(entgelt_5="Daily salary(euro)" year_days_emp_5="Days Employed" year_days_benefits_5="Days on Benefit" entgelt_8 ="Daily salary(euro)" year_days_emp_8="Days Employed" year_days_benefits_8="Days on Benefit", labsize(vsmall) labgap(0.3)) ///
	groups($outcome_jobqual_5= "{bf:Job quality - 5 years}" $outcome_jobqual_8= "{bf:Job quality - 8 years}",gap(0.5) angle(90)) ///
	ylab(,labsize(vsmall)) ysc(outergap(0)) ///	
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0,lwidth(thin)) grid(w) title(`title_`y'') ///
	xtitle("Treatment effect",size(vsmall)) ///
	legend(order(2 "Baseline" 4 "Local linear regression") size(vsmall) rows(1) position(6)) omitted baselevels ///
	xscale(r(-5 5)) xtick(-5(1)5) ///
	xlabel(-5 -4 -3 -2 -1 0 1 2 3 4 5,labsize(vsmall))
	gr export "$graph/rkd_rb5_jobqual.png",replace
	
	
********************************************************************************
*********************** Density - Manipulation checks
********************************************************************************
est clear
estimates dir
	*matrix drop _all
	matrix p_value1_5= (.)
	matrix p_value1_8= (.)
	
	matrix p_value2_5= (.)
	matrix p_value2_8= (.)
	
	matrix p_value3_5= (.)
	matrix p_value3_8= (.)
	
	
foreach i in 5 8 {
	foreach y in $outcome_labor $outcome_jobqual{
		
	*matrix p_value_`i' = (.,.,.)
	
	rddisttestk cont if `y'_`i'!=. & year_de== `i',threshold(0) k(0)
	local p : display %12.3f r(p)
	matrix p_value1_`i'= p_value1_`i'\(`p')
	
	rddisttestk cont if `y'_`i'!=. & year_de== `i',threshold(0) k(0.01)
	local p : display %12.3f r(p)
	matrix p_value2_`i'= p_value2_`i'\(`p')
	
	rddisttestk cont if `y'_`i'!=. & year_de== `i',threshold(0) k(0.02)
	local p : display %12.3f r(p)
	matrix p_value3_`i'= p_value3_`i'\(`p')
		}
	}

	matrix p_value1= p_value1_5\p_value1_8
	matrix list p_value1
	
	matrix p_value2= p_value2_5\p_value2_8
	matrix list p_value2

	matrix p_value3= p_value3_5\p_value3_8
	matrix list p_value3
	
	matrix p_value= p_value1,p_value2,p_value3
	matrix list p_value
	
	
	*mata : mata clear
	capture drop bvector*
	svmat float p_value, name(bvector)
	matrix rownames p_value = "Year=5" "Being Employed" "Being employed: Full-time" "Being employed: Part-time" "Daily salary(euro)" "Days Employed" "Days on Benefit" "Year=8" "Being Employed" "Being employed: Full-time" "Being employed: Part-time" "Daily salary(euro)" "Days Employed" "Days on Benefit"
	matrix colnames p_value = "K=0" "K=0.01" "K=0.02"

local title1a "Manipulation check"

esttab matrix(p_value,fmt(%8.3f)) using "$output/robustness/rkd_rb6_density.tex",replace ///
	title(`title1a') ///
	eqlab(none) nomtitles ///
	addn(Note)

	
*** Histogram ghraphs for each outcome
use "$file/final_1",clear

foreach y in $outcome_educ $outcome_labor $outcome_jobqual {
	
		foreach i in 5 8 {
			
	tw (hist cont,blcolor(black) color(none)) (scatteri 0 0 0.1 0, c(l) m(i)) if inrange(cont,-24,24) & `y'_`i'!=., legend(off) xtitle("Relative Month at Arrival") ///
	  graphregion(color(white)) xscale(r(-24 24)) xtick(-24(4)24) ///
		xlabel(-24(4)24,labsize(small)) ///
		name(`y'`i',replace) title(``y'`i'',position(11) size(medium))
		*title(p-value=`p',position(1) size(small)) xline(-10 10,lpattern(dash)) 
	local graphs "`graphs' `y'`i'"
	graph export "$graph\hist_cont_`y'`i'.png", replace
	
		}
}
	
	
*** Multiple hypothesis test ***********************************************************
***************************************************************************
est clear
set seed 20240611

***TABLE 1 - Analysis

foreach y in $outcome_labor $outcome_jobqual{ // 
		foreach i in 5 8 {
	* RKD main analysis
	
		reghdfe `y'_`i' v_over1 v_minus1 male age birth_m if year_de==`i' & inrange(cont,-24,24), a(state country_ref year2) vce(cluster state)
		est sto `y'_`i'
		}
}

estimates clear

global mh5 "v_over1 v_minus1 birth_m male age if year_de==5 & inrange(cont,-24,24), a(state country_ref year2) vce(cluster state)"
global mh8 "v_over1 v_minus1 birth_m male age if year_de==8 & inrange(cont,-24,24), a(state country_ref year2) vce(cluster state)"


set seed 123456789
rwolf2 (reghdfe haupt_cer_5 $mh5) ///
	(reghdfe mittler_cer_5 $mh5) ///
	(reghdfe ausbildung_5 $mh5) ///
	(reghdfe employed_5 $mh5) ///
	(reghdfe employed_full_5 $mh5) ///
	(reghdfe employed_part_5 $mh5) ///
	(reghdfe entgelt_5 $mh5) ///
	(reghdfe year_days_emp_5 $mh5) ///
	(reghdfe year_days_benefits_5 $mh5) ///
	(reghdfe haupt_cer_8 $mh8) ///	
	(reghdfe mittler_cer_8 $mh8) ///	
	(reghdfe ausbildung_8 $mh8) ///	
	(reghdfe employed_8 $mh8) ///	
	(reghdfe employed_full_8 $mh8) ///	
	(reghdfe employed_part_8 $mh8) ///	
	(reghdfe entgelt_8 $mh8) ///	
	(reghdfe year_days_emp_8 $mh8) ///	
	(reghdfe year_days_benefits_8 $mh8) ///	
	, indepvars(v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1,v_over1) ///
	reps(1000) nodots //graph
	
matrix list e(RW)
matrix c = e(RW)
svmat float c, name(bvector)
matrix rownames c = "Highest degree: Lower Secondary" "Highest degree: Intermediate" "Ever enroll: Apprenticeship" "Being Employed" "Being employed: Full-time" "Being employed: Part-time" "Daily salary(euro)" "Days Employed" "Days on Benefit" "Highest degree: Lower Secondary" "Highest degree: Intermediate" "Ever enroll: Apprenticeship" "Being Employed" "Being employed: Full-time" "Being employed: Part-time" "Daily salary(euro)" "Days Employed" "Days on Benefit"
matrix colnames c = "Model p-value" "Resample p-value" "Romano-Wolf p-value"

local title1a "Multiple hypothesis test"

esttab matrix(c,fmt(%8.3f)) using "$output/robustness/rkd_rb1_mh_test.tex",replace ///
	title(`title1a') ///
	eqlab(none) nomtitles ///
	addn(Note)