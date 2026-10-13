************************************************
*    load basic panel
*	 Important: We use birth_UrbanPopulationMZ1995 as Dummy Urban
************************************************
use "$results\0_basicpanel_UrbanRural.dta", clear
keep if yob>=1944 & yob<=1986

sort ID_t date

*** First: Rename UrbanDummy (Too Long)
rename birth_UrbanPopulationMZ1995 birth_Urban
rename interw_UrbanPopulationMZ1995 interw_Urban
rename resid_UrbanPopulationMZ1995 resid_Urban
rename sch_UrbanPopulationMZ1995 sch_Urban
rename ausbild_UrbanPopulationMZ1995 ausbild_Urban
rename emp_UrbanPopulationMZ1995 emp_Urban

cap drop bl_birth2 
bysort ID_t: gen bl_birth2=bl_birth if _n==1

cap drop kr_birth2 
bysort ID_t: gen kr_birth2=kr_birth if _n==1

cap drop birth_Urban2 
bysort ID_t: gen birth_Urban2 = birth_Urban if _n==1

cap drop mun_birth2 
bysort ID_t: gen mun_birth2 = birth_ags_anonym if _n==1


************************************************
*    Aggregate at age level // New in 2024/05/14
************************************************
*S* For Bula
sort ID_t age date
foreach var of varlist bl_interw bl_resid bl_sch bl_ausbild bl_emp bl_samp kr_interw kr_resid kr_sch kr_ausbild kr_emp birth_Urban interw_Urban resid_Urban sch_Urban ausbild_Urban emp_Urban birth_ags_anonym interw_ags_anonym resid_ags_anonym sch_ags_anonym ausbild_ags_anonym emp_ags_anonym {
	
	gen bulaexists=(`var'!=.)
	
by ID_t age: egen minbulaex=min(date) if bulaexists==1	
by ID_t age: gen firstbula=`var' if minbulaex==date
by ID_t age: egen f_`var'=max(firstbula) 

drop bulaexists minbulaex firstbula
}

foreach var of varlist kr_interw kr_resid kr_sch kr_ausbild kr_emp {
	gen kreisexists=(`var'!=.)
	
by ID_t age: egen minkreisex=min(date) if kreisexists ==1	
by ID_t age: gen firstkreis=`var' if minkreisex==date
by ID_t age: egen f_`var'_2 = max(firstkreis) 

drop kreisexists minkreisex firstkreis
}

foreach var of varlist interw_ags_anonym resid_ags_anonym sch_ags_anonym ausbild_ags_anonym emp_ags_anonym {
	gen munexists=(`var'!=.)
	
by ID_t age: egen minmunex = min(date) if munexists ==1	
by ID_t age: gen firstmun = `var' if minmunex == date
by ID_t age: egen f_`var'_2 = max(firstmun) 

drop munexists minmunex firstmun
}

foreach var of varlist interw_Urban resid_Urban sch_Urban ausbild_Urban emp_Urban {
	gen Urbanexists=(`var'!=.)
	
by ID_t age: egen minUrbanex = min(date) if Urbanexists ==1	
by ID_t age: gen firstUrban=`var' if minUrbanex == date
by ID_t age: egen f_`var'_2 = max(firstUrban) 

drop Urbanexists minUrbanex firstUrban
}

************************************************
*    Define state of residence
************************************************
egen bula_preint = rowfirst(bl_birth2 f_bl_interw f_bl_resid f_bl_sch f_bl_ausbild f_bl_emp) if (date < idate1) 	// bula before first interview
bysort ID_t: replace bula_preint = bula_preint[_n-1] if missing(bula_preint) & (date < idate1) 			// fill in missings before interview

gen bula_int = f_bl_interw if date >= idate1  					// bula at interview 
replace bula_int = f_bl_samp if bula_int == . & date == idate1 	// not all individuals contain information about bundesland at first interview -> replace with bl_samp

cap drop bula
clonevar bula = bula_preint
replace bula = bula_int if bula == . 
bysort ID_t: replace bula = bula[_n-1] if missing(bula) & (date > idate1) 	// fill in spells after first interview
replace bula=99 if date> idate99 											// all spells occuring after last interview

drop bula_preint bula_int 
label var bula "bula of residence"

************************************************
*  *S*  Define Kreis of residence
************************************************
cap drop kr_preint
egen kr_preint = rowfirst (kr_birth2 f_kr_interw_2 f_kr_resid_2 f_kr_sch_2 f_kr_ausbild_2 f_kr_emp_2) if (date <= idate1) 	// Here: New! 2024 / 06 / 07 // De- Comment This For "basicalpanel_new_2.dta"
bysort ID_t: replace kr_preint = kr_preint[_n-1] if missing(kr_preint) & (date < idate1) 			// fill in missings before interview; some missings remain as we do not observe people from beginning of life


gen kr_int = f_kr_interw if date >= idate1  					// kreis at interview *S* Achtung: Fehlt per default im NEPS
replace kr_int = f_kr_resid if kr_int == . & date == idate1 	// not all individuals contain information about kreis at first interview -> fill in with other information
replace kr_int = f_kr_ausbild if kr_int == . & date == idate1 	
replace kr_int = f_kr_emp if kr_int == . & date == idate1 	


cap drop kreis
clonevar kreis = kr_preint
replace kreis = kr_int if kreis == . 
bysort ID_t: replace kreis = kreis[_n-1] if missing(kreis) // & (date > idate1)
*we do not observe the Kreis for first interview -> we just fill this information vertically from the last information prior to first interview (slightly different to Bundesland; but only for 9 individuals)	
replace kreis=99 if date> idate99 											// all spells occuring after last interview

drop kr_int //kreis_preint
label var kreis "kreis/district of residence"


************************************************
*  *S*  Define Municipality of residence
************************************************
cap drop mun_preint
egen mun_preint = rowfirst (mun_birth2 f_interw_ags_anonym_2 f_resid_ags_anonym_2 f_sch_ags_anonym_2 f_ausbild_ags_anonym_2 f_emp_ags_anonym_2) if (date <= idate1) 	// Here: New! 2024 / 06 / 07 // De- Comment This For "basicalpanel_new_2.dta"
bysort ID_t: replace mun_preint = mun_preint[_n-1] if missing(mun_preint) & (date < idate1) 			// fill in missings before interview; some missings remain as we do not observe people from beginning of life


gen mun_int = f_interw_ags_anonym if date >= idate1  					// kreis at interview *S* Achtung: Fehlt per default im NEPS
replace mun_int = f_resid_ags_anonym_2 if mun_int == . & date == idate1 	// not all individuals contain information about kreis at first interview -> fill in with other information
replace mun_int = f_ausbild_ags_anonym_2 if mun_int == . & date == idate1 	
replace mun_int = f_emp_ags_anonym_2 if mun_int == . & date == idate1 	


cap drop mun
clonevar mun = mun_preint
replace mun = mun_int if mun == . 
bysort ID_t: replace mun = mun[_n-1] if missing(mun) // & (date > idate1)
*we do not observe the Kreis for first interview -> we just fill this information vertically from the last information prior to first interview (slightly different to Bundesland; but only for 9 individuals)	
replace mun=99 if date> idate99 											// all spells occuring after last interview

drop mun_int //kreis_preint
label var mun "municipality of residence at t"


************************************************
*  *S*  Define Urban of residence
************************************************
cap drop Urban_preint
egen Urban_preint = rowfirst (birth_Urban2 f_interw_Urban_2 f_resid_Urban_2 f_sch_Urban_2 f_ausbild_Urban_2 f_emp_Urban_2) if (date <= idate1) 	// Here: New! 2024 / 06 / 07 // De- Comment This For "basicalpanel_new_2.dta"
bysort ID_t: replace Urban_preint = Urban_preint[_n-1] if missing(Urban_preint) & (date < idate1) 			// fill in missings before interview; some missings remain as we do not observe people from beginning of life


gen Urban_int = f_interw_Urban if date >= idate1  					// kreis at interview *S* Achtung: Fehlt per default im NEPS
replace Urban_int = f_resid_Urban if Urban_int == . & date == idate1 	// not all individuals contain information about kreis at first interview -> fill in with other information
replace Urban_int = f_ausbild_Urban if Urban_int == . & date == idate1 	
replace Urban_int = f_emp_Urban if Urban_int == . & date == idate1 	


cap drop Urban
clonevar Urban = Urban_preint
replace Urban = Urban_int if Urban == . 
bysort ID_t: replace Urban = Urban[_n-1] if missing(Urban) // & (date > idate1)
*we do not observe the Kreis for first interview -> we just fill this information vertically from the last information prior to first interview (slightly different to Bundesland; but only for 9 individuals)	
replace Urban=99 if date> idate99 											// all spells occuring after last interview

drop Urban_int //kreis_preint
label var Urban "Urban-Dummy of residence at t"

*** Problems: 

count if missing(mun) // 7,188
count if missing(Urban) // 7,188
count if missing(kreis) //  5,676
count if missing(bula) // 0


************************************************
*    Define mobility measures
************************************************
************************************************
* Define mobility measures for Kreis
************************************************
*stock
cap drop mig_stock_kr
gen mig_stock_kr =kreis!=kr_birth if kreis!=.
replace mig_stock_kr =99 if kreis==99
label var mig_stock_kr "lifetime mobility (vs. kreis/district of birth)"

*flow
cap drop mig_flow1_kr
bysort ID_t: gen kreis_pre12 = kreis[_n-12] if date <= idate99  	// information on kreis 12 months before
gen mig_flow1_kr = kreis!=kreis_pre12 if kreis_pre12 != .
bysort ID_t: replace mig_flow1_kr = 99 if age == 0 					// not measurable for children within first year of their life
bysort ID_t: replace mig_flow1_kr = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_kr "1-mobility (vs. 12 months prior) for kreis/district"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on kreis 12 months before
cap drop mig_flow5_kr
bysort ID_t: gen kreis_pre60 = kreis[_n-60] if date <= idate99
gen mig_flow5_kr = kreis!=kreis_pre60 if kreis_pre60 != .
bysort ID_t: replace mig_flow5_kr = 99 if age < 5 					// not measurable for children ithin first year of their life
bysort ID_t: replace mig_flow5_kr = 99 if date > idate99			 // no info after last interview 
label var mig_flow5_kr "5-year mobility (vs. 60 months prior) for kreis/district"

* number of moves 
bysort ID_t: gen mig_number_kr_ = kreis != kreis[_n-1] 
bysort ID_t: replace mig_number_kr_ = . if date > idate99 
bysort ID_t: replace mig_number_kr_ = 0 if _n==1
bysort ID_t age: egen mig_number_kr_age = total(mig_number_kr_)
bysort ID_t age: replace mig_number_kr_age = . if date > idate99 
bysort ID_t: egen mig_number_kr_2555 = total(mig_number_kr_) if inrange(age,25,55)
label var mig_number_kr_2555
sort ID_t date

label var mig_number_kr_ "=1, if kreis different to kreis in t-1"
label var mig_number_kr_age "number of cross-county moves per year"
label var mig_number_kr_2555 "number of cross-county moves in age range 25-55"

drop kreis_pre12 kreis_pre60

*label variables and define dummies
*S* lab def mig_def 0 "0: no mig" 1 "1: mig" 99 "99: no valid info" 

foreach var of varlist mig_stock_kr mig_flow1_kr mig_flow5_kr {
	label value `var' mig_def
	qui tab `var', gen(`var') mis
}	


************************************************
*  Define mobility measures for Municipality
* -> Should hopefully be different from kreis 
************************************************
*stock
cap drop mig_stock_mun
bysort ID_t: gen mig_stock_mun =mun!= birth_ags_anonym if date <= idate99
bysort ID_t: replace mig_stock_mun = 99 if date > idate99			 // no info after last interview 
label var mig_stock_mun "lifetime mobility (vs. municipality of birth)"

*flow
cap drop mig_flow1_mun
bysort ID_t: gen mun_pre12 = mun[_n-12] if date <= idate99  	// information on mun 12 months before
bysort ID_t: gen mig_flow1_mun = mun!=mun_pre12 if mun_pre12 != .
bysort ID_t: replace mig_flow1_mun = 99 if age == 0 					// not measurable for children within first year of their life
bysort ID_t: replace mig_flow1_mun = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_mun "1-mobility (vs. 12 months prior) for municipality"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on mun 12 months before
cap drop mig_flow5_mun
bysort ID_t: gen mun_pre60 = mun[_n-60] if date <= idate99
bysort ID_t: gen mig_flow5_mun = mun!=mun_pre60 if mun_pre60 != .
bysort ID_t: replace mig_flow5_mun = 99 if age < 5 					// not measurable for children ithin first year of their life
bysort ID_t: replace mig_flow5_mun = 99 if date > idate99			 // no info after last interview 
label var mig_flow5_mun "5-year mobility (vs. 60 months prior) for municipality"

* number of moves 
bysort ID_t: gen mig_number_mun_ = mun != mun[_n-1] 
bysort ID_t: replace mig_number_mun_ = . if date > idate99 
bysort ID_t: replace mig_number_mun_ = 0 if _n==1
bysort ID_t age: egen mig_number_mun_age = total(mig_number_mun_)
bysort ID_t age: replace mig_number_mun_age = . if date > idate99 
bysort ID_t: egen mig_number_mun_2555 = total(mig_number_mun_) if inrange(age,25,55)
label var mig_number_mun_2555
sort ID_t date

label var mig_number_mun_ "=1, if municipality different to mun in t-1"
label var mig_number_mun_age "number of cross-municipality moves per year"
label var mig_number_mun_2555 "number of cross-municipality moves in age range 25-55"

drop mun_pre12 mun_pre60

foreach var of varlist mig_stock_mun mig_flow1_mun mig_flow5_mun {
	label value `var' mig_def
	qui tab `var', gen(`var') mis
}	

