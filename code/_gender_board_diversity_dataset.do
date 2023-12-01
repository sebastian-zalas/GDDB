/******************************************************************************/
/* 					Gender Board Diversity Dataset							  */
/******************************************************************************/
clear

foreach cntry in ALBANIA AUSTRIA BELGIUM BELARUS CROATIA CYPRUS BOSNIA BULGARIA CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY UKRAINE UK {
    clear
	use "$person_level_path\managers_personlvl_`cntry'.dta" , replace
	
	* drop nofunction
	drop if nofunction==1
	drop nofunction
	
	* drop observations without gender
	drop if !inlist(gender, 0, 1)
	
	* tag women
	foreach i in senmen supboard ambg boards {
		gen `i'_w = 1 if `i'==1 & gender==1
	}
	
	* collapse
	collapse (sum) senmen* supboard* ambg* boards*, by(bvdidnumber year country)
	
	* merge NACE
	merge 1:1 bvdidnumber year using "$nace_path\nace`cntry'.dta" , keepusing(nace)
	keep if _merge == 3
	drop _merge
	gen nace2 = substr(nace, 1, 2)
	drop if nace2==""
	
	* female share
	foreach i in senmen supboard ambg boards {
		gen female_share_`i' = `i'_w / `i'
	}
	
	* female weighted share
	foreach i in senmen supboard ambg boards {
		egen `i'_ind_w = sum(`i'_w) , by(year nace2)
		egen `i'_ind  = sum(`i') , by(year nace2)		
		gen female_share_ind_`i' = `i'_ind_w / `i'_ind
	}
	
	* zero share
	foreach i in senmen supboard ambg boards {
		cap gen zero_share_`i' = 0 if `i'!=.
		replace zero_share_`i' = 1 if `i'!=0 & `i'_w==0
	}	
	
	* any person
	foreach i in senmen supboard ambg boards {
		gen any_`i' = .
		replace any_`i' = 0 if `i'!=.
		replace any_`i' = 1 if `i'!=0 
	}
	
	keep bvdidnumber year country nace* zero_share* female_share* any* senmen_w supboard_w ambg_w boards_w
	compress
	save "$documentation_path\_measures\_measures_cntrylvl_`cntry'.dta" , replace	
}

/*--- append firm-level data from all countries -----------------------------*/
clear
foreach cntry in ALBANIA AUSTRIA BELGIUM BELARUS CROATIA CYPRUS BOSNIA BULGARIA CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA PORTUGAL SPAIN SPAIN SWEDEN SWITZERLAND TURKEY UKRAINE UK {
	append using "$documentation_path\_measures\_measures_cntrylvl_`cntry'.dta"	
}

/*--- collapse to country -- year -- 2digit NACE ----------------------------*/
egen id = group(bvdidnumber)
collapse (mean) female_share_senmen female_share_supboard female_share_boards ///
				female_share_ind_senmen female_share_ind_supboard female_share_ind_boards ///
		 (sum)	zero_share_senmen zero_share_supboard zero_share_boards ///
				any_senmen any_supboard any_boards ///
		 (count) id , by(year nace2 country)

* only sectors with at least three firms
drop if id<2
		 
* save dataset
save "$documentation_path\_measures\_gbdd.dta" , replace
