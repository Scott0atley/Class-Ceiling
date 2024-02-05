
/// The Class Ceiling Replication placing Ceiling Effects in Temporal Context ///

*/

/*
1. Change the following parameters.
*/
* Top-level directory which original and constructed data files will be located under
cd "G:\Working Directory for Econ Data"
* Directory in which UKHLS and BHPS files are kept.
global fld					"G:\Working Directory for Econ Data\UKHLS BHPS Folder"
* Folder data will be saved in.
global dta_fld				"G:\Stata data and do\do files\Class Ceiling\data"
* Folder do files are kept in.
global do_fld				"G:\Stata data and do\do files\Class Ceiling\do files"
* Set Personal ado folder
sysdir set PLUS 			"${do_fld}\ado\"

* BHPS Folder Prefix for Stata Files
global bhps_path			bhps
* UKHLS Folder Prefix for Stata Files
global ukhls_path			ukhls

* Number of BHPS Waves to be collected
global bhps_waves			18
* Number of Understanding Society Waves to be collected
global ukhls_waves			9		

* Decide whether to run full code (set equal to YES, if so)
global run_full				"YES"

/*
2. Macros to be used across do files.
*/
global total_waves=${ukhls_waves}+${bhps_waves}
global max_waves=max(${bhps_waves},${ukhls_waves})
global first_bhps_eh_wave=8
global last_bhps_eh_wave=18

/*
3. Create Reusable Programs.
*/
do "${do_fld}/Create Programs.do"

									
if "$run_full"=="YES"{
	cls
	global start_time "$S_TIME"
	di in red "Program Started: $start_time"
	
	*i. Prepare basis data.
	qui do "${do_fld}\Interview Grid.do"	
	
	di in red "Program Started: $start_time"
	di in red "Program Completed: $S_TIME"
}



cd "G:\Stata data and do\do files\Class Ceiling\data"
use "G:\Stata data and do\do files\Class Ceiling\data\Interview Grid"


codebook pasoc10_cc panssec8_dv masoc10_cc manssec8_dv jbnssec8_dv jbsoc10_cc fimnlabgrs_dv dvage Birth_Y sex racel plbornc qfhigh_dv health sf1 gor_dv jbiindb_dv jbsect jbsectpub jbsize jbft_dv, compact


*Re-coding*

tab panssec8_dv

gen nssecf=. 
replace nssecf=1 if(panssec8_dv==1)
replace nssecf=2 if(panssec8_dv==2)
replace nssecf=3 if(panssec8_dv==3)
replace nssecf=4 if(panssec8_dv==4)
replace nssecf=5 if(panssec8_dv==5)
replace nssecf=6 if(panssec8_dv==6)
replace nssecf=7 if(panssec8_dv==7)
replace nssecf=8 if(panssec8_dv==8)

label define nssec_lbl 1"Large employers & higher management" 2"Higher professional" 3"Lower management & professional" 4"Intermediate" 5"Small employers & own account" 6"Lower supervisory & technical" 7"Semi-routine" 8"Routine"
label values nssecf nssec_lbl

tab nssecf

tab manssec8_dv

gen nssecm=.
replace nssecm=1 if(manssec8_dv==1)
replace nssecm=2 if(manssec8_dv==2)
replace nssecm=3 if(manssec8_dv==3)
replace nssecm=4 if(manssec8_dv==4)
replace nssecm=5 if(manssec8_dv==5)
replace nssecm=6 if(manssec8_dv==6)
replace nssecm=7 if(manssec8_dv==7)
replace nssecm=8 if(manssec8_dv==8)

label values nssecm nssec_lbl

tab nssecm

gen nssecdom=.
replace nssecdom=1 if(nssecf==1)
replace nssecdom=1 if(nssecf==. & nssecm==1)
replace nssecdom=2 if(nssecf==2)
replace nssecdom=2 if(nssecf==. & nssecm==2)
replace nssecdom=3 if(nssecf==3)
replace nssecdom=3 if(nssecf==. & nssecm==3)
replace nssecdom=4 if(nssecf==4)
replace nssecdom=4 if(nssecf==. & nssecm==4)
replace nssecdom=5 if(nssecf==5)
replace nssecdom=5 if(nssecf==. & nssecm==5)
replace nssecdom=6 if(nssecf==6)
replace nssecdom=6 if(nssecf==. & nssecm==6)
replace nssecdom=7 if(nssecf==7)
replace nssecdom=7 if(nssecf==. & nssecm==7)
replace nssecdom=8 if(nssecf==8)
replace nssecdom=8 if(nssecf==. & nssecm==8)

label values nssecdom nssec_lbl

tab nssecdom

* Semi-dominance approach adds about 6,000 cases *


tab jbnssec8_dv

gen curnssec=.
replace curnssec=1 if(jbnssec8_dv==1)
replace curnssec=2 if(jbnssec8_dv==2)
replace curnssec=3 if(jbnssec8_dv==3)
replace curnssec=4 if(jbnssec8_dv==4)
replace curnssec=5 if(jbnssec8_dv==5)
replace curnssec=6 if(jbnssec8_dv==6)
replace curnssec=7 if(jbnssec8_dv==7)
replace curnssec=8 if(jbnssec8_dv==8)

label values curnssec nssec_lbl

tab curnssec

summarize fimnlabgrs_dv

*generate yearly income*
gen labincome = fimnlabgrs_dv
replace labincome=. if (labincome<10)
gen yearlyincome= labincome*12

*generate yearly income adjusted for inflation to be comparable to 2016 LFS figures* https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/d7bt/mm23?referrer=search&searchTerm=d7bt
*To create inflation adjusted figure, yearlyincome is * by the CPI of 2016/ CPI of 1991
gen adjincome =.
replace adjincome = yearlyincome*100.2/62.9 if istrtdaty==1992 & istrtdatm==9
replace adjincome = yearlyincome*100.2/63.1 if istrtdaty==1992 & istrtdatm==10
replace adjincome = yearlyincome*100.2/63.1 if istrtdaty==1992 & istrtdatm==11
replace adjincome = yearlyincome*100.2/63.2 if istrtdaty==1992 & istrtdatm==12

replace adjincome = yearlyincome*100.2/62.8 if istrtdaty==1993 & istrtdatm==1
replace adjincome = yearlyincome*100.2/63.2 if istrtdaty==1993 & istrtdatm==2
replace adjincome = yearlyincome*100.2/63.6 if istrtdaty==1993 & istrtdatm==3
replace adjincome = yearlyincome*100.2/64.3 if istrtdaty==1993 & istrtdatm==4
replace adjincome = yearlyincome*100.2/64.5 if istrtdaty==1993 & istrtdatm==5
replace adjincome = yearlyincome*100.2/64.5 if istrtdaty==1993 & istrtdatm==6
replace adjincome = yearlyincome*100.2/64.2 if istrtdaty==1993 & istrtdatm==7
replace adjincome = yearlyincome*100.2/64.5 if istrtdaty==1993 & istrtdatm==8
replace adjincome = yearlyincome*100.2/64.5 if istrtdaty==1993 & istrtdatm==9
replace adjincome = yearlyincome*100.2/64.7 if istrtdaty==1993 & istrtdatm==10
replace adjincome = yearlyincome*100.2/64.6 if istrtdaty==1993 & istrtdatm==11
replace adjincome = yearlyincome*100.2/64.7 if istrtdaty==1993 & istrtdatm==12