************************************************
*  Define mobility measuresfor Urban
* 	4 Dimensions: Rural -> Rural; Urban -> Urban; Urban -> Rural; Rural -> Urban
************************************************
recode Urban (0 = 1) (1 = 0), gen(Rural)
recode birth_Urban (0 = 1) (1 = 0), gen(birth_Rural)

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*** Rural -> Rural ***
 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*stock
cap drop mig_stock_RuralRural
gen mig_stock_RuralRural = 0
bysort ID_t: replace mig_stock_RuralRural = 1 if (Rural == 1 & birth_Rural == 1) & mig_stock_mun == 1 // HIER NOCHMAL SCHAUEN! MACHT DAS SINN? --> Kommentar Anton: ich habe das korrigiert und nun sollte es Sinn machen
bysort ID_t: replace mig_stock_RuralRural = 99 if mig_stock_mun == 99
label var mig_stock_RuralRural "lifetime mobility (vs. Rural at Birth)"

*flow
cap drop mig_flow1_RuralRural
gen mig_flow1_RuralRural = 0
bysort ID_t: replace mig_flow1_RuralRural = 1 if (Rural == 1 & Rural[_n-12] == 1) & mig_flow1_mun == 1
bysort ID_t: replace mig_flow1_RuralRural = 0 if age < 1
bysort ID_t: replace mig_flow1_RuralRural = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_RuralRural "1-mobility (vs. 12 months prior) for Rural to Rural"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on kreis 12 months before
cap drop mig_flow5_RuralRural
gen mig_flow5_RuralRural = 0
bysort ID_t: replace mig_flow5_RuralRural = 1 if (Rural == 1 & Rural[_n-60] == 1) & mig_flow5_mun == 1
bysort ID_t: replace mig_flow5_RuralRural = 0 if age < 5
bysort ID_t: replace mig_flow5_RuralRural = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_RuralRural "1-mobility (vs. 12 months prior) for Rural to Rural"

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*** Urban -> Urban ***
 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*stock
