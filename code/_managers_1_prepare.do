/******************************************************************************/
/*	 					Managers data - preparation							  */
/******************************************************************************/
clear

// waves
global waves "2002 2003 2004 2006 2008 2010 2014 2016 2020"

foreach wave of global waves {
	
	// 2002
	if `wave' == 2002 {
		di "*** `wave' ***"
		clear
		
		// load data
		use bvdidnumber bvdaccountnumber country managername managerfunction using "$originaldta_path\2002 December\management.dta"
		merge m:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2002 December\header.dta", keepusing(lastyear) nogenerate

		// unify countries' names
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		// save
		compress
		save "$preparation_path\managers_2002.dta", replace
	}
	
	// 2003
	if `wave' == 2003 {
		di "*** `wave' ***"
		clear
		
		//load data
		use bvdidnumber bvdaccountnumber country managerfirstname managerlastname managerfullname managerfunction using "$originaldta_path\2003 December\activitiesandmanagement.dta"
		merge m:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2003 December\header.dta", keepusing(legalform lastyear) nogenerate
		
		//
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"
		replace country = "SERBIA" if country == "SERBIA AND MONTENEGRO" 
		
		// save
		compress
		save "$preparation_path\managers_2003.dta", replace
	}

	// 2004
	if `wave' == 2004 {
		di "*** `wave' ***"
		clear
		
		// load data
		use bvdidnumber bvdaccountnumber country managerfullname managerfunction using "$originaldta_path\2004 June\activitiesandmanagement.dta"
		merge m:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2004 June\header.dta", keepusing(legalform lastyear) nogenerate

		// unify counttries' names
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SERBIA" if country == "SERBIA AND MONTENEGRO" 
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"

		// save
		compress
		save "$preparation_path\managers_2004.dta", replace
	}

	// 2006
	if `wave' == 2006 {
		di "*** `wave' ***"
		clear
		
		// load data
		use mark bvdidnumber bvdaccountnumber managerfullname managerfunction using "$originaldta_path\2006 March\p6_management_1.dta"
		replace bvdidnumber = bvdidnumber[_n-1] if mark== .
		replace bvdaccountnumber = bvdaccountnumber[_n-1] if mark== .
		merge m:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2006 March\p1_header.dta", keepusing(country legalform lastyear) nogenerate 

		// unify countries' names
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SERBIA" if country == "SERBIA AND MONTENEGRO" 
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"

		// save
		compress
		save "$preparation_path\managers_2006.dta", replace
	}

	// 2008
	if `wave' == 2008 {
		di "*** `wave' ***"
		clear
		
		// load data
		use bvdepidnumber bvdepaccountnumber country fullname title salutation gender titlesince using "$originaldta_path\2008 May\boardmemandmanagers.dta"
		merge m:n bvdepidnumber bvdepaccountnumber using "$originaldta_path\2008 May\header.dta", keepusing(lastyear) nogenerate
		
		// adjust bvdidnumber name
		rename bvdepidnumber bvdidnumber
		rename bvdepaccountnumber bvdaccountnumber
		
		// unify countries' names
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "MOLDOVA REPUBLIC OF"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		// save
		compress
		save "$preparation_path\managers_2008.dta", replace
	}
	
	// 2010
	if `wave' == 2010 {
		di "*** `wave' ***"
		clear
		
		// load data
		use "$originaldta_path\2010 December\amadeus_export_1.dta"
		forvalues i=2(1)55 {
			di "file no. `i' "
			append using "$originaldta_path\2010 December\amadeus_export_`i'.dta", force
		}
		merge n:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2010 December\key_22.dta", update nogenerate
		merge n:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2010 December\key_23.dta", update
		drop if bvdidnumber=="Credit needed"
		
		// convert to numeric
		destring lastyear numberofcurrentmembersoftheboard, replace force
		
		// append Russian and Ukrainian obs with latin alphabet names
		append using "$originaldta_path\2010 December\managers_russia_latin_1.dta", keep(bvdidnumber bvdaccountnumber numberofcurrentmembersoftheboard bmfullname bmtitle bmsalutation  bmsuffix bmoriginaljobtitle bmboardcommitteeorexecutivedepar bmlevelofresponsability bmalsoashareholder)
		append using "$originaldta_path\2010 December\managers_russia_latin_2.dta", keep(bvdidnumber bvdaccountnumber numberofcurrentmembersoftheboard bmfullname bmtitle bmsalutation bmsuffix bmoriginaljobtitle bmboardcommitteeorexecutivedepar bmlevelofresponsability bmalsoashareholder) force
		append using "$originaldta_path\2010 December\managers_ukraine_latin.dta", keep(bvdidnumber bvdaccountnumber numberofcurrentmembersoftheboard bmfullname bmtitle bmsalutation bmsuffix bmoriginaljobtitle bmboardcommitteeorexecutivedepar bmlevelofresponsability bmalsoashareholder) force
		
		// keep only necessary variables
		keep bvdidnumber bvdaccountnumber country legalform lastyear nacerev2primarycode numberofcurrentmembersoftheboard bmfullname bmtitle bmsalutation bmsuffix bmoriginaljobtitle bmboardcommitteeorexecutivedepar bmlevelofresponsability bmalsoashareholder conscode
		
		//
		sort bvdidnumber country
		replace legalform = legalform[_n+1] if bvdidnumber==bvdidnumber[_n+1] & legalform=="" & legalform[_n+1]!="" & (substr(bvdidnumber, 1, 2) == "RU" | substr(bvdidnumber, 1, 2) == "UA")
		replace nacerev2primarycode = nacerev2primarycode[_n+1] if bvdidnumber==bvdidnumber[_n+1] & nacerev2primarycode=="" & nacerev2primarycode[_n+1]!="" & (substr(bvdidnumber, 1, 2) == "RU" | substr(bvdidnumber, 1, 2) == "UA")
		replace lastyear = lastyear[_n+1] if bvdidnumber==bvdidnumber[_n+1] & lastyear==. & lastyear[_n+1]!=. & (substr(bvdidnumber, 1, 2) == "RU" | substr(bvdidnumber, 1, 2) == "UA")
		
		// lastyear to numeric
		drop if country == "UKRAINE" | country == "RUSSIAN FEDERATION"
		replace country = "RUSSIAN FEDERATION" if substr(bvdidnumber, 1, 2) == "RU" & country == ""
		replace country = "UKRAINE" if substr(bvdidnumber, 1, 2) == "UA" & country == ""
		
		forvalues i = 53(1)90 {
			replace legalform = legalform[_n+1] if bvdidnumber==bvdidnumber[_n+1] & legalform=="" & legalform[_n+1]!="" & (substr(bvdidnumber, 1, 2) == "RU" | substr(bvdidnumber, 1, 2) == "UA")
			replace nacerev2primarycode = nacerev2primarycode[_n+1] if bvdidnumber==bvdidnumber[_n+1] & nacerev2primarycode=="" & nacerev2primarycode[_n+1]!="" & (substr(bvdidnumber, 1, 2) == "RU" | substr(bvdidnumber, 1, 2) == "UA")
			replace lastyear = lastyear[_n+1] if bvdidnumber==bvdidnumber[_n+1] & lastyear==. & lastyear[_n+1]!=. & (substr(bvdidnumber, 1, 2) == "RU" | substr(bvdidnumber, 1, 2) == "UA")
			local i = `i' + 1
		}
		
		// unify countries' names
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "MOLDOVA REPUBLIC OF"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		// save
		compress
		save "$preparation_path\managers_2010.dta", replace
	}

	// 2014
	if `wave' == 2014 {
		di "*** `wave' ***"
		clear
		
		// load data
		forvalues i=1/4 {
			append using "$originaldta_path\2014 May\managers_2014_`i'.dta" , keep(country bvdidnumber bvdaccountnumber lastyear nacerev2primarycode numberofcurrentdirectorsmanagers dmcfullname dmcoriginaljobtitleinenglish dmctitle dmcsalutation dmcsuffix dmcindividualorcompany dmcoriginaljobtitle dmctypeofposition dmcboardcommitteeordepartment dmclevelofresponsibility dmcalsoashareholder dmcconfirmationdates dmcdateslastreceivedfromips)
		}
		drop if (bvdidnumber=="Credit needed")
		drop if dmcfullname=="" | numberofcurrentdirectorsmanagers == "0"
		destring lastyear numberofcurrentdirectorsmanagers , replace force
		merge n:1 bvdidnumber bvdaccountnumber using "$legalform_path\_by_wave\legalform_2014.dta", keepusing(legalform)
		drop if _merge==2
		drop _merge
		cap ren nationallegalform legalform
		
		// unify countries' names
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "REPUBLIC OF MOLDOVA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"

		// save
		compress
		save "$preparation_path\managers_2014.dta", replace
	}
	
	// 2016
	if `wave' == 2016 {
		di "*** `wave' ***"
		clear
		
		// load data
		forvalues i=1/4 {
			append using "$originaldta_path\2016 May\managers_2016_`i'.dta" , keep(bvdidnumber bvdaccountnumber country lastyear numberofcurrentdirectorsmanagers dmcfullname dmcuciuniquecontactidentifier dmcoriginaljobtitleinenglish dmcindividualorcompany dmctitle dmcsalutation dmcsuffix dmcoriginaljobtitle dmctypeofposition dmcboardcommitteeordepartment dmclevelofresponsibility dmcalsoashareholder dmcconfirmationdates dmcdateslastreceivedfromips)
		}
		drop if (bvdidnumber=="Credit needed")
		drop if dmcfullname=="" | numberofcurrentdirectorsmanagers == "0"
		destring lastyear numberofcurrentdirectorsmanagers , replace
		merge n:1 bvdidnumber using "$legalform_path\_by_wave\legalform_2016.dta" , keepusing(nationallegalform)
		drop if _merge==2
		drop _merge
		ren nationallegalform legalform
		
		// unify countries' names
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "REPUBLIC OF MOLDOVA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"

		// save
		compress
		save "$preparation_path\managers_2016.dta", replace
	}
	
	// 2020
	if `wave' == 2020 {
		di "*** `wave' ***"

		global vars_to_use "bvdidnumber titleiedrlord salutation suffix fullname originaljobtitleinenglish originaljobtitleinlocallanguagew typeofposition boardcommitteeordepartment levelofresponsibility appointmentdate resignationdate confirmationdates dateslastreceivedfromips notvalidafterdate individualorcompany gender uciuniquecontactidentifier"
		
		clear
		local p = 1
		forvalues i = 1(1)10 {
			cd "$originaldta_path\2020"
			use $vars_to_use using DMC_previous_1_`i'.dta
			
			// merge lastyear, country and legal form
			merge n:1 bvdidnumber using "A:\AMA_data\_managers\lastyear_2020.dta", keepusing(lastyear2020)
			drop if _merge == 2
			capture rename lastyear2020 lastyear
			drop _merge
			
			merge n:1 bvdidnumber using "$preparation_path\country_2020.dta"
			drop if _merge == 2
			drop _merge
			
			merge n:1 bvdidnumber using "$legalform_path\_by_wave\legalform_2020.dta", keepusing(nationallegalform)
			drop if _merge == 2
			drop _merge
			ren nationallegalform legalform
			
			//
			cd "$preparation_path"
			save managers_2020_`i'_previous.dta, replace
		}
		
		clear
		local p = 1
		forvalues i = 1(1)7 {
			cd "$originaldta_path"
			cd "2020"
			use $vars_to_use using DMC_current_1_`i'.dta
			
			// merge lastyear 
			merge n:1 bvdidnumber using "A:\AMA_data\_managers\lastyear_2020.dta", keepusing(lastyear2020)
			drop if _merge == 2
			capture rename lastyear2020 lastyear
			drop _merge
			
			merge n:1 bvdidnumber using "$preparation_path\country_2020.dta"
			drop if _merge == 2
			drop _merge
			
			merge n:1 bvdidnumber using "$legalform_path\_by_wave\legalform_2020.dta", keepusing(nationallegalform)
			drop if _merge == 2
			drop _merge
			ren nationallegalform legalform
			
			//
			cd "$preparation_path"
			save managers_2020_`i'_current.dta, replace
		}
	}
}
