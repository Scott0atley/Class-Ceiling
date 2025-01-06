
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