cap drop mig_stock_UrbanUrban
gen mig_stock_UrbanUrban = 0
bysort ID_t: replace mig_stock_UrbanUrban = 1 if (Rural == 0 & birth_Rural == 0) & mig_stock_mun == 1 // HIER NOCHMAL SCHAUEN! MACHT DAS SINN? --> Kommentar Anton: ich habe das korrigiert und nun sollte es Sinn machen
bysort ID_t: replace mig_stock_UrbanUrban = 99 if mig_stock_mun == 99
label var mig_stock_UrbanUrban "lifetime mobility (vs. Urban at Birth)"

*flow
cap drop mig_flow1_UrbanUrban
gen mig_flow1_UrbanUrban = 0
bysort ID_t: replace mig_flow1_UrbanUrban = 1 if (Rural == 0 & Rural[_n-12] == 0) & mig_flow1_mun == 1
bysort ID_t: replace mig_flow1_UrbanUrban = 0 if age < 1
bysort ID_t: replace mig_flow1_UrbanUrban = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_UrbanUrban "1-mobility (vs. 12 months prior) for Urban to Urban"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on kreis 12 months before
cap drop mig_flow5_UrbanUrban
gen mig_flow5_UrbanUrban = 0
bysort ID_t: replace mig_flow5_UrbanUrban = 1 if (Rural == 0 & Rural[_n-60] == 0) & mig_flow5_mun == 1
bysort ID_t: replace mig_flow5_UrbanUrban = 0 if age < 5
bysort ID_t: replace mig_flow5_UrbanUrban = 99 if date > idate99			 // no info after last interview 
label var mig_flow5_UrbanUrban "5-year mobility (vs. 60 months prior) for Urban to Urban"


 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*** Rural -> Urban ***
