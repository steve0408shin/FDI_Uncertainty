clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty\FDI_toChina"

import excel using FDI_toChina_withIndCode.xlsx, firstrow
save data_FDItoChina, replace

tab 大陸業別 if ISIC_4d == .
// 有一堆人名，甚麼狀況??
// 2014、2015全是這狀況


use data_FDItoChina, clear

drop 地區別 主要營業項目 大陸投資事業 大陸電話 身份註記 大陸事業地址 國內電話 大陸傳真 Unnamed14 國內投資地址 國內傳真 twIndCode_4d

rename 核准日期 date
generate year = int(date/10000) + 1911
generate month = int(mod(date,10000) / 100)

generate ISIC_3d = int(ISIC_4d/10)
save data_FDItoChina_simple, replace



/*******************************
Create the balanced panel data
(參考1:"https://www.statalist.org/forums/forum/general-stata-discussion/general/1293994-duplicate-observations-by-group-following-a-pattern")
(參考2:"https://www.statalist.org/forums/forum/general-stata-discussion/general/1358759-duplicate-each-row-as-many-times-as-is-given-in-a-variable")
*******************************/
clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty\FDI_toChina"
use data_FDItoChina_simple, clear

// Check the missing values.
count if missing(大陸業別)  // 12
count if missing(date)  // 2
count if missing(ISIC_4d)  // 1663
// Drop the observations with missing 國別/date/ISIC_4d.
drop if missing(大陸業別)
drop if missing(date)
drop if missing(ISIC_4d)
// In total, 1665 observations were dropped.


// Let the panel data start from 2000.
tab year
drop if year < 2000

sort ISIC_3d
sort 國內投資人 year, stable

drop 大陸業別 統一編號 date ISIC_4d month

levelsof ISIC_3d, local(industry_list)
levelsof year, local(year_list)
foreach y in `year_list'{
    foreach ind in `industry_list'{
	    gen FDIin`y'toChinafor`ind' = (year==`y' & ISIC_3d==`ind')
	}
}

collapse (max) FDIin*, by(國內投資人)
/***
In the command "collapse (max) FDIin*, by(國內投資人)",
the * character is a wildcard that matches all variables that start with the prefix FDIin.
***/

local year_count = 21
local industry_count = 108
expand `year_count'*`industry_count'

gen index = _n
drop if index <= 1060
drop index


bysort 國內投資人: gen year = 2000 + mod(_n-1,21)

tokenize `industry_list'
bysort 國內投資人 year: generate industry = word("`industry_list'", _n)
// 參考:"https://www.statalist.org/forums/forum/general-stata-discussion/general/1428349-how-to-refer-to-the-first-element-in-a-macro"
 
destring industry, generate(industry_int)
drop industry
rename industry_int industry

gen FDItoChina = 0
foreach y in `year_list'{
    foreach ind in `industry_list'{
	    replace FDItoChina = 1 if (FDIin`y'toChinafor`ind'==1 & year==`y' & industry==`ind')
	}
}

drop FDIin*

save data_FDItoChina_balancedPanel, replace
// 任務完成!


clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty\FDI_toChina"
use data_FDItoChina_balancedPanel, clear




/*
levelsof year, local(year_list)
tokenize `year_list'
di "`: word 1 of `year_list''"
*/



/************************************************
不用了的code
/***********************************************
sort ISIC_4d
sort 國內投資人 year, stable

by 國內投資人 year: egen yearMainInd_ISIC = mode(ISIC_4d)
by 國內投資人 year: replace yearMainInd_ISIC = ISIC_4d[1] if missing(yearMainInd_ISIC)

by 國內投資人 year: egen yearMainInd_name = mode(業別)
by 國內投資人 year: replace yearMainInd_name = 業別[1] if yearMainInd_name == ""
collapse (first) yearMainInd_ISIC yearMainInd_name, by(國內投資人 year)

// Generate an indicator variable for FDI activity in specific year.
generate annualFDI_indicator = 1
drop annualFDI_indicator
***********************************************/



/***********************************************************
Previous code (analysis with dataset without industry code)
************************************************
clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty"

import excel using 上市櫃公司對外投資事業名錄.xlsx, firstrow
save data_outward_FDI, replace

use data_outward_FDI, clear

tab 國別
//tax heavnes: 英屬維京群島(549)、英屬開曼群島(280)、薩摩亞(232)、百慕達、模里西斯、塞席爾、庫克群島
//top six: 日本、新加坡、泰國、美國、越南、香港
graph bar (count), over(國別, label(labsize(tiny) angle(270)))


use data_outward_FDI, clear
destring 核准日期, generate(date)
generate year = int(date/10000) + 1911
generate month = int(mod(date,10000) / 100)
*************************************************/

