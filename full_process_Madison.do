*** Full process for assembling data, creating AIME and PIA, and doing basic tabulations on Claim age and benefit amounts.
clear matrix
clear
set maxvar 120000
* use the summary earnings data first
use "R:\Restricted\SSA Administrative Data\Respondent\SumEarn\stata\xyrsumern.dta" 
egen hhid_pn = concat(hhid pn) // save a copy in personal drive and delete it immediately after merging
save Copy, replace
* note that pn is string 3

use "R:\Restricted\SSA Administrative Data\Respondent\Benefits\stata\ben1a_r.dta"
duplicates report hhidpn // there are many duplicates because they are missing values
recast str3 pn
egen hhid_pn = concat(hhid pn) // this takes care of the holes in hhidpn in benefits set.
merge 1:1 hhid_pn using "R:\SharedProjects\Shared2022-016\Copy.dta"
tab _merge // oh it works now
rename _merge mrg_1
save Copy, replace

use "R:\Restricted\SSA Administrative Data\Other\SSweights\stata\SSWGTSA_R.dta"
egen hhid_pn = concat(HHID PN)
save Weight1, replace
use "R:\Restricted\SSA Administrative Data\Other\SSweights\stata\SSWGTSF_R.dta"
egen hhid_pn = concat(HHID PN)
merge 1:1 hhid_pn using "R:\SharedProjects\Shared2022-016\Weight1.dta"
rename _merge mrg_2
save Weight1, replace
use "R:\Restricted\SSA Administrative Data\Other\SSweights\stata\SSWGTSJ_R.dta"
egen hhid_pn = concat(HHID PN)
merge 1:1 hhid_pn using "R:\SharedProjects\Shared2022-016\Weight1.dta"
rename _merge mrg_3
merge 1:1 hhid_pn using "R:\SharedProjects\Shared2022-016\Copy.dta"
rename _merge mrg_4
save Copy, replace

use "R:\Public\Contributions\Rand\RandHrs2018V1\stata\randhrs1992_2018v1.dta"
egen hhid_pn = concat(hhid pn)
keep hhid_pn r1agey_b r2agey_b r3agey_b r4agey_b r5agey_b r6agey_b r7agey_b r8agey_b r9agey_b r10agey_b r11agey_b r12agey_b r13agey_b r14agey_b r1mdiv r2mdiv r3mdiv r4mdiv r5mdiv r6mdiv r7mdiv r8mdiv r9mdiv r10mdiv r11mdiv r12mdiv r13mdiv r14mdiv r1mlen r2mlen r3mlen r4mlen r5mlen r6mlen r7mlen r8mlen r9mlen r10mlen r11mlen r12mlen r13mlen r14mlen r1mstath r2mstath r3mstath r4mstath r5mstath r6mstath r7mstath r8mstath r9mstath r10mstath r11mstath r12mstath r13mstath r14mstath
merge 1:1 hhid_pn using "R:\SharedProjects\Shared2022-016\Copy.dta"


* Make a counter for claim year
forvalues y = 62(1)70 {
	gen claimyear_`y' = dob_yr+`y'
}

* make new earnings variable to manipulate
* set earnings after the last year in survey to missing and later project using the CPI
forvalues x = 1951(1)2018{
	gen earn`x' = EARN`x'
	replace earn`x' = . if `x'>lastyr
}

* set missing values before the last year to 0 
forvalues x = 1951(1)2018 {
	replace earn`x' = 0 if earn`x' == . & `x'<= lastyr
}

*** Generate benefits for claiming ages 62-70: ***
* AWI data starts in 1951
* not currently using any predicted AWI numbers from SSA (as far as I am aware) - only ones from 1951 to 2021

matrix AWI = (2799.16, 2973.32, 3139.44, 3155.64, 3301.44, 3532.44, 3532.36, 3641.72, 3673.80, 3855.80, 4007.12, 4086.76, 4291.40, 4396.64, 4576.32, 4658.72, 4938.36, 5213.44, 5571.76, 5893.76, 6186.24, 6497.08, 7133.80, 7580.16, 8030.76, 8630.92, 9226.48, 9779.44, 10556.03, 11479.46, 12513.46, 13773.10, 14531.34, 15239.24, 16135.07, 16822.51, 17321.82, 18426.51, 19334.04, 20099.55, 21027.98, 21811.60, 22935.42, 23132.67, 23753.53, 24705.66, 25913.90, 27426.00, 28861.44, 30469.84, 32154.82, 32921.92, 33252.09, 34064.95, 35648.55, 36952.94, 38651.41, 40405.48, 41334.97, 40711.61, 41673.83, 42979.61, 44321.67, 44888.16, 46481.52, 48098.63, 48642.15, 50321.89, 52145.8, 54099.99, 55628.6, 57646.527, 59737.655, 61904.639, 64150.229, 66477.279, 68888.742, 71387.681, 73977.27, 76660.795, 79441.665)

