version 13
* ***********************************************
* * NatCen DATA: put together all the relevant info
* * from all ELSA waves
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
clear all
set maxvar 10000

cd "$diri\stata13_se\"

glo basic ///
	intdatm intdaty iintdatm iintdaty // Dates	

* SR Diagnosis of conditions ***************************************************
glo hbpW0    ///
	bp1 diabete2 strodef angidef heartdef iregdef murmur1 ohtdef
glo hbpW456  ///
	hedacch hedimch /// // Cholesterol
	hedacbp hedimbp /// // HBP
	hedacst hedimst /// // Stroke			
			hedimmi /// // Myocardial infarction
			hedimhf /// // Heart Failure
	        hediman /// // Angina			
			hedimhm /// // Heart Murmur
			hedimar /// // Arrhythmia
	                /// // Diabetes or high blood sugar
	hedacdi hedimdi /// // Diabetes
	hedbdlu hediblu /// // Lung
	hedbdas hedibas /// // Asthma
	hedbsar hedibar /// // Arthritis 
	hedbsca hedibca ///   // Cancer
	heag*		  // When

* Dervied vars (when diagnosis of)	
* !!! In waves 1 2 3 is hedimbp recoded ("hedimbp" in waves 4 and 5 is completely different!)
glo hbpW12345 ///
	hediagbp  /// // HBP. 
	hediagst  /// // Stroke
	hediagmi  /// // Myocardial infarction
	hediaghf  /// // Heart failure
	hediagan  /// // Angina	
	hediaghm  /// // Heart Murmur
	hediagar  /// // Arrhythmia
	hediagdh  /// // diabetes or high blood sugar
	hediagdi  /// // Diabetes
	hebdialu  /// // Lung	
	hebdiaas  /// // Asthma
	hebdiaar  /// // Arthritis
	hebdiaca  /// // Cancer	
	heag*		  // When
	
glo hbpW345	 ///
	hediaghc /// // Cholesterol
	
glo biomarkw246 ///
	chol hdl ldl  fglu 					///  // CVD related
	htval wtval wstval  bmival bmiok    ///  // Height and Obesity, Hip was not measures in Wve 6? (whval)
	htfvc htfev 						///  // Lung function; htpf not is wave 6?
	mmgsd1 mmgsd2 mmgsd3     				 // Grip-strength	

glo biomarkw8 ///
	chol hdl ldl  fglu 					///  // CVD related
	wtval								///  // Only weight
	mmgsd1 mmgsd2 mmgsd3     				 // Grip-strength	
	
* Expectations ****************************************************************	
glo expW12345 ///
	expw exwork55 exwork60 exwork65 /// // Work expectations
	exlo80 exhlim exrslf // Survival and health expectations
	
glo expW2345 ///	
	expwf // Work expectations 2
	
glo expW345 ///
	exlo90 // Survival expectations till age 85
	
glo healthVars ///	
	llsill hlimwrk hlimwrkc // Derived IFS disability status
	
glo disW56 ///	
	iahdb

glo disW1234 ///	
	iahdb
	
* House and Family *************************************************************
glo house ///
	hotenu famtype idauniq_p srh3_hrs_p srh3_hse_p
	
glo pensions ///
	pp_cont pp_occdb pp_occdc pp_per	
	
glo consumption ///
	rpi- mortinc85	
	
* Demand of Health Care ********************************************************

glo demandHCw0 ///
	whendoc   /// // When last talked to doctor about self

glo demandHCw6 ///
	hegpoft /// // GP:whether talked to GP during previous 4 weeks
	hegpnhs     // GP:whether consultation NHS or private


* Mental and physical function *************************************************		
glo functionIndex ///
	memtotb	execnn nright  // Cognitive	(not in wave 6)
	*gtspd_mn				  // Gait wlaking speed (not in wave 6?)
	
* Job details ******************************************************************
glo jobdetails ///
	wpjact wpaskd wpjobl wpjob wpjact wpsjoby wpcjob ///
	sic2003

glo jobdetails2 ///
	wpjact wpaskd wpjobl wpjob wpjact wpsjoby wpcjob ///	
	sic sic92 sic92mis
	
glo jobdetails3 ///
	wpjact wpaskd wpjobl wpjob wpjact wpsjoby wpcjob

