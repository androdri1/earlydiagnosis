  ////////////////////////////////////////////////////////////////
 // ***************** 4. Assumptions Tests ******************* //
////////////////////////////////////////////////////////////////
* 2014.07.08
* Paul Rodriguez-Lesmes <p.lesmes.11@ucl.ac.uk>
clear all
matrix drop _all
cap texdoc close
* **************************************************************
* PLEASE NOTICE THIS:
*tabstat sis01, by(sis1) /*  The 140 IS NOT ALWAYS the 0, due to */
                        /*  a different definition in the HSE  */
*tabstat sis01 if wave>1, by(sis1)            /* Ok, 140 */
*tabstat sis01 if wave<2 & masc==0 , by(sis1) /* Ok, 140 */
*tabstat sis01 if wave<2 & masc==1 & age<=50, by(sis1) /* Ok, 140 */
*tabstat sis01 if wave<2 & masc==1 & age>50, by(sis1)  /* Ok, 160 */
* **************************************************************

// glo dropbox="C:\Users\andro\Dropbox"
glo dropbox="D:\Paul.Rodriguez\Universidad del rosario\Proyectos ELSA - Documentos\"
*glo dropbox= "C:\Users\msofi\Universidad del rosario\Proyectos ELSA - Documentos\"


// glo tablas="$dropbox\Health and Labour Supply\RDpaper Text\2018.07. Journal of the Economics of Ageing RR\tablas"
// glo images = "$dropbox\Health and Labour Supply\RDpaper Text\2018.07. Journal of the Economics of Ageing RR\imagenes"
glo tablas="$dropbox\RDpaper Text\2021.05 Plos One RR1\tablas"
glo images = "$dropbox\RDpaper Text\2021.05 Plos One RR1\imagenes"

// do "$dropbox\Health and Labour Supply\RDpaper Text\syntax\HBPRD0_Programs.do"
do "$dropbox\RDpaper Text\syntax\HBPRD0_Programs.do"

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// cd "$dropbox\Health and Labour Supply\ELSA"
cd "$dropbox\ELSA"
use ELSA_NatCen_2017PROC.dta, clear
sum sysval if abs(sis01-1)>0.01
glo SD1 : disp %4.2f r(sd)

glo condic  ="Lhibpe==0 & Lbppills==0 & Ldiab==0 & interBefo==1"

gen Lnettotw_bu_s=L.nettotw_bu_s
xtile tW=Lnettotw_bu_s, n(2)

gen Llogotinc_bu=L.Yotinc_bu
*gen Llogotinc_bu=Yotinc_bu
xtile tYP=Llogotinc_bu, n(2)


foreach varDep in hibpe bppills sis1 bmival alcoM { // chole diab lipidpill heartMa goodHealth anyGeffort smoken smokeInt3b alcoM phyact scveg scfru
	cap gen F`varDep'=F.`varDep'
}
label var Fhibpe "Diagnosed HBP "
label var Fbppills "Takes BP medication "
label var Fsis1 "Systolic Blood Pressure "
label var Fbmival "Body Mass Index "
label var FalcoM "Alcohol twice a week or more"

label var bmival "Body Mass Index"
label var sysval "Systolic BP"
label var diaval "Diastolic BP"

