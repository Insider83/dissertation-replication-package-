*********************Calculate enrolment***************************************


**********************1944-1986*************************************************
use "$results\ssa_eastandwest_19441986_obs1_new.dta", clear

cap drop entry_year_act entry_year_exp compliers
gen entry_year_act = year(start_sp1)
gen entry_year_exp = year(entry_6) 
gen compliers = entry_year_act == entry_year_exp
tab compliers 

gen early = (entry_year_act < entry_year_exp)
gen regular = (entry_year_act == entry_year_exp)
gen late = (entry_year_act > entry_year_exp)

*school enrollment in entire Germany
preserve
keep if inlist(entry_year_act,1976,1980,1985,1990)
keep if w_t4_cal != 0

gen N = 1
collapse early regular late (count) N [aweight = w_t4_cal], by(entry_year_act)
tabstat early regular late N, by(entry_year_act) nototal save format(%9.3f)
return list
putexcel set "$results\enrolment_new_$date.xlsx", replace
putexcel B2 = "early"
putexcel C2 = "regular"
putexcel D2 = "late"
putexcel E2 = "N"
putexcel A3 = "1976/77"
putexcel A4 = "1980/81"
putexcel A5 = "1985/86"
putexcel A6 = "1990/91)"
putexcel A1 = "School enrolment (entire Germany; 1944 - 1986; weighted)"
putexcel B3 = matrix(r(Stat1))
putexcel B4 = matrix(r(Stat2))
putexcel B5 = matrix(r(Stat3))
putexcel B6 = matrix(r(Stat4))



graph bar early regular late , 	over(entry_year_act) scheme(s1mono) stack /// 
								bar(1, color(gs8)) bar(2, color(black)) bar(3, color(blue)) ///
								blabel(bar, position(center) format(%9.0f) ) percent ///
								legend(label (1 "early") label (2 "regular") label (3 "late") rows(1))
								
gr_edit .plotregion1.barlabels[1].style.editstyle color(white) editcopy								
graph save "$graphs/enrolment_44to86_all_new.gph", replace
graph export "$graphs/enrolment_44to86_all_new.pdf", replace
restore


*school enrollment in West Germany
preserve
keep if inlist(entry_year_act,1976,1980,1985,1990)
keep if inrange(bula6,1,10)
keep if inrange(bl_birth,1,10)
keep if w_t4_cal != 0


gen N = 1
collapse early regular late (count) N [aweight = w_t4_cal], by(entry_year_act)
tabstat early regular late N, by(entry_year_act) nototal save format(%9.3f)
return list
putexcel set "$results\enrolment_new_$date.xlsx", modify
putexcel I2 = "early"
putexcel J2 = "regular"
putexcel K2 = "late"
putexcel L2 = "N"
putexcel H1 = "School enrolment (WEST Germany; 1944 - 1986; weighted)"
putexcel I4 = matrix(r(Stat2))
putexcel I3 = matrix(r(Stat1))
putexcel I5 = matrix(r(Stat3))
putexcel I6 = matrix(r(Stat4))



graph bar early regular late , 	over(entry_year_act) scheme(s1mono) stack /// 
								bar(1, color(gs8)) bar(2, color(black)) bar(3, color(blue)) ///
								blabel(bar, position(center) format(%9.0f) ) percent ///
								legend(label (1 "early") label (2 "regular") label (3 "late") rows(1))
								
gr_edit .plotregion1.barlabels[1].style.editstyle color(white) editcopy								
graph save "$graphs/enrolment_44to86_west_new.gph", replace
graph export "$graphs/enrolment_44to86_west_new.pdf", replace
restore


**********************1945-1964*************************************************
use "$results\ssa_eastandwest_19441986_obs1_new.dta", clear


cap drop entry_year_act entry_year_exp compliers
gen entry_year_act = year(start_sp1)
gen entry_year_exp = year(entry_6) 
gen compliers = entry_year_act == entry_year_exp
tab compliers 

gen early = (entry_year_act < entry_year_exp)
gen regular = (entry_year_act == entry_year_exp)
gen late = (entry_year_act > entry_year_exp)

	
*school enrollment in entire Germany
preserve
keep if edgeweek == 0
keep if inrange(yob,1945,1964)	
keep if w_t4_cal != 0
keep if inlist(entry_year_act,1955,1960,1965,1970)