////////////////////////////////////////////////////////////////////////////////
// Wave 0 (HSE) ////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
if 1==1 {

use wave_0_1998_data, clear
append using wave_0_1999_data
append using wave_0_2001_data


* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* Add the extra BP file that I got from the NatCen
* whatever is not matching, is the refreshment sample
merge 1:1 idauniq hseyr using "$dropbox\ELSA\NatCenFiles\BPfile.dta" , gen(refresh_merge)
gen refresh=refresh_merge==2
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*	We have BP information but not self-reported diagnosis
*   of it, which makes it impossible to use this data
*   Aprt from that, there is BIG issues
*   using HSE 2002,2003, 2004 and 2006: 
*   1. The Systolic BP distribution changes as the records
*      are obtained using a different machine (Dinampa -> Omron). 
*      Essentially less people is to right of the distribution
*         tw (kdensity sysval if sysval <200) (kdensity  omsysval if omsysval <200), xline(140)
*         tw (kdensity diaval if diaval <200) (kdensity  omdiaval if  omdiaval <200), xline(85)
*      Notice that the Omron machine is the same used in the ELSA
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* Let's introduce HSE 2003, 2004 and 2006 refresehment values
* They use the same machine as ELSA; the machine that is different
* is the one from Wave 0 (HSE 98, 99, 01)
replace sys2=sys2om
replace sys3=sys3om
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

merge 1:1 idauniq hseyr using wave_0_common_variables_v2, nogen
merge 1:1 idauniq hseyr using "$dropbox\ELSA\NatCenFiles\BPfile.dta", update

gen wave0data=1

rename hseyr year

gen wave=0
* For the refreshment sample I need to assign this data to the
* closest wave. Typically the collection process is a year, and 
* start at mid one.
replace wave=1 if year==2002 | year==2003
replace wave=2 if year==2004
replace wave=3 if year==2006

rename topqual2 edqual 

gen rabyear = dobyear
gen r_agey  = ager
gen ragender= sex
* Household Head Social Class: schoh

* r_mrct ... more complex

*gen r_momliv=livemab==1 if livemab>0 & livemab!=.
*gen r_dadliv=livepab==1 if livepab>0 & livepab!=.
*gen r_momage= (r_momliv==1)*agema+(r_momliv==0)*agemab
*gen r_dadage= (r_momliv==1)*agepa+(r_momliv==0)*agepab
*Casuses of death: consmab conspab
gen r_shlt=genhelf  /* very good, good, fair, bad, very bad */
* gen r_hlthlm=helwk
/*
gen r_vgactx_e = heacta
gen r_mdactx_e = heactb
gen r_ltactx_e = heactc
*/

* In the HSE the question is done in depth (dnnow, dnany). We 
* stick to the last 12 months definition
gen r_drink = dnoft==8 | dnoft==-1 if dnoft!=. & dnoft!=-1

gen r_drinkd_e=	d7many2 /* # days/week drinks */
gen r4drinkwn_e=drating /* # drinks/week: Here is alcoholic units per week */
gen r_drinkn_e=d7unit /* R # drinks/day (HSE: Heaviest)*/

* Info on income... how similar is it to RAND's calculations?
gen r_iearn=srcinc01
gen h_iftot=totinc
* r_wgihr_e s_iearn /* Need to work more to get spouse's info */

gen r_work=econact==1 if econact>0 & econact!=.
* r_work2: more complex
* Status: r_lbrf_e econact
* Status: s_lbrf_e
	
gen r_smokev=smkevr==1 if smkevr>0
gen r_smoken=cignow==1 if cignow>0
* startsmk : age started to smoke	
* smkdad   : Whether father smoked when informant a child
* smkmum   : Whether mother smoked when informant a child
* expsm    : Exposure to others' smoking (hours)	
	
gen heskb=cigwday
gen heskc=cigwend
 
* Past smokers information:
/*
numsmok   How many cigarettes used to smoke
smokyrs   Number of years smoked
endsmoke  Years since stopped smoking
longend   How many months since quit smoking (if less than one year)
nicot     Nicotine products used
smoketry  Tried to stop smoking due to health condition
drsmoke	  Medical practitioner advised to give up smoking
drsmoke1  Time since advised to give up smoking
*/

* Not so deep info on tobacco: hetbc hetbd

	
* famcvd: (D) Family history of CVD

* Nurse info: sys1 sys2 sys3 dias1 dias2 dias3 diaval sysval
* Important. After 2003 the HSE changed the monitor
replace sys1=sys1om if year>=2003
replace sys2=sys2om if year>=2003
replace sys3=sys3om if year>=2003
replace dias1=dias1om if year>=2003
replace dias2=dias2om if year>=2003
replace dias3=dias3om if year>=2003

rename cholval chol
rename hdlval hdl
rename fldlval ldl
* GP utilization: whendoc ngp ngpg4 ngpyr gptalk gpvis


*keep idauniq wave year schoh rabyear r_agey ragender racem r_mstath h_iftot r_smokev r_smoken heskb heskc  r_hibpe r_diabe r_stroke r_hearte sys1 sys2 sys3 dias1 dias2 dias3 diaval sysval bmi    numsmok smokyrs endsmoke longend nicot smoketry drsmoke drsmoke1 bpmeas measlast levelbp whendoc ngp ngpg4 ngpyr gptalk gpvis startsmk smkdad smkmum expsm consmab conspab
keep idauniq wave wave0data year edqual rabyear r_agey ragender ethnicr marital h_iftot ///
     r_smokev r_smoken heskb heskc /// //  r_hibpe r_diab r_strok r_heart ///
	 dnoft dnoft2 ///
	 $hbpW0 $demandHCw0 ///
	 sys1 sys2 sys3 dias1 dias2 dias3 diaval sysval bpconst bprespc ///
     cigdyal cigst1 cigst2 actlevel bmival dnoft2  genhelf refresh  chol hdl ldl bpmedc bpmedd 

*/

tempfile tempo
save `tempo', replace
}

////////////////////////////////////////////////////////////////////////////////
// Wave 9 (2018/19) 
////////////////////////////////////////////////////////////////////////////////
if 1==1 {

use elsa_nurse_w8w9_data_eul , clear
keep if wave==9
tempfile fio1
save `fio1'

use "wave_9_elsa_data_eul_v1", clear
rename *, lower 
merge 1:1 idauniq using `fio1' , nogen 
merge 1:1 idauniq using wave_9_financial_derived_variables , nogen 
merge 1:1 idauniq using wave_9_ifs_derived_variables , nogen 
*merge 1:1 idauniq using elsa_endoflife_w6archive , gen(death) // <<<<<< Not yet available
// I have to assume that they didn't move... by wave 7 this is kind of a bad assumption
	merge 1:1 idauniq using "$dropbox\ELSA\NatCenFiles\PCT\ID2 Paul Lesmes wave5 PCT.dta", gen(pct_merge) keep(master match)

cap drop wave
gen wave=9
gen year=2018

*	foreach x of varlist scveg scfru {
*		replace `x'=. if `x'<0
*	}

// It seems it is not there!
*htval // Height in cm
rename weight wtval // Weight in cm
*wstval // Mean waist in cm
*bmival 
*bmiok // 1 if ok both measures

replace age=. if age==99 // Censoring issue
replace indobyr=. if indobyr==-7
* From the derived dataset	
*edqual	palevel father fthagd mother mthagd totinc_bu_s savings_bu_s invests_bu_s debt_bu_s nettotw_bu_s wpactive hours_aj

rename w9xwgt xwgt // Rename the cross-sectional weight