replace adjincome = yearlyincome*100.2/64.5 if istrtdaty==1994 & istrtdatm==1
replace adjincome = yearlyincome*100.2/64.8 if istrtdaty==1994 & istrtdatm==2
replace adjincome = yearlyincome*100.2/65.0 if istrtdaty==1994 & istrtdatm==3
replace adjincome = yearlyincome*100.2/65.5 if istrtdaty==1994 & istrtdatm==4
replace adjincome = yearlyincome*100.2/65.8 if istrtdaty==1994 & istrtdatm==5
replace adjincome = yearlyincome*100.2/65.8 if istrtdaty==1994 & istrtdatm==6
replace adjincome = yearlyincome*100.2/65.4 if istrtdaty==1994 & istrtdatm==7
replace adjincome = yearlyincome*100.2/65.7 if istrtdaty==1994 & istrtdatm==8
replace adjincome = yearlyincome*100.2/65.8 if istrtdaty==1994 & istrtdatm==9
replace adjincome = yearlyincome*100.2/65.7 if istrtdaty==1994 & istrtdatm==10
replace adjincome = yearlyincome*100.2/65.7 if istrtdaty==1994 & istrtdatm==11
replace adjincome = yearlyincome*100.2/66.0 if istrtdaty==1994 & istrtdatm==12

replace adjincome = yearlyincome*100.2/66.0 if istrtdaty==1995 & istrtdatm==1
replace adjincome = yearlyincome*100.2/66.3 if istrtdaty==1995 & istrtdatm==2
replace adjincome = yearlyincome*100.2/66.7 if istrtdaty==1995 & istrtdatm==3
replace adjincome = yearlyincome*100.2/67.0 if istrtdaty==1995 & istrtdatm==4
replace adjincome = yearlyincome*100.2/67.4 if istrtdaty==1995 & istrtdatm==5
replace adjincome = yearlyincome*100.2/67.4 if istrtdaty==1995 & istrtdatm==6
replace adjincome = yearlyincome*100.2/67.1 if istrtdaty==1995 & istrtdatm==7
replace adjincome = yearlyincome*100.2/67.4 if istrtdaty==1995 & istrtdatm==8
replace adjincome = yearlyincome*100.2/67.7 if istrtdaty==1995 & istrtdatm==9
replace adjincome = yearlyincome*100.2/67.6 if istrtdaty==1995 & istrtdatm==10
replace adjincome = yearlyincome*100.2/67.6 if istrtdaty==1995 & istrtdatm==11
replace adjincome = yearlyincome*100.2/68.0 if istrtdaty==1995 & istrtdatm==12

replace adjincome = yearlyincome*100.2/67.8 if istrtdaty==1996 & istrtdatm==1
replace adjincome = yearlyincome*100.2/68.1 if istrtdaty==1996 & istrtdatm==2
replace adjincome = yearlyincome*100.2/68.4 if istrtdaty==1996 & istrtdatm==3
replace adjincome = yearlyincome*100.2/68.7 if istrtdaty==1996 & istrtdatm==4
replace adjincome = yearlyincome*100.2/68.9 if istrtdaty==1996 & istrtdatm==5
replace adjincome = yearlyincome*100.2/69.0 if istrtdaty==1996 & istrtdatm==6
replace adjincome = yearlyincome*100.2/68.6 if istrtdaty==1996 & istrtdatm==7
replace adjincome = yearlyincome*100.2/68.9 if istrtdaty==1996 & istrtdatm==8
replace adjincome = yearlyincome*100.2/69.3 if istrtdaty==1996 & istrtdatm==9
replace adjincome = yearlyincome*100.2/69.3 if istrtdaty==1996 & istrtdatm==10
replace adjincome = yearlyincome*100.2/69.3 if istrtdaty==1996 & istrtdatm==11
replace adjincome = yearlyincome*100.2/69.5 if istrtdaty==1996 & istrtdatm==12

replace adjincome = yearlyincome*100.2/69.2 if istrtdaty==1997 & istrtdatm==1
replace adjincome = yearlyincome*100.2/69.4 if istrtdaty==1997 & istrtdatm==2
replace adjincome = yearlyincome*100.2/69.5 if istrtdaty==1997 & istrtdatm==3
replace adjincome = yearlyincome*100.2/69.8 if istrtdaty==1997 & istrtdatm==4
replace adjincome = yearlyincome*100.2/70.0 if istrtdaty==1997 & istrtdatm==5
replace adjincome = yearlyincome*100.2/70.2 if istrtdaty==1997 & istrtdatm==6
replace adjincome = yearlyincome*100.2/69.9 if istrtdaty==1997 & istrtdatm==7
replace adjincome = yearlyincome*100.2/70.3 if istrtdaty==1997 & istrtdatm==8
replace adjincome = yearlyincome*100.2/70.6 if istrtdaty==1997 & istrtdatm==9
replace adjincome = yearlyincome*100.2/70.6 if istrtdaty==1997 & istrtdatm==10
replace adjincome = yearlyincome*100.2/70.6 if istrtdaty==1997 & istrtdatm==11
replace adjincome = yearlyincome*100.2/70.7 if istrtdaty==1997 & istrtdatm==12

replace adjincome = yearlyincome*100.2/70.3 if istrtdaty==1998 & istrtdatm==1
replace adjincome = yearlyincome*100.2/70.5 if istrtdaty==1998 & istrtdatm==2
replace adjincome = yearlyincome*100.2/70.7 if istrtdaty==1998 & istrtdatm==3
replace adjincome = yearlyincome*100.2/71.1 if istrtdaty==1998 & istrtdatm==4
replace adjincome = yearlyincome*100.2/71.4 if istrtdaty==1998 & istrtdatm==5
replace adjincome = yearlyincome*100.2/71.3 if istrtdaty==1998 & istrtdatm==6
replace adjincome = yearlyincome*100.2/71.0 if istrtdaty==1998 & istrtdatm==7
replace adjincome = yearlyincome*100.2/71.2 if istrtdaty==1998 & istrtdatm==8
replace adjincome = yearlyincome*100.2/71.5 if istrtdaty==1998 & istrtdatm==9
replace adjincome = yearlyincome*100.2/71.5 if istrtdaty==1998 & istrtdatm==10
replace adjincome = yearlyincome*100.2/71.6 if istrtdaty==1998 & istrtdatm==11
replace adjincome = yearlyincome*100.2/71.8 if istrtdaty==1998 & istrtdatm==12

replace adjincome = yearlyincome*100.2/71.4 if istrtdaty==1999 & istrtdatm==1
replace adjincome = yearlyincome*100.2/71.5 if istrtdaty==1999 & istrtdatm==2
replace adjincome = yearlyincome*100.2/71.9 if istrtdaty==1999 & istrtdatm==3
replace adjincome = yearlyincome*100.2/72.2 if istrtdaty==1999 & istrtdatm==4
replace adjincome = yearlyincome*100.2/72.4 if istrtdaty==1999 & istrtdatm==5
replace adjincome = yearlyincome*100.2/72.3 if istrtdaty==1999 & istrtdatm==6
replace adjincome = yearlyincome*100.2/71.9 if istrtdaty==1999 & istrtdatm==7
replace adjincome = yearlyincome*100.2/72.1 if istrtdaty==1999 & istrtdatm==8
replace adjincome = yearlyincome*100.2/72.4 if istrtdaty==1999 & istrtdatm==9
replace adjincome = yearlyincome*100.2/72.3 if istrtdaty==1999 & istrtdatm==10
replace adjincome = yearlyincome*100.2/72.4 if istrtdaty==1999 & istrtdatm==11
replace adjincome = yearlyincome*100.2/72.6 if istrtdaty==1999 & istrtdatm==12

