clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty"

import excel using data_FDI_withIndCode.xlsx, firstrow

cd "C:\Users\daeyu\Desktop\FDI_Uncertainty\FirmLevel_analysis"


drop if ISIC_4d == .


rename 核准日期 date
generate year = int(date/10000) + 1911
generate month = int(mod(date,10000) / 100)


sort ISIC_4d year month, stable
tostring ISIC_4d, replace
replace ISIC_4d = "0" + ISIC_4d if strlen(ISIC_4d) == 3
sort ISIC_4d year month, stable


generate ISIC_3d = substr(ISIC_4d, 1, 3)  // The first character has index 0.
generate ISIC_2d = substr(ISIC_4d, 1, 2)


replace 統一編號 = "0" + 統一編號 if strlen(統一編號) == 7


keep 國別 業別 對外投資事業名稱中文 國內投資人 統一編號 date ISIC_4d ISIC_3d ISIC_2d year month



/************************
統一編號vs國內投資人比對
************************/
bysort 國內投資人 (統一編號) : gen match1 = 統一編號[1] == 統一編號[_N]
assert match1 == 1
sort match1, stable

bysort 統一編號 (國內投資人) : gen match2 = 國內投資人[1] == 國內投資人[_N]
assert match2 == 1
sort match2 統一編號 year month, stable

// Too many cases of "單一統一編號對應多個公司名稱". So export to excel.
preserve
keep if match2 == 0
sort match2 統一編號 year month, stable
keep 國內投資人 統一編號 year month 國別 對外投資事業名稱中文 ISIC_4d
order 國內投資人 統一編號 year month 國別 對外投資事業名稱中文 ISIC_4d
export excel using "單一統一編號對應多個公司名稱列表.xlsx", firstrow(variables)
restore

capture drop match1 match2
/************************
處理完畢
************************/



order 統一編號 國內投資人 year month 國別 業別 ISIC_4d ISIC_3d ISIC_2d date 對外投資事業名稱中文
sort 統一編號 國內投資人 year month 國別 業別 ISIC_4d


merge m:1 統一編號 using data_TEJ_firmBasicInfo.dta
/**************************************************************
Result                           # of obs.
    -----------------------------------------
    not matched                         4,841
        from master                        29  (_merge==1)
        from using                      4,812  (_merge==2)

    matched                             9,115  (_merge==3)
    -----------------------------------------
****************************************************************/
drop if _merge == 2


order 統一編號 國內投資人 year month 國別 業別 主計處產業名 ISIC_4d ISIC_3d ISIC_2d date 對外投資事業名稱中文


tab 國內投資人 主計處產業名 if ustrpos(國內投資人, "潤泰")>0
/****************************************************************
                      |     主計處產業名
           國內投資人 | 4719 其..  6700 不.. |     Total
----------------------+----------------------+----------
 潤泰全球股份有限公司 |       181          0 |       181 
 潤泰創新國際股份有.. |         0        160 |       160 
 潤泰紡織股份有限公司 |         1          0 |         1 
----------------------+----------------------+----------
                Total |       182        160 |       342 
*****************************************************************/

tab 國內投資人 統一編號 if ustrpos(國內投資人, "潤泰")>0
/****************************************************************
                      |       統一編號
           國內投資人 |  12139612   14053007 |     Total
----------------------+----------------------+----------
 潤泰全球股份有限公司 |         0        181 |       181 
 潤泰創新國際股份有.. |       160          0 |       160 
 潤泰紡織股份有限公司 |         0          1 |         1 
----------------------+----------------------+----------
                Total |       160        182 |       342 
****************************************************************/
				
				


by 統一編號: generate firmFDI_count = _N
save data_FDI_firmLevel, replace






/***********************
Tax Heavens
***********************/

//tax heavnes: 瑞士、盧森堡、新加坡、香港、英屬維京群島(549)、英屬開曼群島(280)、薩摩亞(232)、愛爾蘭、百慕達、模里西斯、塞席爾、庫克群島、英屬安奎拉島、馬紹爾群島、貝里斯、列支敦斯登、奧地利、巴哈馬、薩爾瓦多、聖文森及格瑞那丁
clear
import excel using TaxHeaven_list.xlsx, firstrow
save TaxHeaven_list.dta, replace

use data_FDI_firmLevel, clear
merge m:1 國別 using TaxHeaven_list.dta
sort 統一編號 國內投資人 year month 國別 ISIC_4d

drop if _merge == 2
gen toTaxHeaven = 0
replace toTaxHeaven = 1 if _merge == 3
drop _merge
drop maybeNot


by 統一編號: egen firmFDItoTaxHeaven_count = total(toTaxHeaven)


/************************
Firm size and tax heaven investment
************************/
preserve
collapse (mean) firmFDI_count firmFDItoTaxHeaven_count ISIC_2d, by(統一編號)
scatter firmFDItoTaxHeaven_count firmFDI_count, msize(vsmall)
restore
/************************
處理完畢
************************/







