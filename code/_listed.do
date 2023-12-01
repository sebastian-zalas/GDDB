/******************************************************************************/
/*	 						Stocklisted	firms				 				  */
/******************************************************************************/

* - gather information about firm participating in stock exchange
* - split by country in each wave 
* - merge files from each country from different waves
* - compound time when firm was stock listed

capture frame change default
capture frame drop tempframe
capture frame drop timetempframe
clear

// define options (macros)
	/* set to 1 if you want to split by
	   countries and reshape, otherwise set to 0 */
	local split_reshape = 1

	/* set to 1 if you want to merge country-wave files
	   and aggergate stocklisted status, otherwise set to 0 */
	local merge_countries = 1
	
	/* define for which waves you want to execute code,
	   certin of waves can be omitted if possible */
	global waves "2016"

foreach wv of global waves {
	// 2002
	if `wv' == 2002 {
	    di "*** `wv' ***"
		clear
		use bvdidnumber bvdaccountnumber ipodate using "$originaldta_path\2002 December\stockdata_security_and_price.dta"
		drop if bvdidnumber == ""
		merge 1:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2002 December\header.dta" , keepusing(country publiclyquoted lastyear numberofyears)
		keep if _merge != 1
		drop _merge
		
		// time
		drop if lastyear == 0
		drop if lastyear > 2002
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = . if lastyear == 0
		drop numberofyears
		
		// ipo date to ipo year
		replace ipodate = "" if ipodate == "n.a."
		gen ipoyear = ustrright(ipodate, 4)
		destring ipoyear , replace
		drop ipodate
		
		//
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		//
		replace publiclyquoted = "0" if publiclyquoted == "No"
		replace publiclyquoted = "1" if publiclyquoted == "Yes"
		destring publiclyquoted , replace
		
		compress
		save "$legalform_path\_by_wave\listed_`wv'.dta", replace
	}	
		
	// 2003
	if `wv' == 2003 {
	    di "*** `wv' ***"
		clear
		use bvdidnumber bvdaccountnumber ipodate using "$originaldta_path\2003 December\stockdata_security_and_price.dta"
		drop if bvdidnumber == ""
		merge 1:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2003 December\header.dta" , keepusing(country publiclyquoted lastyear numberofyears)
		keep if _merge != 1
		drop _merge
		
		// time
		drop if lastyear > 2003
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		drop numberofyears
		
		// ipo date to ipo year
		replace ipodate = "" if ipodate == "n.a."
		gen ipoyear = ustrright(ipodate, 4)
		destring ipoyear , replace
		drop ipodate

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
		
		//
		replace publiclyquoted = "0" if publiclyquoted == "No"
		replace publiclyquoted = "1" if publiclyquoted == "Yes"
		destring publiclyquoted , replace
		
		//
		compress
		save "$legalform_path\_by_wave\listed_`wv'.dta", replace
	}
	
	// 2004
	if `wv' == 2004 {
	    di "*** `wv' ***"
		use bvdidnumber bvdaccountnumber ipodate using "$originaldta_path\2004 June\stockdata_security_and_price.dta"
		drop if bvdidnumber == ""
		merge 1:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2004 June\header.dta" , keepusing(country publiclyquoted lastyear numberofyears)
		keep if _merge != 1
		drop _merge
		
		// time
		drop if lastyear > 2004
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		drop numberofyears
		
		// ipo date to ipo year
		replace ipodate = "" if ipodate == "n.a."
		gen ipoyear = ustrright(ipodate, 4)
		destring ipoyear , replace
		drop ipodate
		
		//
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SERBIA" if country == "SERBIA AND MONTENEGRO" 
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"

		//
		replace publiclyquoted = "0" if publiclyquoted == "No"
		replace publiclyquoted = "1" if publiclyquoted == "Yes"
		destring publiclyquoted , replace
		
		//
		compress
		save "$legalform_path\_by_wave\listed_`wv'.dta", replace
	}
	
	// 2006
	if `wv' == 2006 {
		di "*** `wv' ***"
		//
		//. use "I:\DTA\2006 March\p7_stockdata_1.asc.dta" 
		//. bvdidnumber bvdaccountnumber ipodate

		use bvdidnumber bvdaccountnumber ipodate using "$originaldta_path\2006 March\stockdata_security_and_price.dta"
		drop if bvdidnumber == ""
		merge 1:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2006 March\p1_header.dta" , keepusing(country  lastyear numberofyears)
		keep if _merge != 1
		drop _merge
		merge 1:1 bvdidnumber bvdaccountnumber using "$originaldta_path\2006 March\p1_header_2.dta" , keepusing(publiclyquoted) nogen
		
		// time
		drop if lastyear > 2006
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		drop numberofyears
		
		// ipo date to ipo year
		replace ipodate = "" if ipodate == "n.a."
		gen ipoyear = ustrright(ipodate, 4)
		destring ipoyear , replace
		drop ipodate
		
		//
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SERBIA" if country == "SERBIA AND MONTENEGRO" 
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		//
		replace publiclyquoted = "0" if publiclyquoted == "No" | publiclyquoted == ""
		replace publiclyquoted = "1" if publiclyquoted == "Yes"
		destring publiclyquoted , replace
		
		//
		compress
		save "$legalform_path\_by_wave\listed_`wv'.dta", replace
	}

	// 2008
	if `wv' == 2008 {
	    di "*** `wv' ***"
		use bvdepidnumber bvdepaccountnumber ipodate using "$originaldta_path\2008 May\stockdata_security_and_price.dta"
		drop if bvdepidnumber == ""
		merge 1:n bvdepidnumber bvdepaccountnumber  using "$originaldta_path\2008 May\header.dta" , keepusing(country publiclyquoted lastyear numberofyears) nogen
		rename bvdepidnumber bvdidnumber
		rename bvdepaccountnumber bvdaccountnumber
		
		// time
		drop if lastyear > 2008
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		drop numberofyears
		
		//
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "MOLDOVA REPUBLIC OF"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"
	
		//
		replace publiclyquoted = "0" if publiclyquoted == "No"
		replace publiclyquoted = "1" if publiclyquoted == "Yes"
		destring publiclyquoted , replace
		
		// ipo date to ipo year
		replace ipodate = "" if ipodate == "n.a."
		gen ipoyear = ustrright(ipodate, 4)
		destring ipoyear , replace
		drop ipodate
		
		//
		compress
		save "$legalform_path\_by_wave\listed_`wv'.dta", replace
	}

	// 2010
	if `wv' == 2010 {
	    di "*** `wv' ***"
		use bvdidnumber bvdaccountnumber publiclyquoted ipodate using "$originaldta_path\2010 December\stockdata_security_and_price.dta"
		drop if bvdidnumber == ""
		bys bvdidnumber bvdaccountnumber : gen duplos = _n - 1
		drop if duplos > 0
		drop duplos
		merge 1:n bvdidnumber bvdaccountnumber using "$fvar_path\key_2010.dta" , keepusing(country lastyear numberofyears) nogenerate
		drop if bvdidnumber == "Credit needed"
		
		// time
		destring lastyear numberofyears, replace
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		replace firstyear = . if lastyear == .
		
		// ipo date to ipo year
		replace ipodate = "" if ipodate == "n.a."
		gen ipoyear = ustrright(ipodate, 4)
		destring ipoyear , replace
		drop ipodate
		
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "MOLDOVA REPUBLIC OF"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		//
		replace publiclyquoted = "0" if publiclyquoted == "" | publiclyquoted == "No"
		replace publiclyquoted = "1" if publiclyquoted == "Yes"
		destring publiclyquoted , replace
		
		//
		compress
		save "$legalform_path\_by_wave\listed_`wv'.dta", replace
	}

	// 2014
	if `wv' == 2014 {
		use country bvdidnumber bvdaccountnumber lastyear numberofavailableyears using "$originaldta_path\2014 May\accountinginfo.dta"
		drop if bvdidnumber == "Credit needed"
		merge 1:1 bvdidnumber using "$originaldta_path\2014 May\size_and_group_quoted_only.dta" , keepusing(publiclyquoted) nogenerate

		//drop if bvdidnumber == "Credit needed" | bvdidnumber == ""
		//ren nationallegalform legalform
		
		// time
		destring lastyear numberofavailableyears, replace
		drop if lastyear > 2014
		gen firstyear = lastyear - numberofavailableyears + 1
		replace firstyear = lastyear if numberofavailableyears == 0
		drop numberofavailableyears
	
		//
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "REPUBLIC OF MOLDOVA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		//
		replace publiclyquoted = "0" if publiclyquoted == ""
		replace publiclyquoted = "1" if publiclyquoted == "Yes"
		destring publiclyquoted , replace
		
		//
		compress
		save "$legalform_path\_by_wave\listed_`wv'.dta", replace
	}
	
	// 2016
	if `wv' == 2016 {
		di "*** `wv' ***"
		append using "$originaldta_path\2016 May\amadeus_2016_additional_1.dta" , keep(bvdidnumber bvdaccountnumber country lastyear numberofavailableyears)
		append using "$originaldta_path\2016 May\amadeus_2016_additional_2.dta" , keep(bvdidnumber bvdaccountnumber country lastyear numberofavailableyears)
		drop if bvdidnumber=="Credit needed" | bvdidnumber == ""
		destring lastyear numberofavailableyears, replace
		
		// time
		destring lastyear numberofavailableyears, replace
		drop if lastyear > 2016
		gen firstyear = lastyear - numberofavailableyears + 1
		replace firstyear = lastyear if numberofavailableyears == 0
		drop numberofavailableyears
		
		//
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "REPUBLIC OF MOLDOVA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		//
		merge 1:n bvdidnumber using "$originaldta_path\2016 May\quoted.dta" , keepusing(publiclyquoted)
		drop if _merge == 2
		drop _merge
		
		//
		replace publiclyquoted = "0" if publiclyquoted == "No" | publiclyquoted == ""
		replace publiclyquoted = "1" if publiclyquoted == "Yes"
		destring publiclyquoted , replace
		
		//
		compress
		save "$legalform_path\_by_wave\listed_`wv'.dta", replace
	}
	
	// splitting
	if (`split_reshape' == 1  & `wv' != 2020) {
		local wv = 2008
		// some waves contain ipo year
		if (`wv' >= 2002 & `wv' <= 2010) {
			local vars "stocklisted`wv' ipoyear`wv'"
		}
		else {
			local vars "stocklisted`wv'"
		}
		
		// country list
		levelsof country , clean
		global countries "`r(levels)'"
		
		// bvdidnumber is enough
		bys bvdidnumber : gen duplos = _n - 1 
		drop if duplos > 0
		drop duplos
		
		// min and max year
		summ firstyear
		local minyear = `r(min)'
		summ lastyear
		local maxyear = `r(max)'
		
		//
		ren publiclyquoted stocklisted`wv'
		capture ren ipoyear ipoyear`wv'
		
		foreach cntry of global countries {
			// create folder, if not already exists 
			capture mkdir "$legalform_path\_by_country\_`cntry'"
			
			// put data from given country into separate, temporary frame
			frame put bvdidnumber country lastyear firstyear `vars' if country == "`cntry'", into(tempframe)
			frame change tempframe
				
			// go to long - split by year
			forvalues yr = `minyear'(1)`maxyear' {
				di "--- `cntry': `yr' -----------------------------------------------"
				quietly {
				gen year = .
				replace year = `yr' if lastyear >= `yr' & firstyear <= `yr'
				frame put bvdidnumber country year `vars' if year == `yr' , into(timetempframe)
				frame change timetempframe
				compress
				save "$legalform_path\_by_country\_`cntry'\listed_`cntry'_`wv'_`yr'.dta" , replace
				frame change tempframe
				frame drop timetempframe
				drop year
				}
			}
			
			// append year files
			clear
			global filelist: dir "$legalform_path\_by_country\_`cntry'" file "listed_`cntry'_`wv'_*.dta"
			cd "$legalform_path\_by_country\_`cntry'"
			foreach i of global filelist {
				append using `i' , force
				erase `i'
			}
			
			// save
			compress
			save "$legalform_path\_by_country\_`cntry'\listed_`cntry'_`wv'.dta", replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	// 2020
	if `wv' == 2020 {
		clear
		
		// prepare first and lastyear 
		use bvdidnumber year_closing using "K:\Sebastian Zalas\FromHubert\Financial_Long_Country_Nace_Empl_Consolid.dta"
		
		//
		bysort bvdidnumber year_closing : gen dfy = _n - 1
		keep if dfy == 0
		drop dfy
		
		merge n:1 bvdidnumber using "$originaldta_path\2020\legal_info.dta" , keepusing(listeddelistedunlisted delisteddate ipodate listeddelistedunlisted ipodate) nogenerate
		drop if year_closing == .
		ren year_closing year
		
		// countries
		merge n:1 bvdidnumber using "$preparation_path\country_2020.dta" , nogen
		drop if country == ""
		
		//
		gen stocklisted = .
		replace stocklisted = 0 if listeddelistedunlisted == "Unlisted"
		replace stocklisted = 1 if listeddelistedunlisted == "Listed"
		replace stocklisted = 2 if listeddelistedunlisted == "Delisted"
		drop listeddelistedunlisted
		
		// convert dates to years
		tostring ipodate delisteddate, replace
		gen ipoyear = substr(ipodate, 1, 4)
		replace ipoyear = "" if ipodate == "."
		gen delistedyear = substr(delisteddate, 1, 4)
		replace delistedyear = "" if delisteddate == "."
		destring delistedyear ipoyear , replace
		drop delisteddate ipodate
		
		// use exact dates of participating in stock exchange
		replace stocklisted = 1 if delistedyear >= year & delistedyear != .
		replace stocklisted = 0 if delistedyear < year & delistedyear != .
		replace stocklisted = 0 if ipoyear > year & ipoyear != .
		replace stocklisted = 1 if stocklisted == 2
		
		//
		compress
		save "$legalform_path\_by_wave\listed_2020.dta", replace
		
		// split by country
		bys country : gen dc = _n - 1
		levelsof country if dc == 0 , clean
		global countries "`r(levels)'"
		drop dc
		
		foreach cntry of global countries {
			// create folder, if not already exists 
			capture mkdir "$legalform_path\_by_country\_`cntry'"
			
			// put data from given country into separate, temporary frame
			frame put bvdidnumber country year stocklisted ipoyear delistedyear if country == "`cntry'", into(tempframe)
			frame change tempframe
			ren stocklisted stocklisted2020
			ren ipoyear ipoyear2020
			
			// save
			compress
			save "$legalform_path\_by_country\_`cntry'\listed_`cntry'_`wv'.dta", replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}

}

