clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty"

import excel using 上市櫃公司赴中國大陸投資事業名錄.xlsx, firstrow


tab 大陸業別 if (strlen(大陸業別)/3 <= 3) & (substr(大陸業別,-3,.) != "業") // 一個中文字佔3個字元
// 除了有兩個是「醫院」以外，全部都是人名。
replace 大陸業別 = "" if (strlen(大陸業別)/3 <= 3) & (substr(大陸業別,-3,.) != "業")
// 342 real changes made.
// 把那兩個「醫院」也改掉了

tab 大陸業別
replace 大陸業別 = "" if 大陸業別 == "林張清沚"
replace 大陸業別 = "" if 大陸業別 == "WILBER HUANG"

list if 大陸業別 == "" && 主要營業項目 == ""
drop if 大陸業別 == "" && 主要營業項目 == "" && 國內投資人 == ""  // 0 observations deleted

list if 核准日期 == .
drop if 核准日期 == .  // 2 observations deleted
count if 核准日期 == .  // 0


keep 大陸投資事業 大陸事業地址 大陸業別 國內投資人 國內投資地址 統一編號 身份註記 主要營業項目 核准日期
generate 國別 = "中國"
rename 大陸投資事業 對外投資事業名稱中文
rename 大陸事業地址 對外事業地址
rename 大陸業別 業別
rename 國內投資地址 國內地址
order 國別 業別 對外投資事業名稱中文 對外事業地址 國內投資人 國內地址 統一編號 身份註記 主要營業項目 核准日期


replace 統一編號 = "0" + 統一編號 if strlen(統一編號) == 7


// keep if strpos(國內投資人, "潤泰")>0


export excel using 上市櫃公司赴中國大陸投資事業名錄_precleaned.xlsx, firstrow(variables) replace
save 上市櫃公司赴中國大陸投資事業名錄_precleaned, replace