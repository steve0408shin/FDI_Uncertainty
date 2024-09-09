clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty"

import excel using data_FDI_withIndCode.xlsx, firstrow
save data_FDI, replace


use data_FDI, clear

rename 核准日期 date
generate year = int(date/10000) + 1911
generate month = int(mod(date,10000) / 100)

drop if ISIC_4d == .
generate twIndCode_3d = int(twIndCode_4d/10)
generate twIndCode_2d = int(twIndCode_4d/100)
generate ISIC_3d = int(ISIC_4d/10)
generate ISIC_2d = int(ISIC_4d/100)

keep 國內投資人 國別 year ISIC_3d

order year ISIC_3d 國別 國內投資人
sort year ISIC_3d 國別

by year ISIC_3d  國別: gen FDI_count_nst = _N


// Let the panel data start from 1990.
drop if year < 1990

collapse (mean) FDI_count_nst, by(year ISIC_3d 國別)

levelsof year, local(year_list)
levelsof 國別, local(country_list)
levelsof ISIC_3d, local(industry_list)

local year_count: word count `year_list'
display "`year_count'"
local country_count: word count `country_list'
display "`country_count'"
local industry_count: word count `industry_list'
display "`industry_count'"

foreach y in `year_list'{
    foreach ind in `industry_list'{
	    gen FDIin`y'forInd`ind' = (year==`y' & ISIC_3d==`ind') * FDI_count_nst
	}
}

collapse (max) FDIin*, by(國別)
/***
In the command "collapse (max) FDIin*, by(國別)",
the * character is a wildcard that matches all variables that start with the prefix FDIin.
***/


expand `year_count'*`industry_count'
//expand 31*157


local year_list 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020
local year_count: word count `year_list'
tokenize `year_list'
sort 國別
by 國別: generate year = word("`year_list'", ((_n-1)/157)+1)
// 參考:"https://www.statalist.org/forums/forum/general-stata-discussion/general/1428349-how-to-refer-to-the-first-element-in-a-macro"

local industry_list 11 12 14 16 17 32 51 61 104 105 106 107 108 110 131 139 141 151 152 162 170 181 182 191 201 202 203 210 221 222 231 239 241 242 243 251 252 259 261 262 263 264 265 266 267 268 271 272 273 274 275 279 281 282 291 293 301 302 309 310 321 323 324 325 329 331 351 352 360 370 381 382 383 390 410 422 429 432 439 451 452 453 454 461 462 463 464 465 466 469 471 472 474 475 476 477 478 479 492 501 502 511 521 522 551 552 561 582 591 592 601 602 620 631 639 641 642 643 649 651 661 662 663 681 682 691 692 701 702 711 712 721 731 732 741 749 771 773 811 812 821 823 854 869 871 872 881 900 920 931 932 949 951 952 960 970 990
local industry_count: word count `industry_list'
tokenize `industry_list'
sort 國別 year
by 國別 year: generate industry_3d = word("`industry_list'", _n)

destring year, replace
destring industry_3d, replace

order year industry_3d 國別
sort year industry_3d 國別, stable


gen FDI_count = 0

local year_list 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020
local industry_list 11 12 14 16 17 32 51 61 104 105 106 107 108 110 131 139 141 151 152 162 170 181 182 191 201 202 203 210 221 222 231 239 241 242 243 251 252 259 261 262 263 264 265 266 267 268 271 272 273 274 275 279 281 282 291 293 301 302 309 310 321 323 324 325 329 331 351 352 360 370 381 382 383 390 410 422 429 432 439 451 452 453 454 461 462 463 464 465 466 469 471 472 474 475 476 477 478 479 492 501 502 511 521 522 551 552 561 582 591 592 601 602 620 631 639 641 642 643 649 651 661 662 663 681 682 691 692 701 702 711 712 721 731 732 741 749 771 773 811 812 821 823 854 869 871 872 881 900 920 931 932 949 951 952 960 970 990

foreach y in `year_list'{
    foreach ind in `industry_list'{
	    replace FDI_count = FDIin`y'forInd`ind' if `y'==year & `ind'==industry_3d
	}
}
drop FDIin*


save data_FDI_industryLevel, replace
// 任務完成!



clear
cd "C:\Users\daeyu\Desktop\FDI_Uncertainty"
use data_FDI_industryLevel, clear




