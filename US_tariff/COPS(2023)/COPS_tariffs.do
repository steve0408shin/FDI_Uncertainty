/* Goods and Factor Market Integration: A Quantitative Assessment of the EU Enlargement
Lorenzo Caliendo - Yale University
Luca David Opromolla - Banco de Portugal
Fernando J. Parro - Penn State University
Alessandro Sforza - University of Bologna
*/

clear
local path "/Users/alessandrosforza/Dropbox/work/Projects/working directory for stata computing/COPS new"
cap log close
log using "/Users/alessandrosforza/Dropbox/work/Projects/working directory for stata computing/COPS new/log/COPS_tariffs_May_19_2021", replace
set more off
clear all


cd "`path'/Raw data/Tariffs New"


********************************************************************************

// Structure of the code:

// Part 1.  Import data 
// Part 2.  Construct aggregate tariff figures using TRAINS dataset
// Part 2.a Simple average
// Part 2.b Weighted average
// Part 3.  Construct aggregate tariff figures using WTO dataset
// Part 3.a Simple average
// Part 3.b Weighted average
// Part 4.  Fix bilateral tariff matrices to make them complete
// Part 4.a Simple Average
// Part 4.b Weighted Average

********************************************************************************


// Part 1: Import data 
/*

 1. WTO 6 digit
import delimited "/Users/alessandrosforza/Work/Projects/COPS/Raw data/Tariffs/tariffdata22mayWTO6digit.CSV", encoding(ISO-8859-1)
saveold tariffdata22mayWTO6digit, replace

 2. Trains 6 digit
clear
import delimited "/Users/alessandrosforza/Work/Projects/COPS/Raw data/Tariffs/tariffdata22may6digit.CSV", encoding(ISO-8859-1)
saveold tariffdata22may6digit, replace

 3. WTO aggregate
clear 
import delimited "/Users/alessandrosforza/Work/Projects/COPS/Raw data/Tariffs/tariffdata22mayWTO.CSV", encoding(ISO-8859-1)
saveold tariffdata22mayWTOaggr, replace


 4. Trains aggregate
clear
import delimited "/Users/alessandrosforza/Work/Projects/COPS/Raw data/Tariffs/tariffdata22mayTrainsAggr.CSV", encoding(ISO-8859-1)clear
saveold tariffdata22mayTrainsAggr, replace


Methodological Note:
 PartnerName (exporter) is the country facing the tariff
 ReporterName (importer) is the country imposing the tariff 

 Country dropped: Luxembourg and Ireland.
 */
******************************************************************

// Part 2. Construct aggregate tariff figures using TRAINS dataset

******************************************************************

use tariffdataTrainsAggr2019J, clear
replace PartnerName = subinstr(PartnerName, "---","",.)
replace PartnerName = subinstr(PartnerName, " ","",.)
replace PartnerName = subinstr(PartnerName, ","," ",.)
replace PartnerName = "EU25" if PartnerName=="EU25EU25membersEU25"
replace PartnerName = "EU27" if PartnerName=="EU27EU27membersEU27"
replace PartnerName = "OECD" if PartnerName=="ALLOECDmembersOECD"
replace PartnerName = "Korea" if PartnerName=="Korea Rep."
replace PartnerName = "Taiwan" if PartnerName=="Taiwan China"

replace ReporterName = subinstr(ReporterName, "---","",.)
replace ReporterName = subinstr(ReporterName, " ","",.)
replace ReporterName = subinstr(ReporterName, ","," ",.)
replace ReporterName = "EU25" if ReporterName=="EU25EU25membersEU25"
replace ReporterName = "EU27" if ReporterName=="EU27EU27membersEU27"
replace ReporterName = "OECD" if ReporterName=="ALLOECDmembersOECD"
replace ReporterName = "Korea" if ReporterName=="Korea Rep."
replace ReporterName = "Taiwan" if ReporterName=="Taiwan China"

drop if PartnerName =="Georgia"
drop if ReporterName=="Georgia" // this is to keep the same set of countries in ROW for both tariffs and import shares

save Trains_clean_1, replace

// 2.a Simple Average

// Make the matrix square
keep ReporterName PartnerName TariffYear SimpleAverage  // We only have Effectively applied rates as tariff type 
reshape wide SimpleAverage,i(ReporterName PartnerName) j(TariffYear)  // Make the matrix "complete", i.e. we want the same number of observations by year, country in t, country in t-1, etc.
reshape long SimpleAverage,i(ReporterName PartnerName) j(TariffYear)
reshape wide SimpleAverage,i(TariffYear PartnerName) j(ReporterName) string
reshape long SimpleAverage,i(TariffYear PartnerName) j(ReporterName) string
save fixing_a, replace
reshape wide SimpleAverage,i(TariffYear ReporterName) j(PartnerName) string
reshape long SimpleAverage,i(TariffYear ReporterName) j(PartnerName) string

// Fix the issue of having different countries on the rows and on the columns
preserve
use fixing_a,clear
gen repname_new = PartnerName
ren ReporterName parname_new
keep repname_new TariffYear parname_new
rename repname_new ReporterName
save fixing, replace
restore
merge m:m TariffYear ReporterName using fixing
replace PartnerName= parname_new if _m==2
drop parname_new _m

gen country_imp=0 if ReporterName=="EU25"
replace country_imp=99 if ReporterName=="EU27"
replace country_imp=1 if ReporterName=="Austria"
replace country_imp=2 if ReporterName=="Belgium"
replace country_imp=3 if ReporterName=="Bulgaria"
replace country_imp=5 if ReporterName=="Cyprus"
replace country_imp=6 if ReporterName=="CzechRepublic"
replace country_imp=7 if ReporterName=="Germany"
replace country_imp=8 if ReporterName=="Denmark"
replace country_imp=9 if ReporterName=="Estonia"
replace country_imp=13 if ReporterName=="Greece"
replace country_imp=10 if ReporterName=="Spain"
replace country_imp=11 if ReporterName=="Finland"
replace country_imp=12 if ReporterName=="France"
replace country_imp=15 if ReporterName=="Hungary"
replace country_imp=16 if ReporterName=="Ireland"
replace country_imp=18 if ReporterName=="Italy"
replace country_imp=19 if ReporterName=="Lithuania"
replace country_imp=20 if ReporterName=="Luxembourg"
replace country_imp=21 if ReporterName=="Latvia"
replace country_imp=23 if ReporterName=="Netherlands"
replace country_imp=25 if ReporterName=="Poland"
replace country_imp=26 if ReporterName=="Portugal"
replace country_imp=27 if ReporterName=="Romania"
replace country_imp=28 if ReporterName=="Sweden"
replace country_imp=29 if ReporterName=="Slovenia"
replace country_imp=30 if ReporterName=="SlovakRepublic"
replace country_imp=31 if ReporterName=="UnitedKingdom"
replace country_imp=9999 if country_imp==.

