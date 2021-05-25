  ////////////////////////////////////////////////////////////////
 // ***************** 1. Descriptives ******************* //
////////////////////////////////////////////////////////////////
* 2014.06.23
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

*glo dropbox="D:\Paul.Rodriguez\Universidad del rosario\Proyectos ELSA - Documentos\"
glo dropbox= "C:\Users\msofi\Universidad del rosario\Proyectos ELSA - Documentos\"

*glo dropbox="D:\Paul.Rodriguez\Dropbox\Health and Labour Supply"

glo tablas="$dropbox\RDpaper Text\2021.05 Plos One RR1\tablas"
glo images = "$dropbox\RDpaper Text\2021.05 Plos One RR1\imagenes"

do "$dropbox\RDpaper Text\syntax\HBPRD0_Programs.do"

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cd "$dropbox\ELSA"
use ELSA_NatCen_2017PROC.dta, clear
sum sysval if abs(sis01-1)>0.01
glo SD1 : disp %4.2f r(sd)

do "0.Programs.do"

glo condic  ="Lhibpe==0 & Lbppills==0 & Ldiab==0 & interBefo==1"

label var Ytotinc_bu_s  "Total yearly income\textdagger"
label var nettotw_bu_s  "Total net non-pension wealth\textdagger"
label var sysval "Valid mean systolic blood pressure"
label var diaval "Valid mean diastolic blood pressure"


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

* **************************************************************	
* 1. Correlations Graph
* **************************************************************
if 1==1 {

preserve
gen condY1=smoken*100 if   hibpe==1 & wave>0
gen condN1=smoken*100 if   hibpe==0 & wave>0

gen condY2=alco1*100 if hibpe==1 & wave>0
gen condN2=alco1*100 if hibpe==0 & wave>0

gen condY3=dphy1*100 if hibpe==1 & wave>0
gen condN3=dphy1*100 if hibpe==0 & wave>0

gen condY4=goodHealth*100 if hibpe==1 & wave>0
gen condN4=goodHealth*100 if hibpe==0 & wave>0

collapse (mean) condY* condN*, by(hibpe)
drop if hibpe==.
reshape long condY condN, i(hibpe) j(miCond)

label define miCondl 1 "SMOKE: to smoke" 2 "ALCOHOL: more than once a week" 3 "PHYSIC ACT: Sedentary or low" 4 "GOOD HEALTH: Self-reported good or above"
label values miCond miCondl

graph hbar (mean) condY condN , over(miCond) ///
      blabel(bar, format(%4.1f)) ytitle("Percentage points") ///
	  legend(order(1 "Diagnosed HBP" 2 "No HBP")) ///
	  title("Self-reported HBP and lifestyle") ///
	  graphregion(fcolor(white) lcolor(none) ilwidth(none)) scheme(s2mono) ///
	  caption("Own calculations using ELSA waves 1 to 6")

restore

graph export "$images\basicHBP.pdf" , as(pdf) replace

}

* **************************************************************	
* 2. BHPS correlations
* **************************************************************
if 1==0 { //
	 
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
	  caption(Own calculations based on the BHPS data for England)  scheme(s2mono) ///
	  legend(order(1 "Aged 45-60" 2 "Aged 60 or over")) xsize(3) ysize(4) ///
	  graphregion(fcolor(white) lcolor(none) ilwidth(none))

graph export "$images\bhpsStats.pdf" , as(pdf) replace	 
}