keep wave year idauniq wave indager indobyr refreshtype dimar  hepain /// //fqethnr
	 samptyp  w9indout  xwgt w9scwt  /// // Sample and weight   w9lwgt
	 $expW12345 $expW2345 $expW345 ///
	 $house $pensions $healthVars $disW56 $consumption $jobdetails4 /// 
	 sys1 sys2 sys3 dias1 dias2 dias3 diaval sysval  bpconst bprespc $biomarkw8 $functionIndex ///
	 hedacch hedimch hechmd hechme /// // Cholesterol ... not present hechol hechola 
	 $basic  $hbpW456 $demandHCw6 /// // BP
	 hesmk heska heskd heske heskf hestop hecig heskb hetba hetbb heskc hetbc hetbd  hemda hemdab   heacta heactb heactc wpjact   hehelf heill helim helwk hefunc /// // scako   scveg scfru scrtage
	 dicdnf dicdnm  ///
	 wpactw wpmoj wphmsj wphwrk wphjob wpdes ///      // Work status
	 wpperi wpthp wpes wpesj wpesjm			///	// Wages and salary for employees
	 wpphi wphowu wphowe wpmhi wpmhil wpmhiu wpmhie wpmhir /// // Health Insurance
	 coupid- totwq10_bu_f intdatm-mortinc85 /// // Keep all the financial variables
	 chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 /// // children age
	pct pct_merge gor
	

append using `tempo' , force
save `tempo', replace
}

////////////////////////////////////////////////////////////////////////////////
// Wave 8 (2016/17) ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
if 1==1 {
use "wave_8_elsa_data_eul_v2", clear
merge 1:1 idauniq using wave_8_elsa_nurse_data_eul_v1 , nogen 
rename *, lower 
merge 1:1 idauniq using wave_8_elsa_financial_dvs_eul_v1 , nogen 
merge 1:1 idauniq using wave_8_elsa_ifs_dvs_eul_v1 , nogen 
// merge 1:1 idauniq using elsa_endoflife_w6archive , gen(death) // <<<<<<<<<<<<<<<<<<<<<<< No derived vars in ELSA 
// I have to assume that they didn't move
	merge 1:1 idauniq using "$dropbox\ELSA\NatCenFiles\PCT\ID2 Paul Lesmes wave5 PCT.dta", gen(pct_merge) keep(master match)

cap drop wave
gen wave=8
gen year=2016

foreach x of varlist scveg scfru {
	replace `x'=. if `x'<0
}

replace weight=. if weight<35

// It seems it is not there!
*htval // Height in cm
rename weight wtval // Weight in cm
*wstval // Mean waist in cm
*bmival 
*bmiok // 1 if ok both measures

replace age=. if age==99 // Censoring issue
replace indobyr=. if indobyr==-7
* From the derived dataset	
*edqual	palevel father fthagd mother mthagd totinc_bu_s savings_bu_s invests_bu_s debt_bu_s nettotw_bu_s wpactive hours_aj

/*
drop finstat // Only data for which there is nurse data
rename finstatw8 finstatX
decode finstatX, gen(finstat)
drop finstatX
*/

rename w8xwgt xwgt // Rename the cross-sectional weight

keep wave year idauniq wave indager indobyr refreshtype dimar hepain /// // fqethnr
	 samptyp finstat w8indout  xwgt w8scwt w8sscwt /// // Sample and weight w8lwgt
	 $expW12345 $expW2345 $expW345 ///
	 $house $pensions $healthVars $disW56 $consumption $jobdetails4 ///
	 sys1 sys2 sys3 dias1 dias2 dias3 diaval sysval  bpconst bprespc $biomarkw8 $functionIndex ///
     hechol  hedacch hedimch hechmd hechme /// // Cholesterol  hechola
	 $basic  $hbpW456 $demandHCw6 /// // BP
	 hesmk heska heskd heske heskf hestop hecig heskb hetba hetbb heskc hetbc hetbd  hemda hemdab   heacta heactb heactc wpjact scako   scveg scfru scrtage hehelf heill helim helwk hefunc ///
	 dicdnf dicdnm  ///
	 wpactw wpmoj wphmsj wphwrk wphjob wpdes ///      // Work status
	 wpperi wpthp wpes wpesj wpesjm			///	// Wages and salary for employees
	 wpphi wphowu wphowe wpmhi wpmhil wpmhiu wpmhie wpmhir /// // Health Insurance
	 coupid- totwq10_bu_f intdatm-mortinc85 /// // Keep all the financial variables
	 chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 /// // children age
	pct pct_merge gor
	

append using `tempo' , force
save `tempo', replace
}




////////////////////////////////////////////////////////////////////////////////
// Wave 7 (2014/15) --- NO MORTALITY DATA SINCE THEN ///////////////////////////
////////////////////////////////////////////////////////////////////////////////
if 1==1 {
use "wave_7_elsa_data", clear
rename *, lower 
merge 1:1 idauniq using wave_7_financial_derived_variables , nogen 
merge 1:1 idauniq using wave_7_ifs_derived_variables , nogen 
*merge 1:1 idauniq using elsa_endoflife_w6archive , gen(death) // <<<<<< Not yet available
// I have to assume that they didn't move... by wave 7 this is kind of a bad assumption
	merge 1:1 idauniq using "$dropbox\ELSA\NatCenFiles\PCT\ID2 Paul Lesmes wave5 PCT.dta", gen(pct_merge) keep(master match)

cap drop wave
gen wave=7
gen year=2014

	foreach x of varlist scveg scfru {
		replace `x'=. if `x'<0
	}

replace age=. if age==99 // Censoring issue
replace indobyr=. if indobyr==-7
* From the derived dataset	
*edqual	palevel father fthagd mother mthagd totinc_bu_s savings_bu_s invests_bu_s debt_bu_s nettotw_bu_s wpactive hours_aj

rename w7xwgt xwgt // Rename the cross-sectional weight


keep wave year idauniq wave indager indobyr refreshtype dimar fqethnr hepain ///
	 samptyp  w7indout w7lwgt xwgt w7scwt  /// // Sample and weight
	 $expW12345 $expW2345 $expW345 ///
	 $house $pensions $healthVars $disW56 $consumption $jobdetails /// //     
	 hedacch hedimch hechmd hechme /// // Cholesterol ... not present hechol hechola 
	 $basic  $hbpW456 $demandHCw6 /// // BP
	 hesmk heska heskd heske heskf hestop hecig heskb hetba hetbb heskc hetbc hetbd  hemda hemdab   heacta heactb heactc wpjact scako   scveg scfru scrtage hehelf heill helim helwk hefunc ///
	 dicdnf dicdnm  ///
	 wpactw wpmoj wphmsj wphwrk wphjob wpdes ///      // Work status
	 wpperi wpthp wpes wpesj wpesjm			///	// Wages and salary for employees
	 wpphi wphowu wphowe wpmhi wpmhil wpmhiu wpmhie wpmhir /// // Health Insurance
	 coupid- totwq10_bu_f intdatm-mortinc85 /// // Keep all the financial variables
	 chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 /// // children age
	pct pct_merge gor
	

append using `tempo' , force
save `tempo', replace
}