replace adjincome = yearlyincome*100.2/71.9 if istrtdaty==2000 & istrtdatm==1
replace adjincome = yearlyincome*100.2/72.2 if istrtdaty==2000 & istrtdatm==2
replace adjincome = yearlyincome*100.2/72.3 if istrtdaty==2000 & istrtdatm==3
replace adjincome = yearlyincome*100.2/72.6 if istrtdaty==2000 & istrtdatm==4
replace adjincome = yearlyincome*100.2/72.8 if istrtdaty==2000 & istrtdatm==5
replace adjincome = yearlyincome*100.2/72.9 if istrtdaty==2000 & istrtdatm==6
replace adjincome = yearlyincome*100.2/72.5 if istrtdaty==2000 & istrtdatm==7
replace adjincome = yearlyincome*100.2/72.5 if istrtdaty==2000 & istrtdatm==8
replace adjincome = yearlyincome*100.2/73.1 if istrtdaty==2000 & istrtdatm==9
replace adjincome = yearlyincome*100.2/73.1 if istrtdaty==2000 & istrtdatm==10
replace adjincome = yearlyincome*100.2/73.2 if istrtdaty==2000 & istrtdatm==11
replace adjincome = yearlyincome*100.2/73.2 if istrtdaty==2000 & istrtdatm==12

replace adjincome = yearlyincome*100.2/72.6 if istrtdaty==2001 & istrtdatm==1
replace adjincome = yearlyincome*100.2/72.7 if istrtdaty==2001 & istrtdatm==2
replace adjincome = yearlyincome*100.2/73.0 if istrtdaty==2001 & istrtdatm==3
replace adjincome = yearlyincome*100.2/73.4 if istrtdaty==2001 & istrtdatm==4
replace adjincome = yearlyincome*100.2/74.0 if istrtdaty==2001 & istrtdatm==5
replace adjincome = yearlyincome*100.2/74.1 if istrtdaty==2001 & istrtdatm==6
replace adjincome = yearlyincome*100.2/73.6 if istrtdaty==2001 & istrtdatm==7
replace adjincome = yearlyincome*100.2/73.9 if istrtdaty==2001 & istrtdatm==8
replace adjincome = yearlyincome*100.2/74.1 if istrtdaty==2001 & istrtdatm==9
replace adjincome = yearlyincome*100.2/73.9 if istrtdaty==2001 & istrtdatm==10
replace adjincome = yearlyincome*100.2/73.8 if istrtdaty==2001 & istrtdatm==11
replace adjincome = yearlyincome*100.2/74.0 if istrtdaty==2001 & istrtdatm==12

replace adjincome = yearlyincome*100.2/73.7 if istrtdaty==2002 & istrtdatm==1
replace adjincome = yearlyincome*100.2/73.8 if istrtdaty==2002 & istrtdatm==2
replace adjincome = yearlyincome*100.2/74.1 if istrtdaty==2002 & istrtdatm==3
replace adjincome = yearlyincome*100.2/74.4 if istrtdaty==2002 & istrtdatm==4
replace adjincome = yearlyincome*100.2/74.6 if istrtdaty==2002 & istrtdatm==5
replace adjincome = yearlyincome*100.2/74.6 if istrtdaty==2002 & istrtdatm==6
replace adjincome = yearlyincome*100.2/74.4 if istrtdaty==2002 & istrtdatm==7
replace adjincome = yearlyincome*100.2/74.6 if istrtdaty==2002 & istrtdatm==8
replace adjincome = yearlyincome*100.2/74.8 if istrtdaty==2002 & istrtdatm==9
replace adjincome = yearlyincome*100.2/74.9 if istrtdaty==2002 & istrtdatm==10
replace adjincome = yearlyincome*100.2/74.9 if istrtdaty==2002 & istrtdatm==11
replace adjincome = yearlyincome*100.2/75.2 if istrtdaty==2002 & istrtdatm==12

replace adjincome = yearlyincome*100.2/74.7 if istrtdaty==2003 & istrtdatm==1
replace adjincome = yearlyincome*100.2/75.0 if istrtdaty==2003 & istrtdatm==2
replace adjincome = yearlyincome*100.2/75.3 if istrtdaty==2003 & istrtdatm==3
replace adjincome = yearlyincome*100.2/75.5 if istrtdaty==2003 & istrtdatm==4
replace adjincome = yearlyincome*100.2/75.5 if istrtdaty==2003 & istrtdatm==5
replace adjincome = yearlyincome*100.2/75.4 if istrtdaty==2003 & istrtdatm==6
replace adjincome = yearlyincome*100.2/75.3 if istrtdaty==2003 & istrtdatm==7
replace adjincome = yearlyincome*100.2/75.6 if istrtdaty==2003 & istrtdatm==8
replace adjincome = yearlyincome*100.2/75.9 if istrtdaty==2003 & istrtdatm==9
replace adjincome = yearlyincome*100.2/76.0 if istrtdaty==2003 & istrtdatm==10
replace adjincome = yearlyincome*100.2/75.9 if istrtdaty==2003 & istrtdatm==11
replace adjincome = yearlyincome*100.2/76.2 if istrtdaty==2003 & istrtdatm==12

replace adjincome = yearlyincome*100.2/75.8 if istrtdaty==2004 & istrtdatm==1
replace adjincome = yearlyincome*100.2/76.0 if istrtdaty==2004 & istrtdatm==2
replace adjincome = yearlyincome*100.2/76.1 if istrtdaty==2004 & istrtdatm==3
replace adjincome = yearlyincome*100.2/76.4 if istrtdaty==2004 & istrtdatm==4
replace adjincome = yearlyincome*100.2/76.6 if istrtdaty==2004 & istrtdatm==5
replace adjincome = yearlyincome*100.2/76.6 if istrtdaty==2004 & istrtdatm==6
replace adjincome = yearlyincome*100.2/76.4 if istrtdaty==2004 & istrtdatm==7
replace adjincome = yearlyincome*100.2/76.6 if istrtdaty==2004 & istrtdatm==8
replace adjincome = yearlyincome*100.2/76.7 if istrtdaty==2004 & istrtdatm==9
replace adjincome = yearlyincome*100.2/76.9 if istrtdaty==2004 & istrtdatm==10
replace adjincome = yearlyincome*100.2/77.0 if istrtdaty==2004 & istrtdatm==11
replace adjincome = yearlyincome*100.2/77.4 if istrtdaty==2004 & istrtdatm==12

replace adjincome = yearlyincome*100.2/77.0 if istrtdaty==2005 & istrtdatm==1
replace adjincome = yearlyincome*100.2/77.2 if istrtdaty==2005 & istrtdatm==2
replace adjincome = yearlyincome*100.2/77.5 if istrtdaty==2005 & istrtdatm==3
replace adjincome = yearlyincome*100.2/77.8 if istrtdaty==2005 & istrtdatm==4
replace adjincome = yearlyincome*100.2/78.1 if istrtdaty==2005 & istrtdatm==5
replace adjincome = yearlyincome*100.2/78.1 if istrtdaty==2005 & istrtdatm==6
replace adjincome = yearlyincome*100.2/78.2 if istrtdaty==2005 & istrtdatm==7
replace adjincome = yearlyincome*100.2/78.4 if istrtdaty==2005 & istrtdatm==8
replace adjincome = yearlyincome*100.2/78.6 if istrtdaty==2005 & istrtdatm==9
replace adjincome = yearlyincome*100.2/78.7 if istrtdaty==2005 & istrtdatm==10
replace adjincome = yearlyincome*100.2/78.7 if istrtdaty==2005 & istrtdatm==11
replace adjincome = yearlyincome*100.2/78.9 if istrtdaty==2005 & istrtdatm==12

replace adjincome = yearlyincome*100.2/78.5 if istrtdaty==2006 & istrtdatm==1
replace adjincome = yearlyincome*100.2/78.8 if istrtdaty==2006 & istrtdatm==2
replace adjincome = yearlyincome*100.2/78.9 if istrtdaty==2006 & istrtdatm==3
replace adjincome = yearlyincome*100.2/79.4 if istrtdaty==2006 & istrtdatm==4
replace adjincome = yearlyincome*100.2/79.9 if istrtdaty==2006 & istrtdatm==5
replace adjincome = yearlyincome*100.2/80.1 if istrtdaty==2006 & istrtdatm==6
replace adjincome = yearlyincome*100.2/80.0 if istrtdaty==2006 & istrtdatm==7
replace adjincome = yearlyincome*100.2/80.4 if istrtdaty==2006 & istrtdatm==8
replace adjincome = yearlyincome*100.2/80.5 if istrtdaty==2006 & istrtdatm==9
replace adjincome = yearlyincome*100.2/80.6 if istrtdaty==2006 & istrtdatm==10
replace adjincome = yearlyincome*100.2/80.8 if istrtdaty==2006 & istrtdatm==11
replace adjincome = yearlyincome*100.2/81.3 if istrtdaty==2006 & istrtdatm==12

