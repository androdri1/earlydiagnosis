  ////////////////////////////////////////////////////////////////
 // *************** 0. Program definitions ******************* //
////////////////////////////////////////////////////////////////

* ***********************************************************************************
* @ Generate print-friendly versions of stata coefficients
* @ it has to be run after a regression where the first var is the relevant one, and it will
* @ return $coef`number' $se`number' and $star`number'. Something lile 1.23 (0.4) ^{***}
* @ which can be used directly into texdoc
cap program drop myCoeff 
program define myCoeff, rclass
args number fac which
	if "`which'"=="" {
		matrix B=e(b)
		matrix V=e(V)	
		local coefi= B[1,1]
		local sei  = (V[1,1])^0.5
	}
	else {
	disp "`which'"
		local coefi= _b["`which'"]
		local sei  = _se["`which'"]
	}

	glo coef`number' : di %7.2f `coefi'*`fac'
	glo se`number'   : di %7.2f `sei'*`fac'
	if e(cmd)=="xtreg" | e(cmd)=="rd" {
		scalar pval=2*(1-normal( abs(`coefi'/(`sei'))))			
	}
	else {
		scalar pval=2*ttail( e(df_r) , abs(`coefi'/(`sei')))
	}
	glo starX`number' = ""
	if ((pval < 0.1) )  glo starX`number' = "*" 
	if ((pval < 0.05) ) glo starX`number' = "**" 
	if ((pval < 0.01) ) glo starX`number' = "***" 
	
	glo sep`number'="(${se`number'})"
	glo star`number'="^{${starX`number'}}"
	glo pval`number'  : di %7.4f pval
end

* @ An alternative where instead of asuming that you want the first, you give it the 
* @ name of the variable. If the variable is not there, it returns blanks
* @ Example: myCoeff2 2 100 "treatment"
cap program drop myCoeff2
program define myCoeff2, rclass
args number fac vari	
	cap disp _b[`vari']
	if _rc!=0 {  // Coefficient not present
		glo coef`number'=""
		glo se`number'=""
		glo sep`number'=""
		glo star`number'=""	
		glo pval`number' = ""
	}
	else if _se[`vari']==0  & _b[`vari']==0 { // Coefficient was ommited
		glo coef`number'=""
		glo se`number'=""
		glo sep`number'=""
		glo star`number'=""	
		glo pval`number' = ""
	}	
	else {
	
		local coe=_b[`vari']
		local ste=_se[`vari']
		if e(cmd)=="probit" {
			glo coef`number' : di %7.3f `coe'*`fac'
			glo se`number'   : di %7.3f (`ste')*`fac'			
		}
		else {
			glo coef`number' : di %7.3f `coe'*`fac'
			glo se`number'   : di %7.3f (`ste')*`fac'
		}
		glo se`number' = "(${se`number'})"
		glo sep`number'  = "${se`number'}"
		glo t`number' :  di %7.2f abs(`coe'/`ste' )
		glo tb`number'  = "[${t`number'}]"
		
		if e(cmd)=="margins" | e(cmd)=="probit" {
			scalar pval=2*(1-normal( abs(`coe'/`ste' )))			
		}
		else {
			glo df`number' = e(df_r)
			scalar pval=2*ttail( e(df_r) , abs(`coe'/`ste' ))
		}
		glo pval`number' = pval
		glo star`number' = ""
		glo starn`number' = 0
		if ((pval < 0.1) )  glo star`number' = "^{*}" 
		if ((pval < 0.1) )  glo starn`number' = 1
		if ((pval < 0.05) ) glo star`number' = "^{**}" 
		if ((pval < 0.05) ) glo starn`number' = 2	
		if ((pval < 0.01) ) glo star`number' = "^{***}" 
		if ((pval < 0.01) ) glo starn`number' = 3
		glo pval`number'  : di %7.4f pval
	}
end

* ***********************************************************************************
* @ Graphic of an RDD with estimates of the jump for the triangular kernel, 
* @ and with confidence intervals.


* rdGraph sis01 `varDep' "$condic  & age<=64" .052739 "Std. around the cutoff Systolic BP" "Proportion who answers positevely at t+1" "left" "Title"

cap program drop rdGraph
program define rdGraph, rclass
args jumpVar varDep restric bw xtitle ytitle nameg ltitle black

	* Graph construction
	* For the titles
	sum `varDep'
	local fac=1
	local unit=""
	if r(min)>=0 & r(max)<=1 {
		local fac=100
		local unit="\%"

	}
	
	matrix drop _all
	disp "rd `varDep' `jumpVar' if `restric', z0(0) mbw(100)"
	disp "reg `varDep' expSis sis01 sis02 i.expSis#c.sis01 i.expSis#c.sis02 if `restric' & sis01>-1 & sis01<1 , r"
	*rd `varDep' `jumpVar' if `restric', z0(0) mbw(100)
if "`jumpVar'"=="sis01" reg `varDep' expSis sis01 sis02 i.expSis#c.sis01 i.expSis#c.sis02 if `restric' & sis01>-1 & sis01<1 , r
if "`jumpVar'"=="dis01" reg `varDep' expDis dis01 dis02 i.expDis#c.dis01 i.expDis#c.dis02 if `restric' & sis01>-1 & sis01<1 , r	
	myCoeff 1 `fac'	
	
	rd `varDep' `jumpVar' if `restric', z0(0) mbw(100)
	local h=e(w)
	
		replace `varDep'=`varDep'*`fac'		
	
	lpoly `varDep' `jumpVar' if `jumpVar'<0  & `restric' & `jumpVar'>-1.2 & `jumpVar'<1.2, k(tri) bw(`h') generate(xl yl) se(sel) nograph  deg(1)
	gen yl_lb=yl-1.64*sel
	gen yl_ub=yl+1.64*sel
	gen idl=_n if yl_ub!=.

	lpoly `varDep' `jumpVar' if `jumpVar'>=0 & `restric' & `jumpVar'>-1.2 & `jumpVar'<1.2, k(tri) bw(`h') generate(xr yr) se(ser) nograph  deg(1)
	gen yr_lb=yr-1.64*ser
	gen yr_ub=yr+1.64*ser
	gen idr=50+_n if yr_ub!=.

	* Get the 'dots' plot
	cap drop xdl ydl xdr ydr
	lpoly `varDep' `jumpVar' if `jumpVar'<0  & `restric' & `jumpVar'>-1.2 & `jumpVar'<1.2 , k(rectangle) bw(`bw') generate(xdl ydl) nograph
	lpoly `varDep' `jumpVar' if `jumpVar'>=0 & `restric' & `jumpVar'>-1.2 & `jumpVar'<1.2 , k(rectangle) bw(`bw') generate(xdr ydr) nograph

	disp "ya"
	
	local diH : di %3.2f `h'

	* Graph Display options ***************************
	 local myOptions=" (scatter ydl xdl) (scatter ydr xdr), scheme(scheme(colorblind)) "
	if (`black'==1) local myOptions=" , scheme(scheme(colorblind)) "
	
	if ("`xtitle'"=="" ) {
		local myOptions="`myOptions' xtitle(Optimal bandwidth: `diH' SD) "
	}
	else {
		local myOptions="`myOptions' xtitle(`xtitle')" // caption(Optimal bandwidth: `diH' SD) "
	}
	disp "`myOptions'"
  
	tw (rarea yl_lb yl_ub xl, fintensity(20) lcolor(gs16) lwidth(none)) (line yl xl  ) ///
	   (rarea yr_lb yr_ub xr, fintensity(20) lcolor(gs16) lwidth(none)) (line yr xr , xline(0) ) ///
	   `myOptions' legend(off) ytitle(`ytitle') ///
	   ylabel(, angle(horizontal)) title(`ltitle') subtitle( "Estimated discontinuity {&delta}: $coef1 $starX1" "[p-val=$pval1]" ) ///
	   name(`nameg', replace)

	if 1==0 {
		tw (rarea yl_lb yl_ub xl, fintensity(20) lcolor(gs16) lwidth(none)) (line yl xl  ) ///
		   (rarea yr_lb yr_ub xr, fintensity(20) lcolor(gs16) lwidth(none)) (line yr xr , xline(0) ) ///
		   (scatter ydl xdl) (scatter ydr xdr) ///
		   , caption("Optimal bandwidth: `diH' SD") legend(off) ytitle(`ytitle') ///
		   xtitle(`xtitle') ylabel(, angle(horizontal)) title(`ltitle') subtitle( "Estimated discontinuity {&delta}: $coef1 $starX1" "[p-val=$pval1]" ) ///
		   name(`nameg', replace)	
	}
	
	cap drop xl yl sel yl_lb yl_ub idl
	cap drop xr yr ser yr_lb yr_ub idr	 
	cap drop xdl ydl xdr ydr
	
	if `fac'==100   replace `varDep'=`varDep'/100
	   
end	   
	   