* *****************************************************************************
* 1. Main results with fixed bandwidth
* *****************************************************************************
if 1==0 {
	cd "$tablas"

	glo conda "& $condic" 

	* ******************************************************************************		
	* Latex table 		
		glo nCol=10
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResults_fixedBW , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status: fixed bandwidth \label{tab:mainResults_fixedBW}}
		tex \begin{adjustwidth}{-2.25in}{0in}
		tex \begin{adjustbox}{max totalheight=1.5\textheight, max width=1.45\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{3}{c}{h=10} & \multicolumn{3}{c}{h=14} & \multicolumn{3}{c}{h=18} \\
		tex Dependent Variable & Before BP test & 2 years & 4 years & Before BP test & 2 years & 4 years & Before BP test & 2 years & 4 years \\
		tex                    & $ t=0$ & $ t=1$ & $ t=2$ & $ t=0$ & $ t=1$ & $ t=2$ & $ t=0$ & $ t=1$ & $ t=2$  \\

		* End head .................................................................

	local varlist1 missing died	
	local varlist2 hibpe bppills
	*local varlist3 smoken smokeInt3b alcoM dphy1 
	local varlist3 diab heartMa goodHealth sysval diaval bmival

	local title1 "Panel A. Attrition "		
	local title2 "Panel B. High Blood Pressure"
	*local title3 "Panel C. Lifestyle"
	local title3 "Panel C. Health"
	
	forval i=1(1)3 {	// No economic activity
		tex \cmidrule(l){2-4} \cmidrule(l){5-7} \cmidrule(l){8-10}
		tex \multicolumn{4}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
		
			cap drop L`myVar'
			cap drop F`myVar'
			cap gen L`myVar'=L.`myVar'
			cap gen F`myVar'=F.`myVar'
			
			local lname : variable label `myVar'
	
			glo line1=""
			glo line2=""
			glo line3=""
			glo line4=""
			foreach h in 10 14 18 {
				glo opti ="h(`h')"	// Independent bandwidth per side
				* Sharp RDD 0 Y...............................................................
				cap rdrobust L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti 
				if _rc==0 & ("`myVar'"!="hibpe" & "`myVar'"!="bppills" & "`myVar'"!="diab" & "`myVar'"!="missing" & "`myVar'"!="died") {
					loc b     : disp %5.3f e(tau_cl)
					loc se    : disp %5.3f e(se_tau_cl)
					loc pval  : disp %4.3f e(pv_cl)
					loc pvalr : disp %4.3f e(pv_rb)
					loc hl    : disp %4.1f e(h_l)
					loc hr    : disp %4.1f e(h_r)
					loc enel  = e(N_h_l)
					loc ener  = e(N_h_r)		

					glo coef1_`h'="`b'"
					glo star1_`h'="[`pvalr']"
					glo sep1_`h'="(`se')"		
					glo bw1_`h' =" h=`hl'/`hr',"
					glo ene1_`h' =" N=`enel'/`ener'"				
				}
				else {
					glo coef1_`h'=""
					glo star1_`h'=""
					glo sep1_`h'=""	
					glo bw1_`h' =""
					glo ene1_`h' =""								
				}
				
				* Sharp RDD 2 Y...............................................................
				cap rdrobust `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti
				if _rc==0 & `i'!=5 {	
					loc b     : disp %5.3f e(tau_cl)
					loc se    : disp %5.3f e(se_tau_cl)
					loc pval  : disp %4.3f e(pv_cl)
					loc pvalr : disp %4.3f e(pv_rb)
					loc hl    : disp %4.1f e(h_l)
					loc hr    : disp %4.1f e(h_r)
					loc enel  = e(N_h_l)
					loc ener  = e(N_h_r)

					glo coef2_`h'="`b'"
					glo star2_`h'="[`pvalr']"
					glo sep2_`h'="(`se')"	
					glo bw2_`h' =" h=`hl'/`hr',"
					glo ene2_`h' =" N=`enel'/`ener'"								
				}
				else {
					glo coef2_`h'=""
					glo star2_`h'=""
					glo sep2_`h'=""			
					glo bw2_`h' =""
					glo ene2_`h' =""				
				}			
				
				* Sharp RDD 4 Y...............................................................
				cap rdrobust F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti
				if _rc==0 {		
					loc b     : disp %5.3f e(tau_cl)
					loc se    : disp %5.3f e(se_tau_cl)
					loc pval  : disp %4.3f e(pv_cl)
					loc pvalr : disp %4.3f e(pv_rb)
					loc hl    : disp %4.1f e(h_l)
					loc hr    : disp %4.1f e(h_r)
					loc enel  = e(N_h_l)
					loc ener  = e(N_h_r)
					
					glo coef3_`h'="`b'"
					glo star3_`h'="[`pvalr']"
					glo sep3_`h'="(`se')"		
					glo bw3_`h' =" h=`hl'/`hr'"
					glo ene3_`h' =" N=`enel'/`ener'"								
				}
				else {
					glo coef3_`h'=""
					glo star3_`h'=""
					glo sep3_`h'=""			
					glo bw3_`h' =""
					glo ene3_`h' =""				
				}		
				
				forval k=1(1)3 {
					glo line1="$line1 & $ ${coef`k'_`h'} $            "
					glo line2="$line2 & $ ${sep`k'_`h'}  ${star`k'_`h'} $ "
					glo line3="$line3 & ${bw`k'_`h'}        "		
					glo line4="$line4 & ${ene`k'_`h'}        "	
				}				
			}	
			
			disp "`lname'   $line1 "
			disp "          $line2 "
			disp "          $line3 "
			disp "          $line4 "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{4cm}{\raggedright `lname' }   $line1 \\
			tex                                          $line2 \\
			tex                                          $line3 \\	
			tex                                          $line4 \\
			tex \addlinespace[2pt]
			
		}
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{22cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. ///
			It includes only those respondents aged 58 or younger at the time of the measurement who were not diagnosed with HBP or diabetes, and not taking BP-lowering medication. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{22cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
			In the first set of brackets the conventional p-value is presented, while the second corresponds to the robust inference version derived by Calonico, Cattaneo, Titiunik (2014). }} \\
		tex \end{tabular}
		tex \end{adjustbox}
		tex \end{adjustwidth}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	

}

* *****************************************************************************
* 2. Main results with different polynomial order
* *****************************************************************************
if 1==0 {
	cd "$tablas"

	glo conda "& $condic" 

	* ******************************************************************************		
	* Latex table 		
		glo nCol=10
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResults_polOrd , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status: polynomial order \label{tab:mainResults_polOrd}}
		tex \begin{adjustwidth}{-2.25in}{0in}
		tex \begin{adjustbox}{max totalheight=1.5\textheight, max width=1.45\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{3}{c}{p=1} & \multicolumn{3}{c}{p=2} & \multicolumn{3}{c}{p=3} \\
		tex Dependent Variable & Before BP test & 2 years & 4 years & Before BP test & 2 years & 4 years & Before BP test & 2 years & 4 years  \\
		tex                    & $ t=0$ & $ t=1$ & $ t=2$ & $ t=0$ & $ t=1$ & $ t=2$ & $ t=0$ & $ t=1$ & $ t=2$  \\

		* End head .................................................................

	local varlist1 missing died	
	local varlist2 hibpe bppills
	*local varlist3 smoken smokeInt3b alcoM dphy1 
	local varlist3 diab heartMa goodHealth sysval diaval bmival

	local title1 "Panel A. Attrition "		
	local title2 "Panel B. High Blood Pressure"
	*local title3 "Panel D. Lifestyle"
	local title3 "Panel C. Health"	

	forval i=1(1)3 {	
		tex \cmidrule(l){2-4} \cmidrule(l){5-7} \cmidrule(l){8-10}
		tex \multicolumn{4}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
		
			cap drop L`myVar'
			cap drop F`myVar'
			cap gen L`myVar'=L.`myVar'
			cap gen F`myVar'=F.`myVar'
			
			local lname : variable label `myVar'
	
			glo line1=""
			glo line2=""
			glo line3=""
			glo line4=""
			foreach p in 1 2 3 {
				glo opti ="bwselect(msetwo) p(`p')"	// Independent bandwidth per side, specific polynomial
				* Sharp RDD 0 Y...............................................................
				cap rdrobust L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti 
				if _rc==0 & ("`myVar'"!="hibpe" & "`myVar'"!="bppills" & "`myVar'"!="diab" & "`myVar'"!="missing" & "`myVar'"!="died") {
					loc b     : disp %5.3f e(tau_cl)
					loc se    : disp %5.3f e(se_tau_cl)
					loc pval  : disp %4.3f e(pv_cl)
					loc pvalr : disp %4.3f e(pv_rb)
					loc hl    : disp %4.1f e(h_l)
					loc hr    : disp %4.1f e(h_r)
					loc enel  = e(N_h_l)
					loc ener  = e(N_h_r)		

					glo coef1_`p'="`b'"
					glo star1_`p'="[`pvalr']"
					glo sep1_`p'="(`se')"		
					glo bw1_`p' =" h=`hl'/`hr',"
					glo ene1_`p' =" N=`enel'/`ener'"				
				}
				else {
					glo coef1_`p'=""
					glo star1_`p'=""
					glo sep1_`p'=""	
					glo bw1_`p' =""
					glo ene1_`p' =""								
				}
				
				* Sharp RDD 2 Y...............................................................
				cap rdrobust `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti
				if _rc==0 & `i'!=5 {
					loc b     : disp %5.3f e(tau_cl)
					loc se    : disp %5.3f e(se_tau_cl)
					loc pval  : disp %4.3f e(pv_cl)
					loc pvalr : disp %4.3f e(pv_rb)
					loc hl    : disp %4.1f e(h_l)
					loc hr    : disp %4.1f e(h_r)
					loc enel  = e(N_h_l)
					loc ener  = e(N_h_r)

					glo coef2_`p'="`b'"
					glo star2_`p'="[`pvalr']"
					glo sep2_`p'="(`se')"	
					glo bw2_`p' =" h=`hl'/`hr'"
					glo ene2_`p' =" N=`enel'/`ener'"								
				}
				else {
					glo coef2_`p'=""
					glo star2_`p'=""
					glo sep2_`p'=""			
					glo bw2_`p' =""
					glo ene2_`p' =""				
				}			
				
				* Sharp RDD 4 Y...............................................................
				cap rdrobust F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti
				if _rc==0 {		
					loc b     : disp %5.3f e(tau_cl)
					loc se    : disp %5.3f e(se_tau_cl)
					loc pval  : disp %4.3f e(pv_cl)
					loc pvalr : disp %4.3f e(pv_rb)
					loc hl    : disp %4.1f e(h_l)
					loc hr    : disp %4.1f e(h_r)
					loc enel  = e(N_h_l)
					loc ener  = e(N_h_r)
					
					glo coef3_`p'="`b'"
					glo star3_`p'="[`pvalr']"
					glo sep3_`p'="(`se')"		
					glo bw3_`p' =" h=`hl'/`hr',"
					glo ene3_`p' =" N=`enel'/`ener'"								
				}
				else {
					glo coef3_`p'=""
					glo star3_`p'=""
					glo sep3_`p'=""			
					glo bw3_`p' =""
					glo ene3_`p' =""				
				}	
				
				forval k=1(1)3 {
					glo line1="$line1 & $ ${coef`k'_`p'} $            "
					glo line2="$line2 & $ ${sep`k'_`p'}  ${star`k'_`p'} $ "
					glo line3="$line3 & ${bw`k'_`p'}        "		
					glo line4="$line4 & ${ene`k'_`p'}        "
				}
				
			}	
			
			disp "`lname'   $line1 "
			disp "          $line2 "
			disp "          $line3 "
			disp "          $line4 "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{4cm}{\raggedright `lname' }   $line1 \\
			tex                                          $line2 \\
			tex                                          $line3 \\	
			tex                                          $line4 \\
			tex \addlinespace[2pt]
			
		}
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{22cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. ///
			It includes only those respondents aged 58 or younger at the time of the measurement who were not diagnosed with HBP or diabetes, and not taking BP-lowering medication. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{22cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
			In the first set of brackets the conventional p-value is presented, while the second corresponds to the robust inference version derived by Calonico, Cattaneo, Titiunik (2014). }} \\
		tex \end{tabular}
		tex \end{adjustbox}
		tex \end{adjustwidth}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	

}

* *****************************************************************************
* 3. Main results including covariates
* *****************************************************************************
if 1==0 {
	cd "$tablas"

	glo conda "& $condic" 
	glo opti ="bwselect(msetwo)"
	
	glo covseto1 age masc nonwhite dedu_2 dedu_3 married
	glo covseto2 $covseto1 goodHealth  bmival 
	glo covseto3 $covseto2 smoken alcoM
	
	forval i=1(1)3 {
		glo covset`i'=""
		foreach varDep in ${covseto`i'} {
			cap gen L`varDep'= L.`varDep'
			glo covset`i'="${covset`i'} L`varDep' "
		}
	}
	
	* ******************************************************************************		
	* Latex table 		
		glo nCol=10
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResults_covars , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status: including covariates \label{tab:mainResults_covars}}
		tex \begin{adjustwidth}{-2.25in}{0in}
		tex \begin{adjustbox}{max totalheight=1.5\textheight, max width=1.45\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & 	\multicolumn{3}{c}{ \parbox[c]{5cm}{Panel A: age, male, non-white, married, and education level dummies } } & ///
				\multicolumn{3}{c}{ \parbox[c]{5cm}{Panel B: + being on good health, BMI } } & ///
				\multicolumn{3}{c}{ \parbox[c]{5cm}{Panel C: + current smoker, alcohol intake twice a week or more} } \\
		tex Dependent Variable & Before BP test & 2 years & 4 years & Before BP test & 2 years & 4 years & Before BP test & 2 years & 4 years  \\
		tex                    & $ t=0$ & $ t=1$ & $ t=2$ & $ t=0$ & $ t=1$ & $ t=2$ & $ t=0$ & $ t=1$ & $ t=2$  \\

		* End head .................................................................

	local varlist1 missing died	
	local varlist2 hibpe bppills
	*local varlist3 smoken smokeInt3b alcoM dphy1 
	local varlist3 diab heartMa goodHealth sysval diaval bmival

	local title1 "Panel A. Attrition "		
	local title2 "Panel B. High Blood Pressure"
	*local title3 "Panel C. Lifestyle"
	local title3 "Panel C. Health"	

	forval i=1(1)3 {	
		tex \cmidrule(l){2-4} \cmidrule(l){5-7} \cmidrule(l){8-10}
		tex \multicolumn{4}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
		
			cap drop L`myVar'
			cap drop F`myVar'
			cap gen L`myVar'=L.`myVar'
			cap gen F`myVar'=F.`myVar'
			
			local lname : variable label `myVar'
	
			glo line1=""
			glo line2=""
			glo line3=""
			glo line4=""
			foreach p in 1 2 3 {

				* Sharp RDD 0 Y...............................................................
				cap rdrobust L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti covs(${covset`p'})
				if _rc==0 & ("`myVar'"!="hibpe" & "`myVar'"!="bppills" & "`myVar'"!="diab" & "`myVar'"!="missing" & "`myVar'"!="died") {
					loc b     : disp %5.3f e(tau_cl)
					loc se    : disp %5.3f e(se_tau_cl)
					loc pval  : disp %4.3f e(pv_cl)
					loc pvalr : disp %4.3f e(pv_rb)
					loc hl    : disp %4.1f e(h_l)
					loc hr    : disp %4.1f e(h_r)
					loc enel  = e(N_h_l)
					loc ener  = e(N_h_r)		

					glo coef1_`p'="`b'"
					glo star1_`p'="[`pvalr']"
					glo sep1_`p'="(`se')"		
					glo bw1_`p' =" h=`hl'/`hr',"
					glo ene1_`p' =" N=`enel'/`ener'"				
				}
				else {
					glo coef1_`p'=""
					glo star1_`p'=""
					glo sep1_`p'=""	
					glo bw1_`p' =""
					glo ene1_`p' =""								
				}
				
				* Sharp RDD 2 Y...............................................................
				cap rdrobust `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  covs(${covset`p'})
				if _rc==0 & `i'!=5 {
					loc b     : disp %5.3f e(tau_cl)
					loc se    : disp %5.3f e(se_tau_cl)
					loc pval  : disp %4.3f e(pv_cl)
					loc pvalr : disp %4.3f e(pv_rb)
					loc hl    : disp %4.1f e(h_l)
					loc hr    : disp %4.1f e(h_r)
					loc enel  = e(N_h_l)
					loc ener  = e(N_h_r)

					glo coef2_`p'="`b'"
					glo star2_`p'="[`pvalr']"
					glo sep2_`p'="(`se')"	
					glo bw2_`p' =" h=`hl'/`hr'"
					glo ene2_`p' =" N=`enel'/`ener'"								
				}
				else {
					glo coef2_`p'=""
					glo star2_`p'=""
					glo sep2_`p'=""			
					glo bw2_`p' =""
					glo ene2_`p' =""				
				}			
				
				* Sharp RDD 4 Y...............................................................
				cap rdrobust F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  covs(${covset`p'})
				if _rc==0 {		
					loc b     : disp %5.3f e(tau_cl)
					loc se    : disp %5.3f e(se_tau_cl)
					loc pval  : disp %4.3f e(pv_cl)
					loc pvalr : disp %4.3f e(pv_rb)
					loc hl    : disp %4.1f e(h_l)
					loc hr    : disp %4.1f e(h_r)
					loc enel  = e(N_h_l)
					loc ener  = e(N_h_r)
					
					glo coef3_`p'="`b'"
					glo star3_`p'="[`pvalr']"
					glo sep3_`p'="(`se')"		
					glo bw3_`p' =" h=`hl'/`hr',"
					glo ene3_`p' =" N=`enel'/`ener'"								
				}
				else {
					glo coef3_`p'=""
					glo star3_`p'=""
					glo sep3_`p'=""			
					glo bw3_`p' =""
					glo ene3_`p' =""				
				}	
				
				forval k=1(1)3 {
					glo line1="$line1 & $ ${coef`k'_`p'} $            "
					glo line2="$line2 & $ ${sep`k'_`p'}  ${star`k'_`p'} $ "
					glo line3="$line3 & ${bw`k'_`p'}        "		
					glo line4="$line4 & ${ene`k'_`p'}        "
				}
				
			}	
			
			disp "`lname'   $line1 "
			disp "          $line2 "
			disp "          $line3 "
			disp "          $line4 "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{4cm}{\raggedright `lname' }   $line1 \\
			tex                                          $line2 \\
			tex                                          $line3 \\	
			tex                                          $line4 \\
			tex \addlinespace[2pt]
			
		}
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{22cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. ///
			It includes only those respondents aged 58 or younger at the time of the measurement who were not diagnosed with HBP or diabetes, and not taking BP-lowering medication. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{22cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
			In the first set of brackets the conventional p-value is presented, while the second corresponds to the robust inference version derived by Calonico, Cattaneo, Titiunik (2014). }} \\
		tex \end{tabular}
		tex \end{adjustbox}
		tex \end{adjustwidth}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	

}


* *****************************************************************************
* 4. Main results just for ELSA original membrs
* *****************************************************************************
if 1==0 {
	cd "$tablas"

	replace refreshtype=0 if wave==0 & refreshtype==. // By definition
	tab refreshtype, gen(d_typeRec)
	
	label var d_typeRec1 "From the original ELSA sample"
	label var d_typeRecO "From a refreshment sample"

	glo conda "& $condic & d_typeRec1==1" 
	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side
	
	
	* ******************************************************************************		
	* Latex table 		
		glo nCol=4
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResults_d_typeRec11 , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{Main results only for those from the original ELSA sample \label{tab:mainResults_d_typeRec11}}
		tex \begin{adjustwidth}{-2.25in}{0in}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\
		tex Dependent Variable & Before BP test & 2 years & 4 years \\
		tex                    & $ t=0$ & $ t=1$ & $ t=2$ \\

		* End head .................................................................
	*/	

	local varlist1 missing died	
	local varlist2 hibpe bppills
	local varlist3 smoken smokeInt3b alcoM dphy1 
	local varlist4 diab heartMa goodHealth bmival sysval diaval

	local title1 "Panel A. Attrition "		
	local title2 "Panel B. High Blood Pressure"
	local title3 "Panel C. Lifestyle"
	local title4 "Panel D. Health"
	

	forval i=1(1)4 {	// No economic activity
		tex \midrule
		tex \multicolumn{4}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
		
			cap drop L`myVar'
			cap drop F`myVar'
			cap gen L`myVar'=L.`myVar'
			cap gen F`myVar'=F.`myVar'
			
			local lname : variable label `myVar'
	

			* Sharp RDD 0 Y...............................................................
			cap rdrobust L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti 
			if _rc==0 {
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)		

				glo coef1="`b'"
				glo star1="[`pvalr']"
				glo sep1="(`se')"		
				glo bw1 =" h=`hl'/`hr',"
				glo ene1 =" N=`enel'/`ener'"				
			}
			else {
				glo coef1=""
				glo star1=""
				glo sep1=""	
				glo bw1 =""
				glo ene1 =""								
			}
			
			* Sharp RDD 2 Y...............................................................
			cap rdrobust `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti
			if _rc==0 & `i'!=5 {	
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)

				glo coef2="`b'"
				glo star2="[`pvalr']"
				glo sep2="(`se')"	
				glo bw2 =" h=`hl'/`hr',"
				glo ene2 =" N=`enel'/`ener'"								
			}
			else {
				glo coef2=""
				glo star2=""
				glo sep2=""			
				glo bw2 =""
				glo ene2 =""				
			}			
			
			* Sharp RDD 4 Y...............................................................
			cap rdrobust F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti
			if _rc==0 {		
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)
				
				glo coef3="`b'"
				glo star3="[`pvalr']"
				glo sep3="(`se')"		
				glo bw3 =" h=`hl'/`hr',"
				glo ene3 =" N=`enel'/`ener'"								
			}
			else {
				glo coef3=""
				glo star3=""
				glo sep3=""			
				glo bw3 =""
				glo ene3 =""				
			}			
				
			
			disp "`lname'   & $ $coef1 $        & $ $coef2 $        & $ $coef3 $"
			disp "          & $ $sep1  $star1 $ & $ $sep2  $star2 $ & $ $sep3  $star3 $"
			disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3 "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{4cm}{\raggedright `lname' }   &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $ \\
			tex                                          &  $ $sep1  $star1 $ &  $ $sep2  $star2 $ & $ $sep3  $star3 $ \\
			tex                                          &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3 \\	
			tex \addlinespace[2pt]
			
		}
		tex \\
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{14cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. ///
			It includes only those respondents aged 58 or younger at the time of the measurement who were not diagnosed with HBP or diabetes, and not taking BP-lowering medication. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{14cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
			In the first set of brackets the conventional p-value is presented, while the second corresponds to the robust inference version derived by Calonico, Cattaneo, Titiunik (2014). }} \\
		tex \end{tabular}
		tex \end{adjustwidth}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	

}