replace adjincome = yearlyincome*100.2/80.6 if istrtdaty==2007 & istrtdatm==1
replace adjincome = yearlyincome*100.2/81.0 if istrtdaty==2007 & istrtdatm==2
replace adjincome = yearlyincome*100.2/81.4 if istrtdaty==2007 & istrtdatm==3
replace adjincome = yearlyincome*100.2/81.6 if istrtdaty==2007 & istrtdatm==4
replace adjincome = yearlyincome*100.2/81.8 if istrtdaty==2007 & istrtdatm==5
replace adjincome = yearlyincome*100.2/82.0 if istrtdaty==2007 & istrtdatm==6
replace adjincome = yearlyincome*100.2/81.5 if istrtdaty==2007 & istrtdatm==7
replace adjincome = yearlyincome*100.2/81.8 if istrtdaty==2007 & istrtdatm==8
replace adjincome = yearlyincome*100.2/81.9 if istrtdaty==2007 & istrtdatm==9
replace adjincome = yearlyincome*100.2/82.3 if istrtdaty==2007 & istrtdatm==10
replace adjincome = yearlyincome*100.2/82.5 if istrtdaty==2007 & istrtdatm==11
replace adjincome = yearlyincome*100.2/83.0 if istrtdaty==2007 & istrtdatm==12

replace adjincome = yearlyincome*100.2/82.4 if istrtdaty==2008 & istrtdatm==1
replace adjincome = yearlyincome*100.2/83.0 if istrtdaty==2008 & istrtdatm==2
replace adjincome = yearlyincome*100.2/83.4 if istrtdaty==2008 & istrtdatm==3
replace adjincome = yearlyincome*100.2/84.0 if istrtdaty==2008 & istrtdatm==4
replace adjincome = yearlyincome*100.2/84.6 if istrtdaty==2008 & istrtdatm==5
replace adjincome = yearlyincome*100.2/85.2 if istrtdaty==2008 & istrtdatm==6
replace adjincome = yearlyincome*100.2/85.1 if istrtdaty==2008 & istrtdatm==7
replace adjincome = yearlyincome*100.2/85.7 if istrtdaty==2008 & istrtdatm==8
replace adjincome = yearlyincome*100.2/86.1 if istrtdaty==2008 & istrtdatm==9
replace adjincome = yearlyincome*100.2/85.9 if istrtdaty==2008 & istrtdatm==10
replace adjincome = yearlyincome*100.2/85.8 if istrtdaty==2008 & istrtdatm==11
replace adjincome = yearlyincome*100.2/85.5 if istrtdaty==2008 & istrtdatm==12

replace adjincome = yearlyincome*100.2/84.9 if istrtdaty==2009 & istrtdatm==1
replace adjincome = yearlyincome*100.2/85.6 if istrtdaty==2009 & istrtdatm==2
replace adjincome = yearlyincome*100.2/85.8 if istrtdaty==2009 & istrtdatm==3
replace adjincome = yearlyincome*100.2/86.0 if istrtdaty==2009 & istrtdatm==4
replace adjincome = yearlyincome*100.2/86.4 if istrtdaty==2009 & istrtdatm==5
replace adjincome = yearlyincome*100.2/86.7 if istrtdaty==2009 & istrtdatm==6
replace adjincome = yearlyincome*100.2/86.7 if istrtdaty==2009 & istrtdatm==7
replace adjincome = yearlyincome*100.2/87.0 if istrtdaty==2009 & istrtdatm==8
replace adjincome = yearlyincome*100.2/87.1 if istrtdaty==2009 & istrtdatm==9
replace adjincome = yearlyincome*100.2/87.2 if istrtdaty==2009 & istrtdatm==10
replace adjincome = yearlyincome*100.2/87.5 if istrtdaty==2009 & istrtdatm==11
replace adjincome = yearlyincome*100.2/88.0 if istrtdaty==2009 & istrtdatm==12

replace adjincome = yearlyincome*100.2/87.8 if istrtdaty==2010 & istrtdatm==1
replace adjincome = yearlyincome*100.2/88.2 if istrtdaty==2010 & istrtdatm==2
replace adjincome = yearlyincome*100.2/88.7 if istrtdaty==2010 & istrtdatm==3
replace adjincome = yearlyincome*100.2/89.2 if istrtdaty==2010 & istrtdatm==4
replace adjincome = yearlyincome*100.2/89.4 if istrtdaty==2010 & istrtdatm==5
replace adjincome = yearlyincome*100.2/89.5 if istrtdaty==2010 & istrtdatm==6
replace adjincome = yearlyincome*100.2/89.3 if istrtdaty==2010 & istrtdatm==7
replace adjincome = yearlyincome*100.2/89.8 if istrtdaty==2010 & istrtdatm==8
replace adjincome = yearlyincome*100.2/89.8 if istrtdaty==2010 & istrtdatm==9
replace adjincome = yearlyincome*100.2/90.0 if istrtdaty==2010 & istrtdatm==10
replace adjincome = yearlyincome*100.2/90.3 if istrtdaty==2010 & istrtdatm==11
replace adjincome = yearlyincome*100.2/91.2 if istrtdaty==2010 & istrtdatm==12

replace adjincome = yearlyincome*100.2/91.3 if istrtdaty==2011 & istrtdatm==1
replace adjincome = yearlyincome*100.2/92.0 if istrtdaty==2011 & istrtdatm==2
replace adjincome = yearlyincome*100.2/92.2 if istrtdaty==2011 & istrtdatm==3
replace adjincome = yearlyincome*100.2/93.2 if istrtdaty==2011 & istrtdatm==4
replace adjincome = yearlyincome*100.2/93.4 if istrtdaty==2011 & istrtdatm==5
replace adjincome = yearlyincome*100.2/93.3 if istrtdaty==2011 & istrtdatm==6
replace adjincome = yearlyincome*100.2/93.3 if istrtdaty==2011 & istrtdatm==7
replace adjincome = yearlyincome*100.2/93.8 if istrtdaty==2011 & istrtdatm==8
replace adjincome = yearlyincome*100.2/94.4 if istrtdaty==2011 & istrtdatm==9
replace adjincome = yearlyincome*100.2/94.5 if istrtdaty==2011 & istrtdatm==10
replace adjincome = yearlyincome*100.2/94.6 if istrtdaty==2011 & istrtdatm==11
replace adjincome = yearlyincome*100.2/95.1 if istrtdaty==2011 & istrtdatm==12

replace adjincome = yearlyincome*100.2/94.6 if istrtdaty==2012 & istrtdatm==1
replace adjincome = yearlyincome*100.2/95.1 if istrtdaty==2012 & istrtdatm==2
replace adjincome = yearlyincome*100.2/95.4 if istrtdaty==2012 & istrtdatm==3
replace adjincome = yearlyincome*100.2/96.0 if istrtdaty==2012 & istrtdatm==4
replace adjincome = yearlyincome*100.2/95.9 if istrtdaty==2012 & istrtdatm==5
replace adjincome = yearlyincome*100.2/95.5 if istrtdaty==2012 & istrtdatm==6
replace adjincome = yearlyincome*100.2/95.6 if istrtdaty==2012 & istrtdatm==7
replace adjincome = yearlyincome*100.2/96.1 if istrtdaty==2012 & istrtdatm==8
replace adjincome = yearlyincome*100.2/96.5 if istrtdaty==2012 & istrtdatm==9
replace adjincome = yearlyincome*100.2/97.0 if istrtdaty==2012 & istrtdatm==10
replace adjincome = yearlyincome*100.2/97.2 if istrtdaty==2012 & istrtdatm==11
replace adjincome = yearlyincome*100.2/97.6 if istrtdaty==2012 & istrtdatm==12