////////////////////////////////////////////////////////////////////////////////
// Wave 6 (2012/13) ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
if 1==1 {
use "wave_6_elsa_data_v2", clear
merge 1:1 idauniq using wave_6_elsa_nurse_data_v2 , nogen 
rename *, lower 
merge 1:1 idauniq using wave_6_financial_derived_variables , nogen 
merge 1:1 idauniq using wave_6_ifs_derived_variables , nogen 
merge 1:1 idauniq using elsa_endoflife_w6archive , gen(death) // <<<<<<<<<<<<<<<<<<<<<<< No derived vars in ELSA 
// I have to assume that they didn't move
	merge 1:1 idauniq using "$dropbox\ELSA\NatCenFiles\PCT\ID2 Paul Lesmes wave5 PCT.dta", gen(pct_merge) keep(master match)

cap drop wave
gen wave=6
gen year=2012

	foreach x of varlist scveg scfru {
		replace `x'=. if `x'<0
	}

replace age=. if age==99 // Censoring issue
replace indobyr=. if indobyr==-7
* From the derived dataset	
*edqual	palevel father fthagd mother mthagd totinc_bu_s savings_bu_s invests_bu_s debt_bu_s nettotw_bu_s wpactive hours_aj

drop finstat // Only data for which there is nurse data
rename finstatw6 finstatX
decode finstatX, gen(finstat)
drop finstatX

rename w6xwgt xwgt // Rename the cross-sectional weight

gen bprespc=1 if sysval!=. & sysval>0 // This derived var is not present here

keep wave year idauniq wave indager indobyr refreshtype dimar fqethnr hepain ///
	 samptyp finstat w6indout w6lwgt xwgt w6scwt w6sscwt /// // Sample and weight
	 $expW12345 $expW2345 $expW345 ///
	 $house $pensions $healthVars $disW56 $consumption $jobdetails ///
	 sys1 sys2 sys3 dias1 dias2 dias3 diaval sysval  bpconst bprespc $biomarkw246 $functionIndex ///
     hechol hechola hedacch hedimch hechmd hechme /// // Cholesterol
	 $basic  $hbpW456 $demandHCw6 /// // BP
	 hesmk heska heskd heske heskf hestop hecig heskb hetba hetbb heskc hetbc hetbd  hemda hemdab   heacta heactb heactc wpjact scako   scveg scfru scrtage hehelf heill helim helwk hefunc ///
	 dicdnf dicdnm  ///
	 wpactw wpmoj wphmsj wphwrk wphjob wpdes ///      // Work status
	 wpperi wpthp wpes wpesj wpesjm			///	// Wages and salary for employees
	 wpphi wphowu wphowe wpmhi wpmhil wpmhiu wpmhie wpmhir /// // Health Insurance
	 coupid- totwq10_bu_f intdatm-mortinc85 /// // Keep all the financial variables
	 chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 /// // children age
	pct pct_merge gor
	

append using `tempo' , force
save `tempo', replace
}

////////////////////////////////////////////////////////////////////////////////
// Wave 5 (2010/11) ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
if 1==1 {
use "wave_5_elsa_data_v4", clear

gen wave=5
gen year=2010
rename *, lower 

merge 1:1 idauniq using wave_5_financial_derived_variables , nogen 
merge 1:1 idauniq using wave_5_ifs_derived_variables , nogen 
merge 1:1 idauniq using "$dropbox\ELSA\NatCenFiles\PCT\ID2 Paul Lesmes wave5 PCT.dta", gen(pct_merge)  keep(master match)

	foreach x of varlist scveg scfru {
		replace `x'=. if `x'<0
	}

replace age=. if age==99 // Censoring issue
recode indobyr (-7 -1 =.)

rename finstatw5 finstat
rename w5xwgt xwgt

keep wave year indobyr idauniq wave indager refreshtype dimar fqethnr edqual hepain ///
	 samptyp finstat w5indout w5lwgt xwgt w5scwt /// // Sample and weight
     $basic  $expW12345 $expW2345 $expW345 ///
	 $house $pensions $healthVars $disW56 $consumption $jobdetails ///
	palevel $functionIndex  ///
    hesmk heska heskd heske heskf hestop hecig heskb hetba hetbb heskc hetbc hetbd  hemda hemdab   heacta heactb heactc wpjact scako   scveg scfru scrtage hehelf heill helim helwk hefunc ///
	father fthagd  dicdnf mother mthagd  dicdnm ///
	totinc_bu_s savings_bu_s invests_bu_s debt_bu_s nettotw_bu_s ///
    hechol hechola hedacch hedimch  hechmd hechme /// // Cholesterol
	$hbpW12345 $hbpW456 $hbpW345  /// // BP
	wpactive hours_aj  ///
	 wpactw wpmoj wphmsj wphwrk wphjob wpdes ///      // Work status
	 wpperi wpthp wpes wpesj wpesjm	///			// Wages and salary for employees
	 wpphi wphowu wphowe wpmhi wpmhil wpmhiu wpmhie wpmhir /// // Health Insurance	
	 coupid- totwq10_bu_f intdatm-mortinc85 /// // Keep all the financial variables	 
	 chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 /// // children age	 
	pct pct_merge gor

append using `tempo' , force
save `tempo', replace
}

