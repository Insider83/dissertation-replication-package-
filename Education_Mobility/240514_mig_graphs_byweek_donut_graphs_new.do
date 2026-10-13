local word "weighted unweighted"
foreach ds of local word {
use "$results\mig_by_week_donut_`ds'_new.dta", clear
* convert excel sheet to stata-dataset


** migstock
preserve
keep if samp_migstock == 1
twoway scatter migstock run_week, color(gs8) || line fit0_migstock run_week if inrange(run_week,-24,-2), color(gs4%70) clcolor(blue)  || line fit1_migstock run_week if inrange(run_week,3,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.1 0.45)) ylabel(0.1(0.05)0.45) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Lifetime mobility", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\migstock_$date_donut_`ds'_new", replace
graph export "${graphs}\migstock_$date_donut_`ds'_new.pdf", replace
restore

** migstock_kr
preserve
keep if samp_migstock_kr == 1
twoway scatter migstock_kr run_week, color(gs8) || line fit0_migstock_kr run_week if inrange(run_week,-24,-2), color(gs4%70) clcolor(blue)  || line fit1_migstock_kr run_week if inrange(run_week,3,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.35 0.75)) ylabel(0.35(0.05)0.75) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Lifetime mobility", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\migstock_kr_$date_donut_`ds'_new", replace
graph export "${graphs}\migstock_kr_$date_donut_`ds'_new.pdf", replace
restore

** migflow1
preserve
keep if samp_migflow1 == 1
twoway scatter migflow1 run_week, color(gs8) || line fit0_migflow1 run_week if inrange(run_week,-24,-2), color(gs4%70) clcolor(blue)  || line fit1_migflow1 run_week if inrange(run_week,3,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.0 0.04)) ylabel(0.0(0.01)0.04) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("1-year-mobility", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\migflow1_$date_donut_`ds'_new", replace
graph export "${graphs}\migflow1_$date_donut_`ds'_new.pdf", replace
restore


** migflow1_kr
preserve
keep if samp_migflow1_kr == 1
twoway scatter migflow1_kr run_week, color(gs8) || line fit0_migflow1_kr run_week if inrange(run_week,-24,-2), color(gs4%70) clcolor(blue)  || line fit1_migflow1_kr run_week if inrange(run_week,3,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.02 0.06)) ylabel(0.02(0.01)0.06) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("1-year-mobility", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\migflow1_kr_$date_donut_`ds'_new", replace
graph export "${graphs}\migflow1_kr_$date_donut_`ds'_new.pdf", replace
restore

** migflow5
preserve
keep if samp_migflow5 == 1
twoway scatter migflow5 run_week, color(gs8) || line fit0_migflow5 run_week if inrange(run_week,-24,-2), color(gs4%70) clcolor(blue)  || line fit1_migflow5 run_week if inrange(run_week,3,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.00 0.12)) ylabel(0.00(0.02)0.12) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("5-year-mobility", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\migflow5_$date_donut_`ds'_new", replace
graph export "${graphs}\migflow5_$date_donut_`ds'_new.pdf", replace
restore


** migflow5_kr
preserve
keep if samp_migflow5_kr == 1
twoway scatter migflow5_kr run_week, color(gs8) || line fit0_migflow5_kr run_week if inrange(run_week,-24,-2), color(gs4%70) clcolor(blue)  || line fit1_migflow5_kr run_week if inrange(run_week,3,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.05 0.25)) ylabel(0.05(0.05)0.25) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("5-year-mobility", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\migflow5_kr_$date_donut_`ds'_new", replace
graph export "${graphs}\migflow5_kr_$date_donut_`ds'_new.pdf", replace
restore
}