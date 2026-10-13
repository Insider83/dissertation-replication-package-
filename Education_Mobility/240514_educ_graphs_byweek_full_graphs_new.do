local word "weighted unweighted"
foreach ds of local word {
use "$results\educ_by_week_full_`ds'_new.dta", clear


** aase
preserve
keep if samp_aase == 1
twoway scatter aase run_week, color(gs8) || line fit0_aase run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_aase run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(6.2 6.7)) ylabel(6.2(0.1)6.7) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Age at school entry", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\aase_$date_full_`ds'_new", replace
graph export "${graphs}\aase_$date_full_`ds'_new.pdf", replace
restore

** aase_2
preserve
keep if samp_aase_2 == 1
twoway scatter aase_2 run_week, color(gs8) || line fit0_aase_2 run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_aase_2 run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(6.2 6.7)) ylabel(6.2(0.1)6.7) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Age at school entry", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\aase_2_$date_full_`ds'_new", replace
graph export "${graphs}\aase_2_$date_full_`ds'_new.pdf", replace
restore

** aase_3
preserve
keep if samp_aase_3 == 1
twoway scatter aase_3 run_week, color(gs8) || line fit0_aase_3 run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_aase_3 run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(6.2 6.7)) ylabel(6.2(0.1)6.7) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Age at school entry", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\aase_3_$date_full_`ds'_new", replace
graph export "${graphs}\aase_3_$date_full_`ds'_new.pdf", replace
restore


** older
preserve
keep if samp_older == 1
twoway scatter older run_week, color(gs8) || line fit0_older run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_older run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.1 0.9)) ylabel(0.1(0.1)0.9) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Old for grade", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\older_$date_full_`ds'_new", replace
graph export "${graphs}\older_$date_full_`ds'_new.pdf", replace
restore

** compliers
preserve
keep if samp_compliers == 1
twoway scatter compliers run_week, color(gs8) || line fit0_compliers run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_compliers run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.3 0.9)) ylabel(0.3(0.1)0.9) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Compliance", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\compliers_$date_full_`ds'_new", replace
graph export "${graphs}\compliers_$date_full_`ds'_new.pdf", replace
restore


** acadt
preserve
keep if samp_acadt == 1
twoway scatter acadt run_week, color(gs8) || line fit0_acadt run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_acadt run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.1 0.5)) ylabel(0.1(0.1)0.5) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Abitur (Kamila, orig)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\acadt_$date_full_`ds'_new", replace
graph export "${graphs}\acadt_$date_full_`ds'_new.pdf", replace
restore


** acadt_filled
preserve
keep if samp_acadt_filled == 1
twoway scatter acadt_filled run_week, color(gs8) || line fit0_acadt_filled run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_acadt_filled run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.1 0.5)) ylabel(0.1(0.1)0.5) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Abitur (Kamila, missing as zero)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\acadt_filled_$date_full_`ds'_new", replace
graph export "${graphs}\acadt_filled_$date_full_`ds'_new.pdf", replace
restore


** abi_sectrack
preserve
keep if samp_abi_sectrack == 1
twoway scatter abi_sectrack run_week, color(gs8) || line fit0_abi_sectrack run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_abi_sectrack run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.1 0.5)) ylabel(0.1(0.1)0.5) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Abitur (Anton, orig)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\abi_sectrack_$date_full_`ds'_new", replace
graph export "${graphs}\abi_sectrack_$date_full_`ds'_new.pdf", replace
restore

** abi_sectrack_max
preserve
keep if samp_abi_sectrack_max == 1
twoway scatter abi_sectrack_max run_week, color(gs8) || line fit0_abi_sectrack_max run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_abi_sectrack_max run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.2 0.6)) ylabel(0.2(0.1)0.6) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Abitur (highest school degree)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\abi_sectrack_max_$date_full_`ds'_new", replace
graph export "${graphs}\abi_sectrack_max_$date_full_`ds'_new.pdf", replace
restore