////////////////////////////////////////////////////////////////////////////////
// Wave 4 (2008/09) ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
if 1==1 {
use "wave_4_elsa_data_v3" , clear

gen wave=4
gen year=2008

merge 1:1 idauniq using Wave_4_Nurse_Data , nogen 
merge 1:1 idauniq using wave_4_financial_derived_variables , nogen 
merge 1:1 idauniq using wave_4_ifs_derived_variables , nogen 
merge 1:1 idauniq using "$dropbox\ELSA\NatCenFiles\PCT\ID2 Paul Lesmes wave4 PCT.dta", gen(pct_merge)  keep(master match)

replace age=. if age==99 // Censoring issue
recode indobyr (-7 -1 =.)

	foreach x of varlist scvega scvegb scvegc scvegd scfruia scfruib scfruic scfruid scfruie scfruif scfruig scfruih scfruii {
		replace `x'=. if `x'<0
	}
	
	egen scveg=rowtotal(scvega scvegb scvegc scvegd) , missing
	egen scfru=rowtotal(scfruia scfruib scfruic scfruid scfruie scfruif scfruig scfruih scfruii) , missing

	rename (_all), lower
	
	rename finstat4 finstat
	rename w4xwgt xwgt
 	
	
keep wave year idauniq wave indager refreshtype dimar fqethnr  edqual hepain ///
	 samptyp finstat outindw4 w4lwgt xwgt w4scwt /// // Sample and weight
	 $basic $expW12345 $expW2345 $expW345 ///
	 $house $pensions $healthVars $disW1234 $consumption $jobdetails ///
	 sys1 sys2 sys3 dias1 dias2 dias3 diaval sysval  bpconst bprespc  ///
	 palevel hehelf heill helim helwk hefunc $functionIndex  ///
	 hesmk heska heskd heske heskf hestop hecig heskb hetba hetbb heskc hetbc hetbd  hemda hemdab   heacta heactb heactc wpjact scako scveg scfru scrtage ///
	 father fthagd  dicdnf mother mthagd  dicdnm $biomarkw246 ///
	 totinc_bu_s savings_bu_s invests_bu_s debt_bu_s nettotw_bu_s ///
	wpactive thp_r_i oj_r_i empinc_r_s hours_aj  ///
     hedacch hedimch hechmd hechme /// // Cholesterol
	 $hbpW12345 $hbpW456 $hbpW345 /// // BP
	 wpactw wpmoj wphmsj wphwrk wphjob wpdes ///      // Work status
	 wpperi wpthp wpes wpesj wpesjm	///			// Wages and salary for employees
	 wpphi wphowu wphowe wpmhi wpmhil wpmhiu wpmhie wpmhir /// // Health Insurance	 
	 coupid- totwq10_bu_f intdatm-mortinc85  /// // Keep all the financial variables
	 chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 /// // children age	 
	pct pct_merge gor
	
	
	
append using `tempo' , force
save `tempo', replace
}
////////////////////////////////////////////////////////////////////////////////
// Wave 3 (2006/07) ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
if 1==1 {
use "wave_3_elsa_data_v4" , clear

gen wave=3
gen year=2006

	rename (_all), lower

merge 1:1 idauniq using wave_3_financial_derived_variables , nogen 
merge 1:1 idauniq using wave_3_ifs_derived_variables , nogen 
merge 1:1 idauniq using "$dropbox\ELSA\NatCenFiles\PCT\ID2 Paul Lesmes wave3 PCT.dta", gen(pct_merge)  keep(master match)

replace age=. if age==99 // Censoring issue
recode indobyr (-8 -7 = .)

* This question is more like this...
* IMPORTANT: THE MEANING OF hedimbp CHANGE IN WAVES 4 AND 5
rename hedimbp hediagbp
rename hediman hediagan
rename hedimmi hediagmi
rename hedimhf hediaghf
rename hedimhm hediaghm
rename hedimar hediagar
rename hedimdi hediagdh
rename hedbts hediagdi
rename hedimst hediagst
rename hedimch hediaghc
rename hediblu hebdialu
rename hedibas hebdiaas
rename hedibar hebdiaar
rename hedibos hebdiaos
rename hedibca hebdiaca


replace hediagbp=0 if hediagbp==-3
replace hediagan=0 if hediagan==-3
replace hediagmi=0 if hediagmi==-3
replace hediaghf=0 if hediaghf==-3
replace hediaghm=0 if hediaghm==-3
replace hediagar=0 if hediagar==-3
replace hediagdh=0 if hediagdh==-3
replace hediagdi=0 if hediagdi==-3
replace hediagst=0 if hediagst==-3
replace hediaghc=0 if hediaghc==-3
replace hebdialu=0 if hebdialu==-3
replace hebdiaas=0 if hebdiaas==-3
replace hebdiaar=0 if hebdiaar==-3
replace hebdiaos=0 if hebdiaos==-3
replace hebdiaca=0 if hebdiaca==-3


rename w3sic 		sic
rename w3sic92 		sic92
rename w3sic92mis	sic92mis

	foreach x of varlist scvega scvegb scvegc scvegd scfruia scfruib scfruic scfruid scfruie scfruif scfruig scfruih scfruii {
		replace `x'=. if `x'<0
	}
	egen scveg=rowtotal(scvega scvegb scvegc scvegd) , missing
	egen scfru=rowtotal(scfruia scfruib scfruic scfruid scfruie scfruif scfruig scfruih scfruii) , missing

	rename w3xwgt xwgt
	
keep wave year idauniq wave indager refreshtype dimar fqethnr edqual hepain ///
	 sampsta finstat w3lwgt xwgt /// // Sample and weight
	 $basic $expW12345 $expW2345 $expW345 ///
	 $house $pensions $healthVars $disW1234 $consumption $jobdetails2 ///
	palevel $functionIndex ///
   hesmk heska heskd heske heskf hestop hecig heskb hetba hetbb heskc hetbc hetbd  hemda hemdab   heacta heactb heactc wpjact scako  scveg scfru    scrtage hegenh helim heill helwk hefunc ///
   father fthagd  dicdnf mother mthagd  dicdnm ///
   totinc_bu_s savings_bu_s invests_bu_s debt_bu_s nettotw_bu_s ///
	wpactive thp_r_i oj_r_i empinc_r_s hours_aj  ///
     hechmd hechme /// // Pills	
	 $hbpW12345 $hbpW345 ///
	 wpactw wpmoj wphmsj wphwrk wphjob wpdes ///      // Work status
	 wpperi wpthp wpes wpesj wpesjm	///			// Wages and salary for employees
	 coupid- totwq10_bu_f intdatm-mortinc85  /// // Keep all the financial variables	
	 chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 /// // children age	 
	pct pct_merge gor

	
append using `tempo' , force
save `tempo', replace
}