gen country_exp=0 if PartnerName=="EU25"
replace country_exp=99 if PartnerName=="EU27"
replace country_exp=1 if PartnerName=="Austria"
replace country_exp=2 if PartnerName=="Belgium"
replace country_exp=3 if PartnerName=="Bulgaria"
replace country_exp=5 if PartnerName=="Cyprus"
replace country_exp=6 if PartnerName=="CzechRepublic"
replace country_exp=7 if PartnerName=="Germany"
replace country_exp=8 if PartnerName=="Denmark"
replace country_exp=9 if PartnerName=="Estonia"
replace country_exp=13 if PartnerName=="Greece"
replace country_exp=10 if PartnerName=="Spain"
replace country_exp=11 if PartnerName=="Finland"
replace country_exp=12 if PartnerName=="France"
replace country_exp=15 if PartnerName=="Hungary"
replace country_exp=16 if PartnerName=="Ireland"
replace country_exp=18 if PartnerName=="Italy"
replace country_exp=19 if PartnerName=="Lithuania"
replace country_exp=20 if PartnerName=="Luxembourg"
replace country_exp=21 if PartnerName=="Latvia"
replace country_exp=23 if PartnerName=="Netherlands"
replace country_exp=25 if PartnerName=="Poland"
replace country_exp=26 if PartnerName=="Portugal"
replace country_exp=27 if PartnerName=="Romania"
replace country_exp=28 if PartnerName=="Sweden"
replace country_exp=29 if PartnerName=="Slovenia"
replace country_exp=30 if PartnerName=="SlovakRepublic"
replace country_exp=31 if PartnerName=="UnitedKingdom"
replace country_exp=9999 if country_exp==.
label define country_t_1_temp 9999 RoW 1	AT 2	BE 3	BG 5 CY 6	CZ 7	DE 8 DK 9	EE 13	GR 10	ES 11	FI 12	FR 15	HU 16	IE 18	IT 19	LT 20	LU 21	LV 23	NL 25	PL 26	PT 27	RO 28	SE 29	SI 30	SK 31	UK 0 EU25 99 EU27
label values country_imp country_t_1_temp
label values country_exp country_t_1_temp


// Generate country groups
gen byte eu_o =  country_exp==1 | country_exp==2 | country_exp==7 | country_exp==8 | country_exp==10 | country_exp==11 | country_exp==12 | country_exp==13 | country_exp==18 | country_exp==20 | country_exp==26 | country_exp==31 
gen byte eu_d =  country_imp==1 | country_imp==2 | country_imp==7 | country_imp==8 | country_imp==10 | country_imp==11 | country_imp==12 | country_imp==13 | country_imp==18 | country_imp==20 | country_imp==26 | country_imp==31
gen byte nms8_o = country_exp==5 | country_exp==6 | country_exp==9 | country_exp==15 | country_exp==19 | country_exp==21 | country_exp==25 | country_exp==30
gen byte nms8_d = country_imp==5 | country_imp==6 | country_imp==9 | country_imp==15 | country_imp==19 | country_imp==21 | country_imp==25 | country_imp==30
gen byte nms2_o = country_exp==3 | country_exp==27
gen byte nms2_d = country_imp==3 | country_imp==27

keep if country_imp!=. & country_exp!=.

// Use average EU25 tariff to nms8 to replace missing tariff when destination is a EU15 country and origin a NMS8
egen group = group(TariffYear country_exp)
sort group TariffYear country_imp
gen double EU25_imp_average = SimpleAverage if country_imp==0 & nms8_o==1
replace EU25_imp_average = EU25_imp_average[_n-1] if group==group[_n-1]
replace SimpleAverage=EU25_imp_average if eu_d==1 & nms8_o==1 & SimpleAverage==.  

// Use average EU27 tariff to nms2 to replace missing tariff when destination is a EU15 country and origin a NMS2
sort group TariffYear country_imp
gen double temp_EU27_imp_average = SimpleAverage if country_imp==99 & nms2_o==1
egen double EU27_imp_average = max(temp_EU27_imp_average), by(group)  
replace SimpleAverage=EU27_imp_average if eu_d==1 & nms2_o==1 & SimpleAverage==.  
replace SimpleAverage=EU27_imp_average if nms8_d==1 & nms2_o==1 & SimpleAverage==.  
drop temp_EU27_imp_average

drop if country_imp==0 | country_exp==0 // drop EU25 aggregate
drop if country_imp==99 | country_exp==99 // drop EU27 aggregate

// keep AT	BE	DE	DK	GR	ES	FR	IT	PT	UK	CY	CZ	EE	HU	LT	LV	PL

replace country_imp = 9999 if country_imp!=1 & country_imp!=2 & country_imp!=5 & country_imp!=6 & country_imp!=7 & country_imp!=8 & country_imp!=9 & country_imp!=10 & country_imp!=12 & country_imp!=13 & country_imp!=15 & country_imp!=18 & country_imp!=19 & country_imp!=21 & country_imp!=25 & country_imp!=26 & country_imp!=31 
replace country_exp = 9999 if country_exp!=1 & country_exp!=2 & country_exp!=5 & country_exp!=6 & country_exp!=7 & country_exp!=8 & country_exp!=9 & country_exp!=10 & country_exp!=12 & country_exp!=13 & country_exp!=15 & country_exp!=18 & country_exp!=19 & country_exp!=21 & country_exp!=25 & country_exp!=26 & country_exp!=31 

collapse (mean) SimpleAverage, by(TariffYear country_imp country_exp)

replace SimpleAverage=0 if country_imp==country_exp // make sure diagonals are zero

keep country_imp country_exp TariffYear SimpleAverage
reshape wide SimpleAverage,i(country_imp country_exp) j(TariffYear)  // Make the matrix "complete", i.e. we want the same number of observations by year, country in t, country in t-1, etc.
reshape long SimpleAverage,i(country_imp country_exp) j(TariffYear)  
reshape wide SimpleAverage,i(TariffYear country_exp) j(country_imp)  
reshape long SimpleAverage,i(TariffYear country_exp) j(country_imp)  
reshape wide SimpleAverage,i(TariffYear country_imp) j(country_exp)  
reshape long SimpleAverage,i(TariffYear country_imp) j(country_exp) 

gen byte eu_o =  country_exp==1 | country_exp==2 | country_exp==7 | country_exp==8 | country_exp==10 | country_exp==11 | country_exp==12 | country_exp==13 | country_exp==18 | country_exp==20 | country_exp==26 | country_exp==31
gen byte eu_d =  country_imp==1 | country_imp==2 | country_imp==7 | country_imp==8 | country_imp==10 | country_imp==11 | country_imp==12 | country_imp==13 | country_imp==18 | country_imp==20 | country_imp==26 | country_imp==31
gen byte nms8_o = country_exp==5 | country_exp==6 | country_exp==9 | country_exp==15 | country_exp==19 | country_exp==21 | country_exp==25 | country_exp==30
gen byte nms8_d = country_imp==5 | country_imp==6 | country_imp==9 | country_imp==15 | country_imp==19 | country_imp==21 | country_imp==25 | country_imp==30

