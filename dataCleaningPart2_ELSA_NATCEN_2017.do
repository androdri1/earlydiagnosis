version 13
* ***********************************************
* * NatCen DATA *********************************
* Clean and prepare the data for the analysis 
* in each chapter
* ***********************************************
*glo diri="C:\data\UKDA-5050-stata\stata\"
*glo diri="D:\Mis Documentos\Datos\UKDA-5050-stata\stata"
glo diri= "C:\Users\msofi\Universidad del rosario\Proyectos ELSA - Documentos\UKDA-5050-stata\UKDA-5050-stata\stata"

*glo dropbox="C:\Users\andro\Dropbox\Health and Labour Supply"
*glo dropbox="C:\Users\paul.rodriguez\Dropbox\Health and Labour Supply"
glo dropbox= "C:\Users\msofi\Universidad del rosario\Proyectos ELSA - Documentos\"

glo waitfolder="$dropbox\CCG Data"
glo mainPCT="$dropbox\CCG Data"
* ***********************************************

cd "$dropbox\Elsa"

use "$dropbox\ELSA\ELSA_NatCen_2017PRE.dta", replace	

///////////////////////////////////////////////////////////////////////////////////////////
// Basic Characteristics
///////////////////////////////////////////////////////////////////////////////////////////
if 1==1 {

* Fix age **********************************************************************

recode dobyear (-8 -7 =. )
gen diY=abs(indobyr - dobyear)

replace dobyear=indobyr if dobyear==. // solve missings...
replace dobyear=indobyr if ( abs(year-dobyear-age)>3 ) & indobyr!=. & dobyear!=. & age!=. // Then, this one makes more sense
drop diY
gen diY=abs(indobyr - dobyear)

drop indobyr // Trust the derived variable

bys idauniq: egen genera=median(dobyear) // Fill in the gaps
replace dobyear=genera if dobyear==.
drop genera

gen calAge=year-dobyear

* Fill in with all info available
replace age=. if age<0
replace age=indager if age==. & indager!=99 & indager>0
replace age=r_agey if age==. & r_agey!=99 & r_agey>0
replace age=calAge if age==.

replace age= agedead2 +(2012-yrdeath) if died==1 & yrdeath>=1998 & yrdeath<2012 & agedead2>35 & age==.

gen Dyear=year-L.year // At most, 5 years...
forval i=1(1)5 {
	replace age=L.age+Dyear if age==.
}
	
* 1. If there is an odd movement of age, use the calculated version
gen Dage=age- L.age
gen oD= abs(Dyear-Dage)>2 if Dyear!=. & Dage!=.
replace age=calAge if oD==1
drop oD Dage calAge

* 2. Force it!
replace age=L.age+1 if Dyear>=2 & Dyear!=. & (age-L.age<=0) & L.age!=. & age!=. // 1 cases where this can't be
replace age=L.age   if Dyear==1 &            (age-L.age< 0) & L.age!=. & age!=.  // 2 odd cases in which individuals got younger!
gen Dage=age- L.age

replace age=L.age + Dyear if abs(Dyear-Dage)>2 & Dage!=.    // Data is either censored (due to age) or wrong, so just add whatever makes sense
drop Dage 
gen Dage=age- L.age

replace age=. if abs(Dyear-Dage)>2 & Dage!=.    // 7 cases...
drop Dage 
gen Dage=age- L.age


tab Dage Dyear // As fixed as possible...
drop Dage Dyear


gen age2=age^2

* Now, fix back yob, if missing
replace dobyear=year-age if dobyear==.
bys idauniq: egen genera=median(dobyear) // Fill in the gaps
replace dobyear=genera if dobyear==.
drop genera


* Harmonize variables:

* Fix gender ***************************************
bysort idauniq: egen gendero=mode(sex)
gen masc=gendero==1

* Fix ethnicity ************************************
 rename nonwhite nonwhiteIFS
gen nonwhiter=(fqethnr!=1) if fqethnr>0
replace nonwhiter=(ethnicr!=1) if ethnicr>0 & wave==0
bysort idauniq: egen nonwhite=mode(nonwhiter)

replace nonwhite=0 if nonwhiteIFS<1 & nonwhiteIFS!=.
replace nonwhite=1 if nonwhiteIFS==1 & nonwhiteIFS!=.

* Fix education ************************************
* Simplify and solve missings

bysort idauniq: egen educa=mode(edqual) , maxmode  /*Variation here is irrelevant and could be confusing */
replace educa=. if educa<0
label values educa TOPQUAL2

gen educ=0 if educa==7              /* Below high-school */
replace educ=1 if educa>=3 & educa<=6   /* Some or Finished high-school, or any other unclear qualification */
replace educ=2 if educa==1 | educa==2   /* Similar to some college and above */
label define leduc 0 "No qualif" 1 "Medium Qualif" 2 "Some High Qualif"
label values educ leduc

tab educ, gen(dedu_)


* Fix civil status *********************************
*tab marital
*tab dimar

gen civilS=1 if (marital==2 | dimar==2 | dimar==3 | dimar==4 | dimar==8 | dimar==11) & (marital!=. | dimar!=.)
replace civilS=2 if (marital==3 | marital==4 | marital==5 | dimar==5 | dimar==6 | dimar==7) & (marital!=. | dimar!=.)
replace civilS=3 if (marital==1 | dimar==1) & (marital!=. | dimar!=.)

label define lcivilS 1 "Married" 2 "Ex-Married" 3 "Never Married"
label values civilS lcivilS


gen married= civilS==1
label var married "Married"


recode famtype (1=1) (6=2) (2 7 = 3) (3 4 5 8 9 10 11 12 13 14= 4), gen(shortF)
label define typef 1 "Single" 2 "Couple" 3 "Dependents" 4 "Other"
label values shortF typef
tab shortF, gen(shortF_)

recode hotenu (1=1) (2 3=2) (4 5 6 =3), gen(houseten)
label define typeh 1 "Own" 2 "Mortgage" 3 "Rent or others"
label values hotenu typeh
tab hotenu, gen(hotenu_)

* Number of children and their avg. age
/* I don't like this strategy... let's keep with alltotch
foreach varDep in chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 {
	recode `varDep' (-10/-1 = .)
}
egen numchildren=rownonmiss(chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16)
*/

* *********************************
* The refreshment sample blood pressure data
replace refresh=0 if refresh==.
replace refresh=. if refresh==1 & year==2001 /* This is different, it is the merge, not that they are refreshements */


* ************************************
* Weights and type of sample

* Clustering and stratification
* Cluster: ahsecls2, hseclst 
* Stratification: astratif, GOR (since wave 3)

* Cross-sectional analysis uses data collected only at a particular wave
/* 	The cross-sectional weights were calculated separately for each cohort. In each case the
	weighting aimed to adjust for differences in the propensity to respond amongst key subgroups.
	The final step in the calculation of the cross-sectional weight involved computing a
	scaling factor to ensure that the original sample (Cohort 1) and refreshment samples
	(Cohorts 3, 4 and 6) were represented in the same proportions, with respect to age, in
	which they appear in the population (based on the mid year household population estimates
	for the year in which fieldwork started provided by the Office for National Statistics). For
	example, for Wave 7 weights this would be the 2014 mid year household population
	estimates.*/

replace wgt=xwgt // Same variable, but xwgt includes waves 5 and 6
drop xwgt

foreach i of numlist 1 3 4 6 7 {		
	gen coho_C`i'CMx=finstat=="C`i'CM"
	bys idauniq: egen coho_C`i'CM=max(coho_C`i'CMx)
	drop coho_C`i'CMx
	replace coho_C`i'CM=0 if wave<`i' 	// If this is not the year of this sampling cohort, forget about it
										// Example: some C1YP->C3CM in wave 3, let's include them only when they become it
}
			
egen COREsince=rowmax(coho_C?CM)
label var COREsince "1 if is/was a CORE member in ELSA"

tab finstat COREsince if died==0, mi
/*Post-field final type |
     of sample member |  1 if is/was a CORE
    (including cohort |    member in ELSA
        number added) |         0          1 |     Total
----------------------+----------------------+----------
                      |   102,206     15,979 |   118,185 <--- attrited! They are not death but there is no data on them
                 C1CM |         0     46,149 |    46,149 
                 C1CP |       497          0 |       497 
                C1NP1 |       291          0 |       291 
         C1NP1_unprod |         5          0 |         5 
                C1NP2 |       149          0 |       149 
                C1NP3 |        97          0 |        97 
                C1NP4 |        57          0 |        57 
                C1NP5 |        20          0 |        20 
                C1NP6 |        10          0 |        10 
                 C1SM |         1          0 |         1 
                 C1YP |     2,265          0 |     2,265 
          C1YP_unprod |         8          0 |         8 
                 C3CM |         0      4,066 |     4,066 
                 C3CP |        44          0 |        44 
                C3NP3 |        64          0 |        64 
                C3NP4 |        30          0 |        30 
                C3NP5 |        21          0 |        21 
                C3NP6 |         3          0 |         3 
                 C3OP |       443          0 |       443 
                 C3SM |         2          0 |         2 
                 C3YP |       931          0 |       931 
                 C4CM |         0      5,993 |     5,993 
                 C4CP |        27          0 |        27 
                C4NP4 |        41          0 |        41 
                C4NP5 |        22          0 |        22 
                C4NP6 |         7          0 |         7 
                 C4OP |       401          0 |       401 
                 C4SM |        26          0 |        26 
                 C4YP |       311          0 |       311 
                 C6CM |         0        826 |       826 
                 C6CP |        28          0 |        28 
                C6NP6 |        10          0 |        10 
                 C6OP |       144          0 |       144 
                 C6YP |       146          0 |       146 
----------------------+----------------------+----------
                Total |   108,307     73,013 |   181,320  */
		
* Longitudinal weights: Calculated for the set of XX core members who have responded to all YY waves of ELSA, and remain living in private households.
replace lwgt=. if wave==1 | wave==2
replace lwgt=w5lwgt if wave==5 
replace lwgt=w6lwgt if wave==6
replace lwgt=w7lwgt if wave==7
*replace lwgt=w8lwgt if wave==8
*replace lwgt=w9lwgt if wave==9
drop w3lwgt w4lwgt w5lwgt w6lwgt w7lwgt //w8lwgt w9lwgt

* *********************************

*gen hinc=h_itot/1000

* Lagged vars
*xtile incL=h_itot if h_itot!=. & h_itot>0, n(3)
*gen Lsmoken=L.smoken

label var age "Age"
label var age2 "Age^2"
label var masc "Male"
label var nonwhite "Non white ethnicity" 

label var dedu_1 "Educ: No qualifications mentioned "
label var dedu_2 "Educ: Some medium qualif."
label var dedu_3 "Educ: Some high level or above qualif."
*label var dedu_4 "Educ: Some College"
*label var dedu_5 "Educ: College and Above"
*label var hinc "Household Income (1000£)"


gen byear=dobyear if dobyear>0
gen Ago=year-byear
gen Ago2=Ago^2

* **************************
* SIC (industry)
drop sic // Change of SIC code
drop sic92mis

tab sic2003 wave
tab sic92 wave

gen job_sendend=wpjact==1 if wpjact>0 & wpjact!=.
gen job_standing=wpjact==2 if wpjact>0 & wpjact!=.
gen job_physi=wpjact==3 | wpjact==4  if wpjact>0 & wpjact!=.

label var job_sendend  "Sedentary occupation"
label var job_standing "Standing occupation"
label var job_physi    "Physical work"

gen job_yrsExp = intdaty-wpsjoby if wpsjoby>1900 & wpsjoby!=.
label var job_yrsExp "Years in the same job"

gen job_perman = wpcjob==4 if wpcjob>0 & wpcjob!=.
label var job_perman "Permanent job position"

* ****************************************************************************************
}
*

