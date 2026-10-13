/*
This Do File will try to combine all event study estimator in one graph.
		
Event-Study-Estimators we will use:
	- TWFE
	- Callaway & San´Anna (CSDID)
	- Sun & Abraham (eventstudyinteract)
	- Borusyak (didimpute)
	- Gardner (2021) (did2s) // Skipped - Weird Estimations
	- Cengiz, Dube, Lindner, Zipperer (2019) (stackedev)
	
From: https://asjadnaqvi.github.io/DiD/docs/code/06_20_combined/

This file will handle the Mechanisms!

Important: I need a consistent colour and shape coding, otherwise it is really confusing. Consisten coding therefore is:
	1. twfe 			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) 
	2. cs   			lag_opt2(msymbol(lgx) msize(1.2) mlwidth(0.3) color("`r(p1)'")) lag_ci_opt2(color("`r(p1)'") lw(0.15))
	3. didimp  			lag_opt3(msymbol(Dh)  msize(1.2) mlwidth(0.3) color("`r(p2)'")) lag_ci_opt3(color("`r(p2)'") lw(0.15))
	4. sa_b#sa_v  		lag_opt4(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt4(color("`r(p3)'") lw(0.15))
	5. did2s_b#did2s_v 	lag_opt5(msymbol(Sh)  msize(1.2) mlwidth(0.3) color("`r(p4)'")) lag_ci_opt5(color("`r(p4)'") lw(0.15))

ALWAYS above nomenclature!

Version 1.0: 2025/08/14
*/



/*** Install Packages ***
//supporting packages
ssc install schemepack, replace
ssc install avar, replace 
ssc install reghdfe, replace
ssc install event_plot, replace
ssc install palettes, replace
ssc install colrspace, replace

// DiD packages
ssc install drdid, replace
ssc install csdid, replace
ssc install did_imputation, replace
ssc install eventstudyinteract, replace
ssc install did_multiplegt, replace // Not Working
ssc install stackedev, replace 
ssc install did2s, replace
*/


*** Globals
* Results 
global Results_Event_Combined_Mechanism "$master\Results\Mechanism\CombinedGraphsEvent"

*** Create Directory ***
capture mkdir "$Results_Event_Combined_Mechanism"
cd "$Results_Event_Combined_Mechanism"

*** Use final data set ***
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
destring AGS2020, replace
sort AGS2020 Year
xtset AGS2020 Year

*** Set Panel
destring AGS2020, replace
xtset AGS2020 Year


*** For STACKDEV ***
*** Elementary School ***
clonevar STACKDEV_ES = Year_OnlyClosure_ES
replace STACKDEV_ES = . if Year_OnlyClosure_ES == 0
*** Grammar School ***
clonevar STACKDEV_GYM = Year_OnlyClosure_GYM
replace STACKDEV_GYM = . if Year_OnlyClosure_GYM == 0

*** For Borusyak ***
*** Elementary School ***
recode Year_OnlyClosure_ES (0 = .), gen(Year_OnlyClosure_ES_Bor)
*** Grammar School *** 
recode Year_OnlyClosure_GYM (0 = .), gen(Year_OnlyClosure_GYM_Bor) 


