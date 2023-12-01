/******************************************************************************/
/*	 				Split managers and append by country  					  */
/******************************************************************************/
clear

global waves "2002 2003 2004 2006 2008 2010 2014 2016 2020"

// split by country in each wave
foreach wave of global waves {
	di "********* `wave' *********************************************************"
	
	if `wave' == 2002 {
	    clear
		global countries "AUSTRIA BELGIUM BOSNIA BULGARIA CROATIA CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LITHUANIA LUXEMBOURG MACEDONIA NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE YUGOSLAVIA"
		use "$preparation_path\managers_`wave'.dta"
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen source = `wave'
			ren managername fullname
			// reshape here
			compress
			save "$bycountry_path\_`cntry'\managers_`wave'_`cntry'.dta" , replace
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	if `wave' == 2003 {
		clear
		global countries "AUSTRIA BELGIUM BOSNIA BULGARIA CROATIA CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MONACO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE"
		use "$preparation_path\managers_`wave'.dta"
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen source = `wave'
			ren managerfullname fullname
			compress
			save "$bycountry_path\_`cntry'\managers_`wave'_`cntry'.dta" , replace
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	if `wave' == 2004 {
		clear
		global countries "AUSTRIA BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MONACO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE"
		use "$preparation_path\managers_`wave'.dta"
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen source = `wave'
			ren managerfullname fullname
			compress
			save "$bycountry_path\_`cntry'\managers_`wave'_`cntry'.dta" , replace
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	if `wave' == 2006 {
		clear
		global countries "AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE"
		use "$preparation_path\managers_`wave'.dta"
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen source = `wave'
			ren managerfullname fullname
			compress
			save "$bycountry_path\_`cntry'\managers_`wave'_`cntry'.dta" , replace
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	if `wave' == 2008 {
		clear
		global countries "AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND UK UKRAINE"
		use "$preparation_path\managers_`wave'.dta"
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen source = `wave'
			ren title managerfunction
			
			// titlesince
			capture drop titlesinceyear
			gen titlesinceyear = substr(titlesince, strlen(titlesince) - 3, strlen(titlesince))
			destring titlesinceyear, replace force
			drop titlesince
			
			compress
			save "$bycountry_path\_`cntry'\managers_`wave'_`cntry'.dta" , replace
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	if `wave' == 2010 {
		clear
		global countries "ALBANIA AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UK UKRAINE"
		use "$preparation_path\managers_`wave'.dta"
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen source = `wave'
			ren bmoriginaljobtitle managerfunction
			ren bm* *
			ren boardcommitteeorexecutivedepar boardcommitteeordepartment
			capture ren levelofresponsability levelofresponsibility
			compress
			save "$bycountry_path\_`cntry'\managers_`wave'_`cntry'.dta" , replace
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	if `wave' == 2014 {
		clear
		global countries "ALBANIA AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UK UKRAINE" 
		use "$preparation_path\managers_`wave'.dta"
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen source = `wave'
			ren dmcoriginaljobtitleinenglish managerfunction
			ren dmc* *
			
			// confirmation dates
			gen len = strlen(confirmationdates)
			summ len
			if `r(mean)' != 0 {  
				replace confirmationdates = subinstr(confirmationdates, ";", " ", .)
				replace confirmationdates = stritrim(confirmationdates)
				forvalues i = 0(1)9 {
					di "---- `i' ----"
					replace confirmationdates = subinstr(confirmationdates, "0`i'/", "", .)
					replace confirmationdates = subinstr(confirmationdates, "1`i'/", "", .)
					replace confirmationdates = subinstr(confirmationdates, "2`i'/", "", .)
				}
				replace confirmationdates = subinstr(confirmationdates, "30/", "", .)
				replace confirmationdates = subinstr(confirmationdates, "31/", "", .)
				split confirmationdates, generate(confdate) destring
				egen confirmationdatemin = rowmin(confdate*)
				egen confirmationdatemax = rowmax(confdate*)
				drop confdate*
			}
			compress
			save "$bycountry_path\_`cntry'\managers_`wave'_`cntry'.dta" , replace
			frame change default
			frame drop tempframe
			}
		clear
	}
	
	if `wave' == 2016 {
		clear
		global countries "ALBANIA AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UK UKRAINE"
		use "$preparation_path\managers_`wave'.dta"
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen source = `wave'
			ren dmcoriginaljobtitleinenglish managerfunction
			ren dmc* *
			
			// confirmation dates
			gen len = strlen(confirmationdates)
			summ len
			if `r(mean)' != 0 {  
				replace confirmationdates = subinstr(confirmationdates, ";", " ", .)
				replace confirmationdates = stritrim(confirmationdates)
				forvalues i = 0(1)9 {
					di "---- `i' ----"
					replace confirmationdates = subinstr(confirmationdates, "0`i'/", "", .)
					replace confirmationdates = subinstr(confirmationdates, "1`i'/", "", .)
					replace confirmationdates = subinstr(confirmationdates, "2`i'/", "", .)
				}
				replace confirmationdates = subinstr(confirmationdates, "30/", "", .)
				replace confirmationdates = subinstr(confirmationdates, "31/", "", .)
				split confirmationdates, generate(confdate) destring
				egen confirmationdatemin = rowmin(confdate*) // corrected to the spelling
				egen confirmationdatemax = rowmax(confdate*) // corrected to the spelling
				drop confdate*
			}
			compress
			save "$bycountry_path\_`cntry'\managers_`wave'_`cntry'.dta" , replace
			frame change default
			frame drop tempframe
		}
		clear
	}
	
	if `wave' == 2020 {
		global countries "ANDORRA ALBANIA AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UK UKRAINE"
		
		clear
		// previous
		cd "$preparation_path"
		forvalues j = 1(1)10 {
			append using managers_2020_`j'_previous.dta
		}
		
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen is_current = 0
			gen source = 2020
			ren originaljobtitleinenglish managerfunction
			cd "$bycountry_path\_`cntry'"
			compress
			save managers_`wave'_`cntry'_previous.dta, replace
			frame change default
			frame drop tempframe
		}
		
		clear
		// current
		cd "$preparation_path"
		forvalues j = 1(1)7 {
			append using managers_2020_`j'_current.dta
		}
		
		foreach cntry of global countries {
			frame put if country == "`cntry'", into(tempframe)
			frame change tempframe
			gen is_current = 1
			gen source = 2020
			ren originaljobtitleinenglish managerfunction
			cd "$bycountry_path\_`cntry'"
			compress
			save managers_`wave'_`cntry'_current.dta, replace
			frame change default
			frame drop tempframe
		}
		
		clear
		// append within 2020 wave
		foreach cntry of global countries {
			append using "$bycountry_path\_`cntry'\managers_`wave'_`cntry'_previous.dta"
			append using "$bycountry_path\_`cntry'\managers_`wave'_`cntry'_current.dta"
			
			//
			tostring appointmentdate, gen(string_appointment)
			gen year_appointment= substr(string_appointment,1,4)
			destring year_appointment, replace
			drop string_appointment appointmentdate

			tostring resignationdate, gen(string_resignation)
			gen year_resignation=substr(string_resignation, 1, 4)
			destring year_resignation, replace
			drop string_resignation resignationdate

			tostring dateslastreceivedfromips, gen(string_lastips)
			gen year_lastips=substr(string_lastips, 1, 4)
			destring year_lastips, replace
			drop string_lastips dateslastreceivedfromips

			tostring notvalidafter, gen(string_notvalidafter)
			gen year_notvalidafter=substr(string_notvalidafter,1,4)
			destring year_notvalidafter, replace
			drop string_notvalidafter notvalidafter
			
			// confirmation dates
			gen len = strlen(confirmationdates)
			summ len
			if `r(mean)' != 0 {
				drop len
				split confirmationdates, p(";")
				forvalues i=1(1)`r(nvars)'{
					gen year_confdate`i'= substr(confirmationdates`i', 1, 4)
					destring year_confdate`i', replace
					drop confirmationdates`i'
				}
				egen min_years = rowmin(year_confdate*) // confirmationdates
				egen max_years = rowmax(year_confdate*) // confirmationdates
				drop year_confdate*
			}
			gen start = .
			gen end = 0

			replace start = year_appointment if !missing(year_appointment)
			replace start = min_years if missing(year_appointment) & !missing(min_years) 
			 
			replace end =  max_years if !missing(max_years)
			replace end =  2020 if is_current == 1 & end < 2020
			replace end =  year_resignation   if !missing(year_resignation)
			replace end =  year_notvalidafter if !missing(year_notvalidafter)
			
			// save
			compress
			save "$bycountry_path\_`cntry'\managers_`wave'_`cntry'.dta", replace
			clear
		}
	}
}

// join by country from each wave
global countries "ALBANIA AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NETHERLANDS NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UK UKRAINE ANDORRA YUGOSLAVIA"

clear
foreach cntry of global countries {
	cd "$bycountry_path\_`cntry'"
	global files: dir "$bycountry_path\_`cntry'" file "managers_*_`cntry'.dta"
	foreach file of global files {
		append using `file', force
	}
	compress
	save "$bycountry_path\__joined_country_files\managers_`cntry'.dta" , replace
	clear
}