** Maximum taxable earnings matrix:
*MTE data starts in 1951 (available from 1937)
*Use predicted growth rate of AWI=4% after 2022 until 2053
matrix MTE=(3600, 3600, 3600, 3600, 4200, 4200, 4200, 4200, 4800, 4800, 4800, 4800, 4800, 4800, 4800, 6600, 6600, 7800, 7800, 7800, 7800, 9000, 10800, 13200, 14100, 15300, 16500, 17700, 22900, 25900, 29700, 32400, 35700, 37800, 39600, 42000, 43800, 45000, 48000, 51300, 53400, 55500, 57600, 60600, 61200, 62700, 65400, 68400, 72600, 76200, 80400, 84900, 87000, 87900, 90000, 94200, 97500, 102000, 106800, 106800, 106800, 110100, 113700, 117000, 118500, 118500, 127200, 128400, 132900, 137700, 142800, 147000, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037, 2038, 2039, 2040, 2041, 2042, 2043, 2044, 2045, 2046, 2047, 2048, 2049, 2050, 2051, 2052, 2053) 


*** Index earnings to age 60: ***
* after-60 wages are not indexed.
capture drop numyrs
gen numyrs=0
gen year60 = dob_yr+60
forvalues x=1951(1)2018{
	qui: replace numyrs = numyrs+1 if earn`x'>0 & earn`x'<.
	qui: gen earn_cap`x'=.
	qui: replace earn_cap`x'= earn`x'
	qui: replace earn_cap`x'=MTE[1,`x'-1950] if earn`x'>=MTE[1,`x'-1950]
	qui: gen indearn`x' = earn_cap`x'  
*	indexing doesn't make wages smaller
	qui: replace indearn`x'=indearn`x'*((AWI[1, (year60-1950)])/(AWI[1, `x'-1950])) if `x'<year60 & earn`x'>0
}

count if numyrs == 0 

*** find top 35 years ***
* indexed earnings can be the same
* find rowmax, see how many vars = row max and replace them with a 0. repeat.
* generate indexed earnings until retirement age only (62-70), missing values after.


forvalues y=62(1)70 {
	forvalues x = 1951(1)2018 {
		qui: gen earn_cap`x'_`y'=.
		qui: replace earn_cap`x'_`y' = earn_cap`x' if `x'< claimyear_`y'
		gen indearn`x'_`y' = .
		replace indearn`x'_`y'=indearn`x' if `x'< claimyear_`y'
		gen temp_indearn`x'_`y' = indearn`x'_`y'
	}
}

order temp_indearn*

* this replaces missing earnings after retirement with zero
forvalues y=62(1)70 {
	forvalues x = 1951(1)2018 {
		replace indearn`x'_`y' = 0 if indearn`x'_`y'>=.
		replace temp_indearn`x'_`y' = 0 if temp_indearn`x'_`y'>=.
	}
}

*This makes the variable we'll use to identify the top 35 earnings
forvalues y = 62(1)70 {
	forvalues z=1(1)35 {
		gen maxearn`z'_`y' = 0	
	}
}

* This upcoming chunk creates a "count" variable, identifies the max temp indexed earnings value with earnmax, increases count by however many years the person earned that max amount, replaces the max temp index earnings value(s) with 0, and adds count to total_count, zeroes out count, and repeats the process.

