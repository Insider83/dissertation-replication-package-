/*****************************************************************
	Master file, project: Education and regional mobility 
	over the life cycle
		
	Author: K. Cygan-Rehm + A. Barabasch + S. Vogler
	
	This file will produce the master-panel data set, all figures and tables
	
	For more information see "ReadMe.txt" in the Master-Folder
	
	Final Version with Master-Replication: 2025-04
***********************************************************/

version 14.1
clear
set more off
set seed 1258796
set sortseed 32154669 
set linesize 120
set varabbrev off, permanently

* global for date
gen date_current_temp = date("`c(current_date)'","DMY") 
format date_current_temp %tdCCYYNNDD
global date = string(date("`c(current_date)'","DMY"),"%tdCCYYNNDD") 
drop date_current_temp
di "$date"

********************************************************************************
* Set paths
* Insert SC6 with Onsite Data On County-Information
********************************************************************************
global data "Z:\SUF\Remote\SC6\SC6_R_13-0-0\Stata" 
global prog "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\do"
global log "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\log"
global results "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results"
global laws "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\schooling_laws"
global export "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\export"
global graphs "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\graphs"
global frandsen "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\frandsen"
global ratio "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\Teacher Student Ratio"
global rural "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\rural"
global lm "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\Labour Markets And Metropols"
global MergeUrbanFDZ "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Merge Tobias"
global DiDWeights "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\Compulsory Schooling\DiDWeights" 


********************************************************************************
* STEP 1: Generate basic panel over lifecycle for the relevant cohorts
********************************************************************************
do "$prog\230301_basic_panel.do" 
save "$results/0_basicpanel.dta", replace

********************************************************************************
* Extract and merge data on the residency spells
********************************************************************************
do "$prog\230301_residency.do" 
save "$results/0_basicpanel.dta", replace

********************************************************************************
* Extract and merge data on the school spells
********************************************************************************
do "$prog\230301_school_prep.do" 
save "$results/0_basicpanel.dta", replace

********************************************************************************
* Extract and merge data on the vocational training spells
********************************************************************************
do "$prog\230301_ausbild_prep_v1.do" 
save "$results/0_basicpanel.dta", replace

********************************************************************************
* Extract and merge data on the employment spells
********************************************************************************
do "$prog\230301_employment_prep.do"
save "$results/0_basicpanel.dta", replace

********************************************************************************
* STEP 2: Create files that will finally be merged to the basicpanel
********************************************************************************
* Weights 
do "$prog\230301_weights.do" 	

*Labor Market regions 
do "$prog\250305_LabourMarketPreparation.do" 	

* Week of birth
do "$prog\230301_weekofbirth.do" // extract data on week of birth 

* Schoolentry
do "$prog\230301_schoolentry.do" // information on date & state of school entry (from school file)

*Education
do "$prog\231207_educ_prep.do" // information on highest degree (from school file)

*Background
do "$prog\250410_background.do" // information on parental background + kindergarden

*Cognitive skills
do "$prog\250410_cognitiveskills_prep.do" // prep cognitive skills data
do "$prog\250410_locrisk_prep.do" // locus of control + risk

*Schooling laws // Available from Kamila Cygan-Rehm
do "$laws\000_schooling_laws_west.do" // west germany
do "$laws\000_schooling_laws_east.do" // east germany
do "$laws\000_schooling_laws_merge.do" // merge east + west germany
do "$laws\000_schooling_laws_runningvariable.do" // create dataset with running variable -> contains final dataset (schooling_laws_final)

* Rural: information was constructed onsite and provided as seperate dataset by the Research Data Centre (FDZ) of the Leibniz-Institute for Educational Trajectories

********************************************************************************
* STEP 3: Create outcome variables within basicpanel
********************************************************************************
do "$prog\250410_basicpanel_outcomes.do"  
save "$results/0_basicpanel_outcomes.dta", replace 

********************************************************************************
* STEP 4: Merge variables 
********************************************************************************
do "$prog\250410_sample_merge.do" // 
save "$results/0_basicpanel_final.dta", replace // final panel dataset; DO NOT overwrite anymore!

/*
- STEP 1 - STEP 4 create the full dataset
- After that, the analysis is split up into a descriptive part and two causal parts
- Compulsury Schooling and SSA require two different samples which are seperately constructed

*/

********************************************************************************
* Step 5.1: SSA analysis
********************************************************************************
* construct sample for SSA analysis (merge supplementary datasets)
do "$prog\250410_sample_ssa_new.do" 		// prepares basic dataset for SSA analysis
save "$results\ssa_panel_new.dta", replace 	// saves sample for SSA analysis (born and enrolled in west germany, 1945-1964) 

* create different datasets for analysis of 1st stage, migstock, migflow1, migflow5
do "$prog\240514_ssa_samplecleaning_new.do" 		

***********Results And Figures 
**Descriptives
do "$prog\240514_ssa_enrolment_new.do" // enrolment descriptives
do "$prog\240814_ssa_descriptives_new.do" // descriptives
do "$prog\240814_ssa_descriptives_donut_new.do" // descriptives donut without run_week -1,0,1,2
do "$prog\240814_neps_mz_comparison_new.do" // descriptives donut without run_week -1,0,1,2