///////////////////////////////////////////////////////////////////////////////////////////
// Diseases and Medication
///////////////////////////////////////////////////////////////////////////////////////////

if 1==1 {

* First, update the derived vars using the same algorithm as in the documentation
foreach dis in bp di st mi hf an hm ar { // dh is not in waves 6 and 7 (only di exists there)
	replace hediag`dis'=9  if hedim`dis'==1  & wave==9
	replace hediag`dis'=8  if hedim`dis'==1  & wave==8
	replace hediag`dis'=7  if hedim`dis'==1  & wave==7
	replace hediag`dis'=6  if hedim`dis'==1  & wave==6
	replace hediag`dis'=L.hediag`dis'  if hedim`dis'==0  & (wave==6 | wave==7 | wave==8 | wave==9) & hediag`dis'
	replace hediag`dis'=.b if hedim`dis'==-8 & (wave==6 | wave==7 | wave==8 | wave==9)
	replace hediag`dis'=.a if hedim`dis'==-9 & (wave==6 | wave==7 | wave==8 | wave==9)
	replace hediag`dis'=L.hediag`dis' if L.hediag`dis'>=1 & L.hediag`dis'<=5
}

foreach dis in lu as ar ca {
	replace hebdia`dis'=9  if hedib`dis'==1  & wave==9
	replace hebdia`dis'=8  if hedib`dis'==1  & wave==8
	replace hebdia`dis'=7  if hedib`dis'==1  & wave==7
	replace hebdia`dis'=6  if hedib`dis'==1  & wave==6 
	replace hebdia`dis'=L.hedib`dis'  if hedib`dis'==0  & (wave==6 | wave==7 | wave==8 | wave==9)
	replace hebdia`dis'=.b if hedib`dis'==-8 & (wave==6 | wave==7 | wave==8 | wave==9)
	replace hebdia`dis'=.a if hedib`dis'==-9 & (wave==6 | wave==7 | wave==8 | wave==9)
	replace hebdia`dis'=L.hebdia`dis' if L.hebdia`dis'>=1 & L.hebdia`dis'<=5
}

* NOTE: these vars must be used with caution, as they report only on knowledge up to the wave

* ****************************************************************************************
* HBP .... ok, it was fixed by NatCen directly
* ****************************************************************************************
xtset idauniq wave

*hediagbp (W12345): Wave when diagnosis of high blood pressure was first reported
* hedimbp (W456)  : CVD: high blood pressure diagnosis newly reported (merged)
*                   If not new, it is a 0
* hedacbp (W456)  : Whether confirms high blood pressure diagnosis
* IMPORTANT: THE MEANING OF hedimbp CHANGE IN WAVES 4 AND 5
*            THAT'S WHY IT WAS RECODED INTO hediagbp,WHICH IS
*            MORE LIKE IT

* Waves 4, 5, 6 and 7 style......................... 
* This is incorrect: it works well for those who where diagnosed
* this wave or the previous, but it says nothing about past waves
* therefore, it is not possible to construct it
	*gen hibpeSR=.
	* Old cases
	*	replace hibpeSR=1  if hedacbp == 1 //  Still has HBP
	*	replace hibpeSR=0  if hedacbp == 2 //  No more HBP!
	*   replace hibpeSR=0  if hedacbp ==-1 //  Didn't have it before OR YOU WHERE DIAGNOSED BEFORE LAST WAVE!! SO< IS WRONG
	* New cases
	*	replace hibpeSR=.a if hedimbp == -9 // Refusal to say if diagnosed
	*	replace hibpeSR=.b if hedimbp == -8 // Don't know
	*	replace hibpeSR=0  if hedimbp == 0 & hibpe!=1  //  Not this wave, and not diagnosed before
	*	replace hibpeSR=1  if hedimbp == 1  //  Diagnosed this wave
	 
	* hediagbp style (waves 1,2,3,4,5)...............
* That is, if ever had reported HIBPE

* Second, generate an indicator per wave
gen hibpe=.
	replace hibpe=0 if hediagbp==0
	replace hibpe=0 if hediagbp>wave & hediagbp<=7
	replace hibpe=1 if hediagbp>0 & hediagbp<=wave
	
* Third, add wave 0:
replace hibpe=1 if bp1==1
replace hibpe=0 if bp1==2

* Fourth, let's trust ELSA over HSE
replace hibpe=0 if F.hibpe==0 & wave==0

tab hibpe wave , mi
* Missings in bp1 come from "2001, 2002, 2003, 2004, 2006" where this question was not in place
tab hibpe wave if wave0data ==., mi

label var hibpe "Diagnosed HBP ever"


* Just checking... ok!
tab hediagbp hibpe // Don't worry about the "wave 2" issue, it is just wave 1 that has information on wave 2, 
tab hedimbp hibpe  // Ok
tab hedacbp hibpe // This shows that the Self-Report and the "ever" version are different!


gen partnerSick=srh3_hrs_p==3
label var partnerSick "Partner sick (not sick if not have a partner)"

* ****************************************************************************************
* Diabetes / Diabetes or High Blood Sugar
* ****************************************************************************************
* Second, generate an indicator per wave
gen diab=.
	replace diab=0 if !missing(hediagdi) //  Diabetes OR high blood sugar
	replace diab=1 if hediagdi>0 & hediagdi<=wave  // Diabetes
	replace diab=1 if hediagdh>0 & hediagdh<=wave & hediagdh!=. // Diabetes OR high blood sugar, from wave 6 onwards
		
* Third, add wave 0:
replace diab=1 if diabete2==1
replace diab=0 if diabete2==2		

* Fourth, let's trust ELSA over HSE
replace diab=0 if F.diab==0 & wave==0

label var diab  "Diagnosed Diabetes ever"
* ****************************************************************************************
* Stroke
* ****************************************************************************************

* Second, generate an indicator per wave
gen strok=.
	replace strok=0 if hediagst==0
	replace strok=0 if hediagst>wave & hediagst<=7
	replace strok=1 if hediagst>0 & hediagst<=wave
		
* Third, add wave 0:
replace strok=1 if strodef==1
replace strok=0 if strodef==2		

* Fourth, let's trust ELSA over HSE
replace strok=0 if F.strok==0 & wave==0

label var strok  "Diagnosed Stroke ever"

* ****************************************************************************************
* Congestive Heart Failure
* ****************************************************************************************

gen chf=.
	replace chf=0 if hediaghf==0
	replace chf=0 if hediaghf>wave & hediaghf<=7
	replace chf=1 if hediaghf>0 & hediaghf<=wave

* ****************************************************************************************
* Myocardial infarction
* ****************************************************************************************

gen minfar=.
	replace minfar=0 if hediagmi==0
	replace minfar=0 if hediagmi>wave & hediagmi<=7
	replace minfar=1 if hediagmi>0 & hediagmi<=wave	
	

* ****************************************************************************************
* Angina
* ****************************************************************************************

gen angina=.
	replace angina=0 if hediagan==0
	replace angina=0 if hediagan>wave & hediagan<=7
	replace angina=1 if hediagan>0 & hediagan<=wave	
	
* ****************************************************************************************
* Major Heart Event: Stroke / Congestive Heart Failure/ M Infarction / Angina * What about TIA?? No data!
* ****************************************************************************************

* Second, generate an indicator per wave
gen heartMa=.
	foreach varDep in {
		replace `varDep'=. if `varDep'<0
	}
	replace heartMa=0 if !missing(hediagst,hediagmi,hediaghf,hediagan) // Stroke,  Myocardial infarction,  Heart failure, Angina	
	
	replace heartMa=1 if hediagst>0 & hediagst<=wave // Stroke
	replace heartMa=1 if hediagmi>0 & hediagmi<=wave // Myocardial infarction
	replace heartMa=1 if hediaghf>0 & hediaghf<=wave // Heart failure
	replace heartMa=1 if hediagan>0 & hediagan<=wave // Angina	
		
* Third, add wave 0:
replace heartMa=0 if strodef==2 // Stroke		
replace heartMa=0 if heartdef==2 // Myocardial infarction
*replace heartOt=0 if strodef==2 // Heart failure
replace heartMa=0 if angidef==2 // Angina	

replace heartMa=1 if strodef==1 // Stroke		
replace heartMa=1 if heartdef==1 // Myocardial infarction
*replace heartOt=1 if strodef==1 // Heart failure
replace heartMa=1 if angidef==1 // Angina	

* Fourth, let's trust ELSA over HSE
replace heartMa=0 if F.heartMa==0 & wave==0

label var heartMa  "Diagnosed Major Cardiovascular Event ever (Stroke, Heart Failure, Infarction, Angina)"

*Sick since...
foreach suf in a b c e { // angina, heart attack, congestive failure, stroke
	gen yrsSinceDiag`suf' =age-heag`suf' if heag`suf'>0 & heag`suf'!=.
	replace yrsSinceDiag`suf'=iintdty- heag`suf'ry if heag`suf'ry>0 & heag`suf'ry!=. // angina
}

egen heartMaSince=rowmax(yrsSinceDiaga yrsSinceDiagb yrsSinceDiagc yrsSinceDiage)
label var heartMaSince "Time since first CVD-event"


* ****************************************************************************************
* Other Heart Conditions: Heart Murmur / Arrhytmia
* ****************************************************************************************

* Second, generate an indicator per wave
gen heartOt=.
	replace heartOt=0 if hediaghm==0 // Heart Murmur
	replace heartOt=0 if hediagar==0 // Arrhythmia
	
	replace heartOt=0 if hediaghm>wave & hediaghm<=7 // Heart Murmur
	replace heartOt=0 if hediagar>wave & hediagar<=7 // Arrhythmia
	
	replace heartOt=1 if hediaghm>0 & hediaghm<=wave // Heart Murmur
	replace heartOt=1 if hediagar>0 & hediagar<=wave // Arrhythmia
		
* Third, add wave 0:
replace heartOt=0 if murmur1==2 // Heart Murmur
replace heartOt=0 if iregdef==2 // Arrhythmia

replace heartOt=1 if murmur1==1 // Heart Murmur
replace heartOt=1 if iregdef==1 // Arrhythmia

* What about the "others"??
*replace r_heart=ohtdef==1 if ohtdef>0 & ohtdef!=.

* Fourth, let's trust ELSA over HSE
replace heartOt=0 if F.heartOt==0 & wave==0

label var heartOt  "Diagnosed Heart Event ever (Heart Murmur, Arrhytmia)"
* ****************************************************************************************
* Lung/Asthma
* ****************************************************************************************

* Second, generate an indicator per wave
gen lunge=.
	replace lunge=0 if hebdialu==0 // Lung
	replace lunge=0 if hebdiaas==0 // Asthma		
	replace lunge=0 if hebdialu>wave & hebdialu<=7 // Lung
	replace lunge=0 if hebdiaas>wave & hebdiaas<=7 // Asthma	
	replace lunge=1 if hebdialu>0 & hebdialu<=wave // Lung
	replace lunge=1 if hebdiaas>0 & hebdiaas<=wave // Asthma
		
* Third, add wave 0: there is no info here	

label var lunge  "Diagnosed Respiratory Dis ever"
* ****************************************************************************************
* Arthritis
* ****************************************************************************************

* Second, generate an indicator per wave
gen arthre=.
	replace arthre=0 if hebdiaar==0
	replace arthre=0 if hebdiaar>wave & hebdiaar<=7
	replace arthre=1 if hebdiaar>0 & hebdiaar<=wave
		
* Third, add wave 0: there is no info here	

label var arthre  "Diagnosed Arthritis ever"
* ****************************************************************************************
* Cancer
* ****************************************************************************************

* Second, generate an indicator per wave
gen cancr=.
	replace cancr=0 if hebdiaca==0
	replace cancr=0 if hebdiaca>wave & hebdiaca<=7
	replace cancr=1 if hebdiaca>0 & hebdiaca<=wave
		
* Third, add wave 0: there is no info here	

label var cancr "Diagnosed Cancer ever"		
* ****************************************************************************************
* Blood Pressure Medication
* ****************************************************************************************

gen bppills=.
replace bppills= hemda==1 if hemda>=-1 & hemda!=.      /* ELSA vars */
replace bppills= hemdab==1 if hemdab>=-1 & hemda ==-1  & hemdab!=. & hemda!=.  /* ELSA vars */
replace bppills= bpmedc==1 if bpmedc>=-1 & bpmedc!=. /* Wave 0 */
replace bppills= bpmedd==1 if bpmedd>=-1 & bpmedd!=.  /* Wave 0 */
   
label var bppills "Takes BP medication"	
	
	* In wave 2 there was a feed forward problem!!!!
	* They did not ask a lot of people about this!!!
	* So I have to impose that EVERYONE who where taking pills at
	* wave 1, must be doing the same at wave 2
	
replace bppills=1 if L.bppills==1 & wave==2 & hemda==-1
replace bppills=. if hemda==-8	
	
*Lhibpe
xtset  idauniq wave
gen Lbppills=L.bppills
*Ldiab	
	
* ****************************************************************************************
* High Cholesterol
* ****************************************************************************************
* Fist, generate an indicator per wave 3,4,5
gen chole=.
	replace chole=0 if hediaghc==0
	replace chole=0 if hediaghc>wave & hediaghc<=7
	replace chole=1 if hediaghc>0 & hediaghc<=wave

* Second, let's add wave 6
replace chole=L.chole if (wave==6 | wave==7)  		// Fed-forward past results
replace chole=1 if hedimch==1 & (wave==6 | wave==7)	// If new cases are reported, add them

	
	* An alternative version... I don't trust it
		gen chole2= 1 if hedimch==1
	replace chole2= 1 if hedimch!=1 & hedacch== 1
	replace chole2= 0 if hedimch!=1 & hedacch== 2
	replace chole2= 0 if hedimch!=1 & hedacch==-1
	replace chole2=.a if hedimch!=1 & hedacch==-2
	replace chole2=.b if hedimch!=1 & (hedacch==-8 | hedacch==3)

tab chole chole2	
	
* Third, add wave 2:
replace chole=choleW2 if wave==2
replace chole2=choleW2 if wave==2

label var chole "High Cholesterol, wave 2 onwards"
label var chole2 "High Cholesterol, wave 2 -prob incorrect-"

* ****************************************************************************************
* High Cholesterol Medication
* ****************************************************************************************

	
gen     lipidpill= hechmd==1 if hechmd>=-1 & hechmd!=.
replace lipidpill= 1 if hechme==1
replace lipidpill= 0 if hechme==2

label var lipidpill "Takes Lipid-lowering medication"			

* ****************************************************************************************
* Diabetes, Stroke and other CVDs
* ****************************************************************************************


egen anyCVD=rowmax(hibpe heartMa heartOt)
label var anyCVD "Diagnosed with any CVD-related condition"

* ****************************************************************************************
* Demand for Health Care
* ****************************************************************************************

gen visitGPlast4= whendoc==1 | whendoc==2 if whendoc>0 & whendoc!=.
replace visitGPlast4= hegpoft==1 if hegpoft>0 & hegpoft!=.
label var visitGPlast4 "Visit GP during the last 4 weeks"

recode whendoc (-8 -1 =.)

*hegpnhs


* ****************************************************************************************
}
*
///////////////////////////////////////////////////////////////////////////////////////////
// Behaviours
///////////////////////////////////////////////////////////////////////////////////////////
if 1==1 {
* *****************************************************************************************
* Smoking 
* *****************************************************************************************

* Ever smoker? If disputes, say he has the reason
replace r_smokev=1 if hesmk==1
replace r_smokev=0 if hesmk==2

* People who never smoke, cleary are not smokers nowadays
replace r_smoken=0 if r_smokev==0


* Smoking nowadays? If disputes, say he has the reason
replace r_smoken=1 if heska==1
replace r_smoken=0 if heska==2

gen Osmoken=r_smoken
gen LOsmoken=L.r_smoken

* Doble-check questions
	* Delete all smoking behaviour in this wave or before if they
	*    report there was a problem with the records> there have never smoked before
	gen wheretostop=(heske==1)*wave
	replace wheretostop=. if wheretostop==0
	bys idauniq : egen StpH=max(wheretostop)
	bys idauniq : replace r_smokev=0 if  wave<=StpH & StpH!=.
	bys idauniq : replace r_smoken=0 if  wave<=StpH & StpH!=.


	* 1) If they say they had already stopped by last wave, believe them
	replace r_smoken=0 if F.heske==2
	* 2) If it is the case of still being smoking now, fix it
	replace r_smoken=1 if heskf==1

