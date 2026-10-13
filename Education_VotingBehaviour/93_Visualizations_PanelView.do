/**************************************************
This Do-File will produce overall treatment time and gravity of treatment within our sample to show a better overview
	
	
	Author: Sebastian Vogler
	
	Version: 1.0, Created: 2024-11-29	
***************************************************/


* Use Final Data-Set
use "$master\Daten Schulschließung Marcel\SchoolClosureRegress.dta", clear // From "13_05_PrepareVariables.do"
sort AGS2020 Year

* Prepare: Re-Introduce Number of Treatments per Year
* All Schools
bysort AGS2020: gen ClosureYear = NumSchoolsRemain[_n-1] - NumSchoolsRemain 
bysort AGS2020: replace ClosureYear = 0 if Year == 2001
bysort AGS2020: replace ClosureYear = 0 if NumSchoolsRemain == -99

* Only Elementary Schools
bysort AGS2020: gen ClosureYear_ES = NumSchoolsRemain_ES[_n-1] - NumSchoolsRemain_ES 
bysort AGS2020: replace ClosureYear_ES = 0 if Year == 2001
bysort AGS2020: replace ClosureYear_ES = 0 if NumSchoolsRemain_ES == -99

* Only Secondary Schools
bysort AGS2020: gen ClosureYear_SS = NumSchoolsRemain_SS[_n-1] - NumSchoolsRemain_SS 
bysort AGS2020: replace ClosureYear_SS = 0 if Year == 2001
bysort AGS2020: replace ClosureYear_SS = 0 if NumSchoolsRemain_SS == -99

* Only Grammar Schools
bysort AGS2020: gen ClosureYear_GYM = NumSchoolsRemain_GYM[_n-1] - NumSchoolsRemain_GYM 
bysort AGS2020: replace ClosureYear_GYM = 0 if Year == 2001
bysort AGS2020: replace ClosureYear_GYM = 0 if NumSchoolsRemain_GYM == -99

*** Panel View
*** *** First School Closure *** ***
*** Collapse By State
*** Elementary Schools
preserve
collapse (sum) DummyFirstClosure_ES, by (State Year)
panelview DummyFirstClosure_ES, i(State) t(Year) type(treat) xtitle("") ytitle("") title("Accum. First Elementary School Closures",size(small)) ylabel(1 "State: SH" 2 "State: NI" 3 "State: NW" 4 "State: HE" 5 "State: RP" 6 "State: BW" 7 "State: BY " 8 "State: SL" 9 "State: BB" 10 "State: MV"  11 "State: SN" 12 "State: ST"  13 "State: TH" ,labsize(tiny))
graph export "$Visualization_PanelView\PanelView_ElementarySchool.pdf", as(pdf) replace // ytitle("German State")
graph save "$Visualization_PanelView\PanelView_ElementarySchool.gph", replace
restore

*** Grammar Schools
preserve
collapse (sum) DummyFirstClosure_GYM, by (State Year)
panelview DummyFirstClosure_GYM, i(State) t(Year) type(treat) xtitle("") ytitle("") mycolor(Reds) title("Accum. First Grammar School Closures",size(small)) ylabel(1 "State: SH" 2 "State: NI" 3 "State: NW" 4 "State: HE" 5 "State: RP" 6 "State: BW" 7 "State: BY " 8 "State: SL" 9 "State: BB" 10 "State: MV"  11 "State: SN" 12 "State: ST"  13 "State: TH" ,labsize(tiny)) // ytitle("German State")
graph export "$Visualization_PanelView\PanelView_GrammarSchool.pdf", as(pdf) replace
graph save "$Visualization_PanelView\PanelView_GrammarSchool.gph", replace
restore

*** Combine Graphs
preserve
cd "$Visualization_PanelView"
graph combine PanelView_ElementarySchool.gph PanelView_GrammarSchool.gph
graph export "$Visualization_PanelView\PanelView_Combined.pdf", as(pdf) replace
graph save "$Visualization_PanelView\PanelView_Combined.gph", replace
restore

*** *** Last School Closure *** ***
preserve
collapse (sum) DummyOnlyClosure_ES, by (State Year)
bysort State: gen PrevClosure_ES = DummyOnlyClosure_ES[_n-1]

bysort State: gen PrevBigger = (DummyOnlyClosure_ES[_n] < DummyOnlyClosure_ES[_n-1])
bysort State: replace PrevBigger = 0 if _n == 1
bysort State: replace DummyOnlyClosure_ES  = PrevClosure_ES if PrevBigger == 1

bysort State: gen PrevBigger2 = (DummyOnlyClosure_ES[_n] < DummyOnlyClosure_ES[_n-1])
bysort State: replace PrevBigger2 = 0 if _n == 1
bysort State: replace DummyOnlyClosure_ES  = DummyOnlyClosure_ES[_n-1] if PrevBigger2 == 1

bysort State: gen PrevBigger3 = (DummyOnlyClosure_ES[_n] < DummyOnlyClosure_ES[_n-1])
bysort State: replace PrevBigger3 = 0 if _n == 1
bysort State: replace DummyOnlyClosure_ES  = DummyOnlyClosure_ES[_n-1] if PrevBigger3 == 1

bysort State: gen PrevBigger4 = (DummyOnlyClosure_ES[_n] < DummyOnlyClosure_ES[_n-1])
bysort State: replace PrevBigger4 = 0 if _n == 1
bysort State: replace DummyOnlyClosure_ES  = DummyOnlyClosure_ES[_n-1] if PrevBigger4 == 1

panelview DummyOnlyClosure_ES, i(State) t(Year) type(treat) xtitle("") ytitle("") title("Accum. Last Elementary School Closures",size(small)) ylabel(1 "State: SH" 2 "State: NI" 3 "State: NW" 4 "State: HE" 5 "State: RP" 6 "State: BW" 7 "State: BY " 8 "State: SL" 9 "State: BB" 10 "State: MV"  11 "State: SN" 12 "State: ST"  13 "State: TH" ,labsize(tiny))
graph export "$Visualization_PanelView\PanelView_ElementarySchool_ONLY.pdf", as(pdf) replace // ytitle("German State")
graph save "$Visualization_PanelView\PanelView_ElementarySchool_ONLY.gph", replace
restore

*** Grammar Schools
preserve
collapse (sum) DummyOnlyClosure_GYM, by (State Year)

panelview DummyOnlyClosure_GYM, i(State) t(Year) type(treat) xtitle("") ytitle("") mycolor(Reds) title("Accum. Last Grammar School Closures",size(small)) ylabel(1 "State: SH" 2 "State: NI" 3 "State: NW" 4 "State: HE" 5 "State: RP" 6 "State: BW" 7 "State: BY " 8 "State: SL" 9 "State: BB" 10 "State: MV"  11 "State: SN" 12 "State: ST"  13 "State: TH" ,labsize(tiny)) // ytitle("German State")
graph export "$Visualization_PanelView\PanelView_GrammarSchool_ONLY.pdf", as(pdf) replace
graph save "$Visualization_PanelView\PanelView_GrammarSchool_ONLY.gph", replace
restore

*** Combine Graphs
preserve
cd "$Visualization_PanelView"
graph combine PanelView_ElementarySchool_ONLY.gph PanelView_GrammarSchool_ONLY.gph
graph export "$Visualization_PanelView\PanelView_Combined_ONLY.pdf", as(pdf) replace
graph save "$Visualization_PanelView\PanelView_Combined_ONLY.gph", replace
restore

