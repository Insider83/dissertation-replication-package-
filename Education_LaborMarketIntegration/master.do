/********************************************************************************
* Date: 2025/10
* Davit Adunts, Truc Nguyen, Sebastian Vogler


This file will produce all tables, figures and results for the paper "Host-country School Exposure and Refugee Youth Labor Integration: Evidence from German Administrative Data"

Do do so, you will need confidential data from the Sample of Integrated Labour Market Biographies (SIAB) and the Statushistorik Zuwanderung (SHZ), both provided by the Institute for Employment Research (IAB).
As well as complemented survey data from the IAB-BAMF-SOEP Survey of Refugees from the German Socio-Economic Panel (SOEP). 
*******************************************************************************/

                            *************
							* MASTER FILE
							*************
*clear all
							  

		  
							  
*****************************
******* SET GLOBALS *********
*****************************

*** Create folders
adopath +  "//iab.baintern.de/"  // set paths!
adopath ++ "N:\...\Fluechtlingsstichprobe\..." // set paths!
adopath ++ "N:\...\STATA/bocode" // set paths!
sysdir set SITE "N:/.../STATA/bocode" // set paths!


adopath ++ "N:/.../STATA/bocode"
sysdir set SITE "N:\...\bocode"  
mata: mata mlib index


global root "N:\..." // set paths!


capture mkdir "$root/output"
capture mkdir "$root/output/robustness"
capture mkdir "$root/output/summary"
capture mkdir "$root/file"
capture mkdir "$root/log"
capture mkdir "$root/graph"


global data "$root/Daten"
global output "$root/output"
global file "$root/file"
global log "$root/log"
global robustness "$root/output/robustness"
global graph "$root/graph"

capture program drop rddisttestk
do "$root/Prog/rddisttestk.ado"

****************************************************************************************
**** Generate global***** Generate global***** Generate global***** Generate global*****
****************************************************************************************

global outcome_educ haupt_cer mittler_cer ausbildung 
global outcome_labor employed employed_full employed_part
global outcome_jobqual entgelt year_days_emp year_days_benefits 
global control male birth_m ///
	age country1 country2 country3 ///
	country4 country5 country6 country7 country8 ///
	state1 state2 state3 state4 state5 state6 state7 state8 state9 ///
	state10 state11 state12 state13 state14 state15 state16 ///
	year2_1 year2_2 year2_3 year2_4 year2_5 year2_6 year2_7 

global outcome_labor_5 employed_5 employed_full_5 employed_part_5
global outcome_labor_8 employed_8 employed_full_8 employed_part_8

global outcome_jobqual_5 entgelt_5 year_days_emp_5 year_days_benefits_5
global outcome_jobqual_8 entgelt_8 year_days_emp_8 year_days_benefits_8


**********************************************
***** DATA ANALYSIS
**********************************************

*do "$root/Prog/0_cleaning_iab" // Clean IAB Data
*do "$root/Prog/0_cleaning_shz" // Clean SHZ Data
do "$root/Prog/1_merging" // Merge Data Sets
do "$root/Prog/2_desstat" // Figures And Tables
do "$root/Prog/3_analysis" // Figures And Tables 
do "$root/Prog/4_robustness" // Robustness Analyses





