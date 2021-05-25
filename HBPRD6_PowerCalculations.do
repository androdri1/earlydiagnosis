  ////////////////////////////////////////////////////////////////
 // ******************** 6. Power Calulations ********************* //
////////////////////////////////////////////////////////////////
* 2021.05.14
* Paul Rodriguez-Lesmes <paul.rodriguez@urosario.edu.co>
* Using dervide information from
*      SN: 5050 English Longitudinal Study of Ageing: Waves 0-7, 1998-2015
* Graphs use blindschemes schemes by Dan BISCHOF 
*    https://danbischof.com/2015/02/04/stata-figure-schemes/
* **************************************************************
* PLEASE NOTICE THIS:
*tabstat sis01, by(sis1) /*  The 140 IS NOT ALWAYS the 0, due to */
                        /*  a different definition in the HSE  */
*tabstat sis01 if wave>1, by(sis1)            /* Ok, 140 */
*tabstat sis01 if wave<2 & masc==0 , by(sis1) /* Ok, 140 */
*tabstat sis01 if wave<2 & masc==1 & age<=50, by(sis1) /* Ok, 140 */
*tabstat sis01 if wave<2 & masc==1 & age>50, by(sis1)  /* Ok, 160 */
* **************************************************************
* ssc install rdrobust
*net install rddensity, from(https://sites.google.com/site/rdpackages/rddensity/stata) replace
*net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace
* **************************************************************

clear all
cap texdoc close



*glo dropbox="C:\Users\andro\Dropbox"
*glo dropbox="D:\Paul.Rodriguez\Universidad del rosario\Proyectos ELSA - Documentos\"
glo dropbox= "C:\Users\msofi\Universidad del rosario\Proyectos ELSA - Documentos\"

*glo tablas="$dropbox\Health and Labour Supply\RDpaper Text\2018.07. Journal of the Economics of Ageing RR\tablas"
*glo images = "$dropbox\Health and Labour Supply\RDpaper Text\2018.07. Journal of the Economics of Ageing RR\imagenes"

glo tablas="$dropbox\RDpaper Text\2021.05 Plos One RR1\tablas"
glo images = "$dropbox\RDpaper Text\2021.05 Plos One RR1\imagenes"

do "$dropbox\RDpaper Text\syntax\HBPRD0_Programs.do"

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*cd "$dropbox\Health and Labour Supply\ELSA"
cd "$dropbox\ELSA"

use ELSA_NatCen_2017PROC.dta, clear
sum sysval if abs(sis01-1)>0.01
glo SD1 : disp %4.2f r(sd)

glo condic  ="Lhibpe==0 & Lbppills==0 & Ldiab==0 & interBefo==1"

gen Lnettotw_bu_s=nettotw_bu_s
xtile tW=Lnettotw_bu_s, n(2)

gen Llogotinc_bu=Yotinc_bu
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

////////////////////////////////////////////////////////////////////////////////
// By-hand experiments
if 1==1 {
// 2 years =====================================================================

	local varlist1 missing died	
	local varlist2 hibpe bppills
	local varlist3 diab heartMa goodHealth bmival sysval diaval


	rdpow missing sis01 if $condic ,bwselect(msetwo) tau(0.05)
	rdpow died    sis01 if $condic ,bwselect(msetwo) tau(0.05)	

	
// 4 years =====================================================================

	*** Base: First stage ***********************************************
	rdrobust Fhibpe sis01 if Lage<=58  & $condic
	rdrobust Fbppills sis01 if Lage<=58  & $condic
}


* *****************************************************************************
* 3. Main results (individuals aged 58 or younger, non-diagnosed with HBP before
* *****************************************************************************
if 1==1 {
	cd "$tablas"

	glo conda "& $condic" 
	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side


	* ******************************************************************************		
	* Latex table 		
		glo nCol=4
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init powerCalc , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{Power calculations for the main specification \label{tab:powerCalc}}
		tex \begin{adjustwidth}{-1.25in}{0in}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\
		tex Dependent Variable & Before BP test & 2 years & 4 years \\
		tex                    & $ t=0$ & $ t=1$ & $ t=2$ \\

		* End head .................................................................*/	

	local varlist1 missing died	
	local varlist2 hibpe bppills
	local varlist3 diab heartMa goodHealth 
	local varlist4 bmival sysval diaval

	local title1 "Panel A. Attrition. Power against $1 pp. | 2,5 pp. | 5 pp.$ "		
	local title2 "Panel B. High Blood Pressure. Power against $1 pp. | 2,5 pp. | 5 pp.$"
	local title3 "Panel C. Health. Power against $1 pp. | 2,5 pp. | 5 pp.$"
	local title4 "Panel D. Biomarkers. Power against $1/4 SD | 1/2 SD | 1 SD$"

	forval i=1(1)3 {	// No economic activity
		tex \midrule
		tex \multicolumn{4}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
		
			cap drop L`myVar'
			cap drop F`myVar'
			cap gen L`myVar'=L.`myVar'
			cap gen F`myVar'=F.`myVar'
			
			local lname : variable label `myVar'
	

			* Sharp RDD 0 Y...............................................................
			cap rdpow L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(0.01)
			loc p01 = r(power_rbc)
			cap rdpow L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(0.025)
			loc p025= r(power_rbc)
			cap rdpow L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(0.05)
			loc p05 = r(power_rbc)
				
			if _rc==0 {
				loc p01     : disp %4.3f `p01'
				loc p025    : disp %4.3f `p025'
				loc p05     : disp %4.3f `p05'
				
				loc hl    : disp %4.1f r(samph_l)
				loc hr    : disp %4.1f r(samph_r)
				loc enel  = r(N_h_l)
				loc ener  = r(N_h_r)		

				glo coef1="`p01' | `p025' | `p05'"
				glo bw1 =" h=`hl'/`hr',"
				glo ene1 =" N=`enel'/`ener'"				
			}
			else {
				glo coef1=""
				glo bw1 =""
				glo ene1 =""								
			}
			
			* Sharp RDD 2 Y...............................................................
			cap rdpow `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(0.01)
			loc p01 = r(power_rbc)
			cap rdpow `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(0.025)
			loc p025= r(power_rbc)
			cap rdpow `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(0.05)
			loc p05 = r(power_rbc)			
			
			if _rc==0 & `i'!=5 {	
				loc p01     : disp %4.3f `p01'
				loc p025    : disp %4.3f `p025'
				loc p05     : disp %4.3f `p05'
				
				loc hl    : disp %4.1f r(samph_l)
				loc hr    : disp %4.1f r(samph_r)
				loc enel  = r(N_h_l)
				loc ener  = r(N_h_r)		

				glo coef2="`p01' | `p025' | `p05'"
				glo bw2 =" h=`hl'/`hr',"
				glo ene2 =" N=`enel'/`ener'"								
			}
			else {
				glo coef2=""
				glo bw2 =""
				glo ene2 =""				
			}			
			
			* Sharp RDD 4 Y...............................................................
			cap rdpow F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(0.01)
			loc p01 = r(power_rbc)
			cap rdpow F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(0.025)
			loc p025= r(power_rbc)
			cap rdpow F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(0.05)
			loc p05 = r(power_rbc)
			if _rc==0 {		
				loc p01     : disp %4.3f `p01'
				loc p025    : disp %4.3f `p025'
				loc p05     : disp %4.3f `p05'
				
				loc hl    : disp %4.1f r(samph_l)
				loc hr    : disp %4.1f r(samph_r)
				loc enel  = r(N_h_l)
				loc ener  = r(N_h_r)		

				glo coef3="`p01' | `p025' | `p05'"
				glo bw3 =" h=`hl'/`hr',"
				glo ene3 =" N=`enel'/`ener'"								
			}
			else {
				glo coef3=""
				glo bw3 =""
				glo ene3 =""				
			}			
				
			
			disp "`lname'   & $ $coef1 $        & $ $coef2 $        & $ $coef3 $"
			disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3 "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{4cm}{\raggedright `lname' }   &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $ \\
			tex                                          &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3 \\	
			tex \addlinespace[2pt]
			
		}
		tex \\
	}

	
	forval i=4(1)4 {	// Continuous variables
		tex \midrule
		tex \multicolumn{4}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
		
			cap drop L`myVar'
			cap drop F`myVar'
			cap gen L`myVar'=L.`myVar'
			cap gen F`myVar'=F.`myVar'
			
			sum `myVar', d
			loc sdc=r(sd)
			loc sdb=r(sd)*0.5
			loc sda=r(sd)*0.25
			
			local lname : variable label `myVar'
			local lname = "`lname' (SD=`: disp %4.2f r(sd) ')"

			* Sharp RDD 0 Y...............................................................
			cap rdpow L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(`sda')
			loc p01 = r(power_rbc)
			cap rdpow L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(`sdb')
			loc p025= r(power_rbc)
			cap rdpow L`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(`sdc')
			loc p05 = r(power_rbc)
				
			if _rc==0 {
				loc p01     : disp %4.3f `p01'
				loc p025    : disp %4.3f `p025'
				loc p05     : disp %4.3f `p05'
				
				loc hl    : disp %4.1f r(samph_l)
				loc hr    : disp %4.1f r(samph_r)
				loc enel  = r(N_h_l)
				loc ener  = r(N_h_r)		

				glo coef1="`p01' | `p025' | `p05'"
				glo bw1 =" h=`hl'/`hr',"
				glo ene1 =" N=`enel'/`ener'"				
			}
			else {
				glo coef1=""
				glo bw1 =""
				glo ene1 =""								
			}
			
			* Sharp RDD 2 Y...............................................................
			cap rdpow `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(`sda')
			loc p01 = r(power_rbc)
			cap rdpow `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(`sdb')
			loc p025= r(power_rbc)
			cap rdpow `myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(`sdc')
			loc p05 = r(power_rbc)			
			
			if _rc==0 & `i'!=5 {	
				loc p01     : disp %4.3f `p01'
				loc p025    : disp %4.3f `p025'
				loc p05     : disp %4.3f `p05'
				
				loc hl    : disp %4.1f r(samph_l)
				loc hr    : disp %4.1f r(samph_r)
				loc enel  = r(N_h_l)
				loc ener  = r(N_h_r)		

				glo coef2="`p01' | `p025' | `p05'"
				glo bw2 =" h=`hl'/`hr',"
				glo ene2 =" N=`enel'/`ener'"								
			}
			else {
				glo coef2=""
				glo bw2 =""
				glo ene2 =""				
			}			
			
			* Sharp RDD 4 Y...............................................................
			cap rdpow F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(`sda')
			loc p01 = r(power_rbc)
			cap rdpow F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(`sdb')
			loc p025= r(power_rbc)
			cap rdpow F`myVar' sis01 if Lage<=58 $conda , deriv(0) $opti  tau(`sdc')
			loc p05 = r(power_rbc)
			if _rc==0 {		
				loc p01     : disp %4.3f `p01'
				loc p025    : disp %4.3f `p025'
				loc p05     : disp %4.3f `p05'
				
				loc hl    : disp %4.1f r(samph_l)
				loc hr    : disp %4.1f r(samph_r)
				loc enel  = r(N_h_l)
				loc ener  = r(N_h_r)		

				glo coef3="`p01' | `p025' | `p05'"
				glo bw3 =" h=`hl'/`hr',"
				glo ene3 =" N=`enel'/`ener'"								
			}
			else {
				glo coef3=""
				glo bw3 =""
				glo ene3 =""				
			}			
				
			
			disp "`lname'   & $ $coef1 $        & $ $coef2 $        & $ $coef3 $"
			disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3 "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{4cm}{\raggedright `lname' }   &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $ \\
			tex                                          &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3 \\	
			tex \addlinespace[2pt]
			
		}
		tex \\
	}	
	
	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{14cm}{\underline{Notes:} ///
			This table present the power estimates under three alternative hypotheses of impact (1, 2.5, and 5 percentage points) for three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. ///
			It includes only those respondents aged 58 or younger at the time of the measurement who were not diagnosed with HBP or diabetes, and not taking BP-lowering medication. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{14cm}{Power calculations are robust bias-corrected. }} \\
		tex \end{tabular}
		tex \end{adjustwidth}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	

}