*** Means: We "started" as Rural and are now Urban
 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
 *stock
cap drop mig_stock_RuralUrban
gen mig_stock_RuralUrban = 0
bysort ID_t: replace mig_stock_RuralUrban = 1 if (Rural == 0 & birth_Rural == 1) & mig_stock_mun == 1 // HIER NOCHMAL SCHAUEN! MACHT DAS SINN? --> Kommentar Anton: ich habe das korrigiert und nun sollte es Sinn machen
bysort ID_t: replace mig_stock_RuralUrban = 99 if mig_stock_mun == 99
label var mig_stock_RuralUrban "lifetime mobility (vs. Rural at Birth)" 
 
*flow
cap drop mig_flow1_RuralUrban
gen mig_flow1_RuralUrban = 0
bysort ID_t: replace mig_flow1_RuralUrban = 1 if (Rural == 0 & Rural[_n-12] == 1) & mig_flow1_mun == 1
bysort ID_t: replace mig_flow1_RuralUrban = 0 if age < 1
bysort ID_t: replace mig_flow1_RuralUrban = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_RuralUrban "1-mobility (vs. 12 months prior) for Rural to Urban"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on kreis 12 months before
cap drop mig_flow5_RuralUrban
gen mig_flow5_RuralUrban = 0
bysort ID_t: replace mig_flow5_RuralUrban = 1 if (Rural == 0 & Rural[_n-60] == 1) & mig_flow5_mun == 1
bysort ID_t: replace mig_flow5_RuralUrban = 0 if age < 5
bysort ID_t: replace mig_flow5_RuralUrban = 99 if date > idate99			 // no info after last interview 
label var mig_flow5_RuralUrban "5-year mobility (vs. 60 months prior) for Rural to Urban"
 
  *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*** Urban -> Rural ***