**Mobility - maintable
do "$prog\241105_analysis_ssa_all_donut_new.do" // without run_week -1,0,1,2
do "$prog\240616_analysis_ssa_all_new.do" // main tables

**Mobility - number of moves
do "$prog\250303_analysis_ssa_numberofmoves_donut_new.do" // without run_week -1,0,1,2

**Mobility - heterogeneities
do "$prog\241104_analysis_ssa_all_donut_robustness_new.do" // 
do "$prog\240814_analysis_ssa_all_donut_rural_new.do" // rural/urban split
do "$prog\240814_analysis_commute_donut_new.do" // commuting
do "$prog\241104_analysis_ssa_all_gender_new.do" // gender split

**Mobility - graphs
do "$prog\240514_mig_graphs_byweek_datasets_new.do" // creates excel files export -> graphs will be produced locally
do "$prog\240514_mig_graphs_byweek_full_graphs_new.do" // produces graphs -> needs to be exported
do "$prog\240514_mig_graphs_byweek_donut_graphs_new.do" // produces graphs -> needs to be exported

** First Stage/Compliance - Table
do "$prog\240814_ssa_firststage_full_new.do" 
do "$prog\240814_ssa_firststage_donut_new.do" 
do "$prog\240814_ssa_firststage_full_unweighted_new.do" 
do "$prog\240814_ssa_firststage_donut_unweighted_new.do" 

** Educational Outcomes - Table
do "$prog\240814_analysis_ssa_educ_full_new.do" 
do "$prog\240814_analysis_ssa_educ_donut_new.do" // without run_week -1,0,1,2
do "$prog\240814_analysis_ssa_educ_full_unweighted_new.do" 
do "$prog\240814_analysis_ssa_educ_donut_unweighted_new.do" // without run_week -1,0,1,2

** Educational Outcomes - graphs
do "$prog\240514_educ_graphs_byweek_datasets_new.do" // creates excel files export -> graphs will be produced locally
do "$prog\240514_educ_graphs_byweek_full_graphs_new.do" // produces graphs -> needs to be exported
do "$prog\240514_educ_graphs_byweek_donut_graphs_new.do" // produces graphs -> needs to be exported

** Balancing Tests
do "$prog\240814_ssa_balancingtests_full_new.do" 
do "$prog\240814_ssa_balancingtests_donut_new.do" 
do "$prog\240814_ssa_balancingtests_full_unweighted_new.do" 
do "$prog\240814_ssa_balancingtests_donut_unweighted_new.do" 

** Mobility - lifecycle analysis
*Moving average
do "$prog\241122_ssa_lifecycle_analysis_donut_avg3.do" // moving average - 3 years
do "$prog\241122_ssa_lifecycle_graphs_avg3.do" // moving average - 3 years: graph

*1year
do "$prog\241104_ssa_lifecycle_analysis_donut_new.do" // lifecycle effects - regressions; without run_week -1,0,1,2
do "$prog\241122_ssa_lifecycle_graphs_donut_new.do" // lifecycle effects - graphs

*missing 
do "$prog\250303_ssa_lifecycle_missing_donut_new.do" // lifecycle effects - missing

** Density tests
do "$prog\240616_ssa_rddensity_donut_new.do"

do "$prog\240616_ssa_rdbwselect_donut_oneobs_new.do"

do "$prog\240616_ssa_rdbwselect_donut_2555_new.do"

** Placebo cutoff
do "$prog\240514_analysis_ssa_placebo_new.do" // placebo cutoff

*************Cognitive skills mechanism*********************
do "$prog\250303_cognitiveskills_prep_new.do" // prep cognitive skills data
do "$prog\240814_analysis_ssa_cognitiveskills_new.do" // analyse cognitive skills
do "$prog\240814_locrisk_prep_new.do" // prep cognitive skills data
do "$prog\240814_analysis_ssa_locrisk_new.do" // analyse cognitive skills


*************Compliers*************************
do "$prog\240328_compliers_ssa_all.do" // complier all
do "$prog\241002_compliers_ssa_donut.do" // complier donut

********************************************************************************
* Step 5.2: C9 analysis
********************************************************************************
********************************************************************************
* construct sample for C9 analysis (merge supplementary datasets)
********************************************************************************
do "$prog\250413_Combine_C9_final.do"

***************************** Mobility
do "$prog\250414_C9_TWFE_Migration_final.do" // !

***************************** Complier Analysis ********************************
do "$prog\250417_C9_Complier_final.do" // !

***************************** First Stages C9 on Education *********************
do "$prog\250417_C9_FirstStage_final.do" // !

***************************** Descriptives for Education ***********************
do "$prog\250417_C9_TWFE_Education_final.do" // For Table 2: Years of Schooling, SSA and YOS in Grades // !

***************************** Life-Cycle Analysis ******************************
********************** Incl. Missing Life-Cycle Analysis ***********************
do "$prog\250417_C9_LifeCycle_final.do" // 
do "$prog\250417_C9_MISSING_LifeCycle_final.do" // 