////////////////////////////////////////////////////////////////////////////////
// Wave 2 (2004/05) ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
if 1==1 {
use wave_2_core_data_v4, clear
gen wave=2
gen year=2004


merge 1:1 idauniq using Wave_2_Nurse_Data_v2 , nogen 
merge 1:1 idauniq using wave_2_derived_variables , nogen keep(match master)  
merge 1:1 idauniq using wave_2_financial_derived_variables , nogen 
merge 1:1 idauniq using wave_2_ifs_derived_variables , nogen 
merge 1:1 idauniq using "$dropbox\ELSA\NatCenFiles\PCT\ID2 Paul Lesmes wave2 PCT.dta", gen(pct_merge)  keep(master match)
drop persno

replace age=. if age==99 // Censoring issue
recode indobyr (-7 =.)

rename *, lower

* This question is more like this...
* IMPORTANT: THE MEANING OF hedimbp CHANGE IN WAVES 4 AND 5
rename hedimbp hediagbp
rename hediman hediagan
rename hedimmi hediagmi
rename hedimhf hediaghf
rename hedimhm hediaghm
rename hedimar hediagar
rename hedimdi hediagdh
rename hedbts hediagdi
rename hedimst hediagst
*rename hedimch hediaghc
rename hediblu hebdialu
rename hedibas hebdiaas
rename hedibar hebdiaar
rename hedibos hebdiaos
rename hedibca hebdiaca

replace hediagbp=0 if hediagbp==-2
replace hediagan=0 if hediagan==-2
replace hediagmi=0 if hediagmi==-2
replace hediaghf=0 if hediaghf==-2
replace hediaghm=0 if hediaghm==-2
replace hediagar=0 if hediagar==-2
replace hediagdh=0 if hediagdh==-2
replace hediagdi=0 if hediagdi==-2
replace hediagst=0 if hediagst==-2
*replace hediaghc=0 if hediaghc==-2
replace hebdialu=0 if hebdialu==-2
replace hebdiaas=0 if hebdiaas==-2
replace hebdiaar=0 if hebdiaar==-2
replace hebdiaos=0 if hebdiaos==-2
replace hebdiaca=0 if hebdiaca==-2

* Only in this wave there is such problem
replace hesmk=bhesmk if hesmk<1

rename w2sic 		sic
rename w2sic92 		sic92
rename w2sic92mis	sic92mis

	
foreach varDep in hedia01 hedia02 hedia03 hedia04 hedia05 hedia06 hedia07 hedia08 hedia09 {
	replace `varDep'=. if `varDep'<0
}
egen missi=rowmiss(hedia01 hedia02 hedia03 hedia04 hedia05 hedia06 hedia07 hedia08 hedia09)

gen choleW2=0 if missi<9 & missi!=.
foreach varDep in hedia01 hedia02 hedia03 hedia04 hedia05 hedia06 hedia07 hedia08 hedia09 {
	replace choleW2=1 if `varDep'==9
}	
	
	rename w2wgt xwgt
	
keep wave year idauniq wave indobyr indager refreshtype dimar fqethnr edqual hepain ///
	sampsta finstat xwgt scw2wgt /// // Sample and weight
	 $basic $expW12345 $expW2345 ///
	 $house $pensions $healthVars $disW1234 $consumption $jobdetails2 ///
	 sys1 sys2 sys3 dias1 dias2 dias3 diaval sysval bpconst bprespc   ///
	 palevel  hehelf heill helwk helim  hetemp hefunc $functionIndex ///
	 hesmk heska heskd heske heskf hestop hecig heskb hetba hetbb heskc hetbc hetbd hemda    heacta heactb heactc wpjact bmival scako scrtage ///
	 father fthagd  dicdnf mother mthagd  dicdnm  $biomarkw246 choleW2 ///
	 totinc_bu_s savings_bu_s invests_bu_s debt_bu_s nettotw_bu_s ///
	wpactive hours_aj  ///
	$hbpW12345 ///
	 wpactw wpmoj wphmsj wphwrk wphjob wpdes ///      // Work status
	 wpperi wpthp wpes wpesj wpesjm	///			// Wages and salary for employees
 	 wpphi wphowu wphowe wpmhi wpmhil wpmhiu wpmhie wpmhir /// // Health Insurance	 
	 coupid- totwq10_bu_f intdatm-mortinc85  /// // Keep all the financial variables	 
	 chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 /// // children age	 
	pct pct_merge gor

append using `tempo' , force
save `tempo', replace	
}

////////////////////////////////////////////////////////////////////////////////
// Wave 1 (2002/-3) ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
if 1==1 {

 use "wave_1_core_data_v3", clear

gen wave=1
gen year=2002

* It sounds weird, bu this file from wave 2 includes de derived vars for both waves
merge 1:1 idauniq using wave_2_derived_variables , nogen keep(match master) 
merge 1:1 idauniq using wave_1_financial_derived_variables , nogen 
merge 1:1 idauniq using wave_1_ifs_derived_variables , nogen 
merge 1:1 idauniq using "$dropbox\ELSA\NatCenFiles\PCT\ID2 Paul Lesmes wave1 PCT.dta", gen(pct_merge)  keep(master match)

replace age=. if age==99 // Censoring issue
recode indobyr (-7 = .)

* Without using the derived vars...
/*
gen r_hibpe=0
foreach x of varlist hedim* {
	replace r_hibpe=1 if `x'==1
}
*/

* This question is more like this...
* IMPORTANT: THE MEANING OF hedimbp CHANGE IN WAVES 4 AND 5
rename hedimbp hediagbp
rename hediman hediagan
rename hedimmi hediagmi
rename hedimhf hediaghf
rename hedimhm hediaghm
rename hedimar hediagar
rename hedimdi hediagdh
rename hedbts hediagdi
rename hedimst hediagst
*rename hedimch hediaghc
rename hediblu hebdialu
rename hedibas hebdiaas
rename hedibar hebdiaar
rename hedibos hebdiaos
rename hedibca hebdiaca

replace hediagbp=0 if hediagbp==-3
replace hediagan=0 if hediagan==-3
replace hediagmi=0 if hediagmi==-3
replace hediaghf=0 if hediaghf==-3
replace hediaghm=0 if hediaghm==-3
replace hediagar=0 if hediagar==-3
replace hediagdh=0 if hediagdh==-3
replace hediagdi=0 if hediagdi==-3
replace hediagst=0 if hediagst==-3
*replace hediaghc=0 if hediaghc==-3
replace hebdialu=0 if hebdialu==-3
replace hebdiaas=0 if hebdiaas==-3
replace hebdiaar=0 if hebdiaar==-3
replace hebdiaos=0 if hebdiaos==-3
replace hebdiaca=0 if hebdiaca==-3

	rename w1wgt xwgt	

keep wave year idauniq wave indobyr indager refreshtype dimar fqethnr edqual hepain ///
	asampsta finstat xwgt /// // Sample and weight
	 $basic $expW12345 ///
	 $house $pensions $healthVars $disW1234 $consumption $jobdetails3 ///
     hesmk heska hecig heskb hetba hetbb heskc hetbc hetbd heacta heactb heactc wpjact heala healb healc hemda hehelf heill  hegenhb hehelfb  hegenh hehelf helim hefunc  ///
     father fthagd  dicdnf mother mthagd  dicdnm ///
	 totinc_bu_s savings_bu_s invests_bu_s debt_bu_s nettotw_bu_s ///
	wpactive thp_r_i oj_r_i empinc_r_s hours_aj $functionIndex ///
	$hbpW12345 ///
	 wpactw wpmoj wphmsj wphwrk wphjob wpdes ///      // Work status
	 wpperi wpthp wpes wpesj wpesjm	///			// Wages and salary for employees
 	 wpphi wphowu wphowe wpmhi /// // Health Insurance	 
	 coupid- totwq10_bu_f intdatm-mortinc85  /// // Keep all the financial variables	 
	 chage1 chage2 chage3 chage4 chage5 chage6 chage7 chage8 chage9 chage10 chage11 chage12 chage13 chage14 chage15 chage16 /// // children age	 
	pct pct_merge gor
	
	
append using `tempo' , force
save `tempo', replace
}