**
forvalues y = 62(1)70 {
	gen total_count_`y' = 0
	gen count_`y' = 0
	local t = 1
	while `t'<36 {
		egen earnmax_`y' = rowmax(temp_indearn*_`y')
		forvalues x = 1951(1)2018 {
			qui: replace total_count_`y' = total_count_`y'+1 if temp_indearn`x'_`y'== earnmax_`y' & earnmax_`y' > 0 & earnmax_`y'<.
			qui: replace temp_indearn`x'_`y' = 0 if temp_indearn`x'_`y' == earnmax_`y' & earnmax_`y'>0 & earnmax_`y'<.
		}
		tab total_count_`y' if `t'>0
		local k = 1
		while `k'<36 {
			qui: replace maxearn`k'_`y'=earnmax_`y' if `k'<= total_count_`y' & `k' > count_`y'
			local k=`k'+1
		}			
		qui: replace count_`y' = total_count_`y'	
		sum earnmax_`y' 
		drop earnmax_`y'
		local t=`t'+1
	}			
}
* Num of years for which earnings is equal to the highest earnings over life, sum for all highest earnings values
	* count is same as total_count, but doesn't include the latest highest earnings value yet	

* We will have people with less than 35 years of earnings histories.
* For them, replace missing earnings with 0s

forvalues y =62(1)70 {
	forvalues z = 1(1)35 {
		sum maxearn`z'_`y'
		sum maxearn`z'_`y' if maxearn`z'_`y' > 0
	}
}
forvalues y=62(1)70 {
	forvalues x=1951(1)2013 {
		drop temp_indearn`x'_`y'
	}
}
		
*** Create AIME ***
order maxearn*

forvalues y = 62(1)70 {
	egen AIME_`y' = rowtotal(maxearn*_`y'), m
	replace AIME_`y' = AIME_`y'/35
* monthly
	replace AIME_`y'=AIME_`y'/12
	*replace AIME_`y'=.
}

*** QUARTERS ***
* Calculate covered quarters

matrix CQ=(50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 250,	260, 290, 310, 340,	370, 390, 410, 440, 460, 470, 500, 520,	540, 570, 590, 620, 630, 640, 670, 700, 740, 780, 830, 870, 890, 900, 920, 970, 1000, 1050, 1090, 1120, 1120, 1130, 1160, 1200, 1220, 1260, 1300, 1320, 1360, 1410, 1470, 1510, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037, 2038, 2039, 2040, 2041, 2042, 2043, 2044, 2045, 2046, 2047, 2048, 2049, 2050, 2051, 2052, 2053)

forvalues y=62(1)70 {
	qui: gen numqrts_`y'=0
}
forvalues y=62(1)70 { 
	forvalues x=1951(1)2013 {    
		qui: replace numqrts_`y'=numqrts_`y'+1 if earn_cap`x'_`y'>0 & earn_cap`x'_`y'<. & earn_cap`x'_`y'>=CQ[1, `x'-1950]
		qui: replace numqrts_`y'=numqrts_`y'+1 if earn_cap`x'_`y'>0 & earn_cap`x'_`y'<. & earn_cap`x'_`y'>=2*CQ[1, `x'-1950]
		qui: replace numqrts_`y'=numqrts_`y'+1 if earn_cap`x'_`y'>0 & earn_cap`x'_`y'<. & earn_cap`x'_`y'>=3*CQ[1, `x'-1950]
		qui: replace numqrts_`y'=numqrts_`y'+1 if earn_cap`x'_`y'>0 & earn_cap`x'_`y'<. & earn_cap`x'_`y'>=4*CQ[1, `x'-1950]
	}
}

forvalues y=62(1)70 {
	sum numqrts_`y' 
}
* The creators of this file previously zeroed out everyone with less than 40 quarters of earnings histories because those people are less than "fully insured". we only are considering those who are fully insured 
forvalues y=62(1)70 {
	qui: replace AIME_`y'=0 if numqrts_`y'<40
	sum AIME_`y'
}


************************
**** Calculate PIA *****
************************

*** Bend Points ***
matrix BP1 = (180, 194, 211, 230, 254, 267, 280, 297, 310, 319, 339, 356, 370, 387, 401, 422, 426, 437, 455, 477, 505, 531, 561, 592, 606, 612, 627, 656, 680, 711, 744, 761, 749, 767, 791, 816, 826, 856, 885, 895, 926, 960, 996, 1024, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037, 2038, 2039, 2040, 2041, 2042, 2043, 2044, 2045)

local growth = 0.04
local startyear=2018
local o =`startyear'-1978
while (`o'<=67){
	matrix BP1[1, `o'-1]=round(BP1[1, `o'-1]*(1+`growth'), 1)
	local o = `o'+1
}

matrix BP2 = (1085, 1171, 1274, 1388, 1528, 1612, 1790, 1866, 1922, 2044, 2145, 2230, 2333, 2420, 2545, 2567, 2635, 2741, 2875, 3043, 3202, 3381, 3567, 3653, 3689, 3779, 3955, 4100, 4288, 4483, 4586, 4517, 4624, 4768, 4917, 4980, 5157, 5336, 5397, 5583, 5785, 6002, 6172, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037, 2038, 2039, 2040, 2041, 2042, 2043, 2044, 2045)

local o = `startyear'-1978
while (`o'<67){
	matrix BP2[1, `o']=round(BP2[1, `o'-1]*(1+`growth'), 1)
	local o = `o'+1
}

*** Calculate PIA from AIME and Bend Points ***
forvalues y = 62(1)70 {
	gen PIA_`y'=AIME_`y'*.90 if AIME_`y'<BP1[1, claimyear_62-1978]
	replace PIA_`y'=((BP1[1, claimyear_62-1978]*0.90)+((AIME_`y'-BP1[1, claimyear_62-1978])*0.32)) if AIME_`y'<=BP2[1, claimyear_62-1978] & AIME_`y'>BP1[1, claimyear_62-1978]
	replace PIA_`y' = ((BP1[1, claimyear_62-1978]*0.90)+((BP2[1, claimyear_62-1978]-BP1[1, claimyear_62-1978])*0.32)+((AIME_`y'-BP2[1, claimyear_62-1978])*0.15)) if AIME_`y' > BP2[1, claimyear_62-1978]
	replace PIA_`y'= round(PIA_`y', 0.1)
}

