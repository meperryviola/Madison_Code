** making time variable 

* Note: date is in "2010 - Jan" form currently

split date
drop date2
rename date1 year
destring year, replace
rename date3 month_str
gen month = .
replace month = 1 if month_str=="Jan"
replace month = 2 if month_str=="Feb"
replace month = 3 if month_str=="Mar"
replace month = 4 if month_str=="Apr"
replace month = 5 if month_str=="May"
replace month = 6 if month_str=="Jun"
replace month = 7 if month_str=="Jul"
replace month = 8 if month_str=="Aug"
replace month = 9 if month_str=="Sep"
replace month = 10 if month_str=="Oct"
replace month = 11 if month_str=="Nov"
replace month = 12 if month_str=="Dec"

g t = ym(year, month)

format t %tm

tsset t

