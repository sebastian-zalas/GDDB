/******************************************************************************/
/*	 				Clasiify legalform by country 					  		  */
/******************************************************************************/
clear
capture log close

// form list of countries using names of folders, created by previous code
global countries : dir "$bycountry_path\__joined_country_files" files "managers_*.dta"
global rmy_cntry "managers_andorra.dta"
global countries : list global(countries) - global(rmy_cntry)

foreach cntry of global countries {
	local cntry = subinstr("`cntry'", "managers_", "", .)
	local cntry = subinstr("`cntry'", ".dta", "", .)
	local cntry = strupper("`cntry'")
	
	di "************************* `cntry' **************************"
	use "$bycountry_path\__joined_country_files\managers_`cntry'.dta"
	
	capture drop sup_shouldhave
	gen sup_shouldhave = .
	capture ren legalform nationallegalform
	
	// prepare log with check on dropped legal forms
	qui log using "$bycountry_path\__after_legalform\checks\_legalform_check_`cntry'.txt" , replace text
	di "*--- `cntry' ---*"
	qui count if missing(nationallegalform)
	di "1. dropped becasue of missing legalform : `r(N)'"
	di " "
	qui log off
	
	drop if missing(nationallegalform)
	
	***************************** between-country coding ***************************
	{
	di "************************* between-country coding **************************"

	*** dropping non-business legal forms ***
	di "*** dropping non-business legal forms ***"
	// PUBLIC
	replace sup_shouldhave = -1 if strpos(lower(nationallegalform),"government")!=0 | strpos(lower(nationallegalform),"local")!=0 | strpos(lower(nationallegalform),"political party")!=0 | strpos(lower(nationallegalform),"council")!=0  | strpos(lower(nationallegalform),"municipal")!=0  | strpos(lower(nationallegalform),"territoria")!=0 | strpos(lower(nationallegalform),"county")!=0 | strpos(lower(nationallegalform),"ministr")!=0 | strpos(lower(nationallegalform),"embassy")!=0  | strpos(lower(nationallegalform),"budget")!=0 | strpos(lower(nationallegalform),"public institution")!=0
	// RELIGIOUS
	replace sup_shouldhave = -1 if strpos(lower(nationallegalform),"religious")!=0
	// NGO
	replace sup_shouldhave = -1 if strpos(lower(nationallegalform),"non-profit")!=0 | strpos(lower(nationallegalform),"non profit")!=0 | strpos(lower(nationallegalform),"ngos")!=0 | strpos(lower(nationallegalform),"foundation")!=0 | strpos(lower(nationallegalform),"foundation")!=0  | strpos(lower(nationallegalform),"social aim")!=0 | (strpos(lower(nationallegalform),"civil")!=0 & strpos(lower(nationallegalform),"society")!=0) | strpos(lower(nationallegalform),"charity")!=0 | strpos(lower(nationallegalform),"charitable")!=0 
	// EU organizations
	replace sup_shouldhave = -1 if strpos(lower(nationallegalform),"european") !=0 & ( strpos(lower(nationallegalform),"company") !=0 | strpos(lower(nationallegalform),"interest group")!=0) |  strpos(lower(nationallegalform),"geie")!=0
	//
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"central") !=0 & strpos(lower(nationallegalform),"bank") !=0
	replace sup_shouldhave = -1 if strpos(lower(nationallegalform),"liquidat") !=0

	*** dropping single-person firms ***
	di "*** dropping single-person firms ***"
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"sole")!=0 & strpos(lower(nationallegalform),"trader")!=0
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"private")!=0 & strpos(lower(nationallegalform),"trader") !=0 
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"sole")!=0 & strpos(lower(nationallegalform),"propriet")!=0
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"sole")!=0 & strpos(lower(nationallegalform),"owner")!=0
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"sole")!=0 & strpos(lower(nationallegalform),"owner")!=0
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"individual")!=0 & strpos(lower(nationallegalform),"merchant")!=0
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"individual")!=0 & strpos(lower(nationallegalform),"company")!=0 // added sz
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"einzelfirma")!=0
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"entrepreneur")!=0
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"craftsman")!=0

	*** dropping non-classified firms ***
	di "*** dropping non-classified firms ***"
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"not classified") !=0
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"legal form unknown") !=0
	replace sup_shouldhave = -1 if  strpos(lower(nationallegalform),"not companies act") !=0 // mostly UK

	*** standard key words for two-tier firms ***
	di "*** standard key words for two-tier firms ***"

	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"incorporated") !=0 & strpos(lower(nationallegalform),"unincorporated") == 0
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"limited") !=0 & strpos(lower(nationallegalform),"company")!=0
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"stock") !=0 & strpos(lower(nationallegalform),"company")!=0
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"joint") != 0 & strpos(lower(nationallegalform),"stock") !=0
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"trust") !=0 & (strpos(lower(nationallegalform),"company")!=0 | strpos(lower(nationallegalform),"investment")!=0)
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"public") !=0 & (strpos(lower(nationallegalform),"company")!=0 | strpos(lower(nationallegalform),"corporation") !=0 )
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"holding")!=0 & strpos(lower(nationallegalform),"company") !=0
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"limited")!=0 & strpos(lower(nationallegalform),"partnership") !=0
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"limited")!=0 & strpos(lower(nationallegalform),"liability") !=0
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"liability")!=0 & strpos(lower(nationallegalform),"company")!=0
	replace  sup_shouldhave = 1 if strpos(lower(nationallegalform),"sarl") !=0 | strpos(lower(nationallegalform),"llp") !=0 | strpos(lower(nationallegalform),"ltd") !=0 | strpos(lower(nationallegalform),"asa") !=0 | strpos(lower(nationallegalform),"gmbh") !=0 | strpos(lower(nationallegalform),"srl") !=0  | strpos(lower(nationallegalform),"s.r.l.") !=0
	replace  sup_shouldhave = 1 if strpos(nationallegalform," SE ")!=0 | (strpos(lower(nationallegalform),"societa europaea")!=0) | (strpos(lower(nationallegalform),"european company")!=0)  //SOCIETAS EUROPAEAS added HD
	replace  sup_shouldhave = 1 if (strpos(lower(nationallegalform),"limited") !=0 & strpos(lower(nationallegalform),"liabilit")!=0) & strpos(lower(nationallegalform),"sole") !=0 & strpos(lower(nationallegalform),"shareholder") !=0  

	*** standard key words for institutions with management but without obligation to establish supervisory boards ***
	di "*** standard key words for institutions with management but without obligation to establish supervisory boards ***"
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"operative") !=0 | (strpos(lower(nationallegalform),"cooperation") !=0 & strpos(lower(nationallegalform),"company") !=0)
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"operative") !=0 | (strpos(lower(nationallegalform),"operation") !=0 & strpos(lower(nationallegalform),"society") !=0)
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"social") !=0 & strpos(lower(nationallegalform),"compan") !=0 & strpos(lower(nationallegalform),"own") !=0 
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"branch") !=0  & strpos(lower(nationallegalform),"foreign") !=0
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"foreign") !=0 & (strpos(lower(nationallegalform),"company") !=0  | strpos(lower(nationallegalform),"entity") !=0 )
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"investment") !=0  & strpos(lower(nationallegalform),"fund") !=0 
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"investment") !=0 & strpos(lower(nationallegalform),"compan") !=0 
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"retirement") !=0 
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"legal") !=0 & strpos(lower(nationallegalform),"firm") !=0 
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"general") !=0 &  strpos(lower(nationallegalform),"partnership") !=0 
	replace  sup_shouldhave = 2 if (strpos(lower(nationallegalform),"mutual") !=0 | strpos(lower(nationallegalform),"trust") !=0) &  strpos(lower(nationallegalform),"fund") !=0 
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"silent") !=0 & strpos(lower(nationallegalform),"partnership") !=0 
	replace  sup_shouldhave = 2 if strpos(lower(nationallegalform),"joint") !=0  & strpos(lower(nationallegalform),"venture") !=0 
}
	

	*** rudimentary treatment of financial institutions ***
	replace  sup_shouldhave = 0 if strpos(lower(nationallegalform),"bank") !=0
	replace  sup_shouldhave = 0 if strpos(lower(nationallegalform),"insurance") !=0
	
	
	***************************** country-specific coding **************************
	{
	di "************************* country-specific coding *************************"

	*** AUSTRIA, GERMANY, SWITZERLAND ***
	if inlist("`cntry'", "AUSTRIA", "GERMANY", "SWITZERLAND") {
		di "*** country-specific coding: Germanic - AUSTRIA, GERMANY, SWITZERLAND ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"AUSTRIA","GERMANY","SWITZERLAND") & inlist(nationallegalform,"AG","KG")
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"AUSTRIA","GERMANY","SWITZERLAND") & (strpos(nationallegalform,"AG") !=0  & strpos(nationallegalform,"KG") !=0) 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"AUSTRIA","GERMANY","SWITZERLAND") & (strpos(lower(nationallegalform),"corporate") !=0  & strpos(lower(nationallegalform),"body") !=0) 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"AUSTRIA","GERMANY","SWITZERLAND") & strpos(lower(nationallegalform),"bgb") !=0 & (strpos(lower(nationallegalform),"arbeitsgemeinschaft") !=0 | strpos(lower(nationallegalform),"partnership") !=0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"AUSTRIA","GERMANY","SWITZERLAND") &   inlist(nationallegalform,"BGB","eG","eV","OHG")
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"AUSTRIA","GERMANY","SWITZERLAND") &   nationallegalform == "General partnership - OHG"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"AUSTRIA","GERMANY","SWITZERLAND") &   nationallegalform == "Registered association - eV"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"AUSTRIA","GERMANY","SWITZERLAND") &   nationallegalform == "Registered cooperative - eG"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"AUSTRIA","GERMANY","SWITZERLAND") &  nationallegalform == "KGaA"
	}

	*** BELARUS ***
	if inlist("`cntry'", "BELARUS") {
		di "*** country-specific coding: BELARUS ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BELARUS" & strpos(lower(nationallegalform),"cooperative") != 0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BELARUS" & lower(nationallegalform) == "limited company"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "BELARUS" & nationallegalform == "Public institution" 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "BELARUS" & strpos(lower(nationallegalform),"unitary") != 0  & strpos(lower(nationallegalform),"enterprise") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "BELARUS" & strpos(lower(nationallegalform),"unitary") != 0  & strpos(lower(nationallegalform),"company") != 0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BELARUS" & strpos(lower(nationallegalform),"collective") != 0 & strpos(lower(nationallegalform),"enterprise") != 0   
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BELARUS" & strpos(lower(nationallegalform),"stock") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "BELARUS" & strpos(lower(nationallegalform),"affiliate") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "BELARUS" & strpos(lower(nationallegalform),"branch") != 0 & strpos(lower(nationallegalform),"enterprise") != 0 
	}

	*** BENELUX - BELGIUM & NETHERLANDS & LUXEMBOURG ***
	if inlist("`cntry'", "BELGIUM", "NETHERLANDS", "LUXEMBOURG") {
		di "*** country-specific coding: Benelux - BELGIUM & NETHERLANDS & LUXEMBOURG ***"
		replace sup_shouldhave = -1 if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & (strpos(lower(nationallegalform),"geie/eesv") !=0 )
		replace sup_shouldhave = 2 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"snc") !=0 & strpos(lower(nationallegalform),"vof") !=0 
		replace sup_shouldhave = 2 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"sc") !=0 & strpos(lower(nationallegalform),"cv") !=0
		replace sup_shouldhave = 2 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"scs") !=0 
		replace sup_shouldhave = 1 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"scri") !=0 & strpos(lower(nationallegalform),"cvoa") !=0 
		replace sup_shouldhave = 1 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"scrl") !=0 & strpos(lower(nationallegalform),"cvba") !=0 
		replace sup_shouldhave = 2 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"gvc") !=0 & strpos(lower(nationallegalform),"vof") !=0 
		replace sup_shouldhave = 1 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"sprl") != 0 & strpos(lower(nationallegalform),"bvba") !=0 
		replace sup_shouldhave = 2 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"public") !=0 & strpos(lower(nationallegalform),"commercial") !=0 & strpos(lower(nationallegalform),"non-commercial") ==0  
		replace sup_shouldhave = 1 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"limited")  !=0 &  strpos(lower(nationallegalform),"shares")  !=0 &  strpos(lower(nationallegalform),"privat")  !=0 
		replace sup_shouldhave = 1 	if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"nv") != 0 & strpos(lower(nationallegalform),"sa") != 0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & (nationallegalform == "Co-operative society" | nationallegalform == "Cooperative society")
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & (nationallegalform == "Company limited by shares" | nationallegalform == "Limited company by shares - SA")
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"BELGIUM","NETHERLANDS","LUXEMBOURG") & strpos(lower(nationallegalform),"mutual") != 0 & strpos(lower(nationallegalform),"guarantee") != 0 
	}

	*** BALCAN COUNTRIES - BOSNIA, CROATIA, ALBANIA, MACEDONIA, MOLDOVA  ***
	if inlist("`cntry'", "BOSNIA", "CROATIA", "ALBANIA", "MACEDONIA", "MOLDOVA") {
		di "*** country-specific coding: Balcans - BOSNIA, CROATIA, ALBANIA, MACEDONIA, MOLDOVA ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BOSNIA" & strpos(lower(nationallegalform),"social")  !=0 & strpos(lower(nationallegalform),"company")  !=0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "BOSNIA" & strpos(lower(nationallegalform),"fund")  !=0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "CROATIA" & (strpos(lower(nationallegalform),"cooperative") !=0 | strpos(lower(nationallegalform),"co-operative") !=0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "ALBANIA" & strpos(lower(nationallegalform),"simple") !=0  & strpos(lower(nationallegalform),"partnership") !=0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "MACEDONIA" & (strpos(lower(nationallegalform),"cooperations") !=0 | strpos(lower(nationallegalform),"co-operations") !=0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "MOLDOVA"  & strpos(lower(nationallegalform),"represent") !=0 & strpos(lower(nationallegalform),"office") !=0
		// replace sup_shouldhave = 0 if missing(sup_shouldhave) & country == "YUGOSLAVIA"  // fix this, surely wrong
	}

	*** BULGARIA ***
	if inlist("`cntry'", "BULGARIA") {
		di "*** country-specific coding: BULGARIA ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BULGARIA" & strpos(lower(nationallegalform),"limited") !=0 & strpos(lower(nationallegalform),"kda") !=0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BULGARIA" & strpos(lower(nationallegalform),"limited") !=0 & strpos(lower(nationallegalform),"ead") !=0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BULGARIA" & strpos(lower(nationallegalform),"limited") !=0 & strpos(lower(nationallegalform),"ood") !=0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BULGARIA" & strpos(lower(nationallegalform),"limited") !=0 & strpos(lower(nationallegalform),"eood") !=0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "BULGARIA" & strpos(lower(nationallegalform),"unlimited") !=0 & strpos(lower(nationallegalform),"sd") !=0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "BULGARIA" & strpos(lower(nationallegalform),"union") !=  0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "BULGARIA" & strpos(lower(nationallegalform),"legal") !=  0 & strpos(lower(nationallegalform),"person") !=  0 
	}

	*** SLOVAKIA & CZECH REPUBLIC ***
	if inlist("`cntry'", "SLOVAKIA", "CZECH") {
		di "*** country-specific coding: SLOVAKIA & CZECH ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"SLOVAKIA","CZECH") & (strpos(lower(nationallegalform),"sro" ) != 0 | strpos(lower(nationallegalform),"s.r.o") != 0 | strpos(lower(nationallegalform),"a.s." ) != 0 | strpos(lower(nationallegalform),"as") != 0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SLOVAKIA","CZECH") & (strpos(lower(nationallegalform),"k.s." ) != 0 | strpos(lower(nationallegalform),"ks") != 0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SLOVAKIA","CZECH") & (strpos(lower(nationallegalform),"foreign" ) != 0 | strpos(lower(nationallegalform),"person") != 0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SLOVAKIA","CZECH") & (strpos(lower(nationallegalform),"soci" ) != 0 | strpos(lower(nationallegalform),"commandi") != 0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SLOVAKIA","CZECH") & (strpos(lower(nationallegalform),"endowment" ) != 0 | strpos(lower(nationallegalform),"fund") != 0 )
		
		// only Czech
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "CZECH" & strpos(lower(nationallegalform),"czech" ) != 0 & strpos(lower(nationallegalform),"railways") != 0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "CZECH" & strpos(lower(nationallegalform),"v.o.s." ) != 0 
	}

	*** POLAND ***
	if inlist("`cntry'", "POLAND") {
		di "*** country-specific coding: POLAND ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "POLAND" & (lower(nationallegalform) == "sa" | lower(nationallegalform) == "s.a.")
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "POLAND" & strpos(lower(nationallegalform),"sp") != 0 & (strpos(lower(nationallegalform),"z.o.o.") != 0  | strpos(lower(nationallegalform),"z o.o.") != 0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "POLAND" & strpos(lower(nationallegalform),"komandyt") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "POLAND" & (strpos(lower(nationallegalform),"cywiln") != 0  | lower(nationallegalform) == "sc" | lower(nationallegalform) == "s.c.")
	}

	*** SCANDINAVIAN COUNTRIES - DENMARK, SWEDEN, FINLAND, NORWAY, ICELAND ***
	if inlist("`cntry'", "DENMARK") {
		di "*** country-specific coding: Scandinavians - DENMARK ***"
		replace sup_shouldhave = -1 if missing(sup_shouldhave) & country == "DENMARK" & strpos(lower(nationallegalform),"assurance") !=0 & strpos(lower(nationallegalform),"company") !=0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "DENMARK" & strpos(lower(nationallegalform),"i/s") !=0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "DENMARK" & (strpos(lower(nationallegalform),"a/s") !=0  | strpos(lower(nationallegalform),"k/s") !=0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "DENMARK" & strpos(lower(nationallegalform),"aps") !=0 
	}

	if inlist("`cntry'", "SWEDEN") {
		di "*** country-specific coding: Scandinavians - SWEDEN ***"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "SWEDEN" & strpos(lower(nationallegalform),"ab") != 0 & strpos(lower(nationallegalform),"private") != 0 & (strpos(lower(nationallegalform),"company") != 0 | strpos(lower(nationallegalform),"limited") != 0 )
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "SWEDEN" & strpos(lower(nationallegalform),"ab") != 0 & strpos(lower(nationallegalform),"public") != 0 & (strpos(lower(nationallegalform),"company") != 0 | strpos(lower(nationallegalform),"limited") != 0 )
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "SWEDEN" & strpos(lower(nationallegalform),"aktiebolag") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "SWEDEN" & strpos(lower(nationallegalform),"kommanditbolag") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "SWEDEN" & strpos(lower(nationallegalform),"partrederier") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "SWEDEN" & strpos(lower(nationallegalform),"kooperativ") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "SWEDEN" & strpos(lower(nationallegalform),"foreign") != 0 & strpos(lower(nationallegalform),"entity") != 0 
	}

	if inlist("`cntry'", "FINLAND") {
		di "*** country-specific coding: Scandinavians - FINLAND ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "FINLAND" & (strpos(lower(nationallegalform),"oyj" ) != 0 | strpos(lower(nationallegalform),"oy" ) != 0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "FINLAND" & strpos(lower(nationallegalform),"ky" ) != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "FINLAND" & strpos(lower(nationallegalform),"partnership" ) != 0 
	}

	if inlist("`cntry'", "ICELAND") {
		di "*** country-specific coding: Scandinavians - ICELAND ***"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "ICELAND" & strpos(lower(nationallegalform),"operative" ) != 0 
	}

	if inlist("`cntry'", "NORWAY") {
		di "*** country-specific coding: Scandinavians - NORWAY ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "NORWAY" & strpos(lower(nationallegalform),"joint" ) != 0 & (strpos(lower(nationallegalform),"owner" ) != 0 | strpos(lower(nationallegalform),"offic") != 0)
	}

	*** BALTIC STATES - LITHUANIA, ESTONIA, LATVIA ***
	if inlist("`cntry'", "ESTONIA") {
		di "*** country-specific coding: The Baltic States - ESTONIA ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "ESTONIA" & strpos(upper(nationallegalform),"TÜ") != 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "ESTONIA" & strpos(upper(nationallegalform),"UÜ") != 0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "ESTONIA" & strpos(lower(nationallegalform),"share" ) != 0 & strpos(lower(nationallegalform),"company") != 0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "ESTONIA" & strpos(upper(nationallegalform),"OÜ") != 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "ESTONIA" & strpos(lower(nationallegalform),"private") != 0 & strpos(lower(nationallegalform),"opertative") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "ESTONIA" & strpos(lower(nationallegalform),"affiliate") != 0 
	}

	if inlist("`cntry'", "LATVIA") {
		di "*** country-specific coding: The Baltic States - LATVIA ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "LATVIA" & strpos(upper(nationallegalform),"KS") != 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "LATVIA" & strpos(upper(nationallegalform),"PS") != 0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "LATVIA" & (strpos(lower(nationallegalform),"ltd") != 0 | strpos(lower(nationallegalform),"sia") != 0)
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "LATVIA" & (strpos(lower(nationallegalform),"limited") != 0 | strpos(lower(nationallegalform),"sia") != 0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "LATVIA" & (strpos(lower(nationallegalform),"full") != 0 | strpos(lower(nationallegalform),"liability") != 0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "LATVIA" & strpos(lower(nationallegalform),"affiliate") != 0
	}

	if inlist("`cntry'", "LITHUANIA") {
		di "*** country-specific coding: The Baltic States - LITHUANIA ***"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "LITHUANIA" & strpos(lower(nationallegalform),"commandit") != 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "LITHUANIA" & strpos(lower(nationallegalform),"partnership") != 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "LITHUANIA" & (strpos(lower(nationallegalform),"foreign") != 0 | strpos(lower(nationallegalform),"merch") != 0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "LITHUANIA" & (strpos(lower(nationallegalform),"kub") != 0 | strpos(lower(nationallegalform),"tub") != 0)
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "LITHUANIA" & (strpos(lower(nationallegalform),"ag") != 0 | strpos(lower(nationallegalform),"gmbh") != 0)
	}

	*** FRANCE ***
	if inlist("`cntry'", "FRANCE") {
		di "*** country-specific coding: FRANCE ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "FRANCE" & (strpos(lower(nationallegalform),"sarl") != 0 | strpos(lower(nationallegalform),"eurl") != 0 | strpos(lower(nationallegalform),"sa") != 0 | strpos(lower(nationallegalform),"sas") != 0 | strpos(lower(nationallegalform),"sca") != 0 | strpos(lower(nationallegalform),"earl") != 0 )
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "FRANCE" & strpos(lower(nationallegalform),"action") != 0 & strpos(lower(nationallegalform),"simple") != 0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "FRANCE" & (strpos(lower(nationallegalform),"sprl") != 0 | strpos(lower(nationallegalform),"srl") != 0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "FRANCE" & strpos(lower(nationallegalform),"commandit") != 0 & strpos(lower(nationallegalform),"simple") != 0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "FRANCE" & strpos(lower(nationallegalform),"société") != 0 & strpos(lower(nationallegalform),"mutuel") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "FRANCE" & strpos(lower(nationallegalform),"société") != 0 & (strpos(lower(nationallegalform),"fait") != 0 | strpos(lower(nationallegalform),"colectif") != 0 | strpos(lower(nationallegalform),"participat") != 0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "FRANCE" & strpos(lower(nationallegalform),"societe") != 0 & (strpos(lower(nationallegalform),"fait") != 0 | strpos(lower(nationallegalform),"colectif") != 0 | strpos(lower(nationallegalform),"participat") != 0 )
	}

	*** GREECE ***
	if inlist("`cntry'", "GREECE") {
		di "*** country-specific coding: GREECE ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "GREECE" & (strpos(lower(nationallegalform),"e.p.e.") != 0 | strpos(lower(nationallegalform),"epe.") != 0)
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "GREECE" & (strpos(lower(nationallegalform),"i.k.e.") != 0 | strpos(lower(nationallegalform),"ike") != 0)
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "GREECE" & (strpos(lower(nationallegalform),"societ") != 0 | strpos(lower(nationallegalform),"anonym") != 0)
	}

	*** HUNGARY ***
	if inlist("`cntry'", "HUNGARY") {
		di "*** country-specific coding: HUNGARY ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "HUNGARY" & (nationallegalform == "Cooperative company" | nationallegalform == "Cooperative society")
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "HUNGARY" & strpos(lower(nationallegalform),"limited" ) != 0 & (strpos(lower(nationallegalform),"shares") != 0 |  strpos(lower(nationallegalform),"partnership") != 0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "HUNGARY" & strpos(lower(nationallegalform),"general" ) != 0 & strpos(lower(nationallegalform),"partnership") != 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "HUNGARY" & strpos(lower(nationallegalform),"direct" ) != 0 & strpos(lower(nationallegalform),"foreign") != 0
	}

	*** ITALY ***
	if inlist("`cntry'", "ITALY") {
		di "*** country-specific coding: ITALY ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "ITALY" & (strpos(lower(nationallegalform),"sa") != 0 | strpos(lower(nationallegalform),"scari") != 0 | strpos(lower(nationallegalform),"sapa") != 0 | strpos(lower(nationallegalform),"scpa") != 0 | strpos(lower(nationallegalform),"spa") != 0 | strpos(lower(nationallegalform),"srl") != 0  | strpos(lower(nationallegalform),"sdf") != 0)
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "ITALY" & strpos(lower(nationallegalform),"share") != 0 & strpos(lower(nationallegalform),"consor") != 0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "ITALY" & strpos(lower(nationallegalform),"external") != 0 & strpos(lower(nationallegalform),"consor") != 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "ITALY" & strpos(lower(nationallegalform),"ocietá") != 0 & strpos(lower(nationallegalform),"estera") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "ITALY" & (strpos(lower(nationallegalform),"snc") != 0 | strpos(lower(nationallegalform),"sas") != 0 | strpos(lower(nationallegalform),"ss") != 0 | strpos(lower(nationallegalform),"scarl") != 0 | strpos(lower(nationallegalform),"scarlpa") != 0 | strpos(lower(nationallegalform),"scrl") != 0 )
	}

	*** ROMANIA ***
	if inlist("`cntry'", "ROMANIA") {
		di "*** country-specific coding: ROMANIA ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "ROMANIA" & (strpos(lower(nationallegalform),"scs") != 0 | strpos(lower(nationallegalform),"sca") != 0 | strpos(lower(nationallegalform),"sa") != 0 | strpos(lower(nationallegalform),"srl") != 0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "ROMANIA" & strpos(lower(nationallegalform),"snc") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "ROMANIA" & strpos(lower(nationallegalform),"operative") != 0 & strpos(lower(nationallegalform),"comp") != 0 
	}

	*** RUSSIA & UKRAINE ***
	if inlist("`cntry'", "RUSSIA", "UKRAINE") {
		di "*** country-specific coding: RUSSIA and UKRAINE ***"
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"RUSSIA","UKRAINE") & (strpos(lower(nationallegalform),"aoot") !=0  | strpos(lower(nationallegalform),"aozt") !=0  | strpos(lower(nationallegalform),"oao") !=0 | strpos(lower(nationallegalform),"zao") !=0 | strpos(lower(nationallegalform),"ooo") != 0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"RUSSIA","UKRAINE") & ((strpos(lower(nationallegalform),"daughter") !=0  & strpos(lower(nationallegalform),"enterprise") != 0 ) | strpos(lower(nationallegalform),"dho") != 0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"RUSSIA","UKRAINE") & strpos(lower(nationallegalform),"odo") !=0  & (strpos(lower(nationallegalform),"enterprise") != 0 | strpos(lower(nationallegalform),"society") != 0)
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"RUSSIA","UKRAINE") & strpos(lower(nationallegalform),"zho") !=0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"RUSSIA","UKRAINE") & strpos(lower(nationallegalform),"business") !=0  & strpos(lower(nationallegalform),"division") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"RUSSIA","UKRAINE") & strpos(lower(nationallegalform),"daughter") !=0  & (strpos(lower(nationallegalform),"enterpris") != 0 | strpos(lower(nationallegalform),"compan") != 0 )
	}

	*** SLOVENIA ***
	if inlist("`cntry'", "SLOVENIA") {
		di "*** country-specific coding: SLOVENIA ***"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "SLOVENIA" & (strpos(lower(nationallegalform),"z.b.o.") != 0 | strpos(lower(nationallegalform),"z.o.o.") != 0 )
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "SLOVENIA" & strpos(lower(nationallegalform),"d.n.o") != 0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "SLOVENIA" & strpos(lower(nationallegalform),"d.d.o") != 0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "SLOVENIA" & strpos(lower(nationallegalform),"k.d.") != 0 
	}

	*** SPAIN & PORTUGAL ***
	if inlist("`cntry'", "SPAIN", "PORTUGAL") {
		di "*** country-specific coding: SPAIN and PORTUGAL ***"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"socied") != 0 & strpos(lower(nationallegalform),"comandit") !=0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"socied") != 0 & strpos(lower(nationallegalform),"limitad") !=0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"socied") != 0 & strpos(lower(nationallegalform),"anonim") !=0  & strpos(lower(nationallegalform),"labor") == 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"cooperat") != 0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"s.r.l") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"socied") != 0 & strpos(lower(nationallegalform),"colectiv") !=0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"complement") != 0 & strpos(lower(nationallegalform),"comp") !=0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"civil") != 0 & strpos(lower(nationallegalform),"comp") !=0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"comun") != 0 & strpos(lower(nationallegalform),"biene") !=0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"SPAIN","PORTUGAL") & strpos(lower(nationallegalform),"socied") != 0 & strpos(lower(nationallegalform),"cuota") !=0
	}

	*** UK & IRELAND ***
	if inlist("`cntry'", "UK", "IRELAND") {
		di "*** country-specific coding: the UK & IRELAND ***"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"UK","IRELAND") &  strpos(lower(nationallegalform),"royal") != 0 & strpos(lower(nationallegalform),"charter") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"UK","IRELAND") & (strpos(lower(nationallegalform),"unlimited") != 0 | strpos(lower(nationallegalform),"unlimited company") != 0 )
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"UK","IRELAND") & strpos(lower(nationallegalform),"public") != 0 & strpos(lower(nationallegalform),"quoted" ) !=0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"UK","IRELAND") & strpos(lower(nationallegalform),"industr") != 0 & strpos(lower(nationallegalform),"providen" ) !=0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"UK","IRELAND") & strpos(lower(nationallegalform),"guarantee") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"UK","IRELAND") & strpos(lower(nationallegalform),"private" ) != 0 & strpos(lower(nationallegalform),"limited" ) != 0 & strpos(lower(nationallegalform),"company")!= 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & inlist(country,"UK","IRELAND") & strpos(lower(nationallegalform),"private" ) != 0 & strpos(lower(nationallegalform),"limited" ) != 0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & inlist(country,"UK","IRELAND") & (strpos(lower(nationallegalform),"ofex") !=0 |  strpos(lower(nationallegalform),"aim") !=0 | strpos(lower(nationallegalform),"a.i.m.") !=0)
	}

	*** MALTA ***
	if inlist("`cntry'", "MALTA") {
		di "*** country-specific coding: MALTA ***"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "MALTA" & strpos(lower(nationallegalform),"overseas") != 0 & strpos(lower(nationallegalform),"company" ) != 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "MALTA" & strpos(lower(nationallegalform),"international") != 0 & strpos(lower(nationallegalform),"trading") != 0
	}

	*** TURKEY ***
	if inlist("`cntry'", "TURKEY") {
		di "*** country-specific coding: TURKEY ***"
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "TURKEY" & strpos(lower(nationallegalform),"kommandit") != 0 
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "TURKEY" & strpos(lower(nationallegalform),"partnership") != 0 
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "TURKEY" & strpos(lower(nationallegalform),"private") != 0 & strpos(lower(nationallegalform),"limited") != 0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "TURKEY" & strpos(lower(nationallegalform),"anonim") != 0 & strpos(lower(nationallegalform),"sirketi") != 0
		replace sup_shouldhave = 1 if missing(sup_shouldhave) & country == "TURKEY" & strpos(lower(nationallegalform),"anonim") != 0 & strpos(lower(nationallegalform),"ortaklari") != 0
		replace sup_shouldhave = 2 if missing(sup_shouldhave) & country == "TURKEY" & strpos(lower(nationallegalform),"kolektif") != 0 & strpos(lower(nationallegalform),"sirketi") != 0
	}

	}
	
	//
	replace sup_shouldhave = -2 if !missing(nationallegalform) & missing(sup_shouldhave)
	capture ren nationallegalform legalform

	// check
	qui log on
	di "2. tab sup_shouldhave"
	tab sup_shouldhave, sort
	di " "
	di "3. tab sup_shouldhave"
	tab source sup_shouldhave
	di " "
	di "4. unclassified legal forms "
	tab legalform if sup_shouldhave == -2, sort
	di " "
	di "5. legal forms classified as unnecessary"
	tab legalform if sup_shouldhave == -1, sort
	di "6. legal forms classified as two-tier"
	tab legalform if sup_shouldhave == 1, sort
	di "7. legal forms classified as obligatory having MB"
	tab legalform if sup_shouldhave == 2, sort
	di "*--- --- end --- ---*"
	qui log close
	
	// save
	save "$bycountry_path\__after_legalform\managers_`cntry'.dta", replace
	keep if sup_shouldhave > 0
	save "$bycountry_path\__after_legalform\managers_`cntry'.dta", replace
	clear
}