* Number of Moves
do "$prog\250414_C9_NumberMoves_final.do" // 

*** Attrition ***
do "$prog\250413_C9_attrition_final.do" // lifecycle effects - missing // 

**************** Mechanisms: Cognitive Skills **********************************
*** Prepare and Code Cognitive Skills from SC6 xCompetencies
do "$prog\250417_CognitiveSkills_Sebastian_final.do" // 

**************** Mechanism: Risk Aversion and LOC ******************************
do "$prog\250417_RiskAversionLocusOfControl_Sebastian_final.do" // 

**************** Mechanism: Total Number of Moves ******************************
**************** This Inlcudes Labour Market Outcomes **************************
do "$prog\250417_C9_NumberMoves_final.do" // 
do "$prog\250417_C9_LabourMarketMetropols_final.do" // 

********************** Sensitivity Analyses ************************************
****************** DID - Estimations (Borusyak) ********************************
do "$prog\250417_Compulsory_TWFE_DidImputation_final.do"

****************** Negative Weights ***********************
do "$prog\251212_C9_Weight_Diagnostics.do"

********************* Wooldridge DiD **********************
do "$prog\250417_C9_AlternativeDiD_final.do" // !
do "$prog\250417_C9_AlternativeDiD_EventStudy.do" // Event Study Graphs!

**** Unweighted Estimations, Exclusion of Always-Treated and Single States *****
do "$prog\250417_Sensitivity_Exclusion_final.do" // !

**** Itinery On Random Assignment of C9 - Reform Date ***
do "$prog\240120_Sensitivity_Exclusion_ReformAssignment.do" // !


********************************************************************************
* Balancing Test and Main Descriptives
********************************************************************************
do "$prog\250413_C9_Descriptives_BalancingTests_final.do" // Does Balancing Test (Bi- and Multivariate) // !

do "$prog\250413_C9_Descripives_Tables_final.do" // Generate Means for Descriptives (-> Only for the C9 Sample, Column 2) // !

do "$prog\250413_DescriptivesFullSample_final.do" // Generate Means for Descriptives (Full  Sample, not only C9 - Column 1 ) // !


******************************************************************************** ********************************************************************************
* New: Merge Rural Info to final Panel Data Set to Regress Rural-Urban-Mobility
******************************************************************************** ********************************************************************************
******************************************************************************** ********************************************************************************
* Do Every Thing from basic panel again to merge one Rural Dummy again
* Create a Sibling-Basic-Panel, but with restricted information from the FDZ
******************************************************************************** ********************************************************************************
********************************************************************************
* 0: Prepare FDZ-Files (Clonevar, remove redundancy and so on)
********************************************************************************
do "$prog\20251104_Create_UrbanTime.do"

********************************************************************************
* 1: Generate basic panel over lifecycle for the relevant cohorts
********************************************************************************
do "$prog\251104_basic_panel_UrbanRural.do" 
save "$results/0_basicpanel_UrbanRural.dta", replace

********************************************************************************
* Extract and merge data on the residency spells
********************************************************************************
do "$prog\251104_residency_UrbanRural.do" 
save "$results/0_basicpanel_UrbanRural.dta", replace

********************************************************************************
* Extract and merge data on the school spells
********************************************************************************
do "$prog\251104_school_prep_UrbanRural.do" 
save "$results/0_basicpanel_UrbanRural.dta", replace

********************************************************************************
* Extract and merge data on the vocational training spells
********************************************************************************
do "$prog\251104_ausbild_prep_v1_UrbanRural.do" 
save "$results/0_basicpanel_UrbanRural.dta", replace

********************************************************************************
* Extract and merge data on the employment spells
********************************************************************************
do "$prog\251104_employment_prep_UrbanRural.do"
save "$results/0_basicpanel_UrbanRural.dta", replace

***
* 2: Create new (Urban-Rural) Mobility Measures and compress (collapse age year) datasetset for merge with original SSA and C9-Sample
***
do "$prog\251111_basicpanel_outcomes.do"  
* This will create file "0_Panel_Migration_Urban_Rural_Municipality_Merge.dta" in the results-Folder

***
* 3: Merge with C9 Sample 
* -> Done directly within the regressions file
*** 

*** Regressions on Rural-Urban-Mobility
do "251107_C9_TWFE_UrbanRural_final.do"

*** Additional SE-Clustering 
do "251125_C9_AdditionalClustering.do"

********************************************************************************
* Visualizations
********************************************************************************
*** OLS ***
do "$prog\250414_VisualisationCrossStateOLS_final.do"

*** Visualized Gender and Migration over Time
do "$prog\250414_VisualisationMigrationGenderOverTime_final.do" /// Figures 

*** Visualized Percentages and level of Mobility (County or State) over time (Grey and Black)
do "$prog\250413_VisualisationLevelofMigration_final.do" // Figure 1 (Age-Specific cross-state and cross-county mobility rates)

*** Maps *** // Have to be last Do-Files, as we have to change directory manually! 

** Bula **
do "$prog\230511_Maps_final.do"

** County **
do "$prog\231219_Maps_County.do"