*** Means: We "started" as Urban and are now Rural
 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
*stock
cap drop mig_stock_UrbanRural
gen mig_stock_UrbanRural = 0
bysort ID_t: replace mig_stock_UrbanRural = 1 if (Rural == 1 & birth_Rural == 0) & mig_stock_mun == 1 // HIER NOCHMAL SCHAUEN! MACHT DAS SINN? --> Kommentar Anton: ich habe das korrigiert und nun sollte es Sinn machen
bysort ID_t: replace mig_stock_UrbanRural = 99 if mig_stock_mun == 99
label var mig_stock_UrbanRural "lifetime mobility (vs. Urban at Birth)" 
 
*flow
cap drop mig_flow1_UrbanRural
gen mig_flow1_UrbanRural = 0
bysort ID_t: replace mig_flow1_UrbanRural = 1 if (Rural == 1 & Rural[_n-12] == 0) & mig_flow1_mun == 1
bysort ID_t: replace mig_flow1_UrbanRural = 0 if age < 1
bysort ID_t: replace mig_flow1_UrbanRural = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_UrbanRural "1-mobility (vs. 12 months prior) for Urban to Rural"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on kreis 12 months before
cap drop mig_flow5_UrbanRural
gen mig_flow5_UrbanRural = 0
bysort ID_t: replace mig_flow5_UrbanRural = 1 if (Rural == 1 & Rural[_n-60] == 0) & mig_flow5_mun == 1
bysort ID_t: replace mig_flow5_UrbanRural = 0 if age < 5
bysort ID_t: replace mig_flow5_UrbanRural = 99 if date > idate99			 // no info after last interview 
label var mig_flow5_UrbanRural "5-year mobility (vs. 60 months prior) for Urban to Rural"