////////////////////////////////////////////////////////////////////////////////
// Which data do you have? //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

drop if wave==.

gen waveOr=wave

xtset idauniq wave
tsfill, full

save `tempo', replace

////////////////////////////////////////////////////////////////////////////////
// Index file //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

* Index file only until wave 9

use "wave_9_elsa_data_eul_v1", clear // .............................................
merge 1:1 idauniq using wave_9_ifs_derived_variables , nogen 
*merge 1:1 idauniq using elsa_endoflife_w6archive , gen(death) // <<<<<<<<<<< Not yet available
gen sexw9=sex
rename w9indout outindw9
rename w9nurout outnrsw9
keep idauniq sexw9 outindw9 outnrsw9
tempfile wa9
save `wa9'

use "wave_8_elsa_data_eul_v2", clear // .............................................
merge 1:1 idauniq using wave_8_elsa_financial_dvs_eul_v1 , nogen 
gen sexw8=indsex
rename w8indout outindw8
rename w8nurout outnrsw8
keep idauniq sexw8 outindw8 outnrsw8
tempfile wa8
save `wa8'

use "wave_7_elsa_data", clear // .............................................
merge 1:1 idauniq using wave_7_financial_derived_variables , nogen 
gen sexw7=indsex
rename w7indout outindw7
keep idauniq sexw7 outindw7
tempfile wa7
save `wa7'

use "wave_6_elsa_data_v2", clear // .............................................
merge 1:1 idauniq using wave_6_elsa_nurse_data_v2 , nogen 
merge 1:1 idauniq using wave_6_ifs_derived_variables , nogen 
merge 1:1 idauniq using elsa_endoflife_w6archive , gen(death) // <<<<<<<<<<<<<<<<<<<<<<< No derived vars in ELSA 

gen sexw6=sex
replace sexw6=EISex if death==2
rename EiDateY yrdeathw6
rename EiRAGE agedead2w6



	replace w6indout=95 if death==2
	//recode w6indout (11=1) (95 =2 ) (nonmiss = 0 ), gen(outindw6)
	
	rename w6indout outindw6
	label values outindw6 lout
	
	gen mortwavew6=0
	replace mortwavew6=-5 if yrdeathw6<2002  & yrdeathw6!=.
	replace mortwavew6=10 if yrdeathw6>=2002 & yrdeathw6!=.
	replace mortwavew6=20 if yrdeathw6>=2004 & yrdeathw6!=.
	replace mortwavew6=30 if yrdeathw6>=2006 & yrdeathw6!=.
	replace mortwavew6=40 if yrdeathw6>=2008 & yrdeathw6!=.
	replace mortwavew6=50 if yrdeathw6>=2010 & yrdeathw6!=.
	replace mortwavew6=60 if yrdeathw6>=2012 & yrdeathw6!=.

	recode NurOutc (81 =1) (nonmiss = 3 ) , gen(outnrsw6) // << refusals/non-eligibility... don't know!
	
