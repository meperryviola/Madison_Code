cd "C:\Dropbox\Dropbox\Phil Research Dropbox\Madison Perry\Madison_shared\macro_labor"


import excel "C:\Dropbox\Dropbox\Phil Research Dropbox\Madison Perry\Madison_shared\macro_labor\recession_dates.xlsx", clear firstrow
rename excel_last date
g month = month(date)
g year = year(date)
g day = day(date)
drop if date==.
g yearmth = ym(year, month)
format yearmth %tm
sort yearmth

destring RECESSM2USECON, gen(recess)
keep yearmth recess date
save recession_dates, replace


merge 1:1 yearmth using initclaims_urate_series, nogen
order yearmth
g month = month(date)
g year = year(date)

** identify first month of recession 
g firstmo = (recess[_n]==1 & recess[_n-1]==0)

g sixprior = (firstmo[_n+6]==1)
g rec_count = sum(sixprior) 

** mark all observations that take place within a year of a recession beginning
g l1 = (firstmo[_n-1]==1)
g l2 = (firstmo[_n-2]==1)
g l3 = (firstmo[_n-3]==1)
g l4 = (firstmo[_n-4]==1)
g l5 = (firstmo[_n-5]==1)
g l6 = (firstmo[_n-6]==1)
g l7 = (firstmo[_n-7]==1)
g l8 = (firstmo[_n-8]==1)
g l9 = (firstmo[_n-9]==1)
g l10 = (firstmo[_n-10]==1)
g l11 = (firstmo[_n-11]==1)
g l12 = (firstmo[_n-12]==1)

g inyear = firstmo
forvalues i = 1/12 {
	replace inyear = l`i' if inyear==0
}

forvalues i = 1/12 {
	drop l`i'
}

** make a combined variable marking all observations falling between 6 months prior to the start of a recession and 12 months after the start of a recession 
g l1 = (sixprior[_n-1]==1)
g l2 = (sixprior[_n-2]==1)
g l3 = (sixprior[_n-3]==1)
g l4 = (sixprior[_n-4]==1)
g l5 = (sixprior[_n-5]==1)

g ingraph = sixprior 
forvalues i = 1/5 {
	replace ingraph = l`i' if ingraph==0
}
replace ingraph = inyear if ingraph==0
forvalues i = 1/5 {
	drop l`i'
}


tsset yearmth
** check that the time period graphed is correct
tsline urate if ingraph==1 & rec_count==1


** now make the indexes for initial claims 

forvalues i = 1/12 {
	g temp_base`i' = initclaims if (sixprior==1 & rec_count==`i')
	egen base`i' = total(temp_base`i')
	g index`i' = 100*(initclaims/base`i') // THIS IS AN INDEX
	g ppt`i' = (index`i' - 100) // THIS IS PERCENT CHANGED
}


** test with one of the recessions
tsline index8 if ingraph==1 & rec_count==8
tsline ppt8 if ingraph==1 & rec_count==8





** make the ppt difference for unem rate 
forvalues i = 1/12 {
	g temp_ubase`i' = urate if (sixprior==1 & rec_count==`i')
	egen ubase`i' = total(temp_ubase`i')
	g uindex`i' = 100*(urate/ubase`i') // This is an index
	g udif`i' = urate - ubase`i' // this is simple difference in the unemployment rate
	g uppt`i' = uindex`i' - 100 // This is percent changed
}

** test with one of the recessions
// tsline udif8 if ingraph==1 & rec_count==8
tsline uindex8 if ingraph==1 & rec_count==8
tsline uppt8 if ingraph==1 & rec_count==8

graph twoway ///
	(area recess yearmth if ingraph==1 & rec_count==8, color(gs14)) ///
	(tsline index8 if ingraph==1 & rec_count==8, yaxis(1) ytitle("Index", axis(1))) ///
	(tsline uindex8 if ingraph==1 & rec_count==8)
** problem with this is that the area command doesn't make the recession shading rectangular	
	
	
g upper = .
	