replace SimpleAverage=0 if eu_o==1 & eu_d==1 
replace SimpleAverage=0 if SimpleAverage==. & TariffYear>2003 
rename TariffYear refyear
keep refyear country_imp country_exp SimpleAverage
save TRAINS_aggr, replace


// 2.b Weighted average

use Trains_clean_1, clear

// Make the matrix square
keep ReporterName PartnerName TariffYear WeightedAverage  // We only have Effectively applied rates as tariff type 
reshape wide WeightedAverage,i(ReporterName PartnerName) j(TariffYear)  // Make the matrix "complete", i.e. we want the same number of observations by year, country in t, country in t-1, etc.
reshape long WeightedAverage,i(ReporterName PartnerName) j(TariffYear)
reshape wide WeightedAverage,i(TariffYear PartnerName) j(ReporterName) string
reshape long WeightedAverage,i(TariffYear PartnerName) j(ReporterName) string
save fixing_a, replace
reshape wide WeightedAverage,i(TariffYear ReporterName) j(PartnerName) string
reshape long WeightedAverage,i(TariffYear ReporterName) j(PartnerName) string

// Fix the issue of having different countries on the rows and on the columns
preserve
use fixing_a,clear
gen repname_new = PartnerName
ren ReporterName parname_new
keep repname_new TariffYear parname_new
rename repname_new ReporterName
save fixing, replace
restore
merge m:m TariffYear ReporterName using fixing
replace PartnerName= parname_new if _m==2
drop parname_new _m

gen country_imp=0 if ReporterName=="EU25"
replace country_imp=99 if ReporterName=="EU27"
replace country_imp=1 if ReporterName=="Austria"
replace country_imp=2 if ReporterName=="Belgium"
replace country_imp=3 if ReporterName=="Bulgaria"
replace country_imp=5 if ReporterName=="Cyprus"
replace country_imp=6 if ReporterName=="CzechRepublic"
replace country_imp=7 if ReporterName=="Germany"
replace country_imp=8 if ReporterName=="Denmark"
replace country_imp=9 if ReporterName=="Estonia"
replace country_imp=13 if ReporterName=="Greece"
replace country_imp=10 if ReporterName=="Spain"
replace country_imp=11 if ReporterName=="Finland"
replace country_imp=12 if ReporterName=="France"
replace country_imp=15 if ReporterName=="Hungary"
replace country_imp=16 if ReporterName=="Ireland"
replace country_imp=18 if ReporterName=="Italy"
replace country_imp=19 if ReporterName=="Lithuania"
replace country_imp=20 if ReporterName=="Luxembourg"
replace country_imp=21 if ReporterName=="Latvia"
replace country_imp=23 if ReporterName=="Netherlands"
replace country_imp=25 if ReporterName=="Poland"
replace country_imp=26 if ReporterName=="Portugal"
replace country_imp=27 if ReporterName=="Romania"
replace country_imp=28 if ReporterName=="Sweden"
replace country_imp=29 if ReporterName=="Slovenia"
replace country_imp=30 if ReporterName=="SlovakRepublic"
replace country_imp=31 if ReporterName=="UnitedKingdom"
replace country_imp=9999 if country_imp==.

gen country_exp=0 if PartnerName=="EU25"
replace country_exp=99 if PartnerName=="EU27"
replace country_exp=1 if PartnerName=="Austria"
replace country_exp=2 if PartnerName=="Belgium"
replace country_exp=3 if PartnerName=="Bulgaria"
replace country_exp=5 if PartnerName=="Cyprus"
replace country_exp=6 if PartnerName=="CzechRepublic"
replace country_exp=7 if PartnerName=="Germany"
replace country_exp=8 if PartnerName=="Denmark"
replace country_exp=9 if PartnerName=="Estonia"
replace country_exp=13 if PartnerName=="Greece"
replace country_exp=10 if PartnerName=="Spain"
replace country_exp=11 if PartnerName=="Finland"
replace country_exp=12 if PartnerName=="France"
replace country_exp=15 if PartnerName=="Hungary"
replace country_exp=16 if PartnerName=="Ireland"
replace country_exp=18 if PartnerName=="Italy"
replace country_exp=19 if PartnerName=="Lithuania"
replace country_exp=20 if PartnerName=="Luxembourg"
replace country_exp=21 if PartnerName=="Latvia"
replace country_exp=23 if PartnerName=="Netherlands"
replace country_exp=25 if PartnerName=="Poland"
replace country_exp=26 if PartnerName=="Portugal"
replace country_exp=27 if PartnerName=="Romania"
replace country_exp=28 if PartnerName=="Sweden"
replace country_exp=29 if PartnerName=="Slovenia"
replace country_exp=30 if PartnerName=="SlovakRepublic"
replace country_exp=31 if PartnerName=="UnitedKingdom"
replace country_exp=9999 if country_exp==.
label define country_t_1_temp 9999 RoW 1	AT 2	BE 3	BG 5 CY 6	CZ 7	DE 8 DK 9	EE 13	GR 10	ES 11	FI 12	FR 15	HU 16	IE 18	IT 19	LT 20	LU 21	LV 23	NL 25	PL 26	PT 27	RO 28	SE 29	SI 30	SK 31	UK 0 EU25 99 EU27
label values country_imp country_t_1_temp
label values country_exp country_t_1_temp

// Generate country groups
gen byte eu_o =  country_exp==1 | country_exp==2 | country_exp==7 | country_exp==8 | country_exp==10 | country_exp==11 | country_exp==12 | country_exp==13 | country_exp==18 | country_exp==20 | country_exp==26 | country_exp==31 | country_exp==0
gen byte eu_d =  country_imp==1 | country_imp==2 | country_imp==7 | country_imp==8 | country_imp==10 | country_imp==11 | country_imp==12 | country_imp==13 | country_imp==18 | country_imp==20 | country_imp==26 | country_imp==31 | country_imp==0
gen byte nms8_o = country_exp==5 | country_exp==6 | country_exp==9 | country_exp==15 | country_exp==19 | country_exp==21 | country_exp==25 | country_exp==30
gen byte nms8_d = country_imp==5 | country_imp==6 | country_imp==9 | country_imp==15 | country_imp==19 | country_imp==21 | country_imp==25 | country_imp==30
gen byte nms2_o = country_exp==3 | country_exp==27
gen byte nms2_d = country_imp==3 | country_imp==27

keep if country_imp!=. & country_exp!=.