keep idauniq outindw6 outnrsw6 yrdeathw6 agedead2w6 sexw6	 mortwavew6 // outnrsw6
tempfile wa6
save `wa6'

* Index file *******************************************************************
use idauniq outindw* outnrsw* mortstat yrdeath mortwave agedead2 maincod sex dobyear hseyr hseint using "index_file_wave_0-wave_5_v2" , clear

merge 1:1 idauniq using `wa6', gen(mergew6)
merge 1:1 idauniq using `wa7', gen(mergew7)
merge 1:1 idauniq using `wa8', gen(mergew8)
merge 1:1 idauniq using `wa9', gen(mergew9)

replace sex=sexw6 if sex==.
replace yrdeath=yrdeathw6   if (yrdeath==.)  | (yrdeathw6>0 & yrdeathw6!=.)
replace agedead2=agedead2w6 if (agedead2==.) | (agedead2>0 & agedead2!=.)
replace mortwave=mortwavew6 if (mortwave==.) | (mortwavew6>0 & mortwavew6!=.)

forval w=0(1)5 {
	replace outindw`w'=-2 if mergew6==2
}
replace outindw6=0 if mergew6==1
drop mergew6

recode outindw0 (51 53=1) (nonmiss = 0 ), gen(outind0)
recode outindw1 (11=1) (79 99 =2 ) (nonmiss = 0 ), gen(outind1)
recode outindw2 (11=1) (90 99 =2 ) (nonmiss = 0 ), gen(outind2)
recode outindw3 (11=1) (95 99 =2 ) (nonmiss = 0 ), gen(outind3)
recode outindw4 (11=1) (95    =2 ) (nonmiss = 0 ), gen(outind4)
recode outindw5 (11=1) (95 99 =2 ) (nonmiss = 0 ), gen(outind5)
recode outindw6 (11=1) (95 99 =2 ) (nonmiss = 0 ), gen(outind6)
recode outindw7 (11=1) (95 99 =2 ) (nonmiss = 0 ), gen(outind7)
recode outindw8 (11=1) (95 99 =2 ) (nonmiss = 0 ), gen(outind8)
recode outindw9 (11=1) (95 99 =2 ) (nonmiss = 0 ), gen(outind9)
label define lout 0 "No Full interview " 1 "Full interview" 2 "Death"


recode outnrsw0 (81=1) (80 83 84 90 = 2) (82 85/89 = 3) (nonmiss = 0 ), gen(outnrs0)
recode outnrsw2 (81=1) (80 83 84 99 = 2) (82 85/89 = 3) (nonmiss = 0 ), gen(outnrs2)
recode outnrsw4 (81=1) (80 83 84 99 = 2) (82 85/89 = 3) (nonmiss = 0 ), gen(outnrs4)
recode outnrsw6 (81=1) (80 83 84 99 = 2) (82 85/89 = 3) (nonmiss = 0 ), gen(outnrs6)
recode outnrsw8 (81=1) (80 83 84 99 = 2) (82 85/89 = 3) (nonmiss = 0 ), gen(outnrs8)
recode outnrsw9 (81=1) (80 83 84 99 = 2) (82 85/89 = 3) (nonmiss = 0 ), gen(outnrs9)
label define lnurse 0 "Not eligible" 1 "Nurse Schedule OK" 2 "Refusal" 3 "No Nurse Schedule"

drop outindw* outnrsw*

gen died1= mortwave>0 & mortwave<20
gen died2= mortwave>0 & mortwave<30
gen died3= mortwave>0 & mortwave<40
gen died4= mortwave>0 & mortwave<50
gen died5= mortwave>0 & mortwave<60
gen died6= mortwave>0 & mortwave<70

reshape long outind outnrs died sexw , i(idauniq) j(wave)
label var outind "Full Interview in Person"
label values outind lout

label var outnrs "Nurse Interview status"
label values outnrs lnurse

label var died "Already death by this wave"

replace died=0 if wave==0

* ******************************

merge 1:1 idauniq wave using  `tempo' , gen(mergeIndex) keep(match using)
tab wave mergeIndex, mi


* mergeIndex==2?? >> 15 weird guys
drop if (mergeIndex==2) // | wave>6 // >>>>>>>>>>>>>>>>> Until we get info on deaths for wave 7 onwards

* ******************************
// Add prices, unemployment and gdp
// Dta from: http://www.ons.gov.uk/ons/site-information/using-the-website/time-series/index.html#2
merge m:1 intdatm intdaty using "$dropbox\ELSA\ONSdata\ons_monthly2.dta", keep(match master)
tab _merge wave
drop _merge

rename unem unempNat
label var unempNat "National Unempl. Rate (ONS)"

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Giacomo's dataset

merge m:1 iintdatm iintdaty using "$dropbox\ELSA\ONSdata\ons_cpi_unemp.dta", gen(merge_ons)
drop if merge_ons==2

/* region of residence */
gen region = .
replace region = 1 if gor=="E12000001" | gor=="A"
replace region = 2 if gor=="E12000002" | gor=="B"
replace region = 3 if gor=="E12000003" | gor=="D"
replace region = 4 if gor=="E12000004" | gor=="E"
replace region = 5 if gor=="E12000005" | gor=="F"
replace region = 6 if gor=="E12000006" | gor=="G"
replace region = 7 if gor=="E12000007" | gor=="H"
replace region = 8 if gor=="E12000008" | gor=="J"
replace region = 9 if gor=="E12000009" | gor=="K"
replace region = 10 if gor=="S99999999"
replace region = 11 if gor=="W99999999"

lab def reg	1 "North East" ///
			2 "North West" ///
			3 "Yorkshire and The Humber" ///
			4 "East Midlands" ///
			5 "West Midlands" ///
			6 "East of England" ///
			7 "London" ///
			8 "South East" ///
			9 "South West" ///
			10 "Scotland" ///
			11 "Wales"
lab var region reg

/* UNEMPLOYMENT RATE in region of residence (from ONS) */
gen unemp=.
lab var unemp 	"Unempl. Rate in Region of Residence at Interview (ONS)"

forvalues i=1(1)11 {
	replace unemp=u_`i' if region==`i'
	}

drop ym u_*

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
label var wave "Wave"

replace year=intdaty if intdaty!=. // The year of the inerview should be the actual year!

xtset idauniq wave
 
saveold "$dropbox\ELSA\ELSA_NatCen_2017PRE.dta", replace
	
	
	
	
