*! version 1.3.4    0A27       C F Baum / R Sperling  (STB-58: sts15.1)
*  corr 0711 for r(nobs), 
*  corr 0712 to use all available obs in QD regr
*  mod  0717 to add Cheung-Lai response surface crit vals, ERS option
*  mod  0913 to correct SC per R.Sperling
*  mod  0921 to add MAIC optimal lag length
*  corr 0922 for markout of initial obs per VLW
*  corr 0A27 for calculation of ldty2 in conjunction with in clause

program define dfgls, rclass
	version 6

	syntax varname(ts) [if] [in] [ , Maxlag(integer -1) noTrend ERS]  

   	marksample touse
			/* get time variables */
	_ts timevar, sort
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
	}
	tempvar trd y iota qdtrd dty yhat 
	tempname nobs cbar alpha vcv cv stat i rzt1 rzt5 rzt10 first count kmax
	tempname resp10 resp5 ldty2 sldty2 tau t2
		
	if "`trend'"=="notrend" {
		local trend 0
		local stat "mu"
		}
	else {
		local trend 1
		local stat "tau"
		}
	gen `count'=sum(`touse')
	local nobs=`count'[_N]
	if `maxlag'==-1 {
* set maxlag via Schwert criterion (Ng/Perron JASA 1995)
		local maxlag = int(12*(`nobs'/100)^0.25)
		local kmax = "Maxlag = `maxlag' chosen by Schwert criterion" 
		}
	else {
		local kmax ""
		}
	if `trend' {gen `trd' = _n}
* cbars appropriate for trended, detrended case (follow Stock Hbk Metr fn 9)
	local cbar -7.0
	if `trend' {local cbar -13.5}
	local alpha = 1+`cbar'/`nobs'
	qui {
		gen double `y' = `varlist' if `count'==1
		gen double `iota' = 1 if `count'==1
		if `trend' {gen double `qdtrd' = `trd' if `count'==1}
		replace `y' = `varlist'-`alpha'*L.`varlist' if `count'>1
		replace `iota' = 1-`alpha' if `count'>1
		if `trend' {replace `qdtrd' = `trd'-`alpha'*L.`trd' if `count'>1}
* run the GLS regression to detrend (or demean) the data via quasi-differencing
* mod 0712: run over all available observations by relocating additional markout below
		if `trend' {qui reg  `y' `iota' `qdtrd' if `touse', noc}
		else {qui reg `y' `iota' if `touse', noc}
* 0712 markout one more to account for lag of delta
* 0922 correction for missing initial obs
		local maxl1 = `maxlag'+1
		gen byte `t2' = 1 if `touse'
		markout `touse' L(1/`maxl1').`t2'
* generate OLS residual, not GLS residual, which becomes object of (A)DF regression
		gen double `dty'=`varlist'-_b[`iota'] 
		if `trend' {replace `dty'=`dty'-_b[`qdtrd']*`trd'}
* Richard Sperling: sldty2 is used in the calculation of MAIC below
* Richard Sperling: See p. 8 in Ng & Perron (2000).
* cfb double
		gen double `ldty2'=sum((L.`dty')^2) if `touse'
* cfb 0A27 ensure that only obs defined by touse are considered
		qui summarize `ldty2' if `touse',meanonly 
		local sldty2=`ldty2'[r(N)]
		if `trend' { GetCritE `nobs' }
		else { GetCritD `nobs'}
		local rzt1=r(Zt1)
		local rzt5=r(Zt5)
		local rzt10=r(Zt10)
		}
	di " "
	qui summarize D.`dty' if `touse',meanonly 
	local nobs=r(N)
	di in gr "Number of obs = " in ye %5.0f `nobs' 
	if "`kmax'" !="" {di in gr "`kmax'"}
	di " "
	local first 1
        if `maxlag' == 0 {
* run the DF regression, no constant nor trend
		qui reg D.`dty' L.`dty' if `touse', noc 
		mat `vcv'=e(V)
		return scalar dft0=_b[L.`dty']/sqrt(`vcv'[1,1])
		return scalar rmse0=sqrt(e(rss)/`nobs')
		if `trend' { GetCritT `nobs' `maxlag' }
		else { GetCritM `nobs' `maxlag' }
		local resp5=r(resp5)
		local resp10=r(resp10)
		if "`ers'"=="ers" { Out `stat' `first' 0 `return(dft0)' `rzt1' `rzt5' `rzt10'}
		else { Out `stat' `first' 0 `return(dft0)' `rzt1' `resp5' `resp10'}
        	}
        else { 
* loop over lags 1..maxlag
		local i = `maxlag'
		local first 1
		local bRMSE .
		local lOpt .
		local bSC .
		local lSC .
		local bmaic .
		local lmaic .
		while `i'>0 {
* run the ADF regression, no constant nor trend
                	qui reg D.`dty' L.`dty' DL(1/`i').`dty' if `touse', noc 
			mat `vcv'=e(V)
			local col=e(df_m)
			return scalar dft`i'=_b[L.`dty']/sqrt(`vcv'[1,1])
			return scalar rmse`i'=sqrt(e(rss)/`nobs')
			local tprob=tprob(e(df_r),_b[DL`i'.`dty']/sqrt(`vcv'[`col',`col']))
			if `tprob'<0.10 & `lOpt'==. {
				local lOpt = `i'
				local bRMSE = return(rmse`i')
				}
* Calculate SC
			return scalar sc`i'=log(return(rmse`i')^2)+(`i'+1)*log(`nobs')/`nobs'
			local lSC = cond(return(sc`i')<`bSC',`i',`lSC')
			local bSC = min(`bSC',return(sc`i'))
* Richard Sperling: Calculate MAIC, but first calculate tau variable
* Richard Sperling: See p. 8 in Ng & Perron (2000)
			local tau = (return(rmse`i')^2)^(-1)*(_b[L.`dty'])^2*`sldty2'
			return scalar maic`i'=log(return(rmse`i')^2)+2*(`tau'+`i')/`nobs'
			local lmaic = cond(return(maic`i')<`bmaic',`i',`lmaic')
			local bmaic = min(`bmaic',return(maic`i'))
			if `trend' { GetCritT `nobs' `i' }
			else { GetCritM `nobs' `i' }
			local resp5=r(resp5)
			local resp10=r(resp10)
			if "`ers'"=="ers" { Out `stat' `first' `i' `return(dft`i')' `rzt1' `rzt5' `rzt10'}
			else { Out `stat' `first' `i' `return(dft`i')' `rzt1' `resp5' `resp10'}
			local i = `i' - 1
			local first 0
* end while over lags
			}
			if `maxlag' > 1 {
				return scalar optlag = `lOpt'
				di " "
				if  `lOpt' !=. {
					di in gr "Opt Lag (Ng-Perron seq t) = " %2.0f `lOpt' _col(22) " with RMSE " %9.0g `bRMSE'
					}
				else {
					di in gr "Opt Lag (Ng-Perron seq t) = 0 [use maxlag(0)]"
					}
				di in gr "Min SC   = " %9.0g `bSC' " at lag " %2.0f `lSC' " with RMSE " %9.0g return(rmse`lSC')
				di in gr "Min MAIC = " %9.0g `bmaic' " at lag " %2.0f `lmaic' " with RMSE " %9.0g return(rmse`lmaic')
				}