replace adjincome = yearlyincome*100.2/97.1 if istrtdaty==2013 & istrtdatm==1
replace adjincome = yearlyincome*100.2/97.8 if istrtdaty==2013 & istrtdatm==2
replace adjincome = yearlyincome*100.2/98.1 if istrtdaty==2013 & istrtdatm==3
replace adjincome = yearlyincome*100.2/98.3 if istrtdaty==2013 & istrtdatm==4
replace adjincome = yearlyincome*100.2/98.5 if istrtdaty==2013 & istrtdatm==5
replace adjincome = yearlyincome*100.2/98.3 if istrtdaty==2013 & istrtdatm==6
replace adjincome = yearlyincome*100.2/98.3 if istrtdaty==2013 & istrtdatm==7
replace adjincome = yearlyincome*100.2/98.7 if istrtdaty==2013 & istrtdatm==8
replace adjincome = yearlyincome*100.2/99.1 if istrtdaty==2013 & istrtdatm==9
replace adjincome = yearlyincome*100.2/99.1 if istrtdaty==2013 & istrtdatm==10
replace adjincome = yearlyincome*100.2/99.2 if istrtdaty==2013 & istrtdatm==11
replace adjincome = yearlyincome*100.2/99.6 if istrtdaty==2013 & istrtdatm==12

replace adjincome = yearlyincome*100.2/99.0 if istrtdaty==2014 & istrtdatm==1
replace adjincome = yearlyincome*100.2/99.5 if istrtdaty==2014 & istrtdatm==2
replace adjincome = yearlyincome*100.2/99.7 if istrtdaty==2014 & istrtdatm==3
replace adjincome = yearlyincome*100.2/100.1 if istrtdaty==2014 & istrtdatm==4
replace adjincome = yearlyincome*100.2/100.0 if istrtdaty==2014 & istrtdatm==5
replace adjincome = yearlyincome*100.2/100.2 if istrtdaty==2014 & istrtdatm==6
replace adjincome = yearlyincome*100.2/99.9 if istrtdaty==2014 & istrtdatm==7
replace adjincome = yearlyincome*100.2/100.2 if istrtdaty==2014 & istrtdatm==8
replace adjincome = yearlyincome*100.2/100.3 if istrtdaty==2014 & istrtdatm==9
replace adjincome = yearlyincome*100.2/100.4 if istrtdaty==2014 & istrtdatm==10
replace adjincome = yearlyincome*100.2/100.1 if istrtdaty==2014 & istrtdatm==11
replace adjincome = yearlyincome*100.2/100.1 if istrtdaty==2014 & istrtdatm==12

replace adjincome = yearlyincome*100.2/99.3 if istrtdaty==2015 & istrtdatm==1
replace adjincome = yearlyincome*100.2/99.5 if istrtdaty==2015 & istrtdatm==2
replace adjincome = yearlyincome*100.2/99.7 if istrtdaty==2015 & istrtdatm==3
replace adjincome = yearlyincome*100.2/99.9 if istrtdaty==2015 & istrtdatm==4
replace adjincome = yearlyincome*100.2/100.1 if istrtdaty==2015 & istrtdatm==5
replace adjincome = yearlyincome*100.2/100.2 if istrtdaty==2015 & istrtdatm==6
replace adjincome = yearlyincome*100.2/100.0 if istrtdaty==2015 & istrtdatm==7
replace adjincome = yearlyincome*100.2/100.3 if istrtdaty==2015 & istrtdatm==8
replace adjincome = yearlyincome*100.2/100.2 if istrtdaty==2015 & istrtdatm==9
replace adjincome = yearlyincome*100.2/100.3 if istrtdaty==2015 & istrtdatm==10
replace adjincome = yearlyincome*100.2/100.3 if istrtdaty==2015 & istrtdatm==11
replace adjincome = yearlyincome*100.2/100.3 if istrtdaty==2015 & istrtdatm==12

replace adjincome = yearlyincome*100.2/99.5 if istrtdaty==2016 & istrtdatm==1
replace adjincome = yearlyincome*100.2/99.8 if istrtdaty==2016 & istrtdatm==2
replace adjincome = yearlyincome*100.2/100.2 if istrtdaty==2016 & istrtdatm==3
replace adjincome = yearlyincome*100.2/100.2 if istrtdaty==2016 & istrtdatm==4
replace adjincome = yearlyincome*100.2/100.4 if istrtdaty==2016 & istrtdatm==5
replace adjincome = yearlyincome*100.2/100.6 if istrtdaty==2016 & istrtdatm==6
replace adjincome = yearlyincome*100.2/100.6 if istrtdaty==2016 & istrtdatm==7
replace adjincome = yearlyincome*100.2/100.9 if istrtdaty==2016 & istrtdatm==8
replace adjincome = yearlyincome*100.2/101.1 if istrtdaty==2016 & istrtdatm==9
replace adjincome = yearlyincome*100.2/101.2 if istrtdaty==2016 & istrtdatm==10
replace adjincome = yearlyincome*100.2/101.4 if istrtdaty==2016 & istrtdatm==11
replace adjincome = yearlyincome*100.2/101.9 if istrtdaty==2016 & istrtdatm==12

replace adjincome = yearlyincome*100.2/101.4 if istrtdaty==2017 & istrtdatm==1
replace adjincome = yearlyincome*100.2/102.1 if istrtdaty==2017 & istrtdatm==2
replace adjincome = yearlyincome*100.2/102.5 if istrtdaty==2017 & istrtdatm==3
replace adjincome = yearlyincome*100.2/102.9 if istrtdaty==2017 & istrtdatm==4
replace adjincome = yearlyincome*100.2/103.3 if istrtdaty==2017 & istrtdatm==5
replace adjincome = yearlyincome*100.2/103.3 if istrtdaty==2017 & istrtdatm==6
replace adjincome = yearlyincome*100.2/103.2 if istrtdaty==2017 & istrtdatm==7
replace adjincome = yearlyincome*100.2/103.8 if istrtdaty==2017 & istrtdatm==8
replace adjincome = yearlyincome*100.2/104.1 if istrtdaty==2017 & istrtdatm==9
replace adjincome = yearlyincome*100.2/104.2 if istrtdaty==2017 & istrtdatm==10
replace adjincome = yearlyincome*100.2/104.6 if istrtdaty==2017 & istrtdatm==11
replace adjincome = yearlyincome*100.2/104.9 if istrtdaty==2017 & istrtdatm==12

replace adjincome = yearlyincome*100.2/104.4 if istrtdaty==2018 & istrtdatm==1
replace adjincome = yearlyincome*100.2/104.9 if istrtdaty==2018 & istrtdatm==2
replace adjincome = yearlyincome*100.2/105.0 if istrtdaty==2018 & istrtdatm==3
replace adjincome = yearlyincome*100.2/105.4 if istrtdaty==2018 & istrtdatm==4
replace adjincome = yearlyincome*100.2/105.8 if istrtdaty==2018 & istrtdatm==5
replace adjincome = yearlyincome*100.2/105.8 if istrtdaty==2018 & istrtdatm==6
replace adjincome = yearlyincome*100.2/105.8 if istrtdaty==2018 & istrtdatm==7
replace adjincome = yearlyincome*100.2/106.5 if istrtdaty==2018 & istrtdatm==8
replace adjincome = yearlyincome*100.2/106.6 if istrtdaty==2018 & istrtdatm==9
replace adjincome = yearlyincome*100.2/106.7 if istrtdaty==2018 & istrtdatm==10
replace adjincome = yearlyincome*100.2/107.0 if istrtdaty==2018 & istrtdatm==11
replace adjincome = yearlyincome*100.2/107.1 if istrtdaty==2018 & istrtdatm==12

