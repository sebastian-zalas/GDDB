/******************************************************************************/
/*	 					Processing NACE industry codes				  		  */
/******************************************************************************/

** check if nace rev 1.1 and nace rev. 1 codes, given in 2002-2008 waves are correct **
clear

global waves ""

// prepare nace for all countries from each wave separately
foreach wv of global waves {
	// 2002
	if `wv' == 2002 {
		// load data
		clear
		cd "$originaldta_path"
		cd "2002 December"
		use bvdidnumber bvdaccountnumber country nacerev1primarycode nacerev1primarycodedescription using activities.dta
		bysort bvdidnumber bvdaccountnumber : gen df = _n - 1
		drop if df > 0
		drop df
		drop if bvdidnumber == ""
		merge 1:1 bvdidnumber bvdaccountnumber country using header.dta, keepusing(lastyear numberofyears)
		drop if _merge != 3
		drop _merge
		ren nacerev1primarycode nacecode
		ren nacerev1primarycodedescription description
		
		// time
		drop if lastyear == 0
		drop if lastyear > 2002
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = . if lastyear == 0
		
		// drop obs which have few bvdidnumbers for one bvdaccountnumber as nace does not differ among bvdidnumber
		bys bvdidnumber : gen d = _n - 1
		drop if d > 0
		drop d
		
		// modify country names
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		// strL to str#
		generate str description_str = description
		replace description = ""
		compress description
		replace description = description_str
		drop description_str

		// correction based on my findings - should improve merge, and eliminate unexisting codes
		replace nacecode = . if nacecode == 8888
		replace nacecode = . if nacecode == 9999
		replace nacecode = . if nacecode == 9700

		replace nacecode = 20 if nacecode == 200
		replace nacecode = 266 if description == "Manufacture of articles of concrete, plaster or cement"
		replace nacecode = 20 if description == "Forestry,  logging and related service activities"
		replace nacecode = 273 if description == "Other first processing of iron and steel and production of non-ESCS ferro-alloys"
		replace nacecode = 522 if description == "Retail sale of food, beverage and tobacco in specialized stores"
		replace nacecode = 524 if description == "Other retail sale of new goods in specialised stores"
		replace nacecode = 552 if description == "Camping sites and other provision of short-stay accommodation"
		replace nacecode = 671 if description == "Activities auxiliary to financial intermediation, except insurance and pension funding"
		replace nacecode = 701 if description == "Real estate activities with own or leased property"
		replace nacecode = 7310 if description == "Research and experimental development on natural sciences and engineering (NSE)"
		replace nacecode = 911 if description == "Activities of business, employers and professional organisations"
		replace nacecode = 913 if description == "Activities of other membership organisations"

		replace description = "Activities of business and employers organizations" if description =="Activities of business and employers organisation"
		replace description = "Forestry, logging and related service activities" if description == "Forestry,  logging and related service activities"

		// merge with nace rev 1 list
		cd "$nace_path\_nace_check"

		merge n:1 nacecode using nace1listunique, generate(m1) update
		drop if m1 == 2

		merge n:1 description using nace1listduplicates, generate(m2) update replace
		drop if m2 == 2

		merge n:1 description using nace1listuniquedesc, generate(m3) update replace
		drop if m3 == 2

		gen expl = 0
		replace expl = 1 if m1>2 | m2>2 | m3>2

		replace nacecode = . if expl == 0
		keep bvdidnumber bvdaccountnumber country nacecode mainsector nace1twodigit nace1threedigit nace1fourdigit originalnace1 lastyear first
		ren nacecode nace1_2002
		ren mainsector mainsector_2002
		ren nace1twodigit nace1twodigit_2002
		ren nace1threedigit nace1threedigit_2002
		ren nace1fourdigit nace1fourdigit_2002
		ren originalnace1 originalnace1_2002
		gen source_2002 = 2002
		replace nace1fourdigit_2002 = subinstr(nace1fourdigit_2002, ".", "", .)
		replace nace1threedigit_2002 = subinstr(nace1threedigit_2002, ".", "", .)
		replace nace1twodigit_2002 = subinstr(nace1twodigit_2002, ".", "", .)
		
		//
		capture drop level_2002 code
		gen code = ""
		gen level_2002 = .
		replace code = nace1fourdigit_2002
		replace level_2002 = 4 if code != ""
		replace code = nace1threedigit_2002 if code == ""
		replace level_2002 = 3 if nace1fourdigit_2002 == "" & nace1threedigit_2002 != "" & level_2002 == .
		replace code = nace1twodigit_2002 if code == ""
		replace level_2002 = 2 if nace1fourdigit_2002 == "" & nace1threedigit_2002 == "" & nace1twodigit_2002 != "" & level_2002 == .
		drop nace1twodigit_2002 nace1threedigit_2002 nace1fourdigit_2002 originalnace1_2002 nace1_2002
		
		// translate nace rev 1 to nace rev 11
		ren code nace1
		merge n:1 nace1 using "$nace_path\_nace_conversion\_dta\_nace_crosswalk_rev1_to_rev11.dta"
		drop if _merge == 2
		replace level_2002 = strlen(nace11converted)
		ren nace1 nace_2002_1
		ren nace11converted nace_2002
		drop _merge
		
		// generate time variables
		forvalues i = 1989(1)2002 {
			gen t`i' = .
			replace t`i' = `i' if (`i' >= firstyear & `i' <= lastyear)
		}
		
		// reshape and save by country
		global countries "AUSTRIA BELGIUM BOSNIA BULGARIA CROATIA CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LITHUANIA LUXEMBOURG MACEDONIA NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE YUGOSLAVIA"
		cd "$nace_path"
		foreach cntry of global countries {
			// put data from given country into separate, temporary frame
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			
			// go to long
			reshape long t , i(bvdidnumber) j(year)
			keep if (year >= firstyear & year <= lastyear)
			capture drop t
					
			// save
			compress
			save nace2002_`cntry'.dta, replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}

	// 2003
	if `wv' == 2003 {
		// load data
		clear
		cd "$originaldta_path"
		cd "2003 December"
		use bvdidnumber bvdaccountnumber country nacerev11primarycode nacerev11primarycodedescription using activitiesandmanagement.dta
		bysort bvdidnumber bvdaccountnumber : gen df = _n - 1
		drop if df > 0
		drop df
		drop if bvdidnumber == ""
		merge 1:1 bvdidnumber bvdaccountnumber country using header.dta, keepusing(lastyear numberofyears)
		drop if _merge != 3
		drop _merge
		ren nacerev11primarycode nacecode
		ren nacerev11primarycodedescription description
		
		// time
		drop if lastyear > 2003
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		
		// drop obs which have few bvdidnumbers for one bvdaccountnumber as nace does not differ among bvdidnumber
		bys bvdidnumber : gen d = _n - 1
		drop if d > 0
		drop d

		// modify country names
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"
		replace country = "SERBIA" if country == "SERBIA AND MONTENEGRO" 

		// strL to str#
		generate str description_str = description
		replace description = ""
		compress description
		replace description = description_str
		drop description_str

		// correction
		replace nacecode = 671 if description == "Activities auxiliary to financial intermediation, except insurance and pension funding"
		replace nacecode = 911 if description == "Activities of business, employers and professional organisations" 
		replace nacecode = 911 if description == "Activities of business, employers' and professional organisations" 
		replace nacecode = 913 if description == "Activities of other membership organisations"
		replace description = "Agricultural and animal husbandry service activities, except veterinary activities; landscape gardening" if description == "Agricultural and animal husbandry service activities, except veterinary activities"
		replace description = "Agricultural service activities; landscape gardening" if description == "Agricultural service activities"
		replace nacecode = 552 if description == "Camping sites and other provision of short-stay accommodation"
		replace description = "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction excluding surveying" if description == "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction excluding surveying"
		replace nacecode = 11 if description == "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction, excluding surveying"
		replace description = "Forestry, logging and related service activities" if description == "Forestry,  logging and related service activities"
		replace description = "Growing of vegetables, horticultural specialities and nursery products" if description == "Growing of vegetables, horticultural specialties and nursery products"
		replace nacecode = 266 if description == "Manufacture of articles of concrete, plaster or cement"
		replace description = "Fish farming" if description == "Operation of fish hatcheries and fish farms"
		replace description = "Fishing, fish farming and related service activities" if description == "Fishing, operation of fish hatcheries and fish farms; service activities incidental to fishing"
		replace description = "Other first processing of iron and steel" if description == "Other first processing of iron and steel and production of non-ESCS ferro-alloys"
		replace nacecode = 524 if description == "Other retail sale of new goods in specialised stores"
		replace nacecode = 701 if description == "Real estate activities with own or leased property"
		replace nacecode = 7310 if description == "Research and experimental development on natural sciences and engineering (NSE)"
		replace nacecode = 522 if description == "Retail sale of food, beverage and tobacco in specialized stores"
		replace nacecode = . if description == "Unclassified Establishments"
		replace nacecode = 1120 if description == "Service activities incidental to oil and gas extraction excluding surveying"

		// merge with nace rev 1.1 list
		cd "$nace_path\_nace_check"

		merge n:1 nacecode using nace11listunique, generate(m1) update
		drop if m1 == 2

		merge n:1 description using nace11listduplicates, generate(m2) update
		drop if m2 == 2

		merge n:1 description using nace11listuniquedesc, generate(m3) update
		drop if m3 == 2

		gen expl = 0
		replace expl = 1 if m1>2 | m2>2 | m3>2

		replace nacecode = . if expl == 0
		ren code originalnace11 
		keep bvdidnumber bvdaccountnumber country nacecode mainsector nace11twodigit nace11threedigit nace11fourdigit originalnace11 lastyear first
		ren nacecode nace11_2003
		ren mainsector mainsector_2003
		ren nace11twodigit nace11twodigit_2003
		ren nace11threedigit nace11threedigit_2003
		ren nace11fourdigit nace11fourdigit_2003
		ren originalnace11 originalnace11_2003
		gen source_2003 = 2003
		replace nace11fourdigit_2003 = subinstr(nace11fourdigit_2003, ".", "", .)
		replace nace11threedigit_2003 = subinstr(nace11threedigit_2003, ".", "", .)
		replace nace11twodigit_2003 = subinstr(nace11twodigit_2003, ".", "", .)
		
		//
		capture drop level_2003 code
		gen code = ""
		gen level_2003 = .
		replace code = nace11fourdigit_2003
		replace level_2003 = 4 if code != ""
		replace code = nace11threedigit_2003 if code == ""
		replace level_2003 = 3 if nace11fourdigit_2003 == "" & nace11threedigit_2003 != "" & level_2003 == .
		replace code = nace11twodigit_2003 if code == ""
		replace level_2003 = 2 if nace11fourdigit_2003 == "" & nace11threedigit_2003 == "" & nace11twodigit_2003 != "" & level_2003 == .
		drop nace11twodigit_2003 nace11threedigit_2003 nace11fourdigit_2003 originalnace11_2003 nace11_2003
		ren code nace_2003
		
		// generate time variables
		forvalues i = 1990(1)2003 {
			gen t`i' = .
			replace t`i' = `i' if (`i' >= firstyear & `i' <= lastyear)
		}
		
		// reshape and save by country
		global countries "AUSTRIA BELGIUM BOSNIA BULGARIA CROATIA CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MONACO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE"
		cd "$nace_path"
		foreach cntry of global countries {
			// put data from given country into separate, temporary frame
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			
			// go to long
			reshape long t , i(bvdaccountnumber) j(year)
			keep if (year >= firstyear & year <= lastyear)
			capture drop t
					
			// save
			compress
			save nace2003_`cntry'.dta, replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	// 2004
	if `wv' == 2004 {
		clear
		// load data
		cd "$originaldta_path"
		cd "2004 June"
		use bvdidnumber bvdaccountnumber country nacerev11primarycode nacerev11primarycodedescription using activitiesandmanagement.dta
		bysort bvdidnumber bvdaccountnumber : gen df = _n - 1
		drop if df > 0
		drop df
		drop if bvdidnumber == ""
		merge 1:1 bvdidnumber bvdaccountnumber country using header.dta, keepusing(lastyear numberofyears)
		drop if _merge != 3
		drop _merge
		ren nacerev11primarycode nacecode
		ren nacerev11primarycodedescription description

		// time
		drop if lastyear > 2004
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		
		// drop obs which have few bvdidnumbers for one bvdaccountnumber as nace does not differ among bvdidnumber
		bys bvdidnumber : gen d = _n - 1
		drop if d > 0
		drop d		
		
		// modify dataset
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SERBIA" if country == "SERBIA AND MONTENEGRO" 
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		// correction
		replace nacecode = . if nacecode == 9999
		replace nacecode = 911 if description == "Activities of business, employers and professional organisations"
		replace nacecode = 911 if description == "Activities of business, employers' and professional organisations"
		replace nacecode = 913 if description == "Activities of other membership organisations"
		replace nacecode = 9500 if description == "Activities of households as employers of domestic  staff"
		replace nacecode = 14 if description == "Agricultural and animal husbandry service activities, except veterinary activities"
		replace nacecode = 9900 if description == "Extra-territorial organisations and bodies"
		replace nacecode = 11 if description == "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction excluding surveying"
		replace nacecode = 50 if description == "Fishing, operation of fish hatcheries and fish farms; service activities incidental to fishing"
		replace nacecode = 20 if description == "Forestry,  logging and related service activities"
		replace nacecode = 266 if description == "Manufacture of articles of concrete, plaster or cement"
		replace nacecode = 2710 if description == "Other first processing of iron and steel and production of non-ESCS ferro-alloys"
		replace nacecode = 524 if description == "Other retail sale of new goods in specialised stores"
		replace nacecode = 701 if description == "Real estate activities with own or leased property"
		replace nacecode = 522 if description == "Retail sale of food, beverage and tobacco in specialized stores"
		replace nacecode = 7310 if description == "Research and experimental development on natural sciences and engineering (NSE)"
		replace nacecode = 1120 if description == "Service activities incidental to oil and gas extraction excluding surveying"

		replace description = "Agricultural service activities; landscape gardening" if description == "Agricultural service activities"
		replace description = "Forestry, logging and related service activities" if description == "Forestry,  logging and related service activities"
		replace description = "Growing of vegetables, horticultural specialities and nursery products" if description == "Growing of vegetables, horticultural specialties and nursery products"
		replace description = "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction, excluding surveying" if description == "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction excluding surveying"

		// strL to str#
		generate str description_str = description
		replace description = ""
		compress description
		replace description = description_str
		drop description_str

		// merge with nace rev 1.1 list
		cd "$nace_path\_nace_check"

		merge n:1 nacecode using nace11listunique, generate(m1) update
		drop if m1 == 2

		merge n:1 description using nace11listduplicates, generate(m2) update replace
		drop if m2 == 2

		merge n:1 description using nace11listuniquedesc, generate(m3) update
		drop if m3 == 2

		gen expl = 0
		replace expl = 1 if m1>2 | m2>2 | m3>2

		replace nacecode = . if expl == 0
		ren code originalnace11
		keep bvdidnumber bvdaccountnumber country nacecode mainsector nace11twodigit nace11threedigit nace11fourdigit originalnace11 lastyear first
		ren nacecode nace11_2004
		ren mainsector mainsector_2004
		ren nace11twodigit nace11twodigit_2004
		ren nace11threedigit nace11threedigit_2004
		ren nace11fourdigit nace11fourdigit_2004
		ren originalnace11 originalnace11_2004
		gen source_2004 = 2004
		replace nace11fourdigit_2004 = subinstr(nace11fourdigit_2004, ".", "", .)
		replace nace11threedigit_2004 = subinstr(nace11threedigit_2004, ".", "", .)
		replace nace11twodigit_2004 = subinstr(nace11twodigit_2004, ".", "", .)
		
		//
		capture drop level_2004 code
		gen code = ""
		gen level_2004 = .
		replace code = nace11fourdigit_2004
		replace level_2004 = 4 if code != ""
		replace code = nace11threedigit_2004 if code == ""
		replace level_2004 = 3 if nace11fourdigit_2004 == "" & nace11threedigit_2004 != "" & level_2004 == .
		replace code = nace11twodigit_2004 if code == ""
		replace level_2004 = 2 if nace11fourdigit_2004 == "" & nace11threedigit_2004 == "" & nace11twodigit_2004 != "" & level_2004 == .
		drop nace11twodigit_2004 nace11threedigit_2004 nace11fourdigit_2004 originalnace11_2004 nace11_2004
		ren code nace_2004

		// generate time variables
		forvalues i = 1990(1)2004 {
			gen t`i' = .
			replace t`i' = `i' if (`i' >= firstyear & `i' <= lastyear)
		}
		
		// reshape and save by country
		global countries "AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE"
		cd "$nace_path"
		foreach cntry of global countries {
			// put data from given country into separate, temporary frame
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			
			// go to long
			reshape long t , i(bvdaccountnumber) j(year)
			keep if (year >= firstyear & year <= lastyear)
			capture drop t
					
			// save
			compress
			save nace2004_`cntry'.dta, replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}

	// 2006
	if `wv' == 2006 {
		clear
		//
		cd "$originaldta_path"
		cd "2006 March"
		use bvdidnumber bvdaccountnumber country nacerev11primarycode nacerev11primarycodedescription using p12_nacedescription.dta
		bysort bvdidnumber bvdaccountnumber : gen df = _n - 1
		drop if df > 0
		drop df
		drop if bvdidnumber == ""
		merge 1:1 bvdidnumber bvdaccountnumber using p1_header.dta, keepusing(lastyear numberofyears) nogenerate
		ren nacerev11primarycode nacecode
		ren nacerev11primarycodedescription description

		// time
		drop if lastyear > 2006
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		
		// drop obs which have few bvdidnumbers for one bvdaccountnumber as nace does not differ among bvdidnumber
		bys bvdidnumber : gen d = _n - 1
		drop if d > 0
		drop d
		
		// modify dataset
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SERBIA" if country == "SERBIA AND MONTENEGRO" 
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		// correction
		replace nacecode = . if nacecode == 9999
		replace nacecode = 911 if description == "Activities of business, employers and professional organisations"
		replace nacecode = 911 if description == "Activities of business, employers' and professional organisations"
		replace nacecode = 913 if description == "Activities of other membership organisations"
		replace nacecode = 14 if description == "Agricultural and animal husbandry service activities, except veterinary activities"
		replace nacecode = 11 if description == "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction excluding surveying"
		replace nacecode = 20 if description == "Forestry,  logging and related service activities"
		replace nacecode = 2710 if description == "Other first processing of iron and steel and production of non-ESCS ferro-alloys"
		replace nacecode = 524 if description == "Other retail sale of new goods in specialised stores"
		replace nacecode = 701 if description == "Real estate activities with own or leased property"
		replace nacecode = 522 if description == "Retail sale of food, beverage and tobacco in specialized stores"
		replace nacecode = 2010 if description == "Sawmilling and planing of wood, impregnation of wood"
		replace nacecode = 266 if description == "Manufacture of articles of concrete, plaster or cement"

		replace description = "Agricultural and animal husbandry service activities, except veterinary activities; landscape gardening" if description == "Agricultural and animal husbandry service activities, except veterinary activities"
		replace description = "Agricultural service activities; landscape gardening" if description == "Agricultural service activities"
		replace description = "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction, excluding surveying" if description == "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction excluding surveying"
		replace description = "Forestry, logging and related service activities" if description == "Forestry,  logging and related service activities"
		replace description = "Growing of vegetables, horticultural specialities and nursery products" if description == "Growing of vegetables, horticultural specialties and nursery products"

		// strL to str#
		generate str description_str = description
		replace description = ""
		compress description
		replace description = description_str
		drop description_str

		// merge with nace rev 1.1 list
		cd "$nace_path\_nace_check"

		merge n:1 nacecode using nace11listunique, generate(m1) update
		drop if m1 == 2

		merge n:1 description using nace11listduplicates, generate(m2) update replace
		drop if m2 == 2

		merge n:1 description using nace11listuniquedesc, generate(m3) update
		drop if m3 == 2

		gen expl = 0
		replace expl = 1 if m1>2 | m2>2 | m3>2

		replace nacecode = . if expl == 0
		ren code originalnace11
		keep bvdidnumber bvdaccountnumber country nacecode mainsector nace11twodigit nace11threedigit nace11fourdigit originalnace11 lastyear first
		ren nacecode nace11_2006
		ren mainsector mainsector_2006
		ren nace11twodigit nace11twodigit_2006
		ren nace11threedigit nace11threedigit_2006
		ren nace11fourdigit nace11fourdigit_2006
		ren originalnace11 originalnace11_2006
		gen source_2006 = 2006
		replace nace11fourdigit_2006 = subinstr(nace11fourdigit_2006, ".", "", .)
		replace nace11threedigit_2006 = subinstr(nace11threedigit_2006, ".", "", .)
		replace nace11twodigit_2006 = subinstr(nace11twodigit_2006, ".", "", .)
		
		//
		capture drop level_2006 code
		gen code = ""
		gen level_2006 = .
		replace code = nace11fourdigit_2006
		replace level_2006 = 4 if code != ""
		replace code = nace11threedigit_2006 if code == ""
		replace level_2006 = 3 if nace11fourdigit_2006 == "" & nace11threedigit_2006 != "" & level_2006 == .
		replace code = nace11twodigit_2006 if code == ""
		replace level_2006 = 2 if nace11fourdigit_2006 == "" & nace11threedigit_2006 == "" & nace11twodigit_2006 != "" & level_2006 == .
		drop nace11twodigit_2006 nace11threedigit_2006 nace11fourdigit_2006 originalnace11_2006 nace11_2006
		ren code nace_2006

		// generate time variables
		forvalues i = 1992(1)2005 {
			gen t`i' = .
			replace t`i' = `i' if (`i' >= firstyear & `i' <= lastyear)
		}
		
		// reshape and save by country
		global countries "AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE"
		cd "$nace_path"
		foreach cntry of global countries {
			// put data from given country into separate, temporary frame
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			
			// go to long
			reshape long t , i(bvdaccountnumber) j(year)
			keep if (year >= firstyear & year <= lastyear)
			capture drop t
					
			// save
			compress
			save nace2006_`cntry'.dta, replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	// 2008
	if `wv' == 2008 {
		clear
		//
		cd "$originaldta_path"
		cd "2008 May"

		use bvdepidnumber bvdepaccountnumber country nacerev11primarycode nacerev11primarycodedescription using activities.dta
		bysort bvdepidnumber bvdepaccountnumber : gen df = _n - 1
		drop if df > 0
		drop df
		drop if bvdepidnumber == ""
		merge 1:n bvdepidnumber bvdepaccountnumber using header.dta , keepusing(lastyear numberofyears)
		ren nacerev11primarycode nacecode
		ren nacerev11primarycodedescription description
		ren bvdepidnumber bvdidnumber
		ren bvdepaccountnumber bvdaccountnumber
		bysort bvdidnumber bvdaccountnumber : gen df = _n - 1
		drop if df > 0
		drop df

		// time
		drop if lastyear > 2008
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		
		// drop obs which have few bvdidnumbers for one bvdaccountnumber as nace does not differ among bvdidnumber
		bys bvdidnumber : gen d = _n - 1
		drop if d > 0
		drop d		
		
		// modify dataset
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA-HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "IRELAND" if country == "EIRE (IRELAND)"
		replace country = "MACEDONIA" if country == "REPUBLIC OF MACEDONIA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "SERBIA" if country == "SERBIA AND MONTENEGRO" 
		replace country = "SLOVAKIA" if country == "SLOVAK REPUBLIC"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		// strL to str#
		generate str description_str = description
		replace description = ""
		compress description
		replace description = description_str
		drop description_str

		// correction
		replace nacecode = . if nacecode == 9999
		replace nacecode = 522 if description == "Retail sale of food, beverage and tobacco in specialized stores"
		replace nacecode = 7310 if description == "Research and experimental development on natural sciences and engineering (NSE)"
		replace nacecode = 701 if description == "Real estate activities with own or leased property"
		replace nacecode = 524 if description == "Other retail sale of new goods in specialised stores"
		replace nacecode = 2710 if description == "Other first processing of iron and steel and production of non-ESCS ferro-alloys"
		replace nacecode = 2710 if description == "Manufacture of basic iron and steel and of ferro-alloys (ECSC)"
		replace nacecode = 266 if description == "Manufacture of articles of concrete, plaster or cement"
		replace nacecode = 20 if description == "Forestry,  logging and related service activities"
		replace nacecode = 11 if description == "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction excluding surveying"
		replace nacecode = 14 if description == "Agricultural and animal husbandry service activities, except veterinary activities"
		replace nacecode = 913 if description == "Activities of other membership organisations"
		replace nacecode = 911 if description == "Activities of business, employers and professional organisations"
		replace nacecode = 911 if description == "Activities of business, employers' and professional organisations"
		replace nacecode = 9500 if description == "Activities of households as employers of domestic  staff"
		replace nacecode = 2010 if description == "Sawmilling and planing of wood, impregnation of wood"

		replace description = "Growing of vegetables, horticultural specialities and nursery products" if description == "Growing of vegetables, horticultural specialties and nursery products"
		replace description = "Agricultural service activities; landscape gardening" if description == "Agricultural service activities"

		replace description = "Forestry, logging and related service activities" if description == "Forestry,  logging and related service activities"
		replace description = "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction, excluding surveying" if description == "Extraction of crude petroleum and natural gas; service activities incidental to oil and gas extraction excluding surveying"

		// merge with nace rev 1.1 list
		cd "$nace_path\_nace_check"

		merge n:1 nacecode using nace11listunique, generate(m1) update
		drop if m1 == 2

		merge n:1 description using nace11listduplicates, generate(m2) update replace
		drop if m2 == 2

		merge n:1 description using nace11listuniquedesc, generate(m3) update replace
		drop if m3 == 2

		gen expl = 0
		replace expl = 1 if m1>2 | m2>2 | m3>2

		replace nacecode = . if expl == 0

		ren code originalnace11
		keep bvdidnumber bvdaccountnumber country nacecode mainsector nace11twodigit nace11threedigit nace11fourdigit originalnace11 lastyear first
		ren nacecode nace11_2008
		ren mainsector mainsector_2008
		ren nace11twodigit nace11twodigit_2008
		ren nace11threedigit nace11threedigit_2008
		ren nace11fourdigit nace11fourdigit_2008
		ren originalnace11 originalnace11_2008
		gen source_2008 = 2008
		replace nace11fourdigit_2008 = subinstr(nace11fourdigit_2008, ".", "", .)
		replace nace11threedigit_2008 = subinstr(nace11threedigit_2008, ".", "", .)
		replace nace11twodigit_2008 = subinstr(nace11twodigit_2008, ".", "", .)
		
		//
		capture drop level_2008 code
		gen code = ""
		gen level_2008 = .
		replace code = nace11fourdigit_2008
		replace level_2008 = 4 if code != ""
		replace code = nace11threedigit_2008 if code == ""
		replace level_2008 = 3 if nace11fourdigit_2008 == "" & nace11threedigit_2008 != "" & level_2008 == .
		replace code = nace11twodigit_2008 if code == ""
		replace level_2008 = 2 if nace11fourdigit_2008 == "" & nace11threedigit_2008 == "" & nace11twodigit_2008 != "" & level_2008 == .
		drop nace11twodigit_2008 nace11threedigit_2008 nace11fourdigit_2008 originalnace11_2008 nace11_2008
		ren code nace_2008

		// generate time variables
		forvalues i = 1994(1)2008 {
			gen t`i' = .
			replace t`i' = `i' if (`i' >= firstyear & `i' <= lastyear)
		}
		
		// reshape and save by country
		global countries "AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE"
		cd "$nace_path"
		foreach cntry of global countries {
			// put data from given country into separate, temporary frame
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			
			// go to long
			reshape long t , i(bvdaccountnumber) j(year)
			keep if (year >= firstyear & year <= lastyear)
			capture drop t
					
			// save
			compress
			save nace2008_`cntry'.dta, replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}

	// 2010
	if `wv' == 2010 {
		clear
		//
		cd "$fvar_path"
		use key_2010
		capture drop conscode
		
		// standardize countries
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "MOLDOVA REPUBLIC OF"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"
		
		// time
		destring lastyear numberofyears, replace
		gen firstyear = lastyear - numberofyears + 1
		replace firstyear = lastyear if numberofyears == 0
		replace firstyear = . if lastyear == .
		
		//
		order bvdidnumber bvdaccountnumber country nace* lastyear firstyear
		ren nacerev2primarycode nace2
	
		// check nacecodes with the list
		cd "$nace_path\_nace_check"
		replace nace2 = subinstr(nace2, " ", "0", .)
		ren nace2 nacecode
		merge n:1 nacecode using nace2list.dta
		drop if _merge == 2
		drop _merge
		ren nacecode nace2

		keep bvdidnumber bvdaccountnumber country code nace2 mainsector nace2twodigit nace2threedigit nace2fourdigit lastyear first
		ren nace2 originalnace2_2010
		ren mainsector mainsector_2010
		ren nace2twodigit nace2twodigit_2010
		ren nace2threedigit nace2threedigit_2010
		ren nace2fourdigit nace2fourdigit_2010
		ren code nace2_2010
		gen source_2010 = 2010
		replace nace2fourdigit_2010 = subinstr(nace2fourdigit_2010, ".", "", .)
		replace nace2threedigit_2010 = subinstr(nace2threedigit_2010, ".", "", .)
		replace nace2twodigit_2010 = subinstr(nace2twodigit_2010, ".", "", .)
		
		//
		capture drop level_2010 code
		gen code = ""
		gen level_2010 = .
		replace code = nace2fourdigit_2010
		replace level_2010 = 4 if code != ""
		replace code = nace2threedigit_2010 if code == ""
		replace level_2010 = 3 if nace2fourdigit_2010 == "" & nace2threedigit_2010 != "" & level_2010 == .
		replace code = nace2twodigit_2010 if code == ""
		replace level_2010 = 2 if nace2fourdigit_2010 == "" & nace2threedigit_2010 == "" & nace2twodigit_2010 != "" & level_2010 == .
		drop nace2twodigit_2010 nace2threedigit_2010 nace2fourdigit_2010 originalnace2_2010 nace2_2010
		ren code nace_2010

		
		// generate time variables
		forvalues i = 1983(1)2010 {
			gen t`i' = .
			replace t`i' = `i' if (`i' >= firstyear & `i' <= lastyear)
		}
		
		// reshape and save by country
		global countries "ALBANIA AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UK UKRAINE"
		cd "$nace_path"
		foreach cntry of global countries {
			// put data from given country into separate, temporary frame
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			
			// go to long
			reshape long t , i(bvdaccountnumber) j(year)
			keep if (year >= firstyear & year <= lastyear)
			capture drop t
					
			// save
			compress
			save nace2010_`cntry'.dta, replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}

	// 2014
	if `wv' == 2014 {
		clear
		cd "$originaldta_path"
		cd "2014 May"
		
		use country bvdidnumber bvdaccountnumber lastyear numberofavailableyears using accountinginfo.dta
		drop if bvdidnumber == "Credit needed"
		
		merge 1:1 bvdidnumber using nace.dta, keepusing(nacerev2primarycode) nogenerate
		destring lastyear numberofavailableyears, replace
		drop if lastyear > 2014
		
		// drop obs which have few bvdidnumbers for one bvdaccountnumber as nace does not differ among bvdidnumber
		bys bvdidnumber : gen d = _n - 1
		drop if d > 0
		drop d			
		
		// distribute across time
		gen firstyear = lastyear - numberofavailableyears + 1
		replace firstyear = lastyear if numberofavailableyears == 0
		
		// modify dataset
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "REPUBLIC OF MOLDOVA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"
			
		//
		ren nacerev2primarycode nace2
		
		// check nacecodes with the list
		cd "$nace_path\_nace_check"
		replace nace2 = subinstr(nace2, " ", "0", .)
		ren nace2 nacecode
		merge n:1 nacecode using nace2list.dta
		drop if _merge == 2
		drop _merge
		ren nacecode nace2
		
		keep bvdidnumber bvdaccountnumber country code nace2 mainsector nace2twodigit nace2threedigit nace2fourdigit lastyear first
		ren nace2 originalnace2_2014
		ren mainsector mainsector_2014
		ren nace2twodigit nace2twodigit_2014
		ren nace2threedigit nace2threedigit_2014
		ren nace2fourdigit nace2fourdigit_2014
		ren code nace2_2014
		gen source_2014 = 2014
		replace nace2fourdigit_2014 = subinstr(nace2fourdigit_2014, ".", "", .)
		replace nace2threedigit_2014 = subinstr(nace2threedigit_2014, ".", "", .)
		replace nace2twodigit_2014 = subinstr(nace2twodigit_2014, ".", "", .)
		
		//
		capture drop level_2014 code
		gen code = ""
		gen level_2014 = .
		replace code = nace2fourdigit_2014
		replace level_2014 = 4 if code != ""
		replace code = nace2threedigit_2014 if code == ""
		replace level_2014 = 3 if nace2fourdigit_2014 == "" & nace2threedigit_2014 != "" & level_2014 == .
		replace code = nace2twodigit_2014 if code == ""
		replace level_2014 = 2 if nace2fourdigit_2014 == "" & nace2threedigit_2014 == "" & nace2twodigit_2014 != "" & level_2014 == .
		drop nace2twodigit_2014 nace2threedigit_2014 nace2fourdigit_2014 originalnace2_2014 nace2_2014
		ren code nace_2014
		
		// generate time variables
		forvalues i = 1999(1)2014 {
			gen t`i' = .
			replace t`i' = `i' if (`i' >= firstyear & `i' <= lastyear)
		}
		
		// reshape and save by country
		global countries "AUSTRIA ALBANIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UK UKRAINE"
		cd "$nace_path"
		foreach cntry of global countries {
			// put data from given country into separate, temporary frame
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			
			// go to long
			reshape long t , i(bvdaccountnumber) j(year)
			keep if (year >= firstyear & year <= lastyear)
			capture drop t
					
			// save
			compress
			save nace2014_`cntry'.dta, replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}

	// 2016
	if `wv' == 2016 {
		clear
		cd "$originaldta_path"
		cd "2016 May"

		append using amadeus_2016_additional_1.dta , keep(bvdidnumber bvdaccountnumber country lastyear numberofavailableyears nacerev2primarycode)
		append using amadeus_2016_additional_2.dta , keep(bvdidnumber bvdaccountnumber country lastyear numberofavailableyears nacerev2primarycode)
		drop if bvdidnumber=="Credit needed" | bvdidnumber == ""
		destring lastyear numberofavailableyears, replace

		// distribute across time
		drop if lastyear > 2016
		gen firstyear = lastyear - numberofavailableyears + 1
		replace firstyear = lastyear if numberofavailableyears == 0
	
		// modify dataset
		replace country = ustrupper(country)
		replace country = "BOSNIA" if country == "BOSNIA AND HERZEGOVINA"
		replace country = "CZECH" if country == "CZECH REPUBLIC"
		replace country = "MACEDONIA" if country == "MACEDONIA (FYROM)"
		replace country = "MOLDOVA" if country == "REPUBLIC OF MOLDOVA"
		replace country = "RUSSIA" if country == "RUSSIAN FEDERATION"
		replace country = "UK" if country == "UNITED KINGDOM"
			
		//
		ren nacerev2primarycode nace2
		
		// check nacecodes with the list
		cd "$nace_path\_nace_check"
		replace nace2 = subinstr(nace2, " ", "0", .)
		ren nace2 nacecode
		merge n:1 nacecode using nace2list.dta
		drop if _merge == 2
		drop _merge
		ren nacecode nace2

		keep bvdidnumber bvdaccountnumber country code nace2 mainsector nace2twodigit nace2threedigit nace2fourdigit lastyear first
		ren nace2 originalnace2_2016
		ren mainsector mainsector_2016
		ren nace2twodigit nace2twodigit_2016
		ren nace2threedigit nace2threedigit_2016
		ren nace2fourdigit nace2fourdigit_2016
		ren code nace2_2016
		gen source_2016 = 2016
		replace nace2fourdigit_2016 = subinstr(nace2fourdigit_2016, ".", "", .)
		replace nace2threedigit_2016 = subinstr(nace2threedigit_2016, ".", "", .)
		replace nace2twodigit_2016 = subinstr(nace2twodigit_2016, ".", "", .)
		
		//
		capture drop level_2016 code
		gen code = ""
		gen level_2016 = .
		replace code = nace2fourdigit_2016
		replace level_2016 = 4 if code != ""
		replace code = nace2threedigit_2016 if code == ""
		replace level_2016 = 3 if nace2fourdigit_2016 == "" & nace2threedigit_2016 != "" & level_2016 == .
		replace code = nace2twodigit_2016 if code == ""
		replace level_2016 = 2 if nace2fourdigit_2016 == "" & nace2threedigit_2016 == "" & nace2twodigit_2016 != "" & level_2016 == .
		drop nace2twodigit_2016 nace2threedigit_2016 nace2fourdigit_2016 originalnace2_2016 nace2_2016
		ren code nace_2016

		// generate time variables
		forvalues i = 2001(1)2016 {
			gen t`i' = .
			replace t`i' = `i' if (`i' >= firstyear & `i' <= lastyear)
		}
		
		// reshape and save by country
		global countries "AUSTRIA ALBANIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UK UKRAINE"
		cd "$nace_path"
		foreach cntry of global countries {
			// put data from given country into separate, temporary frame
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			
			// go to long
			reshape long t , i(bvdaccountnumber) j(year)
			keep if (year >= firstyear & year <= lastyear)
			capture drop t
					
			// save
			compress
			save nace2016_`cntry'.dta, replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	// 2020
	if `wv' == 2020 {
		clear
		
		// import data
		forvalues i = 1(1)100 {
		    di "`i'/100"
		    append using "$originaldta_path\2020\financials_2020_`i'.dta" , keep(bvdidnumber closingdate)
		}
		tostring closingdate, replace
		gen year = substr(closingdate, 1, 4)
		destring year, replace
		drop closingdate
		
		// choose unique firm-year observations
		bysort bvdidnumber year : gen dfy = _n - 1
		keep if dfy == 0
		drop dfy
		
		// merge nacecodes
		merge n:1 bvdidnumber using "$originaldta_path\2020\nace.dta"
		drop if _merge == 2
		drop _merge
		
		// countries
		capture drop country
		merge n:1 bvdidnumber using "$preparation_path\country_2020.dta"
		drop if _merge != 3
		drop _merge
		
		// save by country
		bys country : gen dc = _n - 1
		levelsof country if dc == 0 , clean
		global countries "`r(levels)'"
		di "$countries"
		drop dc
		
		//
		capture ren mainsec mainsector_2020
		capture ren nacerev2corecode nace_2020
		capture gen level_2020 = strlen(nace_2020)
		capture gen source_2020 = 2020

		
		foreach cntry of global countries {
			// put data from given country into separate, temporary frame
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
					
			// save
			compress
			save "$nace_path\nace2020_`cntry'.dta", replace
			
			// clear temporary frame before next iteration
			frame change default
			frame drop tempframe
		}
		clear
	}

}