clear
local merge_countries = 1
// merge countries
if (`merge_countries' == 1) {
	global countries : dir "$legalform_path\_by_country" dirs "_*"
	di $folders

	foreach cntry of global countries {
		local cntry = subinstr("`cntry'", "_", "", .)
		di "Merging `cntry'"

		// merge all legalform files from one country
		cd "$legalform_path\_by_country\_`cntry'"
		global files: dir "$legalform_path\_by_country\_`cntry'" file "listed_*.dta"
		di $files
		local p = 1
		foreach file of global files {
			// first file
			if `p' == 1 {
				use `file'
			}
			// next files
			if (`p' > 1 ){
				merge 1:1 bvdidnumber year using `file', nogen
			}
			// update file counter
			local p = `p' + 1
		}
		
		// aggregate listed status
			// Let us see if ipo's are conflicting. Let us make sure that ipo is over the whole company
			egen MINipo=rowmin(ipoyear*)
			bysort bvdidnumber: egen ipoyear = min(MINipo)
			capture drop MINipo
			// Let us be sure to extend delistedyear for the whole company
			ren delistedyear delistedyear_
			bysort bvdidnumber: egen delistedyear=max(delistedyear_)
			drop delistedyear_
				
			  log using listed_check_`cntry', replace text
			  log off			
			
			egen MAX = rowmax(stocklisted*)
			egen MIN = rowmin(stocklisted*)

			gen stocklisted=.
		

			matrix input YEARS = (2002, 2003, 2004, 2006, 2008, 2010, 2014, 2016 \ 2003, 2004, 2006, 2008, 2010, 2014, 2016, 2020 )
			foreach i in 02 03 04 06 08 10 14 16 20{
			    capture confirm variable stocklisted20`i'
				if _rc == 0 {
					ren stocklisted20`i' stocklisted20`i'_
					bysort bvdidnumber: egen  stocklisted20`i'= max(stocklisted20`i'_)
					drop stocklisted20`i'_
					
					if 20`i' <=2002 {
						replace stocklisted=stocklisted20`i' if year<delistedyear & year <=2002 
						replace stocklisted=0                if year>delistedyear & year <=2002 						
						replace stocklisted=1                if year<delistedyear & year <=2002 & year>=ipoyear &  ipoyear<=2002 
					}
					forvalues j=1(1)8{ 
						if YEARS[1,`j']< 20`i' &  20`i' <=YEARS[2,`j'] {
							replace stocklisted=stocklisted20`i' if year<delistedyear & YEARS[1,`j']<year & year<=YEARS[2,`j'] 
							replace stocklisted=0                if year>delistedyear & YEARS[1,`j']<year & year<=YEARS[2,`j'] 
							replace stocklisted=1                if year<delistedyear & YEARS[1,`j']<year & year<=YEARS[2,`j']  & YEARS[1,`j']<delistedyear & delistedyear<=YEARS[2,`j'] 
							replace stocklisted=1                if year<delistedyear & YEARS[1,`j']<year & year<=YEARS[2,`j']  & year>=ipoyear& YEARS[1,`j']<ipoyear & ipoyear<=YEARS[2,`j'] 
							continue, break
					}
					}
				}
				if _rc !=0 {				
				}
			 }
			 
			log on
			di "Loop imputation"
			tab year stocklisted, mis
			log off

			// If a year is before ipodate make it zero or the year is the delistation year
			replace stocklisted=0 if (!missing(ipoyear) & year<ipoyear) | year==delistedyear
			// Obvious zeroes
			replace stocklisted=0 if missing(stocklisted) & (missing(MAX)|MAX==0)
			
			sort bvdidnumber year
			capture drop counter
			by bvdidnumber: gen counter = _n
			bysort bvdidnumber: egen counter_max=max(counter)
				
			// A one hole system. If there is a missing one year, that around we have (1 . 1 ) or  (0 . 0) 
			replace stocklisted=1 if missing(stocklisted) & MAX!=MIN & stocklisted[_n-1]==1 & stocklisted[_n+1]==1 & counter!=1 & counter !=counter_max
			replace stocklisted=0 if missing(stocklisted) & MAX!=MIN & stocklisted[_n-1]==0 & stocklisted[_n+1]==0 & counter!=1 & counter !=counter_max

			//Two holes system
			replace stocklisted=1 if missing(stocklisted) & MAX!=MIN & (missing(stocklisted[_n-1]) & stocklisted[_n-2]==1  & stocklisted[_n+1]==1 )| (missing(stocklisted[_n+1]) & stocklisted[_n+2]==1  & stocklisted[_n-1]==1 ) & counter!=1 & counter !=counter_max
			replace stocklisted=0 if missing(stocklisted) & MAX!=MIN & (missing(stocklisted[_n-1]) & stocklisted[_n-2]==0  & stocklisted[_n+1]==0 )| (missing(stocklisted[_n+1]) & stocklisted[_n+2]==0  & stocklisted[_n-1]==0 ) & counter!=1 & counter !=counter_max
			replace stocklisted=1 if missing(stocklisted) & MAX!=MIN & stocklisted[_n-1]==1 & stocklisted[_n+1]==1 & counter!=1 & counter !=counter_max
			replace stocklisted=0 if missing(stocklisted) & MAX!=MIN & stocklisted[_n-1]==0 & stocklisted[_n+1]==0 & counter!=1 & counter !=counter_max

			// The edges missing then make them not missing
			replace stocklisted=1 if  counter==1 & counter[_n+1]==1 & missing(stocklisted) & (missing(ipoyear) | !missing(ipoyear) & year>=ipoyear) & year<delistedyear
			replace stocklisted=0 if  counter==1 & counter[_n+1]==0 & missing(stocklisted) & (missing(ipoyear) | !missing(ipoyear) & year>=ipoyear) & year<delistedyear

			replace stocklisted=1 if  counter_max==counter & counter[_n-1]==1 & missing(stocklisted) & (missing(ipoyear) | !missing(ipoyear) & year>=ipoyear) & year<delistedyear
			replace stocklisted=0 if  counter_max==counter & counter[_n-1]==0 & missing(stocklisted) & (missing(ipoyear) | !missing(ipoyear) & year>=ipoyear) & year<delistedyear

			log on
			di "Wholes imputation"
			tab year stocklisted, mis
			log off

			// Another round
			replace stocklisted=0 if missing(stocklisted) & delistedyear<year

			// If all ones and larger than ipo smaller than delisted give one 
			replace stocklisted=1 if missing(stocklisted) & MIN==1 & (!missing(ipoyear) & year>=ipoyear) & year<delistedyear

			log on
			di "All ones inbetween ipo and delisted"
			tab year stocklisted, mis
			log off

			replace stocklisted=1 if missing(stocklisted) & MIN==1 & year<delistedyear

			log on
			di "All ones no idea when ipoyear"
			tab year stocklisted, mis
			log off
			log close

			drop stocklisted2*
			drop ipoyear2*			
			drop counter
			drop counter_max
			drop MAX
			drop MIN
			drop ipoyear
			drop delistedyear
		
		// save
		compress
		save "$legalform_path\listed_`cntry'.dta" , replace
		clear
	}

}