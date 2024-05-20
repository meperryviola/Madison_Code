cd "C:\Dropbox\Dropbox\Phil Research Dropbox\Madison Perry\Madison_shared\macro_labor"


import excel "C:\Dropbox\Dropbox\Phil Research Dropbox\Madison Perry\Madison_shared\macro_labor\monthly_flows.xlsx", clear firstrow
drop if excel_last=="" | excel_last==".excel_last"


destring  estock_sa estock_nsa ustock_sa ustock_nsa nstock_sa nstock_nsa e2e_sa u2e_sa n2e_sa o2e_sa e2u_sa u2u_sa n2u_sa o2u_sa e2n_sa u2n_sa n2n_sa o2n_sa e2o_sa u2o_sa n2o_sa e2e_nsa u2e_nsa n2e_nsa o2e_nsa e2u_nsa u2u_nsa n2u_nsa o2u_nsa e2n_nsa u2n_nsa n2n_nsa o2n_nsa e2o_nsa u2o_nsa n2o_nsa, replace

g date = date(excel_last, "DMY")

g month = month(date)
g year = year(date)
g day = day(date)

g yearmth = ym(year, month)
format yearmth %tm
sort yearmth

drop A excel_last
order yearmth year month day 

rename yearmth yearmth1

g month0 = month - 1
g year0 = year 
replace year0 = year-1 if month0==0
replace month0 = 12 if month0 ==0
rename month month1
g yearmth0 = ym(year0, month0)
format yearmth0 %tm

order yearmth0 yearmth1 year month0 month1 day 

save flow_series, replace
