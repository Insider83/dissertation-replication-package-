**********Lifecycle graphs***************

***stock
*BL
use "$results\temp\bl_stock_cycle_donut_avg3.dta", clear
	rename idnum age
	rename min95 lo_ci
	rename max95 up_ci
	rename es_1 obs
	keep if parm == "1.after_week"
	keep if inrange(age,7,64)

	
	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.1(0.02)0.1)) ylabel(-0.1(0.02)0.1, labsize(small)) yline(0, lcolor(red)) ///
			title("1944-1965", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\bl_stock_cycle_donut_avg3", replace
	graph export "$graphs\bl_stock_cycle_donut_avg3.pdf", as(pdf) replace		


*KR
use "$results\temp\kr_stock_cycle_donut_avg3.dta", clear
	rename idnum age
	rename min95 lo_ci
	rename max95 up_ci
	rename es_1 obs
	keep if parm == "1.after_week"	
	keep if inrange(age,7,64)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.1(0.02)0.1)) ylabel(-0.1(0.02)0.1, labsize(small)) yline(0, lcolor(red)) ///
			title("1944-1965", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\kr_stock_cycle_donut_avg3", replace
	graph export "$graphs\kr_stock_cycle_donut_avg3.pdf", as(pdf) replace	
	
	
***flow1
*BL	
use "$results\temp\bl_flow1_cycle_donut_avg3.dta", clear
	rename idnum age
	rename min95 lo_ci
	rename max95 up_ci
	rename es_1 obs
	keep if parm == "1.after_week"	
	keep if inrange(age,7,64)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.1(0.02)0.1)) ylabel(-0.1(0.02)0.1, labsize(small)) yline(0, lcolor(red)) ///
			title("1944-1965", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\bl_flow1_cycle_donut_avg3", replace
	graph export "$graphs\bl_flow1_cycle_donut_avg3.pdf", as(pdf) replace		


*KR
use "$results\temp\kr_flow1_cycle_donut_avg3.dta", clear
	rename idnum age
	rename min95 lo_ci
	rename max95 up_ci
	rename es_1 obs
	keep if parm == "1.after_week"	
	keep if inrange(age,7,64)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.1(0.02)0.1)) ylabel(-0.1(0.02)0.1, labsize(small)) yline(0, lcolor(red)) ///
			title("1944-1965", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\kr_flow1_cycle_donut_avg3", replace
	graph export "$graphs\kr_flow1_cycle_donut_avg3.pdf", as(pdf) replace		
	
***flow5
*BL		
use "$results\temp\bl_flow5_cycle_donut_avg3.dta", clear
	rename idnum age
	rename min95 lo_ci
	rename max95 up_ci
	rename es_1 obs
	keep if parm == "1.after_week"	
	keep if inrange(age,7,64)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.1(0.02)0.1)) ylabel(-0.1(0.02)0.1, labsize(small)) yline(0, lcolor(red)) ///
			title("1944-1965", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\bl_flow5_cycle_donut_avg3", replace
	graph export "$graphs\bl_flow5_cycle_donut_avg3.pdf", as(pdf) replace		


*KR
use "$results\temp\kr_flow5_cycle_donut_avg3.dta", clear
	rename idnum age
	rename min95 lo_ci
	rename max95 up_ci
	rename es_1 obs
	keep if parm == "1.after_week"	
	keep if inrange(age,7,64)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.1(0.02)0.1)) ylabel(-0.1(0.02)0.1, labsize(small)) yline(0, lcolor(red)) ///
			title("1944-1965", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\kr_flow5_cycle_donut_avg3", replace
	graph export "$graphs\kr_flow5_cycle_donut_avg3.pdf", as(pdf) replace		
}	