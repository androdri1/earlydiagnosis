  ////////////////////////////////////////////////////////////////
 // *************** 3. DifferentialImpacts ******************* //
////////////////////////////////////////////////////////////////
* 2018.07.31
* Paul Rodriguez-Lesmes <p.lesmes.11@ucl.ac.uk>

* **************************************************************
clear all
cap texdoc close

// glo dropbox="C:\Users\andro\Dropbox"
// glo dropbox="D:\Paul.Rodriguez\Dropbox"
glo dropbox= "C:\Users\msofi\Universidad del rosario\Proyectos ELSA - Documentos\"


// glo tablas="$dropbox\Health and Labour Supply\RDpaper Text\2018.07. Journal of the Economics of Ageing RR\tablas"
// glo images = "$dropbox\Health and Labour Supply\RDpaper Text\2018.07. Journal of the Economics of Ageing RR\imagenes"
glo tablas="$dropbox\RDpaper Text\2021.05 Plos One RR1\tablas"
glo images = "$dropbox\RDpaper Text\2021.05 Plos One RR1\imagenes"

// do "$dropbox\Health and Labour Supply\RDpaper Text\syntax\HBPRD0_Programs.do"
do "$dropbox\RDpaper Text\syntax\HBPRD0_Programs.do"

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//cd "$dropbox\Health and Labour Supply\ELSA"
cd "$dropbox\ELSA"
use ELSA_NatCen_2017PROC.dta, clear
sum sysval if abs(sis01-1)>0.01
glo SD1 : disp %4.2f r(sd)

glo condic  ="Lhibpe==0 & Lbppills==0 & Ldiab==0 & interBefo==1"

xtile tYP=nettotw_bu_s, n(2)
// 188.0983 -  BU total net (non-pension) wealth (1000£ of May2005)


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


	gen LgoodHealth=L.goodHealth
	gen uno=1
	label var LgoodHealth "SR good health baseline"

	gen cvdrisk=(L.framinghamCVDRisk>=.08) if L.framinghamCVDRisk!=.
	label var cvdrisk "10 years CVD risk 8\% and over"