*** *** *** *** *** *** *** *** *** *** *** ***
*** *** *** Loop: Elementary School *** *** ***
*** *** *** *** *** *** *** *** *** *** *** ***
foreach var in $Mechanism {
    
preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
 xtreg `var' lead_OC_ES2 lead_OC_ES3 lead_OC_ES4 lead_OC_ES5 lead_OC_ES6 lead_OC_ES7 lead_OC_ES8 lead_OC_ES9 lead_OC_ES10 lead_OC_ES11 lead_OC_ES12 lead_OC_ES13 lead_OC_ES14 lead_OC_ES15 lead_OC_ES16 lead_OC_ES17 lead_OC_ES18 lag_OC_ES0-lag_OC_ES19 i.Year, fe vce(cluster AGS2020) 
 estimates store twfe 


***********************
*** b) CS ***
***********************
 csdid `var', ivar(AGS2020) time(Year) gvar(Year_OnlyClosure_ES) vce(cluster AGS2020)
 estat event, estore(cs) window(-19 19)  


		 
***********************
*** d) Sun And Abraham ***
***********************
 eventstudyinteract `var' lead_OC_ES2 lead_OC_ES3 lead_OC_ES4 lead_OC_ES5 lead_OC_ES6 lead_OC_ES7 lead_OC_ES8 lead_OC_ES9 lead_OC_ES10 lead_OC_ES11 lead_OC_ES12 lead_OC_ES13 lead_OC_ES14 lead_OC_ES15 lead_OC_ES16 lead_OC_ES17 lead_OC_ES18 lag_OC_ES0-lag_OC_ES19, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_ES) control_cohort(NeverTreated_ES)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)


***********************
*** f) Zipper *** 
***********************	
capture stackedev `var' lead_OC_ES2 lead_OC_ES3 lead_OC_ES4 lead_OC_ES5 lead_OC_ES6 lead_OC_ES7 lead_OC_ES8 lead_OC_ES9 lead_OC_ES10 lead_OC_ES11 lead_OC_ES12 lead_OC_ES13 lead_OC_ES14 lead_OC_ES15 lead_OC_ES16 lead_OC_ES17 lead_OC_ES18 lag_OC_ES0-lag_OC_ES19, cohort(STACKDEV_ES) time(Year) never_treat(NeverTreated_ES) unit_fe(AGS2020) clust_unit(AGS2020)
matrix stackedev_b = e(b)
matrix stackedev_v = e(V)	