* **************************************************************	
* 5. Run it for different cut-offs
* **************************************************************
if 1==1 {

	glo conda "& $condic" 
	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side

	matrix drop _all
	qui {
		cd "$tablas"
			glo nCol=4
			glo nColm1=$nCol-1	
			cap texdoc close
			texdoc init rddPlacebo , replace force
			tex {
			tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
			tex \begin{table}[H]
			tex \centering
			tex \scriptsize		
			tex \caption{The effects of information on potential hypertension status \label{tab:mainResults}}
			tex \begin{adjustwidth}{-2.25in}{0in}
			tex \begin{tabular}{l*{$nColm1}{c}}			
			tex \toprule	
			tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\	
			tex Cutoff-value & HBP diagnosis & BP Pills & Alcohol 2 week or more \\	
			tex \midrule
	}

	foreach value in 117 120 123 125 127 130 133 135 137 140 142 145 147 150 153 155 157 160 163 {
		cap drop sis01X

		gen sis01X=(sis1-`value') if wave>1
		replace sis01X=(sis1-`value') if wave<2 & ( masc==0 | (masc==1 & age<=50) )
		replace sis01X=(sis1-`value'-20) if wave<2 &   masc==1 & age>=50 	

		foreach varDep in sis01X {
			gen X`varDep'=L.`varDep'
			drop `varDep'
			rename X`varDep' `varDep'
		}		
		
		disp " "
		disp "This is for the cutoff systolic BP=`value'"
		disp " "
		
		loc i=1
		foreach myVar in hibpe bppills alcoM smokeInt3b {
			local lname : variable label `myVar'
			cap rdrobust `myVar' sis01X if Lage<=58 $conda , deriv(0) $opti
			if _rc==0 & `i'!=5 {	
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)
				glo lb`i' =e(ci_l_rb)
				glo ub`i' =e(ci_r_rb)

				glo coef`i'="`b'"
				glo star`i'="[`pvalr']"
				glo sep`i'="(`se')"	
				glo bw`i' =" h=`hl'/`hr',"
				glo ene`i' =" N=`enel'/`ener'"								
			}
			else {
				glo coef`i'=""
				glo star`i'=""
				glo sep`i'=""			
				glo bw`i' =""
				glo ene`i'=""				
				glo lb`i' =0
				glo ub`i' =0			
			}	
			
			loc i=`i'+1
		}
		
		disp "Cutoff at = `value'   & $ $coef1 $        & $ $coef2 $              & $ $coef3 & $ $coef4 $ $"
		disp "          & $ $sep1  $star1 $ & $ $sep2  $star2 $ & $ $sep3  $star3 & $ $sep4  $star4 $ $"
		disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3     & $bw4  $ene4 "
		
		tex \rowcolor{Gray}
		tex Up to age at = `value' &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $        & $ $coef4 $ \\
		tex                        &  $ $sep1  $star1 $ &  $ $sep2  $star2 $ & $ $sep3  $star3 $ & $ $sep4  $star4 $ \\
		tex                        &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3       & $bw4  $ene4 \\	
		tex \addlinespace[2pt]
		
		
		* For the graph *********
		matrix miRes=nullmat(miRes) \ (`value',$coef1 , $lb1 ,$ub1 , $coef2 , $lb2 ,$ub2 , $coef3 , $lb3 ,$ub3  , $coef4 , $lb4 ,$ub4 )
		* ***********************	`value',$coef1 , $lb1 ,$ub1 , $coef2 , $lb2 ,$ub2 , $coef3 , $lb3 ,$ub3 )
		* ***********************	
	}


	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{14cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. ///
			It includes only those respondents aged 58 or younger at the time of the measurement who were not diagnosed with HBP or diabetes, and not taking BP-lowering medication. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{14cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
			In the first set of brackets the conventional p-value is presented, while the second corresponds to the robust inference version derived by Calonico, Cattaneo, Titiunik (2014). }} \\
		tex \end{tabular}
		tex \end{adjustwidth}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	

	* ****************************************************************
	* A graph with the coefficients
	* (`value',$coef1 , $lb1 ,$ub1 , $coef2 , $lb2 ,$ub2 , $coef3 , $lb3 ,$ub3 )

	 cap drop miRes*
	  svmat miRes
	rename  miRes1  rddPlacebo_th
	rename  miRes2  rddPlacebo_coef1
	rename  miRes3  rddPlacebo_lb1
	rename  miRes4  rddPlacebo_ub1
	rename  miRes5  rddPlacebo_coef2
	rename  miRes6  rddPlacebo_lb2
	rename  miRes7  rddPlacebo_ub2
	rename  miRes8  rddPlacebo_coef3
	rename  miRes9  rddPlacebo_lb3
	rename  miRes10 rddPlacebo_ub3
	rename  miRes11 rddPlacebo_coef4
	rename  miRes12 rddPlacebo_lb4
	rename  miRes13 rddPlacebo_ub4		

	twoway 	(rarea rddPlacebo_lb1 rddPlacebo_ub1 rddPlacebo_th, fintensity(20) lcolor(gs16) lwidth(none)) ///
			(connected rddPlacebo_coef1 rddPlacebo_th, msymbol(square)) , ///
		   legend( off ) xtitle(Point where SBP was centred) ///
		   xscale(r(117 163)) xlabel(120(5)160) ///
		   ytitle("% diagnosed with HBP") ///
		   yline(0 , lpattern(solid)) xline(140 , lpattern(solid)) ///
			scheme(Plotplainblind)  name(hibpe , replace)			
			
	twoway 	(rarea rddPlacebo_lb2 rddPlacebo_ub2 rddPlacebo_th, fintensity(20) lcolor(gs16) lwidth(none)) ///
			(connected rddPlacebo_coef2 rddPlacebo_th, msymbol(square)) , ///
		   legend( off ) xtitle(Point where SBP was centred) ///
		   xscale(r(117 163)) xlabel(120(5)160) ///
		   ytitle("% under BP lowering medication") ///	   
		   yline(0 , lpattern(solid)) xline(140 , lpattern(solid)) ///
			scheme(Plotplainblind)  name(bppills , replace)		
			
	twoway 	(rarea rddPlacebo_lb3 rddPlacebo_ub3 rddPlacebo_th, fintensity(20) lcolor(gs16) lwidth(none)) ///
			(connected rddPlacebo_coef3 rddPlacebo_th, msymbol(square)) , ///
		   legend( off ) xtitle(Point where SBP was centred) ///
		   xscale(r(117 163)) xlabel(120(5)160) ///
		   ytitle("% alcohol intake twice a week or more") ///	   
		   yline(0 , lpattern(solid)) xline(140 , lpattern(solid)) ///
			scheme(Plotplainblind)  name(alcoM , replace)				
			
	twoway 	(rarea rddPlacebo_lb4 rddPlacebo_ub4 rddPlacebo_th, fintensity(20) lcolor(gs16) lwidth(none)) ///
			(connected rddPlacebo_coef4 rddPlacebo_th, msymbol(square)) , ///
		   legend( off ) xtitle(Point where SBP was centred) ///
		   xscale(r(117 163)) xlabel(117(5)163) ///
		   ytitle("N cigarette per week") ///	   
		   yline(0 , lpattern(solid)) xline(140 , lpattern(solid)) ///
			scheme(Plotplainblind)  name(smokeInt3b , replace)							
			
	graph combine hibpe bppills alcoM smokeInt3b		
	graph export "$images\placeboCutoffsB.pdf" , as(pdf) replace
}


* **************************************************************	
* 6. Tests on the density
* **************************************************************	
if 1==0 {
* Iullastrative purposes
	preserve
	keep if $condic & Lage<=58

	DCdensity sis01 , breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
	disp 2*(1-normal( abs(r(theta) /r(se)) ) )
	drop Yj Xj r0 fhat se_fhat

	rddensity sis01 , plot plot_range(-22 22) graph_options(ytitle("Density") xtitle("SBP (mmHg)") legend(on position(6)))
	// -0.3609      0.7182
	graph export "$images\CataneoDensityTest.png", as(png) replace
	graph export "$images\CataneoDensityTest.pdf", as(pdf) replace
	
	restore

}
* **************************************************************	
* 4. Take out some of the observations at the point OLD
* **************************************************************	
if 1==0 {

qui {
	cd "$tablas"
	texdoc init rddObserMiddle , replace force
	tex {
	tex \footnotesize
	tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
	tex \begin{longtable}{l*{5}{c}}
		tex \toprule
		tex \caption{RDD sample restrictions \label{rddObserMiddle}}\\
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} \\
		tex \parbox[c]{1.6cm}{\centering Restriction $ \Omega$} & \parbox[c]{1.6cm}{\centering Quadratic 1 SD} & \parbox[c]{1.6cm}{\centering Loc Linear Rectangular $ h^*$} & \parbox[c]{1.6cm}{\centering Loc Linear Triangular $ h^*$} & \parbox[c]{1.6cm}{\centering Local Quad 1 SD } & \parbox[c]{1.6cm}{\centering Local Quad 2 SD} \\		
		tex \midrule
	tex \endfirsthead
		tex \caption[]{(Continued)} \\
		tex \toprule
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)}  \\
		tex \parbox[c]{1.6cm}{\centering Restriction $ \Omega$} & \parbox[c]{1.6cm}{\centering Quadratic 1 SD} & \parbox[c]{1.6cm}{\centering Loc Linear Rectangular $ h^*$} & \parbox[c]{1.6cm}{\centering Loc Linear Triangular $ h^*$} & \parbox[c]{1.6cm}{\centering Local Quad 1 SD } & \parbox[c]{1.6cm}{\centering Local Quad 2 SD} \\		
		tex \midrule
	tex \endhead
		tex \midrule \multicolumn{5}{r}{\emph{Continued on next page}}
	tex \endfoot
		tex \bottomrule
		dofooter
	tex \endlastfoot
}

glo myRest1 = " 1==1 "
glo labelRest1 "Without restriction"

* sum sis1 if sis01>=-.06 & sis01<0 & wave==3
* sum sis1 if sis01>=-.06 & sis01<0 & wave==1 & masc==1 & age>50
glo myRest2 = " !(sis01>=-.06 & sis01<0) "
glo labelRest2 "Taking out 139 mmHg$ \dagger$"

* sum sis1 if sis01>=-0.04 & sis01<0.04 & wave==3
* sum sis1 if sis01>=-0.04 & sis01<0.04 & wave==1 & masc==1 & age>50
glo myRest3 = " sis01!=0 "
glo labelRest3 "Taking out 140 mmHg$ \dagger$"

* sum sis1 if sis01>0 & sis01<=0.06 & wave==3
* sum sis1 if sis01>0 & sis01<=0.06 & wave==1 & masc==1 & age>50
glo myRest4 = " !(sis01>0 & sis01<=0.06) "
glo labelRest4 "Taking out 141 mmHg$ \dagger$"

glo myRest5 = " !(sis01>=-0.06 & sis01<0.06)  "
glo labelRest5 "Taking out 139-141 mmHg$ \dagger$"



forval i=1(1)5  {

	reg bppills expSis sis01 sis02  if $condic & sis01>-1 & sis01<1 & Lage<=58 & ${myRest`i'}, r
	myCoeff 1 100
	glo ene1=e(N)	
	
	rd bppills sis01 if $condic  & Lage<=58 & ${myRest`i'}, z0(0) mbw(100)
	myCoeff 2 100
	local h=e(w)	
	
	reg bppills expSis sis01 i.expSis#c.sis01  if $condic & sis01>-`h' & sis01<`h' & Lage<=58 & ${myRest`i'}, r
	myCoeff 3 100
	glo ene3=e(N)

	reg bppills expSis sis01 sis02 i.expSis#c.sis01 i.expSis#c.sis02 if $condic & sis01>-1 & sis01<1 & Lage<=58 & ${myRest`i'}, r
	myCoeff 4 100
	glo ene4=e(N)	

	reg bppills expSis sis01 sis02 i.expSis#c.sis01 i.expSis#c.sis02 if $condic & sis01>-2 & sis01<2 & Lage<=58 & ${myRest`i'}, r
	myCoeff 5 100
	glo ene5=e(N)	

	
	local diH : di %3.2f `h'

	tex \rowcolor{Gray}
	tex \parbox[c]{4cm}{\raggedright ${labelRest`i'} }                       & $ $coef1 $star1 $ & $ $coef2 $star2 $ & $ $coef3 $star3 $ & $ $coef4 $star4 $ & $ $coef5 $star5 $ \\
	tex $ \quad \quad$ {\scriptsize\textit{N: $ene3 $ ( h^*=`diH' )$, $ene4 $ (h=1)$ , $ene5 $ (h=2)$ }} & $ ($se1) $        & $ ($se2 $)        & $ ($se3 $)        & $ ($se4 $)        & ($ $se5 $)        \\
}
qui {
	tex \end{longtable}
	tex }
	texdoc close	
}


}