*** COLAs ***
*Annualize and apply COLAs for years between age 62 and retirement
* COLAs start in 1984 in Tony spreadsheet. 

matrix COLA = (1, 1.064, 1.1268, 1.2, 1.3188, 1.5074, 1.6762, 1.8003, 1.8633, 1.9285, 1.9883, 2.0141, 2.09877, 2.1827, 2.2853, 2.4087, 2.4978, 2.5727, 2.6396, 2.7135, 2.7841, 2.8648, 2.8648, 2.924, 2.963, 3.0371, 3.1434, 3.2251, 3.2703, 3.3389, 3.4291, 3.5697, 3.6875, 3.7723, 3.9911, 3.9911, 3.9911, 4.039, 4.1076, 4.1857, 4.2694, 4.3548, 4.4419, 4.5396, 4.6576, 4.788, 4.9221, 5.0599, 5.2016, 5.3472, 5.497, 5.6509, 5.8091, 5.9718, 6.139, 6.3109, 6.4876, 6.6692, 6.856, 7.0479, 7.2453, 7.4481, 7.6567, 7.8711, 8.0915, 8.318, 8.5504)


** The code below is copied directly from the SS Benefits do file from Tony. I will probably need to modify the startyear. 

local startyear=2041
forvalues y=62(1)70 {
	qui: gen annual_AIME_`y'=AIME_`y'*12
	qui: gen annual_PIA_`y'=PIA_`y'*12
}

* I believe this multiplies each annual PIA by the change from present year to age 62 year.
forvalues y=62(1)70 {
	qui: gen PIA_final_`y'=annual_PIA_`y'*((COLA[1, claimyear_`y'-1974])/(COLA[1, claimyear_62-1974]))
	sum PIA_final_`y'  
}


** making the fake dataset outside the enclave to test this code with:
*clear
*use fifties_prepared_both
*forvalues k = 1(1)14 {
*	replace lastyr = r`k'jlasty if r`k'jlasty<.
*	drop r`k'jlasty
*}
*forvalues x = 1951(1)2018{
*	gen EARN`x' = `x'
*}
*save fake_earnings


** Early and Late retirement credits **

sum dob_yr

