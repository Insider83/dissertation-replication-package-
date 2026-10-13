/**************************************************
   This is the Master-File of the School-Closure Paper
   
   In this Paper, I investigate the effect of (permanent) School Closures on economic performance of municipalities 
   
   To Do So, You Will need confidential data on:
	- Schools in Germany (Available through Helbig (2018) )
	- Data On Municipality Merges (Available Through BBSR)
	- Data On Voting Behaviour (Available through State Statistic Offices)
	- Data On Municipality Development (Available Through BBSR)
   
   The Master-File will do several things in the following order:
   I) Generate (unbalanced) Basic Panel of all German Municipalities (incl. Merging of Municipalities and Counties!)
   II) Process information on any change of administrative names, territory or abolishment
   III) Merge Data on territory change (Municipality and County) with Longitute and Latitute from I) and Create Panel by expanding to year wise
   IV) Use Original Data-Set from Marcel Helbig, Process Data and Generate Data Set (Year-Wise due to data-amount) 
   V) Merge Data of school closures with above created basic panel
   VI) Process dependent variables from the Federal Statistics Office
   VII) Merge Data from federal Statistics Office
   x) Figures And Tables
	
	Author: Sebastian Vogler
	
	Version: 2.0, Created: 2026 - 10
***************************************************/


/**************************************************
* SSC Install
***************************************************
//supporting packages
ssc install schemepack, replace
ssc install avar, replace 
ssc install reghdfe, replace
ssc install event_plot, replace
ssc install palettes, replace
ssc install colrspace, replace
ssc install estout, replace
ssc install parmest, replace
ssc install distinct, replace
ssc install coefplot, replace
ssc install lincomest, replace
ssc install grc1leg2, replace

// DiD packages
ssc install drdid, replace
ssc install csdid, replace
ssc install did_imputation, replace
ssc install eventstudyinteract, replace
ssc install did_multiplegt, replace 
ssc install stackedev, replace 
ssc install did2s, replace

// F - Test 
ssc install ftest

// TWFE Packages
ssc install ftools
ssc install require

// Matching Packages
ssc install psmatch2

// Maps Of Germany
ssc install spmap, replace
ssc install shp2dta, replace
ssc install mif2dta, replace

// Panel View
net install panelview, all replace from("https://yiqingxu.org/packages/panelview_stata") // to describe panel data structures
net install grc1leg, from("http://www.stata.com/users/vwiggins") replace // required for panelview
net install gr0075, from("http://www.stata-journal.com/software/sj18-4") replace // required for panelview
ssc install labutil, replace // required for panelview
ssc install sencode, replace // required for panelview
net install panelview, all replace from("https://yiqingxu.org/packages/panelview_stata")

*/


/**************************************************
* Globals
***************************************************/
* Master Dir
global master "E:\Dokumente\School-Closing" // Input Master Folder

*Do-Files
global do "$master\Masterfile"

*Auxiliary Data (e.g. Info on Changes in Territory or Shape-Files)
global aux "$master\Auxiliary Data"

*Results From Merging and Regressions
global results "$master\Results"
global Results_VotingBehaviour_TWFE "$results\Voting Behaviour\TWFE"
global Results_Mechanism_TWFE "$results\Mechanism\TWFE"

*Database INKAR
global database "" // Input INKAR File

* Panel View Visualization
global Visualization_PanelView "$results\Visualisierungen\Panel View"

* Database Voting Behaviour
global VotingBehaviour "$master\Daten Wahlverhalten" // Input Voting Data

* Visualization Voting Behavior
global VisualizationVotingBehaviour "$master\Results\Visualisierungen\Voting Behaviour"

*Files and Data From Nearest-Neighbour-Merging
global NNMerge "$master\Nearest Neighbour Merge"

* Files and Data for Structural Reform Assignments 
global Reform "$master\Gesetze und Dokumente Schulschließung\Strukturreform" // Input Data On School Reforms (Available On Request)

* Matching for DiD 
global Matching "$master\Matching"

* Matching TWFE, DiD, Event-Studies results
global Results_Matching_Voting "$results\Voting Behaviour\Merged" 
global Results_Matching_Mechanism "$results\Mechanism\Merged"

* Results TWFE, As Well As Combined Results TWFE and Event-Studies (Sun And Abraham); Main-Results-Table XXX in Paper!
global Results_VotingBehaviour_TWFE "$master\Results\Voting Behaviour\TWFE"
global Results_Mechanism_TWFE "$master\Results\Mechanism\TWFE"

