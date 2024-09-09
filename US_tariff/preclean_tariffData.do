clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty\US_tariff"

import delimited using "tariff_Train.csv", clear

keep if tariffyear >= 2013 & tariffyear <= 2019