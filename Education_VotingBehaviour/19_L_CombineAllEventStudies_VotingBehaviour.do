/*
This Do File will combine all event study estimator in one graph.
				
Event-Study-Estimators we will use (FINAL VERDICT):
	
	For Normal Closures:
	- TWFE
	- Sun & Abraham (eventstudyinteract)
	- Borusyak (didimpute)
	
	For Only Closures (Less Nobs, Therefore Specific )
	- TWFE
	- Sun & Abraham (eventstudyinteract)

This file will handle the Voting Behaviour

Important: I need a consistent colour and shape coding, otherwise it is really confusing. Consisten coding therefore is:
	1. twfe 			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) <-
	2. cs   			lag_opt2(msymbol(lgx) msize(1.2) mlwidth(0.3) color("`r(p1)'")) lag_ci_opt2(color("`r(p1)'") lw(0.15)) 
	3. didimp  			lag_opt3(msymbol(Dh)  msize(1.2) mlwidth(0.3) color("`r(p2)'")) lag_ci_opt3(color("`r(p2)'") lw(0.15)) <-
	4. sa_b#sa_v  		lag_opt4(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt4(color("`r(p3)'") lw(0.15)) <-
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
capture mkdir "$Results_Event_Combined_Voting"
cd "$Results_Event_Combined_Voting"

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
clonevar STACKDEV_ES = Year_OnlyClosure_ES // Attention: Same Name than First Closure!
replace STACKDEV_ES = . if Year_OnlyClosure_ES == 0
*** Grammar School ***
clonevar STACKDEV_GYM = Year_OnlyClosure_GYM // Attention: Same Name than First Closure!
replace STACKDEV_GYM = . if Year_OnlyClosure_GYM == 0

*** For Borusyak ***
*** Elementary School ***
recode Year_OnlyClosure_ES (0 = .), gen(Year_OnlyClosure_ES_Bor) 
*** Grammar School *** 
recode Year_OnlyClosure_GYM (0 = .), gen(Year_OnlyClosure_GYM_Bor) 


*** *** *** *** *** *** *** *** *** *** *** ***
*** *** *** Loop: Elementary School *** *** ***
*** *** *** *** *** *** *** *** *** *** *** ***

*** Federal Election ***

foreach var in $Regress_BW $Regress_LW $Regress_KW {
    
	preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
 xtreg `var' lead_OC_ES2 lead_OC_ES3 lead_OC_ES4 lead_OC_ES5 lead_OC_ES6 lead_OC_ES7 lead_OC_ES8 lead_OC_ES9 lead_OC_ES10 lead_OC_ES11 lead_OC_ES12 lead_OC_ES13 lead_OC_ES14 lead_OC_ES15 lead_OC_ES16 lead_OC_ES17 lead_OC_ES18 lag_OC_ES0-lag_OC_ES19 i.Year, fe vce(cluster AGS2020) 
 estimates store twfe 
		 
***********************
*** d) Sun And Abraham ***
***********************
 eventstudyinteract `var' lead_OC_ES2 lead_OC_ES3 lead_OC_ES4 lead_OC_ES5 lead_OC_ES6 lead_OC_ES7 lead_OC_ES8 lead_OC_ES9 lead_OC_ES10 lead_OC_ES11 lead_OC_ES12 lead_OC_ES13 lead_OC_ES14 lead_OC_ES15 lead_OC_ES16 lead_OC_ES17 lead_OC_ES18 lag_OC_ES0-lag_OC_ES1, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(Year_OnlyClosure_ES) control_cohort(NeverTreated_ES)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)

		
***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
 event_plot  twfe    sa_b#sa_v, 	///
	stub_lag( lag_OC_ES#    	       lag_OC_ES#   	) 		///
	stub_lead(lead_OC_ES#  	           lead_OC_ES#     	)		///
		together perturb(-0.30(0.10)0.30) trimlead(6) trimlag(6) noautolegend 									///
		plottype(scatter) ciplottype(rspike)  																	    ///
			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) 	///
			lag_opt2(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt2(color("`r(p3)'") lw(0.15)) 	///
					graph_opt(												///
								title("") 	xtitle("") 					///
								ytitle(" ") xlabel(-6(1)6)	///
								legend(order(1 "TWFE" 3 "eventstudyinteract (SA 2021)") pos(6) rows(1) size(vsmall) region(style(none))) 	///
								xline(-1, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							 ) 

 graph save "$Results_Event_Combined_Voting/`var'_ElementarySchool_OnlyClosure.gph", replace

	restore
}

*** Export To PDF ***
foreach var in $Regress_BW $Regress_LW $Regress_KW { 
	graph use "$Results_Event_Combined_Voting/`var'_ElementarySchool_OnlyClosure.gph" 
	graph export  "$Results_Event_Combined_Voting/`var'_ElementarySchool_OnlyClosure.pdf", as(pdf) replace
}


*** Graph Combine ***
// Comment: 
graph combine LEFT_ZS_BW__ElementarySchool_OnlyClosure.gph RIGHT_ZS_BW__ElementarySchool_OnlyClosure.gph OTHER_ZS_BW__ElementarySchool_OnlyClosure.gph Invalid_ZS_BW__ElementarySchool_OnlyClosure.gph VoteTurnout_ZS_BW__ElementarySchool_OnlyClosure.gph, title("Federal Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_BW_ElementarySchool_OnlyClosure.pdf", as(pdf) replace

// Comment: 
graph combine LEFT_ZS_LW__ElementarySchool_OnlyClosure.gph RIGHT_ZS_LW__ElementarySchool_OnlyClosure.gph OTHER_ZS_LW__ElementarySchool_OnlyClosure.gph Invalid_ZS_LW__ElementarySchool_OnlyClosure.gph VoteTurnout_ZS_LW__ElementarySchool_OnlyClosure.gph, title("State Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_LW_ElementarySchool_OnlyClosure.pdf", as(pdf) replace

// Comment: 
graph combine LEFT_ES_KW__ElementarySchool_OnlyClosure.gph RIGHT_ES_KW__ElementarySchool_OnlyClosure.gph OTHER_ES_KW__ElementarySchool_OnlyClosure.gph Invalid_ES_KW__ElementarySchool_OnlyClosure.gph VoteTurnout_ES_KW__ElementarySchool_OnlyClosure.gph, title("Kommunal Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_KW_ElementarySchool_OnlyClosure.pdf", as(pdf) replace 



*** *** *** *** *** *** *** *** *** *** *** ***  
*** *** ***  Loop:  Grammar School  *** *** ***
*** *** *** *** *** *** *** *** *** *** *** ***
*** Federal Election ***
foreach var in $Regress_BW $Regress_LW $Regress_KW {
    
	preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
 xtreg `var' lead_OC_GYM2 lead_OC_GYM3 lead_OC_GYM4 lead_OC_GYM5 lead_OC_GYM6 lead_OC_GYM7 lead_OC_GYM8 lead_OC_GYM9 lead_OC_GYM10 lead_OC_GYM11 lead_OC_GYM12 lead_OC_GYM13 lead_OC_GYM14 lead_OC_GYM15 lead_OC_GYM16 lead_OC_GYM17 lead_OC_GYM18 lag_OC_GYM0-lag_OC_GYM19 i.Year, fe vce(cluster AGS2020) 
 estimates store twfe 

***********************
*** d) Sun And Abraham ***
***********************
 eventstudyinteract `var' lead_OC_GYM2 lead_OC_GYM3 lead_OC_GYM4 lead_OC_GYM5 lead_OC_GYM6 lead_OC_GYM7 lead_OC_GYM8 lead_OC_GYM9 lead_OC_GYM10 lead_OC_GYM11 lead_OC_GYM12 lead_OC_GYM13 lead_OC_GYM14 lead_OC_GYM15 lead_OC_GYM16 lead_OC_GYM17 lead_OC_GYM18 lag_OC_GYM0-lag_OC_GYM19, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(Year_OnlyClosure_GYM) control_cohort(NeverTreated_GYM)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)
		
***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
 event_plot  		twfe 			     	 	sa_b#sa_v, 	///
	stub_lag( 		lag_OC_GYM#    	          	lag_OC_GYM#) 		///
	stub_lead(		lead_OC_GYM#  	          	lead_OC_GYM#)		///
		together perturb(-0.30(0.10)0.30) trimlead(6) trimlag(6) noautolegend 									///
		plottype(scatter) ciplottype(rspike)  																	    ///
			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) 	///
			lag_opt2(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt2(color("`r(p3)'") lw(0.15)) ///
					graph_opt(												///
								title("") 	xtitle("") 					///
								ytitle(" ") xlabel(-6(1)6)	///
								legend(order(1 "TWFE" 3 "eventstudyinteract (SA 2021)") pos(6) rows(1) size(vsmall) region(style(none))) 	///
								xline(-1, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							 ) 

 graph save "$Results_Event_Combined_Voting/`var'_GrammarSchool_OnlyClosure.gph", replace

	restore
}

*** Export To PDF ***
foreach var in $Regress_BW $Regress_LW $Regress_KW { 
	graph use "$Results_Event_Combined_Voting/`var'_GrammarSchool_OnlyClosure.gph" 
	graph export  "$Results_Event_Combined_Voting/`var'_GrammarSchool_OnlyClosure.pdf", as(pdf) replace
}

*** Graph Combine ***
graph combine LEFT_ZS_BW__GrammarSchool_OnlyClosure.gph RIGHT_ZS_BW__GrammarSchool_OnlyClosure.gph OTHER_ZS_BW__GrammarSchool_OnlyClosure.gph Invalid_ZS_BW__GrammarSchool_OnlyClosure.gph VoteTurnout_ZS_BW__GrammarSchool_OnlyClosure.gph, title("Federal Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_BW_GrammarSchool_OnlyClosure.pdf", as(pdf) replace

graph combine LEFT_ZS_LW__GrammarSchool_OnlyClosure.gph RIGHT_ZS_LW__GrammarSchool_OnlyClosure.gph OTHER_ZS_LW__GrammarSchool_OnlyClosure.gph Invalid_ZS_LW__GrammarSchool_OnlyClosure.gph VoteTurnout_ZS_LW__GrammarSchool_OnlyClosure.gph, title("State Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_LW_GrammarSchool_OnlyClosure.pdf", as(pdf) replace

graph combine LEFT_ES_KW__GrammarSchool_OnlyClosure.gph RIGHT_ES_KW__GrammarSchool_OnlyClosure.gph OTHER_ES_KW__GrammarSchool_OnlyClosure.gph Invalid_ES_KW__GrammarSchool_OnlyClosure.gph VoteTurnout_ES_KW__GrammarSchool_OnlyClosure.gph, title("Kommunal Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_KW_GrammarSchool_OnlyClosure.pdf", as(pdf) replace 