* **************************************************************	
* 3. Means at entry
* **************************************************************
if 1==1 {
	cd "$tablas"
	
	replace refreshtype=0 if wave==0 & refreshtype==. // By definition
	tab refreshtype, gen(d_typeRec)
	egen d_typeRecO = rowtotal(d_typeRec2 d_typeRec3 d_typeRec4)
	label var d_typeRec1 "From the original ELSA sample"
	label var d_typeRecO "From a refreshment sample"
	tab wave, gen(dwave)
	label var dwave1 "Study sample entry at wave 0"
	label var dwave3 "Study sample entry at wave 2"
	label var dwave5 "Study sample entry at wave 4"
	label var dwave7 "Study sample entry at wave 6"

	glo opti ="bwselect(msetwo)"	// Independent bandwidth per side

	qui {
		glo nCol=10
		texdoc init meansEntry , replace force
		tex \begin{table}[H]
		tex \caption{Respondents' characteristics at study entry wave\label{tab:meansEntry}}
		tex \centering
		tex \begin{adjustwidth}{-2.25in}{0in}
		tex \scalebox{0.8}{
		tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
		tex \begin{tabularx} {22cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
		tex \toprule
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} & \multicolumn{1}{c}{(9)} \\
		tex Variables & \textbf{ALL} & \multicolumn{3}{c}{Below cutoff, bandwidth of} & \multicolumn{3}{c}{Above cutoff, bandwidth of} & \multicolumn{2}{c}{Balance test} \\
		tex &              & \textbf{[-22.5,0)} & \textbf{[-15,0)} & \textbf{[-7.5,0)} & \textbf{[0,7.5]} & \textbf{[0,15]} & \textbf{[0,22.5]} & \textbf{Difference} & \textbf{[p-val]} \\
	}
	
	local varlist1 age masc dedu_3 nonwhite married
	local varlist2 bmival sysval diaval
	local varlist3 Ytotinc_bu_s nettotw_bu_s wpactive
	*local varlist4 d_typeRec1 dwave1 dwave3 dwave5 dwave7

	local title1 "Panel A. Socio-demographic"
	local title2 "Panel B. Health"	
	local title3 "Panel C. Economic"
	*local title4 "Panel D. Survey"
	

	forval i=1(1)3 {	// No economic activity
		tex \cmidrule(l){2-2} \cmidrule(l){3-5} \cmidrule(l){6-8}  \cmidrule(l){9-10}
		tex \multicolumn{$nCol}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
		
			cap gen L`myVar'= L.`myVar'
		
			local lname : variable label `myVar'
			
			qui {
				sum L`myVar' if Lage<=58 & $condic & (wave==1 | wave==3 | wave==5 | wave==7 | wave==9)
				loc mean1 : disp %4.2f r(mean)
				sum L`myVar' if Lage<=58 & $condic & sis01>-22.5 & sis01<0
				loc mean2 : disp %4.2f r(mean)
				sum L`myVar' if Lage<=58 & $condic & sis01>-15 & sis01<0
				loc mean3 : disp %4.2f r(mean)
				sum L`myVar' if Lage<=58 & $condic & sis01>-7.5  & sis01<0
				loc mean4 : disp %4.2f r(mean)
				sum L`myVar' if Lage<=58 & $condic & sis01>=0 & sis01<7.5
				loc mean5 : disp %4.2f r(mean)
				sum L`myVar' if Lage<=58 & $condic & sis01>=0 & sis01<15
				loc mean6 : disp %4.2f r(mean)
				sum L`myVar' if Lage<=58 & $condic & sis01>=0 & sis01<22.5		
				loc mean7 : disp %4.2f r(mean)
			}
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
			
			disp "`lname' & `mean1' & `mean2' & `mean3' & `mean4' |||&||| `mean5' & `mean6' & `mean7' & $ $coef1  $star1 $ \\ "		
			tex \parbox[c]{5cm}{\raggedright `lname' }  & `mean1' & `mean2' & `mean3' & `mean4' & `mean5' & `mean6' & `mean7' & $coef1 &  $star1 \\
			
		}
	}
		
	qui {
		tex \addlinespace
		tex \bottomrule
		tex \addlinespace		
		tex \multicolumn{$nCol}{l}{\parbox[c]{22cm}{\raggedright\underline{Notes:} ///
			Simple averages using HSE 1998,99,00 for wave 0 and ELSA waves 2, 4 and 6. ///
			It includes only those aged 58 or younger at the time of the measurement who were ///
			not diagnosed with HBP or diabetes, and not taking BP-lowering medication. ///
			\textdagger Variables measured in thousands of GBP of May 2005 for the benefit unit (family). ///
			\textbf{ALL}: all respondents at waves 0, 2, 4 and 6 (waves where nurse measurements took place), ///
			with the same age and medical restrictions but ///
			without considering the availability of valid SBP measurements. ///
			For columns 2 to 7, the sample was restricted ///
			according to the average SBP of the last two out of three valid measurements. SBP is measured in mmHg ///
			and centred around HBP stage 1 diagnosis cutoff: 140 mmHg in general, with the exception of males ///
			aged 50 and older at wave 0 (HSE 98,99,00) where it is 160 mmHg. Column 8 estimates the jump in the ///
			running variable at $SBP=0$ using a sharp RDD, and column (9) presents the robust p-value for ///
			the null of the jump being zero. }}
		tex \end{tabularx}
		tex }
		tex \end{adjustwidth}
		tex \end{table}						
	}	
	texdoc close	
	
}