* *****************************************************************************
* 1. Main results by education and wealth
* *****************************************************************************
if 1==0 {
	cd "$tablas"

	glo conda "& $condic" 
	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side


	* ******************************************************************************		
	* Latex table 		
		glo nCol=5
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResultsHeter , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status (1 wave ahead), by education and wealth \label{tab:mainResultsHeter}}
		tex \begin{adjustwidth}{-1.25in}{0in}
		tex \begin{adjustbox}{max totalheight=1.5\textheight, max width=1.45\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\
		tex Dependent Variable & \multicolumn{2}{c}{Education} & \multicolumn{2}{c}{Wealth} \\
		tex  & Low & High & Low & High \\

		* End head .................................................................
	*/	

	local varlist1 hibpe bppills
	*local varlist2 smoken smokeInt3b alcoM dphy1 
	local varlist2 diab heartMa goodHealth

	local title1 "Panel A. High Blood Pressure"
	*local title2 "Panel B. Lifestyle"
	local title2 "Panel B. Health"

	forval i=1(1)2 {	// No economic activity
		tex \midrule
		tex \multicolumn{5}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
			local lname : variable label `myVar'
				
			* Sharp RDD 2 Y; low educ ..........................................
			cap rdrobust `myVar' sis01 if Lage<=58 $conda & dedu_3==0, deriv(0) $opti
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
					
			* Sharp RDD 2 Y; high educ ..........................................
			cap rdrobust `myVar' sis01 if Lage<=58 $conda & dedu_3==1, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; low wealth ........................................
			cap rdrobust `myVar' sis01 if Lage<=58 $conda & tYP==1, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; high income ........................................
			cap rdrobust `myVar' sis01 if Lage<=58 $conda & tYP==2, deriv(0) $opti
			if _rc==0 {		
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)

				glo coef4="`b'"
				glo star4="[`pvalr']"
				glo sep4="(`se')"	
				glo bw4 =" h=`hl'/`hr',"
				glo ene4 =" N=`enel'/`ener'"								
			}
			else {
				glo coef4=""
				glo star4=""
				glo sep4=""			
				glo bw4 =""
				glo ene4 =""				
			}				
			
			disp "`lname'   & $ $coef1 $        & $ $coef2 $        & $ $coef3 $        & $ $coef4 $        "
			disp "          & $ $sep1  $star1 $ & $ $sep2  $star2 $ & $ $sep3  $star3 $ & $ $sep4  $star4 $ "
			disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3       & $bw4 $ene4        "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{3.5cm}{\raggedright `lname' }   &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $        &  $ $coef4 $         \\
			tex                                          &  $ $sep1  $star1 $ &  $ $sep2  $star2 $ & $ $sep3  $star3 $ &  $ $sep4  $star4 $  \\
			tex                                          &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3       & $bw4  $ene4         \\	
			tex \addlinespace[2pt]
			
		}
		tex \\
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. In includes only those aged 58 or younger at the time of the measurement. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
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
* 2. Main results by CVD-risk and SR health
* *****************************************************************************
if 1==0 {
	cd "$tablas"

	glo conda "& $condic" 
	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side


	* ******************************************************************************		
	* Latex table 		
		glo nCol=5
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResultsHeter2 , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status (1 wave ahead), by CVD-risk and Self-Rared Health \label{tab:mainResultsHeter2}}
		tex \begin{adjustwidth}{-1.25in}{0in}
		tex \begin{adjustbox}{max totalheight=1.5\textheight, max width=1.45\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\
		tex Dependent Variable & \multicolumn{2}{c}{CVD-risk} & \multicolumn{2}{c}{SR Health} \\
		tex  & Low & High & Bad & Good \\

		* End head .................................................................
	*/	

	local varlist1 hibpe bppills
	*local varlist2 smoken smokeInt3b alcoM dphy1 
	local varlist2 diab heartMa goodHealth

	local title1 "Panel A. High Blood Pressure"
	*local title2 "Panel B. Lifestyle"
	local title2 "Panel B. Health"

	forval i=1(1)2 {	// No economic activity
		tex \midrule
		tex \multicolumn{5}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
			local lname : variable label `myVar'
				
			* Sharp RDD 2 Y; low CVD-risk ..........................................
			cap rdrobust `myVar' sis01 if Lage<=58 $conda & cvdrisk==0, deriv(0) $opti
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
					
			* Sharp RDD 2 Y; high CV-risk ..........................................
			cap rdrobust `myVar' sis01 if Lage<=58 $conda & cvdrisk==1, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; low SR health ........................................
			cap rdrobust `myVar' sis01 if Lage<=58 $conda & LgoodHealth==0, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; high SR health ........................................
			cap rdrobust `myVar' sis01 if Lage<=58 $conda & LgoodHealth==1, deriv(0) $opti
			if _rc==0 {		
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)

				glo coef4="`b'"
				glo star4="[`pvalr']"
				glo sep4="(`se')"	
				glo bw4 =" h=`hl'/`hr',"
				glo ene4 =" N=`enel'/`ener'"								
			}
			else {
				glo coef4=""
				glo star4=""
				glo sep4=""			
				glo bw4 =""
				glo ene4 =""				
			}				
			
			disp "`lname'   & $ $coef1 $        & $ $coef2 $        & $ $coef3 $        & $ $coef4 $        "
			disp "          & $ $sep1  $star1 $ & $ $sep2  $star2 $ & $ $sep3  $star3 $ & $ $sep4  $star4 $ "
			disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3       & $bw4 $ene4        "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{3.5cm}{\raggedright `lname' }   &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $        &  $ $coef4 $         \\
			tex                                          &  $ $sep1  $star1 $ &  $ $sep2  $star2 $ & $ $sep3  $star3 $ &  $ $sep4  $star4 $  \\
			tex                                          &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3       & $bw4  $ene4         \\	
			tex \addlinespace[2pt]
			
		}
		tex \\
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. In includes only those aged 58 or younger at the time of the measurement. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
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
* 3. Balance table for education, wealth, CVD-risk and SR health
* *****************************************************************************
if 1==0 {
	cd "$tablas"

	glo conda "& $condic" 
	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side


	* ******************************************************************************		
	* Latex table 		
		glo nCol=5
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResultsHeterBal , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status (Balance), by education and wealth \label{tab:mainResultsHeterBal}}
		tex \begin{adjustwidth}{-1.25in}{0in}
		tex \begin{adjustbox}{max totalheight=1.5\textheight, max width=1.451\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\
		tex Dependent Variable & \multicolumn{2}{c}{Education} & \multicolumn{2}{c}{Wealth} \\
		tex  & Low & High & Low & High \\

		* End head .................................................................*/	

	*local varlist1 hibpe bppills
	*local varlist2 smoken smokeInt3b alcoM dphy1 
	local varlist1 /*diab*/ heartMa goodHealth

	*local title1 "Panel A. High Blood Pressure"
	*local title2 "Panel B. Lifestyle"
	*local title3 "Panel C. Health"

	forval i=1(1)1 {	// No economic activity
		tex \midrule
		*tex \multicolumn{5}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
			local lname : variable label `myVar'
			
			cap gen L`myVar'=L.`myVar'
				
			* Sharp RDD 2 Y; low educ ..........................................
			cap rdrobust L`myVar' sis01 if Lage<=58 $conda & dedu_3==0, deriv(0) $opti
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
					
			* Sharp RDD 2 Y; high educ ..........................................
			cap rdrobust L`myVar' sis01 if Lage<=58 $conda & dedu_3==1, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; low wealth ........................................
			cap rdrobust L`myVar' sis01 if Lage<=58 $conda & tYP==1, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; high wealth ........................................
			cap rdrobust L`myVar' sis01 if Lage<=58 $conda & tYP==2, deriv(0) $opti
			if _rc==0 {		
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)

				glo coef4="`b'"
				glo star4="[`pvalr']"
				glo sep4="(`se')"	
				glo bw4 =" h=`hl'/`hr',"
				glo ene4 =" N=`enel'/`ener'"								
			}
			else {
				glo coef4=""
				glo star4=""
				glo sep4=""			
				glo bw4 =""
				glo ene4 =""				
			}				
			
			disp "`lname'   & $ $coef1 $        & $ $coef2 $        & $ $coef3 $        & $ $coef4 $        "
			disp "          & $ $sep1  $star1 $ & $ $sep2  $star2 $ & $ $sep3  $star3 $ & $ $sep4  $star4 $ "
			disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3       & $bw4 $ene4        "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{3.5cm}{\raggedright `lname' }   &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $        &  $ $coef4 $         \\
			tex                                          &  $ $sep1  $star1 $ &  $ $sep2  $star2 $ & $ $sep3  $star3 $ &  $ $sep4  $star4 $  \\
			tex                                          &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3       & $bw4  $ene4         \\	
			tex \addlinespace[2pt]
			
		}
		tex \\
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. In includes only those aged 58 or younger at the time of the measurement. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
			In the first set of brackets the conventional p-value is presented, while the second corresponds to the robust inference version derived by Calonico, Cattaneo, Titiunik (2014). }} \\
		tex \end{tabular}
		tex \end{adjustbox}
		tex \end{adjustwidth}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	
	
	* ******************************************************************************		
	* Latex table 		
		glo nCol=5
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResultsHeterBal2 , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status (Balance), by CVD-risk and Self-Rared Health \label{tab:mainResultsHeterBal2}}
		tex \begin{adjustwidth}{-1.25in}{0in}
		tex \begin{adjustbox}{max totalheight=1.5\textheight, max width=1.45\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\
		tex Dependent Variable & \multicolumn{2}{c}{CVD-risk} & \multicolumn{2}{c}{SR Health} \\
		tex  & Low & High & Bad & Good \\

		* End head .................................................................
	*/	

	*local varlist1 hibpe bppills
	*local varlist2 smoken smokeInt3b alcoM dphy1 
	local varlist1 /*diab*/ heartMa goodHealth

	*local title1 "Panel A. High Blood Pressure"
	*local title2 "Panel B. Lifestyle"
	*local title3 "Panel C. Health"

	forval i=1(1)1 {	// No economic activity
		tex \midrule
		*tex \multicolumn{5}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
			local lname : variable label `myVar'
			
			cap gen L`myVar'=L.`myVar'			
				
			* Sharp RDD 2 Y; low educ ..........................................
			cap rdrobust L`myVar' sis01 if Lage<=58 $conda & cvdrisk==0, deriv(0) $opti
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
					
			* Sharp RDD 2 Y; high educ ..........................................
			cap rdrobust L`myVar' sis01 if Lage<=58 $conda & cvdrisk==1, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; low SR health ........................................
			cap rdrobust L`myVar' sis01 if Lage<=58 $conda & LgoodHealth==0, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; high SR health ........................................
			cap rdrobust L`myVar' sis01 if Lage<=58 $conda & LgoodHealth==1, deriv(0) $opti
			if _rc==0 {		
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)

				glo coef4="`b'"
				glo star4="[`pvalr']"
				glo sep4="(`se')"	
				glo bw4 =" h=`hl'/`hr',"
				glo ene4 =" N=`enel'/`ener'"								
			}
			else {
				glo coef4=""
				glo star4=""
				glo sep4=""			
				glo bw4 =""
				glo ene4 =""				
			}				
			
			disp "`lname'   & $ $coef1 $        & $ $coef2 $        & $ $coef3 $        & $ $coef4 $        "
			disp "          & $ $sep1  $star1 $ & $ $sep2  $star2 $ & $ $sep3  $star3 $ & $ $sep4  $star4 $ "
			disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3       & $bw4 $ene4        "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{3.5cm}{\raggedright `lname' }   &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $        &  $ $coef4 $         \\
			tex                                          &  $ $sep1  $star1 $ &  $ $sep2  $star2 $ & $ $sep3  $star3 $ &  $ $sep4  $star4 $  \\
			tex                                          &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3       & $bw4  $ene4         \\	
			tex \addlinespace[2pt]
			
		}
		tex \\
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. In includes only those aged 58 or younger at the time of the measurement. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
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
* 4. 2 waves heterogenous for education, income, CVD-risk and SR health
* *****************************************************************************
if 1==0 {
	cd "$tablas"

	glo conda "& $condic" 
	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side


	* ******************************************************************************		
	* Latex table 		
		glo nCol=5
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResultsHeter2W , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status (2 waves), by education and income \label{tab:mainResultsHeter2W}}
		tex \begin{adjustbox}{max totalheight=1.5\textheight, max width=1.45\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\
		tex Dependent Variable & \multicolumn{2}{c}{Education} & \multicolumn{2}{c}{Income} \\
		tex  & Low & High & Low & High \\

		* End head .................................................................
	*/	

	local varlist1 hibpe bppills
	local varlist2 smoken smokeInt3b alcoM dphy1 
	local varlist3 diab heartMa goodHealth

	local title1 "Panel A. High Blood Pressure"
	local title2 "Panel B. Lifestyle"
	local title3 "Panel C. Health"

	forval i=1(1)3 {	// No economic activity
		tex \midrule
		tex \multicolumn{5}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
			local lname : variable label `myVar'
			
			cap gen F`myVar'=F.`myVar'
				
			* Sharp RDD 2 Y; low educ ..........................................
			cap rdrobust F`myVar' sis01 if Lage<=58 $conda & dedu_3==0, deriv(0) $opti
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
					
			* Sharp RDD 2 Y; high educ ..........................................
			cap rdrobust F`myVar' sis01 if Lage<=58 $conda & dedu_3==1, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; low income ........................................
			cap rdrobust F`myVar' sis01 if Lage<=58 $conda & tYP==1, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; high income ........................................
			cap rdrobust F`myVar' sis01 if Lage<=58 $conda & tYP==2, deriv(0) $opti
			if _rc==0 {		
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)

				glo coef4="`b'"
				glo star4="[`pvalr']"
				glo sep4="(`se')"	
				glo bw4 =" h=`hl'/`hr',"
				glo ene4 =" N=`enel'/`ener'"								
			}
			else {
				glo coef4=""
				glo star4=""
				glo sep4=""			
				glo bw4 =""
				glo ene4 =""				
			}				
			
			disp "`lname'   & $ $coef1 $        & $ $coef2 $        & $ $coef3 $        & $ $coef4 $        "
			disp "          & $ $sep1  $star1 $ & $ $sep2  $star2 $ & $ $sep3  $star3 $ & $ $sep4  $star4 $ "
			disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3       & $bw4 $ene4        "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{3.5cm}{\raggedright `lname' }   &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $        &  $ $coef4 $         \\
			tex                                          &  $ $sep1  $star1 $ &  $ $sep2  $star2 $ & $ $sep3  $star3 $ &  $ $sep4  $star4 $  \\
			tex                                          &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3       & $bw4  $ene4         \\	
			tex \addlinespace[2pt]
			
		}
		tex \\
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. In includes only those aged 58 or younger at the time of the measurement. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
			In the first set of brackets the conventional p-value is presented, while the second corresponds to the robust inference version derived by Calonico, Cattaneo, Titiunik (2014). }} \\
		tex \end{tabular}
		tex \end{adjustbox}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	


	* ******************************************************************************		
	* Latex table 		
		glo nCol=5
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResultsHeter2W2 , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status (2 waves), by CVD-risk and Self-Rared Health \label{tab:mainResultsHeter2W2}}
		tex \begin{adjustbox}{max totalheight=1.5\textheight, max width=1.45\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\
		tex Dependent Variable & \multicolumn{2}{c}{CVD-risk} & \multicolumn{2}{c}{SR Health} \\
		tex  & Low & High & Bad & Good \\

		* End head .................................................................
	*/	

	local varlist1 hibpe bppills
	local varlist2 smoken smokeInt3b alcoM dphy1 
	local varlist3 diab heartMa goodHealth

	local title1 "Panel A. High Blood Pressure"
	local title2 "Panel B. Lifestyle"
	local title3 "Panel C. Health"

	forval i=1(1)3 {	// No economic activity
		tex \midrule
		tex \multicolumn{5}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
			local lname : variable label `myVar'
			
			cap gen F`myVar'=F.`myVar'			
				
			* Sharp RDD 2 Y; low educ ..........................................
			cap rdrobust F`myVar' sis01 if Lage<=58 $conda & cvdrisk==0, deriv(0) $opti
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
					
			* Sharp RDD 2 Y; high educ ..........................................
			cap rdrobust F`myVar' sis01 if Lage<=58 $conda & cvdrisk==1, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; low income ........................................
			cap rdrobust F`myVar' sis01 if Lage<=58 $conda & LgoodHealth==0, deriv(0) $opti
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
			
			* Sharp RDD 2 Y; high income ........................................
			cap rdrobust F`myVar' sis01 if Lage<=58 $conda & LgoodHealth==1, deriv(0) $opti
			if _rc==0 {		
				loc b     : disp %5.3f e(tau_cl)
				loc se    : disp %5.3f e(se_tau_cl)
				loc pval  : disp %4.3f e(pv_cl)
				loc pvalr : disp %4.3f e(pv_rb)
				loc hl    : disp %4.1f e(h_l)
				loc hr    : disp %4.1f e(h_r)
				loc enel  = e(N_h_l)
				loc ener  = e(N_h_r)

				glo coef4="`b'"
				glo star4="[`pvalr']"
				glo sep4="(`se')"	
				glo bw4 =" h=`hl'/`hr',"
				glo ene4 =" N=`enel'/`ener'"								
			}
			else {
				glo coef4=""
				glo star4=""
				glo sep4=""			
				glo bw4 =""
				glo ene4 =""				
			}				
			
			disp "`lname'   & $ $coef1 $        & $ $coef2 $        & $ $coef3 $        & $ $coef4 $        "
			disp "          & $ $sep1  $star1 $ & $ $sep2  $star2 $ & $ $sep3  $star3 $ & $ $sep4  $star4 $ "
			disp "          & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3       & $bw4 $ene4        "
			
			tex \rowcolor{Gray}
			tex \parbox[c]{3.5cm}{\raggedright `lname' }   &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $        &  $ $coef4 $         \\
			tex                                          &  $ $sep1  $star1 $ &  $ $sep2  $star2 $ & $ $sep3  $star3 $ &  $ $sep4  $star4 $  \\
			tex                                          &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3       & $bw4  $ene4         \\	
			tex \addlinespace[2pt]
			
		}
		tex \\
	}

	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. In includes only those aged 58 or younger at the time of the measurement. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{15.5cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
			In the first set of brackets the conventional p-value is presented, while the second corresponds to the robust inference version derived by Calonico, Cattaneo, Titiunik (2014). }} \\
		tex \end{tabular}
		tex \end{adjustbox}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	

}

* **************************************************************	
* 5. Run it for different Max-Age
* **************************************************************
if 1==1 {

	glo conda "& $condic" 
	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side

	matrix drop _all
	qui {
		cd "$tablas"
			glo nCol=5
			glo nColm1=$nCol-1	
			cap texdoc close
			texdoc init rdd_byAge , replace force
			tex {
			tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
			tex \begin{table}[H]
			tex \centering
			tex \scriptsize		
			tex \caption{The effects of information on potential hypertension status: up to age \label{tab:rdd_byAge}}
			tex \begin{tabular}{l*{$nColm1}{c}}			
			tex \toprule	
			tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\	
			tex Cutoff-value & HBP diagnosis & BP Pills & Alcohol 2 week or more & N cigarette per week \\	
			tex \midrule
	}

	forval value=56(2)76  {
		disp " "
		disp "This is for up to age=`value'"
		disp " "
		
		loc i=1
		foreach myVar in hibpe bppills alcoM smokeInt3b {
			local lname : variable label `myVar'
			cap rdrobust `myVar' sis01 if Lage<=`value' $conda , deriv(0) $opti
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
		
		disp "Up to age  `value' & $ $coef1 $        & $ $coef2 $              & $ $coef3 & $ $coef4 $ $"
		disp "                   & $ $sep1  $star1 $ & $ $sep2  $star2 $ & $ $sep3  $star3 & $ $sep4  $star4 $ $"
		disp "                   & $bw1 $ene1        & $bw2 $ene2        & $bw3  $ene3     & $bw4  $ene4 "
		
		tex \rowcolor{Gray}
		tex Up to age `value' &  $ $coef1 $        &  $ $coef2 $        & $ $coef3 $        & $ $coef4 $ \\
		tex                   &  $ $sep1  $star1 $ &  $ $sep2  $star2 $ & $ $sep3  $star3 $ & $ $sep4  $star4 $ \\
		tex                   &  $bw1  $ene1       & $bw2  $ene2        & $bw3  $ene3       & $bw4  $ene4 \\	
		tex \addlinespace[2pt]
		
		
		* For the graph *********
		matrix miRes=nullmat(miRes) \ (`value',$coef1 , $lb1 ,$ub1 , $coef2 , $lb2 ,$ub2 , $coef3 , $lb3 ,$ub3  , $coef4 , $lb4 ,$ub4 )
		* ***********************	
	}


	* Start foot ...............................................................
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{$nCol}{l}{\parbox[c]{14cm}{\underline{Notes:} ///
			This table present the impact estimates under several three specifications of a regression discontinuity design over the systolic blood pressure of respondents centred around 140 mmHg for ELSA. ///
			For males aged 50 and older in the HSE, the standardisation is done around 160 mmHg due to a different measurement protocol. ///
			It includes only those respondents who at the time of the measurement were not diagnosed with HBP or diabetes, and not taking BP-lowering medication. ///
			$ h$ presents the optimal bandwidth to the left/right of the cutoff, and $ N$ the corresponding number of observations effectively included. }} \\	
		tex \addlinespace[2pt]
		tex \multicolumn{$nCol}{l}{\parbox[c]{14cm}{Standard errors, in parenthesis, are derived from heteroskedasticity-robust nearest neighbour variance estimator with at least 3 neighbours. ///
			In the first set of brackets the conventional p-value is presented, while the second corresponds to the robust inference version derived by Calonico, Cattaneo, Titiunik (2014). }} \\
		tex \end{tabular}
		tex \end{table}
		tex }
		texdoc close	
	* ******************************************************************************/
	

	* ****************************************************************
	* A graph with the coefficients
	* (`value',$coef1 , $lb1 ,$ub1 , $coef2 , $lb2 ,$ub2 , $coef3 , $lb3 ,$ub3 )

	 cap drop miRes*
	 cap drop rddPlacebo*
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
		   legend( off ) xtitle(Maximum age for inclusion) ///
		   xscale(r(56  76)) xlabel(56(2)76) ///
		   ytitle("% diagnosed with HBP") ///
		   yline(0 , lpattern(solid)) xline(140 , lpattern(solid)) ///
			scheme(Plotplainblind)  name(hibpe , replace)
			
			
	twoway 	(rarea rddPlacebo_lb2 rddPlacebo_ub2 rddPlacebo_th, fintensity(20) lcolor(gs16) lwidth(none)) ///
			(connected rddPlacebo_coef2 rddPlacebo_th, msymbol(square)) , ///
		   legend( off ) xtitle(Maximum age for inclusion) ///
		   xscale(r(56  76)) xlabel(56(2)76) ///
		   ytitle("% under BP lowering medication") ///	   
		   yline(0 , lpattern(solid)) xline(140 , lpattern(solid)) ///
			scheme(Plotplainblind)  name(bppills , replace)		
			
	twoway 	(rarea rddPlacebo_lb3 rddPlacebo_ub3 rddPlacebo_th, fintensity(20) lcolor(gs16) lwidth(none)) ///
			(connected rddPlacebo_coef3 rddPlacebo_th, msymbol(square)) , ///
		   legend( off ) xtitle(Maximum age for inclusion) ///
		   xscale(r(56  76)) xlabel(56(2)76) ///
		   ytitle("% alcohol intake twice a week or more") ///	   
		   yline(0 , lpattern(solid)) xline(140 , lpattern(solid)) ///
			scheme(Plotplainblind)  name(alcoM , replace)				
			
	twoway 	(rarea rddPlacebo_lb4 rddPlacebo_ub4 rddPlacebo_th, fintensity(20) lcolor(gs16) lwidth(none)) ///
			(connected rddPlacebo_coef4 rddPlacebo_th, msymbol(square)) , ///
		   legend( off ) xtitle(Maximum age for inclusion) ///
		   xscale(r(56  76)) xlabel(56(2)76) ///
		   ytitle("N cigarette per week") ///	   
		   yline(0 , lpattern(solid)) xline(140 , lpattern(solid)) ///
			scheme(Plotplainblind)  name(smokeInt3b , replace)				
			
	graph combine hibpe bppills alcoM smokeInt3b		
	graph export "$images\rddB_byAge.pdf" , as(pdf) replace
}

* **************************************************************	

