clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty\US_tariff"

import delimited using "tariff_Train.csv", clear

keep if tariffyear >= 2013 & tariffyear <= 2019



sort product tariffyear, stable

keep selectednomen nativenomen reportername product productname partnername tariffyear tradeyear dutytype simpleaverage weightedaverage minimumrate maximumrate nbroftotallines importsvaluein1000usd bindingcoverage


preserve
keep if dutytype == "MFN"
by product: gen yearCnt = _N
tab yearCnt
restore


preserve
keep if dutytype == "BND"
by product: gen yearCnt = _N
tab yearCnt
restore


preserve
keep if dutytype == "AHS"
by product: gen yearCnt = _N
tab yearCnt
restore




// generate byte present = !missing(MFNyear)
// bysort present product (MFNyear): generate byte same = MFNyear[1] == MFNyear[_N]