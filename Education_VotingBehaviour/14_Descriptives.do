/**************************************************
This Do-File will produce the descriptives for the School Closure Paper. This contains the dependent and independent Variables 
	
	
	Author: Sebastian Vogler
	
	Version: 1.0, Created: 2023-12-01	
***************************************************/

* Use Final Data-Set
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
sort AGS2020 Year

*Set Panel -> We need to destring AGS2020 in order to use it as a XTSET
destring AGS2020, replace
xtset AGS2020 Year

	
**********************	
*** Mean, distinguished by No Closure and Closure ***
**********************

****************************************
* Generate Summary Statistics For Export
****************************************
****************************************
* City and Territorial Reforms
****************************************

****************************************
*** Label (Only For Esttab) ***    
****************************************        
label var AGS2020 "Unqiue Municipality Identifier"
label var State "State"
label var Year "Year of Obs."
label var NumberChanges "No. Territorial Reforms"
label var NumberChangesCounties "No. Territorial Reforms County"
label var NumberSchools_ES "No. Elem. Schools"
label var NumberSchools_GYM "No. Grammar Schools"

**********************
* Summary With Treatment-Difference in Mean
**********************
* Liste of All Variables
ds Year NumberChanges NumberChangesCounties NumberSchools_ES NumberSchools_GYM 
local variables `r(varlist)'

* Berechne Mean And DIfference In Treatment
* Initialize Matrix to edit
matrix diff = J(`: word count `variables'', 5, .)
local i = 1

foreach var in `variables' {
	
	* Mean for All
    quietly summarize `var' 
    scalar mean = r(mean)
	
    * Mean Treatment == 1
    quietly summarize `var' if EverTreated == 1
    scalar mean_t1 = r(mean)
    
    * Mean Treatment == 0
    quietly summarize `var' if EverTreated == 0
    scalar mean_t0 = r(mean)
    
    * Difference in Mean
    scalar diff_mean = mean_t1 - mean_t0
    
    * t-test
    ttest `var', by(EverTreated)
    scalar t_value = r(t)
    
    * Save above metrics
	matrix diff[`i', 1] = mean
    matrix diff[`i', 2] = mean_t0
    matrix diff[`i', 3] = mean_t1
    matrix diff[`i', 4] = diff_mean
    matrix diff[`i', 5] = t_value
    
    * Increment Counter
    local ++i
}

* Name Row And Colomn
matrix rownames diff = `variables'
matrix colnames diff = Mean Mean_Treatment0 Mean_Treatment1 Difference t_Value

* Quality Check
matrix list diff

* Export Matric to LaTeX
esttab matrix(diff, fmt(3 3 3 3 1)) using "$master\Results\Descriptives\Descriptives_All_Diff_MunicipalityAndReforms.tex", replace ///
    title("Mean Differences Between Treatments - Municipality And Reforms") varlabel(AAGS2020 "Unqiue Municipality Identifier" State "State" NumberChanges "No. Territorial Reforms" NumberChangesCounties "No. Territorial Reforms County" _CX "Longitude Centre Municipality" _CY "Latitude Centre Municipality" NumberSchools "Number Schools" NumberSchools_ES "No. Elem. Schools" NumberSchools_SS "No. Second. Schools" NumberSchools_GYM "No. Grammar Schools" NumSchoolsRemain_ES_PC "No. Remaining Elem. Schools per Capita" NumSchoolsRemain_SS_PC "No. Remaining Secon. Schools per Capita" NumSchoolsRemain_GYM_PC "No. Remaining Grammar Schools per Capita") ///
    collabels(`"Treatment==0" "Treatment==1" "Difference" "t-Value"') ///
    nonumber label
	
	
	
****************************************
* Mechanisms And Controlls
****************************************
* Mechanisms: ShareUnemployedAge25 LTUnemp AvrgAgePop NetMigration NetCommuter GenderRatio  
* Controlls: ShareMaleUnemployed NetDeathBirth TaxRevenue TaxCapacity YoungerPopulation PopulationY6575 DummyUrban NumberChangesAGS 

****************************************
*** Label (Only For Esttab) ***    
**************************************** 
*** Mechanisms ***
label var ShareUnemployedAge25 "Perc. of Unemp. Aged 15-25"
label var LTUnemp "Perc. Long Term Unempl."
label var AvrgAgePop "Average Population Age"
label var NetMigration "Net. Migration in Mun."
label var NetCommuter "Net. In Out Commuter"
label var GenderRatio "Male To Female Population Share" 

*** Controlls (Besides Remaining Schools)
label var ShareMaleUnemployed "Share of Male Total Unemployed" 
label var NetDeathBirth "Net Birth To Death Ratio"
label var TaxRevenue "Total Tax Revenue in EUR"
label var TaxCapacity "Tax leverage rate" // Proxy for economic attractiveness
label var YoungerPopulation "No. Population aged 3, 6, 18-25" // Proxy for Child Care
label var PopulationY6575 "Elderly Population" // Proxy for elderly care
label var DummyUrban "Dummy: Municipality>50.000"
label var NumberChangesAGS "No. Terretorial Reforms Since 2000"


**********************
* Summary With Treatment-Difference in Mean
**********************
* Liste der zu analysierenden Variablen erstellen
ds $Mechanism $Controls_Default
local variables `r(varlist)'

* Berechne Mean And DIfference In Treatment
* Initialize Matrix to edit
matrix diff = J(`: word count `variables'', 5, .)
local i = 1

foreach var in `variables' {
	
	* Mean for All
    quietly summarize `var' 
    scalar mean = r(mean)
	
    * Mean Treatment == 1
    quietly summarize `var' if EverTreated == 1
    scalar mean_t1 = r(mean)
    
    * Mean Treatment == 0
    quietly summarize `var' if EverTreated == 0
    scalar mean_t0 = r(mean)
    
    * Difference in Mean
    scalar diff_mean = mean_t1 - mean_t0
    
    * t-test
    ttest `var', by(EverTreated)
    scalar t_value = r(t)
    
    * Save above metrics
	matrix diff[`i', 1] = mean
    matrix diff[`i', 2] = mean_t0
    matrix diff[`i', 3] = mean_t1
    matrix diff[`i', 4] = diff_mean
    matrix diff[`i', 5] = t_value
    
    * Increment Counter
    local ++i
}

* Name Row And Colomn
matrix rownames diff = `variables'
matrix colnames diff = Mean Mean_Treatment0 Mean_Treatment1 Difference t_Value

* Quality Check Matrix
matrix list diff

* Exportiere die Matrix nach LaTeX
esttab matrix(diff, fmt(3 3 3 3 1)) using "$master\Results\Descriptives\Descriptives_All_Diff_Economic.tex", replace ///
    title("Mean Differences Between Treatments - Economic Development") ///
	varlabel(ShareUnemployedAge25 "Shr Youth Unemployment" LTUnemp "Perc. Long Term Unempl." AvrgAgePop "Average Population Age" NetMigration "Net Migration into Municipality" NetCommuter "Net In Out Commuter" GenderRatio "Male To Female Population Ratio" ShareMaleUnemployed "Share of Male Total Unemployed" NetDeathBirth "Net Birth To Death Ratio" TaxRevenue "Total Tax Revenue in EUR" TaxCapacity "Tax leverage rate" YoungerPopulation "No. Population aged 3, 6, 18-25" PopulationY6575 "Shr. Population aged 65-75"  DummyUrban "Dummy Municipality $\geq$ 50.000" NumberChangesAGS "No. Terretorial Reforms Since 2000") ///
    collabels(`"Treatment==0" "Treatment==1" "Difference" "t-Value"') ///
    nonumber

	
	
****************************************
* Treatments (School Closures)
****************************************
****************************************
*** Label (Only For Esttab) ***    
****************************************        
label var SchoolIdentifier "Unique School Identifier"
label var DistanceCenter "Distance School To Centre"
label var minYear_ES "Year of Closure Elem. School"
label var minYear_SS "Year of Closure Second. School"
label var minYear_GYM "Year of Closure Grammar School"
label var minYear "Year of School Closure "
label var Year_OnlyClosure_ES "Yr Only Elem. School Closure"
label var Year_OnlyClosure_SS "Yr Only Second. School Closure"
label var Year_OnlyClosure_GYM "Yr Only Grammar School Closure"
label var Year_OnlyClosure "Yr Only School Closure"
label var DummyNoSchool "Dummy Municipality has no School"
label var DummyFirstClosure_ES "Dummy Elem. School Closure"
label var DummyFirstClosure_SS "Dummy Second. School Closure"
label var DummyFirstClosure_GYM "Dummy Grammar. School Closure"
label var DummyFirstClosure "Dummy School Closure"
label var DummyOnlyClosure_ES "Dummy Only Elem. School Closed"
label var DummyOnlyClosure_SS "Dummy Only Second. School Closed"
label var DummyOnlyClosure_GYM "Dummy Only Grammar School Closed"
label var DummyOnlyClosure "Dummy Only School Closed"

**********************
* Summary With Treatment-Difference in Mean
**********************
* Liste der zu analysierenden Variablen erstellen
* ds SchoolIdentifier DistanceCenter minYear_ES minYear_SS minYear_GYM minYear Year_OnlyClosure_ES Year_OnlyClosure_SS Year_OnlyClosure_GYM Year_OnlyClosure DummyNoSchool DummyFirstClosure_ES DummyFirstClosure_SS DummyFirstClosure_GYM DummyFirstClosure DummyOnlyClosure_ES DummyOnlyClosure_SS DummyOnlyClosure_GYM DummyOnlyClosure
ds minYear_ES minYear_GYM Year_OnlyClosure_ES Year_OnlyClosure_GYM DummyNoSchool DummyFirstClosure_ES DummyFirstClosure_GYM DummyOnlyClosure_ES DummyOnlyClosure_SS DummyOnlyClosure_GYM
local variables `r(varlist)'

* Berechne Mean And DIfference In Treatment
* Initialize Matrix to edit
matrix diff = J(`: word count `variables'', 5, .)
local i = 1

foreach var in `variables' {
	
	* Mean for All
    quietly summarize `var' 
    scalar mean = r(mean)
	
    * Mean Treatment == 1
    quietly summarize `var' if EverTreated == 1
    scalar mean_t1 = r(mean)
    
    * Mean Treatment == 0
    quietly summarize `var' if EverTreated == 0
    scalar mean_t0 = r(mean)
    
    * Difference in Mean
    scalar diff_mean = mean_t1 - mean_t0
    
    * t-test
    ttest `var', by(EverTreated)
    scalar t_value = r(t)
    
    * Save above metrics
	matrix diff[`i', 1] = mean
    matrix diff[`i', 2] = mean_t0
    matrix diff[`i', 3] = mean_t1
    matrix diff[`i', 4] = diff_mean
    matrix diff[`i', 5] = t_value
    
    * Increment Counter
    local ++i
}

* Name Row And Colomn
matrix rownames diff = `variables'
matrix colnames diff = Mean Mean_Treatment0 Mean_Treatment1 Difference t_Value

* Quality Check Matrix
matrix list diff

* Exportiere die Matrix nach LaTeX
esttab matrix(diff, fmt(3 3 3 3 1)) using "$master\Results\Descriptives\Descriptives_All_Diff_SchoolCharacteristics.tex", replace ///
    title("Mean Differences Between Treatments - School Characteristics") varlabel( SchoolIdentifier "Unique School Identifier" DistanceCenter "Distance School To Centre" minYear_ES "Year of Closure Elem. School" minYear_SS "Year of Closure Second. School" minYear_GYM "Year of Closure Grammar School" minYear "Year of School Closure " Year_OnlyClosure_ES "Yr Only Elem. School Closure" Year_OnlyClosure_SS "Yr Only Second. School Closure" Year_OnlyClosure_GYM "Yr Only Grammar School Closure" Year_OnlyClosure "Yr Only School Closure" DummyNoSchool "Dummy Municipality has no School" DummyFirstClosure_ES "Dummy Elem. School Closure" DummyFirstClosure_SS "Dummy Second. School Closure" DummyFirstClosure_GYM "Dummy Second. School Closure" DummyFirstClosure "Dummy School Closure" DummyOnlyClosure_ES "Dummy Only Elem. School Closed" DummyOnlyClosure_SS "Dummy Only Second. School Closed" DummyOnlyClosure_GYM "Dummy Only Grammar School Closed" DummyOnlyClosure "Dummy Only School Closed") ///
 collabels(`"Mean" "Treatment==0" "Treatment==1" "Difference" "t-Value"') ///
 nonumber 
	


****************************************
* Voting Behaviour - We lose a lot of Obs here, so have to come last!
****************************************
****************************************
* State Election
****************************************
****************************************
*** Label (Only For Esttab) ***    
**************************************** 
label var LEFT_ZS_LW_ "Left-Fridge Parties in \%. State Elec."
label var RIGHT_ZS_LW_ "Right-Fridge Parties in \%. State Elec."
label var OTHER_ES_LW_ "Non-Traditional Parties in \%. State Elec."
label var VoteTurnout_ZS_LW_ "Vote Turnout in \%. State Elec."


**********************
* Summary With Treatment-Difference in Mean
**********************
* Liste der zu analysierenden Variablen erstellen
* ds VoteTurnout_ZS_LW_ Invalid_ZS_LW_ OTHER_ZS_LW_ LEFT_ZS_LW_ RIGHT_ZS_LW_
ds VoteTurnout_ZS_LW_ OTHER_ZS_LW_ LEFT_ZS_LW_ RIGHT_ZS_LW_
local variables `r(varlist)'

* Berechne Mean And DIfference In Treatment
* Initialize Matrix to edit
matrix diff = J(`: word count `variables'', 5, .)
local i = 1

foreach var in `variables' {
	
	* Mean for All
    quietly summarize `var' 
    scalar mean = r(mean)
	
    * Mean Treatment == 1
    quietly summarize `var' if EverTreated == 1
    scalar mean_t1 = r(mean)
    
    * Mean Treatment == 0
    quietly summarize `var' if EverTreated == 0
    scalar mean_t0 = r(mean)
    
    * Difference in Mean
    scalar diff_mean = mean_t1 - mean_t0
    
    * t-test
    ttest `var', by(EverTreated)
    scalar t_value = r(t)
    
    * Save above metrics
	matrix diff[`i', 1] = mean
    matrix diff[`i', 2] = mean_t0
    matrix diff[`i', 3] = mean_t1
    matrix diff[`i', 4] = diff_mean
    matrix diff[`i', 5] = t_value
    
    * Increment Counter
    local ++i
}

* Name Row And Colomn
matrix rownames diff = `variables'
matrix colnames diff = Mean Mean_Treatment0 Mean_Treatment1 Difference t_Value

* Quality Check Matrix
matrix list diff

* Exportiere die Matrix nach LaTeX
esttab matrix(diff, fmt(3 3 3 3 1)) using "$master\Results\Descriptives\Descriptives_All_Diff_Voting_LW.tex", replace ///
    title("Mean Differences Between Treatments - Voting Behaviour") varlabel(VoteTurnout_ZS_LW_ "Vote Turnout in \%. State Elec." Invalid_ZS_LW_ "Invalid Votes in \%. State Elec." OTHER_ZS_LW_ "Non-Traditional Parties in \%. State Elec." LEFT_ZS_LW_ "Left-Fridge Parties in \%. State Elec." RIGHT_ZS_LW_ "Right-Fridge Parties in \%. State Elec.") ///
    collabels(`"Mean" "Treatment==0" "Treatment==1" "Difference" "t-Value"') ///
    nonumber

	
****************************************
* Federal Election
****************************************	
****************************************
*** Label (Only For Esttab) ***    
**************************************** 
label var LEFT_ZS_BW_ "Left-Fridge Parties in \%. Federal Elec."
label var RIGHT_ZS_BW_ "Right-Fridge Parties in \%. Federal Elec."
label var OTHER_ZS_BW_ "Non-Traditional Parties in \%. Federal Elec."
label var VoteTurnout_ZS_BW_ "Vote Turnout in \%. Federal Elec."


**********************
* Summary With Treatment-Difference in Mean
**********************
* Liste der zu analysierenden Variablen erstellen
ds VoteTurnout_ZS_BW_ OTHER_ZS_BW_ LEFT_ZS_BW_ RIGHT_ZS_BW_ // CDU_ZS_BW_ SPD_ZS_BW_ DIELINKE_ZS_BW_ FDP_ZS_BW_ GRÜN_ZS_BW_ Invalid_ZS_BW_
local variables `r(varlist)'

* Berechne Mean And DIfference In Treatment
* Initialize Matrix to edit
matrix diff = J(`: word count `variables'', 5, .)
local i = 1

foreach var in `variables' {
	
	* Mean for All
    quietly summarize `var' 
    scalar mean = r(mean)
	
    * Mean Treatment == 1
    quietly summarize `var' if EverTreated == 1
    scalar mean_t1 = r(mean)
    
    * Mean Treatment == 0
    quietly summarize `var' if EverTreated == 0
    scalar mean_t0 = r(mean)
    
    * Difference in Mean
    scalar diff_mean = mean_t1 - mean_t0
    
    * t-test
    ttest `var', by(EverTreated)
    scalar t_value = r(t)
    
    * Save above metrics
	matrix diff[`i', 1] = mean
    matrix diff[`i', 2] = mean_t0
    matrix diff[`i', 3] = mean_t1
    matrix diff[`i', 4] = diff_mean
    matrix diff[`i', 5] = t_value
    
    * Increment Counter
    local ++i
}

* Name Row And Colomn
matrix rownames diff = `variables'
matrix colnames diff = Mean Mean_Treatment0 Mean_Treatment1 Difference t_Value

* Quality Check Matrix
matrix list diff

* Exportiere die Matrix nach LaTeX
esttab matrix(diff, fmt(3 3 3 3 1)) using "$master\Results\Descriptives\Descriptives_All_Diff_Voting_BW.tex", replace ///
    title("Mean Differences Between Treatments - Voting Behaviour") varlabel(VoteTurnout_ZS_BW_ "Vote Turnout in \%. Federal Elec." Invalid_ZS_BW_ "Invalid Votes in \%. Federal Elec." OTHER_ZS_BW_ "Non-Traditional Parties in \%. Federal Elec." LEFT_ZS_BW_ "Left-Fridge Parties in \%. Federal Elec." RIGHT_ZS_BW_ "Right-Fridge Parties in \%. Federal Elec.") ///
    collabels(`"Mean" "Treatment==0" "Treatment==1" "Difference" "t-Value"') ///
    nonumber
	


****************************************
* Voting Behaviour
****************************************
****************************************
* Communal Election
****************************************
****************************************
*** Label (Only For Esttab) ***    
**************************************** 
label var LEFT_ES_KW_ "Left-Fridge Parties in \%. Communal Elec."
label var RIGHT_ES_KW_ "Right-Fridge Parties in \%. Communal Elec."
label var OTHER_ES_KW_ "Non-Traditional Parties in \%. Communal Elec."
label var VoteTurnout_ES_KW_ "Vote Turnout in \%. Communal Elec."


**********************
* Summary With Treatment-Difference in Mean
**********************
* Liste der zu analysierenden Variablen erstellen
ds VoteTurnout_ES_KW_ OTHER_ES_KW_ LEFT_ES_KW_ RIGHT_ES_KW_ // Invalid_ES_KW_ CDU_ES_KW_ SPD_ES_KW_ DIELINKE_ES_KW_ GRÜN_ES_KW_ FDP_ES_KW_ 
local variables `r(varlist)'

* Berechne Mean And DIfference In Treatment
* Initialize Matrix to edit
matrix diff = J(`: word count `variables'', 5, .)
local i = 1

foreach var in `variables' {
	
	* Mean for All
    quietly summarize `var' 
    scalar mean = r(mean)
	
    * Mean Treatment == 1
    quietly summarize `var' if EverTreated == 1
    scalar mean_t1 = r(mean)
    
    * Mean Treatment == 0
    quietly summarize `var' if EverTreated == 0
    scalar mean_t0 = r(mean)
    
    * Difference in Mean
    scalar diff_mean = mean_t1 - mean_t0
    
    * t-test
    ttest `var', by(EverTreated)
    scalar t_value = r(t)
    
    * Save above metrics
	matrix diff[`i', 1] = mean
    matrix diff[`i', 2] = mean_t0
    matrix diff[`i', 3] = mean_t1
    matrix diff[`i', 4] = diff_mean
    matrix diff[`i', 5] = t_value
    
    * Increment Counter
    local ++i
}

* Name Row And Colomn
matrix rownames diff = `variables'
matrix colnames diff = Mean Mean_Treatment0 Mean_Treatment1 Difference t_Value

* Quality Check Matrix
matrix list diff

* Exportiere die Matrix nach LaTeX
esttab matrix(diff, fmt(3 3 3 3 1)) using "$master\Results\Descriptives\Descriptives_All_Diff_Voting_KW.tex", replace ///
    title("Mean Differences Between Treatments - Voting Behaviour") varlabel(VoteTurnout_ES_KW_ "Vote Turnout in \%. Communal Elec." Invalid_ES_KW_ "Invalid Votes in \%. Communal Elec." OTHER_ES_KW_ "Non-Traditional Parties in \%. Communal Elec." LEFT_ES_KW_ "Left-Fridge Parties in \%. Communal Elec." RIGHT_ES_KW_ "Right-Fridge Parties in \%. Communal Elec.") ///
    collabels("Mean" "Treatment==0" "Treatment==1" "Difference" "t-Value") ///
     nonumber 