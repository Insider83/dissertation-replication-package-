/**************************************************
    Clean up the panel over the life cycle &
	define measures of mobility
	
	Author: K. Cygan-Rehm + A. Barabasch + S. Vogler
	
	Version: 1.0, Created: 2022-04-11	
	Version: 2.0, Created: 2023-03-01
	updated Kreise: 2023 - 03 - 27
***************************************************/

************************************************
*    load basic panel
************************************************
use "$results\0_basicpanel.dta", clear
keep if yob>=1944 & yob<=1986
drop if casmin==-55 // 7 individuals

sort ID_t date

bysort ID_t: gen bl_birth2=bl_birth if _n==1

*S*
bysort ID_t: gen kr_birth2=kr_birth if _n==1

************************************************
*    Define state of residence
************************************************
egen bula_preint = rowfirst (bl_birth2 bl_interw bl_resid bl_sch bl_ausbild bl_emp) if (date < idate1) 	// bula before first interview
bysort ID_t: replace bula_preint = bula_preint[_n-1] if missing(bula_preint) & (date < idate1) 			// fill in missings before interview

gen bula_int = bl_interw if date >= idate1  					// bula at interview 
replace bula_int = bl_samp if bula_int == . & date == idate1 	// not all individuals contain information about bundesland at first interview -> replace with bl_samp

clonevar bula = bula_preint
replace bula = bula_int if bula == . 
bysort ID_t: replace bula = bula[_n-1] if missing(bula) & (date > idate1) 	// fill in spells after first interview
replace bula=99 if date> idate99 											// all spells occuring after last interview

drop bula_preint bula_int 

label var bula "bula of residence"

************************************************
*  *S*  Define state of residence for Kreis
************************************************
*S* (date < idate1) zu (date <= idate1) geändert
egen kr_preint = rowfirst (kr_birth2 kr_interw kr_resid kr_sch kr_ausbild kr_emp) if (date <= idate1) 	// kreis before first interview
bysort ID_t: replace kr_preint = kr_preint[_n-1] if missing(kr_preint) & (date < idate1) 			// fill in missings before interview; some missings remain as we do not observe people from beginning of life


gen kr_int = kr_interw if date >= idate1  					// kreis at interview *S* Achtung: Fehlt per default im NEPS
replace kr_int = kr_resid if kr_int == . & date == idate1 	// not all individuals contain information about kreis at first interview -> fill in with other information
replace kr_int = kr_ausbild if kr_int == . & date == idate1 	
replace kr_int = kr_emp if kr_int == . & date == idate1 	



clonevar kreis = kr_preint
replace kreis = kr_int if kreis == . 
bysort ID_t: replace kreis = kreis[_n-1] if missing(kreis) // & (date > idate1)
*we do not observe the Kreis for first interview -> we just fill this information vertically from the last information prior to first interview (slightly different to Bundesland; but only for 9 individuals)	
replace kreis=99 if date> idate99 											// all spells occuring after last interview

drop kr_int //kreis_preint

label var kreis "kreis/district of residence"

************************************************
*    Check consistency of kreis and bula
************************************************
*** Extract first number:
gen first_digit_kr = real(substr(string(kreis, "%9.0g"), 1, 1))
gen first_digit_bula = real(substr(string(bula, "%9.0g"), 1, 1))
*gen first_digit_kr = int(kreis/10000)
*gen first_digit_bula = int(bula/100)
gen error_kr = 0
gen error_kr2 = 0
replace error_kr = 1 if first_digit_bula != first_digit_kr
replace error_kr2 = 1 if first_digit_bula != first_digit_kr & kreis != .

distinct ID_t if error_kr == 1 
distinct ID_t if error_kr2 == 1 

tab ID_t if error_kr == 1
tab ID_t if error_kr2 == 1

drop error_kr error_kr2 first_digit_bula first_digit_kr


************************************************
*    Define mobility measures
************************************************
*stock
gen mig_stock=bula!=bl_birth if bula!=.
replace mig_stock=99 if bula==99
label var mig_stock "lifetime mobility (vs. state of birth)"

*flow
bysort ID_t: gen bula_pre12 = bula[_n-12] if date <= idate99  	// information on bula 12 months before
gen mig_flow1 = bula!=bula_pre12 if bula_pre12 != .
bysort ID_t: replace mig_flow1 = 99 if age == 0 					// not measurable for children within first year of their life
bysort ID_t: replace mig_flow1 = 99 if date > idate99			 // no info after last interview 
label var mig_flow1 "1-year mobility (vs. 12 months prior)"

bysort ID_t: gen bula_pre60 = bula[_n-60] if date <= idate99
gen mig_flow5 = bula!=bula_pre60 if bula_pre60 != .
bysort ID_t: replace mig_flow5 = 99 if age < 5 					// not measurable for children within first year of their life
bysort ID_t: replace mig_flow5 = 99 if date > idate99			 // no info after last interview 
label var mig_flow5 "5-year mobility (vs. 60 months prior)"

drop bula_pre12 bula_pre60

*label variables and define dummies
lab def mig_def 0 "0: no mig" 1 "1: mig" 99 "99: no valid info" 

foreach var of varlist mig_stock mig_flow1 mig_flow5 {
	label value `var' mig_def
	qui tab `var', gen(`var') mis
}	

************************************************
*  *S*  Define mobility measures for Kreis
* -> Should hopefully be different from Bula
************************************************
*stock
gen mig_stock_kr =kreis!=kr_birth if kreis!=.
replace mig_stock_kr =99 if kreis==99
label var mig_stock_kr "lifetime mobility (vs. kreis/district of birth)"

*flow
bysort ID_t: gen kreis_pre12 = kreis[_n-12] if date <= idate99  	
gen mig_flow1_kr = kreis!=kreis_pre12 if kreis_pre12 != .
bysort ID_t: replace mig_flow1_kr = 99 if age == 0 					
bysort ID_t: replace mig_flow1_kr = 99 if date > idate99			
label var mig_flow1_kr "1-mobility (vs. 12 months prior) for kreis/district"

bysort ID_t: gen kreis_pre60 = kreis[_n-60] if date <= idate99
gen mig_flow5_kr = kreis!=kreis_pre60 if kreis_pre60 != .
bysort ID_t: replace mig_flow5_kr = 99 if age < 5 					
bysort ID_t: replace mig_flow5_kr = 99 if date > idate99			 
label var mig_flow5_kr "5-year mobility (vs. 60 months prior) for kreis/district"


drop kreis_pre12 kreis_pre60

foreach var of varlist mig_stock_kr mig_flow1_kr mig_flow5_kr {
	label value `var' mig_def
	qui tab `var', gen(`var') mis
}	


************************************************
*    Merge weights
************************************************
merge m:1 ID_t using "$results\temp_weights.dta"
drop if _merge == 2
drop _merge

************************************************
*    Generate background variables
************************************************
*recode educational attainment
recode casmin (0 1 2=1) (3 4=2) (5 6=3) (7 8=4) (else=.), gen(educ)
qui tab educ, gen(educ) 
lab def educ 1 "1: Haupt." 2 "2: Real." 3 "3: Fach(abi)" 4 "4: FH/Uni"  
lab val educ educ

*group birth cohorts
recode yob (1944/1949=1940) (1950/1959=1950) (1960/1969=1960) (1970/1979=1970) (1980/1989=1980), gen(yobgr)

*parental controls
foreach var of varlist sibl m_yob f_yob m_gerborn f_gerborn m_yos f_yos fam15 {
gen `var'_mis=`var'==.
replace `var'=0 if `var'==.
}




