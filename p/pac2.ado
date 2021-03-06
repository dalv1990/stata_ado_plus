*! version 1.3.10  CFBaum 21oct2003
*! version 1.3.9  10dec2002
* 1.3.10: enable onepanel (will only work under v8)
program define pac2
	version 6
	if _caller() < 8 {
		pac_7 `0'
		exit
	}

	syntax varname(ts) [if] [in]		///
		[,				///
		LAGs(int -999)			///
		GENerate(string)		///
		Level(int $S_level)		///
		FFT				///
		noGRAPH				///
		SRV				///
		*				///
	]

	if `"`graph'"' != "" {
		syntax varname(ts) [if] [in]	///
			[,			///
			LAGs(int -999)		///
			GENerate(string)	///
			Level(int $S_level)	///
			FFT			///
			noGRAPH			///
		]
	}
	else {
		// parse graph options
		_get_gropts , graphopts(`options')	///
			getallowed(ciopts srvopts plot)
		local options `"`s(graphopts)'"'
		local ciopts `"`s(ciopts)'"'
		local srvopts `"`s(srvopts)'"'
		local plot `"`s(plot)'"'
		_check4gropts ciopts , opt(`ciopts')
		_check4gropts srvopts , opt(`srvopts')
		if `"`srvopts'"' != "" {
			local srv srv
		}
	}

        if `level' < 10 | `level' > 99 {
                di in red "level must be between 10 and 99"
                exit 198
        }
	if "`graph'"!="" {
		if "`generate'"=="" {
			di in red "generate() must be specified with nograph"
			exit 198
		}
	}
	if "`generate'"!="" {
		local nword : word count `generate'
		if `nword' > 1 {
			di in red "generate() should name one new variable"
			exit 198
		}
		confirm new variable `generate'
	}

	marksample touse
	_ts tvar panelvar `if' `in', sort onepanel
	markout `touse' `tvar'

			/* hold the estimates from previous command,
			   otherwise they would be overwritten by -regress- */
        tempname ests
        cap estimates hold `ests', restore	/* -capture- since there may 
						   not be previous cmd */

quietly {

	tempvar  xm pac svar
	tempname R0 se

	summarize `varlist' if `touse'

	local n = r(N)
	if `n' == 0 { error 2000 }
	if `n' < 6 {
		di in red "number of observations must be greater " /*
		*/ "than 5"
		exit 2001
	}

	if `lags' == -999 {
		local lags = min(int(`n'/2)-2,40)
	}
	else if `lags' > int(`n'/2)-2 {
		di in red "lags() too large; must be less than " /*
		*/ int(`n'/2)-2
		exit 498
	}
	else if `lags' <= 0 {
		di in red "lags() must be greater than zero"
		exit 498
	}
	local matsize : set matsize
	if `matsize' < `lags' + 3 {
		di in red "matsize too small; type -help matsize-" _n /*
		*/ "matsize must be greater than or equal to " /*
		*/ `lags' + 3
		exit 908
	}

	scalar `R0' = r(Var)*(`n'-1)
	gen double `xm' = `varlist'-r(mean) if `touse'
	gen double `pac' = . in 1
	gen double `svar' = . in 1

	tsreport if `touse' & `varlist'!=.

	if r(N_gaps) > 0 {
		if r(N_gaps) > 1 {
			noi di in blu "(note: time series has " /*
			*/ r(N_gaps) " gaps)"
		}
		else	noi di in blu "(note: time series has 1 gap)"
	}

	local maxop 100
	local i 1
	while `i' <= `lags' {
		local k 1
		local args
		local diargs
		while (`k'-1)*`maxop'+1 <= `i' {
			local f = (`k'-1)*`maxop' + 1
			local e = min(`k'*`maxop',`i')
			local args `args' L(`f'/`e').`xm'
			local diargs `diargs' L(`f'/`e').`varlist'
			local k = `k' + 1
		}
		capture reg `xm' `args'
		if _rc!=2000 & _rc!=2001 {
			if _rc {
				if _rc==1 { error 1 }
				di in red "regression failed" _n /*
				*/ "failed command: regress " /*
				*/ "`varlist' `diargs'"
				error _rc
			}
			scalar `se' = .
			capture scalar `se' = _se[L`i'.`xm']
			if `se'!=0 & `se'!=. {
				replace `pac' = _b[L`i'.`xm'] in `i'
				replace `svar' = /*
				*/ (e(N)-1)*e(rmse)^2/`R0' in `i'
			}
		}
		local i = `i' + 1
	}

} // quietly

	if "`graph'"=="" { /* produce graph */
		tempvar obs
		qui gen long `obs' = _n  in 1/`lags'
		label var `obs' "Lag"
		local xttl : var label `obs'
		local note "`level'% Confidence bands [se = 1/sqrt(n)]"
		local yttl "Partial autocorrelations of `varlist'"
		label var `pac'  "`yttl'"
		label var `svar' "Standardized variances"

		tempvar LCL UCL
		qui gen `UCL' = invnorm((100+`level')/200)/sqrt(`n')	///
			in 1/`lags'
		qui gen `LCL' = -`UCL'
		label var `LCL' "`level'% CI"
		label var `UCL' "`level'% CI"
		format `LCL' `UCL' `pac' `svar' %-5.2f

		if `"`srv'"' != "" {
			local srvplot				///
			(scatter `svar' `obs'			///
				in 1/`lags',			///
				pstyle(p2)			///
				`srvopts'			///
			)
		}

		if `"`srv'`plot'"' == "" {
			local legend legend(nodraw)
		}
		version 8: graph twoway			///
		(rarea `LCL' `UCL' `obs'		///
			in 1/`lags',			///
			sort				///
			pstyle(ci)			///
			yticks(0,			///
				grid gmin gmax		///
				notick			///
			)				///
			ytitle(`"`yttl'"')		///
			xtitle(`"Lag"')			///
			subtitle(`"`subttl'"')		///
			note(`"`note'"')		///
			legend(cols(1))			///
			`legend'			///
			`ciopts'			///
		)					///
		(dropline `pac' `obs'			///
			in 1/`lags',			///
			pstyle(p1)			///
			`options'			///
		)					///
		`srvplot'				///
		|| `plot'				///
		// blank
	}

	if "`generate'"!="" {
		rename `pac' `generate'
		format `generate' %10.0g
		label var `generate' "Partial autocorrelations of `varlist'"
	}
end

exit

-pac- requires

1.  N >= 6,

2.  lags() <= int(N/2) - 2.

If lags() not specified, by default lags() = min(int(N/2) - 2, 40).

