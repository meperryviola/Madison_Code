* Running regressions
 
* here I am cutting down my dataset bc it doesn't want to run on the huge thing.
use full_elig_upt

keep year dupcount statefip simelig simuptake prop_simelig hhtype hhincome foodstmp ncouples famunit famsize nchild nchlt5 eldch yngch sex age multgend marst birthyr race hispan school educ empstat uhrswork incwage poverty avgmhhinc prop_simupt simuptake 

** making interaction terms 
gen yearxage = year*age
gen yearxstate = year*statefip
gen statexage = statefip*age

** employment outcomes
gen employed = 0
replace employed = 1 if empstat==1
gen unemployed = 0 
replace unemployed = 1 if empstat ==2
gen out_of_lf = 0
replace out_of_lf = 1 if empstat==3

gen inschool = 0
replace inschool = 1 if school==2

gen snapelig=0
forvalues m = 2/10 {
		replace snapelig = 1 if famsize == `m' & hhincome <= 1.2*maxfoodstmp`m'
}

* This part, I used CPI 1999 to get the dollars in 1999 dollars and then put all of those in 2019 dollars - don't remember which data file CPI 99 is, but I just merged it with the same using one and renamed the file "for_regs"


gen hhinc99 = hhincome*cpi99
gen hhinc2019 = hhinc99*1.535
rename hhinc2019 adj_hhinc

gen incwage99 = incwage*cpi99
gen incwage2019 = incwage99*1.535
rename incwage2019 adj_incwage

* use for_regs

** Non-IV - Linear Probability Model using imputed own-state eligibility.
* continuous
* hhincome
reg adj_hhinc simuptake year yearxage statexage statefip yngch i.race age sex i.marst hispan 
* incwage
reg adj_incwage simuptake year yearxage statexage statefip yngch i.race age sex i.marst hispan
*uhrswork
reg uhrswork simuptake year yearxage statexage statefip yngch i.race age sex i.marst hispan
** categorical 
reg employed simuptake year statefip yngch i.race age sex i.marst hispan
reg unemployed simuptake year statefip yngch i.race age sex i.marst hispan
reg out_of_lf simuptake year statefip yngch i.race age sex i.marst hispan

reg foodstmp simuptake year yearxage statexage statefip yngch i.race age sex i.marst hispan 

reg inschool simuptake year yearxage statexage statefip yngch i.race age sex i.marst hispan 

**********

* BINARY - use logit
* empstat
mlogit empstat simuptake year yearxage statexage statefip yngch i.race age sex i.marst hispan 

* food stamp participation
logit foodstmp simuptake year yearxage statexage statefip yngch i.race age sex i.marst hispan 

* school
logit inschool simuptake year yearxage statexage statefip yngch i.race age sex i.marst hispan


*********** IV
* iv full timescale

ivregress 2sls adj_hhinc year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig)

ivregress 2sls employed year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig)

ivregress 2sls unemployed year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig)

ivregress 2sls out_of_lf year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig)

ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig)

ivregress 2sls uhrswork year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig)

ivregress 2sls adj_incwage year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig)

ivregress 2sls inschool year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig)



********** IV Pre-2014 and Post-2014
** Pre-2014
ivregress 2sls adj_hhinc year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan birthyr (prop_simupt = prop_simelig) if year<2014

ivregress 2sls employed year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014

ivregress 2sls unemployed year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014

ivregress 2sls out_of_lf year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014

ivregress 2sls foodstmp year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 // not significant

ivregress 2sls uhrswork year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014

ivregress 2sls adj_incwage year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014

ivregress 2sls inschool year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014
 
** Post-2014
ivregress 2sls adj_hhinc year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan birthyr (prop_simupt = prop_simelig) if year>=2014

ivregress 2sls employed year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014

ivregress 2sls unemployed year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014

ivregress 2sls out_of_lf year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014

ivregress 2sls foodstmp year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 // not significant

ivregress 2sls uhrswork year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014

ivregress 2sls adj_incwage year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014

ivregress 2sls inschool year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014

*******

** Women

ivregress 2sls adj_hhinc year yearxage statexage statefip yngch i.race age sex i.marst hispan birthyr (prop_simupt = prop_simelig) if year<2014 & sex==2

ivregress 2sls employed year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & sex==2
ivregress 2sls unemployed year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & sex==2
ivregress 2sls out_of_lf year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & sex==2

ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & sex==2 // not significant

ivregress 2sls uhrswork year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & sex==2

ivregress 2sls adj_incwage year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & sex==2

ivregress 2sls inschool year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & sex==2