// Use average EU25 tariff to nms8 to replace missing tariff when destination is a EU15 country and origin a NMS8
egen group = group(TariffYear country_exp)
sort group TariffYear country_imp
gen double EU25_imp_average = WeightedAverage if country_imp==0 & nms8_o==1
replace EU25_imp_average = EU25_imp_average[_n-1] if group==group[_n-1]
replace WeightedAverage=EU25_imp_average if eu_d==1 & nms8_o==1 & WeightedAverage==.  

// Use average EU27 tariff to nms2 to replace missing tariff when destination is a EU15 country and origin a NMS2
sort group TariffYear country_imp
gen double temp_EU27_imp_average = WeightedAverage if country_imp==99 & nms2_o==1
egen double EU27_imp_average = max(temp_EU27_imp_average), by(group)  
replace WeightedAverage=EU27_imp_average if eu_d==1 & nms2_o==1 & WeightedAverage==.  
replace WeightedAverage=EU27_imp_average if nms8_d==1 & nms2_o==1 & WeightedAverage==.  
drop temp_EU27_imp_average

drop if country_imp==0 | country_exp==0 // drop EU25 aggregate
drop if country_imp==99 | country_exp==99 // drop EU27 aggregate
// keep AT	BE	DE	DK	GR	ES	FR	IT	PT	UK	CY	CZ	EE	HU	LT	LV	PL

replace country_imp = 9999 if country_imp!=1 & country_imp!=2 & country_imp!=5 & country_imp!=6 & country_imp!=7 & country_imp!=8 & country_imp!=9 & country_imp!=10 & country_imp!=12 & country_imp!=13 & country_imp!=15 & country_imp!=18 & country_imp!=19 & country_imp!=21 & country_imp!=25 & country_imp!=26 & country_imp!=31 
replace country_exp = 9999 if country_exp!=1 & country_exp!=2 & country_exp!=5 & country_exp!=6 & country_exp!=7 & country_exp!=8 & country_exp!=9 & country_exp!=10 & country_exp!=12 & country_exp!=13 & country_exp!=15 & country_exp!=18 & country_exp!=19 & country_exp!=21 & country_exp!=25 & country_exp!=26 & country_exp!=31 

collapse (mean) WeightedAverage, by(TariffYear country_imp country_exp)

replace WeightedAverage=0 if country_imp==country_exp // make sure diagonals are zero

keep country_imp country_exp TariffYear WeightedAverage
reshape wide WeightedAverage,i(country_imp country_exp) j(TariffYear)  // Make the matrix "complete", i.e. we want the same number of observations by year, country in t, country in t-1, etc.
reshape long WeightedAverage,i(country_imp country_exp) j(TariffYear)  
reshape wide WeightedAverage,i(TariffYear country_exp) j(country_imp)  
reshape long WeightedAverage,i(TariffYear country_exp) j(country_imp)  
reshape wide WeightedAverage,i(TariffYear country_imp) j(country_exp)  
reshape long WeightedAverage,i(TariffYear country_imp) j(country_exp) 

gen byte eu_o =  country_exp==1 | country_exp==2 | country_exp==7 | country_exp==8 | country_exp==10 | country_exp==11 | country_exp==12 | country_exp==13 | country_exp==18 | country_exp==20 | country_exp==26 | country_exp==31
gen byte eu_d =  country_imp==1 | country_imp==2 | country_imp==7 | country_imp==8 | country_imp==10 | country_imp==11 | country_imp==12 | country_imp==13 | country_imp==18 | country_imp==20 | country_imp==26 | country_imp==31
gen byte nms8_o = country_exp==5 | country_exp==6 | country_exp==9 | country_exp==15 | country_exp==19 | country_exp==21 | country_exp==25 | country_exp==30
gen byte nms8_d = country_imp==5 | country_imp==6 | country_imp==9 | country_imp==15 | country_imp==19 | country_imp==21 | country_imp==25 | country_imp==30

replace WeightedAverage=0 if eu_o==1 & eu_d==1
replace WeightedAverage=0 if WeightedAverage==. & TariffYear>2003 
rename TariffYear refyear
keep refyear country_imp country_exp WeightedAverage
save TRAINS_aggr_W, replace



***************************************************************

// Part 3. Construct aggregate tariff figures using WTO dataset

***************************************************************

use tariffdataWTOaggr2019J, clear
replace PartnerName = subinstr(PartnerName, "---","",.)
replace PartnerName = subinstr(PartnerName, " ","",.)
replace PartnerName = subinstr(PartnerName, ","," ",.)
replace PartnerName = "EU25" if PartnerName=="EU25EU25membersEU25"
replace PartnerName = "EU27" if PartnerName=="EU27EU27membersEU27"
replace PartnerName = "OECD" if PartnerName=="ALLOECDmembersOECD"
replace PartnerName = "Korea" if PartnerName=="Korea Rep."
replace PartnerName = "Taiwan" if PartnerName=="Taiwan China"

replace ReporterName = subinstr(ReporterName, "---","",.)
replace ReporterName = subinstr(ReporterName, " ","",.)
replace ReporterName = subinstr(ReporterName, ","," ",.)
replace ReporterName = "EU25" if ReporterName=="EU25EU25membersEU25"
replace ReporterName = "EU27" if ReporterName=="EU27EU27membersEU27"
replace ReporterName = "OECD" if ReporterName=="ALLOECDmembersOECD"
replace ReporterName = "Korea" if ReporterName=="Korea Rep."
replace ReporterName = "Taiwan" if ReporterName=="Taiwan China"

drop if PartnerName =="Georgia"
drop if ReporterName=="Georgia" // this is to keep the same set of countries in ROW for both tariffs and import shares

save WTO_clean_1, replace

// 3.a Simple Average

// Make the matrix square
keep ReporterName PartnerName TariffYear SimpleAverage  // We only have Effectively applied rates as tariff type 
reshape wide SimpleAverage,i(ReporterName PartnerName) j(TariffYear)  // Make the matrix "complete", i.e. we want the same number of observations by year, country in t, country in t-1, etc.
reshape long SimpleAverage,i(ReporterName PartnerName) j(TariffYear)
reshape wide SimpleAverage,i(TariffYear PartnerName) j(ReporterName) string
reshape long SimpleAverage,i(TariffYear PartnerName) j(ReporterName) string
save fixing_a, replace
reshape wide SimpleAverage,i(TariffYear ReporterName) j(PartnerName) string
reshape long SimpleAverage,i(TariffYear ReporterName) j(PartnerName) string

// Fix the issue of having different countries on the rows and on the columns
preserve
use fixing_a,clear
gen repname_new = PartnerName
ren ReporterName parname_new
keep repname_new TariffYear parname_new
rename repname_new ReporterName
save fixing, replace
restore
merge m:m TariffYear ReporterName using fixing
replace PartnerName= parname_new if _m==2
drop parname_new _m