***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
 event_plot  twfe 	cs    sa_b#sa_v stackedev_b#stackedev_v, 	///
	stub_lag( lag_OC_ES#    	Tp#        	 lag_OC_ES# 	lag_OC_ES#) 		///
	stub_lead(lead_OC_ES#  		Tm#          lead_OC_ES# 	lead_OC_ES#)		///
		together perturb(-0.30(0.10)0.30) trimlead(6) trimlag(6) noautolegend 									///
		plottype(scatter) ciplottype(rspike)  																	    ///
			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) 	///
			lag_opt2(msymbol(lgx) msize(1.2) mlwidth(0.3) color("`r(p1)'")) lag_ci_opt2(color("`r(p1)'") lw(0.15)) 	///
			lag_opt3(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt3(color("`r(p3)'") lw(0.15)) 	///
			lag_opt4(msymbol(Sh)  msize(1.2) mlwidth(0.3) color("`r(p4)'")) lag_ci_opt4(color("`r(p4)'") lw(0.15)) 	///
					graph_opt(												///
								title("") 	xtitle("") 					///
								ytitle(" ") xlabel(-6(1)6)	///
								legend(order(1 "TWFE" 3 "csdid (CS 2021)" 5 "eventstudyinteract (SA 2021)" 7 "stackedev (CDLZ 2019)") pos(6) rows(2) size(vsmall) region(style(none))) 	///
								xline(-1, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							 ) 

 graph save "$Results_Event_Combined_Mechanism/`var'_ElementarySchool_OnlyClosure.gph", replace

 
 restore
}

*** *** *** *** *** *** *** *** *** *** *** ***  
*** *** ***  Loop:  Grammar School  *** *** ***
*** *** *** *** *** *** *** *** *** *** *** ***
foreach var in $Mechanism {
    
    preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
 xtreg `var' lead_OC_GYM2 lead_OC_GYM3 lead_OC_GYM4 lead_OC_GYM5 lead_OC_GYM6 lead_OC_GYM7 lead_OC_GYM8 lead_OC_GYM9 lead_OC_GYM10 lead_OC_GYM11 lead_OC_GYM12 lead_OC_GYM13 lead_OC_GYM14 lead_OC_GYM15 lead_OC_GYM16 lead_OC_GYM17 lead_OC_GYM18 lag_OC_GYM0-lag_OC_GYM19 i.Year, fe vce(cluster AGS2020) 
 estimates store twfe 


***********************
*** b) CS ***
***********************
 csdid `var', ivar(AGS2020) time(Year) gvar(Year_OnlyClosure_GYM) vce(cluster AGS2020) notyet
 estat event, estore(cs) window(-19 19)  // the average ATT for the entire post-treatment period is 0.070 (insig)

		 
***********************
*** d) Sun And Abraham ***
***********************
 eventstudyinteract `var' lead_OC_GYM2 lead_OC_GYM3 lead_OC_GYM4 lead_OC_GYM5 lead_OC_GYM6 lead_OC_GYM7 lead_OC_GYM8 lead_OC_GYM9 lead_OC_GYM10 lead_OC_GYM11 lead_OC_GYM12 lead_OC_GYM13 lead_OC_GYM14 lead_OC_GYM15 lead_OC_GYM16 lead_OC_GYM17 lead_OC_GYM18 lag_OC_GYM0-lag_OC_GYM19, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_GYM) control_cohort(NeverTreated_GYM)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)


***********************
*** f) Zipper *** 
***********************	
 stackedev `var' lead_OC_GYM2 lead_OC_GYM3 lead_OC_GYM4 lead_OC_GYM5 lead_OC_GYM6 lead_OC_GYM7 lead_OC_GYM8 lead_OC_GYM9 lead_OC_GYM10 lead_OC_GYM11 lead_OC_GYM12 lead_OC_GYM13 lead_OC_GYM14 lead_OC_GYM15 lead_OC_GYM16 lead_OC_GYM17 lead_OC_GYM18 lag_OC_GYM0-lag_OC_GYM19, cohort(STACKDEV_GYM) time(Year) never_treat(NeverTreated_GYM) unit_fe(AGS2020) clust_unit(AGS2020)
 matrix stackedev_b = e(b)
 matrix stackedev_v = e(V)	

		
***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
 event_plot  twfe 	cs    sa_b#sa_v  stackedev_b#stackedev_v, 	///
	stub_lag( lag_OC_GYM#    	Tp#       		lag_OC_GYM#  lag_OC_GYM#) 		///
	stub_lead(lead_OC_GYM#  	Tm#        	   lead_OC_GYM#  lead_OC_GYM#)		///
		together perturb(-0.30(0.10)0.30) trimlead(6) trimlag(6) noautolegend 									///
		plottype(scatter) ciplottype(rspike)  																	    ///
			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) 	///
			lag_opt2(msymbol(lgx) msize(1.2) mlwidth(0.3) color("`r(p1)'")) lag_ci_opt2(color("`r(p1)'") lw(0.15)) 	///
			lag_opt3(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt3(color("`r(p3)'") lw(0.15)) 	///
			lag_opt4(msymbol(Sh)  msize(1.2) mlwidth(0.3) color("`r(p4)'")) lag_ci_opt4(color("`r(p4)'") lw(0.15)) 	///	
					graph_opt(												///
								title("") 	xtitle("") 					///
								ytitle(" ") xlabel(-6(1)6)	///
								legend(order(1 "TWFE" 3 "csdid (CS 2021)" 5 "eventstudyinteract (SA 2021)" 7 "stackedev (CDLZ 2019)") pos(6) rows(2) size(vsmall) region(style(none))) 	///
								xline(-1, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							 ) 

 graph save "$Results_Event_Combined_Mechanism/`var'_GrammarSchool_OnlyClosure.gph", replace
 
 restore
}


*** Graph Combine ***

*** Export Single PDF ***
foreach var in $Mechanism {
	
	* Elementary School
	graph use "$Results_Event_Combined_Mechanism/`var'_ElementarySchool_OnlyClosure.gph"
	graph export "$Results_Event_Combined_Mechanism/`var'_ElementarySchool_OnlyClosure.pdf", as(pdf) replace
	
	* Grammar School
	graph use "$Results_Event_Combined_Mechanism/`var'_GrammarSchool_OnlyClosure.gph"
	graph export "$Results_Event_Combined_Mechanism/`var'_GrammarSchool_OnlyClosure.pdf", as(pdf) replace

}