gen Lsmoken=L.r_smoken
	
* Really odd, from wave 0 to wave 1, and 4 to 5, there are crazy changes!
gen changSmkev= r_smokev==0 & L.r_smokev==1
tab changSmkev wave
* Close to 1000 people said that they have never smoke, but they said that they had on wave 1!!

gen changSmkn= r_smoken==0 & L.r_smoken==1
tab changSmkn wave


* The first ones are in all waves, the later ones only in the ELSA
foreach var in r_smokev r_smoken  { //   r_lung r_asth r_arth r_cancr {
	local name = substr("`var'",3,length("`var'")-2 )
	gen `name' = `var'==1 if `var'>=0 & `var'!=.
	cap gen L`name'=L.`name'	
}





* None of them were previous smokers in the last wave
tab changSmkev changSmkn

* The ELSA provides for waves 2, 3, 4 and 5 information on quitting:
gen stoped= hestop>0 & hestop!=.
tab stoped changSmkn if wave>1

* People who I do not recognize as quitters...
tab r_smoken if stoped==1 & changSmkn==0 /* Ok... */
tab Lsmoken if stoped==1 & changSmkn==0  /* That's ok: people who I do not observe before */

* People who I recognize as quitters, but the survey does not
tab r_smoken if stoped==0 & changSmkn==1 & wave>1 /* Ok... */
tab Lsmoken if stoped==0 & changSmkn==1 & wave>1 /* Clearly there is an issue */
tab heskd if stoped==0 & changSmkn==1 & wave>1 /* 62 non-elegible? */
tab heskf if stoped==0 & changSmkn==1 & wave>1 /* Clearly there is an issue */
tab LOsmoken Osmoken if stoped==0 & changSmkn==1 & wave>1 /* Still 35 are people who have were stoppers before the revitions */
tab heskf if LOsmoken==1 & Osmoken==0 & stoped==0 & changSmkn==1 & wave>1 /* 31 of these are very weird! The others are just stupid*/
gen Lheska=L.heska
tab Lheska if LOsmoken==1 & Osmoken==0 & heskf==-1 & stoped==0 & changSmkn==1 & wave>1 , nol /* 31 of these are very weird! No idea at all */              
gen weird= (LOsmoken==1 & Osmoken==0 & heskf==-1 & stoped==0 & changSmkn==1) if wave>1
bys idauniq : egen weirdGuy=max(weird)
tab heskd heska if weird==1
tab weird wave
	* The issue> These 31 guys stop smoking according to the data after wave 1, but they are not asked for confirmation (keskd)
	* and it is not due to the fixes done due to confirmation questions in other waves. Why? I just don't know!
	* If there is no dispute, I can keep them...


