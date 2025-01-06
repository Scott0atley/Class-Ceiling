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
				hiqual_dv health sf1 gor_dv jbiindb_dv jbsect jbsectpub jbsize jbft_dv jssize scdoby4 jbhrs jbes2000 jshrs jbsoc00_cc nqfede
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
	

* C. CLEAN DATASET
	* i. REPLACE NEGATIVE VALUES WITH STATA . MISSING VALUES (prog_recodemissing)
order pidp Wave
prog_recodemissing *




save "${dta_fld}/Interview Grid", replace
*/
	