gen country_imp=0 if ReporterName=="EU25"
replace country_imp=99 if ReporterName=="EU27"
replace country_imp=1 if ReporterName=="Austria"
replace country_imp=2 if ReporterName=="Belgium"
replace country_imp=3 if ReporterName=="Bulgaria"
replace country_imp=5 if ReporterName=="Cyprus"
replace country_imp=6 if ReporterName=="CzechRepublic"
replace country_imp=7 if ReporterName=="Germany"
replace country_imp=8 if ReporterName=="Denmark"
replace country_imp=9 if ReporterName=="Estonia"
replace country_imp=13 if ReporterName=="Greece"
replace country_imp=10 if ReporterName=="Spain"
replace country_imp=11 if ReporterName=="Finland"
replace country_imp=12 if ReporterName=="France"
replace country_imp=15 if ReporterName=="Hungary"
replace country_imp=16 if ReporterName=="Ireland"
replace country_imp=18 if ReporterName=="Italy"
replace country_imp=19 if ReporterName=="Lithuania"
replace country_imp=20 if ReporterName=="Luxembourg"
replace country_imp=21 if ReporterName=="Latvia"
replace country_imp=23 if ReporterName=="Netherlands"
replace country_imp=25 if ReporterName=="Poland"
replace country_imp=26 if ReporterName=="Portugal"
replace country_imp=27 if ReporterName=="Romania"
replace country_imp=28 if ReporterName=="Sweden"
replace country_imp=29 if ReporterName=="Slovenia"
replace country_imp=30 if ReporterName=="SlovakRepublic"
replace country_imp=31 if ReporterName=="UnitedKingdom"
replace country_imp=9999 if country_imp==.

gen country_exp=0 if PartnerName=="EU25"
replace country_exp=99 if PartnerName=="EU27"
replace country_exp=1 if PartnerName=="Austria"
replace country_exp=2 if PartnerName=="Belgium"
replace country_exp=3 if PartnerName=="Bulgaria"
replace country_exp=5 if PartnerName=="Cyprus"
replace country_exp=6 if PartnerName=="CzechRepublic"
replace country_exp=7 if PartnerName=="Germany"
replace country_exp=8 if PartnerName=="Denmark"
replace country_exp=9 if PartnerName=="Estonia"
replace country_exp=13 if PartnerName=="Greece"
replace country_exp=10 if PartnerName=="Spain"
replace country_exp=11 if PartnerName=="Finland"
replace country_exp=12 if PartnerName=="France"
replace country_exp=15 if PartnerName=="Hungary"
replace country_exp=16 if PartnerName=="Ireland"
replace country_exp=18 if PartnerName=="Italy"
replace country_exp=19 if PartnerName=="Lithuania"
replace country_exp=20 if PartnerName=="Luxembourg"
replace country_exp=21 if PartnerName=="Latvia"
replace country_exp=23 if PartnerName=="Netherlands"
replace country_exp=25 if PartnerName=="Poland"
replace country_exp=26 if PartnerName=="Portugal"
replace country_exp=27 if PartnerName=="Romania"
replace country_exp=28 if PartnerName=="Sweden"
replace country_exp=29 if PartnerName=="Slovenia"
replace country_exp=30 if PartnerName=="SlovakRepublic"
replace country_exp=31 if PartnerName=="UnitedKingdom"
replace country_exp=9999 if country_exp==.
label define country_t_1_temp 9999 RoW 1	AT 2	BE 3	BG 5 CY 6	CZ 7	DE 8 DK 9	EE 13	GR 10	ES 11	FI 12	FR 15	HU 16	IE 18	IT 19	LT 20	LU 21	LV 23	NL 25	PL 26	PT 27	RO 28	SE 29	SI 30	SK 31	UK 0 EU25 99 EU27
label values country_imp country_t_1_temp
label values country_exp country_t_1_temp


// Generate country groups
gen byte eu_o =  country_exp==1 | country_exp==2 | country_exp==7 | country_exp==8 | country_exp==10 | country_exp==11 | country_exp==12 | country_exp==13 | country_exp==18 | country_exp==20 | country_exp==26 | country_exp==31 
gen byte eu_d =  country_imp==1 | country_imp==2 | country_imp==7 | country_imp==8 | country_imp==10 | country_imp==11 | country_imp==12 | country_imp==13 | country_imp==18 | country_imp==20 | country_imp==26 | country_imp==31
gen byte nms8_o = country_exp==5 | country_exp==6 | country_exp==9 | country_exp==15 | country_exp==19 | country_exp==21 | country_exp==25 | country_exp==30
gen byte nms8_d = country_imp==5 | country_imp==6 | country_imp==9 | country_imp==15 | country_imp==19 | country_imp==21 | country_imp==25 | country_imp==30
gen byte nms2_o = country_exp==3 | country_exp==27
gen byte nms2_d = country_imp==3 | country_imp==27

keep if country_imp!=. & country_exp!=.

// Use average EU25 tariff to nms8 to replace missing tariff when destination is a EU15 country and origin a NMS8
egen group = group(TariffYear country_exp)
sort group TariffYear country_imp
gen double EU25_imp_average = SimpleAverage if country_imp==0 & nms8_o==1
replace EU25_imp_average = EU25_imp_average[_n-1] if group==group[_n-1]
replace SimpleAverage=EU25_imp_average if eu_d==1 & nms8_o==1 & SimpleAverage==.  

// Use average EU27 tariff to nms2 to replace missing tariff when destination is a EU15 country and origin a NMS2
sort group TariffYear country_imp
gen double temp_EU27_imp_average = SimpleAverage if country_imp==99 & nms2_o==1
egen double EU27_imp_average = max(temp_EU27_imp_average), by(group)  
replace SimpleAverage=EU27_imp_average if eu_d==1 & nms2_o==1 & SimpleAverage==.  
replace SimpleAverage=EU27_imp_average if nms8_d==1 & nms2_o==1 & SimpleAverage==.  
drop temp_EU27_imp_average

drop if country_imp==0 | country_exp==0 // drop EU25 aggregate
drop if country_imp==99 | country_exp==99 // drop EU27 aggregate

// keep AT	BE	DE	DK	GR	ES	FR	IT	PT	UK	CY	CZ	EE	HU	LT	LV	PL

replace country_imp = 9999 if country_imp!=1 & country_imp!=2 & country_imp!=5 & country_imp!=6 & country_imp!=7 & country_imp!=8 & country_imp!=9 & country_imp!=10 & country_imp!=12 & country_imp!=13 & country_imp!=15 & country_imp!=18 & country_imp!=19 & country_imp!=21 & country_imp!=25 & country_imp!=26 & country_imp!=31 
replace country_exp = 9999 if country_exp!=1 & country_exp!=2 & country_exp!=5 & country_exp!=6 & country_exp!=7 & country_exp!=8 & country_exp!=9 & country_exp!=10 & country_exp!=12 & country_exp!=13 & country_exp!=15 & country_exp!=18 & country_exp!=19 & country_exp!=21 & country_exp!=25 & country_exp!=26 & country_exp!=31 

