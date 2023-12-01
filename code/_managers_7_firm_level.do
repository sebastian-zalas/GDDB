/******************************************************************************/
/*	 					Firm-level Managers Dataset							  */
/******************************************************************************/
clear

global countries "ALBANIA AUSTRIA BELGIUM BELARUS CROATIA CYPRUS BOSNIA BULGARIA CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UKRAINE UK"


foreach cntry of global countries {
	use "$person_level_path\managers_personlvl_`cntry'.dta" 
		
	* drop nofunction
	drop if nofunction==1
	drop nofunction
	
	* drop observations without gender
	drop if !inlist(gender, 0, 1)
	
	* men or women
	foreach cat in senmen supboard boards ambg {
		gen `cat'_fem = .
		gen `cat'_male = .
		replace `cat'_fem = 1 if gender == 1 & `cat' == 1
		replace `cat'_male = 1 if gender == 0 & `cat' == 1
		drop `cat'
 	}

	* collapse (from person-level to firm-level data)
	collapse (sum) senmen_* supboard_* boards_* ambg_* ///
			 (max) sup_shouldhave, by(country bvdidnumber year)
	
	* merge NACE
	merge 1:1 bvdidnumber year using "$nace_path\nace`cntry'.dta" , keepusing(nace)
	keep if _merge == 3
	drop _merge
	drop if nace==""
	
	* zero women dummy (==1 if there is NO WOMEN in board)
	foreach cat in senmen supboard boards {
		gen zero_`cat' = .
		replace zero_`cat' = 0 if `cat'_fem != 0 & `cat'_fem != . 
		replace zero_`cat' = 1 if `cat'_fem == 0 & `cat'_fem != .
	}
	
	* save
	save "$firm_level_path\managers_firmlvl_`cntry'.dta" , replace
	clear
}

