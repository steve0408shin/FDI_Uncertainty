clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty"

import excel using 上市櫃公司對外投資事業名錄.xlsx, firstrow

tab 業別
drop if _n == 3810 // 業別是"02-25153969", 對外投資事業名稱英文是"台北市中山區建國北路一段九十六號十樓"
drop if 業別 == "11912102"
drop if 國內負責人 == "1081127" // 業別是"陳哲宏"

list if 業別 == "" && 主要營業項目 == ""
list if 業別 == "" && 主要營業項目 == "" && 國內投資人 == ""
drop if 業別 == "" && 主要營業項目 == "" && 國內投資人 == ""  // 2 observations deleted

list if 國別 == ""
replace 國別 = "英屬維京群島" if _n == 36
replace 國別 = "英屬維京群島" if _n ==79
replace 國別 = "英屬維京群島" if _n == 440
replace 國別 = "斯洛伐克" if _n == 1116
count if 國別 == ""  // 0


list if 核准日期 == ""
drop if 核准日期 == ""  // 2 observations deleted
count if 核准日期 == ""  // 0

/*
keep if 國內投資人 == "振樺電子股份有限公司"
keep 國別 業別 國內投資人 主要營業項目
*/


keep 國別 業別 對外投資事業名稱中文 對外事業地址 國內投資人 國內地址 統一編號 主要營業項目 核准日期
generate 身份註記 = "上市、上櫃公司"
order 國別 業別 對外投資事業名稱中文 對外事業地址 國內投資人 國內地址 統一編號 身份註記 主要營業項目 核准日期

rename 核准日期 核准日期_str
encode 核准日期_str, generate(核准日期)
drop 核准日期_str


replace 統一編號 = "0" + 統一編號 if strlen(統一編號) == 7


export excel using 上市櫃公司對外投資事業名錄_precleaned.xlsx, firstrow(variables) replace
save 上市櫃公司對外投資事業名錄_precleaned, replace