collapse (mean) SimpleAverage, by(TariffYear country_imp country_exp)

replace SimpleAverage=0 if country_imp==country_exp // make sure diagonals are zero

keep country_imp country_exp TariffYear SimpleAverage
reshape wide SimpleAverage,i(country_imp country_exp) j(TariffYear)  // Make the matrix "complete", i.e. we want the same number of observations by year, country in t, country in t-1, etc.
reshape long SimpleAverage,i(country_imp country_exp) j(TariffYear)  
reshape wide SimpleAverage,i(TariffYear country_exp) j(country_imp)  
reshape long SimpleAverage,i(TariffYear country_exp) j(country_imp)  
reshape wide SimpleAverage,i(TariffYear country_imp) j(country_exp)  
reshape long SimpleAverage,i(TariffYear country_imp) j(country_exp) 

gen byte eu_o =  country_exp==1 | country_exp==2 | country_exp==7 | country_exp==8 | country_exp==10 | country_exp==11 | country_exp==12 | country_exp==13 | country_exp==18 | country_exp==20 | country_exp==26 | country_exp==31
gen byte eu_d =  country_imp==1 | country_imp==2 | country_imp==7 | country_imp==8 | country_imp==10 | country_imp==11 | country_imp==12 | country_imp==13 | country_imp==18 | country_imp==20 | country_imp==26 | country_imp==31
gen byte nms8_o = country_exp==5 | country_exp==6 | country_exp==9 | country_exp==15 | country_exp==19 | country_exp==21 | country_exp==25 | country_exp==30
gen byte nms8_d = country_imp==5 | country_imp==6 | country_imp==9 | country_imp==15 | country_imp==19 | country_imp==21 | country_imp==25 | country_imp==30

replace SimpleAverage=0 if eu_o==1 & eu_d==1
replace SimpleAverage=0 if SimpleAverage==. & TariffYear>2003 
rename TariffYear refyear
keep refyear country_imp country_exp SimpleAverage
save WTO_aggr, replace

// 3.b Weighted average
use WTO_clean_1, clear

// Make the matrix square
keep ReporterName PartnerName TariffYear WeightedAverage  // We only have Effectively applied rates as tariff type 
reshape wide WeightedAverage,i(ReporterName PartnerName) j(TariffYear)  // Make the matrix "complete", i.e. we want the same number of observations by year, country in t, country in t-1, etc.
reshape long WeightedAverage,i(ReporterName PartnerName) j(TariffYear)
reshape wide WeightedAverage,i(TariffYear PartnerName) j(ReporterName) string
reshape long WeightedAverage,i(TariffYear PartnerName) j(ReporterName) string
save fixing_a, replace
reshape wide WeightedAverage,i(TariffYear ReporterName) j(PartnerName) string
reshape long WeightedAverage,i(TariffYear ReporterName) j(PartnerName) string

// Fix the issue of having different countries on the rows and on the columns
preserve
use fixing_a,clear
gen repname_new = PartnerName
ren ReporterName parname_new
keep repname_new TariffYear parname_new
rename repname_new ReporterName
save fixing, replace
restore
merge m:m TariffYear ReporterName using fixing
replace PartnerName= parname_new if _m==2
drop parname_new _m

gen country_imp=0 if ReporterName=="EU25"
replace country_imp=99 if ReporterName=="EU27"
replace country_imp=1 if ReporterName=="Austria"
replace country_imp=2 if ReporterName=="Belgium"
replace country_imp=3 if ReporterName=="Bulgaria"
replace country_imp=5 if ReporterName=="Cyprus"
replace country_imp=6 if ReporterName=="CzechRepublic"
replace country_imp=7 if ReporterName=="Germany"
replace country_imp=8 if ReporterName=="Denmark"
replace country_imp=9 if ReporterName=="Estonia"
replace country_imp=13 if ReporterName=="Greece"
replace country_imp=10 if ReporterName=="Spain"
replace country_imp=11 if ReporterName=="Finland"
replace country_imp=12 if ReporterName=="France"
replace country_imp=15 if ReporterName=="Hungary"
replace country_imp=16 if ReporterName=="Ireland"
replace country_imp=18 if ReporterName=="Italy"
replace country_imp=19 if ReporterName=="Lithuania"
replace country_imp=20 if ReporterName=="Luxembourg"
replace country_imp=21 if ReporterName=="Latvia"
replace country_imp=23 if ReporterName=="Netherlands"
replace country_imp=25 if ReporterName=="Poland"
replace country_imp=26 if ReporterName=="Portugal"
replace country_imp=27 if ReporterName=="Romania"
replace country_imp=28 if ReporterName=="Sweden"
replace country_imp=29 if ReporterName=="Slovenia"
replace country_imp=30 if ReporterName=="SlovakRepublic"
replace country_imp=31 if ReporterName=="UnitedKingdom"
replace country_imp=9999 if country_imp==.

gen country_exp=0 if PartnerName=="EU25"
replace country_exp=99 if PartnerName=="EU27"
replace country_exp=1 if PartnerName=="Austria"
replace country_exp=2 if PartnerName=="Belgium"
replace country_exp=3 if PartnerName=="Bulgaria"
replace country_exp=5 if PartnerName=="Cyprus"
replace country_exp=6 if PartnerName=="CzechRepublic"
replace country_exp=7 if PartnerName=="Germany"
replace country_exp=8 if PartnerName=="Denmark"
replace country_exp=9 if PartnerName=="Estonia"
replace country_exp=13 if PartnerName=="Greece"
replace country_exp=10 if PartnerName=="Spain"
replace country_exp=11 if PartnerName=="Finland"
replace country_exp=12 if PartnerName=="France"
replace country_exp=15 if PartnerName=="Hungary"
replace country_exp=16 if PartnerName=="Ireland"
replace country_exp=18 if PartnerName=="Italy"
replace country_exp=19 if PartnerName=="Lithuania"
replace country_exp=20 if PartnerName=="Luxembourg"
replace country_exp=21 if PartnerName=="Latvia"
replace country_exp=23 if PartnerName=="Netherlands"
replace country_exp=25 if PartnerName=="Poland"
replace country_exp=26 if PartnerName=="Portugal"
replace country_exp=27 if PartnerName=="Romania"
replace country_exp=28 if PartnerName=="Sweden"
replace country_exp=29 if PartnerName=="Slovenia"
replace country_exp=30 if PartnerName=="SlovakRepublic"
replace country_exp=31 if PartnerName=="UnitedKingdom"
replace country_exp=9999 if country_exp==.
label define country_t_1_temp 9999 RoW 1	AT 2	BE 3	BG 5 CY 6	CZ 7	DE 8 DK 9	EE 13	GR 10	ES 11	FI 12	FR 15	HU 16	IE 18	IT 19	LT 20	LU 21	LV 23	NL 25	PL 26	PT 27	RO 28	SE 29	SI 30	SK 31	UK 0 EU25 99 EU27
label values country_imp country_t_1_temp
label values country_exp country_t_1_temp

