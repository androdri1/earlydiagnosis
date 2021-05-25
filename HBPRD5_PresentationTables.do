  ////////////////////////////////////////////////////////////////
 // *************** 4. Presentation Tables ******************* //
////////////////////////////////////////////////////////////////
* 2014.07.08
* Paul Rodriguez-Lesmes <p.lesmes.11@ucl.ac.uk>

* **************************************************************
* PLEASE NOTICE THIS:
*tabstat sis01, by(sis1) /*  The 140 IS NOT ALWAYS the 0, due to */
                        /*  a different definition in the HSE  */
*tabstat sis01 if wave>1, by(sis1)            /* Ok, 140 */
*tabstat sis01 if wave<2 & masc==0 , by(sis1) /* Ok, 140 */
*tabstat sis01 if wave<2 & masc==1 & age<=50, by(sis1) /* Ok, 140 */
*tabstat sis01 if wave<2 & masc==1 & age>50, by(sis1)  /* Ok, 160 */
* **************************************************************
clear all

glo BHPSfolder="C:\Datos\BHPS"
* glo dropbox="C:\Users\PaulAndrés\Google Drive"
 glo dropbox="C:\GoogleDrive\"

 cd "$dropbox\Health and Labour Supply\Elsa"
use ELSA_NatCen_SmokingBeliefs.dta, clear
*keep if wave>1

do "0.Programs.do"

glo condic  ="Lhibpe==0 & Lbppills==0"
*glo condic  =" 1==1 "

cd "$dropbox\Health and Labour Supply\Presentation\tablas"

