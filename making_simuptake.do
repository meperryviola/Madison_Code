** Making simuptake

** I want to make sure to run all years of ACS sample to get their instate simuptake

forvalues k = 2014/2019 {
	use acs_sample_`k' 
	duplicates drop
	save, replace
	gen kidage_elig = 0
	replace kidage_elig = 1 if yngch<=eligmaxagechild // youngest child lt/et max age served.

	gen fulltime = 0
	replace fulltime =1 if uhrswork >= 30
	gen parttime = 0
	replace parttime = 1 if uhrswork<30 & uhrswork>0

	gen twoparent = 0
	replace twoparent = 1 if hhtype == 1 & ncouples>=1

	* These are tests for eligibility by hours worked
	gen hrs_elig_2par_ft = 0
	replace hrs_elig_2par_ft = 1 if hhtype==1 & twoparent==1 & uhrswork>=eligminworkhrstwoparent & uhrswork>=eligminhoursfulltime //2parent fulltime
	gen hrs_elig_2par_pt = 0
	replace hrs_elig_2par_pt = 1 if hhtype==1 & twoparent==1 & uhrswork>=eligminworkhrstwoparent & uhrswork>=eligminhoursamount // 2parent parttime

	gen hrs_elig_1par_ft = 0 // single, fulltime
	replace hrs_elig_1par = 1 if twoparent==0 & uhrswork>=eligminhoursamount & uhrswork>=eligminhoursfulltime
	gen hrs_elig_1par_pt = 0 // single, parttime
replace hrs_elig_1par_pt = 1 if twoparent==0 & uhrswork>=eligminhoursamount


	gen eligible_by_hoursworked = 0 // making a bigger indicator that shows if they meet ONE of the types of elig fams.
	replace eligible_by_hoursworked = 1 if (hrs_elig_2par_ft==1 | hrs_elig_2par_pt==1 | hrs_elig_1par_ft==1 | hrs_elig_1par_pt==1)

	** household characteristics and calculating the actual amount being considered for income eligibility
	gen mom_income = 0
	replace mom_income = inctot if sex==2 & nchild>=1  
	gen dad_income = 0
	replace dad_income = inctot if sex==1 & nchild>=1


	gen adultnonrel_income = hhinc - ftotinc
	gen relnonparent_income = (hhinc - adultnonrel_income) - (mom_income+dad_income)
		//assert relnonparent_income>=0 // the code will keep running if this is true, else break.

	gen oldersib_income = 0
	replace oldersib_income = relnonparent_income if multgend == 21 & eldch>=14 // no grandparents and a sibling of working age => call all nonparent income as belonging to older sibling.
	replace relnonparent_income = hhinc - oldersib_income // if there's a working sib, nonparent_income goes to zero
	** issue here where these conditions would pick up an adult non-relative's income if there's an older sib nonworking and some other adult non rel who is working. 

	gen grandma_income = 0
	replace grandma_income = relnonparent_income if multgend == 31 // if there's 3+ generations present, instead call all nonparent income as belonging to a grandparent.
	replace relnonparent_income = relnonparent_income - grandma_income // if there's a working grandma, nonparent_income goes to zero & oldersib_income is already zero.

	gen income_considered = hhinc
	//replace income_considered = hhinc if (grandma_income==0 | incnonparentadultrelative==1) & (oldersib_income==0 | (incchild==1 & incchildagecounted<=eldch)) & incnonparentadultnonrelative==1 // full HHinc if no nonparent income to begin with OR if there was but it was fully counted as eligible.
 
	replace income_considered = (hhinc - oldersib_income - grandma_income - relnonparent_income) if incchildagecounted>eldch | incchild!=1 |  incnonparentadultrelative!=1 | incnonparentadultnonrelative!=1 // reduced HHinc if any of the things is nonzero and counted out.

	gen teenparent = 0 
	replace teenparent = 1 if age<=famteenparentdef
	replace income_considered = (income_considered - inctot) if (teenparent==1 & incteenparent==2)

	replace incdisregard = (incdisregard*income_considered) if incdisregardtype==1 // converts percentages to a number i can subtract
	replace income_considered = (income_considered - incdisregard) if incdisregard>=0 // subtracts disregarded dollar amount from the considered income amount.


	* Is the Welfare benefit income generally excluded from the amount considered?? 
	** Assuming that incwelfr is tanf if no disability status and IncSSDI if yes disability status**

	gen disabled = 0
	replace disabled = 1 if (vetdisab==1 | diffrem==1 | diffphys==1 | diffmob==1 | diffcare==1 | diffsens==1)

	replace income_considered = (income_considered - incwelfr) if disabled==0 & (inctanf==2 | incgeneralassistance==2 | incssi==2 | foodstmp==1 & incvaluesnapbenefits==2) // if not disabled but one of these types is noncounted (we can't tell exactly what type of welfare they recieve, but it's one of these).
	replace income_considered = (income_considered - incwelfr) if disabled==1 & incssdi==2 // if disabled and SSDI benefits are excluded from count. 


	* put it in monthy amount 
	gen income_cons_monthly = income_considered/12 // makes the monthly amount. this is what we'll calculate eligibility from. 


	** matching income with family size.
	gen famsize_considered = famsize
	replace famsize_considered = (famsize - 1) if eldch>=fammaxagesib & fammaxagesib>0

	gen elig_by_income = 0 
	forvalues h=1/10 {
		replace elig_by_income = 1 if famsize_considered==`h' & income_cons_monthly<=eligfamsize`h'
			}

	* eligibility based on non-work activities
	** for students
	gen schoollevel = 0 // reflects current maximum level of school achieved.
	replace schoollevel = 1 if gradeattd<=54 & gradeattd!=0
	replace schoollevel = 2 if gradeattd>54 & gradeattd<=60
	replace schoollevel = 3 if gradeattd>=70

	gen elig_emp_act = 0
	replace elig_emp_act = 1 if (eligapproveactivityemployment==1 & empstat==1) | (eligapproveactivityhighschool==1 & school==2 & schoollevel==1) | (eligapproveactivitypostseced==1 & school==2 & (schoollevel == 2 | schoollevel==3))

	gen elig_elderly = 0
	replace elig_elderly=1 if eligminageparent>0 & age>=eligminageparent 

		//gen homeless = 0
		//replace homeless=1 if mortgage==0 & rentgrs==0 & valueh==9999999 // this might not really be the right way to interpret those things though. Not clear if those people are actually homeless.

	** eligibility for the unemployed
	gen maxtime_wks = eligmaxtimejobsearch
	replace maxtime_wks = eligmaxtimejobsearch/168 if eligmaxtimejobsearchunit==1
	replace maxtime_wks = eligmaxtimejobsearch/7 if eligmaxtimejobsearchunit==2
	replace maxtime_wks = eligmaxtimejobsearch*3.5 if eligmaxtimejobsearchunit==4
	replace maxtime_wks = 0 if eligmaxtimejobsearchunit==92

	replace elig_emp_act=1 if (eligapproveactivityjobsearch==1 & looking==2 & labforce==2 & (eligmaxtimejobsearch==-1 | eligmaxtimejobsearch==-2)) // looking, no binding time limits.

	replace elig_emp_act=1 if (eligapproveactivityjobsearch==1 & looking==2 & labforce==2 & (52-wkswork2)<=maxtime_wks) // looking, DNW for less than the max # of weeks last year.

	replace elig_emp_act = 1 if school==2 & schoollevel==1 & eligfulltimehighschoolwork>0 & uhrswork>=eligfulltimehighschoolwork // if HSers must work, works more than minimum hours.
	replace elig_emp_act = 1 if school==2 & (schoollevel == 2 | schoollevel==3) & eligfulltimepostsecondarywork>0 & uhrswork>=eligfulltimepostsecondarywork // if PSS must work, works more than minimum hours.


	** collect all eligibility markers

	gen simuptake = 0
	replace simuptake = 1 if kidage_elig==1 & elig_by_income==1 & (elig_emp_act==1 | eligible_by_hoursworked==1 | elig_elderly==1)
	save, replace	
}