cap drop UrbanRural_pre12 UrbanRural_pre60
cap drop *_kr *_kr* kr_* *_kr_* 

*** Important Infos ***
foreach var of varlist mig_stock_mun mig_stock_RuralRural mig_stock_UrbanUrban mig_stock_RuralUrban mig_stock_UrbanRural mig_flow1_mun mig_flow1_RuralRural mig_flow1_UrbanUrban mig_flow1_RuralUrban mig_flow1_UrbanRural mig_flow5_mun mig_flow5_RuralRural mig_flow5_UrbanUrban mig_flow5_RuralUrban mig_flow5_UrbanRural {
	label value `var' mig_def
	*qui tab `var', gen(`var') mis
}	


************************Create outcomes on a person-age-level*******************

*** *** migstock *** ***
*** Rural -> Rural ***
sort ID_t date
bysort ID_t age: egen migstock_RuralRural =mean(mig_stock_RuralRural) 

*** Rural -> Urban ***
sort ID_t date
bysort ID_t age: egen migstock_RuralUrban =mean(mig_stock_RuralUrban) 

*** Urban -> Urban ***
sort ID_t date
bysort ID_t age: egen migstock_UrbanUrban =mean(mig_stock_UrbanUrban) 

*** Urban -> Rural ***
sort ID_t date
bysort ID_t age: egen migstock_UrbanRural =mean(mig_stock_UrbanRural) 

* Municipality 
sort ID_t date
bysort ID_t age: egen migstock_mun =mean(mig_stock_mun)
bysort ID_t age: egen migstock_mun_max =max(mig_stock_mun)

*** *** migflow1 *** ***
*** Rural -> Rural ***
sort ID_t date
bysort ID_t age: egen migflow1_RuralRural =mean(mig_flow1_RuralRural) 

*** Rural -> Urban ***
sort ID_t date
bysort ID_t age: egen migflow1_RuralUrban =mean(mig_flow1_RuralUrban) 