replace adjincome = yearlyincome*100.2/106.3 if istrtdaty==2019 & istrtdatm==1
replace adjincome = yearlyincome*100.2/106.8 if istrtdaty==2019 & istrtdatm==2
replace adjincome = yearlyincome*100.2/107.0 if istrtdaty==2019 & istrtdatm==3
replace adjincome = yearlyincome*100.2/107.6 if istrtdaty==2019 & istrtdatm==4
replace adjincome = yearlyincome*100.2/107.9 if istrtdaty==2019 & istrtdatm==5
replace adjincome = yearlyincome*100.2/107.9 if istrtdaty==2019 & istrtdatm==6
replace adjincome = yearlyincome*100.2/107.9 if istrtdaty==2019 & istrtdatm==7
replace adjincome = yearlyincome*100.2/108.4 if istrtdaty==2019 & istrtdatm==8
replace adjincome = yearlyincome*100.2/108.5 if istrtdaty==2019 & istrtdatm==9
replace adjincome = yearlyincome*100.2/108.3 if istrtdaty==2019 & istrtdatm==10
replace adjincome = yearlyincome*100.2/108.5 if istrtdaty==2019 & istrtdatm==11
replace adjincome = yearlyincome*100.2/108.5 if istrtdaty==2019 & istrtdatm==12

*generate log income?*
gen logincome = log(yearlyincome)

summarize dvage

gen nage = dvage
replace nage=. if (nage<23)
replace nage=. if (nage>69)

gen nage2=nage^2

summarize nage nage2

tab racel

gen ethnic=.
replace ethnic=1 if(racel==1)
replace ethnic=1 if(racel==2)
replace ethnic=1 if(racel==3)
replace ethnic=1 if(racel==4)
replace ethnic=2 if(racel==5)
replace ethnic=2 if(racel==6)
replace ethnic=2 if(racel==7)
replace ethnic=2 if(racel==8)
replace ethnic=3 if(racel==9)
replace ethnic=4 if(racel==10)
replace ethnic=4 if(racel==11)
replace ethnic=5 if(racel==12)
replace ethnic=6 if(racel==13)
replace ethnic=7 if(racel==14)
replace ethnic=7 if(racel==15)
replace ethnic=7 if(racel==16)
replace ethnic=8 if(racel==17)
replace ethnic=8 if(racel==18)

label define ethnic_lbl 1"White" 2"Mixed/Multiple Ethnic Groups" 3"Indian" 4"Pakistani and Bangladeshi" 5"Chinese" 6"Any other Asian Background" 7"Black/African/Carribean/Black British" 8"Other" 
label values ethnic ethnic_lbl

tab ethnic

tab sex

tab health

gen healthy=.
replace healthy=1 if(health==1)
replace healthy=2 if(health==2)

label define healthy_lbl 1"yes" 2"no"
label values healthy healthy_lbl

tab healthy

tab sf1

gen genhealth=sf1
replace genhealth=. if(genhealth<1)

label define genhealth_lbl 1"excellent" 2"very good" 3"good" 4"fair" 5"poor"
label values genhealth genhealth_lbl

tab genhealth

tab qfhigh_dv

gen hed=.
replace hed=1 if(qfhigh_dv==1)
replace hed=1 if(qfhigh_dv==2)
replace hed=1 if(qfhigh_dv==3)
replace hed=1 if(qfhigh_dv==4)
replace hed=1 if(qfhigh_dv==5)

replace hed=2 if(qfhigh_dv==7)
replace hed=2 if(qfhigh_dv==8)
replace hed=2 if(qfhigh_dv==9)
replace hed=2 if(qfhigh_dv==10)
replace hed=2 if(qfhigh_dv==11)

replace hed=3 if(qfhigh_dv==12)
replace hed=3 if(qfhigh_dv==13)
replace hed=3 if(qfhigh_dv==14)
replace hed=3 if(qfhigh_dv==15)
replace hed=3 if(qfhigh_dv==16)

replace hed=4 if(qfhigh_dv==96)

label define hed_lbl 1"NVQ4+" 2"NVQ3" 3"NVQ1-2" 4"None"
label values hed hed_lbl

tab hed

summarize jbhrs


tab jbes2000 
gen status=.
replace status=1 if (jbes2000==1)
replace status=1 if (jbes2000==2)
replace status=1 if (jbes2000==3)

replace status=2 if (jbes2000==4)
replace status=2 if (jbes2000==5)
replace status=2 if (jbes2000==6)
replace status=2 if (jbes2000==7)

label define status_lbl 1"Self-Employed" 2"Employed"
label values status status_lbl

tab status

gen labhours=.
replace labhours=jbhrs if status==2
replace labhours=jbhrs if status==1
replace labhours=. if (labhours<1)
summarize labhours

tab gor_dv

tab jbsect 

tab jbsectpub

gen sector=.
replace sector=1 if(jbsect==1)
replace sector=1 if(jbsect==2)
replace sector=2 if(jbsectpub>=1 & jbsectpub<=9)


label define sector_lbl 1"private" 2"public" 
label values sector sector_lbl

tab sector


tab jbiindb_dv 

gen industry=jbiindb_dv
replace industry=. if(industry==-9)
replace industry=. if(industry==-1)
replace industry=. if(industry==0)

replace industry=2 if(industry==1)
replace industry=2 if(industry==2)

replace industry=1 if(industry==27)
replace industry=1 if(industry==28)
replace industry=1 if(industry==33)


replace industry=3 if(industry==3)

replace industry=4 if(industry==4)
replace industry=4 if(industry==5)
replace industry=4 if(industry==6)
replace industry=4 if(industry==7)
replace industry=4 if(industry==8)
replace industry=4 if(industry==9)
replace industry=4 if(industry==10)
replace industry=4 if(industry==11)
replace industry=4 if(industry==12)
replace industry=4 if(industry==13)

replace industry=5 if(industry==14)
replace industry=5 if(industry==15)

replace industry=6 if(industry==16)
replace industry=6 if(industry==17)
replace industry=6 if(industry==18)
replace industry=6 if(industry==24)

replace industry=7 if(industry==19)
replace industry=7 if(industry==20)
replace industry=7 if(industry==21)

replace industry=8 if(industry==22)
replace industry=8 if(industry==23)
replace industry=8 if(industry==25)

replace industry=9 if(industry==26)
replace industry=9 if(industry==29)
replace industry=9 if(industry==30)
replace industry=9 if(industry==31)
replace industry=9 if(industry==32)
replace industry=9 if(industry==34)

label define industry_lbl 1"Public Admin, education, and health" 2"Agriculture, forestry, and fishing" 3"Energy and water" 4"Manufacturing" 5"Construction" 6"Distribution, hotels, and restaurants" 7"Transport and Communication" 8"Banking and finance" 9"Other services" 
label values industry industry_lbl

tab industry


tab jbsize 

gen size=jbsize 
replace size=. if(size<1)
replace size=. if(size==10)
replace size=. if(size==11)

replace size=1 if(size<3)
replace size=2 if(size==4)
replace size=3 if(size==5)
replace size=3 if(size==6)
replace size=3 if(size==7)
replace size=4 if(size>7)

replace size=1 if(jssize==1)
replace size=1 if(jssize==2)
replace size=1 if(jssize==3)
replace size=2 if(jssize==4)
replace size=3 if(jssize==5)
replace size=3 if(jssize==6)
replace size=3 if(jssize==7)
replace size=4 if(jssize==9)
replace size=1 if(jssize==10)