* **************************************************************	
* 4. Means by stage
* **************************************************************
if 1==1 {
	cd "$tablas"

	qui {
		glo nCol=8
		texdoc init meansStage , replace force
		tex \begin{table}[H]
		tex \caption{Dependent variables' means by stage \label{tab:meansStage}}
		tex \centering
		tex \begin{adjustwidth}{-2.25in}{0in}
		tex \scalebox{0.8}{
		tex \newcolumntype{Y}{>{\raggedleft\arraybackslash}X} 
		tex \begin{tabularx} {19cm} {@{} l Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y Y@{}} \\
		tex \toprule
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} \\
		tex Variables & \multicolumn{3}{c}{t=0 (Before BP test)} & \multicolumn{2}{c}{t=1 (2 years)} & \multicolumn{2}{c}{t=2 (4 years)} \\
		tex           & \textbf{ALL} & \textbf{[-15,0)} & \textbf{[0,15]} & \textbf{[-15,0)} & \textbf{[0,15]} & \textbf{[-15,0)} & \textbf{[0,15]}  \\
	}
	
	local varlist1 age missing died	
	local varlist2 hibpe bppills
	*local varlist3 smoken smokeInt3b alcoM dphy1 
	local varlist3 diab heartMa goodHealth bmival sysval diaval 

	local title1 "Panel A. Sample characteristics"		
	local title2 "Panel B. High Blood Pressure"
	*local title4 "Panel C. Lifestyle"
	local title3 "Panel C. Other health outcomes"
	

	forval i=1(1)3 {	
		tex \cmidrule(l){2-4} \cmidrule(l){5-6} \cmidrule(l){7-8}
		tex \multicolumn{$nCol}{l}{\textbf{`title`i''}} \\*
		foreach myVar in `varlist`i'' {
		
			cap gen L`myVar'= L.`myVar'
			cap gen F`myVar'= F.`myVar'
		
			local lname : variable label `myVar'
			
			qui {
				sum L`myVar' if Lage<=58 & $condic & (wave==1 | wave==3 | wave==5 | wave==7 |wave==9)
				loc mean1 : disp %4.2f r(mean)
				
				sum L`myVar' if Lage<=58 & $condic & sis01>-15 & sis01<0
				loc mean2 : disp %4.2f r(mean)
				sum L`myVar' if Lage<=58 & $condic & sis01>=0 & sis01<15
				loc mean3 : disp %4.2f r(mean)
				
				sum `myVar' if Lage<=58 & $condic & sis01>-15 & sis01<0
				loc mean4 : disp %4.2f r(mean)
				sum `myVar' if Lage<=58 & $condic & sis01>=0 & sis01<15
				loc mean5 : disp %4.2f r(mean)		
				
				sum F`myVar' if Lage<=58 & $condic & sis01>-15 & sis01<0
				loc mean6 : disp %4.2f r(mean)
				sum F`myVar' if Lage<=58 & $condic & sis01>=0 & sis01<15
				loc mean7 : disp %4.2f r(mean)				
			}

			disp "`lname' & `mean1' & `mean2' & `mean3' & `mean4' & `mean5' & `mean6' & `mean7' \\ "		
			tex $ \quad$ \parbox[c]{5cm}{\raggedright `lname' }  & `mean1' & `mean2' & `mean3' & `mean4' & `mean5' & `mean6' & `mean7' \\
			
		}
	}
	
		* ... Number of Obs ........................................................
		tex \addlinespace
		count
		loc mean1 = r(N)
		count if Lage<=58 & $condic & (wave==1 | wave==3 | wave==5 | wave==7 |wave==9)
		loc mean2 = r(N)
		count if Lage<=58 & $condic & sis01>-15 & sis01<0
		loc mean3 = r(N)
		count if Lage<=58 & $condic & sis01>=0 & sis01<15
		loc mean4 = r(N)
		count if Lage<=58 & $condic & sis01>-15 & sis01<0
		loc mean5 = r(N)
		count if Lage<=58 & $condic & sis01>=0 & sis01<15
		loc mean6 = r(N)
		count if Lage<=58 & $condic & sis01>-15 & sis01<0
		loc mean7 = r(N)
		count if Lage<=58 & $condic & sis01>=0 & sis01<15
		tex \parbox[c]{6.5cm}{\raggedright Number of observations }  & `mean1' & `mean2' & `mean3' & `mean4' & `mean5' & `mean6' & `mean7' \\

	* ..........................................................................
		
	
	
	qui {
		tex \addlinespace
		tex \bottomrule
		tex \addlinespace		
		tex \multicolumn{$nCol}{l}{\parbox[c]{19cm}{\raggedright\underline{Notes:} ///
			Simple averages. It includes only those aged 58 or younger at the time of the measurement who were ///
			not diagnosed with HBP or diabetes, and not taking BP-lowering medication. ///
			\textbf{ALL}: all respondents at waves 0, 2, 4, 6, 8 (waves where nurse measurements took place), with the same age and medical restrictions but ///
			without considering the availability of valid SBP measurements. ///
			The sample was restricted according to the average SBP of the last two out of three valid measurements at $ t=0$ ///
			SBP is measured in mmHg and centred around HBP stage 1 diagnosis cutoff: 140 mmHg in general, with the exception of males ///
			aged 50 and older at wave 0 (HSE 98,99,00) where it is 160 mmHg. }}
		tex \end{tabularx}
		tex }
		tex \end{adjustwidth}
		tex \end{table}						
	}
	texdoc close	
}

	

* **************************************************************	
* 5. Histogram
* **************************************************************
if 1==1 {
	hist sis1  if wave>1 & $condic & Lage<=58  , width(3) xline(140) xtitle(SBP) freq scheme(plotplainblind) // Para el gráfico de la Figura 1
	* It was complemented in Power Point	 
}	  
* **************************************************************	
* 6. How different are sys2 and sys3?
* **************************************************************
if 1==1 {

	replace sys2=. if sys2>250 | sys2<10
	replace sys3=. if sys3>250 | sys3<10
	gen diff=abs(sys2-sys3) 
	label var diff "Difference between SBP measurements 2 and 3"
	sum diff, d
	/*		Difference between SBP measurements 2 and 3
	-------------------------------------------------------------
		  Percentiles      Smallest
	 1%            0              0
	 5%            0              0
	10%            1              0       Obs              42,365
	25%            2              0       Sum of Wgt.      42,365

	50%            4                      Mean           5.547315
							Largest       Std. Dev.      5.181519
	75%            8             64
	90%           12             66       Variance       26.84814
	95%           15             66       Skewness       2.222918
	99%           23            118       Kurtosis       16.23974
	*/
}