* **************************************************************	
* 1. Basic lifestyle means
* **************************************************************
if 1==0 {
label var alco1100 "Alcohol: more than once a week"

qui {
	texdoc init basicLifestyleMeans , replace
	tex \begin{table}[H]
	tex Lifestyle and High Blood Pressure
	tex \centering
	tex \scalebox{0.7}{
	tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
	tex \begin{tabularx} {15cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
	tex \toprule
	tex & \multicolumn{2}{c}{ Everyone } & \multicolumn{2}{c}{ Diagnosed HBP } \\
	tex Variable & All ages & $ Age\in[50,60]$ & All ages & $ Age\in[50,60]$ \\	
	tex \cmidrule(r){2-3} \cmidrule(r){4-5}
}
foreach mivar in smoken100  alco1100 dphy1100 {
	local lname : variable label `mivar'

	sum `mivar'
	return list
	local med1 : dis %4.2f r(mean)
	local se1  : dis %4.2f r(sd)

	sum `mivar' if age>=50 & age<=60
	return list
	local med2 : dis %4.2f r(mean)
	local se2  : dis %4.2f r(sd)

	sum `mivar' if hibpe==1
	return list
	local med3 : dis %4.2f r(mean)
	local se3  : dis %4.2f r(sd)

	sum `mivar' if age>=50 & age<=60 &  hibpe==1
	return list
	local med4 : dis %4.2f r(mean)
	local se4  : dis %4.2f r(sd)

	tex `lname' & `med1'\%  &  `med2'\%  & `med3'\%  &  `med4'\%  \\
	tex         & (`se1') &  (`se2') & (`se3') &  (`se4') \\
}
qui {
	tex \bottomrule
	tex \end{tabularx}
	tex }
	tex \end{table}			
	texdoc close		
}


}
* **************************************************************	
* 2. Observed Transitions
* **************************************************************
if 1==0 {

qui {
	texdoc init transitionsEvi , replace
	tex \begin{table}[H]
*	tex \caption{Lifestyle and Diseases}
	tex \centering
	tex \scalebox{0.6}{
	tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
	tex \begin{tabularx} {15cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
	tex \multicolumn{6}{c}{\parbox[c]{14cm}{\centering $ Y_{it}=X_{it}'\beta + \alpha_{i}+ \gamma_t +u_{it} \quad | \quad Age \leq 60 , HBP_{i,t-1}=0 $ }} \\
	tex \toprule
	tex Diagnosed Disease (X) & $ \bar{X} $ & SMOKE & ALCOHOL & PHYSIC ACT & GOOD HEALTH \\	
	tex \midrule
}
foreach depVar in smoken  alco1 dphy1 goodHealth {
	xtreg `depVar' hibpe heart lung diab age age2 parentDCard100 i.wave if age<=60 & $condic, fe r
	myCoeff `depVar'1 100 "hibpe"
	myCoeff `depVar'2 100 "heart"
	myCoeff `depVar'3 100 "lung"
	myCoeff `depVar'4 100 "diab"
	local numObs`depVar'=e(N)
	local numInd`depVar'=e(N_g)
}
local i=1
foreach dise in hibpe heart lung diab strok {
	sum `dise' if age<=60
	local mean`i' : di %4.2f r(mean)*100
	local i=`i'+1
}

tex High Blood Pressure & `mean1'\% & $ $coefsmoken1 $starsmoken1 $ & $ $coefalco11 $staralco11 $ & $ $coefdphy11 $stardphy11 $ & $ $coefgoodHealth1 $stargoodHealth1 $ \\
tex                     &           & ($sesmoken1)                  & ($sealco11)                 & ($sedphy11)                 & ($segoodHealth1)  \\
tex Heart diseases      & `mean2'\% & $ $coefsmoken2 $starsmoken2 $ & $ $coefalco12 $staralco12 $ & $ $coefdphy12 $stardphy12 $ & $ $coefgoodHealth2 $stargoodHealth2 $ \\
tex                     &           & ($sesmoken2)                  & ($sealco12)                 & ($sedphy12)                 & ($segoodHealth2)  \\
tex Lung diseases       & `mean3'\% & $ $coefsmoken3 $starsmoken3 $ & $ $coefalco13 $staralco13 $ & $ $coefdphy13 $stardphy13 $ & $ $coefgoodHealth3 $stargoodHealth3 $ \\
tex                     &           & ($sesmoken3)                  & ($sealco13)                 & ($sedphy13)                 & ($segoodHealth3)  \\
tex Diabetes            & `mean4'\% & $ $coefsmoken4 $starsmoken4 $ & $ $coefalco14 $staralco14 $ & $ $coefdphy14 $stardphy14 $ & $ $coefgoodHealth4 $stargoodHealth4 $ \\
tex                     &           & ($sesmoken4)                  & ($sealco14)                 & ($sedphy14)                 & ($segoodHealth4)  \\
tex \addlinespace[10pt]
tex N Obs               &           & `numObssmoken'                & `numObsalco1'               & `numObsdphy1'               & `numObsgoodHealth' \\ 
tex N Indiv             &           & `numIndsmoken'                & `numIndalco1'               & `numInddphy1'               & `numIndgoodHealth' \\
tex \midrule

foreach depVar in smoken  alco1 dphy1 goodHealth {
	sum `depVar' if age<=60
	local `depVar'_b : di %3.1f r(mean)*100
}
tex Average $ \bar{Y}$ &  & $ `smoken_b'\% $ & $ `alco1_b'\% $ & $ `dphy1_b'\% $ & $ `goodHealth_b'\% $ \\

qui {
	tex \bottomrule
	tex \multicolumn{6}{l}{\parbox[c]{15cm}{Regressions include age, age squared and parental mortality due to CVDs. Cluster by individual SE in parenthesis. Significance: * 10\%, ** 5\%, *** 1\%.  }} \\		
	tex \end{tabularx}
	tex }
	tex \end{table}			
	texdoc close		
}


}
* **************************************************************	
* Correlations Graph
* **************************************************************
if 1==0 {

preserve
gen condY1=smoken*100 if   hibpe==1
gen condN1=smoken*100 if   hibpe==0

gen condY2=alco1*100 if hibpe==1
gen condN2=alco1*100 if hibpe==0

gen condY3=dphy1*100 if hibpe==1
gen condN3=dphy1*100 if hibpe==0

gen condY4=goodHealth*100 if hibpe==1
gen condN4=goodHealth*100 if hibpe==0

collapse (mean) condY* condN*, by(hibpe)
drop if hibpe==.
reshape long condY condN, i(hibpe) j(miCond)

label define miCondl 1 "SMOKE: to smoke" 2 "ALCOHOL: more than once a week" 3 "PHYSIC ACT: Sedentary or low" 4 "GOOD HEALTH: Self-reported good or above"
label values miCond miCondl

graph hbar (mean) condY condN , over(miCond) ///
      blabel(bar, format(%4.1f)) ytitle("Percentage points") ///
	  legend(order(1 "Diagnosed HBP" 2 "No HBP")) ///
	  title("Self-reported HBP and lifestyle") ///
	  graphregion(fcolor(white) lcolor(none) ilwidth(none))

restore

graph export "$dropbox\Health and Labour Supply\Presentation\imagenes\basicHBP.png" , as(png) replace


}
* **************************************************************	
* 3. BHPS descriptives
* **************************************************************
if 1==0 {

use "$BHPSfolder\derived\mixed.dta", clear

gen england=region>=1 & region<=16
keep if england==1


gen visitas=0 if hl2gp!=.
replace visitas=1.5 if hl2gp==2
replace visitas=4 if hl2gp==3
replace visitas=8 if hl2gp==4
replace visitas=10 if hl2gp==5
*lpoly visitas  year if age>=49 & age<=51 , noscatter ci bw(1)

gen visitasUno=visitas>0 if visitas!=.
label var visitasUno "GP: visited at least once"
label var visitas "GP: Number of visits"

gen visitasOut=0 if hl2hop!=.
replace visitasOut=1.5 if hl2hop==1
replace visitasOut=4   if hl2hop==2
replace visitasOut=8   if hl2hop==3
replace visitasOut=10  if hl2hop==4

label var visitasOut "Outpatient: Number of visits"

gen yI= year==1998 | year==2000 | year==2002 | year==2004 | year==2006 | year==2008

drop if pid==.
duplicates list pid year
xtset pid year
gen Lhlckd=L.hlckd
gen LvisitasUno=L.visitasUno

gen BP2years= (hlckd + Lhlckd >=1 )*100
gen LvisitasUno2years= (visitasUno + LvisitasUno >=1 )*100

gen BP2years_you= BP2years if age>45 & age<=60 & yI==1
gen BP2years_old= BP2years if age>60 & yI==1

graph hbar (mean) BP2years_you BP2years_old  if yI==1, over(year) ///
	  title(Had a BP test (self-reported)) ///
      blabel(bar, format(%4.1f)) subtitle(At least once during the last 2 years) ///
	  caption(Own calculations based on the BHPS data) ///
	  legend(order(1 "Aged 45-60" 2 "Aged 60 or over")) xsize(1.5) ysize(2) ///
	  graphregion(fcolor(white) lcolor(none) ilwidth(none))

graph export "$dropbox\Health and Labour Supply\RDpaper Text\imagenes\bhpsStats.png" , as(png) replace

}
* **************************************************************	
* 3. Basic HIBPE results
* **************************************************************
if 1==0 {

 cd "$dropbox\Health and Labour Supply\Elsa"
use ELSA_NatCen_SmokingBeliefs.dta, clear
cd "$dropbox\Health and Labour Supply\Presentation\tablas"

qui {
	texdoc init basicHBP , replace
	tex \begin{table}[H]
	tex \centering
	tex \scalebox{0.6}{
	tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
	tex \begin{tabularx} {19cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
	tex \toprule
	tex \parbox[c]{5cm}{\centering Dependent Variable at $ t+1$ } & Mean & \parbox[c]{2cm}{\centering Quadratic Rectang. $ h=1SD$ } & \parbox[c]{2cm}{\centering Loc Linear Triangular $ h^*_1$} & \parbox[c]{2cm}{\centering Loc Linear Rectang. $ h^*_2$} & \parbox[c]{2cm}{\centering Loc Quad Rectang. $ h=1SD$ } \\	
*	tex \parbox[c]{5cm}{\centering Dependent Variable} & \parbox[c]{2cm}{\centering Quadratic 1 SD} & \parbox[c]{2cm}{\centering L. Linear Rc $ h^*$ SD} & \parbox[c]{2cm}{\centering \textcolor{red}{L. Linear Tri $ h^*$ SD}} & \parbox[c]{2cm}{\centering L. Quad 1 SD } & \parbox[c]{2cm}{\centering L. Quad 2 SD} \\
	tex \midrule 
}
foreach myVar in hibpe bppills {

		local lname : variable label `myVar'
		sum `myVar'
		local fac=1
		local unit=""
		if r(min)>=0 & r(max)<=1 {
			local fac=100
			local unit="\%"
		}
		
		reg `myVar' expSis sis01 sis02 if $condic & sis01>-1 & sis01<1 & age<=64, r
		myCoeff 1 `fac'
		glo ene1=e(N)	
		
		rd `myVar' sis01 if $condic  & age<=64 , z0(0) mbw(100)
			myCoeff 2 `fac'
			local h=e(w)
			local diH1 : di %3.2f `h'
			qui reg `myVar' sis01  if $condic  & age<=64 & sis01>=-`h' & sis01<=`h'
			count if e(sample)==1
			glo eneh1=r(N)
			
		rd `myVar' sis01 if $condic  & age<=64 , z0(0) mbw(100) kernel(rectangle)
			myCoeff 3 `fac'
			local h=e(w)
			local diH2 : di %3.2f `h'
			qui reg `myVar' sis01  if $condic  & age<=64 & sis01>=-`h' & sis01<=`h'
			count if e(sample)==1
			glo eneh2=r(N)


		reg `myVar' expSis sis01 sis02 i.expSis#c.sis01 i.expSis#c.sis02 if $condic & sis01>-1 & sis01<1 & age<=64 , r
			myCoeff 4 `fac'
			glo ene4=e(N)		
		
		sum `myVar' if e(sample)==1
			local mean : di %3.2f r(mean)*`fac'
		
		tex \parbox[c]{6cm}{\raggedright `lname' }                                                                     & `mean'`unit' & $ $coef1 $star1 $ & $ $coef2 $star2 $ & $ $coef3 $star3 $ & $ $coef4 $star4 $  \\*
		tex $ \quad$ {\scriptsize\textit{N: $eneh1 $ ( h^*_1=`diH1' )$, $eneh2 $ ( h^*_2=`diH2' )$ , $ene4 $ (h=1)$ }} &              & $ ($se1) $        & $ ($se2 $)        & $ ($se3 $)        & $ ($se4 $)        \\
		
}
qui {
	tex \bottomrule
	tex \end{tabularx}
	tex }
	tex \end{table}			
	texdoc close		
}

}
* **************************************************************	
* 3. RDD Basic Graph
* **************************************************************
if 1==0 {

glo condic  ="Lhibpe==0 & Lbppills==0"

* First Graph //////////////////////////////////////////////
* HBP
	rdGraph sis01 hibpe   "$condic  & age<=64" .052739 "Std. around the cutoff Systolic BP" "% who answers positevely at t+1" "left" "Self-Report of HBP at t+1"
	 
* BP Medication
	rdGraph sis01 bppills "$condic  & age<=64" .052739 "Std. around the cutoff Systolic BP" "% who answers positevely at t+1" "right" "Takes BP Medication at t+1"  

	graph combine left right,  ///
	   caption("Individuals without diagnosed HBP or being taking medication for blood pressure at the moment of the intervention (t) from the" "HSE-ELSA data. Calculations using linear triangular kernel with 95% CI. Sample: individuals aged 64 or less" "Significance level: *90%, ** 95%, *** 99%") ///
	   xsize(6) ysize(3) title("Impact of Nurse Advice")	 
	 
    graph export "$dropbox\Health and Labour Supply\Presentation\imagenes\mainImpactGraph.png" , as(png) replace	
	

* Results Graphs //////////////////////////////////////////////
label var Fbmival "BMI"
label var Falco1  "Alcohol: More than once a week"
label var Fsavings_bu_s "BU total savings (1000£)"

foreach varDep in goodHealth heskb savings_bu_s Fbmival Falco1 Fsavings_bu_s  {
	local lname : variable label `varDep'
	disp "`varDep': `lname'"

	rdGraph sis01 `varDep' "$condic  & age<=64" .052739 "Std. around the cutoff Systolic BP" "" "right" "Dependent: `lname'"  	
	
	graph export "$dropbox\Health and Labour Supply\Presentation\imagenes\r`varDep'64.png" , as(png) replace
}	

* Appendix Graphs //////////////////////////////////////////////
* HBP
	rdGraph dis01 hibpe   "$condic  & age<=64" .0855253 "Std. around the cutoff Diastolic BP" "% who answers positevely at t+1" "left" "Self-Report of HBP at t+1"
	 
* BP Medication
	rdGraph dis01 bppills "$condic  & age<=64" .0855253 "Std. around the cutoff Diastolic BP" "% who answers positevely at t+1" "right" "Takes BP Medication at t+1"  

	graph combine left right,  ///
	   caption("Individuals without diagnosed HBP or being taking medication for blood pressure at the moment of the intervention (t) from the" "HSE-ELSA data. Calculations using linear triangular kernel with 95% CI. Sample: individuals aged 64 or less" "Significance level: *90%, ** 95%, *** 99%") ///
	   xsize(6) ysize(3) title("Impact of Nurse Advice")	 
	 
    graph export "$dropbox\Health and Labour Supply\Presentation\imagenes\diastolicGraph.png" , as(png) replace	
		
	
}	
* **************************************************************	
* 3. Discontinuities in covariates? Reduced version
* **************************************************************
if 1==0 {


 cd "$dropbox\Health and Labour Supply\Elsa"
use ELSA_NatCen_SmokingBeliefs.dta, clear
cd "$dropbox\Health and Labour Supply\Presentation\tablas"

label var Lalco1   "Alcohol more than once a week"
label var Ldphy1   "Sedentary or low physical activity"


glo vars1= "age masc nonwhite dedu_2 dedu_3 Lsmoken Lalco1 Ldphy1"
glo vars2= "LbadHealth Lssp75 Lbmival Lhdl Lchol LframinghamCVDRisk LparentDCard"
glo vars3= "Ltotinc_bu_s Lsavings_bu_s Lnettotw_bu_s Lhours_aj Lwpactive"

glo titulo1 = "Demographic and habits"
glo titulo2 = "Health"
glo titulo3 = "Economic"

forval set=1(1)3 {
	qui {
		texdoc init testCovars_`set' , replace
		tex \begin{table}[H]
		tex \centering
		tex \scalebox{0.6}{
		tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
		tex \begin{tabularx} {9cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
		tex \multicolumn{3}{l}{\parbox[c]{9cm}{\centering ${titulo`set'} }} \\
		tex \multicolumn{3}{l}{\parbox[c]{9cm}{For those aged 64 or less }} \\
		tex \toprule
		tex \parbox[c]{5cm}{\centering Dependent Variable} & $ \parbox[c]{2cm}{\centering $ \bar{X}$ } $ & \parbox[c]{2cm}{\centering L. Linear Tri $ h^*$ SD}  \\
		tex \midrule 
	}
	foreach mivar in  ${vars`set'}    {

		local lname : variable label `mivar'
		sum `mivar'
		local fac=1
		local unit=""
		if r(min)>=0 & r(max)<=1 {
			local fac=100
			local unit="\%"
		}
		
		sum `mivar' if $condic
		local myMean : di %4.2f r(mean)*`fac'

		rd `mivar' sis01 if $condic  & age<=64 , z0(0) mbw(100)
		myCoeff 2 `fac'
		local h=e(w)
			
		reg `mivar' expSis sis01 i.expSis#c.sis01  if $condic & sis01>-`h' & sis01<`h' & age<=64 , r
		myCoeff 3 `fac'
		glo ene3=e(N)

		local diH : di %3.2f `h'

		tex \parbox[c]{5cm}{\raggedright `lname' }                    & $ `myMean'`unit' $ & $ $coef2 $star2 $  \\
		tex $ \quad$ {\scriptsize\textit{N: $ene3 $ ( h^*=`diH' )$ }} &          & $ ($se2 $)         \\
	}
	qui {
		tex \bottomrule
		tex \multicolumn{3}{l}{\parbox[c]{9cm}{Robust SE in parenthesis. Significance: * 10\%, ** 5\%, *** 1\%.  }} \\
		tex \end{tabularx}
		tex }
		tex \end{table}			
		texdoc close		
	}
}

}
* **************************************************************	
* 4. McCrary Density Tests
* **************************************************************
if 1==0 {

 cd "$dropbox\Health and Labour Supply\Elsa"
use ELSA_NatCen_SmokingBeliefs.dta, clear
cd "$dropbox\Health and Labour Supply\Presentation\tablas"

* Iullastrative purposes
DCdensity sis01 if $condic & age<=64, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
disp 2*(1-normal( abs(r(theta) /r(se)) ) )
drop Yj Xj r0 fhat se_fhat

* Table multiple bin sizes
local listVals="0.5 0.7 0.9 1 1.1 1.3 1.5"
local numVals: word count `listVals'
local colsR=`numVals'+1

qui {
	texdoc init basicMcCrary , replace
	tex \begin{table}[H]
	tex \centering
	tex \scalebox{0.6}{
	tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
	tex \begin{tabularx} {16cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
	tex \toprule
	tex & \multicolumn{`numVals'}{c}{ Bin Size (SD) }\\	
}

	* The test using the optimal bandwidht 
	DCdensity sis01 if $condic & age<=64, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) nograph
	disp 2*(1-normal( abs(r(theta) /r(se)) ) )
	drop Yj Xj r0 fhat se_fhat
	local bstar=r(binsize)
	disp "Optimal bi size is: `bstar'"

	tex 
	local cont=1
	foreach value in `listVals' {
		local bstar2=`bstar'*`value'
			disp "Current value is `value', that is, a bin size of `bstar2'"
		qui DCdensity sis01 if $condic & age<=64, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) b(`bstar2') nograph
		glo binwd`cont' : di %7.3f `bstar2'
		glo theta`cont' : di %7.2f r(theta)
		glo se`cont'    : di %7.2f r(se)
		scalar pval= 2*(1-normal( abs(r(theta) /r(se)) ) )
			glo star`cont' = ""
			if ((pval < 0.1) )  glo star`cont' = "^{*}" 
			if ((pval < 0.05) ) glo star`cont' = "^{**}" 
			if ((pval < 0.01) ) glo star`cont' = "^{***}" 	
		drop Yj Xj r0 fhat se_fhat
		
		disp "B: ${binwd`cont'},  Theta: ${theta`cont'} (${se`cont'}), pval:"
		disp pval
		
		* Bin size. Which is the optimal?
		if(`value'==1){
			tex & \textbf{${binwd`cont'} $ \dagger $}
		}
		else {
			tex & ${binwd`cont'}
		}
		
		local cont=`cont'+1
	}
	tex \\
	tex \midrule
	tex Density Jump 
	* Coefficients
	forval i=1(1)`numVals' {
		tex & $ ${theta`i'} ${star`i'} $
	}
	tex \\
	tex 	
	* Std Errors
	forval i=1(1)`numVals' {
		tex & (${se`i'})
	}
	tex \\

qui {
	tex \bottomrule
	tex \multicolumn{`colsR'}{l}{\parbox[c]{16cm}{SE in parenthesis. Significance: * 10\%, ** 5\%, *** 1\%. Triangular kernels are fitted ///
											on the means of the bins of a particular bin size. The optimal bin size$ \dagger $ and the bandwidths are chosen following ///
											McCrary implementation of the test. }} \\		
	tex \end{tabularx}
	tex }
	tex \end{table}			
	texdoc close		
}

}
* **************************************************************	
* 5. Main Results
* **************************************************************
if 1==0 {

 cd "$dropbox\Health and Labour Supply\Elsa"
use ELSA_NatCen_SmokingBeliefs.dta, clear
cd "$dropbox\Health and Labour Supply\Presentation\tablas"

glo vars1= "hibpe bppills heart goodHealth badHealth ssp75"
glo vars2= "smoken smokeInt heskb heskc alco1 dphy1"
glo vars3= "totinc_bu_s savings_bu_s nettotw_bu_s hours_aj wpactive"

glo titulo1 = "Lifestyle"
glo titulo2 = "Health"
glo titulo3 = "Economic"


forval set=1(1)3 {
	qui {
		texdoc init mainRes_`set' , replace
		tex \begin{table}[H]
		tex \centering
		tex \scalebox{0.6}{
		tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
		tex \begin{tabularx} {9cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
		tex \multicolumn{3}{l}{\parbox[c]{9cm}{\centering ${titulo`set'} }} \\
		tex \multicolumn{3}{l}{\parbox[c]{9cm}{For those aged 64 or less }} \\		
		tex \toprule
		tex \parbox[c]{5cm}{\centering Dependent Variable} & $ \parbox[c]{2cm}{\centering $ \bar{X}$ } $ & \parbox[c]{2cm}{\centering L. Linear Tri $ h^*$ SD}  \\
		tex \midrule 
	}
	foreach mivar in  ${vars`set'}    {


		local lname : variable label `mivar'
		sum `mivar'
		local fac=1
		local unit=""
		if r(min)>=0 & r(max)<=1 {
			local fac=100
			local unit="\%"
		}
		
		sum `mivar' if $condic
		local myMean : di %4.2f r(mean)*`fac'
			
		
		rd `mivar' sis01 if $condic  & age<=64 , z0(0) mbw(100)
		myCoeff 2 `fac'
		local h=e(w)
			
		reg `mivar' expSis sis01 i.expSis#c.sis01 if $condic & sis01>-`h' & sis01<`h' & age<=64 , r
		myCoeff 3 100
		glo ene3=e(N)
		
		local diH : di %3.2f `h'	
		
		tex \parbox[c]{5cm}{\raggedright `lname' }                    & $ `myMean'`unit' $ & $ $coef2 $star2 $  \\
		tex $ \quad$ {\scriptsize\textit{N: $ene3 $ ( h^*=`diH' )$ }} &          & $ ($se2 $)         \\
	}
	qui {
		tex \bottomrule
		tex \multicolumn{3}{l}{\parbox[c]{9cm}{Robust SE in parenthesis. Significance: * 10\%, ** 5\%, *** 1\%.  }} \\
		tex \end{tabularx}
		tex }
		tex \end{table}			
		texdoc close		
	}
}


}
* **************************************************************	
* 6. RDD Heterogenous
* **************************************************************
if 1==0 {

 cd "$dropbox\Health and Labour Supply\Elsa"
use ELSA_NatCen_SmokingBeliefs.dta, clear
cd "$dropbox\Health and Labour Supply\Presentation\tablas"

gen uno=1

gen HigExpecHealt=L.ssp75>=80 if ssp75!=.
gen first =wave==1
gen second=wave==3
gen third =wave==5

gen LgoodHealth=L.goodHealth
label var LgoodHealth "SR good health baseline"

label var parentDCard "Parents CVD mortality "
label var HigExpecHealt " SSP75 $ \geq$ 80 "
label var first  "Wave 0 measures" 
label var second "Wave 2 measures" 
label var third  "Wave 4 measures" 

qui {
	texdoc init rddHeterog , replace
	tex \begin{table}[H]
	tex \centering
	tex \scalebox{0.57}{
	tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
	tex \begin{tabularx} {17cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
	tex \multicolumn{7}{l}{\parbox[c]{17cm}{\centering For those aged 64 or less }} \\		
	tex \toprule
	tex \parbox[c]{1.6cm}{\centering Restriction $ X_i$ } & \parbox[c]{1.6cm}{\centering HBP} & \parbox[c]{1.6cm}{\centering PILLS} & \parbox[c]{1.6cm}{\centering SMOKE} & \parbox[c]{1.6cm}{\centering ALCOHOL} & \parbox[c]{1.6cm}{\centering BAD H} & \parbox[c]{1.6cm}{\centering SAVINGS} \\
	tex \midrule 
}

foreach var in uno LgoodHealth parentDCard HigExpecHealt {

	local title : variable label `var'		
	if "`var'"!="uno" tex \multicolumn{6}{l}{\parbox[c]{15cm}{\textbf{`title'} }} \\	

	foreach i in 1 0 {
		if "`var'"!="uno" | ("`var'"=="uno" & `i'==1) {
		
			disp "`var', `title', `i'"
			qui reg hibpe sis01 bppills smoken alco1 heart  if $condic & `var'==`i' & age<=64
			cap drop mySample
			gen mySample=e(sample)
			
			rd hibpe sis01 if $condic & `var'==`i' & age<=64 & mySample==1, z0(0) mbw(100)
			myCoeff 1 100
			glo ene1=e(N)

			rd bppills sis01 if $condic & `var'==`i' & age<=64 & mySample==1, z0(0) mbw(100)
			myCoeff 2 100
			glo ene2=e(N)
			
			rd smoken sis01 if $condic & `var'==`i' & age<=64 & mySample==1, z0(0) mbw(100)
			myCoeff 3 100
			glo ene3=e(N)

			rd alco1 sis01 if $condic & `var'==`i' & age<=64 & mySample==1, z0(0) mbw(100)
			myCoeff 4 100
			glo ene4=e(N)

			rd badHealth sis01 if $condic & `var'==`i' & age<=64 & mySample==1, z0(0) mbw(100)
			myCoeff 5 100
			glo ene5=e(N)
			
			rd savings_bu_s sis01 if $condic & `var'==`i' & age<=64 & mySample==1, z0(0) mbw(100)
			myCoeff 6 1
			glo ene6=e(N)	
			
			if ("`var'"=="uno") {
				local labelo="Everyone"
			}
			else {
				if `i'==1 local labelo=" $ \quad$ Yes "
				if `i'==0 local labelo=" $ \quad$ No "
			}
			
			tex \parbox[c]{5cm}{\raggedright  `labelo' } & $ $coef1 $star1 $ & $ $coef2 $star2 $ & $ $coef3 $star3 $ & $ $coef4 $star4 $ & $ $coef5 $star5 $  & $ $coef6 $star6 $ \\
			tex $ \quad \quad$ {\scriptsize\textit{N obs: $ene1 }} & $ ($se1) $        & $ ($se2 $)        & $ ($se3 $)        & $ ($se4 $)      & ($ $se5 $) & ($ $se6 $)  \\
		}	
		else {
			disp "Nothing should happen"
		}	
	}
	tex \midrule
}

qui {
	tex \bottomrule
	tex \multicolumn{7}{l}{\parbox[c]{9cm}{Robust SE in parenthesis. Significance: * 10\%, ** 5\%, *** 1\%. Same sample across outcomes, using triangular kernels with the optimal bandwidht.  }} \\
	tex \end{tabularx}
	tex }
	tex \end{table}			
	texdoc close		
}


}
* **************************************************************	
* 7. Two waves ahead
* **************************************************************
if 1==0 {


 cd "$dropbox\Health and Labour Supply\Elsa"
use ELSA_NatCen_SmokingBeliefs.dta, clear
cd "$dropbox\Health and Labour Supply\Presentation\tablas"

xtset idauniq wave 

label var bmival "BMI"
label var alco1100 "Alcohol more than once a week"
label var hdl "HDL Colesterol (mmol/l)"
label var chol "Total Colesterol (mmol/l)"
label var sysval "Mean systolic BP (mmHg)"

*gen fat=bmival>=30
label var fat "Obesity (BMI $ \geq$ 30)"

glo vars1= "hibpe bppills heart goodHealth ssp75 bmival hdl chol sysval"
glo vars2= "smoken smokeInt heskb heskc alco1 dphy1"
glo vars3= "totinc_bu_s savings_bu_s nettotw_bu_s hours_aj wpactive"


glo titulo1 = "Lifestyle and health (2 waves)"
glo titulo2 = "Economic (2 waves)"

forval set=1(1)3 {
	qui {
		texdoc init mainRes2W_`set' , replace
		tex \begin{table}[H]
		tex \centering
		tex \scalebox{0.6}{
		tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
		tex \begin{tabularx} {9cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
		tex \multicolumn{3}{l}{\parbox[c]{9cm}{\centering ${titulo`set'} }} \\
		tex \multicolumn{3}{l}{\parbox[c]{9cm}{For those aged 64 or less }} \\		
		tex \toprule
		tex \parbox[c]{5cm}{\centering Dependent Variable} & $ \parbox[c]{2cm}{\centering $ \bar{X}$ } $ & \parbox[c]{2cm}{\centering L. Linear Tri $ h^*$ SD}  \\
		tex \midrule 
	}
	foreach mivar in  ${vars`set'}    {

		gen F`mivar'=F.`mivar'
	
		local lname : variable label `mivar'
		sum `mivar'
		local fac=1
		local unit=""
		if r(min)>=0 & r(max)<=1 {
			local fac=100
			local unit="\%"
		}
		
		sum F`mivar' if $condic
		local myMean : di %4.2f r(mean)*`fac'
			
		
		rd F`mivar' sis01 if $condic  & age<=64 , z0(0) mbw(100)
		myCoeff 2 `fac'
		local h=e(w)
			
		reg F`mivar' expSis sis01 i.expSis#c.sis01 if $condic & sis01>-`h' & sis01<`h' & age<=64 , r
		myCoeff 3 `fac'
		glo ene3=e(N)
		
		local diH : di %3.2f `h'	
		
		tex \parbox[c]{5cm}{\raggedright `lname' }                    & $ `myMean'`unit' $ & $ $coef2 $star2 $  \\
		tex $ \quad$ {\scriptsize\textit{N: $ene3 $ ( h^*=`diH' )$ }} &          & $ ($se2 $)         \\
	}
	qui {
		tex \bottomrule
		tex \multicolumn{3}{l}{\parbox[c]{9cm}{Robust SE in parenthesis. Significance: * 10\%, ** 5\%, *** 1\%.  }} \\
		tex \end{tabularx}
		tex }
		tex \end{table}			
		texdoc close		
	}
}



}
