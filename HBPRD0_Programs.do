  ////////////////////////////////////////////////////////////////
 // *************** 0. Program definitions ******************* //
////////////////////////////////////////////////////////////////


* *************************************************************
* @ Generate print-friendly versions of stata coefficients
* @ For the case of binary vars, you can add "fac=100", otherwise a "fac=1" is enough
* @ it has to be run after a regression where the first var is the relevant one, and it will
* @ return $coef`number' $se`number' and $star`number'. Something lile 1.23 (0.4) ^{***}
* @ which can be used directly into texdoc. 
* @ Any question: p.lesmes.11@ucl.ac.uk
cap program drop myCoeff4

* @ In the standard form
* @ example:  myCoeff4 , vari("treatment") number(2) fac(100) format("%7.3f")
program myCoeff4
	syntax [if] [in] , vari(string) number(real) [fac(integer 1) format(string) ] 
	loc formato="%7.3f"
	if "`format'"!=""  	loc formato="`format'"
	
	cap disp _b[`vari']
	if _rc==0 {
		est store r`number'
		local coe=_b[`vari']
		local ste=_se[`vari']
		if e(cmd)=="probit" |  {
			glo coef`number' : di `formato' `coe'*`fac'
			glo se`number'   : di `formato' (`ste')*`fac'			
		}
		else {
			glo coef`number' : di `formato' `coe'*`fac'
			glo se`number'   : di `formato' (`ste')*`fac'
		}
		glo se`number' = "(${se`number'})"
		glo sep`number'  = "${se`number'}"
		if e(cmd)=="margins" | e(cmd)=="ivregress" | e(cmd)=="sem" {
			scalar pval=2*(1-normal( abs(`coe'/`ste' )))			
		}
		else {
			scalar pval=2*ttail( e(df_r) , abs(`coe'/`ste' ))
		}
		glo star`number' = ""
		glo starn`number' = 0
		if ((pval < 0.1) )  glo star`number' = "^{*}" 
		if ((pval < 0.1) )  glo starn`number' = 1
		if ((pval < 0.05) ) glo star`number' = "^{**}" 
		if ((pval < 0.05) ) glo starn`number' = 2	
		if ((pval < 0.01) ) glo star`number' = "^{***}" 
		if ((pval < 0.01) ) glo starn`number' = 3
		
		glo pval`number' : di %4.3f pval
	}
	else {
		glo coef`number'=""
		glo se`number'=""
		glo sep`number'=""
		glo star`number'=""
		glo pval`number'=""
	}
end

* *************************************************************

* ***********************************************************************************
* @ Graphic of an RDD with estimates of the jump for the triangular kernel, 
* @ and with confidence intervals.


* rdGraph sis01 `varDep' "$condic  & age<=64" .052739 "Std. around the cutoff Systolic BP" "Proportion who answers positevely at t+1" "left" "Title"

cap program drop rdGraph
program define rdGraph, rclass
	syntax varlist [if] [in] , plot_range(string) xtitle(string) ytitle(string) [nameg(string) ltitle(string) black(integer 0)]

	local varDep : word 1 of `varlist'
	local jumpVar : word 2 of `varlist'
	
	tokenize `plot_range'
		local h_l `"`1'"'
		local h_r `"`2'"'	
		local rangell =`h_l'
		local rangelr =`h_r'			
		
	local restric = "`if'"
	
	if "`ytitle'"==""  local ytitle=" "

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
	
	rdrobust `varDep' `jumpVar' `restric' , p(1) bwselect(msetwo)
		loc b     : disp %5.2f e(tau_cl)*`fac'
		loc se    : disp %5.2f e(se_tau_cl)
		loc pval  : disp %4.2f e(pv_cl)
		loc pvalr : disp %4.2f e(pv_rb)
		loc hl    : disp %4.1f e(h_l)
		loc hr    : disp %4.1f e(h_r)
		loc enel  = e(N_h_l)
		loc ener  = e(N_h_r)		

		glo coef1="`b'"
		glo star1="[`pvalr']"
		glo sep1="(`se')"		
		glo bw1 =" h=`hl'/`hr',"
		glo ene1 =" N=`enel'/`ener'"	
	
		replace `varDep'=`varDep'*`fac'		
	
	
	lpoly `varDep' `jumpVar' `restric' & `jumpVar'<0 & `jumpVar'>`rangell' & `jumpVar'<`rangelr', k(tri) bw(`hl') generate(xl yl) se(sel) nograph  deg(1)
	gen yl_lb=yl-1.64*sel
	gen yl_ub=yl+1.64*sel
	gen idl=_n if yl_ub!=.

	lpoly `varDep' `jumpVar' `restric' & `jumpVar'>=0 & `jumpVar'>`rangell' & `jumpVar'<`rangelr', k(tri) bw(`hr') generate(xr yr) se(ser) nograph  deg(1)
	gen yr_lb=yr-1.64*ser
	gen yr_ub=yr+1.64*ser
	gen idr=50+_n if yr_ub!=.

	* Get the 'dots' plot
	cap drop xdl ydl xdr ydr
	lpoly `varDep' `jumpVar' `restric' & `jumpVar'<0  & `jumpVar'>`rangell' & `jumpVar'<`rangelr' , k(triangle) bw(1) generate(xdl ydl) nograph
	lpoly `varDep' `jumpVar' `restric' & `jumpVar'>=0 & `jumpVar'>`rangell' & `jumpVar'<`rangelr' , k(triangle) bw(1) generate(xdr ydr) nograph

	disp "ya"
	
	local diH : di %3.2f `h'

	* Graph Display options ***************************
	local myOptions=" , scheme(Plotplainblind) "
	disp "`myOptions'"

	tw (line yl xl if xl>`rangell' , lwidth(thick) lpattern(solid) lcolor(black)  ) ///
	   (line yr xr if xr<`rangelr' , xline(0 , lwidth(vthick) lpattern(solid)) lwidth(thick) lpattern(solid) lcolor(black) ) ///
	   (scatter ydl xdl if xdl>`rangell' & xdl<`rangelr') (scatter ydr xdr) ///
	   `myOptions' legend(off) ytitle("`ytitle'",size(large)) ///
	   xscale(r(`rangell' `rangelr')) xlabel(`rangell'(5)`rangelr', labsize(medlarge)) ///
	   xtitle("`xtitle'" , size(medlarge)) ///
	   ylabel(, angle(horizontal) labsize(medlarge) ) title("`ltitle'",size(vlarge) ) subtitle( "Estimated jump {&delta}: $coef1 p-val=$star1" ,size(large) ) ///
	   name(`nameg', replace) caption("$bw1 $ene1" ,size(large) )	
	
	cap drop xl yl sel yl_lb yl_ub idl
	cap drop xr yr ser yr_lb yr_ub idr	 
	cap drop xdl ydl xdr ydr
	
	if `fac'==100   replace `varDep'=`varDep'/100
	   
end	   
	   

	   
