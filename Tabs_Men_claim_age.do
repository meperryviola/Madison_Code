*use Copy
gen weight = R1WTSSWR
qui: replace weight = R4WTSSWR if R1WTSSWR==. | R1WTSSWR==0
qui: replace weight = R7WTSSWR if weight==. | weight==0 

* just in case, run this before tabs.
replace rounded_init_claim_age = init_claim_age
forvalues y = 1(1)70 {
	forvalues x = 70(-1)1 {
		qui: replace rounded_init_claim_age = `y' if init_claim_age>`y' & init_claim_age<`x'
		qui: replace rounded_init_claim_age = 66 if init_claim_age>66
		drop if init_claim_age<62
	}
}

****************
** start here **
****************
drop if rounded_init_claim_age<62

*trying to see if this properly excludes those not fullyy insured. 
count if AIME_65==0 & numqrts_65<40
gen notfullyinsured = 0
replace notfullyinsured=1 if AIME_65==0 & numqrts_65<40
keep if notfullyinsured==0

*checking the mean claim age for each quartile 
sum rounded_init_claim_age if qtile_wSSDI_men==1 & sex==1 [aweight=weight] // aime 1 all
sum rounded_init_claim_age if qtile_wSSDI_men==2 & sex==1 [aweight=weight] // aime 2 all
sum rounded_init_claim_age if qtile_wSSDI_men==3 & sex==1 [aweight=weight] // aime 3 all
sum rounded_init_claim_age if qtile_wSSDI_men==4 & sex==1 [aweight=weight] // aime 4 all

* checking the mean birthyear for each quartile
sum BIRTHYR if qtile_wSSDI_men==1 & sex==1 [aweight=weight] // aime 1 all
sum BIRTHYR if qtile_wSSDI_men==2 & sex==1 [aweight=weight]
sum BIRTHYR if qtile_wSSDI_men==3 & sex==1 [aweight=weight]
sum BIRTHYR if qtile_wSSDI_men==4 & sex==1 [aweight=weight]


* open a log file

** Table 1A
* ALL men
* Weighted
tab rounded_init_claim_age if sex==1 [aweight=weight] // all men

tab rounded_init_claim_age if race==1 & sex==1 [aweight=weight] // White men

tab rounded_init_claim_age if race==2 & sex==1 [aweight=weight] // Black men

tab rounded_init_claim_age if race==3 & sex==1 [aweight=weight] // Other men

tab rounded_init_claim_age if qtile_wSSDI_men==1 & sex==1 [aweight=weight] // aime 1 all
tab rounded_init_claim_age if qtile_wSSDI_men==2 & sex==1 [aweight=weight] // aime 2 all
tab rounded_init_claim_age if qtile_wSSDI_men==3 & sex==1 [aweight=weight] // aime 3 all
tab rounded_init_claim_age if qtile_wSSDI_men==4 & sex==1 [aweight=weight] // aime 4 all

** Table 2A
* ALL men, weighted
tab rounded_init_claim_age if sex==1 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

*table 1B
** Non SSDI men, weighted
tab rounded_init_claim_age if sex==1 & doeitob==1 [aweight=weight] // Non-SSDI men
tab rounded_init_claim_age if race==1 & sex==1 & doeitob==1 [aweight=weight] // White men

tab rounded_init_claim_age if race==2 & sex==1 & doeitob==1 [aweight=weight] // Black men

tab rounded_init_claim_age if race==3 & sex==1 & doeitob==1 [aweight=weight] // Other men

tab rounded_init_claim_age if qtile_noSSDI_men==1 & sex==1 & doeitob==1 [aweight=weight] // aime 1 no ssdi
tab rounded_init_claim_age if qtile_noSSDI_men==2 & sex==1 & doeitob==1 [aweight=weight] // aime 2 no ssdi
tab rounded_init_claim_age if qtile_noSSDI_men==3 & sex==1 & doeitob==1 [aweight=weight] // aime 3 no ssdi
tab rounded_init_claim_age if qtile_noSSDI_men==4 & sex==1 & doeitob==1 [aweight=weight] // aime 4 no ssdi

*table 2B
tab rounded_init_claim_age if sex==1 & (mstat_62==1 | mstat_62==2) & doeitob==1 [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) & doeitob==1 [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) & doeitob==1 [aweight=weight] // divorced, <10

* Table 1A - part 2
*** Unweighted, waves 1, 4, 7 - ALL men
tab rounded_init_claim_age if sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59))

tab rounded_init_claim_age if race==1 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // White men

tab rounded_init_claim_age if race==2 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // Black men

tab rounded_init_claim_age if race==3 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // Other men

