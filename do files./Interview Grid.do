/*
********************************************************************************
INTERVIEW GRID.DO
	
	THIS FILE CREATES A DATASET OF VARIABLES (BIRTH DATES, INTERVIEW DATES) WHICH
	ARE USED FREQUENTLY TO CONSTRUCT WORKING-LIFE HISTORIES.
	
********************************************************************************
*/

/*
1. Dataset Preparation.
*/
/**/
	*i. Bring in interview dates, interview type from indresp files.
		*Feed these forward and backwards best on next and last interviews.
		*Replace missing values with .m (missing) or .i (inapplicable).
		/// BHPS Wave 1 interviews all took place in 1991 and no interview date variable is available for this wave.
* A. COLLECT VARIABLES FROM INDRESP FILES RELATED TO:
global vlist 	istrtdatm istrtdaty jbft ivfio intdatm_dv ///
				intdaty_dv jbft_dv ///
				pasoc10_cc panssec8_dv masoc10_cc manssec8_dv jbnssec8_dv jbsoc10_cc fimnlabgrs_dv dvage birthy sex racel plbornc ///
				qfhigh_dv health sf1 gor_dv jbiindb_dv jbsect jbsectpub jbsize jbft_dv jssize scdoby4 jbhrs jbes2000 jshrs jbsoc00_cc
local k=0
forval i=1/$max_waves{
	local j: word `i' of `c(alpha)'
	if `i'<=$ukhls_waves{
		prog_getvars vlist `j' "${fld}/${ukhls_path}_w`i'/`j'_indresp${file_type}"		// prog_getvars adds wave specfic stubs to names in global vlist and then searches for these variables in relevent data file
		rename `j'_* *
		gen Wave=`i'+18		// UKHLS set as Wave>=19
		local k=`k'+1
		tempfile Temp`k'
		save "`Temp`k''", replace
		}
	if `i'<=$bhps_waves{
		prog_getvars vlist b`j' "${fld}/${bhps_path}_w`i'/b`j'_indresp${file_type}"
		rename b`j'_* *
		gen Wave=`i'
		local k=`k'+1
		tempfile Temp`k'
		save "`Temp`k''", replace
		}
	}
forval i=`=`k'-1'(-1)1{
	append using "`Temp`i''"
	}
	
* B. COLLECT BIRTH DATES AND HOUSEHOLD IDs FROM CROSS-WAVE FILES.	
merge m:1 pidp using "${fld}/${bhps_path}_wx/xwaveid_bh${file_type}", /*
	*/ keepusing(birth*) keep(match master) nogenerate
merge m:1 pidp using "${fld}/${ukhls_path}_wx/xwavedat${file_type}", /*
	*/ keepusing(dob*) keep(match master) nogenerate	
preserve
	use pidp *hidp using "${fld}/${ukhls_path}_wx/xwaveid${file_type}", clear
	merge 1:1 pidp using "${fld}/${bhps_path}_wx/xwaveid_bh${file_type}", /*
		*/ keepusing(*hidp) nogenerate
	forval i=1/$max_waves{
		local j=word("`c(alpha)'",`i')
		if `i'<=$bhps_waves{
			rename b`j'_hidp hidp`i'
			}
		if `i'<=$ukhls_waves{
			rename `j'_hidp hidp`=`i'+18'
			}
		}
	reshape long hidp, i(pidp) j(Wave)
	drop if hidp<0
	tempfile Temp
	save "`Temp'", replace
restore
merge 1:1 pidp Wave using "`Temp'", keep(match master) nogenerate

* C. CLEAN DATASET
	* i. REPLACE NEGATIVE VALUES WITH STATA . MISSING VALUES (prog_recodemissing)
order pidp Wave
prog_recodemissing *

	* ii. GET BIRTH DATES. IF MONTH OF BIRTH MISSING (AS IN NORMAL EUL DATASET, SET BIRTH MONTH TO 6)
capture confirm variable dobm_dv birthm
if _rc==0{
	gen Birth_M=cond(!missing(dobm_dv),dobm_dv,birthm)
	replace Birth_M=.m if missing(Birth_M)
	}
else{
	gen Birth_M=6
	}
gen Birth_Y=cond(!missing(doby_dv),doby_dv,birthy)
replace Birth_Y=.m if missing(Birth_Y)
replace Birth_M=6 if missing(Birth_M) & !missing(Birth_Y)
gen Birth_S=floor(Birth_M/3)+1
gen Birth_MY=ym(Birth_Y,Birth_M)
gen Birth_SY=ym(Birth_Y,Birth_S)
drop dob* birth*


save "${dta_fld}/Interview Grid", replace
*/
	
