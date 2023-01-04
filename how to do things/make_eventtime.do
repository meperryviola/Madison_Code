* event time

bys id: egen timing_before = max(time) if outside==1
bys id: egen timing_after = min(time)  if outside==0

replace timing_before =0 if timing_before ==.
replace timing_after =0 if timing_after ==.
gen timing = timing_before + timing_after