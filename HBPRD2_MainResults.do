  ////////////////////////////////////////////////////////////////
 // ******************** 2. Main Results ********************* //
////////////////////////////////////////////////////////////////
* 2018.07.04
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
*glo dropbox="D:\Paul.Rodriguez\Dropbox"

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

	* What
	rdrobust Lhibpe sis01   if Lage<=58  & interBefo==1 ,bwselect(msetwo) p(1) // Nothing...
	rdrobust Lbppills sis01 if Lage<=58  & interBefo==1 ,bwselect(msetwo) p(1) // Negative!

	*** Base: First stage ***********************************************
	rdrobust hibpe sis01 if Lage<=58  & $condic ,bwselect(msetwo) p(1)			//  +6* , N=5568

	rdGraph hibpe sis01 if Lage<=58  & $condic , plot_range(-30 30) xtitle("SBP") ytitle("Proportion using BP lowering medication") nameg("left") ltitle(" ") black(1)
	
	/*
	RD Manipulation Test using local polynomial density estimation.  ---> Robust bias-corrected statistic. This is the default option.

		  Cutoff c = 0 |Left of c   Right of c          Number of obs =         6593
	-------------------+----------------------          Model         = unrestricted
		 Number of obs |      5176        1417          BW method     =         comb
	Eff. Number of obs |      1063         699          Kernel        =   triangular
		Order est. (p) |         2           2          VCE method    =    jackknife
		Order bias (q) |         3           3
		   BW est. (h) |     8.142       8.284

	Running variable: sis01.
	-----------------------------------------------
				Method |          T        P>|T|
	-------------------+---------------------------
				Robust |      -0.3487      0.7273
	----------------------------------------------- */
	
	rdrobust hibpe sis01 if Lage<=58  & $condic & masc==1 	//  +8*
	rdrobust hibpe sis01 if Lage<=58  & $condic & masc==0 	//  +4 N sig
	rdrobust hibpe sis01 if Lage<=58  & $condic & dedu_3==0 , bwselect(msetwo) 	// +12*
	rdrobust hibpe sis01 if Lage<=58  & $condic & dedu_1==0 , bwselect(msetwo)	//  +4 N sig
	rdrobust hibpe sis01 if Lage<=58  & $condic & tW!=.		//  +7** , N=2749
	rdrobust hibpe sis01 if Lage<=58  & $condic & tW==1 	//  +8 N sig
	rdrobust hibpe sis01 if Lage<=58  & $condic & tW==2 	//  +8*
	rdrobust hibpe sis01 if Lage<=58  & $condic & tYP!=.	//  +5** , N=2749
	rdrobust hibpe sis01 if Lage<=58  & $condic & tYP==1 	//   0 N sig
	rdrobust hibpe sis01 if Lage<=58  & $condic & tYP==2 	// +16** N sig , N=1374

	rdrobust hibpe sis01 if Lage<=58  & $condic , bwselect(msetwo)	//

	*** Ver 1: Sharp with diagnosis ***********************************************
	glo conda "& $condic" 

	glo conda "& $condic & tYP==2 "
	rdrobust bppills   sis01 if Lage<=58 $conda, deriv(0)  		// +6***  | tYP2 +13***
	rdrobust chole     sis01 if Lage<=58 $conda , deriv(0) 
	rdrobust diab      sis01 if Lage<=58  $conda, deriv(0) 
	rdrobust lipidpill sis01 if Lage<=58  $conda, deriv(0) 
	rdrobust heartMa    sis01 if Lage<=58  $conda, deriv(0) 		//        | tYP2 +21**

	rdrobust goodHealth  sis01 if Lage<=58  $conda, deriv(0)

	rdrobust anyGeffort sis01 if Lage<=58  $conda, deriv(0) 
	rdrobust smoken     sis01 if Lage<=58  $conda, deriv(0) 
	rdrobust smokeInt3b     sis01 if Lage<=58  $conda, deriv(0) 
	rdrobust alcoM      sis01 if Lage<=58  $conda, deriv(0) 	// -9.53 **
	rdrobust phyact     sis01 if Lage<=58  $conda, deriv(0) 
	rdrobust scveg  sis01 if Lage<=58  $conda, deriv(0) 
	rdrobust scfru  sis01 if Lage<=58  $conda, deriv(0) 		//        | tYP2 +.95*

	* No se puede!
	*rdrobust missing  sis01 if Lage<=58 , deriv(0) fuzzy(hibpe) 
	*rdrobust died  sis01 if Lage<=58 , deriv(0) fuzzy(hibpe) 


	*** Ver 2: Fuzzy with diagnosis ***********************************************
	glo conda "& $condic" 

	glo conda "& $condic & tYP==2 "
	rdrobust bppills   sis01 if Lage<=58 $conda, deriv(0) fuzzy(hibpe) 	// +100** | tYP2 +76.9
	rdrobust chole     sis01 if Lage<=58 $conda , deriv(0) fuzzy(hibpe)
	rdrobust diab      sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe)	
	rdrobust lipidpill sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe)
	rdrobust heartMa    sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe) //        | tYP2  +111.2%

	rdrobust goodHealth  sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe)

	rdrobust anyGeffort sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe )
	rdrobust smoken     sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe)
	rdrobust smokeInt3b sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe)
	rdrobust alcoM      sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe) 
	rdrobust phyact     sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe)
	rdrobust scveg  sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe)
	rdrobust scfru  sis01 if Lage<=58  $conda, deriv(0) fuzzy(hibpe)  	//        | tYP2 +5.6

	* No se puede!
	*rdrobust missing  sis01 if Lage<=58 , deriv(0) fuzzy(hibpe) 
	*rdrobust died  sis01 if Lage<=58 , deriv(0) fuzzy(hibpe) 

	*** Ver 3: Fuzzy with medication **********************************************

	glo conda "& $condic"

	glo conda "& $condic & tYP==2 "
	rdrobust chole     sis01 if Lage<=58 $conda , deriv(0) fuzzy(bppills)
	rdrobust diab      sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)
	rdrobust lipidpill sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)
	rdrobust heartMa    sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills) 

	rdrobust goodHealth  sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)

	rdrobust anyGeffort sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)
	rdrobust smoken     sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)
	rdrobust smokeInt3b sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)
	rdrobust alcoM      sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)	// -1.68* 
	rdrobust phyact     sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)
	rdrobust scveg  sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)
	rdrobust scfru  sis01 if Lage<=58  $conda, deriv(0) fuzzy(bppills)