// merge data from the same country and different waves
clear
cd "$nace_path"
global countries "ALBANIA AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UK UKRAINE YUGOSLAVIA"

foreach cntry of global countries {
	// join all nace files from one country
	global files: dir "$nace_path" file "nace*_`cntry'.dta"
	di $files
	local p = 1
	foreach file of global files {
		if `p' == 1 {
			use `file'
		}
		if (`p' > 1 ){
			merge 1:1 bvdidnumber year using `file', nogen
		}
		local p = `p' + 1
	}

	// aggregate nace codes within each classification
	
	// nace rev 1.1
	/* nace rev 1 was converted to nace rev 1.1 in earlier in 
	   this dofile (in section for wave 2002). We use this codes
	   unless latter waves does not provide nace 1.1 */
	
	gen mainsec_rev11 = ""
	gen nace_rev11 = ""
	gen level_rev11 = .
	gen source_rev11 = .

	foreach i in 2003 2004 2006 2008 2002 {
		capture replace mainsec_rev11 = mainsector_`i' if mainsec_rev11 == ""
		capture replace nace_rev11 = nace_`i' if nace_rev11 == ""
		capture replace level_rev11 = level_`i' if level_rev11 == .
		capture replace source_rev11 = source_`i' if source_rev11 == .	
	}
	
	// nace rev 2
	gen mainsec_rev2 = ""
	gen nace_rev2 = ""
	gen level_rev2 = .
	gen source_rev2 = .

	foreach i in 2010 2014 2016 2020 {
		capture replace mainsec_rev2 = mainsector_`i' if mainsec_rev2 == ""
		capture replace nace_rev2 = nace_`i' if nace_rev2 == ""
		capture replace level_rev2 = level_`i' if level_rev2 == .
		capture replace source_rev2 = source_`i' if source_rev2 == .	
	}
	
	// fix codes in nace 1.1
	{
	replace nace_rev11 = "0130" if nace_rev11 == "013"
	replace nace_rev11 = "0150" if nace_rev11 == "015"
	replace nace_rev11 = "1010" if nace_rev11 == "101"
	replace nace_rev11 = "1020" if nace_rev11 == "102"
	replace nace_rev11 = "1030" if nace_rev11 == "103"
	replace nace_rev11 = "1110" if nace_rev11 == "111"
	replace nace_rev11 = "1120" if nace_rev11 == "112"
	replace nace_rev11 = "1200" if nace_rev11 == "120" | nace_rev11 == "12"
	replace nace_rev11 = "1310" if nace_rev11 == "131"
	replace nace_rev11 = "1320" if nace_rev11 == "132"
	replace nace_rev11 = "1430" if nace_rev11 == "143"
	replace nace_rev11 = "1440" if nace_rev11 == "144"
	replace nace_rev11 = "1450" if nace_rev11 == "145"
	replace nace_rev11 = "1520" if nace_rev11 == "152"
	replace nace_rev11 = "1600" if nace_rev11 == "160" | nace_rev11 == "16"
	replace nace_rev11 = "1730" if nace_rev11 == "173"
	replace nace_rev11 = "1740" if nace_rev11 == "174"
	replace nace_rev11 = "1760" if nace_rev11 == "176"
	replace nace_rev11 = "1810" if nace_rev11 == "181"
	replace nace_rev11 = "1830" if nace_rev11 == "183"
	replace nace_rev11 = "1910" if nace_rev11 == "191"
	replace nace_rev11 = "1920" if nace_rev11 == "192"
	replace nace_rev11 = "1930" if nace_rev11 == "193"
	replace nace_rev11 = "2010" if nace_rev11 == "201"
	replace nace_rev11 = "2020" if nace_rev11 == "202"
	replace nace_rev11 = "2030" if nace_rev11 == "203"
	replace nace_rev11 = "2040" if nace_rev11 == "204"
	replace nace_rev11 = "2310" if nace_rev11 == "231"
	replace nace_rev11 = "2320" if nace_rev11 == "232"
	replace nace_rev11 = "2330" if nace_rev11 == "233"
	replace nace_rev11 = "2420" if nace_rev11 == "242"
	replace nace_rev11 = "2430" if nace_rev11 == "243"
	replace nace_rev11 = "2470" if nace_rev11 == "247"
	replace nace_rev11 = "2630" if nace_rev11 == "263"
	replace nace_rev11 = "2640" if nace_rev11 == "264"
	replace nace_rev11 = "2670" if nace_rev11 == "267"
	replace nace_rev11 = "2710" if nace_rev11 == "271"
	replace nace_rev11 = "2830" if nace_rev11 == "283"
	replace nace_rev11 = "2840" if nace_rev11 == "284"
	replace nace_rev11 = "2960" if nace_rev11 == "296"
	replace nace_rev11 = "3110" if nace_rev11 == "311"
	replace nace_rev11 = "3120" if nace_rev11 == "312"
	replace nace_rev11 = "3130" if nace_rev11 == "313"
	replace nace_rev11 = "3140" if nace_rev11 == "314"
	replace nace_rev11 = "3150" if nace_rev11 == "315"
	replace nace_rev11 = "3210" if nace_rev11 == "321"
	replace nace_rev11 = "3220" if nace_rev11 == "322"
	replace nace_rev11 = "3230" if nace_rev11 == "323"
	replace nace_rev11 = "3310" if nace_rev11 == "331"
	replace nace_rev11 = "3320" if nace_rev11 == "332"
	replace nace_rev11 = "3330" if nace_rev11 == "333"
	replace nace_rev11 = "3340" if nace_rev11 == "334"
	replace nace_rev11 = "3350" if nace_rev11 == "335"
	replace nace_rev11 = "3410" if nace_rev11 == "341"
	replace nace_rev11 = "3420" if nace_rev11 == "342"
	replace nace_rev11 = "3430" if nace_rev11 == "343"
	replace nace_rev11 = "3520" if nace_rev11 == "352"
	replace nace_rev11 = "3530" if nace_rev11 == "353"
	replace nace_rev11 = "3550" if nace_rev11 == "355"
	replace nace_rev11 = "3630" if nace_rev11 == "363"
	replace nace_rev11 = "3640" if nace_rev11 == "364"
	replace nace_rev11 = "3650" if nace_rev11 == "365"
	replace nace_rev11 = "3710" if nace_rev11 == "371"
	replace nace_rev11 = "3720" if nace_rev11 == "372"
	replace nace_rev11 = "4030" if nace_rev11 == "403"
	replace nace_rev11 = "4100" if nace_rev11 == "410" | nace_rev11 == "41"
	replace nace_rev11 = "4550" if nace_rev11 == "455"
	replace nace_rev11 = "5010" if nace_rev11 == "501"
	replace nace_rev11 = "5020" if nace_rev11 == "502"
	replace nace_rev11 = "5030" if nace_rev11 == "503"
	replace nace_rev11 = "5040" if nace_rev11 == "504"
	replace nace_rev11 = "5050" if nace_rev11 == "505"
	replace nace_rev11 = "5190" if nace_rev11 == "519"
	replace nace_rev11 = "5250" if nace_rev11 == "525"
	replace nace_rev11 = "5510" if nace_rev11 == "551"
	replace nace_rev11 = "5530" if nace_rev11 == "553"
	replace nace_rev11 = "5540" if nace_rev11 == "554"
	replace nace_rev11 = "6010" if nace_rev11 == "601"
	replace nace_rev11 = "6030" if nace_rev11 == "603"
	replace nace_rev11 = "6110" if nace_rev11 == "611"
	replace nace_rev11 = "6120" if nace_rev11 == "612"
	replace nace_rev11 = "6210" if nace_rev11 == "621"
	replace nace_rev11 = "6220" if nace_rev11 == "622"
	replace nace_rev11 = "6230" if nace_rev11 == "623"
	replace nace_rev11 = "6330" if nace_rev11 == "633"
	replace nace_rev11 = "6340" if nace_rev11 == "634"
	replace nace_rev11 = "6420" if nace_rev11 == "642"
	replace nace_rev11 = "6720" if nace_rev11 == "672"
	replace nace_rev11 = "7020" if nace_rev11 == "702"
	replace nace_rev11 = "7110" if nace_rev11 == "711"
	replace nace_rev11 = "7140" if nace_rev11 == "714"
	replace nace_rev11 = "7210" if nace_rev11 == "721"
	replace nace_rev11 = "7230" if nace_rev11 == "723"
	replace nace_rev11 = "7240" if nace_rev11 == "724"
	replace nace_rev11 = "7250" if nace_rev11 == "725"
	replace nace_rev11 = "7260" if nace_rev11 == "726"
	replace nace_rev11 = "7310" if nace_rev11 == "731"
	replace nace_rev11 = "7320" if nace_rev11 == "732"
	replace nace_rev11 = "7420" if nace_rev11 == "742"
	replace nace_rev11 = "7430" if nace_rev11 == "743"
	replace nace_rev11 = "7440" if nace_rev11 == "744"
	replace nace_rev11 = "7450" if nace_rev11 == "745"
	replace nace_rev11 = "7460" if nace_rev11 == "746"
	replace nace_rev11 = "7470" if nace_rev11 == "747"
	replace nace_rev11 = "7530" if nace_rev11 == "753"
	replace nace_rev11 = "8010" if nace_rev11 == "801"
	replace nace_rev11 = "8030" if nace_rev11 == "803"
	replace nace_rev11 = "8520" if nace_rev11 == "852"
	replace nace_rev11 = "9120" if nace_rev11 == "912"
	replace nace_rev11 = "9220" if nace_rev11 == "922"
	replace nace_rev11 = "9240" if nace_rev11 == "924"
	replace nace_rev11 = "9500" if nace_rev11 == "950" | nace_rev11 == "95"
	replace nace_rev11 = "9600" if nace_rev11 == "960" | nace_rev11 == "96"
	replace nace_rev11 = "9700" if nace_rev11 == "970" | nace_rev11 == "97"
	replace nace_rev11 = "9900" if nace_rev11 == "990" | nace_rev11 == "99"
	}
	
	// fix codes in nace 2
	{
	replace nace_rev2 = "0130" if nace_rev2 == "013"
	replace nace_rev2 = "0150" if nace_rev2 == "015"
	replace nace_rev2 = "0170" if nace_rev2 == "017"
	replace nace_rev2 = "0210" if nace_rev2 == "021"
	replace nace_rev2 = "0220" if nace_rev2 == "022"
	replace nace_rev2 = "0230" if nace_rev2 == "023"
	replace nace_rev2 = "0240" if nace_rev2 == "024"
	replace nace_rev2 = "0510" if nace_rev2 == "051"
	replace nace_rev2 = "0520" if nace_rev2 == "052"
	replace nace_rev2 = "0610" if nace_rev2 == "061"
	replace nace_rev2 = "0620" if nace_rev2 == "062"
	replace nace_rev2 = "0710" if nace_rev2 == "071"
	replace nace_rev2 = "0910" if nace_rev2 == "091"
	replace nace_rev2 = "0990" if nace_rev2 == "099"
	replace nace_rev2 = "1020" if nace_rev2 == "102"
	replace nace_rev2 = "1200" if nace_rev2 == "12" | nace_rev2 == "120"
	replace nace_rev2 = "1310" if nace_rev2 == "131"
	replace nace_rev2 = "1320" if nace_rev2 == "132"
	replace nace_rev2 = "1330" if nace_rev2 == "133"
	replace nace_rev2 = "1420" if nace_rev2 == "142"
	replace nace_rev2 = "1520" if nace_rev2 == "152"
	replace nace_rev2 = "1610" if nace_rev2 == "161"
	replace nace_rev2 = "1820" if nace_rev2 == "182"
	replace nace_rev2 = "1910" if nace_rev2 == "191"
	replace nace_rev2 = "1920" if nace_rev2 == "192"
	replace nace_rev2 = "2020" if nace_rev2 == "202"
	replace nace_rev2 = "2030" if nace_rev2 == "203"
	replace nace_rev2 = "2060" if nace_rev2 == "206"
	replace nace_rev2 = "2110" if nace_rev2 == "211"
	replace nace_rev2 = "2120" if nace_rev2 == "212"
	replace nace_rev2 = "2320" if nace_rev2 == "232"
	replace nace_rev2 = "2370" if nace_rev2 == "237"
	replace nace_rev2 = "2410" if nace_rev2 == "241"
	replace nace_rev2 = "2420" if nace_rev2 == "242"
	replace nace_rev2 = "2530" if nace_rev2 == "253"
	replace nace_rev2 = "2540" if nace_rev2 == "254"
	replace nace_rev2 = "2550" if nace_rev2 == "255"
	replace nace_rev2 = "2620" if nace_rev2 == "262"
	replace nace_rev2 = "2630" if nace_rev2 == "263"
	replace nace_rev2 = "2640" if nace_rev2 == "264"
	replace nace_rev2 = "2660" if nace_rev2 == "266"
	replace nace_rev2 = "2670" if nace_rev2 == "267"
	replace nace_rev2 = "2680" if nace_rev2 == "268"
	replace nace_rev2 = "2720" if nace_rev2 == "272"
	replace nace_rev2 = "2740" if nace_rev2 == "274"
	replace nace_rev2 = "2790" if nace_rev2 == "279"
	replace nace_rev2 = "2830" if nace_rev2 == "283"
	replace nace_rev2 = "2910" if nace_rev2 == "291"
	replace nace_rev2 = "2920" if nace_rev2 == "292"
	replace nace_rev2 = "3020" if nace_rev2 == "302"
	replace nace_rev2 = "3030" if nace_rev2 == "303"
	replace nace_rev2 = "3040" if nace_rev2 == "304"
	replace nace_rev2 = "3220" if nace_rev2 == "322"
	replace nace_rev2 = "3230" if nace_rev2 == "323"
	replace nace_rev2 = "3240" if nace_rev2 == "324"
	replace nace_rev2 = "3250" if nace_rev2 == "325"
	replace nace_rev2 = "3320" if nace_rev2 == "332"
	replace nace_rev2 = "3530" if nace_rev2 == "353"
	replace nace_rev2 = "3600" if nace_rev2 == "36" | nace_rev2 == "360"
	replace nace_rev2 = "3700" if nace_rev2 == "37" | nace_rev2 == "370"
	replace nace_rev2 = "3900" if nace_rev2 == "39" | nace_rev2 == "390"
	replace nace_rev2 = "4110" if nace_rev2 == "411"
	replace nace_rev2 = "4120" if nace_rev2 == "412"
	replace nace_rev2 = "4520" if nace_rev2 == "452"
	replace nace_rev2 = "4540" if nace_rev2 == "454"
	replace nace_rev2 = "4690" if nace_rev2 == "469"
	replace nace_rev2 = "4730" if nace_rev2 == "473"
	replace nace_rev2 = "4910" if nace_rev2 == "491"
	replace nace_rev2 = "4920" if nace_rev2 == "492"
	replace nace_rev2 = "4950" if nace_rev2 == "495"
	replace nace_rev2 = "5010" if nace_rev2 == "501"
	replace nace_rev2 = "5020" if nace_rev2 == "502"
	replace nace_rev2 = "5030" if nace_rev2 == "503"
	replace nace_rev2 = "5040" if nace_rev2 == "504"
	replace nace_rev2 = "5110" if nace_rev2 == "511"
	replace nace_rev2 = "5210" if nace_rev2 == "521"
	replace nace_rev2 = "5310" if nace_rev2 == "531"
	replace nace_rev2 = "5320" if nace_rev2 == "532"
	replace nace_rev2 = "5510" if nace_rev2 == "551"
	replace nace_rev2 = "5520" if nace_rev2 == "552"
	replace nace_rev2 = "5530" if nace_rev2 == "553"
	replace nace_rev2 = "5590" if nace_rev2 == "559"
	replace nace_rev2 = "5610" if nace_rev2 == "561"
	replace nace_rev2 = "5630" if nace_rev2 == "563"
	replace nace_rev2 = "5920" if nace_rev2 == "592"
	replace nace_rev2 = "6010" if nace_rev2 == "601"
	replace nace_rev2 = "6020" if nace_rev2 == "602"
	replace nace_rev2 = "6110" if nace_rev2 == "611"
	replace nace_rev2 = "6120" if nace_rev2 == "612"
	replace nace_rev2 = "6130" if nace_rev2 == "613"
	replace nace_rev2 = "6190" if nace_rev2 == "619"
	replace nace_rev2 = "6420" if nace_rev2 == "642"
	replace nace_rev2 = "6430" if nace_rev2 == "643"
	replace nace_rev2 = "6520" if nace_rev2 == "652"
	replace nace_rev2 = "6530" if nace_rev2 == "653"
	replace nace_rev2 = "6630" if nace_rev2 == "663"
	replace nace_rev2 = "6810" if nace_rev2 == "681"
	replace nace_rev2 = "6820" if nace_rev2 == "682"
	replace nace_rev2 = "6910" if nace_rev2 == "691"
	replace nace_rev2 = "6920" if nace_rev2 == "692"
	replace nace_rev2 = "7010" if nace_rev2 == "701"
	replace nace_rev2 = "7120" if nace_rev2 == "712"
	replace nace_rev2 = "7220" if nace_rev2 == "722"
	replace nace_rev2 = "7320" if nace_rev2 == "732"
	replace nace_rev2 = "7410" if nace_rev2 == "741"
	replace nace_rev2 = "7420" if nace_rev2 == "742"
	replace nace_rev2 = "7430" if nace_rev2 == "743"
	replace nace_rev2 = "7490" if nace_rev2 == "749"
	replace nace_rev2 = "7500" if nace_rev2 == "75" | nace_rev2 == "750"
	replace nace_rev2 = "7740" if nace_rev2 == "774"
	replace nace_rev2 = "7810" if nace_rev2 == "781"
	replace nace_rev2 = "7820" if nace_rev2 == "782"
	replace nace_rev2 = "7830" if nace_rev2 == "783"
	replace nace_rev2 = "7990" if nace_rev2 == "799"
	replace nace_rev2 = "8010" if nace_rev2 == "801"
	replace nace_rev2 = "8020" if nace_rev2 == "802"
	replace nace_rev2 = "8030" if nace_rev2 == "803"
	replace nace_rev2 = "8110" if nace_rev2 == "811"
	replace nace_rev2 = "8130" if nace_rev2 == "813"
	replace nace_rev2 = "8220" if nace_rev2 == "822"
	replace nace_rev2 = "8230" if nace_rev2 == "823"
	replace nace_rev2 = "8430" if nace_rev2 == "843"
	replace nace_rev2 = "8510" if nace_rev2 == "851"
	replace nace_rev2 = "8520" if nace_rev2 == "852"
	replace nace_rev2 = "8560" if nace_rev2 == "856"
	replace nace_rev2 = "8610" if nace_rev2 == "861"
	replace nace_rev2 = "8690" if nace_rev2 == "869"
	replace nace_rev2 = "8710" if nace_rev2 == "871"
	replace nace_rev2 = "8720" if nace_rev2 == "872"
	replace nace_rev2 = "8730" if nace_rev2 == "873"
	replace nace_rev2 = "8790" if nace_rev2 == "879"
	replace nace_rev2 = "8810" if nace_rev2 == "881"
	replace nace_rev2 = "9200" if nace_rev2 == "92" | nace_rev2 == "920"
	replace nace_rev2 = "9420" if nace_rev2 == "942"
	replace nace_rev2 = "9700" if nace_rev2 == "97" | nace_rev2 == "970"
	replace nace_rev2 = "9810" if nace_rev2 == "981"
	replace nace_rev2 = "9820" if nace_rev2 == "982"
	replace nace_rev2 = "9900" if nace_rev2 == "99" | nace_rev2 == "990"
	}
	
	// -- impute nace in inside missings when nace is constant -- //
	egen idfirm = group(bvdidnumber)
	
	// impute nace 11
	qui count if nace_rev11!=""
	if `r(N)'!=0{
		gen indic11 = 1 if nace_rev11 != ""
		mipolate indic11 year, by(idfirm) gen(missin11) linear
		replace missin11 = . if indic11==1
		qui summ missin11
		if `r(N)'!=0 {
			egen see11 = max(missin11) , by(bvdidnumber) 	
			sort bvdidnumber year
			by bvdidnumber: stripolate nace_rev11 year if see11==1, gen(imp11) groupwise
			replace imp11 = "" if missin11!=1
			replace nace_rev11 = imp11 if nace_rev11==""	
			drop indic* see* imp*
		}
	}
	
	// impute nace 2
	qui count if nace_rev2!=""
	if `r(N)'!=0{
		gen indic2 = 1 if nace_rev2 != ""
		mipolate indic2 year, by(idfirm) gen(missin2) linear 
		replace missin2  = . if indic2 ==1
		qui summ missin2
		if `r(N)'!=0 {
			egen see2  = max(missin2 ) , by(bvdidnumber)
			sort bvdidnumber year
			by bvdidnumber: stripolate nace_rev2 year if see2==1, gen(imp2) groupwise
			replace imp2 = "" if missin2!=1
			replace nace_rev2 = imp2 if nace_rev2==""
			drop indic* see* imp*
		}
	}
	cap drop idfirm
	
	// -- aggregate nace codes between available classifications -- //
	
	// drop unncecessary variables
	foreach i in mainsector_ source_ nace_ level_ {
		foreach j in 2002 2002_1 2003 2004 2006 2008 2010 2014 2016 2020 {
			capture confirm variable `i'`j'
			if _rc == 0 {
				drop `i'`j'
			}
		}
	}
	drop lastyear firstyear bvdaccountnumber
	
	// case 1: we want to have nace 1.1 when it was official classiffication in use (period before 2007), and the same for nace 2 (period after 2008). This is prepared for matching Amadeus data with SES.
	foreach i in nace mainsec source level {
		capture drop `i'_ses
		if ("`i'" == "nace" | "`i'" == "mainsec") {
			gen `i'_ses = ""
		}
		else {
			gen `i'_ses = .
		}
		capture replace `i'_ses = `i'_rev11 if year <= 2007 & year != .
		capture replace `i'_ses = `i'_rev2 if year >= 2008 & year != .
	}
	
	// whole ses thing? translation+conversion
	
	// case 2: whenever possible use nace rev 2. If this classification is not available, use nace rev 1.1. Observations with nace rev 1.1 will be later translated to nace rev 2 whenever possible.
	
	// conversion
	do "$dofiles_path\_nace_crosswalk_nace11_to_nace2.do"
	
	//
	gen classtype_rev11 = .
	replace classtype_rev11 = 11 if nace_rev11 != ""
	gen classtype_rev2 = .
	replace classtype_rev2 = 2 if nace_rev2 != ""
	
	foreach i in nace mainsec source level classtype {
		capture drop `i'
		if ("`i'" == "nace" | "`i'" == "mainsec") {
			gen `i' = ""
		}
		else {
			gen `i' = .
		}
		capture replace `i'	= `i'_rev2
		capture replace `i' = `i'_rev11 if missing(`i')
	}
	
	replace nace = nace_rev2_crosswalk if classtype == 11
	replace conversion_type = . if classtype != 11
	
	// save dataset
	compress
	save "$nace_path\nace`cntry'.dta" , replace
	clear
}


