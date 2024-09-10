clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty\FDI_toChina"

import excel using FDI_toChina_withIndCode.xlsx, firstrow

tab 大陸業別 if (strlen(大陸業別)/3 <= 3) & (substr(大陸業別,-3,.) != "業") // 一個中文字佔3個字元
// 除了有兩個是「醫院」以外，全部都是人名。

replace 大陸業別 = "" if (strlen(大陸業別)/3 <= 3) & (substr(大陸業別,-3,.) != "業")

replace 大陸業別 = "" if 大陸業別 == "林張清沚"
replace 大陸業別 = "" if 大陸業別 == "WILBER HUANG"

export excel using 上市櫃公司赴中國大陸投資事業名錄_precleaned.xlsx, firstrow(varlabels) replace