* Combine All Event-Studies for Voting And Mechanism
global Results_Event_Combined_Voting "$results\Voting Behaviour\CombinedGraphsEvent"
global Results_Event_Combined_Mechanism "$results\Mechanism\CombinedGraphsEvent"

* Robustness Tests
global RobustnessVoting "$results\Voting Behaviour\Robustnes"
global RobustnessMechanisms "$results\Mechanism\Robustnes"

* Global Controlls
global Controls_Default ShareMaleUnemployed NetDeathBirth TaxRevenue TaxCapacity PopulationY6575 DummyUrban 

* Global Everything we need for Mahalanobis Matching (Keep This to reduce time and data) 
global KeepMahalanobis AGS2020 AGS2020_ Year minYear_ES minYear_GYM Year_OnlyClosure_ES Year_OnlyClosure_GYM NeverTreated_ES NeverTreated_GYM $Mechanism $Controls_Default State

*** *** Depenend Variables for Regressions and Matching *** ***
*** Voting Behaviour
global Regress_BW LEFT_ZS_BW_ RIGHT_ZS_BW_ OTHER_ZS_BW_  VoteTurnout_ZS_BW_ 
global Regress_LW LEFT_ZS_LW_ RIGHT_ZS_LW_ OTHER_ZS_LW_  VoteTurnout_ZS_LW_ 
global Regress_KW LEFT_ES_KW_ RIGHT_ES_KW_ OTHER_ES_KW_  VoteTurnout_ES_KW_ 

*** Mechanism
global Mechanism ShareUnemployedAge25 LTUnemp AvrgAgePop NetCommuter GenderRatio 

*Set Seed For Replication
set seed 123

* Set Sheme 
set scheme s1mono, permanent

* XIII) Descriptives
do "$do\14_Descriptives.do"

*****************************************************
* XIV)  Regressions (TWFE, DiD, Callaway&San´Anna and misceallous Event-Studies)
*****************************************************
*****************************************************
* First School Closure
*****************************************************
* TWFE/DiD/Event
do "$do\15_Regressions_Event_TWFE_VotingBehaviour.do" // Combine TWFE and Event-Study in one Table (Table A6 in Paper)
do "$do\15_Regressions_Event_TWFE_Mechanisms.do" // Combine TWFE and Event-Study in one Table (Table A7 in Paper)

* XVII) Matching and matched DiD 
** Non-Reform **
* Matching Algorithm
do "$do\17_Matching_final.do" // 

* XVIII) Combine All Functional Event-Studies into one beautiful Graph (for figure X)
do "$do\19_CombineAllEventStudies_VotingBehaviour.do"
do "$do\19_CombineAllEventStudies_Mechanisms.do"

* XVIII) Robustness Checks
do "$do\20_Robustness_Checks_VotingBehaviour.do"
do "$do\20_Robustness_Checks_Mechanisms.do"

*****************************************************
* Last School Closure
*****************************************************
* TWFE/DiD/Event
do "$do\15_L_Regressions_Event_TWFE_VotingBehaviour.do"  // Combine TWFE and Event-Study in one Table (Table A8 in Paper)
do "$do\15_L_Regressions_Event_TWFE_Mechanisms.do"  // Combine TWFE and Event-Study in one Table (Table A9 in Paper)

* XVII) Matching and matched DiD 
** Non-Reform **
* Matching Algorithm
do "$do\17_L_Matching_final.do" // 
* Voting Behaviour
do "$do\17_1_L_Matched_TWFE_DiD_VotingBehaviour.do" // 
* Mechanism
do "$do\17_2_L_Matched_TWFE_DiD_Mechanisms.do" //  

* XVIII) Combine All Functional Event-Studies into one beautiful Graph (for figure X)
do "$do\19_L_CombineAllEventStudies_Mechanisms.do" // 
do "$do\19_L_CombineAllEventStudies_VotingBehaviour.do" // 

* XVIII) Robustness Checks
do "$do\20_L_Robustness_Checks_VotingBehaviour.do"
do "$do\20_L_Robustness_Checks_Mechanisms.do"

*****************************************************
* XIX) Balancing Tests
*****************************************************
do "$do\93_BalancingTests.do" 

*****************************************************
* XXX) Visualizations
*****************************************************
* Visualization School Closures - Bar Graphs of School Numbers and Closures and Line Graphs for Changes in Terretorial Reforms
do "$do\90_Visualizations_SchoolClosures.do"

* Visualization School Closures - Maps Of Germany
do "do\91_Visualizations_MapsOfGermany.do"

* Visualization Treatment Timings - Panel View
do "$do\93_Visualizations_PanelView.do"

