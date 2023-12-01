/******************************************************************************/
/*	 				Assign boards based on manager functions 				  */
/******************************************************************************/

* prepare functions id *
clear

// list of countries in the folder
global countries : dir "$bycountry_path\__after_legalform" files "managers_*.dta"
global rmy_cntry "managers_andorra.dta managers_yugoslavia.dta"
global countries : list global(countries) - global(rmy_cntry)

// agenda of the code - make 1 if want to run; make 0 if do not want to run
scalar supervisory_board=1 	// assigns supervisory roles
scalar management_board=1  	// assigns management roles
scalar audit=1				// assigns audit roles
scalar board=1				// assings roles to the board
scalar topman=1				// identifies top management below the boards in the corproate ladder
scalar orbis=1              // make use of orbis additional variables
scalar corrections=1		// applies corrections to the previous codes
scalar checks=1             // produce logs of summary tables of results of the whole procedure

foreach cntry of global countries {
	clear
	local cntry = subinstr("`cntry'", "managers_", "", .)
	local cntry = subinstr("`cntry'", ".dta", "", .)
	local cntry = strupper("`cntry'")
	
	di "---------- `cntry' ----------------------------------------------------"
	use "$bycountry_path\__after_legalform\managers_`cntry'.dta"

	replace managerfunction = ustrupper(managerfunction) //unify the font	
	capture drop original_managerfunction
	replace managerfunction=ustrregexra(ustrnormalize(managerfunction, "nfd" ) , "\p{Mark}", "") //convert weird symbols
	
	if inlist("`cntry'", "UK", "IRELAND"){		
		replace managerfunction = subinstr(managerfunction, "DIRECTOR (OCCUPATION:", "", .)  //it makes it easier to read the end results checks for those countries
	}

// Normalization of information about levelofresponsibility between different waves of Orbis
	if inlist("`cntry'", "UK")==0{
		capture gen levelofresponsibility	="."
		capture gen levelofresponsability	="."
		capture gen typeofposition			="."
		capture gen boardcommitteeordepartment="."
		
		capture replace levelofresponsibility = levelofresponsability if missing(levelofresponsibility) & !missing(levelofresponsability)
		
		capture drop levelofresponsability
		
		capture replace typeofposition="." 				if typeofposition==""
		capture replace boardcommitteeordepartment="." 	if boardcommitteeordepartment==""
		capture replace levelofresponsibility="." 		if levelofresponsibility==""
		
		replace boardcommitteeordepartment 	= ustrupper(boardcommitteeordepartment)
		replace levelofresponsibility 		= ustrupper(levelofresponsibility)
	}
	
	if inlist("`cntry'", "UK")==1{
		replace boardcommitteeordepartment 	= ustrupper(boardcommitteeordepartment)
		replace levelofresponsibility 		= ustrupper(levelofresponsibility)				
	}
	
// Take only a list of all, but distinct possible positions and perform classification on it
	capture confirm variable functionid 	
	if _rc != 0 {
	    di "generatinf function's ids"
		capture drop duplo_function
		qui count if managerfunction==""
		local no_missing_functions = `r(N)'
		qui des
		local no_all_obs = `r(N)'
		
		// generate function id
		egen functionid = group(managerfunction levelofresponsibility typeofposition boardcommitteeordepartment)
			
		// check uniqueness
		qui summ functionid
		qui local no_generated_ids = `r(max)'
		
		qui bys managerfunction levelofresponsibility typeofposition boardcommitteeordepartment: gen duplo_function = _n - 1 if managerfunction!=""
		
		qui count if duplo_function == 0
		local no_functions = `r(N)'
		
		di "Uniqueness check in `cntry'"
		di "No of all obs : `no_all_obs'"
		di "No of obs with mis. function : `no_missing_functions'"
		di "No of generated ids    : `no_generated_ids'"
		di "No of function in data : `no_functions '"
		
		// save managers with function ids
		save "$bycountry_path\__after_legalform\managers_`cntry'.dta" , replace
	}
	// keep only manager functions and ids
	keep if duplo_function == 0
	keep country functionid managerfunction levelofresponsibility typeofposition boardcommitteeordepartment
	
	save "$function_path\_functions\functions_`cntry'.dta" , replace
	
**********************
**#* CLASSIFICATION ***
**********************

	timer clear 1
	timer on 1
	
	// corporate governance groups
	local FRANCO `" "FRANCE", "MONACO", "LUXEMBOURG", "BEGLIUM", "SWITZERLAND" "'
	local GERMANO `" "GERMANY", "AUSTRIA", "SWITZERLAND" "'
	local SCANDINAV `" "SWEDEN", "NORWAY", "FINLAND", "DENMARK" "'

	
	************************
	**#*** 1. SUPBOARD *****
	************************
	if supervisory_board==1{
	di "** supboard part"
	cap drop supboard
	gen supboard = 0
	
	*a) General names
	global type 	"SURVEIL SURVAIL SUPERVIS REMUNER COMPENSAT MONITOR APPOINT NOMIN SELECT SUPERIOR NON-EXEC NONEXEC INDEPEND ELECT AUDIT"
	global position	"MEMBER PRESID HEAD REPRESEN COMMISSIONER COMISSIONER COMMISSIONER CHAIR"
	global board	"BOARD COUNC CONSEIL COMMIT COMITE CHAMBER COMISSIO COMMIS"

	* three-word combinations
	foreach type in $type {
	foreach position in $position {
	foreach board in $board {
		replace supboard = 1 if 	(strpos(managerfunction,"`type'")>0 ///
						& strpos(managerfunction,"`position'")>0 ///
						& strpos(managerfunction,"`board'")>0  ///
						& strpos(managerfunction,"SECRET")==0)
			}
		}
	}

	* two-word combinations
	foreach type in $type {
		foreach board in $board {
			replace supboard = 1 if 	(strpos(managerfunction,"`type'")>0 ///
						& strpos(managerfunction,"`board'")>0  ///
						& strpos(managerfunction,"SECRET")==0)
		}
	}

	foreach type in $type {
		foreach position in $position {
			replace supboard = 1 if (strpos(managerfunction,"`type'")>0 ///
							   & strpos(managerfunction,"`position'")>0  ///
							   & strpos(managerfunction,"SECRET")==0)
		}
	}
	
	foreach variant in NON-EXEC NONEXEC INDEPENDENT { 
		replace supboard = 1 if  (strpos(managerfunction,"`variant'")>0  & supboard==0)
	}
	
	replace supboard = 1 if strpos(managerfunction,"NON")>0 & strpos(managerfunction,"EXEC")>0 
	replace supboard = 1 if	strpos(managerfunction,"INDEPEND")>0 & strpos(managerfunction,"DIRECT")>0 
	replace supboard = 1 if	strpos(managerfunction,"DELEG")>0 & strpos(managerfunction,"DIRECT")>0  & strpos(managerfunction,"EXEC")==0  & strpos(managerfunction,"MANAG")==0
	replace supboard = 1 if  strpos(managerfunction,"ASSEM") != 0 & strpos(managerfunction,"GENER") != 0
	
	replace	supboard = 1 if	strpos(managerfunction,"GOVERNANCE")>0 & strpos(managerfunction,"COMMI")>0
	replace	supboard = 1 if	strpos(managerfunction,	"SUPB") > 0
	replace supboard = 1 if strpos(managerfunction, "SUPE") > 0 
	replace	supboard = 1 if	(strpos(managerfunction, "CONTROL")>0 | strpos(managerfunction,	"RISK")>0) & (strpos(managerfunction,"COMMI")>0 | strpos(managerfunction,"BOARD")>0 )
	
	* Country specific names INDIVIDUAL	***
	di "supboard - country specific"
	** Bulgaria & Ukraine
	if ("`cntry'"=="BULGARIA" | "`cntry'"=="UKRAINE") {
		replace supboard = 1 if strpos(managerfunction,"CONTROLLER") > 0 & strpos(managerfunction,"BOARD") > 0	
	}
	
	** Czech
	if ("`cntry'"=="CZECH") {
		replace supboard = 1 if strpos(managerfunction,"COMMISSIONER") > 0	
	}	
	
	** Denmark
	if ("`cntry'"=="DENMARK") {
		replace supboard = 1 if strpos(managerfunction,"BOARD OF DIRECTOR") > 0	
	}
	
	** Estonia
	if "`cntry'"=="ESTONIA" {
		replace supboard = 1 if strpos(managerfunction,"COUNCIL") > 0	
	}

	** France & other francophone //
	if inlist("`cntry'", `FRANCO') {	
		replace	supboard = 1 if strpos(managerfunction, "CONSULTATIVE")>0 & strpos(managerfunction, "COMMI")>0 & strpos(managerfunction,"SHAREHOLDERS")>0
		replace supboard = 1 if strpos(managerfunction,"INDEPEND")>0
		replace	supboard = 1 if strpos(managerfunction,"ADMINISTRA") > 0 & strpos(managerfunction,"DELEGUE")>0
		replace	supboard = 1 if strpos(managerfunction,"PRESID") > 0 & strpos(managerfunction,"DELEGUE")>0
		replace	supboard = 1 if strpos(managerfunction,"COMMISSIONER") > 0 
	}
	
	** Germany & other germanic //
	if inlist("`cntry'", `GERMANO', `SCANDINAV') {
		replace	supboard = 1 if strpos(managerfunction, "PERSONNEL")>0 &  strpos(managerfunction,"COMMI")>0	
		replace	supboard = 1 if strpos(managerfunction, "ADVISORY")>0 & strpos(managerfunction,"COMMI")>0
		replace	supboard = 1 if strpos(managerfunction, "EMPLOY")>0 & strpos(managerfunction,"REPRES")>0
		replace	supboard = 1 if strpos(managerfunction, "EMPLOY")>0 & strpos(managerfunction,"ELECTED")>0
		replace supboard = 1 if strpos(managerfunction, "AUFSICHTSRAT")>0  
	}

	** Hungary
	if "`cntry'"=="HUNGARY" {
		replace supboard = 1 if strpos(managerfunction, "CONTROL")>0 & strpos(managerfunction, "COM")>0
	}
	
	** RUSSIA
	if "`cntry'"=="RUSSIA" {
		replace supboard = 1 if strpos(managerfunction, "BOARD OF DIRECTORS")>0 
	}

	** Serbia
	if "`cntry'"=="SERBIA" {
		replace	supboard = 1 if strpos(managerfunction, "PRESIDENT")>0 & strpos(managerfunction,"ASSEMBLY")>0	
	}

	** Spanish and Portugese
	if ("`cntry'"=="SPAIN" | "`cntry'"=="PORTUGAL") {
		replace supboard = 1 if strpos(managerfunction, "CONSEL")>0  & strpos(managerfunction, "SUPERIOR")>0  
		replace supboard = 1 if strpos(managerfunction, "COMISSAO")>0 & strpos(managerfunction, "VENCIMENT")>0  		
		replace	supboard = 1 if strpos(managerfunction, "CONSELHO")>0 & strpos(managerfunction,"CONSULTIVO")>0 		
		replace supboard = 1 if strpos(managerfunction,"GENERAL")>0 & strpos(managerfunction,"COUNCIL")>0  & inlist("`cntry'", "PORTUGAL")
		replace	supboard = 1 if  strpos(managerfunction,"GOVERNING")>0 & inlist("`cntry'", "SPAIN") 		
	}
	}	
	
	***********************
	**#*** 1.2 AUDIT *******
	***********************
	if audit==1{
	di "** audit part"
	capture drop audit
	capture gen audit = 0
	if ("`cntry'"=="ITALY" | "`cntry'"=="PORTUGAL") {
		replace	audit = 1 if strpos(managerfunction,"AUDITOR")>0 & strpos(managerfunction,"COMMISSION")>0  
		replace	audit = 1 if strpos(managerfunction,"AUDIT")>0
		replace	audit = 1 if strpos(managerfunction,"CONSELHO")>0 & strpos(managerfunction,"FISCAL")>0  
		replace	audit = 1 if strpos(managerfunction,"STATUTORY")>0 & strpos(managerfunction,"AUDITORS")>0 
		replace audit = 1 if strpos(managerfunction, "COLLEG")>0  & strpos(managerfunction, "SINDA")>0 
		replace audit = 1 if strpos(managerfunction, "SINDACO")>0
	}
	if inlist("`cntry'", "SPAIN"){
		replace audit = 1 if strpos(managerfunction, "COMMISSIONER")>0 
	}
	replace supboard=1 if audit==1
	}
	
	***********************
	**#*** 2. SENMEN *******
	***********************
	if management_board==1{
	di "** senmen part"
	capture drop senmen
	capture gen senmen = 0

	*a) General names
	foreach word in CEO CFO CIO COO CTO CXO CED C.E.O PDG GM MD {
		replace senmen = 1 if (managerfunction=="`word'") | strpos(managerfunction, "`word' ")>0 | strpos(managerfunction, " `word'")>0 | strpos(managerfunction, "`word';")>0
	}

	replace senmen = 1 if strpos(managerfunction,"CHIEF")>0		& strpos(managerfunction,"OFFICER")>0 		& strpos(managerfunction,"INDEP")==0 
	replace senmen = 1 if strpos(managerfunction,"CHIEF")>0		& strpos(managerfunction,"ACCOUNT")>0 		& strpos(managerfunction,"INDEP")==0 
	replace senmen = 1 if strpos(managerfunction,"CHIEF")>0		& strpos(managerfunction,"EXEC")>0 			& strpos(managerfunction,"INDEP")==0 
	replace senmen = 1 if strpos(managerfunction,"CHIEF")>0		& strpos(managerfunction,"OFFICER")>0 		& strpos(managerfunction,"INDEP")==0 
	replace senmen = 1 if strpos(managerfunction,"EXEC")>0		& strpos(managerfunction,"MANAGER")>0 		& strpos(managerfunction,"INDEP")==0 & strpos(managerfunction,"NON")==0
	replace senmen = 1 if strpos(managerfunction,"EXEC")>0		& strpos(managerfunction,"PRESID")>0 		& strpos(managerfunction,"INDEP")==0 & strpos(managerfunction,"NON")==0
	replace senmen = 1 if strpos(managerfunction,"EXEC")>0		& strpos(managerfunction,"DEPUTY")>0 		& strpos(managerfunction,"INDEP")==0 & strpos(managerfunction,"NON")==0
	replace senmen = 1 if strpos(managerfunction,"PRESID")>0	& strpos(managerfunction,"DIRECT")>0		& strpos(managerfunction,"GENER")>0 // this is repeated in later loop
	replace senmen = 1 if strpos(managerfunction,"EXEC")>0		& strpos(managerfunction,"DIRECT")>0		& strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 
	replace senmen = 1 if strpos(managerfunction,"EXEC")>0		& strpos(managerfunction,"HEAD")>0			& strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 
	replace senmen = 1 if strpos(managerfunction,"ESEC")>0		& strpos(managerfunction,"DIRETT")>0		& strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 
	replace senmen = 1 if strpos(managerfunction,"EXEC")>0		& strpos(managerfunction,"ADMINISTRAT")>0	& strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 
	replace senmen = 1 if strpos(managerfunction,"TREASURER")>0  
	replace senmen = 1 if strpos(managerfunction,"SOLE") > 0	& (strpos(managerfunction,"PARTNE")>0		| strpos(managerfunction,"MANAGE") >0 )
	replace senmen = 1 if strpos(managerfunction,"SIGNING")>0	& strpos(managerfunction,"AUTHOR")>0		& strpos(managerfunction,"MEMB")>0 & strpos(managerfunction,"WITH")>0 & strpos(managerfunction,"WITHOUT") == 0 
	replace senmen = 1 if strpos(managerfunction, "SENMAN")>0	| 	(strpos(managerfunction,"SENIOR") > 0 	& strpos(managerfunction,"MANAG" ) >0 ) // Amadeus classification
	
	global type 	"MANAGEM GERAN PLANNI STRATEGY EXECUT ADMINI INVEST"
	global position	"MEMBER MEMBRE PRESID COMMISIONER COMISSIONER COMMISSIONER CHAIR"
	global board	"BOARD COUNC CONSEIL COMMIT COMITE CHAMBER COMISSIO COMMIS"
	
	** three-word combinations
	foreach type in $type {
	foreach position in $position {
	foreach board in $board {
		replace senmen = 1 if strpos(managerfunction,"`type'")>0 ///
						& strpos(managerfunction,"`position'")>0 ///
						& strpos(managerfunction,"`board'")>0  ///
						& (strpos(managerfunction,"SECRET")==0 | inlist("cntry", "UK", "SWITZERLAND", "IRELAND") )  ///
						& strpos(managerfunction,"NON")==0 ///
						& strpos(managerfunction,"INDEP")==0 ///
						& strpos(managerfunction,"ADVIS")==0 
			}
		}
	}
	
	** two-word combinations
	foreach type in $type {
		foreach board in $board {
			replace senmen = 1 if	strpos(managerfunction,"`type'")>0 ///
						& strpos(managerfunction,"`board'")>0  ///
						& strpos(managerfunction,"SECRET")==0 ///
						& strpos(managerfunction,"NON")==0 ///
						& strpos(managerfunction,"INDEP")==0 ///
						& strpos(managerfunction,"ADVIS")==0 
		}
	}

	**
	foreach word in CHAIR {
	    replace senmen=1 if strpos(managerfunction, "`word'")>0 & strpos(managerfunction, "MANAG")>0 
	}
	
	** General Manager and similar
	foreach word in PARTNER DIRECT MANAG REPRESENTAT PARTNER {
		replace senmen = 1 if	strpos(managerfunction,"GENERAL")>0 & ///
								strpos(managerfunction,"`word'")>0 & ///
								strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 & ///
								country !="HUNGARY" & ///
								strpos(managerfunction,"ADVIS")==0 						
	}

	replace senmen = 1 if strpos(managerfunction,"GM")>0 & strpos(managerfunction,"SHAREHOLDER")==0 & strpos(managerfunction,"LIMITED PARTNER")==0  & strpos(managerfunction,"JUD")==0 // General Manager

	** Managing Director, Partner-Manager and similar
	foreach word in GENER BOARD DIRETT DIRECT COUNCIL CHAIR PRESIDENT  CHIEF COMPANY PARTNER PRINCIPA {
		replace senmen = 1 if strpos(managerfunction,"MANAG")>0 & ///
							  strpos(managerfunction,"`word'")>0 & ///
							  strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 & ///
								(country !="HUNGARY" & country!="UK") & strpos(managerfunction,"SUPER")==0 & ///
							  strpos(managerfunction,"ADVIS")==0 
	}
	
	replace senmen = 1 if strpos(managerfunction,"MD")>0  // Managing Director


	** General Director and similar
	foreach word in GENER PARTNER CHIEF COMPANY{ //BOARD PRESIDENT COUNCIL 
		replace senmen = 1 if	(strpos(managerfunction,"DIRECT")>0 | strpos(managerfunction,"DIRETT")>0  )  & ///
							 strpos(managerfunction,"`word'")>0  & ///
							 strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 & strpos(managerfunction,"SUPER")==0 & ("`cntry'"!="HUNGARY" & "`cntry'"!="UK")
	}

	** Managing Boards and the similar 
	foreach word in ADMIN GOVERNING {
		replace senmen= 1 if strpos(managerfunction,"BOARD") & strpos(managerfunction, "`word'")>0 & ///
							 strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 & ///
							(strpos(managerfunction,"SECRE")==0 & inlist("`cntry'", "TURKEY", "SWITZERLAND", "IRELAND" ,"UK"))
	}

	** Business Manager (Denmark and France)
	replace senmen = 1 if inlist("`cntry'","DENMARK","FRANCE") & ///
						  strpos(managerfunction,"BUSIN") > 0	& strpos(managerfunction,"MANAG") > 0 & ///
						  strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0
							 

	foreach word in IT SALE PRODUCTION CREATIVE PURCHAS ECONOMIC ENGENEERING PUBLIC STRATEGY INVEST MARKET TECHNIC PLANNING OPERAT DEVELO EXPORT ADVERT HR FINANC HUMAN TECHNICAL TRUSTEE {
		replace senmen = 1 if strpos(managerfunction,"CHIEF")>0 & strpos(managerfunction," `word'")>0 &	strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 
	} 

	replace senmen = 1 if strpos(managerfunction,"CHIEF")>0  &	strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 & supboard==0
 
	* b). Individual countries
	di "senmen individual countries"
	** Estonia
	if "`cntry'"=="ESTONIA" {
		replace senmen = 1 if strpos(managerfunction,"BOARD")>0 & (strpos(managerfunction,"MEMB")>0  | strpos(managerfunction,"CHAIRM")>0 ) & strpos(managerfunction,"COUNCIL")==0
		replace senmen = 1 if strpos(managerfunction,"BOARD")>0 & (strpos(managerfunction,"MAMB")>0  | strpos(managerfunction,"CHAIRM")>0 ) & strpos(managerfunction,"COUNCIL")==0 // frequent typo
		replace senmen = 1 if strpos(managerfunction,"AUTHORIZED")>0
	}
	
	** Portugal & Spain
	if inlist("`cntry'", "PORTUGAL", "SPAIN") {
		replace senmen = 1 if strpos(managerfunction,"COMMANDER")>0 	& strpos(managerfunction,"CORPORATION")>0
		replace senmen = 1 if strpos(managerfunction,"GROUP")>0 		& strpos(managerfunction,"CHIEF")>0
		replace senmen = 1 if strpos(managerfunction,"MANAGER")>0  		& strpos(managerfunction,"PARTNER")>0 
		replace senmen = 1 if strpos(managerfunction,"EXEC")>0 			& strpos(managerfunction,"ADMINISTR")>0 & strpos(managerfunction,"NON")==0
		replace senmen = 1 if strpos(managerfunction,"DIRECTOR")>0	 	& strpos(managerfunction,"PARTNER")>0 	& strpos(managerfunction,"SHAREHOL") & strpos(managerfunction, "MINORITY")>0 
		replace senmen = 1 if strpos(managerfunction,"MANAGING")>0  	& strpos(managerfunction,"ENTITY")>0
		replace senmen = 1 if strpos(managerfunction,"GOVERNING")>0  & strpos(managerfunction,"SECRETARY")>=0
	}

	** Belgium
	if inlist("`cntry'", "BELGIUM") {
		replace senmen = 1 if strpos(managerfunction,"PRESIDENT")>0 	& strpos(managerfunction,"SALES")>0
		replace senmen = 1 if strpos(managerfunction,"LEGAL")>0 		& strpos(managerfunction,"REPRESENTATIVE")>0
		replace senmen = 1 if strpos(managerfunction,"EXPORT")>0 		& strpos(managerfunction,"COMMIT")>0 
		replace senmen = 1 if strpos(managerfunction,"PARTNER") > 0 
		replace senmen = 1 if strpos(managerfunction,"DIRECTOR")>0 	& strpos(managerfunction,"OF")>0 & (strpos(managerfunction,"INDEP")==0 & strpos(managerfunction,"NON")==0) & strpos(managerfunction, "MANA")>0
		
		replace senmen = 1 if strpos(managerfunction,"MANAGER")>0  	& (strpos(managerfunction,"BUSINESS" )>0 | strpos(managerfunction,"STATUTORY-GENERAL")>0   | strpos(managerfunction,"JOINT")>0 ) 
	 }
	
	** Countires of former Yugoslavia
	replace senmen = 1 if inlist("`cntry'", "SERBIA", "BOSNIA") & strpos(managerfunction,"PERSON")>0 & strpos(managerfunction,"AUTHORIZED")>0 &  strpos(managerfunction,"REPRESENT")>0
	replace senmen = 1 if inlist("`cntry'", "SERBIA") & strpos(managerfunction,"PRESIDENT")>0 & strpos(managerfunction,"OF")>0 & strpos(managerfunction,"COMPANY")>0
	replace senmen = 1 if inlist("`cntry'", "MONTENEGRO", "BOSNIA") & strpos(managerfunction,"ACTING")>0 & strpos(managerfunction,"DIRECTOR")>0
	replace senmen = 1 if inlist("`cntry'", "CROATIA") & managerfunction=="MEMBER OF THE MANAGEMENT"
	
	** Czechia  / Slovakia
	if inlist("`cntry'", "CZECH", "SLOVAKIA") {
		replace senmen = 1 if strpos(managerfunction,"FINANCE")>0 		& strpos(managerfunction,"MANAGER")>0 
		replace senmen = 1 if strpos(managerfunction,"CHIEF")>0 		& strpos(managerfunction,"ACCOUNTANT")>0
		replace senmen = 1 if strpos(managerfunction,"OPERATING")>0 	& strpos(managerfunction,"DIRECTOR")>0 
	}
	
	** Franco
	if inlist("`cntry'", `FRANCO') {
		replace senmen = 1 if strpos(managerfunction,"SOLE")>0 			& strpos(managerfunction,"PRESIDENT")>0
		replace senmen = 1 if strpos(managerfunction,"DIRECTEUR") 		& strpos(managerfunction, "GENERAL") >0 & (strpos(managerfunction,"ADJOINT")>0 | strpos(managerfunction,"DELEGUE")>0)
		replace senmen = 1 if strpos(managerfunction,"DIRECT")>0 		& strpos(managerfunction,"FINANC")>0
		replace senmen = 1 if strpos(managerfunction,"ADMINISTRAT")>0	& strpos(managerfunction,"REPRESEN")>0 &  strpos(managerfunction, "ETAT")>0 & strpos(managerfunction,"DIRECT")>0 
		replace	senmen = 1 if strpos(managerfunction,"DIREC") > 0 		& strpos(managerfunction,"DELEGUE")>0
	}
	 
	** Germano
	if inlist("`cntry'", `GERMANO') {
		replace senmen = 1 if strpos(managerfunction,"MEMBER") > 0 		& (strpos(managerfunction,"SIGN") > 0 | strpos(managerfunction,"PROCUR") > 0)
		replace senmen = 1 if strpos(managerfunction,"PRESIDING")>0 	& strpos(managerfunction,"COMMIT")>0 
		replace senmen = 1 if strpos(managerfunction,"MANAG")>0 		& strpos(managerfunction,"DIRECT")>0 & (strpos(managerfunction, "GMBH")>0   | strpos(managerfunction, "AG")>0  |strpos(managerfunction, "EV")>0)
		replace senmen = 1 if strpos(managerfunction,"MEMB")>0 			& strpos(managerfunction,"PROCUR")>0
		replace senmen = 1 if strpos(managerfunction,"MEMB")>0 			& strpos(managerfunction, "DIRECT")>0 & strpos(managerfunction,"COMMIT")>0
	}

	** Greece
	if inlist("`cntry'", "GREECE"){
	    replace senmen=1 if strpos(managerfunction, "MEMBER ADMIN COUNCIL")>0
		replace senmen=1 if strpos(managerfunction, "MEMBER & ADMIN")>0 
	}
	
	** Hungary
	if "`cntry'"=="HUNGARY" {
		replace senmen = 1 if strpos(managerfunction,"OFFICE-BEARER")>0 
		replace senmen = 1 if strpos(managerfunction,"MEMBER")>0 & strpos(managerfunction,"ENTITLED")>0 & strpos(managerfunction, "MANAGEMENT")>0 
		replace senmen = 1 if strpos(managerfunction,"CHAIRMAN") > 0  & strpos(managerfunction,"MANAGER") > 0
		replace senmen = 1 if strpos(managerfunction,"GENERAL") > 0  & strpos(managerfunction,"MANAGER") > 0
		replace senmen = 1 if strpos(managerfunction,"MANAGING") > 0  & strpos(managerfunction,"DIRECTOR") > 0
		replace senmen = 1 if strpos(managerfunction,"MEMBER WITH MAJORITY OWNERSHIP") > 0  
		replace senmen = 0 if managerfunction == "GM" 
	}
	
	** Italian
	if "`cntry'"=="ITALY" {
		replace senmen = 1 if strpos(managerfunction,"PERSON")>0 & strpos(managerfunction,"CHARGE")>0
		replace senmen = 1 if strpos(managerfunction,"ADMINISTR")>0	& strpos(managerfunction,"CHAIRMAN")>0 
	}
	replace senmen = 1 if strpos(managerfunction,"AMMINISTRATORE")>0 & strpos(managerfunction,"STRAORDINARIO")>0
	replace senmen = 1 if strpos(managerfunction,"PRES")>0 & strpos(managerfunction,"CONSIGLIO")>0 & strpos(managerfunction,"AMM")>0
	replace senmen = 1 if strpos(managerfunction,"AMM")>0 & strpos(managerfunction,"UNICO")>0
	replace senmen = 1 if strpos(managerfunction,"AMM")>0 & strpos(managerfunction,"DELEGATO")>0
	replace senmen = 1 if strpos(managerfunction,"CONSIGLIERE")>0 & strpos(managerfunction,"DELEGATO")>0
	
	** Lithuania
	replace senmen = 1 if "`cntry'"=="LITHUANIA" & strpos(managerfunction, "DIRECTOR")>0 & (strpos(managerfunction, "FOUNDER")>0 | strpos(managerfunction, "OWNER")>0)

	** Uk / Ireland
	if inlist("`cntry'", "UK", "IRELAND") {
		foreach word in MANAG ENGAG CORPORATE TREASURY INVEST {
			replace senmen = 1 if strpos(managerfunction, "`word'")>0 &  strpos(managerfunction,"COMMITTEE")>0 
		}
		replace senmen = 1 if strpos(managerfunction,"MANAGING")>0 		& strpos(managerfunction,"DIRECT")>0  & strpos(managerfunction,"NON")==0 
		replace senmen = 1 if strpos(managerfunction,"COMPANY")>0 		& strpos(managerfunction,"CHAIRMAN")>0  & strpos(managerfunction,"NON")==0 
		replace senmen = 1 if strpos(managerfunction,"BUSINESS")>0 		& strpos(managerfunction,"MANAGER")>0 	&  strpos(managerfunction,"GENERAL")>0 
		replace senmen = 1 if strpos(managerfunction,"EXECUTIVE")>0 	& strpos(managerfunction,"NON")==0 	
		replace senmen = 1 if strpos(managerfunction,"DIRECTOR")>0		& strpos(managerfunction,"FINANC")>0 
	}

	** Scandinavia
	if inlist("`cntry'", "FINLAND") {
		replace senmen = 1 if strpos(managerfunction, "ORDINARY")>0 	& (strpos(managerfunction, "MEMBER")>0 | strpos(managerfunction, "MEMBRE")>0) & strpos(managerfunction,"DIRECTOR")>0  & strpos(managerfunction,"NON")==0  
	}

	** Slovenia
	if inlist("`cntry'", "SLOVENIA") {
		foreach word in DEPUTY VICE {
			replace senmen = 1 if strpos(managerfunction,"`word'")>0 		& strpos(managerfunction,"DIRECT")>0   
		}		
	}
	
	** Switzerland
	 if inlist("`cntry'", "SWITZERLAND") {
			replace senmen = 1 if managerfunction=="MEMBER OF THE MANAGEMENT"
	 }
	 
	 
	* c) In native language
	replace senmen = 1 if strpos(managerfunction,"ADMINISTRATEUR ")>0	& strpos(managerfunction,"REPRESENTANT")>0 & strpos(managerfunction,"NON")==0 
	replace senmen = 1 if strpos(managerfunction,"COMITATO")>0			& strpos(managerfunction,"ESECUTIVO")>0  & strpos(managerfunction,"NON")==0 
	replace senmen = 1 if strpos(managerfunction,"COMITE")>0 			& strpos(managerfunction,"DIRECTEURS")>0  & strpos(managerfunction,"INDEP")==0 
	replace senmen = 1 if strpos(managerfunction,"MEMBRE")>0 			& strpos(managerfunction,"EXECUTIF")>0 & strpos(managerfunction,"NON")==0 
	replace senmen = 1 if strpos(managerfunction,"VOORZITTER")>0
	replace senmen = 1 if strpos(managerfunction,"VORSTAND")>0
	replace senmen = 1 if strpos(managerfunction,"BESTUURSLID")>0
	replace senmen = 1 if strpos(managerfunction, "LID")>0 & strpos(managerfunction,"RAAD")>0 & strpos(managerfunction,"VAN")>0 & strpos(managerfunction,"BESTUUR")>0
	replace senmen = 1 if strpos(managerfunction,"MEMBER")>0 			& strpos(managerfunction,"DIRECTORATE")>0 
	replace senmen = 1 if strpos(managerfunction,"CHEF")>0 			& strpos(managerfunction,"COMPTABLE")>0   
	 
	foreach word in GERENCIA DIRECTIVO EXEC GERAL GESTAO {
		replace senmen = 1 if (strpos(managerfunction,"CONSELHO")>0 & strpos(managerfunction,"`word'")>0) & strpos(managerfunction,"NON")==0
	}
	
	}
							
	************************
	**#*** 3 BOARDS *******
	************************			
	if boards==1{
	di "Boards category"
	capture drop boards
	gen boards = 0
	replace boards = 1 if senmen == 1 | supboard == 1 //| audit==1

	global words "CHAIR PRESIDENT SHAREHOLDER"
	foreach word in  $words {
		replace boards = 1 if strpos(managerfunction,"`word'") != 0
	}

	replace boards = 1 if  strpos(managerfunction,"ASSEM") != 0 & strpos(managerfunction,"GENER") != 0

	global words "BOARD DEPUTY DIRECTOR ORDINARY REGULAR"
	foreach word in  $words {
		replace boards = 1 if strpos(managerfunction, "MEMBER") != 0 & strpos(managerfunction,"`word'") != 0
	}

	global words "AG EG EV"
	foreach word in  $words {
		replace boards = 1 if strpos(managerfunction, "MEMBER") != 0 & strpos(managerfunction,"(`word')") != 0
}

	global words "DEPUTY DIRECT ORDINARY"
	foreach word in  $words {
		replace boards = 1 if strpos(managerfunction, "BOARD") != 0 & strpos(managerfunction,"`word'")!=0
}
	replace boards = 1 if strpos(managerfunction, "PARTNER")>0	
	replace boards = 1 if managerfunction=="MEMBER"
	
	replace boards = 1 if strpos(managerfunction,"LLP")>0 & strpos(managerfunction,"MEMBER")>0 
	replace boards = 1 if strpos(managerfunction,"BOARD") & strpos(managerfunction,"DIRECTORS")>0 
	
	replace boards = 1 if strpos(managerfunction, "VOTER")>0 & country=="PORTUGAL"
	replace boards = 1 if strpos(managerfunction, "MEMBER OF THE COUNCIL")>0 & "`cntry'"=="LATVIA"

	
	if "`cntry'"=="CZECH"{ // We won't be able to tell where are they exactly, safe to put them in boards
	    replace boards   = 1 if strpos(managerfunction,"COMMISSIONER")>0 & strpos(managerfunction, "EXECUTIVE HEAD")>0  //These guys are supboard since COMISSIONER. These guys are senmen since EXECUTIVE
		replace supboard = 0 if strpos(managerfunction,"COMMISSIONER")>0 & strpos(managerfunction, "EXECUTIVE HEAD")>0 //According to Amadeus they are SupB and SenMen
		replace senmen   = 0 if strpos(managerfunction,"COMMISSIONER")>0 & strpos(managerfunction, "EXECUTIVE HEAD")>0 //According to Amadedeus they are in BoD for sure
	}
	
		if "`cntry'"!="UK"{
			replace boards = 1 if (strpos(managerfunction, "ADVISOR")>0 | strpos(managerfunction, "ADVISER")>0)
	}
	
	}
	************************
	**#*** 4 TOPMAN *******
	************************
	if topman==1{
	di "Topmanager category"
	capture drop topmanager 
	gen topmanager = 0	

	replace topmanager = 1 if (strpos(managerfunction, "ADVISER")>0 | strpos(managerfunction, "ADVISOR" )>0 | strpos(managerfunction, "CONSIGLIERE")>0) & boards==0
	replace topmanager = 1 if strpos(managerfunction, "PROXY")>0 & boards==0
	replace topmanager = 1 if strpos(managerfunction, "AUTHORISED")>0 & strpos(managerfunction, "SIGNATORY")>0 & boards==0
	replace topmanager = 1 if strpos(managerfunction, "LEGAL")>0      & strpos(managerfunction, "REPRESENTATIVE")>0 & boards==0
	replace topmanager = 1 if strpos(managerfunction, "BUSINESS")>0   & strpos(managerfunction, "REPRESENTATIVE")>0 & boards==0

	if inlist("`cntry'", "UK", "IRELAND"){
		replace topmanager = 1 if strpos(managerfunction, "SECRETARY")>0 & strpos(managerfunction, "COMPANY")>0     & boards==0
		replace topmanager = 1 if strpos(managerfunction, "SECRETARY")>0 & strpos(managerfunction, "BOARD")>0     & boards==0		
}     

	replace topmanager = 1 if strpos(managerfunction, "HEAD")>0 | strpos(managerfunction, "DIRECTOR")>0 

	foreach name in EXEC DIRECT HEAD{
		foreach word in INFOR SALE PRODUCTION CREATIVE PURCHAS ECONOMIC EXPORT IMPORT ECONOMY ENGENEE ENGINEE PUBLIC STRATEGY INVEST MARKET TECHNIC PLANNING OPERAT DEVELO EXPORT ADVERT FINANC HUMAN TECHNICAL TRUSTEE COMME QUALITY ACHATS LOGIST FINAN{
			replace topmanager = 1 if strpos(managerfunction,"`name'")>0  & strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 & strpos(managerfunction,"`word'")>0 & boards==0
	} 
		foreach word in IT HR{
			replace topmanager = 1 if strpos(managerfunction,"`name'")>0  & strpos(managerfunction,"NON")==0 & strpos(managerfunction,"INDEP")==0 & (strpos(managerfunction," `word'")>0 | strpos(managerfunction,"`word' ")>0) & boards==0
	} 
}
}
		
	***********************
	**#*** 5 ORBIS HELP****	 
	***********************
	if orbis==1{
	di "Orbis help"
	
	if country!="UK"{
	    // Can't trust in sole (typeofposition,SenMan)
		//BoD & SenMan		
		replace senmen=1 if strpos(typeofposition,"BoD")!=0 & strpos(typeofposition,",")!=0 & ( supboard==0 & strpos(typeofposition,"SupB")==0 & strpos(typeofposition,"NomC")==0 & strpos(typeofposition,"AudC")==0 & strpos(typeofposition,"RiskC")==0 & strpos(typeofposition,"RemC")==0 & strpos(typeofposition,"CoGoC")==0 & strpos(typeofposition,"ChmC")==0 & strpos(typeofposition,"AdvC")==0 ) & strpos(managerfunction, "SECRETARY")==0 //& strpos(typeofposition,"OthBC")==0
	
				
		* BoD 
		replace boards=1 if strpos(typeofposition, "BoD")!=0 & strpos(managerfunction, "SECRETARY")==0
		replace boards=1 if strpos(levelofresponsibility, "PRESIDENT")!=0 & strpos(managerfunction, "SECRETARY")==0
		replace boards=1 if strpos(levelofresponsibility, "CHAIR")!=0 & strpos(managerfunction, "SECRETARY")==0
		replace boards=1 if strpos(levelofresponsibility, "MEMBER")!=0 & strpos(managerfunction, "SECRETARY")==0
		
		* Chiefs 
		replace senmen=1 if strpos(levelofresponsibility, "CHIEF")!=0 & senmen==0 & supboard==0 & audit==0
		replace senmen=1 if strpos(levelofresponsibility, "TREASURER")!=0 & senmen==0 & supboard==0 & audit==0
		
		* If board member is he a specific - managing executive? 
		foreach name in EXEC{
			foreach word in INFOR SALE PRODUCTION CREATIVE PURCHAS ECONOMIC EXPORT IMPORT ECONOMY ENGENEE ENGINEE PUBLIC STRATEGY INVEST MARKET TECHNIC PLANNING OPERAT DEVELO EXPORT ADVERT FINANC HUMAN TECHNICAL TRUSTEE COMME QUALITY ACHATS LOGIST FINAN{
				replace senmen = 1 if strpos(levelofresponsibility,"`name'")>0  & strpos(levelofresponsibility,"NON")==0 & strpos(levelofresponsibility,"INDEP")==0 & strpos(levelofresponsibility,"`word'")>0 & strpos(levelofresponsibility, "UNSPEC")==0 & boards==1 & supboard==0 & audit==0
	} 
		foreach word in IT HR{
			replace senmen = 1 if strpos(levelofresponsibility,"`name'")>0  & strpos(levelofresponsibility,"NON")==0 & strpos(levelofresponsibility,"INDEP")==0 & (strpos(levelofresponsibility," `word'")>0 | strpos(levelofresponsibility,"`word' ")>0) & strpos(levelofresponsibility, "UNSPEC")==0 & boards==1 & supboard==0 & audit==0
	} 
}		
		* some more senmen
		replace senmen=1 if strpos(levelofresponsibility,"HIGHEST EXECUTIVE")>0 & audit==0 & supboard==0 & boards==1
		replace senmen=1 if strpos(levelofresponsibility,"DEPUTY EXECUTIVE")>0 & audit==0 & supboard==0 & boards==1
		
		replace senmen=1 if strpos(boardcommitteeordepartment, "BOARD")>0 & strpos(boardcommitteeordepartment,"MANAG")>0 & audit==0 & supboard==0 & boards==1
		replace senmen=1 if (strpos(boardcommitteeordepartment, "EXECUTIVE BOARD")>0 | strpos(boardcommitteeordepartment, "EXECUTIVE COMMITTEE")>0) & strpos(boardcommitteeordepartment, "NON")==0 & supboard==0 & audit==0					
		replace senmen=1 if strpos(typeofposition, "SenMan")>0 & boards==1 & supboard==0 & audit==0			 
		
		* topmans
		// Highest executives
		replace topmanager=1 if	strpos(levelofresponsibility, "HIGHEST EXECUTIVE")!=0 & boards==0 
		
		
		foreach name in EXEC{
			foreach word in INFOR SALE PRODUCTION CREATIVE PURCHAS ECONOMIC EXPORT IMPORT ECONOMY ENGENEE ENGINEE PUBLIC STRATEGY INVEST MARKET TECHNIC PLANNING OPERAT DEVELO EXPORT ADVERT FINANC HUMAN TECHNICAL TRUSTEE COMME QUALITY ACHATS LOGIST FINAN{
				replace topmanager = 1 if strpos(levelofresponsibility,"`name'")>0  & strpos(levelofresponsibility,"NON")==0 & strpos(levelofresponsibility,"INDEP")==0 & strpos(levelofresponsibility,"`word'")>0 & strpos(levelofresponsibility, "UNSPEC")==0 & boards==0 
	} 
		foreach word in IT HR{
			replace topmanager = 1 if strpos(levelofresponsibility,"`name'")>0  & strpos(levelofresponsibility,"NON")==0 & strpos(levelofresponsibility,"INDEP")==0 & (strpos(levelofresponsibility," `word'")>0 | strpos(levelofresponsibility,"`word' ")>0) & strpos(levelofresponsibility, "UNSPEC")==0 & boards==0
	} 
}

	if "`cntry'"!="UK"{
		replace boards = 1 if strpos(typeofposition, "AdvC") & audit==0
	}
				
}			
}	
	******************************
	**#*** 6 MANUAL CORRECTIONS****	 
	******************************
	if corrections==1{
	* small SENMEN AND BOARDS corrections
	replace	senmen = 0 if  strpos(managerfunction,"GOVERNING")>0 & inlist("`cntry'", "SPAIN") 
	replace senmen = 0 if  strpos(managerfunction,"COMMISSIONER")>0	& inlist("`cntry'", "CZECH") 		 
	replace senmen = 0 if  strpos(managerfunction,"SUPERVISORY")>0
	
	foreach brds in senmen boards{					
		replace	`brds' = 0 if  strpos(managerfunction, "INSOLVENCY")>0 		
		replace	`brds' = 0 if  strpos(managerfunction, "JUDICIAL")>0
		replace	`brds' = 0 if  strpos(managerfunction, "PERSON AUTHORIZED TO REPRESENT")>0
		replace `brds' = 0 if  strpos(managerfunction, "SECRETARY")>0 & strpos(managerfunction, "CHIEF")==0
		
		replace	`brds' = 0 if  strpos(managerfunction, "LEGAL REPRESENTATIVE")>0  & inlist("`cntry'", "BELGIUM") 
	
		replace	`brds' = 0 if  strpos(managerfunction, "SALES EXECUTIVE")>0 & country=="UK"
		replace	`brds' = 0 if  strpos(managerfunction, "MARKETING EXECUTIVE")>0 & country=="UK"
		replace	`brds' = 0 if  strpos(managerfunction, "ADVERTISING EXECUTIVE")>0 & country=="UK"
		
	}
	
	
	replace supboard = 0 if  strpos(managerfunction, "SECRETARY")>0 
	replace boards = 0 if  strpos(managerfunction, "SOLVENCY")>0 | strpos(managerfunction, "JUDICIAL")>0 |strpos(managerfunction, "PERSON AUTHORIZED TO REPRESENT")>0 | strpos(managerfunction, "LEGAL REPRESENTATIVE")>0 | strpos(managerfunction, "COURT")>0 | strpos(managerfunction, "INVESTIGATOR")>0 | strpos(managerfunction, "INSOLVENCY")>0
	replace boards = 0 if  strpos(managerfunction, "LIQUID")>0 
	
	* small supboard correction
	replace	supboard = 0 if  strpos(managerfunction, "JUDICIAL")>0
	replace	supboard = 0 if  strpos(managerfunction, "COURT")>0
	replace	supboard = 0 if  strpos(managerfunction, "INVESTIGATOR")>0
	replace	supboard = 0 if  strpos(managerfunction, "CEO")>0
	replace	supboard = 0 if  strpos(managerfunction, "BANK")>0
	replace	supboard = 0 if  strpos(managerfunction, "INSOLVENCY")>0
	replace	supboard = 0 if  strpos(managerfunction, "NON")>0 & strpos(managerfunction, "DESIGNATE")>0
	replace supboard = 0 if strpos(managerfunction, "SUPERDAD LIABILITY")>0 						& strpos(managerfunction, "SURVEIL")==0 & strpos(managerfunction, "SUPERVISO")==0
	
	* supervisory senmen conflicts	
	replace senmen = 0 if strpos(managerfunction, "GENERAL ASSEMBLY")>0 							& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "MANAG")==0 & strpos(managerfunction, "CEO")==0	
	replace senmen = 0 if strpos(managerfunction, "RISK MANAG")>0 									& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "SENIOR MANAG")==0 	& strpos(managerfunction, "CEO")==0
	replace senmen = 0 if strpos(managerfunction, "NON-")>0 & strpos(managerfunction, "EXEC")>0 	& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "MANAG")==0 		& strpos(managerfunction, "CEO")==0
	replace senmen = 0 if strpos(managerfunction, "MANAGEMENT ENGAGEMENT")>0 						& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "SENIOR MANAG")==0 	& strpos(managerfunction, "CEO")==0
	replace senmen = 0 if strpos(managerfunction, "MANAGEMENT DEVELOPMENT")>0 						& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "SENIOR MANAG")==0 	& strpos(managerfunction, "CEO")==0
	replace senmen = 0 if strpos(managerfunction, "STRATEGY COMMITTEE")>0 							& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "MANAG")==0 		& strpos(managerfunction, "CEO")==0
	replace senmen = 0 if strpos(managerfunction, "COMMITTEE FOR MANAGEMENT")>0 					& strpos(managerfunction, "CHIEF")==0 												& strpos(managerfunction, "CEO")==0
	replace senmen = 0 if strpos(managerfunction, "ADMINISTRATEUR INDEPENDANT")>0 					& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "MANAG")==0 		& strpos(managerfunction, "CEO")==0
	replace senmen = 0 if strpos(managerfunction, "INDEPENDENT")>0 & (strpos(managerfunction, "DIRECTOR")>0 | strpos(managerfunction, "MEMBER")>0)	& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "MANAG")==0 & strpos(managerfunction, "CEO")==0
	
	replace senmen = 0 if strpos(managerfunction, "RISK AND INVESTMENT COMMITTEE")>0 				& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "MANAG")==0 & strpos(managerfunction, "CEO")==0
	replace senmen = 0 if strpos(managerfunction, "CORPORATE GOVERNANCE")>0 						& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "MANAG")==0 & strpos(managerfunction, "CEO")==0
	replace senmen = 0 if strpos(managerfunction, "RESPONSIBILITY COMMITTEE")>0 					& strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "MANAG")==0 & strpos(managerfunction, "CEO")==0
	replace senmen = 0 if (strpos(managerfunction, "REMUNERATION")>0 | strpos(managerfunction, "COMPENSATION")>0) & strpos(managerfunction, "COMMITTEE")>0 & strpos(managerfunction, "CHIEF")==0 & strpos(managerfunction, "MANAG")==0 & strpos(managerfunction, "CEO")==0	
				
	}
		
	*************
	*** FINAL ***
	*************
	replace boards = 1 if senmen==1 | supboard==1 | audit==1 
	
	gen conflict 	= 1 if senmen==1 & supboard==1
	replace senmen	= 0 if conflict==1
	replace supboard= 0 if conflict==1
	
	
	capture gen person
	gen person = 1
			
	***********************
	******* MERGE *********
	***********************
	
	// save classified functions
	save "$function_path\_functions\functions_`cntry'.dta" , replace
	clear
	
	// load manager-wave-country file
	use "$bycountry_path\__after_legalform\managers_`cntry'.dta"
	
	// drop obs with missing function
	drop if functionid == .
	
	// merge classification indicators by dfunction id to managers
	merge n:1 functionid using "$function_path\_functions\functions_`cntry'.dta", keepusing(supboard senmen boards person) nogen //topmanager ambg audit nofunction
				
	// save final file
	compress
	save "$function_path\managers_function2_`cntry'.dta" , replace 
		
	************************
	**#*** 7. CHECKS *******
	************************
	if checks==1{

	// Tabulate faces a limit of display rows. Change the limit of the count of the min number of frequency of appearances for tabulation purposes.			
	duplicates tag managerfunction, gen(FREQ)
	keep if FREQ>1000
	
	qui log using "$function_path\checks_`cntry'" , replace text
	
	di _newline(3) "Country: `cntry'" _newline(3)
			
	di "Country: `cntry'; MANAGEMENT BOARD"
	tab managerfunction if senmen==1 & country == "`cntry'", sort

	di "Country: `cntry'; SUPBOARD"
	tab managerfunction if supboard==1 & country == "`cntry'", sort

	di "Country: `cntry'; BOARDS"
	tab managerfunction if boards==1 & country == "`cntry'", sort
	
	di "Country: `cntry'; NO FUNCTION"
	tab managerfunction if boards==0 & country == "`cntry'", sort
	
	qui log close
	}	
	
}
	clear
	
	