label define size_lbl 1"Less than 25" 2"25-49" 3"50-499" 4"500+"
label values size size_lbl

tab size

tab jbsoc00_cc


codebook adjincome yearlyincome nssecdom nage nage2 ethnic sex healthy genhealth hed labhours gor_dv curnssec sector industry size jbsoc00_cc istrtdaty, compact

keep adjincome nssecdom nage nage2 ethnic sex healthy genhealth hed labhours gor_dv curnssec sector industry size jbsoc00_cc yearlyincome istrtdaty
	

*CCA*

misstable summarize adjincome nssecdom nage nage2 ethnic sex healthy genhealth hed labhours gor_dv curnssec sector industry size jbsoc00_cc istrtdaty

misstable patterns adjincome nssecdom nage nage2 ethnic sex healthy genhealth hed labhours gor_dv curnssec sector industry size jbsoc00_cc istrtdaty

*Mobility sankey prior to listwise deletion *


capture drop gh_origin
gen gh_origin = nssecdom 
lab define sankeylabs 1"1.1" 2"1.2" 3"2" 4"3" 5"4" 6"5" 7"6" 8"7"
lab val gh_origin sankeylabs

capture drop gh_dest
gen gh_dest = curnssec
lab val gh_dest sankeylabs

capture drop count_gh 
gen count_gh = !missing(nssecdom)

gen coh=1



