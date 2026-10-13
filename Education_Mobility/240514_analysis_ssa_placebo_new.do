********************************************************************************
*			pooled estimations - robustness
********************************************************************************
use "$results\ssa_panel_all_new.dta", clear
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




** placebo cutoff - donut sample
cap erase "$results\SSA_placebo_new_$date.csv"
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	drop if inrange(run_week,-1,2)
	
	clonevar run_week_donut = run_week
	replace run_week_donut = run_week_donut -12 if run_week_donut <= -2
	replace run_week_donut = run_week_donut -15 if inrange(run_week_donut,3,13)
	replace run_week_donut = run_week_donut -11 if inrange(run_week_donut,14,25)

	local i = 15
	foreach num of numlist -36(1)-26 {
	replace run_week_donut = run_week_donut - `num' + `i' if run_week_donut == `num'
	local i = `++i'
	}
	gen after_week_donut = inrange(run_week_donut,3,25)


est drop _all
global lin_placebo run_week_donut i.after_week_donut#c.run_week_donut
global instr  i.after_week_donut
	
	ivreg2 migstock $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	ivreg2 migflow1 $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	ivreg2 migflow1_kr $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock $instr $lin_placebo  	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo unwbl_stock_plain		
	qui sum migstock 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	ivreg2 migflow1 $instr $lin_placebo   if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo unwbl_flow1_plain		
	qui sum migflow1 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_placebo  	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo unwbl_flow5_plain		
	qui sum migflow5 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_placebo  	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo unwkr_stock_plain		
	qui sum migstock_kr 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	ivreg2 migflow1_kr $instr $lin_placebo  if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo unwkr_flow1_plain		
	qui sum migflow1_kr 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_placebo   	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo unwkr_flow5_plain		
	qui sum migflow5_kr 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	
	esttab bl_* kr_* unwbl_* unwkr_* using "$results\SSA_placebo_new_$date", append scsv keep(1.after_week_donut) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut sample (placebo cutoff shifted by 12 weeks)") nodepvars mtitle("BL lifetime" "BL 1 yr" "BL 5 yrs" "KR lifetime" "KR 1 yr" "KR 5 yrs" "BL lifetime (weighted)" "BL 1 yr (weighted)" "BL 5 yrs (weighted)" "KR lifetime (weighted)" "KR 1 yr (weighted)" "KR 5 yrs (weighted)")	
	restore	




*placebo cutoff - full sample
	preserve
	keep if w_t4_cal != 0
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)

	clonevar run_week_placebo = run_week
	local i = 26
	foreach num of numlist -24(1)-13 {
	replace run_week_placebo = run_week_placebo - `num' + `i' if run_week_placebo == `num'
	local i = `++i'
	}
	replace run_week_placebo = run_week_placebo - 12
	gen after_week_placebo = inrange(run_week_placebo,1,25)
	
est drop _all
global lin_placebo run_week_placebo i.after_week_placebo#c.run_week_placebo
global instr  i.after_week_placebo

	
	ivreg2 migstock $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	ivreg2 migflow1 $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	ivreg2 migflow1_kr $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock $instr $lin_placebo  	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo unwbl_stock_plain		
	qui sum migstock 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	ivreg2 migflow1 $instr $lin_placebo   if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo unwbl_flow1_plain		
	qui sum migflow1 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_placebo  	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo unwbl_flow5_plain		
	qui sum migflow5 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_placebo  	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo unwkr_stock_plain		
	qui sum migstock_kr 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	ivreg2 migflow1_kr $instr $lin_placebo  if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo unwkr_flow1_plain		
	qui sum migflow1_kr 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_placebo   	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo unwkr_flow5_plain		
	qui sum migflow5_kr 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	
	esttab bl_* kr_* unwbl_* unwkr_* using "$results\SSA_placebo_new_$date", append scsv keep(1.after_week_placebo) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Full sample (placebo cutoff shifted by 12 weeks)") nodepvars mtitle("BL lifetime" "BL 1 yr" "BL 5 yrs" "KR lifetime" "KR 1 yr" "KR 5 yrs" "BL lifetime (weighted)" "BL 1 yr (weighted)" "BL 5 yrs (weighted)" "KR lifetime (weighted)" "KR 1 yr (weighted)" "KR 5 yrs (weighted)")	
	restore	