// 4 years =====================================================================

	*** Base: First stage ***********************************************
	rdrobust Fhibpe sis01 if Lage<=58  & $condic
	rdrobust Fbppills sis01 if Lage<=58  & $condic
}

*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
* *****************************************************************************
* 1. RDD Typical Graph
* *****************************************************************************
if 1==0 {

	* 1st. Restricted sample on both Sys and Dias ******************************

	glo condic  ="Lhibpe==0 & Lbppills==0 & Ldiab==0 & interBefo==1"
	label var hibpe "self-report of HBP at t+1"
	label var bppills "% under BP medication at t+1"
	foreach varDep in hibpe bppills { // 
		local  varlabel : var label `varDep'
	* Systolic
		rdGraph `varDep' sis01 if Lage<=58  & $condic , plot_range(-20 20) xtitle("SBP") ytitle("`varlabel'") nameg("left") ltitle(" ") black(1)
	* Diastolic
		rdGraph `varDep' dis01 if Lage<=58  & $condic , plot_range(-20 20) xtitle("DBP") ytitle("`varlabel'") nameg("right") ltitle(" ") black(1)

		graph combine left right,  graphregion( fcolor(white))   ///
		   scheme(plotplainblind) commonscheme xsize(6) ysize(3)
		cd "$images"
		graph export "rR`varDep'.pdf" , as(pdf) replace
		
	}	
	label var hibpe "self-report of HBP"
	label var bppills "using BP medication"

	* 3rd. All information BUT at the baseline (balance test) ******************

	* Systolic
		rdGraph Lhibpe sis01 if Lage<=58  & 1==1 , plot_range(-20 20) xtitle("SBP") ytitle("% diagnosed with HBP at t=0") nameg("left") ltitle(" ") black(1)
	* Diastolic
		rdGraph Lbppills sis01 if Lage<=58  & 1==1 , plot_range(-20 20) xtitle("DBP") ytitle("% under BP medication at t=0") nameg("right") ltitle(" ") black(1)

		graph combine left right, subtitle(All available information from the HSE-ELSA data) ///
		   scheme(plotplainblind) commonscheme xsize(6) ysize(3) graphregion( fcolor(white))
		cd "$images"
		graph export "rAllBal.pdf" , as(pdf) replace	
		
		
		
}