** label the variables 
label variable recess "Recession"
forvalues i = 1/12{
	label variable index`i' "Initial Claims"
	label variable uindex`i' "Unemployment Rate"
}
label variable yearmth "Month"
label variable upper "Recession"

** make a loop to generate the graphs 


forvalues i = 5/11 {
	
	summarize uindex`i' if ingraph==1 & rec_count==`i', meanonly
	local umax = 5 * ceil(r(max)/5)
	local umin = 5 * floor(r(max)/5)
	display "`umax' `umin'"
	
	summarize index`i' if ingraph==1 & rec_count==`i', meanonly
	local cmax = 5 * ceil(r(max)/5)
	local cmin = 5 * floor(r(max)/5)
	display "`cmax' `cmin'"
	
	local max = max(`umax', `cmax')
	local min = min(`umin', `cmin')
	display "`max' `min'"
	local max = `max'
	display "`max' `min'"
	replace upper = `max' if recess==1 & rec_count==`i'
	
	
	graph twoway ///
	(line upper yearmth if ingraph==1 & rec_count==`i' & recess==1, recast(area) color(gs14)  plotregion(margin(zero)) base(90) yaxis(1)) ///
	(tsline index`i' if ingraph==1 & rec_count==`i' & index`i'<=`max', yaxis(1) ytitle("Index", axis(1)) ylab(90 (10) `max')) ///
	(tsline uindex`i' if ingraph==1 & rec_count==`i' & uindex`i'<=`max')
	replace upper =.
	
	graph export "claims_urate_rec`i'.png", replace
}

** the 12th recession is displaying weirdly so I need to tweak it manually
forvalues i = 12/12 {
	
	summarize uindex`i' if ingraph==1 & rec_count==`i', meanonly
	local umax = 5 * ceil(r(max)/5)
	local umin = 5 * floor(r(max)/5)
	display "`umax' `umin'"
	
	summarize index`i' if ingraph==1 & rec_count==`i', meanonly
	local cmax = 5 * ceil(r(max)/5)
	local cmin = 5 * floor(r(max)/5)
	display "`cmax' `cmin'"
	
	local max = max(`umax', `cmax')
	local min = min(`umin', `cmin')
	display "`max' `min'"
	local max = `max'
	display "`max' `min'"
	replace upper = `max' if recess==1 & rec_count==`i'
	
	
	graph twoway ///
	(line upper yearmth if ingraph==1 & rec_count==`i' & recess==1, recast(area) color(gs14)  plotregion(margin(zero)) base(90) yaxis(1)) ///
	(tsline index`i' if ingraph==1 & rec_count==`i' & index`i'<=`max', yaxis(1) ytitle("Index", axis(1)) ylab(100 (100) `max')) ///
	(tsline uindex`i' if ingraph==1 & rec_count==`i' & uindex`i'<=`max')
	replace upper =.
	
	graph export "claims_urate_rec`i'.png", replace
}










//
// forvalues i = 1/1 {
//	
// 	summarize udif`i' if ingraph==1 & rec_count==`i', meanonly
// 	local umax = 5 * ceil(r(max)/5)
// 	local umin = 5 * floor(r(max)/5)
// 	display "`umax' `umin'"
//	
// 	summarize ppt`i' if ingraph==1 & rec_count==`i', meanonly
// 	local cmax = 5 * ceil(r(max)/5)
// 	local cmin = 5 * floor(r(max)/5)
// 	display "`cmax' `cmin'"
//	
// 	local max = max(`umax', `cmax')
// 	local min = min(`umin', `cmin')
// 	display "`max' `min'"
//	
// 	replace upper = `max' if recess==1 & rec_count==`i'
//	
// 	graph twoway ///
// 	(line upper yearmth if ingraph==1 & rec_count==`i' & recess==1, recast(area) color(gs14)  plotregion(margin(zero)) base(`min')) ///
// 	(tsline ppt`i' if ingraph==1 & rec_count==`i', yaxis(1) ytitle("Percentage point growth", axis(1)) ysc(titlegap(2) r(`min' `cmax'))) ///
// 	(tsline udif`i' if ingraph==1 & rec_count==`i', yaxis(2) ytitle("Percentage point growth", axis(2)) ysc(titlegap(2) r(`min' `umax')))
// }
//            
//
// ** Recession 1
// 	replace upper = 4 if recess==1 & rec_count==1
//
//	
// 	graph twoway ///
// 	(line upper yearmth if ingraph==1 & rec_count==1 & recess==1, recast(area) color(gs14)  plotregion(margin(zero)) base(-4)) ///
// 	(tsline udif1 if ingraph==1 & rec_count==1, ytitle("Percentage point growth") ylabel(-4(2)2))
//	
// 	replace upper =.
//			
//		
// ** Recession 2
// 	replace upper = 0 if recess==1 & rec_count==2
//
// 	graph twoway ///
// 	(line upper yearmth if ingraph==1 & rec_count==2 & recess==1, recast(area) color(gs14)  plotregion(margin(zero)) base(-6)) ///
// 	(tsline udif1 if ingraph==1 & rec_count==2, ytitle("Percentage point growth") ylabel(-6(2)0))
//	
// 	replace upper =.
//
//	
// ** Recession 3
// 	replace upper = 2 if recess==1 & rec_count==3
//
// 	graph twoway ///
// 	(line upper yearmth if ingraph==1 & rec_count==3 & recess==1, recast(area) color(gs14)  plotregion(margin(zero)) base(-4)) ///
// 	(tsline udif1 if ingraph==1 & rec_count==3, ytitle("Percentage point growth") ylabel(-4(2)2))
//	
// 	replace upper =.
//
//
// ** Recession 4
// 	replace upper = 2 if recess==1 & rec_count==4
//
// 	graph twoway ///
// 	(line upper yearmth if ingraph==1 & rec_count==4 & recess==1, recast(area) color(gs14)  plotregion(margin(zero)) base(-4)) ///
// 	(tsline udif8 if ingraph==1 & rec_count==4, ytitle("Percentage point growth") ylabel(-4(2)2))
//	
// 	replace upper =.
//
// ** Recession 5
// 	replace upper = 1 if recess==1 & rec_count==5
//	
// 	graph twoway ///
// 	(line upper yearmth if ingraph==1 & rec_count==5 & recess==1, recast(area) color(gs14)  plotregion(margin(zero)) base(-4)) ///
// 	///
// 	(tsline udif8 if ingraph==1 & rec_count==5, yaxis(1) ytitle("Percentage point growth", axis(1)) ylabel(-4(1)1)) ///
// 	(tsline 8 if ingraph==1 & rec_count==5, yaxis(1) ytitle("Percentage point growth", axis(1)) ylabel(-4(1)1))
//
// replace upper==.
//
//
//
//
//
// 	summarize udif8 if ingraph==1 & rec_count==1, meanonly
// 	local umax = 5 * ceil(r(max)/5)
// 	local umin = 5 * floor(r(max)/5)
// 	display "`umax' `umin'"
//	
// 	summarize ppt8 if ingraph==1 & rec_count==1, meanonly
// 	local cmax = 5 * ceil(r(max)/5)
// 	local cmin = 5 * floor(r(max)/5)
// 	display "`cmax' `cmin'"
//	
// 	local max = max(`umax', `cmax')
// 	local min = min(`umin', `cmin')
// 	display "`max' `min'"
//	
// 	replace upper = `max' if recess==1 & rec_count==1
//	
//	
// 	graph twoway ///
// 	(line upper yearmth if ingraph==1 & rec_count==1 & recess==1, recast(area) color(gs14)  plotregion(margin(zero)) base(-2)) ///
// 	(tsline ppt8 if ingraph==1 & rec_count==`i', yaxis(1) ytitle("Percentage point growth", axis(1)) ysc(titlegap(2) r(-2 10))) ///
// 	(tsline udif8 if ingraph==1 & rec_count==`i', yaxis(2) ytitle("Percentage point growth", axis(2)))
// 	replace upper =.
//			