*1935-1983
forvalues y = 62(1)70 {
	qui: gen own_perc_`y' = 0
}

* retire at 62
replace own_perc_62 = 0.8 if dob_yr<1938
replace own_perc_62 = ((79+1/6)/100) if dob_yr==1938
replace own_perc_62 = ((78+1/3)/100) if dob_yr==1939
replace own_perc_62 = ((77+1/2)/100) if dob_yr==1940
replace own_perc_62 = ((76+2/3)/100) if dob_yr==1941
replace own_perc_62 = ((75+5/6)/100) if dob_yr==1942
replace own_perc_62 = ((75)/100) if dob_yr>1942 & dob_yr<1955
replace own_perc_62 = ((74+1/6)/100) if dob_yr==1955
replace own_perc_62 = ((73+1/3)/100) if dob_yr==1956
replace own_perc_62 = ((72+1/2)/100) if dob_yr==1957
replace own_perc_62 = ((71+2/3)/100) if dob_yr==1958
replace own_perc_62 = ((70+5/6)/100) if dob_yr==1959
replace own_perc_62 = (70/100) if dob_yr>1959


* retire at 63
replace own_perc_63 = ((86+2/3)/100) if dob_yr<1938
replace own_perc_63 = ((85+5/9)/100) if dob_yr==1938
replace own_perc_63 = ((84+4/9)/100) if dob_yr==1939
replace own_perc_63 = ((83+1/3)/100) if dob_yr==1940
replace own_perc_63 = ((82+2/9)/100) if dob_yr==1941
replace own_perc_63 = ((81+1/9)/100) if dob_yr==1942
replace own_perc_63 = ((80)/100) if dob_yr>1942 & dob_yr<1955
replace own_perc_63 = ((79+1/6)/100) if dob_yr==1955
replace own_perc_63 = ((78+1/3)/100) if dob_yr==1956
replace own_perc_63 = ((77+1/2)/100) if dob_yr==1957
replace own_perc_63 = ((76+2/3)/100) if dob_yr==1958
replace own_perc_63 = ((75+5/6)/100) if dob_yr==1959
replace own_perc_63 = (75/100) if dob_yr>1959

* retire at 64
replace own_perc_64 = ((93+1/3)/100) if dob_yr<1938
replace own_perc_64 = ((92+2/9)/100) if dob_yr==1938
replace own_perc_64 = ((91+1/9)/100) if dob_yr==1939
replace own_perc_64 = ((90)/100) if dob_yr==1940
replace own_perc_64 = ((88+8/9)/100) if dob_yr==1941
replace own_perc_64 = ((87+7/9)/100) if dob_yr==1942
replace own_perc_64 = ((86+2/3)/100) if dob_yr>1942 & dob_yr<1955
replace own_perc_64 = ((85+5/9)/100) if dob_yr==1955
replace own_perc_64 = ((84+4/9)/100) if dob_yr==1956
replace own_perc_64 = ((83+1/3)/100) if dob_yr==1957
replace own_perc_64 = ((82+2/9)/100) if dob_yr==1958
replace own_perc_64 = ((81+1/9)/100) if dob_yr==1959
replace own_perc_64 = (80/100) if dob_yr>1959

* retire at 65
replace own_perc_65 = (100/100) if dob_yr<1938
replace own_perc_65 = ((98+8/9)/100) if dob_yr==1938
replace own_perc_65 = ((97+7/9)/100) if dob_yr==1939
replace own_perc_65 = ((96+2/3)/100) if dob_yr==1940
replace own_perc_65 = ((95+5/9)/100) if dob_yr==1941
replace own_perc_65 = ((94+4/9)/100) if dob_yr==1942
replace own_perc_65 = ((93+1/3)/100) if dob_yr>1942 & dob_yr<1955
replace own_perc_65 = ((92+2/9)/100) if dob_yr==1955
replace own_perc_65 = ((91+1/9)/100) if dob_yr==1956
replace own_perc_65 = ((90)/100) if dob_yr==1957
replace own_perc_65 = ((88+8/9)/100) if dob_yr==1958
replace own_perc_65 = ((87+7/9)/100) if dob_yr==1959
replace own_perc_65 = ((86+2/3)/100) if dob_yr>1959

* retire at 66
replace own_perc_66 = (103/100) if dob_yr<1925
replace own_perc_66 = ((103+1/2)/100) if dob_yr>1924 & dob_yr<1927
replace own_perc_66 = ((104)/100) if dob_yr>1926 & dob_yr<1929
replace own_perc_66 = ((104+1/2)/100) if dob_yr>1928 & dob_yr<1931
replace own_perc_66 = ((105)/100) if dob_yr>1930 & dob_yr<1933
replace own_perc_66 = ((105+1/2)/100) if dob_yr>1932 & dob_yr<1935
replace own_perc_66 = ((106)/100) if dob_yr>1934 & dob_yr<1937
replace own_perc_66 = ((106+1/2)/100) if dob_yr==1937
replace own_perc_66 = ((105+5/12)/100) if dob_yr==1938
replace own_perc_66 = ((104+2/3)/100) if dob_yr==1939
replace own_perc_66 = ((103+1/2)/100) if dob_yr==1940
replace own_perc_66 = ((102+1/2)/100) if dob_yr==1941
replace own_perc_66 = ((101+1/4)/100) if dob_yr==1942
replace own_perc_66 = ((100)/100) if dob_yr>1942 & dob_yr<1955
replace own_perc_66 = ((98+8/9)/100) if dob_yr==1955
replace own_perc_66 = ((97+7/9)/100) if dob_yr==1956
replace own_perc_66 = ((96+2/3)/100) if dob_yr==1957
replace own_perc_66 = ((95+5/9)/100) if dob_yr==1958
replace own_perc_66 = ((94+4/9)/100) if dob_yr==1959
replace own_perc_66 = ((93+1/3)/100) if dob_yr>1959

* retire at 67
replace own_perc_67 = (106/100) if dob_yr<1925
replace own_perc_67 = ((107)/100) if dob_yr>1924 & dob_yr<1927
replace own_perc_67 = ((108)/100) if dob_yr>1926 & dob_yr<1929
replace own_perc_67 = ((109)/100) if dob_yr>1928 & dob_yr<1931
replace own_perc_67 = ((110)/100) if dob_yr>1930 & dob_yr<1933
replace own_perc_67 = ((111)/100) if dob_yr>1932 & dob_yr<1935
replace own_perc_67 = ((112)/100) if dob_yr>1934 & dob_yr<1937
replace own_perc_67 = ((113)/100) if dob_yr==1937
replace own_perc_67 = ((111+11/12)/100) if dob_yr==1938
replace own_perc_67 = ((111+2/3)/100) if dob_yr==1939
replace own_perc_67 = ((110+1/2)/100) if dob_yr==1940
replace own_perc_67 = ((110)/100) if dob_yr==1941
replace own_perc_67 = ((108+3/4)/100) if dob_yr==1942
replace own_perc_67 = ((108)/100) if dob_yr>1942 & dob_yr<1955
replace own_perc_67 = ((106+2/3)/100) if dob_yr==1955
replace own_perc_67 = ((105+1/3)/100) if dob_yr==1956
replace own_perc_67 = ((104)/100) if dob_yr==1957
replace own_perc_67 = ((102+2/3)/100) if dob_yr==1958
replace own_perc_67 = ((101+1/3)/100) if dob_yr==1959
replace own_perc_67 = ((100)/100) if dob_yr>1959

* retire at 68
replace own_perc_68 = (106/100)+0.03 if dob_yr<1925
replace own_perc_68 = ((107)/100)+0.035 if dob_yr>1924 & dob_yr<1927
replace own_perc_68 = ((108)/100)+0.04 if dob_yr>1926 & dob_yr<1929
replace own_perc_68 = ((109)/100)+0.045 if dob_yr>1928 & dob_yr<1931
replace own_perc_68 = ((110)/100)+0.05 if dob_yr>1930 & dob_yr<1933
replace own_perc_68 = ((111)/100)+0.055 if dob_yr>1932 & dob_yr<1935
replace own_perc_68 = ((112)/100)+0.06 if dob_yr>1934 & dob_yr<1937
replace own_perc_68 = ((113)/100)+0.065 if dob_yr==1937
replace own_perc_68 = ((111+11/12)/100)+0.65 if dob_yr==1938
replace own_perc_68 = ((111+2/3)/100)+0.07 if dob_yr==1939
replace own_perc_68 = ((110+1/2)/100)+0.075 if dob_yr==1940
replace own_perc_68 = ((110)/100)+0.075 if dob_yr==1941
replace own_perc_68 = ((108+3/4)/100)+0.075 if dob_yr==1942
replace own_perc_68 = ((108)/100)+0.08 if dob_yr>1942 & dob_yr<1955
replace own_perc_68 = ((106+2/3)/100)+0.08 if dob_yr==1955
replace own_perc_68 = ((105+1/3)/100)+0.08 if dob_yr==1956
replace own_perc_68 = ((104)/100)+0.08 if dob_yr==1957
replace own_perc_68 = ((102+2/3)/100)+0.08 if dob_yr==1958
replace own_perc_68 = ((101+1/3)/100)+0.08 if dob_yr==1959
replace own_perc_68 = ((100)/100)+0.08 if dob_yr>1959

* retire at 69
replace own_perc_69 = (106/100)+2*0.03 if dob_yr<1925
replace own_perc_69 = ((107)/100)+2*0.035 if dob_yr>1924 & dob_yr<1927
replace own_perc_69 = ((108)/100)+2*0.04 if dob_yr>1926 & dob_yr<1929
replace own_perc_69 = ((109)/100)+2*0.045 if dob_yr>1928 & dob_yr<1931
replace own_perc_69 = ((110)/100)+2*0.05 if dob_yr>1930 & dob_yr<1933
replace own_perc_69 = ((111)/100)+2*0.055 if dob_yr>1932 & dob_yr<1935
replace own_perc_69 = ((112)/100)+2*0.06 if dob_yr>1934 & dob_yr<1937
replace own_perc_69 = ((113)/100)+2*0.065 if dob_yr==1937
replace own_perc_69 = ((111+11/12)/100)+2*0.65 if dob_yr==1938
replace own_perc_69 = ((111+2/3)/100)+2*0.07 if dob_yr==1939
replace own_perc_69 = ((110+1/2)/100)+2*0.075 if dob_yr==1940
replace own_perc_69 = ((110)/100)+2*0.075 if dob_yr==1941
replace own_perc_69 = ((108+3/4)/100)+2*0.075 if dob_yr==1942
replace own_perc_69 = ((108)/100)+2*0.08 if dob_yr>1942 & dob_yr<1955
replace own_perc_69 = ((106+2/3)/100)+2*0.08 if dob_yr==1955
replace own_perc_69 = ((105+1/3)/100)+2*0.08 if dob_yr==1956
replace own_perc_69 = ((104)/100)+2*0.08 if dob_yr==1957
replace own_perc_69 = ((102+2/3)/100)+2*0.08 if dob_yr==1958
replace own_perc_69 = ((101+1/3)/100)+2*0.08 if dob_yr==1959
replace own_perc_69 = ((100)/100)+2*0.08 if dob_yr>1959

* retire at 70
replace own_perc_70 = (106/100)+3*0.03 if dob_yr<1925
replace own_perc_70 = ((107)/100)+3*0.035 if dob_yr>1924 & dob_yr<1927
replace own_perc_70 = ((108)/100)+3*0.04 if dob_yr>1926 & dob_yr<1929
replace own_perc_70 = ((109)/100)+3*0.045 if dob_yr>1928 & dob_yr<1931
replace own_perc_70 = ((110)/100)+3*0.05 if dob_yr>1930 & dob_yr<1933
replace own_perc_70 = ((111)/100)+3*0.055 if dob_yr>1932 & dob_yr<1935
replace own_perc_70 = ((112)/100)+3*0.06 if dob_yr>1934 & dob_yr<1937
replace own_perc_70 = ((113)/100)+3*0.065 if dob_yr==1937
replace own_perc_70 = ((111+11/12)/100)+3*0.65 if dob_yr==1938
replace own_perc_70 = ((111+2/3)/100)+3*0.07 if dob_yr==1939
replace own_perc_70 = ((110+1/2)/100)+3*0.075 if dob_yr==1940
replace own_perc_70 = ((110)/100)+3*0.075 if dob_yr==1941
replace own_perc_70 = ((108+3/4)/100)+3*0.075 if dob_yr==1942
replace own_perc_70 = ((108)/100)+3*0.08 if dob_yr>1942 & dob_yr<1955
replace own_perc_70 = ((106+2/3)/100)+3*0.08 if dob_yr==1955
replace own_perc_70 = ((105+1/3)/100)+3*0.08 if dob_yr==1956
replace own_perc_70 = ((104)/100)+3*0.08 if dob_yr==1957
replace own_perc_70 = ((102+2/3)/100)+3*0.08 if dob_yr==1958
replace own_perc_70 = ((101+1/3)/100)+3*0.08 if dob_yr==1959
replace own_perc_70 = ((100)/100)+3*0.08 if dob_yr>1959

forvalues y = 62(1)70 {
	sum own_perc_`y'
}

