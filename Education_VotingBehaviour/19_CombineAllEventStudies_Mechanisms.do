/*
This Do File will try to combine all event study estimator in one graph.
	Important: As we are using election data, that is only collected every 4-5 years, we have a lot of missing control-to-treatment years. 
				Therefore, not all event-study estimators are capable of handling this data structure. See "XXX_Testing_Event_Combine.do" for further informations!
				
Event-Study-Estimators we will use:
	- TWFE
	- Callaway & San´Anna (CSDID)
	- Sun & Abraham (eventstudyinteract)
	- Borusyak (didimpute)
	- Gardner (2021) (did2s) // Skipped - Weird Estimations
	- Cengiz, Dube, Lindner, Zipperer (2019) (stackedev)

This file will handle the Mechanisms

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

*** Create Directory ***
capture mkdir "$Results_Event_Combined_Mechanism"
cd "$Results_Event_Combined_Mechanism"

*** Use final data set ***
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
destring AGS2020, replace
sort AGS2020 Year
xtset AGS2020 Year

*** For STACKDEV ***
*** Elementary School ***
clonevar STACKDEV_ES = minYear_ES
replace STACKDEV_ES = . if minYear_ES == 0
*** Grammar School ***
clonevar STACKDEV_GYM = minYear_GYM
replace STACKDEV_GYM = . if minYear_GYM == 0

*** For Borusyak ***
*** Elementary School ***
recode minYear_ES (0 = .), gen(minYear_ES_Bor)
*** Grammar School *** 
recode minYear_GYM (0 = .), gen(minYear_GYM_Bor) 


*** *** *** *** *** *** *** *** *** *** *** ***
*** *** *** Loop: Elementary School *** *** ***
*** *** *** *** *** *** *** *** *** *** *** ***
foreach var in $Mechanism {
    
preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
 xtreg `var' lead_ES2 lead_ES3 lead_ES4 lead_ES5 lead_ES6 lead_ES7 lead_ES8 lead_ES9 lead_ES10 lead_ES11 lead_ES12 lead_ES13 lead_ES14 lead_ES15 lead_ES16 lead_ES17 lead_ES18 lag_ES0-lag_ES19 i.Year, fe vce(cluster AGS2020) 
 estimates store twfe 


***********************
*** b) CS ***
***********************
 csdid `var', ivar(AGS2020) time(Year) gvar(minYear_ES) vce(cluster AGS2020) notyet
 estat event, estore(cs) window(-19 19) 
		 
		 
***********************
*** d) Sun And Abraham ***
***********************
 eventstudyinteract `var' lead_ES2 lead_ES3 lead_ES4 lead_ES5 lead_ES6 lead_ES7 lead_ES8 lead_ES9 lead_ES10 lead_ES11 lead_ES12 lead_ES13 lead_ES14 lead_ES15 lead_ES16 lead_ES17 lead_ES18 lag_ES0-lag_ES19, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_ES) control_cohort(NeverTreated_ES)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)


***********************
*** f) Zipper *** // Nicht ref einfügen, da sonst event_plot nicht funktionier!
***********************	
capture stackedev `var' lead_ES* lag_ES*, cohort(STACKDEV_ES) time(Year) never_treat(NeverTreated_ES) unit_fe(AGS2020) clust_unit(AGS2020)
matrix stackedev_b = e(b)
matrix stackedev_v = e(V)	

		
***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
 event_plot  twfe 	cs    sa_b#sa_v stackedev_b#stackedev_v, 	///
	stub_lag( lag_ES#    	Tp#           	lag_ES# 	lag_ES#) 		/// 
	stub_lead(lead_ES#  	Tm#             lead_ES# 	lead_ES#)		///
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

 *graph save "Graph" "$Results_Event_Combined_Mechanism/`var'_ElementarySchool.gph", replace
 graph save "$Results_Event_Combined_Mechanism/`var'_ElementarySchool.gph", replace


restore
}

*** Graph Combine ***
graph combine ShareUnemployedAge25_ElementarySchool.gph LTUnemp_ElementarySchool.gph ShrWRkAb_ElementarySchool.gph AvrgAgePop_ElementarySchool.gph NetMigration_ElementarySchool.gph NetCommuter_ElementarySchool.gph GenderRatio_ElementarySchool.gph, title("", size(medsmall))
graph export "$Results_Event_Combined_Mechanism\Event_Combined_Mechanisms_ElementarySchool.pdf", as(pdf) replace


*** *** *** *** *** *** *** *** *** *** *** ***  
*** *** ***  Loop:  Grammar School  *** *** ***
*** *** *** *** *** *** *** *** *** *** *** ***
foreach var in $Mechanism {
    
    preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
 xtreg `var' lead_GYM* lag_GYM* i.Year, fe vce(cluster AGS2020) 
 estimates store twfe 


***********************
*** b) CS ***
***********************
 csdid `var', ivar(AGS2020) time(Year) gvar(minYear_GYM) vce(cluster AGS2020) notyet
 estat event, estore(cs) window(-19 19)  // the average ATT for the entire post-treatment period is 0.070 (insig)

		 
***********************
*** d) Sun And Abraham ***
***********************
 eventstudyinteract `var' lead_GYM2 lead_GYM3 lead_GYM4 lead_GYM5 lead_GYM6 lead_GYM7 lead_GYM8 lead_GYM9 lead_GYM10 lead_GYM11 lead_GYM12 lead_GYM13 lead_GYM14 lead_GYM15 lead_GYM16 lead_GYM17 lead_GYM18 lag_GYM0-lag_GYM19, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_GYM) control_cohort(NeverTreated_GYM)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)


***********************
*** f) Zipper *** // Nicht ref einfügen, da sonst event_plot nicht funktionier!
***********************	
 stackedev `var' lead_GYM* lag_GYM*, cohort(STACKDEV_GYM) time(Year) never_treat(NeverTreated_GYM) unit_fe(AGS2020) clust_unit(AGS2020)
 matrix stackedev_b = e(b)
 matrix stackedev_v = e(V)	

		
***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
 event_plot  twfe 	cs    sa_b#sa_v  stackedev_b#stackedev_v, 	///
	stub_lag( lag_GYM#    	Tp#        	lag_GYM#  lag_GYM#) 		///
	stub_lead(lead_GYM#  	Tm#        	lead_GYM#  lead_GYM#)		///
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

 graph save "$Results_Event_Combined_Mechanism/`var'_GrammarSchool.gph", replace
 
 
 restore
}


*** Graph Combine ***
graph combine ShareUnemployedAge25_GrammarSchool.gph LTUnemp_GrammarSchool.gph ShrWRkAb_GrammarSchool.gph AvrgAgePop_GrammarSchool.gph NetMigration_GrammarSchool.gph NetCommuter_GrammarSchool.gph GenderRatio_GrammarSchool.gph 
graph export "$Results_Event_Combined_Mechanism\Event_Combined_Mechanisms_GrammarSchool.pdf", as(pdf) replace


*** Export Single PDF ***
foreach var in $Mechanism {
	
	* Elementary School
	graph use "$Results_Event_Combined_Mechanism/`var'_ElementarySchool.gph"
	graph export "$Results_Event_Combined_Mechanism/`var'_ElementarySchool.pdf", as(pdf) replace
	
	* Grammar School
	graph use "$Results_Event_Combined_Mechanism/`var'_GrammarSchool.gph"
	graph export "$Results_Event_Combined_Mechanism/`var'_GrammarSchool.pdf", as(pdf) replace

}