* *****************************************************************************
* 2a. RDD main results on other outcomes super graph
* *****************************************************************************
if 1==0 {
	glo condic  ="Lhibpe==0 & Lbppills==0 & Ldiab==0 & interBefo==1"
	label var hibpe "Diagnosed HBP ever"
	label var diab "Diagnosed Diabetes ever"
	label var bppills "Takes BP medication"
	label var heartMa "Diagnosed Heart Condition"
	label var goodHealth "Self-reported GOOD health"
	label var smokeInt3b "Cigarettes per week"
	label var alcoM "\% alcohol twice a week or more"
	label var dphy1 "\% sedentary or low physical act."
	label var sysval "Systolic BP (SBP)"
	label var diaval "Diastolic BP (DBP)"
	label var bmival "Body Mass Index (BMI)"
	*foreach varDep smokeInt3b alcoM dphy1 
	foreach varDep in hibpe bppills diab heartMa goodHealth  bmival sysval diaval  {
	* Systolic
		cap gen L`varDep'=L.`varDep'
		cap gen F`varDep'=F.`varDep'
		local lname : variable label `varDep'
		
		glo opto=""
		
		if ("`varDep'"!="bppills" & "`varDep'"!="hibpe" &  "`varDep'"!="diab" ){
			rdGraph L`varDep' sis01 if Lage<=58  & $condic , plot_range(-20 20) xtitle("sBP") ytitle("`lname'") nameg("G1_`varDep'") ltitle("Before BP test (t=0)") black(1)
			glo opto ytitle(" ")
		}
		else {
			glo opto ytitle("`lname' ")
		}

		if ("`varDep'"!="bmival" & "`varDep'"!="sysval" &  "`varDep'"!="diaval" ) ///		
			rdGraph `varDep' sis01 if Lage<=58  & $condic , plot_range(-20 20) xtitle("sBP") nameg("G2_`varDep'") ltitle("2 years (t=1)") black(1) $opto
		
		rdGraph F`varDep' sis01 if Lage<=58  & $condic , plot_range(-20 20) xtitle("sBP") ytitle(" ") nameg("G3_`varDep'") ltitle("4 years (t=2)") black(1)
		
		cd "$images"	
		if ("`varDep'"=="bppills" | "`varDep'"=="hibpe" |  "`varDep'"=="diab" ) {
			graph combine G2_`varDep' G3_`varDep'  ,	 ///
				   scheme(plotplainblind) commonscheme ycommon   graphregion(margin(large) fcolor(white)) rows(1) xsize(6) ysize(2.5)
		}
		else if ("`varDep'"=="bmival" | "`varDep'"=="sysval" |  "`varDep'"=="diaval" ) {
			graph combine G1_`varDep' G3_`varDep'  ,	 ///
				   scheme(plotplainblind) commonscheme ycommon   graphregion(margin(large) fcolor(white)) rows(1) xsize(6) ysize(2.5)
		}
		else {
			graph combine G1_`varDep' G2_`varDep' G3_`varDep'  ,	 ///
				   scheme(plotplainblind) commonscheme ycommon   graphregion(margin(large) fcolor(white)) rows(1) xsize(6) ysize(2.5)
		}
		graph export "row`varDep'.pdf", as(pdf) replace			
	}
	
}

* *****************************************************************************
* 3. Main results (individuals aged 58 or younger, non-diagnosed with HBP before
* *****************************************************************************
if 1==0 {
	cd "$tablas"

	glo conda "& $condic" 
	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side


	* ******************************************************************************		
	* Latex table 		
		glo nCol=4
		glo nColm1=$nCol-1
		cap texdoc close
		texdoc init mainResults , replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{The effects of information on potential hypertension status \label{tab:mainResults}}
		tex 
ustwidth}{-1.25in}{0in}
		tex \begin{tabular}{l*{$nColm1}{c}}			
		tex \toprule	
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\
		tex Dependent Variable & Before BP test & 2 years & 4 years \\
		tex                    & $ t=0$ & $ t=1$ & $ t=2$ \\

		* End head .................................................................*/	

	local varlist1 missing died	
	local varlist2 hibpe bppills
	*local varlist3 smoken smokeInt3b alcoM dphy1 
	local varlist3 diab heartMa goodHealth bmival sysval diaval

	local title1 "Panel A. Attrition "		
	local title2 "Panel B. High Blood Pressure"
	*local title3 "Panel C. Lifestyle"
	local title3 "Panel C. Health"
	

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

