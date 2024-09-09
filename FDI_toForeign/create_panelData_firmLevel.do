clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty"

import excel using FDI_toForegin_withIndCode.xlsx, firstrow
save data_outwardFDI, replace

use data_outwardFDI, clear

tab 業別 if ISIC_4d == .

rename 核准日期 date
generate year = int(date/10000) + 1911
generate month = int(mod(date,10000) / 100)

generate twIndCode_3d = int(twIndCode_4d/10)
generate twIndCode_2d = int(twIndCode_4d/100)
generate ISIC_3d = int(ISIC_4d/10)
generate ISIC_2d = int(ISIC_4d/100)

drop 國外電話 國外傳真 國內電話 國內傳真 核准記錄
order 國別 業別 對外投資事業名稱中文 對外投資事業名稱英文 國內投資人 國內負責人 對外事業地址 國內地址 統一編號 date year month twIndCode_4d twIndCode_2d twIndCode_3d ISIC_4d ISIC_3d ISIC_2d 主要營業項目
save data_outwardFDI, replace


/******************
初步製作圖表
******************/
use data_outwardFDI, clear

cd "C:\Users\daeyu\Desktop\FDI_Uncertainty\Figures"
tab 國別
//tax heavnes: 瑞士、盧森堡、新加坡、香港、英屬維京群島(549)、英屬開曼群島(280)、薩摩亞(232)、愛爾蘭、百慕達、模里西斯、塞席爾、庫克群島、英屬安奎拉島、馬紹爾群島、貝里斯、列支敦斯登
//top six: 日本、新加坡、泰國、美國、越南、香港
graph bar (count), over(國別, label(labsize(tiny) angle(270))) title("Investment count by country")
graph export "InvbyCountry.png", replace      

tab year
// 從1985開始每年都有投資案
// 從1990開始比較多
graph bar (count), over(year, label(labsize(tiny) angle(270))) title("Investment count by year")
graph export "InvbyYear.png", replace       

// Drop the tax heavens and analyze again.
preserve
drop if 國別=="英屬維京群島" || 國別=="英屬開曼群島" || 國別=="薩摩亞" || 國別=="百慕達" || 國別=="模里西斯" || 國別=="塞席爾" || 國別=="庫克群島" || 國別=="英屬曼奎拉島" || 國別=="馬紹爾群島" || 國別=="貝里斯"

tab 國別
graph bar (count), over(國別, label(labsize(tiny) angle(270))) title("Investment count by country, excluding tax heavens")
graph export "InvbyCountry_noHeaven.png", replace

tab year
graph bar (count), over(year, label(labsize(tiny) angle(270)))  title("Investment count by country, excluding tax heavens")
graph export "InvbyYear_noHeaven.png", replace

restore

// Look only at the tax heavens
preserve
keep if 國別=="英屬維京群島" || 國別=="英屬開曼群島" || 國別=="薩摩亞" || 國別=="百慕達" || 國別=="模里西斯" || 國別=="塞席爾" || 國別=="庫克群島" || 國別=="英屬曼奎拉島" || 國別=="馬紹爾群島" || 國別=="貝里斯"

tab year
graph bar (count), over(year, label(labsize(tiny) angle(270)))  title("Investment count by country, only tax heavens")
graph export "InvbyYear_onlyHeaven.png", replace

restore



/*******************************
Create the balanced panel data
(參考1:"https://www.statalist.org/forums/forum/general-stata-discussion/general/1293994-duplicate-observations-by-group-following-a-pattern")
(參考2:"https://www.statalist.org/forums/forum/general-stata-discussion/general/1358759-duplicate-each-row-as-many-times-as-is-given-in-a-variable")
*******************************/
clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty"
use data_outwardFDI, clear

// Check the missing values.
count if missing(國別)
count if missing(業別)
count if missing(date)
count if missing(ISIC_4d)
// Drop the observations with missing 國別/date/ISIC_4d.
drop if missing(國別)
drop if missing(date)
drop if missing(ISIC_4d)

// Let the panel data start from 1990.
drop if year < 1990

sort ISIC_4d
sort 國內投資人 year, stable
order 國內投資人 year ISIC_4d 業別 國別 對外投資事業名稱中文 對外投資事業名稱英文 國內負責人 對外事業地址 國內地址 統一編號 date month twIndCode_4d twIndCode_2d twIndCode_3d ISIC_3d ISIC_2d 主要營業項目
drop 主要營業項目 對外事業地址 國內地址
keep 國內投資人 year ISIC_4d 國別

levelsof 國別, local(country_list)
levelsof year, local(year_list)
foreach y in `year_list'{
    foreach c in `country_list'{
	    gen FDIin`y'to`c' = (year==`y' & 國別=="`c'")
	}
}

collapse (max) FDIin*, by(國內投資人)
/***
In the command "collapse (max) FDIin*, by(國內投資人)",
the * character is a wildcard that matches all variables that start with the prefix FDIin.
***/

local year_count = 31
expand `year_count'

gen index = _n
drop if index <= 952
drop index

bysort 國內投資人: gen year = 1989 + _n

foreach c in `country_list'{
    gen FDIto`c' = 0
    foreach y in `year_list'{
	    replace FDIto`c' = 1 if (FDIin`y'to`c'==1 & `y'==year)
	}
}

drop FDIin*
egen firm_annual_FDI_count = rowtotal(FDIto*)

save data_outwardFDI_balancedPanel, replace
// 任務完成!



clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty"
use data_outwardFDI_balancedPanel, clear






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
Previous code (analysis using dataset without industry code)
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

