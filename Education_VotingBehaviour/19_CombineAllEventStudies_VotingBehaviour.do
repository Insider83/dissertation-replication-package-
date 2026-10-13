/*
This Do File will try to combine all event study estimator in one graph.
				
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

*** Federal Election ***

foreach var in $Regress_BW {   
    
	preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
 xtreg `var' lead_ES2 lead_ES3 lead_ES4 lead_ES5 lead_ES6 lead_ES7 lead_ES8 lead_ES9 lead_ES10 lead_ES11 lead_ES12 lead_ES13 lead_ES14 lead_ES15 lead_ES16 lead_ES17 lead_ES18 lag_ES0-lag_ES19 i.Year, fe vce(cluster AGS2020) 
 estimates store twfe 

***********************
*** c) Apply the Borusyak, Jaravel, Spiess (2021) estimator using the did_imputation command.
***********************	
 did_imputation `var' AGS2020 Year minYear_ES_Bor, cluster(AGS2020) autosample horizons(0/19) pretrend(19) minn(0) tol(0.00000000001) maxit(2000)
 ereturn list
 estimates store didimp	
 
***********************
*** d) Sun And Abraham ***
***********************
 eventstudyinteract `var' lead_ES2 lead_ES3 lead_ES4 lead_ES5 lead_ES6 lead_ES7 lead_ES8 lead_ES9 lead_ES10 lead_ES11 lead_ES12 lead_ES13 lead_ES14 lead_ES15 lead_ES16 lead_ES17 lead_ES18 lag_ES0-lag_ES19, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_ES) control_cohort(NeverTreated_ES)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)

***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
 event_plot  twfe  didimp  sa_b#sa_v, 	///
	stub_lag( lag_ES#       tau#        lag_ES#) 		///
	stub_lead(lead_ES#      pre#        lead_ES#)		///
		together perturb(-0.30(0.10)0.30) trimlead(6) trimlag(6) noautolegend 									///
		plottype(scatter) ciplottype(rspike)  																	    ///
			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) 	///
			lag_opt2(msymbol(Dh)  msize(1.2) mlwidth(0.3) color("`r(p2)'")) lag_ci_opt2(color("`r(p2)'") lw(0.15)) 	///
			lag_opt3(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt3(color("`r(p3)'") lw(0.15)) 	///
					graph_opt(												///
								title("") 	xtitle("") 					///
								ytitle(" ") xlabel(-6(1)6)	///
								legend(order(1 "TWFE" 3 "did_imputation (BJS 2024)" 5 "eventstudyinteract (SA 2021)") pos(6) rows(1) size(vsmall) region(style(none))) 	///
								xline(-1, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							 ) 

 graph save "$Results_Event_Combined_Voting/`var'_ElementarySchool.gph", replace

	restore
}

*** State and Kommunal Elections ***
foreach var in $Regress_LW $Regress_KW { 
    
	preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
xtreg `var' lead_ES2 lead_ES3 lead_ES4 lead_ES5 lead_ES6 lead_ES7 lead_ES8 lead_ES9 lead_ES10 lead_ES11 lead_ES12 lead_ES13 lead_ES14 lead_ES15 lead_ES16 lead_ES17 lead_ES18 lag_ES0-lag_ES19 i.Year, fe vce(cluster AGS2020) 
estimates store twfe 
		 
***********************
*** d) Sun And Abraham ***
***********************
eventstudyinteract `var' lead_ES2 lead_ES3 lead_ES4 lead_ES5 lead_ES6 lead_ES7 lead_ES8 lead_ES9 lead_ES10 lead_ES11 lead_ES12 lead_ES13 lead_ES14 lead_ES15 lead_ES16 lead_ES17 lead_ES18 lag_ES0-lag_ES19, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_ES) control_cohort(NeverTreated_ES)
matrix sa_b = e(b_iw) 
matrix sa_v = e(V_iw)

		
***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
event_plot  	twfe 		   			sa_b#sa_v  		, 	///
	stub_lag( lag_ES#    		       	lag_ES#   		) 		///
	stub_lead(lead_ES#  		        lead_ES#   		)		///
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

graph save "$Results_Event_Combined_Voting/`var'_ElementarySchool.gph", replace

	restore
}

*** Export To PDF ***
foreach var in $Regress_BW $Regress_LW $Regress_KW { 
	graph use "$Results_Event_Combined_Voting/`var'_ElementarySchool.gph" 
	graph export  "$Results_Event_Combined_Voting/`var'_ElementarySchool.pdf", as(pdf) replace
}

*** Graph Combine ***
// Comment: 
graph combine LEFT_ZS_BW__ElementarySchool.gph RIGHT_ZS_BW__ElementarySchool.gph OTHER_ZS_BW__ElementarySchool.gph Invalid_ZS_BW__ElementarySchool.gph VoteTurnout_ZS_BW__ElementarySchool.gph, title("Federal Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_BW_ElementarySchool.pdf", as(pdf) replace

// Comment: 
graph combine LEFT_ZS_LW__ElementarySchool.gph RIGHT_ZS_LW__ElementarySchool.gph OTHER_ZS_LW__ElementarySchool.gph Invalid_ZS_LW__ElementarySchool.gph VoteTurnout_ZS_LW__ElementarySchool.gph, title("State Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_LW_ElementarySchool.pdf", as(pdf) replace

// Comment: 
graph combine LEFT_ES_KW__ElementarySchool.gph RIGHT_ES_KW__ElementarySchool.gph OTHER_ES_KW__ElementarySchool.gph Invalid_ES_KW__ElementarySchool.gph VoteTurnout_ES_KW__ElementarySchool.gph, title("Kommunal Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_KW_ElementarySchool.pdf", as(pdf) replace 



*** *** *** *** *** *** *** *** *** *** *** ***  
*** *** ***  Loop:  Grammar School  *** *** ***
*** *** *** *** *** *** *** *** *** *** *** ***
*** Important: As we have many missings due to the nature of elections (only 4-5 Years in Germany), not all estimators are feasible for every election type; 
*** Therefore, we have to remove Borusyak from State and Kommunal Elections
*** Federal Election ***
foreach var in $Regress_BW {
    
	preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
 xtreg `var' lead_GYM2 lead_GYM3 lead_GYM4 lead_GYM5 lead_GYM6 lead_GYM7 lead_GYM8 lead_GYM9 lead_GYM10 lead_GYM11 lead_GYM12 lead_GYM13 lead_GYM14 lead_GYM15 lead_GYM16 lead_GYM17 lead_GYM18 lag_GYM0-lag_GYM19 i.Year, fe vce(cluster AGS2020) 
 estimates store twfe 
 
***********************
*** c) Apply the Borusyak, Jaravel, Spiess (2021) estimator using the did_imputation command.
***********************	
 did_imputation `var' AGS2020 Year minYear_GYM_Bor, cluster(AGS2020) autosample horizons(0/19) pretrend(19) minn(0) tol(0.00000000001) maxit(2000)
 ereturn list
 estimates store didimp	

***********************
*** d) Sun And Abraham ***
***********************
 eventstudyinteract `var' lead_GYM* lag_GYM*, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_GYM) control_cohort(NeverTreated_GYM)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)
		
***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
 event_plot  		twfe 		   	didimp  	 sa_b#sa_v, 	///
	stub_lag( 		lag_GYM#        tau#       	 lag_GYM#) 		///
	stub_lead(		lead_GYM#  	    pre#         lead_GYM#)		///
		together perturb(-0.30(0.10)0.30) trimlead(6) trimlag(6) noautolegend 									///
		plottype(scatter) ciplottype(rspike)  																	    ///
			lag_opt1(msymbol(+)   msize(1.2) mlwidth(0.3) color(black)) 	lag_ci_opt1(color(black)     lw(0.15)) 	///
			lag_opt2(msymbol(Dh)  msize(1.2) mlwidth(0.3) color("`r(p2)'")) lag_ci_opt2(color("`r(p2)'") lw(0.15)) 	///
			lag_opt3(msymbol(Th)  msize(1.2) mlwidth(0.3) color("`r(p3)'")) lag_ci_opt3(color("`r(p3)'") lw(0.15)) 	///
					graph_opt(												///
								title("") 	xtitle("") 					///
								ytitle(" ") xlabel(-6(1)6)	///
								legend(order(1 "TWFE" 3 "did_imputation (BJS 2024)" 5 "eventstudyinteract (SA 2021)") pos(6) rows(1) size(vsmall) region(style(none))) 	///
								xline(-1, lc(gs8) lp(dash)) ///
								yline(   0, lc(gs8) lp(dash)) ///
							 ) 

 graph save "$Results_Event_Combined_Voting/`var'_GrammarSchool.gph", replace

	restore
}

*** State and Kommunal Elections ***
foreach var in $Regress_LW $Regress_KW {
    
	preserve

***********************
*** a) TWFE ***
***********************   
*** TWFE ***
 xtreg `var' lead_GYM2 lead_GYM3 lead_GYM4 lead_GYM5 lead_GYM6 lead_GYM7 lead_GYM8 lead_GYM9 lead_GYM10 lead_GYM11 lead_GYM12 lead_GYM13 lead_GYM14 lead_GYM15 lead_GYM16 lead_GYM17 lead_GYM18 lag_GYM0-lag_GYM19 i.Year, fe vce(cluster AGS2020) 
 estimates store twfe 

***********************
*** d) Sun And Abraham ***
***********************
 eventstudyinteract `var' lead_GYM2 lead_GYM3 lead_GYM4 lead_GYM5 lead_GYM6 lead_GYM7 lead_GYM8 lead_GYM9 lead_GYM10 lead_GYM11 lead_GYM12 lead_GYM13 lead_GYM14 lead_GYM15 lead_GYM16 lead_GYM17 lead_GYM18 lag_GYM0-lag_GYM19, vce(cluster AGS2020) absorb(AGS2020 Year) cohort(minYear_GYM) control_cohort(NeverTreated_GYM)
 matrix sa_b = e(b_iw) 
 matrix sa_v = e(V_iw)
 
		
***********************
*** Combine in one graph ***
***********************		
colorpalette tableau, nograph	
			 					 
 event_plot  		twfe 			  		sa_b#sa_v  	  	, 	///
	stub_lag( 		lag_GYM#    	       	lag_GYM#  		 ) 		///
	stub_lead(		lead_GYM#  	           lead_GYM#   	 )		///
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

 graph save "$Results_Event_Combined_Voting/`var'_GrammarSchool.gph", replace

	restore
}

*** Export To PDF ***
foreach var in $Regress_BW $Regress_LW $Regress_KW { 
	graph use "$Results_Event_Combined_Voting/`var'_GrammarSchool.gph"
	graph export  "$Results_Event_Combined_Voting/`var'_GrammarSchool.pdf", as(pdf) replace
}


*** Graph Combine ***
// Comment: LInks und Rechts sehen nicht so gut aus... Links hoch rechts runter ?!
graph combine LEFT_ZS_BW__GrammarSchool.gph RIGHT_ZS_BW__GrammarSchool.gph OTHER_ZS_BW__GrammarSchool.gph Invalid_ZS_BW__GrammarSchool.gph VoteTurnout_ZS_BW__GrammarSchool.gph, title("Federal Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_BW_GrammarSchool.pdf", as(pdf) replace

// Comment: Sieht okayish aus
graph combine LEFT_ZS_LW__GrammarSchool.gph RIGHT_ZS_LW__GrammarSchool.gph OTHER_ZS_LW__GrammarSchool.gph Invalid_ZS_LW__GrammarSchool.gph VoteTurnout_ZS_LW__GrammarSchool.gph, title("State Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_LW_GrammarSchool.pdf", as(pdf) replace

// Comment: Sieht okayish aus
graph combine LEFT_ES_KW__GrammarSchool.gph RIGHT_ES_KW__GrammarSchool.gph OTHER_ES_KW__GrammarSchool.gph Invalid_ES_KW__GrammarSchool.gph VoteTurnout_ES_KW__GrammarSchool.gph, title("Kommunal Elections", size(medsmall))
graph export "$Results_Event_Combined_Voting\Event_Combined_KW_GrammarSchool.pdf", as(pdf) replace