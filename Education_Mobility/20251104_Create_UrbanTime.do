* This file will prepare all files from the FDZ so we can acutally merge them while we are creating our master-panel
* Meaning: We create variable amd remove balast
* Author: Sebastian Vogler
* Date: 2025 / 11 / 04

* Globals // Done in master-file
* global MergeUrbanFDZ "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Merge Tobias"

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
* Merge with data from the FDZ (They had to manually enrich the data about Urban/Rural bc of Data-Protection)
* SC6_pTarget_t700101_PanelUrbanLatLong_remote.dta
use "$MergeUrbanFDZ\SC6_pTarget_t700101_PanelUrbanLatLong_remote.dta", clear
drop LabourNum2021 Metropol2021

foreach var in ags_anonym DummyUrban2021 UrbanPopulation CatSizeMZ CatSizeMZ1995 UrbanPopulationMZ UrbanPopulationMZ1995 UrbanBBSR {
	clonevar birth_`var' = `var'
	drop `var'
}

sort ID_t wave
compress
save "$MergeUrbanFDZ\SC6_pTarget_t700101_PanelUrbanLatLong_merge.dta", replace



 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
* SC6_pTarget_t751001_PanelUrbanLatLong_remote.dta
use "$MergeUrbanFDZ\SC6_pTarget_t751001_PanelUrbanLatLong_remote.dta", clear
drop LabourNum2021 Metropol2021

foreach var in ags_anonym DummyUrban2021 UrbanPopulation CatSizeMZ CatSizeMZ1995 UrbanPopulationMZ UrbanPopulationMZ1995 UrbanBBSR {
	clonevar interw_`var' = `var'
	drop `var'
}

sort ID_t wave
compress
save "$MergeUrbanFDZ\SC6_pTarget_t751001_PanelUrbanLatLong_merge.dta", replace



 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
* SC6_spResidence_th21111_PanelUrbanLatLong_remote.dta
use "$MergeUrbanFDZ\SC6_spResidence_th21111_PanelUrbanLatLong_remote.dta", clear

foreach var in ags_anonym DummyUrban2021 UrbanPopulation CatSizeMZ CatSizeMZ1995 UrbanPopulationMZ UrbanPopulationMZ1995 UrbanBBSR {
	clonevar resid_`var' = `var'
	drop `var'
}

sort ID_t spell subspell 
compress
save "$MergeUrbanFDZ\SC6_spResidence_th21111_PanelUrbanLatLong_merge.dta", replace



 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
* SC6_spSchool_ts11202_PanelUrbanLatLong_remote.dta
use "$MergeUrbanFDZ\SC6_spSchool_ts11202_PanelUrbanLatLong_remote.dta", clear

foreach var in ags_anonym DummyUrban2021 UrbanPopulation CatSizeMZ CatSizeMZ1995 UrbanPopulationMZ UrbanPopulationMZ1995 UrbanBBSR {
	clonevar sch_`var' = `var'
	drop `var'
}

sort ID_t spell subspell 
compress
save "$MergeUrbanFDZ\SC6_spSchool_ts11202_PanelUrbanLatLong_merge.dta", replace



*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
* SC6_spVocTrain_ts15207_PanelUrbanLatLong_remote.dta
use "$MergeUrbanFDZ\SC6_spVocTrain_ts15207_PanelUrbanLatLong_remote.dta", clear

foreach var in ags_anonym DummyUrban2021 UrbanPopulation CatSizeMZ CatSizeMZ1995 UrbanPopulationMZ UrbanPopulationMZ1995 UrbanBBSR {
	clonevar ausbild_`var' = `var'
	drop `var'
}

sort ID_t spell subspell 
compress
save "$MergeUrbanFDZ\SC6_spVocTrain_ts15207_PanelUrbanLatLong_merge.dta", replace



 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
* SC6_spEmp_ts23237_PanelUrbanLatLong_remote
use "$MergeUrbanFDZ\SC6_spEmp_ts23237_PanelUrbanLatLong_remote.dta", clear

foreach var in ags_anonym DummyUrban2021 UrbanPopulation CatSizeMZ CatSizeMZ1995 UrbanPopulationMZ UrbanPopulationMZ1995 UrbanBBSR {
	clonevar emp_`var' = `var'
	drop `var'
}

sort ID_t spell subspell
compress
save "$MergeUrbanFDZ\SC6_spEmp_ts23237_PanelUrbanLatLong_merge.dta", replace











 
