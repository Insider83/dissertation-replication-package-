/**************************************************
This Do-File will produce the overall TWFE regressions for the school closure paper

-> This File: Mechanisms for Change in Voting Behaviour

	
	
	Author: Sebastian Vogler
	
	Version: 1.0, Created: 2024-11-14	
***************************************************/
*** Use Final Data-Set
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
destring AGS2020, replace
sort AGS2020 Year

*** Globals
* Results 
global Results_BalanchingTest "$results\Balancing Test"

* Makedir
capture mkdir "$Results_BalanchingTest"

********************************************************************************
* Treatment: First School Closes 
********************************************************************************
*** Elementary Schools ***  
*** Multi-Variate ***
eststo C_ES: reghdfe DummyFirstClosure_ES $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)
testparm $Controls_Default

*** Bi-Variate ***
*** Use this as placeholder to manually enter bi-variate
eststo C_ES_BI: reghdfe DummyFirstClosure_ES $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

*** Grammar Schools ***  
*** Multi-Variate ***	
eststo C_GYM: reghdfe DummyFirstClosure_GYM $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)
testparm $Controls_Default

*** Bi-Variate ***
*** Use this as placeholder to manually enter bi-variate
eststo C_GYM_BI: reghdfe DummyFirstClosure_GYM $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)


***	estout
esttab C_ES C_ES_BI C_GYM C_GYM_BI using "$Results_BalanchingTest\BalancingTestMultivariate.tex", cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) replace title("Balancing Test") varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

esttab C_ES C_ES_BI C_GYM C_GYM_BI using "$Results_BalanchingTest\BalancingTestMultivariate.txt", cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) replace title("Balancing Test") varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

eststo clear


*** Bivariate Regressions ***
*** Elementary Schools *** 
foreach var in $Controls_Default $Controls_ES {
    eststo C_ES_`var': reghdfe DummyFirstClosure_ES `var', absorb(AGS2020 Year) vce(cluster AGS2020)
}
esttab C* using "$Results_BalanchingTest\BalancingTestBivariate.txt", replace cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

esttab C* using "$Results_BalanchingTest\BalancingTestBivariate.tex", replace cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

eststo clear

*** Grammar Schools *** 
foreach var in $Controls_Default $Controls_GYM {
   eststo C_G_`var': reghdfe DummyFirstClosure_GYM `var', absorb(AGS2020 Year) vce(cluster AGS2020)
}
esttab C* using "$Results_BalanchingTest\BalancingTestBivariate.txt", append cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

esttab C* using "$Results_BalanchingTest\BalancingTestBivariate.tex", append cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

eststo clear


********************************************************************************
* Treatment: Last (Only) School Closes 
********************************************************************************
*** Elementary Schools ***  
*** Multi-Variate ***
eststo C_ES: reghdfe DummyOnlyClosure_ES $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)
testparm $Controls_Default

*** Bi-Variate ***
*** Use this as placeholder to manually enter bi-variate
eststo C_ES_BI: reghdfe DummyOnlyClosure_ES $Controls_Default $Controls_ES, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

*** Grammar Schools ***  
*** Multi-Variate ***	
eststo C_GYM: reghdfe DummyOnlyClosure_GYM $Controls_Default, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)
testparm $Controls_Default

*** Bi-Variate ***
*** Use this as placeholder to manually enter bi-variate
eststo C_GYM_BI: reghdfe DummyOnlyClosure_GYM $Controls_Default $Controls_GYM, absorb(AGS2020 Year) vce(cluster AGS2020)
qui sum `e(depvar)' if e(sample)
estadd scalar Mean = r(mean)
estadd scalar Distinct = e(N_clust)

***	estout
esttab C_ES C_ES_BI C_GYM C_GYM_BI using "$Results_BalanchingTest\BalancingTestMultivariate_OnlyClosure.txt", cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) replace title("Balancing Test") varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

esttab C_ES C_ES_BI C_GYM C_GYM_BI using "$Results_BalanchingTest\BalancingTestMultivariate_OnlyClosure.tex", cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) replace title("Balancing Test") varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

eststo clear

*** Bivariate Regressions ***
*** Elementary Schools *** 
foreach var in $Controls_Default $Controls_ES {
    eststo C_ES_`var': reghdfe DummyOnlyClosure_ES `var', absorb(AGS2020 Year) vce(cluster AGS2020)
}
esttab C* using "$Results_BalanchingTest\BalancingTestBivariate_OnlyClosure.txt", replace cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

esttab C* using "$Results_BalanchingTest\BalancingTestBivariate_OnlyClosure.tex", replace cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 
eststo clear

*** Grammar Schools *** 
foreach var in $Controls_Default $Controls_GYM {
   eststo C_G_`var': reghdfe DummyOnlyClosure_GYM `var', absorb(AGS2020 Year) vce(cluster AGS2020)
}
esttab C* using "$Results_BalanchingTest\BalancingTestBivariate_OnlyClosure.txt", append cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 

esttab C* using "$Results_BalanchingTest\BalancingTestBivariate_OnlyClosure.tex", append cells(b(fmt(%12,4f) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stats(Mean N , fmt(1 3)) note(Note: All Regressions controlled via Municipality and Year fixed effects. Standard-Errors clustered on the Municipality-Level.) varlabel(ShareUnemployedAge25 "Share Unemployed Age 15-25" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration Municipality" NetCommuter "Net Commuter" GenderRatio "Male Female Ratio" ShareMaleUnemployed "Share Male Unemployed" NetDeathBirth "Net Birth Death Ratio" TaxRevenue "Tax Revenue EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "Young Population" PopulationY6575 "Elderly Population"  DummyUrban "Dummy Urban" NumberChangesAGS "No. Terretorial Reforms" _cons "Constant") 
eststo clear

 