forvalues y = 62(1)70 {
	qui: gen ss_benefit_`y' = PIA_final_`y'*own_perc_`y'
	sum ss_benefit_`y'
}

* I want tabulations of the benefit amounts. Want to find mean for a particular cohort excluding zeroes

* People's earnings are indexed to two years prion to first year of eligibility
* so these benefit numbers are in terms of that index-year's dollars.
* I need to take them and put them in constant 2018.

matrix CPI = 104.5, 108.3, 110, 114.4, 119.2, 124.9, 132.1, 136.966667, 141.033333, 145.1, 148.86667, 152.866667, 157.666667, 160.9, 163.4, 167.333333, 172.9666667, 176.9, 180.366667, 184.033333, 189.63333, 195.866667, 201.3, 208.6406667, 212.3606667, 215.1393333, 218.5056667, 225.1666667, 229.5573333, 232.828, 235.7823333, 236.7086667, 240.521, 245.7563333, 251.12, 256.198, 259.42

* this puts the benefit amounts in constant 2018 dollars

forvalues y = 62(1)70 {
	qui: gen ss_benconst_`y' = ss_benefit_`y'
	forvalues x=1984(1)2020 {
		qui: replace ss_benconst_`y' = ss_benconst_`y'*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'==year60
	}
}

*** AIME amounts are in terms of the respective person's year60 dollars.
* I need to take them and put them in constant 2018.

