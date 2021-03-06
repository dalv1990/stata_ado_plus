program define lms
*! version 2.0.1 M. Blasnik 10/98 
* least median squares fit
version 5.0
local varlist "required existing min(2)"
local if "optional"
local in "optional"
local options "slow gen(str)"
parse"`*'"
if "`gen'"!="" {confirm new var `gen'}
tempvar rand yres touse finsamp
tempname mad bestmad
local nvar: word count `varlist'
/* includes constant implicitly by counting depvar */
mark `touse' `if' `in'
markout `touse' `varlist'
qui count if `touse'
local nobs=_result(1)
local begin=_N-`nobs'+1
local end=`begin'+`nvar'-1
if "`slow'"=="" {
	local reps=`nvar'*100+100
	if `nvar'==7 {local reps=850}
	if `nvar'==8 {local reps=1250}
	if `nvar'>=9 {local reps=1500}
}
else {local reps=min(3000,`nvar'*500)}
quietly {
gen `rand'=0
gen byte `finsamp'=0
scalar `bestmad'=10e+12
local i 1
while `i'<=`reps' {
	replace `rand'=uniform()
	sort `touse' `rand'
	reg `varlist' in `begin'/`end'
	capture drop `yres'
	predict `yres', res
	replace `yres'=abs(`yres')
	summ `yres' if `touse', d
	scalar `mad'=_result(10)
	if `i'==1 | `mad'<`bestmad' {
		replace `finsamp'=0
		replace `finsamp'=1 in `begin'/`end'
		scalar `bestmad'=`mad'
	}
	local i=`i'+1
}
}
if "`gen'"!="" {gen byte `gen'=`finsamp'}
di "Least Median of Squares Fit"
di in red "***!!! WARNING - IGNORE STD ERRORS"
reg `varlist' if `finsamp', nohead
di in bl "Median Absolute Residual= "%9.0g scalar(`bestmad') /*
*/ _col(45) "sampled points=`reps'" 
global S_1=`bestmad'
end	