// Generate country groups
gen byte eu_o =  country_exp==1 | country_exp==2 | country_exp==7 | country_exp==8 | country_exp==10 | country_exp==11 | country_exp==12 | country_exp==13 | country_exp==18 | country_exp==20 | country_exp==26 | country_exp==31 | country_exp==0
gen byte eu_d =  country_imp==1 | country_imp==2 | country_imp==7 | country_imp==8 | country_imp==10 | country_imp==11 | country_imp==12 | country_imp==13 | country_imp==18 | country_imp==20 | country_imp==26 | country_imp==31 | country_imp==0
gen byte nms8_o = country_exp==5 | country_exp==6 | country_exp==9 | country_exp==15 | country_exp==19 | country_exp==21 | country_exp==25 | country_exp==30
gen byte nms8_d = country_imp==5 | country_imp==6 | country_imp==9 | country_imp==15 | country_imp==19 | country_imp==21 | country_imp==25 | country_imp==30
gen byte nms2_o = country_exp==3 | country_exp==27
gen byte nms2_d = country_imp==3 | country_imp==27

keep if country_imp!=. & country_exp!=.

// Use average EU25 tariff to nms8 to replace missing tariff when destination is a EU15 country and origin a NMS8
egen group = group(TariffYear country_exp)
sort group TariffYear country_imp
gen double EU25_imp_average = WeightedAverage if country_imp==0 & nms8_o==1
replace EU25_imp_average = EU25_imp_average[_n-1] if group==group[_n-1]
replace WeightedAverage=EU25_imp_average if eu_d==1 & nms8_o==1 & WeightedAverage==.  

// Use average EU27 tariff to nms2 to replace missing tariff when destination is a EU15 country and origin a NMS2
sort group TariffYear country_imp
gen double temp_EU27_imp_average = WeightedAverage if country_imp==99 & nms2_o==1
egen double EU27_imp_average = max(temp_EU27_imp_average), by(group)  
replace WeightedAverage=EU27_imp_average if eu_d==1 & nms2_o==1 & WeightedAverage==.  
replace WeightedAverage=EU27_imp_average if nms8_d==1 & nms2_o==1 & WeightedAverage==.  
drop temp_EU27_imp_average

drop if country_imp==0 | country_exp==0 // drop EU25 aggregate
drop if country_imp==99 | country_exp==99 // drop EU27 aggregate
// keep AT	BE	DE	DK	GR	ES	FR	IT	PT	UK	CY	CZ	EE	HU	LT	LV	PL

replace country_imp = 9999 if country_imp!=1 & country_imp!=2 & country_imp!=5 & country_imp!=6 & country_imp!=7 & country_imp!=8 & country_imp!=9 & country_imp!=10 & country_imp!=12 & country_imp!=13 & country_imp!=15 & country_imp!=18 & country_imp!=19 & country_imp!=21 & country_imp!=25 & country_imp!=26 & country_imp!=31 
replace country_exp = 9999 if country_exp!=1 & country_exp!=2 & country_exp!=5 & country_exp!=6 & country_exp!=7 & country_exp!=8 & country_exp!=9 & country_exp!=10 & country_exp!=12 & country_exp!=13 & country_exp!=15 & country_exp!=18 & country_exp!=19 & country_exp!=21 & country_exp!=25 & country_exp!=26 & country_exp!=31 

collapse (mean) WeightedAverage, by(TariffYear country_imp country_exp)

replace WeightedAverage=0 if country_imp==country_exp // make sure diagonals are zero

keep country_imp country_exp TariffYear WeightedAverage
reshape wide WeightedAverage,i(country_imp country_exp) j(TariffYear)  // Make the matrix "complete", i.e. we want the same number of observations by year, country in t, country in t-1, etc.
reshape long WeightedAverage,i(country_imp country_exp) j(TariffYear)  
reshape wide WeightedAverage,i(TariffYear country_exp) j(country_imp)  
reshape long WeightedAverage,i(TariffYear country_exp) j(country_imp)  
reshape wide WeightedAverage,i(TariffYear country_imp) j(country_exp)  
reshape long WeightedAverage,i(TariffYear country_imp) j(country_exp) 

gen byte eu_o =  country_exp==1 | country_exp==2 | country_exp==7 | country_exp==8 | country_exp==10 | country_exp==11 | country_exp==12 | country_exp==13 | country_exp==18 | country_exp==20 | country_exp==26 | country_exp==31
gen byte eu_d =  country_imp==1 | country_imp==2 | country_imp==7 | country_imp==8 | country_imp==10 | country_imp==11 | country_imp==12 | country_imp==13 | country_imp==18 | country_imp==20 | country_imp==26 | country_imp==31
gen byte nms8_o = country_exp==5 | country_exp==6 | country_exp==9 | country_exp==15 | country_exp==19 | country_exp==21 | country_exp==25 | country_exp==30
gen byte nms8_d = country_imp==5 | country_imp==6 | country_imp==9 | country_imp==15 | country_imp==19 | country_imp==21 | country_imp==25 | country_imp==30

replace WeightedAverage=0 if eu_o==1 & eu_d==1
replace WeightedAverage=0 if WeightedAverage==. & TariffYear>2003 
rename TariffYear refyear
keep refyear country_imp country_exp WeightedAverage
save WTO_aggr_W, replace


******************************************************************

// Part 4. Fix bilateral tariff matrices to make them complete

******************************************************************


// Part 4.a Simple average tariffs

set scheme s1color
set scheme plotplainblind 

use TRAINS_aggr, clear
rename SimpleAverage simpleavg_TR
merge 1:1 refyear country_imp country_exp using WTO_aggr // WTO dataset only contains tariffs after 1996
drop _merge
rename SimpleAverage simpleavg_WTO
keep if refyear>=2000

// Fixing 1: Use WTO values to impute Trains values if WTO is not missing
gen double simpleavg_TR_adj = simpleavg_TR
replace simpleavg_TR_adj=simpleavg_WTO if simpleavg_TR==.

// Fixing 2: Missing values for 2003 are replaced with values from 2002
sort country_imp country_exp refyear
gen check=1 if simpleavg_TR_adj==. & refyear==2003 & simpleavg_TR_adj[_n-1]!=. 
tab country_imp refyear if check==1
drop check 
replace simpleavg_TR_adj = simpleavg_TR_adj[_n-1] if simpleavg_TR_adj==. & refyear==2003
bys country_imp: gen avg_chg = (1-(simpleavg_TR_adj/simpleavg_TR_adj[_n-1]))*100 if simpleavg_TR_adj[_n-1]!=.
su avg_chg if country_imp==21 & refyear==2002, d