* Fix smoking **************************************

*use cigdyal cigst1 cigst2 from wave 0 to contrast

replace smoken=smoker if smoker>=0 & wave>0 // Use IFS derived version of smoking
drop Lsmoken
gen Lsmoken=L.smoken

sum heskb, d
replace heskb=. if heskb>r(p99)

sum heskc, d
replace heskc=. if heskc>r(p99)


gen cig1=heskb*5 if heskb>0
gen cig2=heskc*2 if heskc>0
*replace cig1=cig2 if cig1==.
*replace cig2=cig1 if cig2==.
gen smokeInt= cig1+cig2 if hecig==1 | hecig==3 | wave==0
replace smokeInt=. if smoken==0
label var smokeInt "Cigaretes per week"

replace heskc=. if heskc<0 | smoken==0
replace heskb=. if heskb<0 | smoken==0

label var heskb "Cigarettes a day (weekdays)"
label var heskc "Cigarettes a day (weekends)"

label var Lsmoken "Smoker on last wave"
label var smokev "Ever smoker"
label var smoken "Current smoker"




***

gen cig1eq=.
replace cig1eq=hetbd*1*5     if hetbc==1 & hetbd>=0 // Grams, weekday (1 gram -> 1 cig)
replace cig1eq=hetbd*28.35*5 if hetbc==2 & hetbd>=0 // Ounces, weekday (1 gram -> 1 cig)
sum cig1eq, d
replace cig1eq=. if cig1eq>r(p99)

gen cig2eq=.
replace cig2eq=hetbb*1*2     if hetba==1 & hetbb>=0 // Grams, weekend (1 gram -> 1 cig)
replace cig2eq=hetbb*28.35*2 if hetba==2 & hetbb>=0 // Ounces, weekend (1 gram -> 1 cig)
sum cig2eq, d
replace cig2eq=. if cig2eq>r(p99)


gen     smokeIntI= cig1eq+ cig2eq    if hecig==2 | hecig==3	
replace smokeIntI=smokeInt+smokeIntI if hecig==3
replace smokeIntI=smokeInt if hecig==1 | wave==0 // In wave 0, cigarettes measure includes roll-ups! (check cig type question)

replace smokeIntI=. if smoken==0
label var smokeIntI "Cigaretes per week (including rollups)"


gen smokeInt3=smokeInt if wave>0 // In this case, we cannot separate cigs from roll-ups
replace smokeInt3=0 if smoken==0 & wave>0
label var smokeInt3 "Cigaretes per week (0 for non-smokers)"

gen smokeInt3b=smokeIntI
replace smokeInt3b=0 if smoken==0 
label var smokeInt3b "Cigaretes per week (0 for non-smokers, includes rollups)"

replace smokeInt=. if wave==0 // In this case, we cannot separate cigs from roll-ups

* *****************************************************************************************
* Physical activity 
* *****************************************************************************************

* Let's construct again this derived variable so Wave 6 and 7 data can be obtained
rename palevel palevelOrig

gen palevel=.

replace palevel=0 if wpjact == 1 & (heactc == 3 | heactc == 4) & heactb == 4 & heacta == 4  /* Not working or sedentary occupation, engages in mild exercise 1–3 times a month or less, with no moderate or vigorous activity. */

replace palevel=0 if wpjact ==-1 &  (heactc == 3 | heactc == 4) & heactb==4 & heacta==4                       /* If it is not working  */

replace palevel=1 if wpjact == 2 & (heactb == 2 | heactb == 3 | heactb == 4) & heacta ==4  /* Standing occupation, engages in moderate leisure-time exercise once a week or less and no vigorous activity */
replace palevel=1 if (heactc > 0 & heactc < 4) & (heactb > 1 & heactb <= 4) & heacta == 4  /* engages in mild leisure-time activity at least 1–3 times a month, moderate once a week or less and no vigorous */
replace palevel=1 if (wpjact == -1 | wpjact == 1) & (heactb == 2 | heactb ==3) & heacta == 4  /* has a sedentary or no occupation and engages in moderate leisure-time activity once a week or 1–3 times a month, with no vigorous activity */

replace palevel=2 if wpjact == 3 | heactb == 1 | (heacta == 2 | heacta == 3)  /* Does physical work; OR engages in moderate leisure-time activity more than once a week; OR engages in vigorous activity once a week to 1–3 times a month. */

replace palevel=3 if wpjact == 4 | heacta == 1 /* Heavy manual work or vigorous leisure activity more than once a week. */

replace palevel=-8 if  wpjact == -9 | wpjact == -8 | heacta == -9 | heacta == -8 | heactb == -9 | heactb == -8 | heactc == -9 | heactc == -8 
replace palevel=-1 if heacta==-1

label values palevel palevel
tab palevelOrig palevel  /* it is the same for waves 1-5, that's good */
drop palevelOrig


* What about Wave 0???
* This stuff on physical activity... they seems to be different stuff
tab actlevel /* More objective, and includes quest. on sports, work, housework... */
tab palevel  /* Your perception on mild, moderate, vigorous activities ? */

recode palevel ( 0 1 = 1) (-8 -1=.) , gen(phyact)
label values phyact palevel
label var phyact "Physical Activity"
tab phyact, gen(dphy)
label var dphy1 "1. Sedentary or low physical activity"
label var dphy2 "2. Moderate physical activity"
label var dphy3 "3. High physical activity"