forvalues y = 62(1)70 {
	qui: gen AIME_const_`y' = AIME_`y'
}

forvalues x=1984(1)2020 {
	qui: replace AIME_const_62 = AIME_62*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'-2==year60
	qui: replace AIME_const_63 = AIME_63*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'-3==year60
	qui: replace AIME_const_64 = AIME_64*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'-4==year60
	qui: replace AIME_const_65 = AIME_65*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'-5==year60
	qui: replace AIME_const_66 = AIME_66*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'-6==year60
	qui: replace AIME_const_67 = AIME_67*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'-7==year60
	qui: replace AIME_const_68 = AIME_68*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'-8==year60
	qui: replace AIME_const_69 = AIME_69*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'-9==year60
	qui: replace AIME_const_70 = AIME_70*((CPI[1, (2018-1983)])/(CPI[1, `x'-1983])) if `x'-10==year60
}


gen init_claim_age = (doei_yr+(doei_mo/12))-(dob_yr+(dob_mo/12)) if doeibic==1 & doeitob==1 // init claim age ret worker benefit
replace init_claim_age = (doec_yr+(doec_mo/12))-(dob_yr+(dob_mo/12)) if doecbic==1 & doectob==1 &  doeitob!=1 

**# Bookmark #1
* initial claim age hereafter specifically refers to the age at which a respondent first claims their retired worker benefit as a primary.

**# Bookmark #3
replace rounded_init_claim_age = init_claim_age
forvalues y = 1(1)70 {
	forvalues x = 70(-1)1 {
		replace rounded_init_claim_age = `y' if init_claim_age>`y' & init_claim_age<`x'
		replace rounded_init_claim_age = 66 if init_claim_age>66
		drop if init_claim_age<62
	}
}

** Make AIME quartile
* define quartiles sample as those who are "fully insured" and do quartiles by birthyear.
* use the AIME amounts in constant 2018 $.

gen qtile_noSSDI_men = .
gen qtile_wSSDI_men = .

forvalues x = 1900(1)1957 {
	xtile qtile_noSSDI_men_`x' = AIME_const_65 if rounded_init_claim_age<. & AIME_65>0 & AIME_65<. & doeitob==1 & sex==1 & BIRTHYR==`x', n(4)
	replace qtile_noSSDI_men = qtile_noSSDI_men_`x' if doeitob==1 & sex==1 & BIRTHYR==`x'

	xtile qtile_wSSDI_men_`x' = AIME_const_65 if rounded_init_claim_age<. & AIME_65>0 & AIME_65<. & (doeitob==1 | doeitob==2 | doeitob==7 | doeitob==8) & sex==1 & BIRTHYR==`x', n(4) // retired workers are included in this, plus those are the codes for claims related to disability
	replace qtile_wSSDI_men = qtile_wSSDI_men_`x' if (doeitob==1 | doeitob==2 | doeitob==7 | doeitob==8) & sex==1 & BIRTHYR==`x'
}

gen actual_ss_benefit = .

* this identifies their actual ss benefit amount using their actual claim year. 
forvalues y = 62(1)70 {
	replace actual_ss_benefit = ss_benconst_`y' if doei_yr==(dob_yr + rounded_init_claim_age) & doeitob==1
}
* recall that this actual_ss_benefit is in constant 2018 dollars

gen mstat_62 = .

* figuring out marriage status at 62 - for people who aren't exactly 62 and who experience a change in marriage status between the two waves of survey, we can't tell exactly what their marriage status at 62 was.
forvalues k = 1/14 {
	replace mstat_62=r`k'mstath if r`k'agey_b>=60 & r`k'agey_b<=61 & r`k'mstath==r`k+1'mstath // check that k+1 mstat == k mstat
	replace mstat_62=r`k'mstath if r`k'agey_b==62
	replace mstat_62=r`k'mstath if r`k'agey_b>=63 & r`k'agey_b<=69 & r`k'mstath==r`k-1'mstath // check that k=1 mstat == k mstat
}