/*
// join all missing nace data
clear
global files: dir "$nace_path" file "missing*.dta"
di $files
cd "$nace_path"
foreach i of global files {
	append using `i'
}

// keep only unique cases
bys nace : gen unique = _n - 1
keep if unique  == 0
keep nace

// create nace 11 as in official classification
gen nace1official = substr(nace, 1 , 2) + "."+ substr(nace, 3 , 2)
replace nace1official = nace if strlen(nace) < 3
save "$nace_path\missingALL.dta" , replace

// merge with old manual crosswalk
ren nace nace1str 
merge 1:1 nace1str using "$nace_path\_nace_old\missing_nace1v2.dta"
ren nace1str nace 

// create nace 2 codes ready to be used (without dot)
gen nace2 = ""
replace nace2 = substr(nace2dot, 1, 2) + substr(nace2dot, 4, 2) if strlen(nace2dot) == 5
replace nace2 = "0" + substr(nace2dot, 1, 1) + substr(nace2dot, 3, 2) if strlen(nace2dot) == 4

// check if nace 11 in manual crosswalk are correct
gen correct = 0
replace correct = 1 if nace1dot == nace1official

// indicator what to do with praticualar code
gen to_do = .
/*  description:
	1 - to do
	2 - to check (sth was done but not sure)
	3 - consider its done
*/

// if _merge == 1 => codes that appear in data but does not have translation
replace to_do = 1 if _merge == 1

// if _merge == 2 => unncecessary or incorrect translation
drop if _merge == 2

// if _merge == 3 correct = 1 => ready to use, unless nace2 not empty 
replace to_do = 3 if _merge == 3 & correct == 1 & nace2!=""
replace to_do = 1 if _merge == 3 & correct == 1 & nace2==""

// if _merge == 3 correct = 0 => nace 11 was originally interpreted incorrectly
replace to_do = 2 if _merge == 3 & correct == 0 & nace2!=""
replace to_do = 1 if _merge == 3 & correct == 0 & nace2==""

// keep necessary vars
keep nace nace1official nace1dot nace2dot nace2 to_do
ren nace nace11
ren nace1official nace11official
ren nace1dot nace11_which_we_saw
ren nace2dot nace2official

label define to_do_lab 1 "to do" 2 "to check" 3 "done"
label values to_do to_do_lab
drop if nace11 == ""

// save
save "$nace_path\crosswalk_to_do.dta", replace
*/