* *****************************************************************************************
* Alcohol Intake 
* *****************************************************************************************

* wave 0: dnoft2
* wave 1: heala    Interesting: self-assesed change of behaviour
*                     healb (yes/no)  and healc (sign)
gen deltaAw1=healb==1 if healb>0 & healb!=.
* wave 2-5: scako  Paper self-complete... selection issues?

* Almost every day / Once or Twice a day / Daily or almost daily
gen     alco1=dnoft2>=1 & dnoft2<=3 if dnoft2>0 & dnoft2!=.
replace alco1=heala==1 | heala==2   if heala>0 & heala!=.
replace alco1=scako==1 & scako<=3   if scako>0 & scako!=.
* Every week: Once or twice a week
gen     alco2=dnoft2==4  if dnoft2>0 & dnoft2!=.
replace alco2=heala==3   if heala>0 & heala!=.
replace alco2=scako==4   if scako>0 & scako!=.
* Ocasional: Once or twice a month or more
gen     alco3=dnoft2>=5  if dnoft2>0 & dnoft2!=.
replace alco3=heala>=5   if heala>0 & heala!=.
replace alco3=scako>=5   if scako>0 & scako!=.

gen alcoC=alco1
replace alcoC=2 if alco2==1
replace alcoC=3 if alco3==1 /* The most stable one */
replace alcoC=. if alcoC==0

label var alco1 "1. Alcohol: More than once a week"
label var alco2 "2. Alcohol: Once or twice a week"
label var alco3 "3. Alcohol: Once or twice a month or less"
label define alcoCl 1 "1. More than once a week" 2 "2. Once or twice a week" 3 "3. Once or twice a month or less"
label values alcoC alcoCl
label var alcoC "Alcohol intake"

* This could be problematic... may be they are not 
* comparable at all!!

* Is it possible to construct the "3 drinks or more per day?"
	* May be 2 per day... and that's all!
	* This variable gives the number of alcohol units consumed on the heaviest day’s drinking in the
	* week prior to interview. Respondents were first asked how often they drank alcohol in the previous
	* the heaviest day in that week. 

	/* For wave2... maxalc. However, the questions change a lot across the waves
		gen maxalc = 0
		replace maxalc = maxalc + scabnp*2     if scabnp >= 0
		replace maxalc = maxalc + scabnlc*1.5  if scabnlc >= 0 
		replace maxalc = maxalc + scabnsc      if scabnsc >= 0
		replace maxalc = maxalc + scabsp*3     if scabsp >= 0
		replace maxalc = maxalc + scabslc*2.25 if scabslc >= 0
		replace maxalc = maxalc + scabssc*1.5  if scabssc >= 0
		replace maxalc = maxalc + scaspir      if scaspir >= 0
		replace maxalc = maxalc + scasher      if scasher >= 0
		replace maxalc = maxalc + scawin       if scawin >= 0
		replace maxalc = maxalc + scapopg      if scapopg >= 0
	*/
	
* *****************************************************************************************
* Fruits and vegtables
* *****************************************************************************************


* Only waves 3 and 4, and other measure in wave 5
* And waves

* hist scveg if scveg <18, by(year)
* hist scfru if scfru <18, by(year)
	
label var scveg "Portions of vegtables per day"	
label var scfru "Portions of fruits per day"	
		
	
* ****************************************************************************************	
}	

*
///////////////////////////////////////////////////////////////////////////////////////////
// Perceptions and Expectations
///////////////////////////////////////////////////////////////////////////////////////////
*
if 1==1 {

* **************************************************************************************
* Subjective Survival Probabilities
* **************************************************************************************

* See documentation for this variable: what it means depend on the respondent age
gen ssp75=exlo80 if exlo80>=0 & exlo80!=. & age<=65
label var ssp75 "SSP: Chances to live to age 75"
forval num=0(5)40 {
	local dest = 80 + `num'
	local lb = 65+`num'
	local ub = 70+`num'
	gen ssp`dest'=exlo80 if exlo80>=0 & exlo80!=. & age>`lb' & age<=`ub'
	label var ssp`dest' "SSP: Chances to live to age `dest'"
}

replace ssp75=. if age>67

		

* Mortality to age 85?
replace exlo90=. if exlo90<0
replace exlo90=. if age>=70

* **************************************************************************************
* Expectations on Being Working
* **************************************************************************************
foreach varDep in expw expwf exwork55 exwork60 exwork65 {
	replace `varDep'=. if `varDep'<0
}
* Depends on age AND gender:
*exwork55 -> female 50..54
*exwork60 -> female 55..59, male 50..59
*exwork65 -> males 60..64

* **************************************************************************************
* Expectations on Health Limitation and Financial Problems
* **************************************************************************************

replace exhlim=. if exhlim<0
replace exrslf=. if exrslf<0


* **************************************************************************************
* Desired age of retirement
* **************************************************************************************
replace scrtage=. if (scrtage >99) | (scrtage <age) | (scrtage <=0)
* hist scrtage if scrtage <100 & scrtage >age & scrtage >0	

	
* **************************************************************************************
* Self Reported Health 
* **************************************************************************************
* Quite complicated in this survey

gen badHealth=hehelf==4 | hehelf==5 if hehelf>0 & hehelf!=.
replace badHealth=hehelfb==4 | hehelfb==5 if badHealth==. & hehelfb!=. & hehelfb>0
replace badHealth=genhelf==4 | genhelf==5 if badHealth==. & genhelf!=. & genhelf>0
replace badHealth=hegenh==3 | hegenh==4 | hegenh==5 if badHealth==. & hegenh!=. & hegenh>0

label var badHealth "Self-reported bad health"

gen     goodHealth= hehelf==1 | hehelf==2 | hehelf==3    if hehelf!=. & hehelf>0     /* waves 1 to 5 */
replace goodHealth= hehelfb==1 | hehelfb==2 | hehelfb==3 if hehelfb!=. & hehelfb>0   /* wave 1, sole difference is timing */
* These other two have a different style
replace goodHealth= genhelf==1 | genhelf==2 if genhelf!=. & genhelf>0  /* wave 0 */
replace goodHealth= hegenh==1 | hegenh==2 if hegenh!=. & hegenh>0      /* waves 1 and 3 */
label var goodHealth "Self-reported GOOD health"

* SRH: New classification, 1. Very good, good, fair, poor
recode hehelf   (1 2=1) (3=2) (4=3) (5=4) if hehelf>0, gen(SRH)
recode hehelfb  (1 2=1) (3=2) (4=3) (5=4) if hehelfb>0, gen(SRH2)
replace SRH=SRH2 if SRH==.

recode hegenh  (1 =1) (2=2) (3=3) (4 5=4) if hegenh>0, gen(SRH3)
recode genhelf (1 =1) (2=2) (3=3) (4 5=4) if genhelf>0, gen(SRH4)
replace SRH=SRH3 if SRH==.
replace SRH=SRH4 if SRH==.
label define lSRH 1 "1. Very Good" 2 "2. Good" 3 "3. Fair" 4 "4. Bad" , replace
label var SRH "Self Reported Health: 1 very good to 4 bad"
label values SRH lSRH
drop SRH2 SRH3 SRH4


* ****************************************************************************************
}
*
///////////////////////////////////////////////////////////////////////////////////////////
// Objective Health Measures
///////////////////////////////////////////////////////////////////////////////////////////

