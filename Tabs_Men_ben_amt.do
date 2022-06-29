** Weighted
sum actual_ss_benefit if sex==1 [aweight=weight] // all men

sum actual_ss_benefit if sex==1 & doeitob==1 [aweight=weight] // Non-SSDI men

sum actual_ss_benefit if race==1 & sex==1 [aweight=weight] // White men

sum actual_ss_benefit if race==2 & sex==1 [aweight=weight] // Black men

sum actual_ss_benefit if race==1 & sex==1 [aweight=weight] // Other men

sum actual_ss_benefit if qtile_wSSDI_men==1 & sex==1 [aweight=weight] // aime 1 all
sum actual_ss_benefit if qtile_wSSDI_men==2 & sex==1 [aweight=weight] // aime 2 all
sum actual_ss_benefit if qtile_wSSDI_men==3 & sex==1 [aweight=weight] // aime 3 all
sum actual_ss_benefit if qtile_wSSDI_men==4 & sex==1 [aweight=weight] // aime 4 all

sum actual_ss_benefit if qtile_noSSDI_men==1 & sex==1 [aweight=weight] // aime 1 no ssdi
sum actual_ss_benefit if qtile_noSSDI_men==2 & sex==1 [aweight=weight] // aime 2 no ssdi
sum actual_ss_benefit if qtile_noSSDI_men==3 & sex==1 [aweight=weight] // aime 3 no ssdi
sum actual_ss_benefit if qtile_noSSDI_men==4 & sex==1 [aweight=weight] // aime 4 no ssdi


sum actual_ss_benefit if sex==1 & (mstat_62==1 | mstat_62==2) [aweight=weight]  // married Men
sum actual_ss_benefit if sex==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) [aweight=weight] // divorced, >10
sum actual_ss_benefit if sex==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) [aweight=weight] // divorced, <10

*** Unweighted, waves 1, 4, 7
sum actual_ss_benefit if sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59))

sum actual_ss_benefit if sex==1 & doeitob==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // Non-SSDI men

sum actual_ss_benefit if race==1 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // White men

sum actual_ss_benefit if race==2 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // Black men

sum actual_ss_benefit if race==1 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // Other men

sum actual_ss_benefit if qtile_wSSDI_men==1 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 1 all
sum actual_ss_benefit if qtile_wSSDI_men==2 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 2 all
sum actual_ss_benefit if qtile_wSSDI_men==3 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 3 all
sum actual_ss_benefit if qtile_wSSDI_men==4 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 4 all

sum actual_ss_benefit if qtile_noSSDI_men==1 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 1 no ssdi
sum actual_ss_benefit if qtile_noSSDI_men==2 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 2 no ssdi
sum actual_ss_benefit if qtile_noSSDI_men==3 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 3 no ssdi
sum actual_ss_benefit if qtile_noSSDI_men==4 & sex==1 & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // aime 4 no ssdi

sum actual_ss_benefit if sex==1 & (mstat_62==1 | mstat_62==2) & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59))  // married Men
sum actual_ss_benefit if sex==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // divorced, >10
sum actual_ss_benefit if sex==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) & ((r1agey_b>=50 & r1agey_b<=59)|(r4agey_b>=50 & r4agey_b<=59)|(r7agey_b>=50 & r7agey_b<=59)) // divorced, <10

*** Unweighted, all waves
** Weighted
sum actual_ss_benefit if sex==1 // all men

sum actual_ss_benefit if sex==1 & doeitob==1 // Non-SSDI men

sum actual_ss_benefit if race==1 & sex==1 // White men

sum actual_ss_benefit if race==2 & sex==1 // Black men

sum actual_ss_benefit if race==1 & sex==1 // Other men


sum actual_ss_benefit if qtile_wSSDI_men==1 & sex==1 // aime 1 all
sum actual_ss_benefit if qtile_wSSDI_men==2 & sex==1 // aime 2 all
sum actual_ss_benefit if qtile_wSSDI_men==3 & sex==1 // aime 3 all
sum actual_ss_benefit if qtile_wSSDI_men==4 & sex==1 // aime 4 all

sum actual_ss_benefit if qtile_noSSDI_men==1 & sex==1 // aime 1 no ssdi
sum actual_ss_benefit if qtile_noSSDI_men==2 & sex==1 // aime 2 no ssdi
sum actual_ss_benefit if qtile_noSSDI_men==3 & sex==1 // aime 3 no ssdi
sum actual_ss_benefit if qtile_noSSDI_men==4 & sex==1 // aime 4 no ssdi


sum actual_ss_benefit if sex==1 & (mstat_62==1 | mstat_62==2)  // married Men
sum actual_ss_benefit if sex==1 & mstat_62==5 & (r1mlen>=10 | r4mlen>=10 | r7mlen>=10) // divorced, >10
sum actual_ss_benefit if sex==1 & mstat_62==5 & (r1mlen<10 | r4mlen<10 | r7mlen<10) // divorced, <10