*** Urban -> Urban ***
sort ID_t date
bysort ID_t age: egen migflow1_UrbanUrban =mean(mig_flow1_UrbanUrban) 

*** Urban -> Rural ***
sort ID_t date
bysort ID_t age: egen migflow1_UrbanRural =mean(mig_flow1_UrbanRural) 

* Municipality 
sort ID_t date
bysort ID_t age: egen migflow1_mun =mean(mig_flow1_mun)
bysort ID_t age: egen migflow1_mun_max =max(mig_flow1_mun)

*** *** migflow5 *** ***
*** Rural -> Rural ***
sort ID_t date
bysort ID_t age: egen migflow5_RuralRural =mean(mig_flow5_RuralRural) 

*** Rural -> Urban ***
sort ID_t date
bysort ID_t age: egen migflow5_RuralUrban =mean(mig_flow5_RuralUrban) 

*** Urban -> Urban ***
sort ID_t date
bysort ID_t age: egen migflow5_UrbanUrban =mean(mig_flow5_UrbanUrban) 

*** Urban -> Rural ***
sort ID_t date
bysort ID_t age: egen migflow5_UrbanRural =mean(mig_flow5_UrbanRural) 

* Municipality 
sort ID_t date
bysort ID_t age: egen migflow5_mun =mean(mig_flow5_mun)
bysort ID_t age: egen migflow5_mun_max =max(mig_flow5_mun)


*** Now: Keep only relevant variables 
keep mig_stock* mig_flow1* mig_flow5* migstock_mun migflow1_mun migflow5_mun ID_t yob mob bdate date age
compress

*** Save For Merge ***
*** This one includes 99 and is not collapsed
save "$results\0_Panel_Migration_Urban_Rural_Municipality_Merge_raw.dta", replace

use "$results\0_Panel_Migration_Urban_Rural_Municipality_Merge_raw.dta", clear

* Now: Clean 99 and Collapse to merge via ID_t age
foreach var in ///
mig_stock_mun mig_stock_RuralRural mig_stock_UrbanUrban mig_stock_RuralUrban mig_stock_UrbanRural ///
mig_flow1_mun mig_flow1_RuralRural mig_flow1_UrbanUrban mig_flow1_RuralUrban mig_flow1_UrbanRural ///
mig_flow5_mun mig_flow5_RuralRural mig_flow5_UrbanUrban mig_flow5_RuralUrban mig_flow5_UrbanRural {
	sum `var'
	recode `var' (99 = .)
	sum `var'
}

collapse (mean) yob mob date bdate ///
mig_stock_mun mig_stock_RuralRural mig_stock_UrbanUrban mig_stock_RuralUrban mig_stock_UrbanRural ///
mig_flow1_mun mig_flow1_RuralRural mig_flow1_UrbanUrban mig_flow1_RuralUrban mig_flow1_UrbanRural ///
mig_flow5_mun mig_flow5_RuralRural mig_flow5_UrbanUrban mig_flow5_RuralUrban mig_flow5_UrbanRural ///
,by(ID_t age)

* Finally, I have to rename variables, otherwise they get too long for est-out ...
rename (mig_stock_RuralRural mig_stock_UrbanUrban mig_stock_RuralUrban mig_stock_UrbanRural) (mig_stock_RR mig_stock_UU mig_stock_RU mig_stock_UR)
rename (mig_flow1_RuralRural mig_flow1_UrbanUrban mig_flow1_RuralUrban mig_flow1_UrbanRural) (mig_flow1_RR mig_flow1_UU mig_flow1_RU mig_flow1_UR)
rename (mig_flow5_RuralRural mig_flow5_UrbanUrban mig_flow5_RuralUrban mig_flow5_UrbanRural) (mig_flow5_RR mig_flow5_UU mig_flow5_RU mig_flow5_UR)


*** Save For Merge ***
save "$results\0_Panel_Migration_Urban_Rural_Municipality_Merge.dta", replace