if 1==1 {

* ****************************************************************************************
* Clean derived measures
* ****************************************************************************************

replace fglu=. if fglu<0		// Blood glucose level (mmol/L)
replace sysval=. if sysval<1
replace diaval=. if diaval<1
replace bmival=. if bmival<1
replace hdl =. if hdl<0
replace chol=. if chol<1
replace ldl =. if ldl<0
replace bmi =. if bmi<1		
		
replace wstval=. if wstval>200 | wstval<57
replace htval=. if htval<100


replace htfvc=. if htfvc<0
replace htfev=. if htfev<0

replace gtspd_av= gtspd_mn if wave==4

* ****************************************************************************************
* Physical Function
* ****************************************************************************************

recode memtotb (-9/-1=.)
recode execnn (-9/-1=.)
recode nright (-3=.)

recode mmgsd1 (-9 / 0 =.)
recode mmgsd2 (-9 / 0 =.)
recode mmgsd3 (-9 / 0 =.)
egen grips = rowmean(mmgsd1 mmgsd2 mmgsd3)
label var grips "Grip strength: Avg measurement dominant hand (kg)"
	
* ****************************************************************************************
* 10-years Framingham CVD risk
* ****************************************************************************************

*  D'Agostino, Vasan, Pencina, Wolf, Cobain, Massaro, Kannel. 'A General Cardiovascular Risk Profile for Use in Primary Care: The Framingham Heart Study'
* http://www.framinghamheartstudy.org/risk-functions/cardiovascular-disease/10-year-risk.php


* Conversion: 18 × 5 mmol/dl = 90 mg/dl
gen TCL=chol*18.0182  /* chol is (mmol/l), while here it is mg/dL  */
gen HDL=hdl*18.0182   /* hdl is (mmol/l), while here it is mg/dL  */

	* This is just for testing the "program"
	cap drop riskn  framinghamCVDRisk
	glo newObs = _N + 1
	set obs $newObs
	replace age=55     in $newObs
	replace masc=1     in $newObs
	replace sysval=137 in $newObs
	replace TCL=180    in $newObs
	replace HDL=45     in $newObs
	replace smoken=0   in $newObs
	replace bppills=0  in $newObs
	replace diab=0	   in $newObs		 
				 
gen riskn=.
replace riskn=3.06117*ln(age)+1.1237*ln(TCL)-0.93263*ln(HDL)+0.65451*smoken+0.57367*diab 	///
             +1.93303*ln(sysval)*(1-bppills)+1.93303*ln(sysval)*bppills	if masc==1

replace riskn=2.32888*ln(age)+1.20904*ln(TCL)-0.70833*ln(HDL)+0.52873*smoken+0.69154*diab ///
             +2.76157*ln(sysval)*(1-bppills)+ 2.82263*ln(sysval)*bppills if masc==0

gen framinghamCVDRisk=.
replace framinghamCVDRisk=1-0.88936^(exp(riskn-23.9802)) if masc==1
replace framinghamCVDRisk=1-0.95012^exp(riskn-26.1931) if masc==0

* Good!! Same results as the calculator
sum framinghamCVDRisk in $newObs 
drop in $newObs

label var framinghamCVDRisk "Framingham 10 years CVD Risk"



* ****************************************************************************************
* Obesity
* ****************************************************************************************

gen fat1=bmival>=25 if bmival!=.
gen fat2=bmival>=30 if bmival!=.
gen fat3=bmival>=35 if bmival!=.
gen fat4=bmival>=40 if bmival!=.

label var fat1 "Overweight or above"
label var fat2 "Obesity I or above"
label var fat3 "Obesity II or above"
label var fat4 "Obesity III"

gen  whtrval = wstval/htval 
label var whtrval "Waist-to-height ratio (WHtR)"

gen original_order = _n
sort idauniq wave

gen balance86 = 0 if wave == 8
replace balance86 = 1 if (idauniq[_n] == idauniq[_n-2]) & wave == 8
summarize balance86

gen htval_imp86 = htval[_n-2] if wave == 8
replace htval_imp86 = htval if wave != 8

egen htval_imp86mean = mean(htval), by(idauniq)
replace htval_imp86mean = htval if wave != 8

 
gen balance96 = 0 if wave == 9
replace balance96 = 1 if (idauniq[_n] == idauniq[_n-3]) & wave == 9
sum balance96

gen htval_imp96 = htval[_n-3] if wave == 9
replace htval_imp96 = htval if wave != 9

egen htval_imp96mean = mean(htval), by(idauniq)
replace htval_imp96mean = htval if wave != 9

bys wave: sum htval htval_imp86mean htval_imp86 htval_imp96mean htval_imp96

replace htval = htval_imp86 if wave == 8
replace htval = htval_imp96 if wave == 9

sort original_order
drop original_order balance86 balance96 htval_imp86mean htval_imp96mean htval_imp86 htval_imp96

gen htval_m = htval/100
replace bmival = (wtval/(htval_m^2)) if wave == 8 | wave == 9 & wtval > 30
drop htval_m

* ****************************************************************************************
* Disability Benefits
* ****************************************************************************************
recode iahdb (2=0) (1=1) (-9 -8 -1 =.), gen(disableBen)
label var disableBen "Claims health-benefits"

tab llsill disableBen

* ****************************************************************************************
}
*
///////////////////////////////////////////////////////////////////////////////////////////
// Financial Variables
///////////////////////////////////////////////////////////////////////////////////////////#

egen earnings_r= rowtotal(empinc_r_s seinc_r_s) // These var include 0s!!!
label var earnings_r "Weekly earning from Employment/Self-employment"

gen       otinc_bu=totinc_bu_s
replace   otinc_bu=totinc_bu_s-earnings_r if earnings_r!=.
label var otinc_bu "BU total weekly income minus respondent's earnings"

gen       otincNF_bu=otinc_bu
replace   otincNF_bu=otinc_bu-assinc_bu_s if assinc_bu_s!=.
label var otincNF_bu "BU total weekly income minus respondent earnings and financial inc."

gen       otincHNF_bu=otincNF_bu
replace   otincHNF_bu=otincNF_bu+homei_bu_i if homei_bu_i!=.
label var otincHNF_bu "BU total weekly income minus respondent earnings and financial inc. other than housing"




gen Yearnings_r=earnings_r*52/1000
label var Yearnings_r "Yearly (52w) earnings from Employment/Self-employment 1000£"
gen Yotinc_bu=otinc_bu*52/1000
label var Yotinc_bu "BU total yearly (52w) income minus r. earnings 1000£"

gen YotincHNF_bu=otincHNF_bu*52/1000
label var YotincHNF_bu "BU total yearly (52w) non-financial income minus r. earnings other than housing 1000£"

gen YotincNF_bu=otincNF_bu*52/1000
label var YotincNF_bu "BU total yearly (52w) non-financial income minus r. earnings 1000£"


gen Ytotinc_bu_s=totinc_bu_s*52/1000
label var Ytotinc_bu_s  "BU total yearly income (1000£ of May2005)"