* end switch over nolags/lags
		}
	return scalar N =`nobs'
	return local lags `lags'
end

program define Out, nclass
	args stat first lags dft rzt1 rzt5 rzt10
	if (`first') {
	di in gr _col (20) "Test" /*
        */ _col(32)  "1% Critical"  _col(50)  "5% Critical" /*
        */ _col(67) "10% Critical"
        di in gr _col (16) "Statistic" /*
        */ _col(36)  "Value" _col(54)  "Value" _col(72) "Value"
        di in gr _dup(78) "-"
	}
        di in gr "DF-GLS(`stat')[`lags']" /*
        */ _col(16) in ye %10.3f `dft'  _col(33) %10.3f `rzt1' /*
        */ _col(51) %10.3f `rzt5'  _col(69) %10.3f `rzt10'
	end 
        	       
program define GetCritE, rclass
* interp values from Elliott et al, Econometrica 64:4 1996 Table 1c
        args N
	tempname zt
                mat `zt' = ( -3.77,-3.58,-3.46,-3.48\ /*
                          */ -3.19,-3.03,-2.93,-2.89\ /*
                          */ -2.89,-2.74,-2.64,-2.57)

        if `N' <= 50 {
                local zt1  = `zt'[1,1] 
                local zt5  = `zt'[2,1]
                local zt10 = `zt'[3,1]
        }
        else if `N' <= 100 {
                local zt1  = `zt'[1,1] + (`N'-50)/50 * (`zt'[1,2]-`zt'[1,1])
                local zt5  = `zt'[2,1] + (`N'-50)/50 * (`zt'[2,2]-`zt'[2,1])
                local zt10 = `zt'[3,1] + (`N'-50)/50 * (`zt'[3,2]-`zt'[3,1])
        }
        else if `N' <= 200 {
                local zt1  = `zt'[1,2] + (`N'-100)/100 * (`zt'[1,3]-`zt'[1,2])
                local zt5  = `zt'[2,2] + (`N'-100)/100 * (`zt'[2,3]-`zt'[2,2])
                local zt10 = `zt'[3,2] + (`N'-100)/100 * (`zt'[3,3]-`zt'[3,2])
        }
        else {
                local zt1  = `zt'[1,4]
                local zt5  = `zt'[2,4]
                local zt10 = `zt'[3,4]
        }
        return scalar Zt1  = `zt1'
        return scalar Zt5  = `zt5'
        return scalar Zt10 = `zt10'
end

program define GetCritD, rclass
* hacked from official dfuller.ado
        args N
	tempname zt
                mat `zt' = ( -2.66,-2.62,-2.60,-2.58,-2.58,-2.58\ /*
                          */ -1.95,-1.95,-1.95,-1.95,-1.95,-1.95\ /*
                          */ -1.60,-1.61,-1.61,-1.62,-1.62,-1.62)

        if `N' <= 25 {
                local zt1  = `zt'[1,1] 
                local zt5  = `zt'[2,1]
                local zt10 = `zt'[3,1]
        }
        else if `N' <= 50 {
                local zt1  = `zt'[1,1] + (`N'-25)/25 * (`zt'[1,2]-`zt'[1,1])
                local zt5  = `zt'[2,1] + (`N'-25)/25 * (`zt'[2,2]-`zt'[2,1])
                local zt10 = `zt'[3,1] + (`N'-25)/25 * (`zt'[3,2]-`zt'[3,1])
        }
        else if `N' <= 100 {
                local zt1  = `zt'[1,2] + (`N'-50)/50 * (`zt'[1,3]-`zt'[1,2])
                local zt5  = `zt'[2,2] + (`N'-50)/50 * (`zt'[2,3]-`zt'[2,2])
                local zt10 = `zt'[3,2] + (`N'-50)/50 * (`zt'[3,3]-`zt'[3,2])
        }
        else if `N' <= 250 {
                local zt1  = `zt'[1,3] + (`N'-100)/150 * (`zt'[1,4]-`zt'[1,3])
                local zt5  = `zt'[2,3] + (`N'-100)/150 * (`zt'[2,4]-`zt'[2,3])
                local zt10 = `zt'[3,3] + (`N'-100)/150 * (`zt'[3,4]-`zt'[3,3])
        }
        else if `N' <= 500 {
                local zt1  = `zt'[1,4] + (`N'-250)/250 * (`zt'[1,5]-`zt'[1,4])
                local zt5  = `zt'[2,4] + (`N'-250)/250 * (`zt'[2,5]-`zt'[2,4])
                local zt10 = `zt'[3,4] + (`N'-250)/250 * (`zt'[3,5]-`zt'[3,4])
        }
        else {
                local zt1  = `zt'[1,6]
                local zt5  = `zt'[2,6]
                local zt10 = `zt'[3,6]
        }
        return scalar Zt1  = `zt1'
        return scalar Zt5  = `zt5'
        return scalar Zt10 = `zt10'
end
program define GetCritM, rclass
* response surface values from Cheung and Lai OBES 1995 Table 1, cols 1-2
	args N p
	tempname rsm
	mat `rsm' = ( -1.624, -19.888, 155.231, 0.709, 5.480, -16.055 \ /*
	*/            -1.948, -17.839, 104.086, 0.802, 5.558, -18.332 )
	
	local n1 = 1.0/`N'
	local pt = `p'/`N'
	local cr10 = `rsm'[1,1] + `rsm'[1,2]*`n1' + `rsm'[1,3]*(`n1'^2) + /*
	*/ `rsm'[1,4]*`pt' + `rsm'[1,5]*(`pt'^2) + `rsm'[1,6]*(`pt'^3)
	local cr05 = `rsm'[2,1] + `rsm'[2,2]*`n1' + `rsm'[2,3]*(`n1'^2) + /*
	*/ `rsm'[2,4]*`pt' + `rsm'[2,5]*(`pt'^2) + `rsm'[2,6]*(`pt'^3)
	return scalar resp10 = `cr10'
	return scalar resp5 = `cr05'
end
program define GetCritT, rclass
* response surface values from Cheung and Lai OBES 1995 Table 1, cols 3-4
	args N p
	tempname rst
	mat `rst' = ( -2.550, -20.166, 155.215, 1.133, 9.808, -20.313 \ /*
	*/            -2.838, -20.328, 124.191, 1.267, 10.530, -24.600 )
	
	local n1 = 1.0/`N'
	local pt = `p'/`N'
	local cr10 = `rst'[1,1] + `rst'[1,2]*`n1' + `rst'[1,3]*(`n1'^2) + /*
	*/ `rst'[1,4]*`pt' + `rst'[1,5]*(`pt'^2) + `rst'[1,6]*(`pt'^3)
	local cr05 = `rst'[2,1] + `rst'[2,2]*`n1' + `rst'[2,3]*(`n1'^2) + /*
	*/ `rst'[2,4]*`pt' + `rst'[2,5]*(`pt'^2) + `rst'[2,6]*(`pt'^3)
	return scalar resp10 = `cr10'
	return scalar resp5 = `cr05'
end
exit