sankey count_gh if !missing(gh_dest) ///
	, from(gh_origin) to (gh_dest) by(coh) ///
	gap(8) ///
	smooth(6) ///
	sort1(name, reverse) ///
	labs(2) noval ///
	laba(0) labpos(3) labg(0) offset(5) showtot ///
	ctitles(Origin Destination) ctsize(2.2) ctg(-1000) ///
	palette(d3 20) ///
	title(`"{fontface "Book Antiqua":$gsannkey}"', size(3)) ///
	note(`"{it:{fontface "Book Antiqua":$gnote}}"', size(2.2)) ///
	name(sankey_gh, replace) 
	
	graph save "G:\Stata data and do\Tables and Figures\Class Ceiling\sankeynonnested.gph", replace 

*sector, industry, and soc codes wipe out small employers and own account workers from curnssec*

egen miss1=rmiss(adjincome nssecdom nage nage2 ethnic sex healthy genhealth labhours gor_dv curnssec sector industry size jbsoc00_cc)
tab miss1
keep if miss1==0




* Re-code for most accurate Model (1) *

tab nssecdom

gen classorigin=.
replace classorigin=1 if(nssecdom==1)
replace classorigin=1 if(nssecdom==2)
replace classorigin=1 if(nssecdom==3)

replace classorigin=2 if(nssecdom==4)
replace classorigin=2 if(nssecdom==5)
replace classorigin=2 if(nssecdom==6)

replace classorigin=3 if(nssecdom==7)
replace classorigin=3 if(nssecdom==8)

label define classorigin_lbl 1"Professional" 2"Intermediate" 3"Working Class"
label values classorigin classorigin_lbl

tab classorigin

tab ethnic 

tab sex

tab healthy

tab hed

summarize labhours

tab gor_dv

tab curnssec

gen nsseccat=.
replace nsseccat=1 if(curnssec==1)
replace nsseccat=1 if(curnssec==2)

replace nsseccat=2 if(curnssec==3)

replace nsseccat=3 if(curnssec==4)
replace nsseccat=3 if(curnssec==5)
replace nsseccat=3 if(curnssec==6)
replace nsseccat=3 if(curnssec==7)
replace nsseccat=3 if(curnssec==8)

label define nsseccat_lbl 1"Higher Managerial & Professional" 2"Lower Managers & Professionals" 3"Any Other Category"
label values nsseccat nsseccat_lbl
tab nsseccat

tab industry

tab size



codebook adjincome nssecdom nage nage2 ethnic sex healthy genhealth hed labhours gor_dv curnssec sector industry size jbsoc00_cc, compact

label variable yearlyincome "Yearly Labour Income"
label variable adjincome "Yearly Labour Income Adjusted for 2016 Inflation"
label variable nssecdom "Semi-Dominant NS-SEC Social Origins"
label variable nage "Age"
label variable nage2 "Age Squared"
label variable ethnic "Ethnicity"
label variable sex "Sex"
label variable healthy "Serious Health Issue"
label variable genhealth "General Health"
label variable hed "Highest Educational Qualification"
label variable labhours "Weekly Labour Hours"
label variable gor_dv "Governmental Regions"
label variable curnssec "NS-SEC Current Job"
label variable sector "Public or Private Sector"
label variable industry "Industry of Labour"
label variable size "Number of Employees at Work"





*descriptive statistics*
cd "G:\Stata data and do\Tables and Figures\Class Ceiling"

table (var) (), statistic(fvfrequency classorigin ethnic sex healthy genhealth hed gor_dv nsseccat sector industry size) ///
					statistic(fvpercent classorigin ethnic sex healthy genhealth hed gor_dv nsseccat sector industry size) ///
					statistic(mean adjincome nage nage2 labhours) ///  
					statistic(sd adjincome nage nage2 labhours) 
					
* Organise the column structure of the table			
collect remap result[fvfrequency mean] = Col[1 1] 
collect remap result[fvpercent sd] = Col[2 2]
* Name the stored results for Mean and SD in the collection
collect get resname = "Mean", tag(Col[1] var[mylabel]) 
collect get resname = "SD", tag(Col[2] var[mylabel])
* collect an empty result to create a blank row in the table. 
collect get empty = "  ", tag(Col[1] var[empty]) 
collect get empty = "  ", tag(Col[2] var[empty])
* collect the sample size from the 'count' command.
count
collect get n = `r(N)', tag(Col[2] var[n])
* specify the order of the contents of our table.
collect layout (var[1.classorigin 2.classorigin 3.classorigin ///
						1.ethnic 2.ethnic 3.ethnic 4.ethnic 5.ethnic 6.ethnic 7.ethnic 8.ethnic ///
						1.sex 2.sex ///
						1.healthy 2.healthy ///
						1.genhealth 2.genhealth 3.genhealth 4.genhealth 5.genhealth ///
						1.hed 2.hed 3.hed 4.hed ///
						1.gor_dv 2.gor_dv 3.gor_dv 4.gor_dv 5.gor_dv 6.gor_dv 7.gor_dv 8.gor_dv 9.gor_dv 10.gor_dv 11.gor_dv 12.gor_dv ///
						1.nsseccat 2.nsseccat 3.nsseccat ///
						1.sector 2.sector ///
						1.industry 2.industry 3.industry 4.industry 5.industry 6.industry 7.industry 8.industry 9.industry ///
						1.size 2.size 3.size 4.size ////
						empty mylabel ///
						adjincome nage nage2 labhours ///
						empty n]) (Col[1 2])
* label the columns for the categorical variable (n and %).
collect label levels Col 1 "n" 2 "%"
* drop the title column
collect style header Col, title(hide)
* hide the variable names for the empty row
collect style header var[empty mylabel], level(hide)
collect style row stack, nobinder
* edit the numerical formats of the numbers shown (i.e. number of decimal places).
collect style cell var[classorigin ethnic sex healthy genhealth hed gor_dv nsseccat sector industry size jbsoc00_cc]#Col[1], nformat(%6.0fc) 
collect style cell var[classorigin ethnic sex healthy genhealth hed gor_dv nsseccat sector industry size jbsoc00_cc]#Col[2], nformat(%6.2f) sformat("%s%%") 	
collect style cell var[adjincome nage nage2 labhours], nformat(%6.2f)
* remove border above row-header and results 
collect style cell border_block[item row-header], border(top, pattern(nil))
* add a title to the table
collect title "Table 1: Descriptive Statistics"
* add a note to the table	
collect note "Source: BHPS, adults in work in Wave A (1991)" 
* Let's take a look at the table now... 
collect preview
* export your finished table to Word
collect export "ccdescstats.docx", replace	


*data vis*

*sankey diagram*


*mobility sankey better version*

capture drop gh_origin
gen gh_origin = nssecdom 
lab define sankeylabs1 1"1.1" 2"1.2" 3"2" 4"3" 5"4" 6"5" 7"6" 8"7"
lab val gh_origin sankeylabs1

capture drop gh_dest
gen gh_dest = curnssec
lab val gh_dest sankeylabs1

capture drop count_gh 
gen count_gh = !missing(nssecdom)

gen coh1=1



sankey count_gh if !missing(gh_dest) ///
	, from(gh_origin) to (gh_dest) by(coh1) ///
	gap(8) ///
	smooth(6) ///
	sort1(name, reverse) ///
	labs(2) noval ///
	laba(0) labpos(3) labg(0) offset(5) showtot ///
	ctitles(Origin Destination) ctsize(2.2) ctg(-1000) ///
	palette(d3 20) ///
	title(`"{fontface "Book Antiqua":$gsannkey}"', size(3)) ///
	note(`"{it:{fontface "Book Antiqua":$gnote}}"', size(2.2)) ///
	name(sankey_gh, replace) 
	
	graph save "G:\Stata data and do\Tables and Figures\Class Ceiling\sankey.gph", replace 

*Hist Example*

separate adjincome, by(sex) gen(revsex)	
tab1 revsex* /* revsex1 = male */ 
			   /* revsex2 = female */

		twoway ///
	(hist revsex1, percent color(purple%25) bin(30) ///
		legend(label(1 "{stSerif:Male}"))) ///
	(hist revsex2, percent color(orange%25) bin(30)  ///
		legend(label(2 "{stSerif:Female}") pos(6) col(2)) ///
		title("{stSerif:Graph 1. Adjusted Annual Labour Income of {bf:Male} and{bf: Female} respondents}", ///
		size(med)) ///
		ytitle("{stSerif:Percent}", size(vsmall)) ///
		xtitle("{stSerif:Yearly Income £s (Adjusted for 2016 Inflation)}", size(vsmall)) ///
		note(`"{it:{fontface "Times New Roman":$gnote}}"', size(small) pos(6)))
	
graph save "G:\Stata data and do\Tables and Figures\Class Ceiling\sexincome.gph", replace 
	
	
seperate adjincome, by(curnssec) gen(revclass)
tab1 revclass*

		twoway ///
	(hist revclass1, percent color(dkgreen%25) bin(30) ///
		legend(label(1 "{stSerif:1.1}"))) ///
	(hist revclass2, percent color(orange_red%25) bin(30)  ///
		legend(label(2 "{stSerif:1.2}"))) ///
	(hist revclass3, percent color(navy%25) bin(30) ///
		legend(label(3 "{stSerif:2}"))) ///
	(hist revclass4, percent color(maroon%25) bin(30) ///
		legend(label(4 "{stSerif:3}"))) ///
	(hist revclass6, percent color(magenta%25) bin(30) ///
		legend(label(6 "{stSerif:5}"))) ///
	(hist revclass7, percent color(cyan%25) bin(30) ///
		legend(label(7 "{stSerif:6}"))) ///
	(hist revclass8, percent color(lime%25) bin(30) ///
		legend(label(8 "{stSerif:7}") pos(6) col(7)) ///
		title("{stSerif:Graph 2. Adjusted Annual Labour Income of {bf:Current NS-SEC} respondents}", size(med)) ///
		ytitle("{stSerif:Percent}", size(vsmall)) ///
		xtitle("{stSerif:Yearly Income £s (Adjusted for 2016 Inflation)}", size(vsmall)) ///
		note(`"{it:{fontface "Times New Roman":$gnote}}"', size(vsmall) pos(6)))
		
graph save "G:\Stata data and do\Tables and Figures\Class Ceiling\classincome.gph", replace 
	
	
*model*

regress adjincome i.classorigin i.istrtdaty
est store modelone
etable

regress adjincome i.classorigin i.istrtdaty nage nage2 i.ethnic i.sex i.healthy 
est store modeltwo
etable, append

regress adjincome i.classorigin i.istrtdaty nage nage2 i.ethnic i.sex i.healthy i.hed
est store modelthree
etable, append

regress adjincome i.classorigin i.istrtdaty nage nage2 i.ethnic i.sex i.healthy i.hed labhours
est store modelfour
etable, append

regress adjincome i.classorigin i.istrtdaty nage nage2 i.ethnic i.sex i.healthy i.hed labhours ib(8).gor_dv 
est store modelfive
etable, append

regress adjincome i.classorigin i.istrtdaty nage nage2 i.ethnic i.sex i.healthy i.hed labhours ib(8).gor_dv i.nsseccat i.sector i.industry ib(4).size i.jbsoc00_cc
est store modelsix
etable, append

est table modelone modeltwo modelthree modelfour modelfive modelsix

collect style showbase all

collect label levels etable_depvar 1 "Model One" ///
								   2 "Model Two" ///
								   3 "Model Three" ///
								   4 "Model Four" ///
								   5 "Model Five" ///
								   6 "Model Six", modify

collect style cell, font(Times New Roman)

etable, replay column(depvar) ///
cstat(_r_b, nformat(%4.2f))  ///
		cstat(_r_se, nformat(%6.2f))  ///
		showstars showstarsnote  ///
		stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
		mstat(N) mstat(aic) mstat(bic) mstat(r2_a)	///
		title("Table 1: Regression Model") ///
		titlestyles(font(Arial Narrow, size(14) bold)) ///
		note("Data Source: UKHLS Wave 1-12") ///
		notestyles(font(Arial Narrow, size(10) italic)) ///
		export("classceilingregression.docx", replace)  



* the oaxaca that the class ceiling use requires a dummy for all cat varaibles. They use a working class/privileged origin dependent variable. The former is defined through ns-sec 6+7 from the 8 class version and the latter is from 1+2*

gen oax=.
replace oax=0 if(nssecdom==1)
replace oax=0 if(nssecdom==2)
replace oax=0 if(nssecdom==3)


replace oax=1 if(nssecdom==7)
replace oax=1 if(nssecdom==8)



oaxaca adjincome nage, by(oax)







regress adjincome i.nssecdom nage nage2 i.ethnic i.sex i.healthy i.genhealth i.hed labhours ib(8).a_gor_dv i.curnssec i.sector i.industry ib(4).size i.a_jbsoc00_cc

est store linearadj

capture drop pr_inc
predict pr_inc

global scatteroptions "mcolor(%15) msize(tiny)"

twoway  ///
	(scatter adjincome nage, $scatteroptions ) ///
	(scatter pr_inc nage, $scatteroptions )
	
	
*Model assumptions*

predict resids, resid
sum resid
hist resids, normal

qnorm resids

scatter resids nage, $scatteroptions

scatter resids a_gor_dv, $scatteroptions
































/// This will be a seperate Paper ///
* seeing if a random effects model is needed?*
mixed yearlyincome i.nssecdom nage nage2 i.ethnic i.sex i.healthy i.genhealth i.hed labhours i.curnssec i.sector i.industry i.size ///
    ||a_gor_dv:, mle
	
	estat icc
	*not really needed, linear regression better*
	
mixed yearlyincome i.nssecdom nage nage2 i.ethnic i.sex i.healthy i.genhealth i.hed labhours i.curnssec i.sector i.industry i.size ///
    ||a_jbsoc00_cc:, mle

		estat icc
		*soc random does seem needed*
	


mixed yearlyincome i.nssecdom nage nage2 i.ethnic i.sex i.healthy i.genhealth i.hed labhours i.curnssec i.sector i.industry i.size ///
    ||_all:R.a_jbsoc00_cc ///
    ||_all:R.a_gor_dv, mle
	
