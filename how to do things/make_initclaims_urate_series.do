cd "C:\Dropbox\Dropbox\Phil Research Dropbox\Madison Perry\Madison_shared\macro_labor"

import excel "C:\Dropbox\Dropbox\Phil Research Dropbox\Madison Perry\Madison_shared\macro_labor\weeklyinitclaims.xlsx", clear firstrow
rename week date
// rename B initclaims

g month = month(date)
g year = year(date)
g day = day(date)

// collapse (mean) initclaims, by(month year)

g yearmth = ym(year, month)
format yearmth %tm

sort yearmth


g distance = day-12
g flag = (distance>=0 & distance<=6)

preserve 
keep if flag
rename date date_claims
save initclaims_weekpull, replace
restore

import excel urate.xlsx, firstrow clear
rename excel_last date
g month = month(date)
g year = year(date)
g day = day(date)
g yearmth = ym(year, month)
format yearmth %tm
drop if yearmth==.
rename date date_urate

destring RA16EMPL, gen(urate)
merge 1:1 yearmth using initclaims_weekpull



sort yearmth
keep yearmth initclaims claims_4wkavg urate

order yearmth urate initclaims
save initclaims_urate_series, replace