// Fixing 3: If missing values for a country are only in one year, I interpolate using the values of the year before or the year after. 
sort country_imp country_exp refyear
replace simpleavg_TR_adj = simpleavg_TR_adj[_n+1] if simpleavg_TR_adj==. & country_imp==19 & refyear==2000 // Lithuania has no data as a reporting country for 2000

// Fixing 4: If all values are missing for a country over time, I construct an average tariff of similar countries and impute that value
** This is the case of Latvia, for which we do not have info from other countries when good arrive from Latvia, so Latvia is the exporter
** We use the average of the tariffs that Lithuania and Estonia face as exporters to proxy for the one that Latvia faces itself
bys country_exp refyear : gen double EE_1 = simpleavg_TR_adj if country_imp==9
bys refyear : egen double EE = max(EE_1)
bys country_exp refyear : gen double LT_1 = simpleavg_TR_adj if country_imp==19
bys refyear : egen double LT = max(LT_1)
sort country_exp refyear
drop EE_1 LT_1 
gen avg_gr = (LT + EE)/2
replace simpleavg_TR_adj=avg_gr if simpleavg_TR_adj==. & country_exp==21

replace simpleavg_TR_adj=0 if country_imp==country_exp // make sure diagonals are zero
save Tariffs_complete_JPE_full.dta, replace

* Figure B.1 - panel A of the online appendix

preserve
keep if refyear>=2002 & refyear<=2014
collapse (mean) TR=simpleavg_TR WTO=simpleavg_WTO TR_adj=simpleavg_TR_adj, by(refyear)
twoway (line TR refyear,lcolor(eltblue) lwidth(thick) lpattern(dash) sort) || (line WTO refyear,lcolor(red) lwidth(thick) lpattern(solid) sort) || (line TR_adj refyear,lcolor(edkblue) lwidth(thick) lpattern(shortdash) xlab(2002(1)2014,labsize(small)) ylab(#5,labsize(small) nogrid) legend(order(1 2 3) label(1 "TRAINS") label(2 "WTO") label(3 "Trains adjusted")  size(small) region(lcolor(white)) position(6) rows(1) symxsize(*2)) graphregion(fcolor(none) ifcolor(none) ilcolor(none) icolor(none) lcolor(none) margin(medium) ilpattern(blank) lpattern(blank) lstyle(none)) plotregion(fcolor(white) ifcolor(white) ilcolor(white) icolor(white)) ytitle(Average tariff (%),size(small) margin(small)) xtitle(Years,size(small) margin(small)) title("Trains vs WTO + Trains adjusted - simple average",size(medium)) saving("`path'/graphs/tariffs/F29_TRvsWTO_00_avg",replace))
graph export "`path'/graphs/tariffs/F29_TRvsWTO_00_avg.eps", as(eps) replace
graph export "`path'/graphs/tariffs/F29_TRvsWTO_00_avg.pdf", as(pdf) replace
erase "`path'/graphs/tariffs/F29_TRvsWTO_00_avg.gph" 
restore
keep refyear country_imp country_exp simpleavg_TR_adj
rename simpleavg_TR_adj SimpleAverage
save Tariffs_complete_JPE.dta, replace


// Part 4.b Weighted average tariffs

use TRAINS_aggr_W, clear
rename WeightedAverage weighted_TR
merge 1:1 refyear country_imp country_exp using WTO_aggr_W // WTO dataset only contains tariffs after 1996
drop _merge
rename WeightedAverage weighted_WTO
keep if refyear>=2000

// Fixing 1: Use WTO values to impute Trains values if WTO is not missing
gen double weighted_TR_adj = weighted_TR
replace weighted_TR_adj=weighted_WTO if weighted_TR==.

// Fixing 2: Missing values for 2003 are replaced with values from 2002
sort country_imp country_exp refyear
replace weighted_TR_adj = weighted_TR_adj[_n-1] if weighted_TR_adj==. & refyear==2003

// Fixing 3: If missing values for a country are only in one year, I interpolate using the values of the year before or the year after. 
sort country_imp country_exp refyear
replace weighted_TR_adj = weighted_TR_adj[_n+1] if weighted_TR_adj==. & country_imp==19 & refyear==2000 // Lithuania has no data as a reporting country for 2000

// Fixing 4: If all values are missing for a country over time, I construct an average tariff of similar countries and impute that value
** This is the case of Latvia, for which we do not have info from other countries when good arrive from Latvia, so Latvia is the exporter
** We use the average of the tariffs that Lithuania and Estonia face as exporters to proxy for the one that Latvia faces itself
bys country_exp refyear : gen double EE_1 = weighted_TR_adj if country_imp==9
bys refyear : egen double EE = max(EE_1)
bys country_exp refyear : gen double LT_1 = weighted_TR_adj if country_imp==19
bys refyear : egen double LT = max(LT_1)
sort country_exp refyear
drop EE_1 LT_1 
gen avg_gr = (LT + EE)/2
replace weighted_TR_adj=avg_gr if weighted_TR_adj==. & country_exp==21

replace weighted_TR_adj=0 if country_imp==country_exp // make sure diagonals are zero

save Tariffs_complete_W_JPE_full.dta, replace

* Figure B.1 - panel b of the online appendix 

preserve
keep if refyear>=2002 & refyear<=2014
collapse (mean) TR=weighted_TR WTO=weighted_WTO TR_adj=weighted_TR_adj, by(refyear)
twoway (line TR refyear,lcolor(eltblue) lwidth(thick) lpattern(dash) sort) || (line WTO refyear,lcolor(red) lwidth(thick) lpattern(solid) sort) || (line TR_adj refyear,lcolor(edkblue) lwidth(thick) lpattern(shortdash) xlab(2002(1)2014,labsize(small)) ylab(#5,labsize(small) nogrid) legend(order(1 2 3) label(1 "TRAINS") label(2 "WTO") label(3 "Trains adjusted")  size(small) region(lcolor(white)) position(6) rows(1) symxsize(*2)) graphregion(fcolor(none) ifcolor(none) ilcolor(none) icolor(none) lcolor(none) margin(medium) ilpattern(blank) lpattern(blank) lstyle(none)) plotregion(fcolor(white) ifcolor(white) ilcolor(white) icolor(white)) ytitle(Average tariff (%),size(small) margin(small)) xtitle(Years,size(small) margin(small)) title("Trains vs WTO + Trains adjusted - weighted average",size(medium)) saving("`path'/graphs/tariffs/F31_TRvsWTO_00_avg",replace))
graph export "`path'/graphs/tariffs/F31_TRvsWTO_00_avg.eps", as(eps) replace
graph export "`path'/graphs/tariffs/F31_TRvsWTO_00_avg.pdf", as(pdf) replace
erase "`path'/graphs/tariffs/F31_TRvsWTO_00_avg.gph" 
restore
keep refyear country_imp country_exp weighted_TR_adj
rename weighted_TR_adj WeightedAverage
save Tariffs_complete_W_JPE.dta, replace



log close