forvalues k = 2009/2019 {
	use psimelig_`k'
	merge 1:m statefip using acs_sample_`k', nogenerate
	save elig_upt_merged_`k'
}

forvalues k = 2009/2019 {
	forvalues m = 1/56 {
		use elig_upt_merged_`k'
		sum simuptake if dupcount==`m' & year == `k'
		egen prop_simuptake_`m'_`k' = mean(simuptake) if dupcount==`m' & year==`k'
		keep prop_simuptake_`m'_`k' year statefip dupcount
		duplicates drop
		keep if dupcount==`m'
		save simupt_`m'_`k', replace
	}
}

**  This appends my simupt elig files so that I can have one. 
forvalues k = 2009/2019 {
	use simupt_1_`k'
	keep if dupcount==1
	save simupt_`k', replace
	forvalues m = 2/56 {
		use simupt_`m'_`k'
		keep if dupcount==`m'
		append using simupt_`k'
		save simupt_`k', replace
	}
}
use simupt_2009
save simupt, replace
forvalues k = 2010/2019 {
	use simupt_`k'
	append using simupt
	save simupt, replace
}
	
** then I want to merge the allyears ACS sample with allyears rules with psimelig 

forvalues k = 2009/2019 {
	use simupt_`k'
	merge 1:m statefip using elig_upt_merged_`k', nogenerate
	save elig_upt_merged_`k', replace
}

*** combining the simupt vars into one for the whole country
forvalues k = 2009/2019 {
	use elig_upt_merged_`k'
	gen prop_simupt = 0
	forvalues m=1/56 {
		replace prop_simupt = prop_simuptake_`m'_`k' if dupcount==`m'
	}
	save, replace
}
* getting rid of the state-specific simupt vars
forvalues k = 2009/2019 {
	use elig_upt_merged_`k'
	forvalues m=1/56 {
		drop prop_simuptake_`m'_`k'
	}
	save, replace
}

** I would like to append all the years together so I can have one single set on which to run the regressions.

use elig_upt_merged_2009
save full_elig_upt
forvalues k = 2010/2019 {
	use elig_upt_merged_`k'
	append using full_elig_upt
	save full_elig_upt, replace
}

* then I'm ready to run the regressions - see "running_regs"