** Post-2014
ivregress 2sls adj_hhinc year yearxage statexage statefip yngch i.race age sex i.marst hispan birthyr (prop_simupt = prop_simelig) if year>=2014 & sex==2

ivregress 2sls employed year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2
ivregress 2sls unemployed year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2
ivregress 2sls out_of_lf year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2

ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2 // not significant

ivregress 2sls uhrswork year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2

ivregress 2sls adj_incwage year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2

ivregress 2sls inschool year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2

** Black
ivregress 2sls adj_hhinc year yearxage statexage statefip yngch i.race age sex i.marst hispan birthyr (prop_simupt = prop_simelig) if year<2014 & race==2

ivregress 2sls employed year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & race==2
ivregress 2sls unemployed year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & race==2
ivregress 2sls out_of_lf year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & race==2


ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & race==2 // not significant

ivregress 2sls uhrswork year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & race==2

ivregress 2sls adj_incwage year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & race==2

ivregress 2sls inschool year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year<2014 & race==2

** Post-2014
ivregress 2sls adj_hhinc year yearxage statexage statefip yngch i.race age sex i.marst hispan birthyr (prop_simupt = prop_simelig) if year>=2014 & race==2

ivregress 2sls employed year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & race==2
ivregress 2sls unemployed year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & race==2
ivregress 2sls out_of_lf year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & race==2

ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & race==2 // not significant

ivregress 2sls uhrswork year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & race==2

ivregress 2sls adj_incwage year yearxage statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & race==2

ivregress 2sls inschool year yearxage yearxstate statexage statefip yngch i.race age sex i.marst hispan (prop_simupt = prop_simelig) if year>=2014 & race==2


** married women:
ivregress 2sls adj_hhinc year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==2 & marst==1

ivregress 2sls employed year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==2 & marst==1

ivregress 2sls foodstmp year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==2 & marst==1 // not significant

ivregress 2sls uhrswork year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==2 & marst==1

ivregress 2sls adj_incwage year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==2 & marst==1

ivregress 2sls inschool year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==2 & marst==1


** Post-2014
ivregress 2sls adj_hhinc year yearxage yearxstate statexage statefip yngch i.race age sex hispan birthyr (prop_simupt = prop_simelig) if year>=2014 & sex==2 & marst==1

ivregress 2sls employed year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2 & marst==1

ivregress 2sls foodstmp year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2 & marst==1 // not significant

ivregress 2sls uhrswork year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2 & marst==1

ivregress 2sls adj_incwage year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2 & marst==1

ivregress 2sls inschool year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==2 & marst==1


** married men:
ivregress 2sls adj_hhinc year yearxage yearxstate statexage statefip yngch i.race age sex hispan birthyr (prop_simupt = prop_simelig) if year<2014 & sex==1 & marst==1

ivregress 2sls employed year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==1 & marst==1

ivregress 2sls foodstmp year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==1 & marst==1 // not significant

ivregress 2sls uhrswork year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==1 & marst==1

ivregress 2sls adj_incwage year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==1 & marst==1

ivregress 2sls inschool year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year<2014 & sex==1 & marst==1

** Post-2014
ivregress 2sls adj_hhinc year yearxage yearxstate statexage statefip yngch i.race age sex hispan birthyr (prop_simupt = prop_simelig) if year>=2014 & sex==1 & marst==1

ivregress 2sls employed year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==1 & marst==1

ivregress 2sls foodstmp year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==1 & marst==1 // not significant

ivregress 2sls uhrswork year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==1 & marst==1

ivregress 2sls adj_incwage year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==1 & marst==1

ivregress 2sls inschool year yearxage yearxstate statexage statefip yngch i.race age sex hispan (prop_simupt = prop_simelig) if year>=2014 & sex==1 & marst==1


** summary statistics:

sum adj_hhinc

sum employed
sum unemployed
sum out_of_lf
sum foodstmp

sum uhrswork

sum adj_incwage

sum inschool

sort year
by year: sum prop_simelig 
by year: egen avg_psimelig = mean(prop_simelig)


** graphing
twoway (line prop_simupt year, lcolor(blue)) (line prop_simelig year, lcolor(green)) if statefip == 1, xlabel(#10)


twoway (line prop_simupt year, lcolor(blue)) (line prop_simelig year, lcolor(green)) if statefip == 42, xlabel(#10)

tab prop_simupt if statefip==6 & year == 2019


** Analysis 5.2

ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig) if snapelig==1


ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig) if snapelig==1 & sex==2

ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig) if snapelig==1 & race==2

ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig) if snapelig==1 & marst==1 & sex==2

ivregress 2sls foodstmp year yearxage statexage statefip yngch i.race age sex i.marst hispan (simuptake = prop_simelig) if snapelig==1 & marst==1 & sex==1