tab rounded_init_claim_age if qtile_wSSDI_men==1 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 1 all
tab rounded_init_claim_age if qtile_wSSDI_men==2 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 2 all
tab rounded_init_claim_age if qtile_wSSDI_men==3 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 3 all
tab rounded_init_claim_age if qtile_wSSDI_men==4 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 4 all
***

*Table 2A part 2 - all men marriage status unweighted
tab rounded_init_claim_age if sex==1 & (mstat_62==1 | mstat_62==2) & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59))  // married Men
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // divorced, >10
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // divorced, <10

* Table 1B - part 2
*** Unweighted, waves 1, 4, 7 - Non-SSDI Men
tab rounded_init_claim_age if sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 

tab rounded_init_claim_age if race==1 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 // White men

tab rounded_init_claim_age if race==2 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 // Black men

tab rounded_init_claim_age if race==3 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 // Other men

tab rounded_init_claim_age if qtile_noSSDI_men==1 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 // aime 1 Non-SSDI
tab rounded_init_claim_age if qtile_noSSDI_men==2 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 // aime 2 Non-SSDI
tab rounded_init_claim_age if qtile_noSSDI_men==3 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 // aime 3 Non-SSDI
tab rounded_init_claim_age if qtile_noSSDI_men==4 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 // aime 4 Non-SSDI
***
*Table 2B part 2 - Non-SSDI men marriage status unweighted, waves 1, 4, 7 
tab rounded_init_claim_age if sex==1 & (mstat_62==1 | mstat_62==2) & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1  // married Men
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 // divorced, >10
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) & doeitob==1 // divorced, <10


*** Unweighted all waves, all men
tab rounded_init_claim_age if sex==1 // ALL men

tab rounded_init_claim_age if race==1 & sex==1 // White men

tab rounded_init_claim_age if race==2 & sex==1 // Black men

tab rounded_init_claim_age if race==3 & sex==1 // Other men

tab rounded_init_claim_age if qtile_wSSDI_men==1 & sex==1 // aime 1 all
tab rounded_init_claim_age if qtile_wSSDI_men==2 & sex==1 // aime 2 all
tab rounded_init_claim_age if qtile_wSSDI_men==3 & sex==1 // aime 3 all
tab rounded_init_claim_age if qtile_wSSDI_men==4 & sex==1 // aime 4 all
* unweigthed marstat all waves all men
tab rounded_init_claim_age if sex==1 & (mstat_62==1 | mstat_62==2)  // married Men
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) // divorced, >10
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) // divorced, <10


*** Unweighted all cohorts, Non-SSDI men
tab rounded_init_claim_age if sex==1 & doeitob==1 // ALL men

tab rounded_init_claim_age if race==1 & sex==1 & doeitob==1 // White men

tab rounded_init_claim_age if race==2 & sex==1 & doeitob==1 // Black men

tab rounded_init_claim_age if race==3 & sex==1 & doeitob==1 // Other men

tab rounded_init_claim_age if qtile_noSSDI_men==1 & sex==1 & doeitob==1 // aime 1 no ssdi
tab rounded_init_claim_age if qtile_noSSDI_men==2 & sex==1 & doeitob==1 // aime 2 no ssdi
tab rounded_init_claim_age if qtile_noSSDI_men==3 & sex==1 & doeitob==1 // aime 3 no ssdi
tab rounded_init_claim_age if qtile_noSSDI_men==4 & sex==1 & doeitob==1 // aime 4 no ssdi
* unweigthed marstat all waves non-SSDI men
tab rounded_init_claim_age if sex==1 & (mstat_62==1 | mstat_62==2) & doeitob==1 // married Men
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) & doeitob==1 // divorced, >10
tab rounded_init_claim_age if sex==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) & doeitob==1 // divorced, <10



**
*marriage status by race - white
* ALL men, weighted
tab rounded_init_claim_age if sex==1 & race==1 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & race==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & race==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10
*black
tab rounded_init_claim_age if sex==1 & race==2 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & race==2 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & race==2 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10
*other
tab rounded_init_claim_age if sex==1 & race==3 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & race==3 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & race==3 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

* marriage status by aime qtile_wSSDI_men
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==1 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==2 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==2 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==2 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==3 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==3 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==3 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==4 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==4 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==4 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

** Marriage status by race and AIME qtile_wSSDI_men - WHITE
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==1 & race==1 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==1 & race==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==1 & race==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==2 & race==1 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==2 & race==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==2 & race==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==3 & race==1 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==3 & race==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==3 & race==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==4 & race==1 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==4 & race==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
tab rounded_init_claim_age if sex==1 & qtile_wSSDI_men==4 & race==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

** BLACK

** OTHER