** hs1
preserve
keep if samp_hs1 == 1
twoway scatter hs1 run_week, color(gs8) || line fit0_hs1 run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_hs1 run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.2 0.6)) ylabel(0.2(0.1)0.6) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Basic degree", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\hs1_$date_full_`ds'_new", replace
graph export "${graphs}\hs1_$date_full_`ds'_new.pdf", replace
restore

** rs1
preserve
keep if samp_rs1 == 1
twoway scatter rs1 run_week, color(gs8) || line fit0_rs1 run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_rs1 run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.1 0.5)) ylabel(0.1(0.1)0.5) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Middle degree", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\rs1_$date_full_`ds'_new", replace
graph export "${graphs}\rs1_$date_full_`ds'_new.pdf", replace
restore

** abi
preserve
keep if samp_abi == 1
twoway scatter abi run_week, color(gs8) || line fit0_abi run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_abi run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.0 0.4)) ylabel(0.0(0.1)0.4) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("High school degree", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\abi_$date_full_`ds'_new", replace
graph export "${graphs}\abi_$date_full_`ds'_new.pdf", replace
restore


** YOS1_Sum
preserve
keep if samp_YOS1_Sum == 1
twoway scatter YOS1_Sum run_week, color(gs8) || line fit0_YOS1_Sum run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_YOS1_Sum run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(9.0 10.5)) ylabel(9.0(0.25)10.5) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Years of schooling (Sebastian)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\YOS1_Sum_$date_full_`ds'_new", replace
graph export "${graphs}\YOS1_Sum_$date_full_`ds'_new.pdf", replace
restore

** YOS2_Sum
preserve
keep if samp_YOS2_Sum == 1
twoway scatter YOS2_Sum run_week, color(gs8) || line fit0_YOS2_Sum run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_YOS2_Sum run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(9.0 10.5)) ylabel(9.0(0.25)10.5) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Years of schooling (Sebastian; without half percentiles)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\YOS2_Sum_$date_full_`ds'_new", replace
graph export "${graphs}\YOS2_Sum_$date_full_`ds'_new.pdf", replace
restore

** YOS3_Sum
preserve
keep if samp_YOS3_Sum == 1
twoway scatter YOS3_Sum run_week, color(gs8) || line fit0_YOS3_Sum run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_YOS3_Sum run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(9.0 10.5)) ylabel(9.0(0.25)10.5) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Years of schooling (Sebastian; half percentiles replaced)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\YOS3_Sum_$date_full_`ds'_new", replace
graph export "${graphs}\YOS3_Sum_$date_full_`ds'_new.pdf", replace
restore

** yos_max
preserve
keep if samp_yos_max == 1
twoway scatter yos_max run_week, color(gs8) || line fit0_yos_max run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_yos_max run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(9.0 10.5)) ylabel(9.0(0.25)10.5) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Years of schooling (in grades)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\yos_max_$date_full_`ds'_new", replace
graph export "${graphs}\yos_max_$date_full_`ds'_new.pdf", replace
restore

** uni
preserve
keep if samp_uni == 1
twoway scatter uni run_week, color(gs8) || line fit0_uni run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_uni run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.0 0.4)) ylabel(0.0(0.1)0.4) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("High school degree", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\uni_$date_full_`ds'_new", replace
graph export "${graphs}\uni_$date_full_`ds'_new.pdf", replace
restore

** yoe_yrs
preserve
keep if samp_yoe_yrs == 1
twoway scatter yoe_yrs run_week, color(gs8) || line fit0_yoe_yrs run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_yoe_yrs run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(11.5 14.5)) ylabel(11.5(0.5)14.5) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Years of education", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\yoe_yrs_$date_full_`ds'_new", replace
graph export "${graphs}\yoe_yrs_$date_full_`ds'_new.pdf", replace
restore

** yoe_grade
preserve
keep if samp_yoe_grade == 1
twoway scatter yoe_grade run_week, color(gs8) || line fit0_yoe_grade run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_yoe_grade run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(9.0 11)) ylabel(9.0(0.25)11) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Years of education", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\yoe_grade_$date_full_`ds'_new", replace
graph export "${graphs}\yoe_grade_$date_full_`ds'_new.pdf", replace
restore
}