if 1==1 {

* In real terms (May2005)
foreach varDep in ///
	savings_bu_s  invests_bu_s  debt_bu_s ///
	foodinl foodinu foodoutl foodoutu ///
	leisurel leisureu ///
	clothesl clothesu ///
	transfersl transfersu ///
	otherfl otherfu ///
	gaselecl gaselecu ///
	gasl gasu ///
	elecl elecu ///
	coall coalu ///
	paral parau ///
	oill oilu ///
	woodl woodu ///	
	grossrentl grossrentu ///
	netrentl netrentu ///
	mortpayl mortpayu ///
	mortpayxl mortpayxu ///	
	earnings_r otinc_bu otincHNF_bu YotincNF_bu YotincHNF_bu ///
	Yearnings_r Ytotinc_bu_s Yotinc_bu YotincNF_bu totinc_bu_s nettotw_bu_s nettotnhw_bu_s nethw_bu_s ///
{
	replace `varDep'=`varDep'*(100/cpi)
}

* ************

gen logotinc_bu=log(Yotinc_bu)
label var logotinc_bu "LOG BU total yearly (52w) income minus r. earnings 1000£ "

gen logotincNF_bu=log(YotincNF_bu)
label var logotincNF_bu "LOG BU total yearly (52w) non-financial income minus r. earnings 1000£ "

gen logotincHNF_bu=log(YotincHNF_bu)
label var logotincHNF_bu "LOG BU total yearly (52w) non-financial income minus r. earnings other than housing 1000£ "



gen logearnings=log(Yearnings_r)
label var logearnings "LOG yearly (52w) earnings from Employment/Self-employment 1000£ "

***

replace totinc_bu_s = totinc_bu_s/1000
replace savings_bu_s =savings_bu_s /1000
replace nettotw_bu_s=nettotw_bu_s/1000
replace debt_bu_s=debt_bu_s/1000
replace nettotnhw_bu_s=nettotnhw_bu_s/1000
replace nethw_bu_s=nethw_bu_s/1000

label var totinc_bu_s  "BU total weekly income (£ of May2005)"

label var savings_bu_s "BU total savings (1000£ of May2005)"
label var nettotw_bu_s "BU total net (non-pension) wealth (1000£ of May2005)"
label var nettotnhw_bu_s "BU total net (non-housing) wealth (1000£ of May2005)"
label var debt_bu_s    "BU total financial debt (1000£ of May2005)"
label var nethw_bu_s  "BU total net primary housing wealth (1000£ of May2005)"

gen logassets=log(nettotw_bu_s)
label var logassets  "LOG BU total net (non-pension) wealth (1000£ of May2005)"
gen logassetsNH=log(nettotnhw_bu_s)
label var logassetsNH  "LOG BU total net (non-housing/pension) wealth (1000£ of May2005)"

* ************

foreach varDep in ///
	foodinl foodinu foodoutl foodoutu ///
	leisurel leisureu ///
	clothesl clothesu ///
	otherfl otherfu ///
{
	replace `varDep'=. if `varDep'<0
}

egen foodin= rowmean(foodinl foodinu)
egen foodout= rowmean(foodoutl foodoutu)
egen leisure= rowmean(leisurel leisureu)
egen clothes= rowmean(clothesl clothesu)
egen fuel   = rowmean(otherfl otherfu)

gen totconsumption=foodin+foodout+leisure+clothes
sum totconsumption, d
replace totconsumption=. if totconsumption>100000 // Shall I??

label var foodin         "HH Weekly Food-In  Consumption (£ of May2005)" 
label var foodout        "HH Weekly Food-Out Consumption (£ of May2005)" 
label var leisure        "HH Weekly Leisure  Consumption (£ of May2005)" 
label var clothesl       "HH Weekly Clothes  Consumption (£ of May2005)" 
label var totconsumption "HH Weekly Total Consumption (£ of May2005)"

* **************************************************
* Reconstruct IFS derived variables

rename wpactive wpactiveOrig
gen wpactive=(wpactw==1 | wpactw==2) if wpactw!=.
label var wpactive "Working"
tab wpactive wpactiveOrig /* This is odd: 48 do not match */
replace wpactive=. if wpactive!=wpactiveOrig & wave!=6 & wave!=7  /* Don't use them */
drop wpactiveOrig


gen work_no= worktime==-1 if worktime!=. & worktime!=. // The "-8" is people who said that they work, but for which there is no "hours" information
label var work_no "Not working"
gen work_full= worktime==1 if worktime!=. & worktime!=.
label var work_full "Working full time"
gen work_part= worktime==2 if worktime!=. & worktime!=.
label var work_part "Working part time"



*MIRAR ESTO DE LAS HORAS, HAY MUCHAS FUERA DE UN RANGO LOGICO!!!
/*
rename hours hoursOrig
gen hours = wphwrk if wphwrk~=-1	   // Self-employ			
 replace hours = wphjob if wphjob~=-1  // Employees
 replace hours =  0 if wpactive==0				
 replace hours = -8 if wpactive==1 & wphjob==-1 & wphwrk==-1			
 replace hours = -8 if hours==-9	
 */
 label var hours "Hours of work main job (employed or self employed)"
 /*
 gen difH=hours-hoursOrig
 tab difH  /* This is odd: 48 do not match */
replace hours=. if difH!=. /* Don't use them */  
drop hoursOrig difH

rename  hours_aj hours_ajOrig

gen     subshours = 0 if wpmoj~=1			
 replace subshours = wphmsj if wpmoj==1				
 gen hours_aj = hours+subshours if hours>=0& subshours>=0			
 replace hours_aj = -8 if hours==-8|subshours==-8|subshours==-9	
 */
 label var hours_aj "Hours of work all jobs (employed or self employed)"
 /*
  gen difH=hours_aj-hours_ajOrig
  tab difH  /* Ok */
  replace hours=. if difH!=0 /* Don't use them */  
drop    difH hours_ajOrig
*/

replace hours=. if hours<0
replace hours_aj=. if hours_aj<0

replace hours_aj=. if wpactive==0
replace hours_aj=. if hours_aj<0

/*
rename thp_r_i thp_r_iOrig
rename oj_r_i oj_r_iOrig
rename empinc_r_s empinc_r_sOrig

* Wage per week main job
gen     thp_r_i=.
replace thp_r_i=wpthp*1       if wpperi==1 | wpperi==90
replace thp_r_i=wpthp*(1/2)   if wpperi==2
replace thp_r_i=wpthp*(1/3)   if wpperi==3
replace thp_r_i=wpthp*(1/4)   if wpperi==5 | wpperi==4
replace thp_r_i=wpthp*(1/9)   if wpperi==7
replace thp_r_i=wpthp*(8/52)  if wpperi==8
replace thp_r_i=wpthp*(10/52) if wpperi==10
replace thp_r_i=wpthp*(1/13)  if wpperi==13
replace thp_r_i=wpthp*(1/26)  if wpperi==26
replace thp_r_i=wpthp*(1/52)  if wpperi==52
replace thp_r_i=. if wpthp<0
*/
label var thp_r_i "Employees: Take-home pay last time MAIN JOB (weekly)"

* Wage per week subsidiary job
/*
gen     oj_r_i =wpesj/4 if wpesj>=0
replace oj_r_i =wpesjm/4 if  wpesjm>=0
*/
label var oj_r_i "Employees: Take-home pay last time SUBSID JOB (weekly)"

*egen empinc_r_s=rowtotal(thp_r_i oj_r_i)
label var thp_r_i "Employees: Take-home pay last time ALL JOBS (weekly)"

/*
* There were some differences... better to use their data
scatter thp_r_i thp_r_iOrig
scatter oj_r_i oj_r_iOrig
scatter empinc_r_s empinc_r_sOrig
*/

gen empinc_main_h=thp_r_i/hours
gen empinc_tot_h =empinc_r_s/hours_aj

label var empinc_main_h "Employees: wage per hour MAIN JOB"
label var empinc_tot_h "Employees: wage per hour ALL JOBS"


* *****************************************************************************************
}
*
///////////////////////////////////////////////////////////////////////////////////////////
// Family Information
///////////////////////////////////////////////////////////////////////////////////////////
if 1==1 {

* *****************************************************************************************
* Parents' death data
* *****************************************************************************************

* father fthagd  dicdnf mother mthagd  dicdnm
gen fathD= father==2
gen mothD= mother==2

tab dicdnf if dicdnf>0, gen(fad_)
tab dicdnm if dicdnm>0, gen(mod_)

forval i=1(1)6 {
	bys  idauniq: egen fath_`i'=max(fad_`i')
	bys  idauniq: egen moth_`i'=max(mod_`i')	

	replace fath_`i'=fath_`i'*fathD
	replace moth_`i'=moth_`i'*mothD
}

label var fath_1 "Father dead by Cancer"
label var fath_2 "Father dead by Hearth Attack"
label var fath_3 "Father dead by Stroke"
label var fath_4 "Father dead by Other Cardio"
label var fath_5 "Father dead by Respirat. Dis"
label var fath_6 "Father dead by Other"

label var moth_1 "Mother dead by Cancer"
label var moth_2 "Mother dead by Hearth Attack"
label var moth_3 "Mother dead by Stroke"
label var moth_4 "Mother dead by Other Cardio"
label var moth_5 "Mother dead by Respirat. Dis"
label var moth_6 "Mother dead by Other"

gen parentDCard= fath_2==1 | fath_3==1 | fath_4==1 | moth_2==1 | moth_3==1 | moth_4==1
label var parentDCard "Any parent dead due to a CVD"

*******************************************************************************************
}
*
///////////////////////////////////////////////////////////////////////////////////////////
// Chapter Specific Variables
///////////////////////////////////////////////////////////////////////////////////////////
if 1==1 {

* ************************************************************************
* RDD Transformations for Chapter 1
* ************************************************************************

tab  bprespc

egen maxsys = rowmax(sys2 sys3)       /* This IS the criteria in the ELSA at leat */
egen maxdias= rowmax(dias2 dias3)

replace maxsys=. if (maxsys<0 | maxsys>200 | maxsys==.) | (maxdias<0 | maxdias>200 | maxdias==.) | bprespc!=1
replace maxdias=. if (maxsys<0 | maxsys>200 | maxsys==.) | (maxdias<0 | maxdias>200 | maxdias==.) | bprespc!=1

* Beautiful graphs
* tw (kdensity maxsys if hibpe==1 , xline(140) xline(160) xline(180) lpattern(dash) lwidth(medthick)) (kdensity maxsys if hibpe==0 , lwidth(medthick)) if sysval>=0 , legend(on order(1 "Diagnosed HBP Before" 2 "Non-Diagnosed HBP Before")) title("Max Systolic Reading mmHg")
* tw (kdensity maxdias if hibpe==1 , xline(85) xline(100) xline(115) lpattern(dash) lwidth(medthick)) (kdensity maxdias if hibpe==0 , lwidth(medthick)) if sysval>=0 & wave==2, legend(on order(1 "Diagnosed HBP Before" 2 "Non-Diagnosed HBP Before")) title("Max Diastolic Reading mmHg")


gen sis1=maxsys if maxsys>0 & maxsys<200 & ( wave==0 | wave==2 | wave==4 | wave==6 | wave==8 | wave==9 )
gen dis1=maxdias if maxdias>0 & maxdias<200 & ( wave==0 | wave==2 | wave==4 | wave==6 | wave==8 | wave==9 )

gen sis2=sis1^2
gen dis2=dis1^2


* Center the results around the cutoff and standarize them
sum sis1
gen sis01=(sis1-140)/r(sd) if wave>1
sum dis1
gen dis01=(dis1-85)/r(sd)  if wave>1

* Wave 0 has different cutoffs:
sum sis1
replace sis01=(sis1-140)/r(sd) if wave<2 & ( masc==0 | (masc==1 & age<=50) )
replace sis01=(sis1-160)/r(sd) if wave<2 &   masc==1 & age>=50 

sum dis1
replace dis01=(dis1-85)/r(sd) if wave<2 & ( masc==0 | (masc==1 & age<=50) )
replace dis01=(dis1-95)/r(sd) if wave<2 &   masc==1 & age>=50 


egen maxM1=rowmax( sis01 dis01)
gen expDis=dis01>=0 if dis01!=.
gen expSis=sis01>=0 if sis01!=.


gen sis02=(sis01^2)/100
gen dis02=(dis01^2)/100
gen maxM2=(maxM1^2)/100
gen sis03=(sis01^3)/100
gen dis03=(dis01^3)/100
gen maxM3=(maxM1^3)/100
gen sis04=(sis01^4)/100
gen dis04=(dis01^4)/100
gen maxM4=(maxM1^4)/100

gen sisdis01=sis01*dis01/100
gen sisdis0102=sis01*dis02/100
gen sisdis0103=sis01*dis03/100
gen sisdis0104=sis01*dis04/100

gen sisdis0201=sis02*dis01/100
gen sisdis02  =sis02*dis02/100
gen sisdis0203=sis02*dis03/100
gen sisdis0204=sis02*dis04/100

gen sisdis0301=sis03*dis01/100
gen sisdis0302=sis03*dis02/100
gen sisdis03  =sis03*dis03/100
gen sisdis0304=sis03*dis04/100

gen sisdis0401=sis04*dis01/100
gen sisdis0402=sis04*dis02/100
gen sisdis0403=sis04*dis03/100
gen sisdis04  =sis04*dis04/100

gen expSissis01=expSis*sis01
gen expSissis02=expSis*sis02/100
gen expDisdis01=expDis*dis01
gen expDisdis02=expDis*dis02/100




label var expDis "Dis Mildly Raised "
label var expSis "Sis Mildly Raised "

gen maxF=floor(maxM1*10)
gen expM=maxM1>=0

label var maxF "Discrete BP measure"
label var expM "Nurse Advice Max BP"

* ************************************************************


sum sis1
gen sis01b=(sis1-160)/r(sd) if wave>1
sum dis1
gen dis01b=(dis1-100)/r(sd) if wave>1

* Wave 0 has different cutoffs:
sum sis1
replace sis01b=(sis1-160)/r(sd) if wave<2 & ( masc==0 | (masc==1 & age<=50) )
replace sis01b=(sis1-170)/r(sd) if wave<2 &   masc==1 & age>=50 

sum dis1
replace dis01b=(dis1-100)/r(sd) if wave<2 & ( masc==0 | (masc==1 & age<=50) )
replace dis01b=(dis1-105)/r(sd) if wave<2 &   masc==1 & age>=50 

gen sis02b=(sis01b^2)/100
gen dis02b=(dis01b^2)/100

gen expDisb=dis01b>=0 if dis01!=.
gen expSisb=sis01b>=0 if sis01!=.

label var expDisb "Dis Moderat. Raised "
label var expSisb "Sis Moderat. Raised "



* ************************************************************************
* 2018.07. RR new variables


drop if wave==. // 1 odd obs!
xtset idauniq wave , delta(1) // Fill the waves, so we can talk about attrition
tsfill, full

gen missing= year==.
label var missing "Missing this wave"


* Move the indep variable one wave up
foreach varDep in sis01 sis02 dis01 dis02 expSis expDis {
	gen X`varDep'=L.`varDep'
	drop `varDep'
	rename X`varDep' `varDep'
}

gen Lhibpe=L.hibpe
gen Ldiab=L.diab
gen Lage=L.age

egen alcoM=rowmax(alco1 alco2)
label var alcoM "Alcohol twice a week or more"
label var dphy1 "Sedentary or low physical activity"
label var bmival "BMI: Body Mass Index (kg/m2)"
label var fat1 "Overweight or above: BMI 25+"
label var fat2 "Obesity level 1 or above: BMI 30+"
label var fat3 "Obesity level 2 or above: BMI 35+"
label var fat4 "Obesity level 3 or above: BMI 40+"

* Did you have a full-interview?
gen interBefo=(L.outind==1 | L.outind==2)
gen interToda=(outind==1 | outind==2)

*********

cap drop smoken2
gen smoken2=smoken
replace smoken2=. if L.smoken==0
label var smoken2 "Current smoker if smoker at $ t$ "

cap drop smokeInt2
gen smokeInt2=smokeInt
replace smokeInt2=0 if smoken==0 & L.smoken==1
label var smokeInt2 "Cigaretes per week (0 for non-smokers) if smoker at $ t$ "

cap drop smokeInt2b
gen smokeInt2b=smokeIntI
replace smokeInt2b=0 if smoken==0 & L.smoken==1
label var smokeInt2b "Cigaretes per week (0 for non-smokers) if smoker at $ t$, include rollups "


label var smokeInt3b "Cigarettes per week (0 for non-smokers, includes roll-ups)"


cap drop smoken2L2
gen smoken2L2=smoken
replace smoken2L2=. if L2.smoken==0
label var smoken2L2 "Current smoker if smoker at $ t$ "

cap drop smokeInt2L2
gen smokeInt2L2=smokeInt
replace smokeInt2L2=0 if smoken==0 & L2.smoken==1
label var smokeInt2L2 "Cigaretes per week (0 for non-smokers) if smoker at $ t$ "


cap drop smokeInt2bL2
gen smokeInt2bL2=smokeIntI
replace smokeInt2bL2=0 if smoken==0 & L2.smoken==1
label var smokeInt2bL2 "Cigaretes per week (0 for non-smokers) if smoker at $ t$, include rollups "


gen anyGeffort=((smoken==0 & L.smoken==1) | (smokeInt3b<L.smokeInt3b) | (alcoM==0 & L.alcoM==1) ) if !missing(bppill,smoken,L.smoken,smokeInt3b,L.smokeInt3b,alcoM,L.alcoM)
label var anyGeffort "Better lifestyle"
gen anyBeffort=((smoken==1 & L.smoken==0) | (smokeInt3b>L.smokeInt3b) | (alcoM==1 & L.alcoM==0)  ) if !missing(bppill,smoken,L.smoken,smokeInt3b,L.smokeInt3b,alcoM,L.alcoM)
label var anyBeffort "Worse lifestyle"

gen aloC=(alcoM==0 & L.alcoM==1) if !missing(alcoM,L.alcoM)
label var aloC "Stop heavy alcohol intake"

gen smoK=(smoken==0 & L.smoken==1) if !missing(smoken,L.smoken)
label var smoK "Stop smoking"

********************************************************************************
* New version of the strategy

drop sis01 sis02 dis01 dis02 maxM1 expSis expDis

* Center the results around the cutoff and standarize them

gen sis01=(sis1-140) if wave>1
gen dis01=(dis1-85)  if wave>1
egen maxM1=rowmax( sis01 dis01)


* Wave 0 has different cutoffs:
replace sis01=(sis1-140) if wave<2 & ( masc==0 | (masc==1 & age<=50) )
replace sis01=(sis1-160) if wave<2 &   masc==1 & age>=50 

replace dis01=(dis1-85) if wave<2 & ( masc==0 | (masc==1 & age<=50) )
replace dis01=(dis1-95) if wave<2 &   masc==1 & age>=50 

gen sis02=sis01^2
gen expSis=sis01>=0 if sis01!=.
gen dis02=dis01^2
gen expDis=dis01>=0 if dis01!=.

* Move the indep variable one wave up
foreach varDep in sis01 sis02 dis01 dis02 maxM1 expSis dis02 {
	gen X`varDep'=L.`varDep'
	drop `varDep'
	rename X`varDep' `varDep'
}


*rd smoken hibpe   sis01  , z0(0) mbw(100)
*rd bppills hibpe sis01 , z0(0) mbw(100)

label var heartMa "Diagnosed Heart Condition"



* ************************************************************************
* PCT Merge for Chapter 2
* ************************************************************************


*******************************************************************
* PCT Information: I want all of them to be in 2006-2012 coding
* Scotland is not taken into account: S03000005  S03000007  S03000013  S03000025 S03000035
* Wales is not taken into account: W11000023 W11000025 W11000026 W11000028, 6A1-6B7
* I have not idea what these codes mean: 004 007 013 025 035
* Have a look to this: http://www.ons.gov.uk/ons/guide-method/geography/beginner-s-guide/health/english-health-geography/index.html

* IMPORTANT: I assumed that they didn't move in Wave 6 or 7

* Step 1: 2005 pct's came from an different code (ONS version)
gen PCTONS=pct
merge n:1  PCTONS using "$waitfolder\Maps\ONS PCT code\PCTids2.dta", gen(pctIdmatch) keepusing(codePCT_str)
tab pctIdmatch wave // 2010 pct issues are: Scotland and wales
replace pct=codePCT_str if pctIdmatch==3
drop pctIdmatch PCTONS codePCT_str

* Step 2: 2002, 2004 codes are translated into the "merged" version of post-2006

gen pct303code= pct if year<2006
rename pct pct_orig
label var pct_orig "PCT Original (without mergers)"
merge n:1 pct303code using "$waitfolder\Maps\ONS PCT code\PCT2006_303to152.dta" , gen(pctIdmatch)  /* Get PCT standarized id */
tab pctIdmatch year // Good, 2002 and 2004 match properly
replace pct303code="" if wave>2 //1 change? It should be 0
replace pct303name="" if wave>2 //1 change? It should be 0

replace pct152code= pct_orig if year>=2006
*replace pct152name= PCTname if year>=2006
* *********************************************************
rename pct152code pct_code
do "$mainPCT\generalDos\ALL_00_PCTmergers2006to2011.do"
rename pct_code pct

tab pct wave, mi

* *****************************************************************************************
}
///////////////////////////////////////////////////////////////////////////////////////////



* ****************************************************************************
* ***** PROCESS DATA FOR ESTIMATIONS ***************************************** 
* ****************************************************************************

xtset idauniq wave




xtset idauniq wave
cd "$dropbox\Elsa"

saveold ELSA_NatCen_2017PROC.dta, replace
	
	
	