gen N = 1
collapse early regular late (count) N [aweight = w_t4_cal], by(entry_year_act)
tabstat early regular late N, by(entry_year_act) nototal save format(%9.3f)
return list
putexcel set "$results\enrolment_new_$date.xlsx", modify
putexcel B10 = "early"
putexcel C10 = "regular"
putexcel D10 = "late"
putexcel E10 = "N"
putexcel A11 = "1955/56"
putexcel A12 = "1960/61"
putexcel A13 = "1965/66"
putexcel A14 = "1970/71"
putexcel A9 = "School enrolment (in entire Germany; 1945 - 1964; weighted)"
putexcel B11 = matrix(r(Stat1))
putexcel B12 = matrix(r(Stat2))
putexcel B13 = matrix(r(Stat3))
putexcel B14 = matrix(r(Stat4))



graph bar early regular late , 	over(entry_year_act) scheme(s1mono) stack /// 
								bar(1, color(gs8)) bar(2, color(black)) bar(3, color(blue)) ///
								blabel(bar, position(center) format(%9.0f) ) percent ///
								legend(label (1 "early") label (2 "regular") label (3 "late") rows(1))
								
gr_edit .plotregion1.barlabels[1].style.editstyle color(white) editcopy								
graph save "$graphs/enrolment_45to64_all_new.gph", replace
graph export "$graphs/enrolment_45to64_all_new.pdf", replace
restore	
	
	
	
	
	
*school enrollment in WEST Germany
preserve
keep if edgeweek == 0
keep if inrange(yob,1945,1964)	
keep if inrange(bula6,1,10)
keep if inrange(bl_birth,1,10)
keep if inlist(entry_year_act,1955,1960,1965,1970)
keep if w_t4_cal != 0

gen N = 1
collapse early regular late (count) N [aweight = w_t4_cal], by(entry_year_act)
tabstat early regular late N, by(entry_year_act) nototal save format(%9.3f)
return list
putexcel set "$results\enrolment_new_$date.xlsx", modify
putexcel I10 = "early"
putexcel J10 = "regular"
putexcel K10 = "late"
putexcel L10 = "N"
putexcel H9 = "School enrolment (in WEST Germany; 1945 - 1964; weighted)"
putexcel I11 = matrix(r(Stat1))
putexcel I12 = matrix(r(Stat2))
putexcel I13 = matrix(r(Stat3))
putexcel I14 = matrix(r(Stat4))



graph bar early regular late , 	over(entry_year_act) scheme(s1mono) stack /// 
								bar(1, color(gs8)) bar(2, color(black)) bar(3, color(blue)) ///
								blabel(bar, position(center) format(%9.0f) ) percent ///
								legend(label (1 "early") label (2 "regular") label (3 "late") rows(1))
								
gr_edit .plotregion1.barlabels[1].style.editstyle color(white) editcopy								
graph save "$graphs/enrolment_45to64_west_new.gph", replace
graph export "$graphs/enrolment_45to64_west_new.pdf", replace
restore	
	




*earlier school entry years in full sample
preserve
keep if edgeweek == 0
keep if inrange(yob,1944,1986)	
keep if inrange(bula6,1,10)
keep if inrange(bl_birth,1,10)
keep if inlist(entry_year_act,1955,1960,1965,1970)
keep if w_t4_cal != 0

gen N = 1
collapse early regular late (count) N [aweight = w_t4_cal], by(entry_year_act)
tabstat early regular late N, by(entry_year_act) nototal save format(%9.3f)
return list
putexcel set "$results\enrolment_new_$date.xlsx", modify
putexcel P10 = "early"
putexcel Q10 = "regular"
putexcel R10 = "late"
putexcel S10 = "N"
putexcel O9 = "School enrolment (in WEST Germany; 1944 - 1986; weighted)"
putexcel P11 = matrix(r(Stat1))
putexcel P12 = matrix(r(Stat2))
putexcel P13 = matrix(r(Stat3))
putexcel P14 = matrix(r(Stat4))
restore	
	
	
cd "$graphs"
graph combine  	enrolment_44to86_all.gph enrolment_44to86_west.gph ///
				enrolment_45to64_all.gph enrolment_45to64_west.gph, cols(2) scheme(s1mono)
	
gr_edit .plotregion1.graph1.title.style.editstyle size(medsmall) editcopy
gr_edit .plotregion1.graph1.title.text = {}
gr_edit .plotregion1.graph1.title.text.Arrpush All			

gr_edit .plotregion1.graph2.title.style.editstyle size(medsmall) editcopy
gr_edit .plotregion1.graph2.title.text = {}
gr_edit .plotregion1.graph2.title.text.Arrpush West Germany				

								
graph save "$graphs/enrolment_combined_new.gph", replace
graph export "$graphs/enrolment_combined_new.pdf", replace

								