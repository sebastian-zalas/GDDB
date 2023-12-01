/******************************************************************************/
/*	 						Person level dataset 							  */
/******************************************************************************/

*** managers making persol-level dataset ***
clear

frame change default
capture frame drop tempframe

global countries  "ALBANIA AUSTRIA BELGIUM BELARUS CROATIA CYPRUS BOSNIA BULGARIA CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA PORTUGAL SPAIN SPAIN SWEDEN SWITZERLAND TURKEY UKRAINE UK"

foreach cntry of global countries {
	di "---------- `cntry' ----------------------------------------------------"
	
	// 1. prepare data -------------------------------------------------------//
	use "$gender_path\managers_gender_`cntry'.dta"
	
	//capture keep bvdidnumber bvdaccountnumber country fullname managerfunction legalform lastyear numberofyears sup_shouldhave source gender_ama titlesinceyear title salutation suffix confirmationdates confiramtiondatemin confiramtiondatemax titleiedrlord is_current year_appointment year_resignation year_lastips year_notvalidafter min_years max_years start end supboard_old senmen_old csuite_old senmen_new supboard_new csuite_new csuite_new_min prepared_name firm gender uciuniquecontactidentifier middlename firm 
	
	capture destring lastyear, replace
	
	// merge lastyear 2020 - temporaray section
	/*
	merge n:1 country bvdidnumber using "K:\Sebastian Zalas\FromHubert\_lastyear.dta"
	drop if _merge == 2
	replace lastyear = lastyear_2020 if source == 2020
	drop lastyear_2020 firstyear_2020

	// to be corrected
	capture ren confiramtiondatemin confirmationdatemin 
	capture ren confiramtiondatemax confirmationdatemax
	*/
	//
	capture gen confirmationdatemin = min_years 
	capture gen confirmationdatemax = max_years
	
	capture replace confirmationdatemin = min_years if !missing(min_years) & (missing(confirmationdatemin) | min_years < confirmationdatemin)
	capture replace confirmationdatemax = max_years if !missing(max_years) & (missing(confirmationdatemax) | max_years > confirmationdatemax)
	
	egen is_lastyear = max(lastyear) , by(bvdidnumber) // idic. if we have any info on time for firm in any wave
	drop if (sup_shouldhave == . | sup_shouldhave <1 )
	drop if firm == 1 
//	keep if (gender == 0 | gender == 1) 
	
	// clean name for recognition
	capture replace title = titleiedrlord if source == 2020
	capture drop unifying_name
	gen unifying_name = fullname
	replace unifying_name = subinstr(unifying_name, title, "", .)
	replace unifying_name = subinstr(unifying_name, salutation, "", .)
	replace unifying_name = ustrupper(unifying_name)
	
	replace unifying_name = subinstr(unifying_name, "Ü", "UE", .)
	replace unifying_name = subinstr(unifying_name, "Ä", "AE", .)
	replace unifying_name = subinstr(unifying_name, "Ö", "OE", .)
	replace unifying_name = subinstr(unifying_name, "Ø", "OE", .)
	replace unifying_name = subinstr(unifying_name, "Å", "AA", .)
	
	// clean diacrytics
	{
	replace unifying_name = subinstr(unifying_name, "À", "A", .)
	replace unifying_name = subinstr(unifying_name, "Á", "A", .)
	replace unifying_name = subinstr(unifying_name, "Â", "A", .)
	replace unifying_name = subinstr(unifying_name, "Ã", "A", .)
	replace unifying_name = subinstr(unifying_name, "Ä", "A", .)
	replace unifying_name = subinstr(unifying_name, "Å", "A", .)
	replace unifying_name = subinstr(unifying_name, "Æ", "AE", .) //
	replace unifying_name = subinstr(unifying_name, "Ç", "C", .)
	replace unifying_name = subinstr(unifying_name, "È", "E", .)
	replace unifying_name = subinstr(unifying_name, "É", "E", .)
	replace unifying_name = subinstr(unifying_name, "Ê", "E", .)
	replace unifying_name = subinstr(unifying_name, "Ë", "E", .)
	replace unifying_name = subinstr(unifying_name, "Ì", "I", .)
	replace unifying_name = subinstr(unifying_name, "Í", "I", .)
	replace unifying_name = subinstr(unifying_name, "Î", "I", .)
	replace unifying_name = subinstr(unifying_name, "Ï", "I", .)
	//replace unifying_name = subinstr(unifying_name, "Ð", "ETH", .) //
	replace unifying_name = subinstr(unifying_name, "Ñ", "N", .)
	replace unifying_name = subinstr(unifying_name, "Ò", "O", .)
	replace unifying_name = subinstr(unifying_name, "Ó", "O", .)
	replace unifying_name = subinstr(unifying_name, "Ô", "O", .)
	replace unifying_name = subinstr(unifying_name, "Õ", "O", .)
	replace unifying_name = subinstr(unifying_name, "Ö", "O", .)
	replace unifying_name = subinstr(unifying_name, "Ø", "O", .)
	replace unifying_name = subinstr(unifying_name, "Ù", "U", .)
	replace unifying_name = subinstr(unifying_name, "Ú", "U", .)
	replace unifying_name = subinstr(unifying_name, "Û", "U", .)
	replace unifying_name = subinstr(unifying_name, "Ü", "U", .)
	replace unifying_name = subinstr(unifying_name, "Ý", "Y", .)
	//replace unifying_name = subinstr(unifying_name, "Þ", "THORN", .) //
	replace unifying_name = subinstr(unifying_name, "Ā", "A", .)
	replace unifying_name = subinstr(unifying_name, "Ă", "A", .)
	replace unifying_name = subinstr(unifying_name, "Ą", "A", .)
	replace unifying_name = subinstr(unifying_name, "Ć", "C", .)
	replace unifying_name = subinstr(unifying_name, "Ĉ", "C", .)
	replace unifying_name = subinstr(unifying_name, "Ċ", "C", .)
	replace unifying_name = subinstr(unifying_name, "Č", "C", .)
	replace unifying_name = subinstr(unifying_name, "Ď", "D", .)
	replace unifying_name = subinstr(unifying_name, "Đ", "D", .)
	replace unifying_name = subinstr(unifying_name, "Ē", "E", .)
	replace unifying_name = subinstr(unifying_name, "Ė", "E", .)
	replace unifying_name = subinstr(unifying_name, "Ę", "E", .)
	replace unifying_name = subinstr(unifying_name, "Ě", "E", .)
	replace unifying_name = subinstr(unifying_name, "Ğ", "G", .)
	replace unifying_name = subinstr(unifying_name, "Ģ", "G", .)
	replace unifying_name = subinstr(unifying_name, "Ī", "I", .)
	replace unifying_name = subinstr(unifying_name, "İ", "I", .)
	replace unifying_name = subinstr(unifying_name, "Ķ", "K", .)
	replace unifying_name = subinstr(unifying_name, "Ĺ", "L", .)
	replace unifying_name = subinstr(unifying_name, "Ļ", "L", .)
	replace unifying_name = subinstr(unifying_name, "Ľ", "L", .)
	replace unifying_name = subinstr(unifying_name, "Ń", "N", .)
	replace unifying_name = subinstr(unifying_name, "Ņ", "N", .)
	replace unifying_name = subinstr(unifying_name, "Ň", "N", .)
	replace unifying_name = subinstr(unifying_name, "Ō", "O", .)
	replace unifying_name = subinstr(unifying_name, "Ő", "O", .)
	replace unifying_name = subinstr(unifying_name, "Œ", "OE", .) //
	replace unifying_name = subinstr(unifying_name, "Ŕ", "R", .)
	replace unifying_name = subinstr(unifying_name, "Ř", "R", .)
	replace unifying_name = subinstr(unifying_name, "Ś", "S", .)
	replace unifying_name = subinstr(unifying_name, "Ş", "S", .)
	replace unifying_name = subinstr( unifying_name, "Š", "S", .)
	replace unifying_name = subinstr(unifying_name, "Ţ", "T", .)
	replace unifying_name = subinstr(unifying_name, "Ť", "T", .)
	replace unifying_name = subinstr(unifying_name, "Ũ", "U", .)
	replace unifying_name = subinstr(unifying_name, "Ū", "U", .)
	replace unifying_name = subinstr(unifying_name, "Ů", "U", .)
	replace unifying_name = subinstr(unifying_name, "Ű", "U", .)
	replace unifying_name = subinstr(unifying_name, "Ÿ", "Y", .)
	replace unifying_name = subinstr(unifying_name, "Ź", "Z", .)
	replace unifying_name = subinstr(unifying_name, "Ż", "Z", .)
	replace unifying_name = subinstr(unifying_name, "Ž", "Z", .)
	replace unifying_name = subinstr(unifying_name, "Ǣ", "AE", .) //
	replace unifying_name = subinstr(unifying_name, "Ȅ", "E", .)
	replace unifying_name = subinstr(unifying_name, "Ȍ", "O", .)
	replace unifying_name = subinstr(unifying_name, "Ș", "S", .)
	replace unifying_name = subinstr(unifying_name, "Ț", "T", .)
	}
	replace unifying_name = subinstr(unifying_name, "-", " ", .)
	replace unifying_name = strtrim(unifying_name)
	replace unifying_name = stritrim(unifying_name)
	

	
	// 2. recognize same people from different waves -------------------------//
	// prepapre id numbers
	egen id_firm = group(bvdidnumber)
	egen id_uname = group(unifying_name)
	
	// any changes in uci within one id_uname?
	bys id_firm id_uname uciuniquecontactidentifier :  gen d_uci_w_id = _n - 1
	replace d_uci_w_id = . if uciuniquecontactidentifier == ""
	duplicates tag id_firm id_uname if d_uci_w_id == 0 , gen(tag)
	capture drop uci_not_applicable*
	gen uci_not_applicable = .
	replace uci_not_applicable = 1 if tag > 0 & uciuniquecontactidentifier != "" & tag != .
	egen uci_not_applicable1 = max(uci_not_applicable) , by(id_firm id_uname)
	drop uci_not_applicable tag d_uci_w_id
	ren uci_not_applicable1 uci_not_applicable
	
	// any changes in id_uname within one uciuniquecontactidentifier? 
	bys id_firm uciuniquecontactidentifier id_uname:  gen d_id_w_uci = _n - 1
	replace d_id_w_uci = . if uciuniquecontactidentifier == ""
	duplicates tag id_firm uciuniquecontactidentifier if d_id_w_uci == 0 , gen(tag)
	capture drop uci_applicable*
	gen uci_applicable = .
	replace uci_applicable = 1 if tag > 0 & uciuniquecontactidentifier != "" & tag != .
	egen uci_applicable1 = max(uci_applicable) , by(id_firm uciuniquecontactidentifier)
	drop uci_applicable tag d_id_w_uci
	ren uci_applicable1 uci_applicable
	egen uci_applicable1 = max(uci_applicable) , by(id_firm id_uname)
	
	// sign obs having uci, when applicable
	gen is_uci = .
	replace is_uci = 1 if uciuniquecontactidentifier != "" & uci_applicable1 == 1
	
	// sign id_unames having somewhere uci, when applicable
	egen is_uci1 = max(is_uci) , by(id_uname)
	
	// distibute uciuniquecontactidentifier among id_uname, when applicable
	gen uci_distributed = ""
	replace uci_distributed = uciuniquecontactidentifier if is_uci1 == 1
	replace uci_distributed = subinstr(uci_distributed, "P", "", .)
	destring uci_distributed, replace force
	egen uci_distributed1 = max(uci_distributed) , by(id_firm id_uname)
	recast long uci_distributed1
	egen id_name_corrected = max(id_uname) , by(id_firm uci_distributed1)
	replace id_name_corrected = . if uci_distributed1 == .
	replace id_name_corrected = id_uname if id_name_corrected == .
	
	
	// gender unficiation in time - 28.09.2023 -------------------------------//
	gen gendertemp = gender
	replace gendertemp = 2 if !inlist(gendertemp, 0, 1, 2)
	cap drop temp
	forvalues i = 0(1)2 {
	    gen temp = `i' if gendertemp == `i'
		egen gender`i' = max(temp) , by(id_firm id_name_corrected)
		cap drop temp
	}

	replace gender = 0 if gender0==0 & gender1==. & gender2==2
	replace gender = 1 if gender0==. & gender1==1 & gender2==2
	
	drop gender0 gender1 gender2 gendertemp
	/*
	bys id_firm id_name_corrected : gen duplosind = _n
	count if duplosind == 1
	
	count if duplosind == 1 & gender0==0 & gender1==. & gender2==.
	local n1 = `r(N)'
	
	count if duplosind == 1 & gender0==. & gender1==1 & gender2==.
	local n2 = `r(N)'
	
	count if duplosind == 1 & gender0==. & gender1==. & gender2==2
	local n3 = `r(N)'
	
	
	count if duplosind == 1 & gender0==0 & gender1==. & gender2==2
	local n4 = `r(N)'
	
	count if duplosind == 1 & gender0==. & gender1==1 & gender2==2
	local n5 = `r(N)'
	
	count if duplosind == 1 & gender0==0 & gender1==1 
	local n6 = `r(N)'
	
	local nall = `n1' + `n2' + `n3' + `n4' + `n5' + `n6'
	di "`nall'"
	*/
	// -----------------------------------------------------------------------//
	
	// 3. combine time information from all waves for unique obs -------------//

	// assign time for each row observation (i.e. without identifying unique person)
	capture drop start 
	capture drop end
	gen start = . 
	gen end = .
	replace lastyear = . if lastyear == 0
	capture gen titlesinceyear=.
	replace titlesinceyear = . if titlesinceyear > 2008

	replace start =  year_appointment	
	
	replace end =  year_resignation
	replace end =  year_notvalidafter if missing(end)
	
	replace start =  titlesinceyear if missing(start) & !missing(titlesinceyear) 				& (titlesinceyear <= year_notvalidafter & titlesinceyear<= year_resignation)
	replace start =  confirmationdatemin if missing(start) & !missing(confirmationdatemin) 		& (confirmationdatemin <= year_notvalidafter & confirmationdatemin <= year_resignation) // some people have confirmation date after they have oficially resigned (annalogous case for the starts below)
	replace start =  lastyear if missing(start) & (is_current == 1 | source <= 2016)   			& (lastyear <= year_notvalidafter & lastyear<= year_resignation)
			
	replace end =  confirmationdatemax if missing(end) 
	replace end =  lastyear if missing(end) & !missing(lastyear) & (is_current == 1 | source <= 2016) & (lastyear>=year_appointment & !missing(year_appointment))
	replace end =  lastyear if missing(end) & !missing(lastyear) & year_appointment>=2016 & lastyear>=year_appointment  & !missing(year_appointment) 
	
	replace end =  start if missing(end)  // at least have a year
	
	replace start =  end if missing(start)  // at least have a year
	
	replace end = year_appointment if end<year_appointment & !missing(year_appointment) // some people have confiramtiondate before their appointment within the position
	
	// assign time for each unique person, and for each board category
	foreach brd in supboard boards senmen person{ 
		capture drop start_`brd' end_`brd' dup_`brd'		
		bysort id_name_corrected id_firm `brd' :  egen start_`brd' = min(start)		
		bysort id_name_corrected id_firm `brd' :  egen end_`brd' = max(end)
		bysort id_name_corrected id_firm `brd' :  gen dup_`brd' = _n
		replace start_`brd' = . if `brd' != 1
		replace end_`brd' = . if `brd' != 1
		replace dup_`brd' = . if `brd' != 1						
	}	

	foreach brd in supboard boards senmen person{
	    foreach start in year_appointment{
		    bysort id_name_corrected id_firm `brd' :  egen start_`start'_`brd' = min(`start')					
			replace start_`start'_`brd' = . if `brd' != 1			
		}
		
		foreach end in year_resignation{
			bysort id_name_corrected id_firm `brd' :  egen end_`end'_`brd' = max(`end')
			replace end_`end'_`brd' = . if `brd' != 1		    
		}				
	}

	// -- prepare data in long (firm - person - year - board info - country) -//
	// keep only necessary variables
	keep bvdidnumber id_firm id_name_corrected unifying_name country sup_shouldhave gender start_* end_* dup_*	
	
	// keep unique people by board category
	keep if (dup_supboard == 1 | dup_senmen == 1 | dup_boards==1  | dup_person==1)
	
	// 26.09.2023 -------------------------------------------------------------
	drop dup_*
	foreach brd in  supboard senmen  boards  person{ 
		foreach j in start end { 
		    gen temp = `j'_`brd' 
			drop `j'_`brd'
			egen `j'_`brd' = max(temp) , by(id_firm id_name_corrected)
		    drop temp
		}
	}	    
	
	******* DOING THE TIME INDICATORS BELOW ***********
	foreach brd in supboard senmen boards person{ 	
		   foreach j in year_appointment{
				gen temp = start_`j'_`brd' 
				drop start_`j'_`brd'
				egen start_`j'_`brd' = max(temp) , by(id_firm id_name_corrected)
				drop temp
			}
			
		    foreach j in year_resignation{
				gen temp = end_`j'_`brd' 
				drop end_`j'_`brd'
				egen end_`j'_`brd' = max(temp) , by(id_firm id_name_corrected)
				drop temp
			}		    
		}
		    	
	//-------------------------------------------------------------------------
	bys id_firm id_name_corrected : gen duplos_obs = _n
		
	// keep unique people
	keep if duplos_obs == 1

	// save the person dataset for bias checks
	save "$documentation_path\_gender_bias_check\bias_person_level_`cntry'.dta", replace


	summarize start_person
		if `r(min)' >=1985 {
			local min_start=`r(min)'
		}
		else{
			local min_start=1985
		}

	// create folder if not exists
	capture mkdir "$person_level_path\_`cntry'"
	

	forvalues year = `min_start'(1)2020 {
		di "--- `cntry': `year' -----------------------------------------------"
		foreach i in senmen supboard boards person {
		    capture drop `i'
		}
		
		foreach word in supboard senmen boards person{	 
			gen `word' = 0
			replace `word' = 1 if `year' >= start_`word' & `year' <= end_`word'
		}
		
		frame put bvdidnumber country sup_shouldhave gender id_firm id_name_corrected senmen supboard boards person if (supboard == 1 | senmen == 1 | boards==1 | person==1), into(tempframe)
		frame change tempframe 
		gen year = `year'
		compress
		save "$person_level_path\_`cntry'\managers_personlvl_`cntry'_`year'.dta" , replace
		frame change default
		frame drop tempframe
	}
	clear
	
	// 4. append year files to country file
	global files: dir "$person_level_path\_`cntry'" file "managers_personlvl_`cntry'_*.dta"
	cd "$person_level_path\_`cntry'"
	foreach file of global files {
		append using `file' , force
	}
	compress
	
	gen ambg=0
	gen nofunction=0
	
	replace ambg=1 if boards==1 & senmen==0 & supboard==0
	replace nofunction=1 if person==1 & boards==0
	
	save "$person_level_path\managers_personlvl_`cntry'.dta", replace

	clear
}

