/******************************************************************************/
/*	 						Gender assignment 								  */
/******************************************************************************/
clear

// close if there is opened log file
capture log close

// list of all countries 
global countries "ALBANIA AUSTRIA BELARUS BELGIUM BOSNIA BULGARIA CROATIA CYPRUS CZECH DENMARK ESTONIA FINLAND FRANCE GERMANY GREECE HUNGARY ICELAND IRELAND ITALY KOSOVO LATVIA LIECHTENSTEIN LITHUANIA LUXEMBOURG MACEDONIA MALTA MOLDOVA MONACO MONTENEGRO NORWAY POLAND PORTUGAL ROMANIA RUSSIA SERBIA SLOVAKIA SLOVENIA SPAIN SWEDEN SWITZERLAND TURKEY  UKRAINE UK"
//
// NETHERLANDS 

// list of variables which will saved in the end of this dofile
global vars_to_save "bvdidnumber country lastyear fullname title salutation suffix sup_shouldhave uciuniquecontactidentifier gender* is_current year_appointment year_resignation year_lastips year_notvalidafter confirmationdatemin confirmationdatemax min_years max_years start end senmen supboard prepared_name firm source boards person"	 //topmanager ambg audit nofunction

foreach cntry of global countries {
	// load data
	use "$function_path\managers_function2_`cntry'.dta" // !!! 2 - the new one
	
	// correct for the confirmationdates mess - should be corrected back to the beginning
	capture gen confirmationdatemax =.
	capture gen confirmationdatemin =.
	capture gen confiramtiondatemax =.
	capture gen confiramtiondatemin =.
	
	capture replace confirmationdatemax = confiramtiondatemax if !missing(confiramtiondatemax) & (missing(confirmationdatemax) | confirmationdatemax > confirmationdatemax)	
	capture replace confirmationdatemin = confiramtiondatemin if !missing(confiramtiondatemax) & (missing(confirmationdatemin) | confirmationdatemin < confiramtiondatemin)	
	
	// keep these observations which have assigned function
	//keep if (supboard == 1 | senmen == 1 | boards==1 | topmanager==1) //JT: "For accounting and analysis reasons"
		
	// drop varaibles that are generated after to avoid errors
	capture rename gender gender_ama
	capture replace title = titleiedrlord if source == 2020
	
	// drop if do not have manager names
	count if fullname == ""
	scalar droppedobs = `r(N)'
	drop if fullname == ""

	// prepare variable with names - clean it from salutations and titles and suffices
	gen name = subinstr(fullname, salutation, "", .)
	replace name = subinstr(name, title, "", .)
	replace name = subinstr(name, suffix, "", .)
	replace name = ustrupper(name)
	replace name = subinstr(name, "Ł", "L", .)
	replace name = subinstr(name, ".", "", .)
	replace name = subinstr(name, "-", " ", .)
	replace name = subinstr(name, ",", " ", .)
	replace name = subinstr(name, ")", " ", .)
	replace name = subinstr(name, "(", " ", .)
	replace name = subinstr(name, "]", " ", .)
	replace name = subinstr(name, "[", " ", .)
	replace name = subinstr(name, "!", "", .)
	replace name = subinstr(name, "'", "", .)
	replace name = subinstr(name, char(34), "", .)
	ren name prepared_name
	
	// firms detection (still can be improved)
	capture drop firm
	gen firm = .
	if "`cntry'" == "UK" {
		global firm_det "ACCOUNT Account ASSOCIAT Associat B.V COMPANY COUNCIL Council CONSULT CORPORATION CORP. DIRECTOR ESTATE FOUNDTAION GMBH GmbH GROUP HOLDING INCORPORATED INTERNATIONAL INVESTMENT Limited LIMITED LIMTED LTD Ltd LLP Llp LLC L.L.C. Llc MARKETING MANAGEMENT Management N.V. PARTNER PLC Plc S.A. SERVICES Services SECRETAR Secretar SOLICITOR Solicitor"
		foreach word of global firm_det {
			replace firm = 1 if strpos(fullname, "`word'") > 0
		}
		replace firm = 1 if strpos(fullname, "& CO") > 0
		replace firm = 1 if strpos(fullname, "& Co") > 0
		replace firm = 1 if strpos(fullname, "P L C") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" A/S")), " A/S") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AB")), " AB") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AG")), " AG") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" BV")), " BV") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA")), " SA") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" INC")), " INC") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" INC.")), " INC.") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Inc.")), " Inc.") > 0
		replace firm = 1 if strpos(fullname, char(38)) > 0
	}
	if "`cntry'" == "POLAND" {
		replace firm = 1 if strpos(fullname, "Sp. z o.o.") > 0
		replace firm = 1 if strpos(fullname, "Sp z oo") > 0
		replace firm = 1 if strpos(fullname, " SA ") > 0
		replace firm = 1 if strpos(fullname, "S.A.") > 0
		replace firm = 1 if strpos(fullname, "S-ka z oo") > 0
		replace firm = 1 if strpos(fullname, "Sp. K.") > 0
		replace firm = 1 if strpos(fullname, "Sp.k.") > 0
		replace firm = 1 if strpos(fullname, "GmbH") > 0
	}
	if "`cntry'" == "GERMANY" {
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "Gmbh") > 0
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "gmbh") > 0
		replace firm = 1 if strpos(fullname, "G.m.b.H.") > 0
		replace firm = 1 if strpos(fullname, "mbH") > 0
		replace firm = 1 if strpos(fullname, "mit beschraenkter Haftung") > 0
		replace firm = 1 if strpos(fullname, "mit beschränkter Haftung") > 0
		replace firm = 1 if strpos(fullname, "Gesellschaft") > 0
		replace firm = 1 if strpos(fullname, "gesellschaft") > 0
		replace firm = 1 if strpos(fullname, "GESELLSCHAFT") > 0
		replace firm = 1 if strpos(fullname, "S.a.r.l.") > 0
		replace firm = 1 if strpos(fullname, "S.á.r.l.") > 0
		replace firm = 1 if strpos(fullname, "S.à.r.l.") > 0
		replace firm = 1 if strpos(fullname, "s.a.r.l.") > 0
		replace firm = 1 if strpos(fullname, "Sarl") > 0
		replace firm = 1 if strpos(fullname, "Limited") > 0
		replace firm = 1 if strpos(fullname, "LIMITED") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "LLC") > 0
		replace firm = 1 if strpos(fullname, "verwaltung") > 0
		replace firm = 1 if strpos(fullname, "Verwaltung") > 0
		replace firm = 1 if strpos(fullname, "VERWALTUNG") > 0
		replace firm = 1 if strpos(fullname, "B.V.") > 0
		replace firm = 1 if strpos(fullname, "SA") > 0
		replace firm = 1 if strpos(fullname, "AG") > 0
		replace firm = 1 if strpos(fullname, "AB") > 0
		replace firm = 1 if strpos(fullname, "KG") > 0
		replace firm = 1 if strpos(fullname, "UG") > 0
		replace firm = 1 if strpos(fullname, "SL") > 0
		replace firm = 1 if strpos(fullname, "S.L.") > 0
		replace firm = 1 if strpos(fullname, "MARKETING") > 0
		replace firm = 1 if strpos(fullname, "MANAGEMENT") > 0
		replace firm = 1 if strpos(fullname, "Management") > 0
		replace firm = 1 if strpos(fullname, "BETEILIGUNGS") > 0
		replace firm = 1 if strpos(fullname, "Beteiligungs") > 0
		replace firm = 1 if strpos(fullname, "beteiligungs") > 0
		replace firm = 1 if strpos(fullname, "HOLDING") > 0
		replace firm = 1 if strpos(fullname, "BVBA") > 0
		replace firm = 1 if strpos(fullname, "Corp.") > 0
		replace firm = 1 if strpos(fullname, "Familienstiftung") > 0
		replace firm = 1 if strpos(fullname, "haftungsbeschraenkt") > 0
		replace firm = 1 if strpos(fullname, "Societe Civile") > 0
		replace firm = 1 if strpos(fullname, "Stiftung") > 0
		replace firm = 1 if strpos(fullname, "International") > 0
		replace firm = 1 if strpos(fullname, "Kommanditisten") > 0
	}
	if "`cntry'" == "FRANCE" {
		replace fullname = fullname + " "
		replace firm = 1 if strpos(fullname, "FINANCIERE") > 0
		replace firm = 1 if strpos(fullname, "FINANCE") > 0
		replace firm = 1 if strpos(fullname, "HOLDING") > 0
		replace firm = 1 if strpos(fullname, "Holding") > 0
		replace firm = 1 if strpos(fullname, "INVESTISSEMENTS") > 0
		replace firm = 1 if strpos(fullname, "SARL") > 0
		replace firm = 1 if strpos(fullname, "Sarl") > 0
		replace firm = 1 if strpos(fullname, "SOCIETE") > 0
		replace firm = 1 if strpos(fullname, "SOCIeT") > 0
		replace firm = 1 if strpos(fullname, "Societe") > 0
		replace firm = 1 if strpos(fullname, "GROUP") > 0
		replace firm = 1 if strpos(fullname, "Group") > 0
		replace firm = 1 if strpos(fullname, "COMPAGNIE") > 0
		replace firm = 1 if strpos(fullname, "INTERNATIONAL") > 0
		replace firm = 1 if strpos(fullname, "IMMOBILIER") > 0
		replace firm = 1 if strpos(fullname, "MANAGEMENT") > 0
		replace firm = 1 if strpos(fullname, "Management") > 0
		replace firm = 1 if strpos(fullname, "CONSEIL") > 0
		replace firm = 1 if strpos(fullname, "COMPANY") > 0
		replace firm = 1 if strpos(fullname, "INVEST") > 0
		replace firm = 1 if strpos(fullname, "Invest") > 0
		replace firm = 1 if strpos(fullname, "MANAGERS") > 0
		replace firm = 1 if strpos(fullname, "GESTION") > 0
		replace firm = 1 if strpos(fullname, "ASSOCIATION") > 0
		replace firm = 1 if strpos(fullname, "DEVELOPPEMENT") > 0
		replace firm = 1 if strpos(fullname, "DEVELOPMENT") > 0
		replace firm = 1 if strpos(fullname, "Developpement") > 0
		replace firm = 1 if strpos(fullname, "DeVELOPPEMENT") > 0
		replace firm = 1 if strpos(fullname, "ACT") > 0
		replace firm = 1 if strpos(fullname, "A.C.T.") > 0
		replace firm = 1 if strpos(fullname, "BV") > 0
		replace firm = 1 if strpos(fullname, "B.V.") > 0
		replace firm = 1 if strpos(fullname, "S A ") > 0
		replace firm = 1 if strpos(fullname, " SA ") > 0
		replace firm = 1 if strpos(fullname, "S.A.") > 0
		replace firm = 1 if strpos(fullname, "S A R L") > 0
		replace firm = 1 if strpos(fullname, "S.R.L.") > 0
		replace firm = 1 if strpos(fullname, "LIMITED") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "LLC") > 0
		replace firm = 1 if strpos(fullname, "COMMERCES") > 0
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "MBH") > 0
		replace firm = 1 if strpos(fullname, "Mbh") > 0
		replace firm = 1 if strpos(fullname, "UNION") > 0
		replace firm = 1 if strpos(fullname, "Union") > 0
		replace firm = 1 if strpos(fullname, "SERVICE") > 0
		replace firm = 1 if strpos(fullname, "MARKETING") > 0
		replace firm = 1 if strpos(fullname, "CAPITAL") > 0
		replace firm = 1 if strpos(fullname, "Capital") > 0
		replace firm = 1 if strpos(fullname, "CORPORATION") > 0
		replace firm = 1 if strpos(fullname, "HOTEL") > 0
		replace firm = 1 if strpos(fullname, "VENTURE") > 0
		replace firm = 1 if strpos(fullname, "CONSULTING") > 0
		replace firm = 1 if strpos(fullname, "LOGISTICS") > 0
		replace firm = 1 if strpos(fullname, "Entreprise") > 0
		replace firm = 1 if strpos(fullname, "PROMOTION") > 0
		replace firm = 1 if strpos(fullname, "ENERGY") > 0
		replace firm = 1 if strpos(fullname, "EQUITY") > 0
		replace firm = 1 if strpos(fullname, "BANQUE") > 0
		replace firm = 1 if strpos(fullname, "Banque") > 0
		replace firm = 1 if strpos(fullname, "ASSOCIES") > 0
		replace firm = 1 if strpos(fullname, "Associes") > 0
		replace firm = 1 if strpos(fullname, "DISTRIBUTION") > 0
		replace firm = 1 if strpos(fullname, "& CO.") > 0
		replace firm = 1 if strpos(fullname, "PARTICIPATIONS") > 0
		replace firm = 1 if strpos(fullname, "SELARL") > 0
		replace firm = 1 if strpos(fullname, "SNC") > 0
		replace firm = 1 if strpos(fullname, "S.N.C.") > 0
		replace firm = 1 if strpos(fullname, " SPA") > 0
		replace firm = 1 if strpos(fullname, "EURL") > 0
		replace firm = 1 if strpos(fullname, "COOPERATIVE") > 0
		replace firm = 1 if strpos(fullname, "SYNDICAT") > 0
		replace firm = 1 if strpos(fullname, "Syndicat") > 0
		replace firm = 1 if strpos(fullname, "TRANSPORTS") > 0
		replace firm = 1 if strpos(fullname, "Transports") > 0
		replace firm = 1 if strpos(fullname, "UNIVERSIT") > 0
		replace firm = 1 if strpos(fullname, "TECHN") > 0
		replace firm = 1 if strpos(fullname, "INFRASTR") > 0
	}
	if "`cntry'" == "ITALY" {
		replace firm = 1 if strpos(fullname, "SRL") > 0
		replace firm = 1 if strpos(fullname, "S.P.A") > 0
		replace firm = 1 if strpos(fullname, "S.C.P.A") > 0
		replace firm = 1 if strpos(fullname, "S.N.C.") > 0
		replace firm = 1 if strpos(fullname, "SnC") > 0
		replace firm = 1 if strpos(fullname, "S. L.") > 0
		replace firm = 1 if strpos(fullname, "S.A.") > 0
		replace firm = 1 if strpos(fullname, "S.R.L.") > 0
		replace firm = 1 if strpos(fullname, "SRL") > 0
		replace firm = 1 if strpos(fullname, "Srl") > 0
		replace firm = 1 if strpos(fullname, "S.R.L.S.") > 0
		replace firm = 1 if strpos(fullname, "SARL") > 0
		replace firm = 1 if strpos(fullname, "S.A.R.L.") > 0
		replace firm = 1 if strpos(fullname, "SOCIETA") > 0
		replace firm = 1 if strpos(fullname, "LIMITED") > 0
		replace firm = 1 if strpos(fullname, "LLC") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "Invest") > 0
		replace firm = 1 if strpos(fullname, "INVEST") > 0
		replace firm = 1 if strpos(fullname, "SpA") > 0
		replace firm = 1 if strpos(fullname, " SPA") > 0
		replace firm = 1 if strpos(fullname, " SA") > 0
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "G.M.B.H.") > 0
		replace firm = 1 if strpos(fullname, "MBH") > 0
		replace firm = 1 if strpos(fullname, "SpA") > 0
		replace firm = 1 if strpos(fullname, "B.V.") > 0
		replace firm = 1 if strpos(fullname, "BVBA") > 0
		replace firm = 1 if strpos(fullname, "A.L.A.R.") > 0
		replace firm = 1 if strpos(fullname, "CONFEDERAZIONE") > 0
		replace firm = 1 if strpos(fullname, "ASSOCIAZIONE") > 0
		
	}
	if "`cntry'" == "POLAND" {
		replace firm = 1 if strpos(fullname, "Sp. z o.o.") > 0
		replace firm = 1 if strpos(fullname, "Sp z oo") > 0
		replace firm = 1 if strpos(fullname, "Spolka z") > 0
		replace firm = 1 if strpos(fullname, "S.A.") > 0
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "mbH") > 0
		replace firm = 1 if strpos(fullname, "B.V.") > 0
		replace firm = 1 if strpos(fullname, "S-ka z oo") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
	}
	if "`cntry'" == "PORTUGAL" {
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "mbH") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "Lda") > 0
		replace firm = 1 if strpos(fullname, "LDA") > 0
		replace firm = 1 if strpos(fullname, "Sociedade") > 0
		replace firm = 1 if strpos(fullname, "SOCIEDADE") > 0
		replace firm = 1 if strpos(fullname, "SpA") > 0
		replace firm = 1 if strpos(fullname, "BV") > 0
		replace firm = 1 if strpos(fullname, "B.V.") > 0
		replace firm = 1 if strpos(fullname, "ASSOCIADOS") > 0
		replace firm = 1 if strpos(fullname, "ASSOC.") > 0
		replace firm = 1 if strpos(fullname, "ASS.") > 0
		replace firm = 1 if strpos(fullname, "A/S") > 0
		replace firm = 1 if strpos(fullname, "Sarl") > 0
		replace firm = 1 if strpos(fullname, "Srl") > 0
		replace firm = 1 if strpos(fullname, "LLC") > 0
		replace firm = 1 if strpos(fullname, "Co KG") > 0
		replace firm = 1 if strpos(fullname, "Co SA") > 0
		replace firm = 1 if strpos(fullname, "Goverment") > 0
		replace firm = 1 if strpos(fullname, "Government") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA")), " SA") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AG")), " AG") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" KG")), " KG") > 0
	}
	if "`cntry'" == "BELGIUM" {
		replace firm = 1 if strpos(fullname, "B.V.B.A.") > 0
		replace firm = 1 if strpos(fullname, "BVBA") > 0
		replace firm = 1 if strpos(fullname, "bvba") > 0
		replace firm = 1 if strpos(fullname, "Bvba") > 0
		
		replace firm = 1 if strpos(fullname, "BV") > 0
		replace firm = 1 if strpos(fullname, "B.V.") > 0
		
		replace firm = 1 if strpos(fullname, "HOLDING") > 0
		replace firm = 1 if strpos(fullname, "Holding") > 0
		replace firm = 1 if strpos(fullname, "INVEST") > 0
		replace firm = 1 if strpos(fullname, "Invest") > 0
		
		replace firm = 1 if strpos(fullname, "SARL") > 0
		replace firm = 1 if strpos(fullname, "Sarl") > 0
		replace firm = 1 if strpos(fullname, "S A R L") > 0
		replace firm = 1 if strpos(fullname, "S.R.L.") > 0
		replace firm = 1 if strpos(fullname, "SRL") > 0
		replace firm = 1 if strpos(fullname, "SPRL") > 0
		replace firm = 1 if strpos(fullname, "Sprl") > 0

		replace firm = 1 if strpos(fullname, "S A ") > 0
		replace firm = 1 if strpos(fullname, " SA ") > 0
		replace firm = 1 if strpos(fullname, "S.A.") > 0

		replace firm = 1 if strpos(fullname, "LIMITED") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "LLC") > 0
		replace firm = 1 if strpos(fullname, "CONSULT") > 0

		replace firm = 1 if strpos(fullname, "MANAGEMENT") > 0
		replace firm = 1 if strpos(fullname, "Management") > 0
		
		replace firm = 1 if strpos(fullname, "GROUP") > 0
		replace firm = 1 if strpos(fullname, "Group") > 0
		
		replace firm = 1 if strpos(fullname, "VENTURE") > 0
		replace firm = 1 if strpos(fullname, "CAPITAL") > 0
		replace firm = 1 if strpos(fullname, "Capital") > 0
		
		replace firm = 1 if strpos(fullname, "LOGISTICS") > 0
		
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "Gmbh") > 0
		replace firm = 1 if strpos(fullname, "gmbh") > 0
		replace firm = 1 if strpos(fullname, "MBH") > 0
		replace firm = 1 if strpos(fullname, "Mbh") > 0
		
		replace firm = 1 if strpos(fullname, "ADMINISTRATION") > 0
		replace firm = 1 if strpos(fullname, "Administration") > 0
		replace firm = 1 if strpos(fullname, "& CO") > 0
		replace firm = 1 if strpos(fullname, "ADVOCATENKANTOOR") > 0
		replace firm = 1 if strpos(fullname, "Advocatenkantoor") > 0

		replace firm = 1 if strpos(fullname, "ENGINEERING") > 0
		replace firm = 1 if strpos(fullname, "ASSOCIACAO") > 0
		replace firm = 1 if strpos(fullname, "Associated") > 0
		replace firm = 1 if strpos(fullname, "ASSOCIATED") > 0
		replace firm = 1 if strpos(fullname, "Association") > 0
		replace firm = 1 if strpos(fullname, "ASSOCIATION") > 0
		replace firm = 1 if strpos(fullname, "BEHEER") > 0
		replace firm = 1 if strpos(fullname, "BANQUE") > 0
		replace firm = 1 if strpos(fullname, "Banque") > 0
		replace firm = 1 if strpos(fullname, "BANK") > 0
		replace firm = 1 if strpos(fullname, "Bank") > 0
		replace firm = 1 if strpos(fullname, "BENELUX") > 0
		replace firm = 1 if strpos(fullname, "TECH") > 0
		replace firm = 1 if strpos(fullname, "FINANCE") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA")), " SA") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" NV")), " NV") > 0		
	}
	if "`cntry'" == "SPAIN" {
		// typical Spanish acronyms
		replace firm = 1 if strpos(fullname, "S. L.") > 0
		replace firm = 1 if strpos(fullname, "S.L") > 0
		replace firm = 1 if strpos(fullname, "S.A") > 0
		replace firm = 1 if strpos(fullname, "S. A") > 0
		replace firm = 1 if strpos(fullname, "S R L") > 0
		replace firm = 1 if strpos(fullname, "S. R. L") > 0
		replace firm = 1 if strpos(fullname, "S L P") > 0
		replace firm = 1 if strpos(fullname, "SOCIEDA") > 0
		replace firm = 1 if strpos(fullname, "SL. REPR.") > 0
		replace firm = 1 if strpos(fullname, "SL  REPR") > 0
		replace firm = 1 if strpos(fullname, "SL REPR") > 0
		replace firm = 1 if strpos(fullname, "SA REP") > 0
		replace firm = 1 if strpos(fullname, "S. A. REPR") > 0
		replace firm = 1 if strpos(fullname, "SLP REPR") > 0
		replace firm = 1 if strpos(fullname, "SRL REPR") > 0
		replace firm = 1 if strpos(fullname, "SRLP") > 0
		replace firm = 1 if strpos(fullname, "S.R.L.P") > 0
		// typical Spanish acronyms, but only checked in last letters
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA")), " SA") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" S A")), " S A") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SL")), " SL") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SLP")), " SLP") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" S L")), " S L") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" S. L.")), " S. L.") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SLL")), " SLL") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SRL")), " SRL") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA RE")), " SA RE") > 0
		// typical Spanish words
		replace firm = 1 if strpos(fullname, "ASOCIADO") > 0
		replace firm = 1 if strpos(fullname, "AGENCIA") > 0
		replace firm = 1 if strpos(fullname, "ADMINISTRA") > 0
		replace firm = 1 if strpos(fullname, "GESTIO") > 0
		replace firm = 1 if strpos(fullname, "GESTORA") > 0
		replace firm = 1 if strpos(fullname, "CAJA") > 0
		replace firm = 1 if strpos(fullname, "CAIXA") > 0
		replace firm = 1 if strpos(fullname, "Caja ") > 0
		replace firm = 1 if strpos(fullname, "ABOGADOS") > 0
		replace firm = 1 if strpos(fullname, "GRUPO") > 0
		replace firm = 1 if strpos(fullname, "INVERSION") > 0
		replace firm = 1 if strpos(fullname, "CONSULTOR") > 0
		replace firm = 1 if strpos(fullname, "COOPERATIVA") > 0
		replace firm = 1 if strpos(fullname, "CORPORACION") > 0
		replace firm = 1 if strpos(fullname, "SUCURSAL") > 0
		replace firm = 1 if strpos(fullname, "FEDERACION") > 0
		replace firm = 1 if strpos(fullname, "FUNDACIO") > 0
		replace firm = 1 if strpos(fullname, "SEGURIDAD SOCIAL") > 0
		replace firm = 1 if strpos(fullname, "UNIVERSIDAD") > 0
		replace firm = 1 if strpos(fullname, "UNION") > 0
		replace firm = 1 if strpos(fullname, "REPR") > 0 & strpos(fullname, "RRM") > 0
		// general words
		replace firm = 1 if strpos(fullname, "SPRL") > 0
		replace firm = 1 if strpos(fullname, "SARL") > 0
		replace firm = 1 if strpos(fullname, "MANAGEMENT") > 0
		replace firm = 1 if strpos(fullname, "CAPITAL") > 0
		replace firm = 1 if strpos(fullname, "CONSULTING") > 0
		replace firm = 1 if strpos(fullname, "HOLDING") > 0
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "B.V") > 0
		replace firm = 1 if strpos(fullname, "LIMITED") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "MARKETING") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" B V")), " B V") > 0
	}
	if "`cntry'" == "NORWAY" {
		replace firm = 1 if strpos(fullname, "ADVOKAT") > 0
		replace firm = 1 if strpos(fullname, "A/S") > 0
		replace firm = 1 if strpos(fullname, "B. V.") > 0
		replace firm = 1 if strpos(fullname, "Corp") > 0
		replace firm = 1 if strpos(fullname, "P/R") > 0
		replace firm = 1 if strpos(fullname, "Sp z oo") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "mbH") > 0
		replace firm = 1 if strpos(fullname, "& Co") > 0
		replace firm = 1 if strpos(fullname, "UNIVERSITET") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AS")), " AS") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA")), " SA") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" ASA")), " ASA") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" BV")), " BV") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AB")), " AB") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" INC")), " INC") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Inc")), " Inc") > 0
	}
	if "`cntry'" == "SWITZERLAND" {
		replace firm = 1 if strpos(fullname, "Departement") > 0
		replace firm = 1 if strpos(fullname, "Dipartimento") > 0
		replace firm = 1 if strpos(fullname, "fondation") > 0
		replace firm = 1 if strpos(fullname, "Kanton") > 0
		replace firm = 1 if strpos(fullname, "LIQUIDAZIONE") > 0
		replace firm = 1 if strpos(fullname, "Liquidazione") > 0
		replace firm = 1 if strpos(fullname, "LIQUIDATION") > 0
		replace firm = 1 if strpos(fullname, "Liquidation") > 0
		replace firm = 1 if strpos(fullname, "Office") > 0
		replace firm = 1 if strpos(fullname, "Service") > 0
		replace firm = 1 if strpos(fullname, "Stiftung") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AG")), " AG") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" ag")), " ag") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA")), " SA") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Sagl")), " Sagl") > 0
		
		replace firm = 1 if strpos(fullname, "B.V.") > 0
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "mbH") > 0
		replace firm = 1 if strpos(fullname, "gmbh") > 0
		replace firm = 1 if strpos(fullname, "HOLDING") > 0
		replace firm = 1 if strpos(fullname, "Holding") > 0
		replace firm = 1 if strpos(fullname, "INC.") > 0
		replace firm = 1 if strpos(fullname, "Inc.") > 0
		replace firm = 1 if strpos(fullname, "LIMITED") > 0
		replace firm = 1 if strpos(fullname, "Limited") > 0
		replace firm = 1 if strpos(fullname, "LLC") > 0
		replace firm = 1 if strpos(fullname, "LLP") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "S.A.") > 0
		replace firm = 1 if strpos(fullname, "S.P.A.") > 0
		replace firm = 1 if strpos(fullname, "S.R.A.") > 0
		replace firm = 1 if strpos(fullname, "SARL") > 0
		replace firm = 1 if strpos(fullname, "Sarl") > 0
		replace firm = 1 if strpos(fullname, "sarl") > 0
		replace firm = 1 if strpos(fullname, "PLC") > 0
	}
	if "`cntry'" == "FINLAND" {
		replace firm = 1 if strpos(fullname, " Oy ") > 0
		replace firm = 1 if strpos(fullname, "Oy/AB") > 0
		replace firm = 1 if strpos(fullname, "A/S") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Ab")), " Ab") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AB")), " AB") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Ky")), " Ky") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Oy")), " Oy") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" OY")), " OY") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" ry")), " ry") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Ry")), " Ry") > 0
		
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "Aktiebolag") > 0
		replace firm = 1 if strpos(fullname, "Limited") > 0
		replace firm = 1 if strpos(fullname, "Government") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" BV")), " BV") > 0
		
	}
	if "`cntry'" == "RUSSIA" {
		replace firm = 1 if strpos(fullname, "AKTSIONERNOE OBSHCHESTVO") > 0
		replace firm = 1 if strpos(fullname, "A/O") > 0
		replace firm = 1 if strpos(fullname, "BIZNES") > 0
		replace firm = 1 if strpos(fullname, "Collective") > 0
		replace firm = 1 if strpos(fullname, "GRUPP") > 0
		replace firm = 1 if strpos(fullname, "KAPITAL") > 0
		replace firm = 1 if strpos(fullname, "KOMPANIYA") > 0
		replace firm = 1 if strpos(fullname, "Kompaniya") > 0
		replace firm = 1 if strpos(fullname, "KONSALTING") > 0
		replace firm = 1 if strpos(fullname, "KORP.") > 0
		replace firm = 1 if strpos(fullname, "MENEDZHMENT") > 0
		replace firm = 1 if strpos(fullname, "OBSHCHESTVO S OGRANICHENNOI OTVETSTVENNOSTYU") > 0
		replace firm = 1 if strpos(fullname, "ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ") > 0
		replace firm = 1 if strpos(fullname, "Общество с ограниченной ответственностью") > 0
		replace firm = 1 if strpos(fullname, "OOO") > 0
		replace firm = 1 if strpos(fullname, "OAO") > 0
		replace firm = 1 if strpos(fullname, "КОМПАНИЯ") > 0
		replace firm = 1 if strpos(fullname, "ZAO") > 0
		
		replace firm = 1 if strpos(fullname, "A/S") > 0
		replace firm = 1 if strpos(fullname, "COMPANY") > 0
		replace firm = 1 if strpos(fullname, "Government") > 0
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "GROUP") > 0
		replace firm = 1 if strpos(fullname, "HOLDING") > 0
		replace firm = 1 if strpos(fullname, "Holding") > 0
		replace firm = 1 if strpos(fullname, "INVEST") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "Limited") > 0
		replace firm = 1 if strpos(fullname, "LIMITED") > 0
		replace firm = 1 if strpos(fullname, "LIABILITY") > 0
		replace firm = 1 if strpos(fullname, "LLC") > 0
		replace firm = 1 if strpos(fullname, "MANAGEMENT") > 0
		replace firm = 1 if strpos(fullname, "PARTNER") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" BV")), " BV") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Inc")), " Inc") > 0		
	}
	if "`cntry'" == "AUSTRIA" {
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "Gmbh") > 0
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "gmbh") > 0
		replace firm = 1 if strpos(fullname, "G.m.b.H.") > 0
		replace firm = 1 if strpos(fullname, "mbH") > 0
		replace firm = 1 if strpos(fullname, "m.b.H") > 0
		replace firm = 1 if strpos(fullname, "M.B.H") > 0
		replace firm = 1 if strpos(fullname, "gesellschaft") > 0
		replace firm = 1 if strpos(fullname, "Gesellschaft") > 0
		replace firm = 1 if strpos(fullname, "Genossenschaft") > 0
		replace firm = 1 if strpos(fullname, "genossenschaft") > 0
		replace firm = 1 if strpos(fullname, "Infrastruktur") > 0
		replace firm = 1 if strpos(fullname, "Maschine") > 0
		replace firm = 1 if strpos(fullname, "Tourism") > 0
		replace firm = 1 if strpos(fullname, "Verein") > 0 & strpos(fullname, "Förderung") > 0
		replace firm = 1 if strpos(fullname, "Verein") > 0 & strpos(fullname, "Foerderung") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AG")), " AG") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" KG")), " KG") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" OG")), " OG") > 0
		
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		replace firm = 1 if strpos(fullname, "Limited") > 0
		replace firm = 1 if strpos(fullname, "LIMITED") > 0
		replace firm = 1 if strpos(fullname, "MANAGEMENT") > 0
		replace firm = 1 if strpos(fullname, "Management") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" INC")), " INC") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Inc")), " Inc") > 0
	}
	if "`cntry'" == "SWEDEN" {
		replace firm = 1 if strpos(fullname, "A/B") > 0
		replace firm = 1 if strpos(fullname, " AB ") > 0
		replace firm = 1 if strpos(fullname, "A/S") > 0
		replace firm = 1 if strpos(fullname, "ApS") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AB")), " AB") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Ab")), " Ab") > 0
		replace firm = 1 if strpos(ustrleft(fullname, ustrlen("AB ")), "AB ") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AS")), " AS") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" BV")), " BV") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA")), " SA") > 0

		replace firm = 1 if strpos(fullname, "B.V.") > 0
		replace firm = 1 if strpos(fullname, "GmbH") > 0
		replace firm = 1 if strpos(fullname, "Government") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" Inc")), " Inc") > 0
	}
	if "`cntry'" == "ROMANIA" {
		replace firm = 1 if strpos(fullname, "ApS") > 0
		replace firm = 1 if strpos(fullname, "CABINET") > 0
		replace firm = 1 if strpos(fullname, "CAB.") > 0
		replace firm = 1 if strpos(fullname, "CAPITAL") > 0
		replace firm = 1 if strpos(fullname, "C.I.I") > 0
		replace firm = 1 if strpos(fullname, "IPURL") > 0
		replace firm = 1 if strpos(fullname, "I.P.U.R.L.") > 0
		replace firm = 1 if strpos(fullname, "PRESEDIN") > 0
		replace firm = 1 if strpos(fullname, "SPRL") > 0
		replace firm = 1 if strpos(fullname, "S.P.R.L") > 0
		replace firm = 1 if strpos(fullname, "S.R.L") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SRL")), " SRL") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" CII")), " CII") > 0
		replace firm = 1 if strpos(ustrleft(fullname, ustrlen("CII ")), "CII ") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" NV")), " NV") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" nv")), " nv") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA")), " SA") > 0
		
		replace firm = 1 if strpos(fullname, "B.V.") > 0
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "LIMITED") > 0
		replace firm = 1 if strpos(fullname, "N.V.") > 0
		replace firm = 1 if strpos(fullname, "S.A.") > 0
	}	
	if "`cntry'" == "DENMARK" {
		replace firm = 1 if strpos(fullname, "A/S") > 0
		replace firm = 1 if strpos(fullname, "ApS") > 0
		replace firm = 1 if strpos(fullname, "Aps") > 0
		replace firm = 1 if strpos(fullname, "I/S") > 0
		replace firm = 1 if strpos(fullname, "K/S") > 0
		replace firm = 1 if strpos(fullname, "P/F") > 0
		replace firm = 1 if strpos(fullname, "P/R") > 0
		replace firm = 1 if strpos(fullname, "SpA") > 0
		replace firm = 1 if strpos(fullname, "Sp/f") > 0

		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AB")), " AB") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" AS")), " AS") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" KG")), " KG") > 0
		
		replace firm = 1 if strpos(fullname, "B.V.") > 0
		replace firm = 1 if strpos(fullname, "GMBH") > 0
		replace firm = 1 if strpos(fullname, "Government") > 0
		replace firm = 1 if strpos(fullname, "mbH") > 0
		replace firm = 1 if strpos(fullname, "LLC") > 0
		replace firm = 1 if strpos(fullname, "LTD") > 0
		replace firm = 1 if strpos(fullname, "Ltd") > 0
		
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" BV")), " BV") > 0
		replace firm = 1 if strpos(ustrright(fullname, ustrlen(" SA")), " SA") > 0
	}
	
	replace senmen=0 if firm==1
	replace supboard=0 if firm==1
// 	replace audit=0 if firm==1
	replace boards=0 if firm==1
//	replace topmanager=0 if firm==1
// 	replace nofunction=1 if firm==1
	
	// number of words in fullname
	capture drop no_name
	gen no_name = wordcount(prepared_name)
	
	// prepare first name (kept in variable name1) and last name (lastname)
	capture drop name1
	capture drop namelast
	gen namelast = word(prepared_name, no_name)
	gen name1 = word(prepared_name, 1)
	
	// in some countries the order of names and surnames is reversed but we can manually extract some of them:
	// Romania
	if "`cntry'" == "ROMANIA" {
		replace name1 = word(prepared_name, no_name) if (no_name > 1 & no_name < 5 & source < 2008 )
		replace name1 = word(prepared_name, no_name) if (no_name == 2 & source == 2008)
		replace name1 = word(prepared_name, no_name - 1) if (no_name == 3 & source == 2008)
		replace name1 = word(prepared_name, no_name) if (no_name == 3 & strlen(word(prepared_name, 2)) < 3 & source == 2008)
		replace name1 = word(prepared_name, no_name - 1) if (no_name == 4 & source == 2008)
		replace name1 = word(prepared_name, no_name) if (no_name == 2 & source == 2010)
		replace name1 = word(prepared_name, no_name - 1) if (no_name == 3 & source == 2010)
		replace name1 = word(prepared_name, no_name) if (no_name == 3 & strlen(word(prepared_name, 2)) < 3 & source == 2010)
		replace name1 = word(prepared_name, no_name - 1) if (no_name == 4 & source == 2010)
		replace name1 = word(prepared_name, no_name) if (no_name == 4 & strlen(word(prepared_name, 3)) < 3 & source == 2010)
	}
	
	// Serbia -- ?? sth to correct
	if "`cntry'" == "SERBIA" {
		replace name1 = word(prepared_name, no_name) if source == 2006 
		replace namelast = word(namelast, no_name) if source == 2006
		replace name1 = word(prepared_name, no_name) if source == 2008
		replace namelast = word(prepared_name, 1) if source == 2008
	}
	
	// Spain
	if "`cntry'" == "SPAIN" {
		replace name1 = word(prepared_name, no_name) if (no_name == 2 & source < 2008)
		replace name1 = word(prepared_name, no_name) if (no_name == 3 & source < 2008)
		replace name1 = word(prepared_name, no_name - 1) if (no_name == 4 & strpos(prepared_name, "DEL") == 0 & source < 2008)
		replace name1 = word(prepared_name, no_name) if (no_name == 4 & source < 2008)
		//
		replace name1 = word(prepared_name, no_name) if (no_name == 2 & source == 2008)
		replace name1 = word(prepared_name, no_name) if (no_name == 3 & source == 2008)
		replace name1 = word(prepared_name, no_name - 1) if (no_name == 4 & source == 2008)
		replace name1 = word(prepared_name, no_name) if (no_name == 4 & strpos(prepared_name, "DE ") > 0 & source == 2008)
		replace name1 = word(prepared_name, no_name) if (no_name == 4 & strpos(prepared_name, "DEL ") > 0 & source == 2008)
		replace name1 = word(prepared_name, no_name - 1 ) if (no_name == 5 & source == 2008)
		replace name1 = word(prepared_name, no_name) if (no_name == 5 & strpos(prepared_name, "DE ") > 0 & strpos(prepared_name, "DE LA") == 0 & strpos(prepared_name, "DE LOS") == 0 & source == 2008)
		replace name1 = word(prepared_name, no_name - 1) if (no_name == 5 & strpos(prepared_name, "DEL ") > 0 & source == 2008)
		replace name1 = word(prepared_name, no_name) if (no_name == 5 & (strpos(prepared_name, "DE LA") > 0 | strpos(prepared_name, "DE LA") >0))  & source == 2008
	}
	
	// Italy
	if "`cntry'" == "ITALY" {
		replace name1 = word(prepared_name, no_name) if (source == 2003 | source == 2002)
	}
	
	//------ gender_rule----------------------------------------------------//
	capture drop gender_rule
	capture drop lastchar
	capture gen gender_rule = .

		// type 1 ----------------------------------------------------------//
		// heuristics for BOSNIA POLAND SLOVENIA - operate on names
		if ("`cntry'" == "BOSNIA" | "`cntry'" == "POLAND" | "`cntry'" == "SLOVENIA") {
			gen lastchar = "."
			replace lastchar = substr(name1, strlen(name1), 1)
			replace gender_rule = 0 if (name1 != "")
			replace gender_rule = 1 if (lastchar == "A")
			drop lastchar
		}
		
		// type 2 ----------------------------------------------------------//
		// heuristics for BELARUS BULGARIA CZECH HUNGARY ICELAND LATVIA LITHUANIA MACEDONIA SLOVAKIA RUSSIA UKRAINE
		// Czech - female
		if ("`cntry'" == "CZECH" | "`cntry'" == "SLOVAKIA") {
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("OVA")), "OVA") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("OVÁ")), "OVÁ") > 0
			//replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("NA")), "NA") > 0
		}
		
		if ("`cntry'" == "ICELAND") {
			// Iceland-female
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("DóTTIR")), "DóTTIR") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("DÓTTIR")), "DÓTTIR") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("DOTTIR")), "DóTTIR") > 0
			// Iceland-male
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("SSON")), "SSON") > 0
		}
		
		if ("`cntry'" == "LITHUANIA") {
			// Lithuania-female
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("IENE")), "IENE") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("AITE")), "AITE") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("UTE")), "UTE") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("YTE")), "YTE") > 0
			// Lithuania-male
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("AS")), "AS") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("YS")), "YS") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("IS")), "IS") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("US")), "US") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("IJ")), "IJ") > 0
		}
		
		if ("`cntry'" == "MACEDONIA") {		
			// Macedonia-female
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("SKA")), "SKA") > 0
			// Macedonia-male
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("SKI")), "SKI") > 0
		}
		
		// Russia, Bulgaria, Serbia, Ukraine
		if ("`cntry'" == "RUSSIA" | "`cntry'" == "BULGARIA" | "`cntry'" == "SERBIA") {
			// -OV -ОВ
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("OV")), "OV") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("ОВ")), "ОВ") > 0
			// -ев -ev
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("EV")), "EV") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("ЕВ")), "ЕВ") > 0
			// -ёв -yov 
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("YOV")), "YOV") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("ЁВ")), "ЁВ") > 0
			// -ОВА -OVA
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("OVA")), "OVA") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("ОВА")), "ОВА") > 0
			// -ЕВА -EVA
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("EVA")), "EVA") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("ЕВА")), "ЕВА") > 0
			// -YOVA -ЁВА
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("YOVA")), "YOVA") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("ЁВА")), "ЁВА") > 0
			// -ИН -IN
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("IN")), "IN") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("ИН")), "ИН") > 0
			// -ИНА -INA
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("INA")), "INA") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("ИНА")), "ИНА") > 0
		}
	
		//-sky (-ska)
		if ("`cntry'" == "UKRAINE" | "`cntry'" == "RUSSIA" | "`cntry'" == "BULGARIA" | "`cntry'" == "SERBIA") {
			// -ski -sky -ska 
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("SKY")), "SKY") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("SKA")), "SKA") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("SKI")), "SKI") > 0
			// -skiy -skaya
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("SKIY")), "SKIY") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("SKAYA")), "SKAYA") > 0
		}

		if ("`cntry'" == "UKRAINE" | "`cntry'" == "RUSSIA" | "`cntry'" == "BELARUS") {
			// ovich evich
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("OVICH")), "OVICH") > 0
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("EVICH")), "EVICH") > 0
			// OVNA EVNA INVA
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("OVNA")), "OVNA") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("IVNA")), "IVNA") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("EVNA")), "EVNA") > 0
		}
		
		// Hungary 
		/*
		replace gender_rule = 0 if strpos(ustrright(fullnamelast, ustrlen("O")), "O") > 0 & country== "HUNGARY"
		replace gender_rule = 1 if strpos(ustrright(fullnamelast, ustrlen("É")), "É") > 0 & country== "HUNGARY"
		replace gender_rule = 1 if strpos(ustrright(fullnamelast, ustrlen("A")), "A") > 0 & country== "HUNGARY"
		replace gender_rule = 1 if strpos(ustrright(fullnamelast, ustrlen("Ó")), "Ó") > 0 & country== "HUNGARY" */

		// Latvia
		if "`cntry'" == "LATVIA" {
			replace gender_rule = 0 if strpos(ustrright(namelast, ustrlen("S")), "S") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("A")), "A") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("E")), "E") > 0
		}
		
		// Spain
		if "`cntry'" == "SPAIN" {
			replace gender_rule = 1 if strpos(prepared_name, "MARIA DEL ") > 0
			replace gender_rule = 1 if strpos(prepared_name, "MARIA DE ") > 0
			replace gender_rule = 1 if strpos(prepared_name, "JUAN DE DIOS") > 0
		}
		
		// Hungary
		if "`cntry'" == "HUNGARY" {
			replace gender_rule = 0 if strpos(prepared_name, "BÉLA") > 0
			replace gender_rule = 1 if strpos(ustrright(namelast, ustrlen("NÉ")), "NÉ") > 0
		}
		
	replace gender_rule = -2 if gender_rule == .
	
	//------ gender_rus ----------------------------------------------------//
	// assign gender to names written with cyryllic letters
	capture drop gender_rus
	ren name1 name
	merge n:1 name using "$wgnd_path\russian_names.dta"
	ren gender gender_rus
	drop if _merge == 2
	drop _merge
	ren name name1
	replace gender_rus = -2 if gender_rus == .
	
	//------ gender_country ------------------------------------------------//
	
	// clean diacrytics
	// unicode string fuction frquently eliminate some of the diacrytic signs, what unables the identification of names
	{
	replace name1 = subinstr(name1, "À", "A", .)
	replace name1 = subinstr(name1, "Á", "A", .)
	replace name1 = subinstr(name1, "Â", "A", .)
	replace name1 = subinstr(name1, "Ã", "A", .)
	replace name1 = subinstr(name1, "Ä", "A", .)
	replace name1 = subinstr(name1, "Å", "A", .)
	replace name1 = subinstr(name1, "Æ", "AE", .) //
	replace name1 = subinstr(name1, "Ç", "C", .)
	replace name1 = subinstr(name1, "È", "E", .)
	replace name1 = subinstr(name1, "É", "E", .)
	replace name1 = subinstr(name1, "Ê", "E", .)
	replace name1 = subinstr(name1, "Ë", "E", .)
	replace name1 = subinstr(name1, "Ì", "I", .)
	replace name1 = subinstr(name1, "Í", "I", .)
	replace name1 = subinstr(name1, "Î", "I", .)
	replace name1 = subinstr(name1, "Ï", "I", .)
	//replace name1 = subinstr(name1, "Ð", "ETH", .) //
	replace name1 = subinstr(name1, "Ñ", "N", .)
	replace name1 = subinstr(name1, "Ò", "O", .)
	replace name1 = subinstr(name1, "Ó", "O", .)
	replace name1 = subinstr(name1, "Ô", "O", .)
	replace name1 = subinstr(name1, "Õ", "O", .)
	replace name1 = subinstr(name1, "Ö", "O", .)
	replace name1 = subinstr(name1, "Ø", "O", .)
	replace name1 = subinstr(name1, "Ù", "U", .)
	replace name1 = subinstr(name1, "Ú", "U", .)
	replace name1 = subinstr(name1, "Û", "U", .)
	replace name1 = subinstr(name1, "Ü", "U", .)
	replace name1 = subinstr(name1, "Ý", "Y", .)
	//replace name1 = subinstr(name1, "Þ", "THORN", .) //
	replace name1 = subinstr(name1, "Ā", "A", .)
	replace name1 = subinstr(name1, "Ă", "A", .)
	replace name1 = subinstr(name1, "Ą", "A", .)
	replace name1 = subinstr(name1, "Ć", "C", .)
	replace name1 = subinstr(name1, "Ĉ", "C", .)
	replace name1 = subinstr(name1, "Ċ", "C", .)
	replace name1 = subinstr(name1, "Č", "C", .)
	replace name1 = subinstr(name1, "Ď", "D", .)
	replace name1 = subinstr(name1, "Đ", "D", .)
	replace name1 = subinstr(name1, "Ē", "E", .)
	replace name1 = subinstr(name1, "Ė", "E", .)
	replace name1 = subinstr(name1, "Ę", "E", .)
	replace name1 = subinstr(name1, "Ě", "E", .)
	replace name1 = subinstr(name1, "Ğ", "G", .)
	replace name1 = subinstr(name1, "Ģ", "G", .)
	replace name1 = subinstr(name1, "Ī", "I", .)
	replace name1 = subinstr(name1, "İ", "I", .)
	replace name1 = subinstr(name1, "Ķ", "K", .)
	replace name1 = subinstr(name1, "Ĺ", "L", .)
	replace name1 = subinstr(name1, "Ļ", "L", .)
	replace name1 = subinstr(name1, "Ľ", "L", .)
	replace name1 = subinstr(name1, "Ń", "N", .)
	replace name1 = subinstr(name1, "Ņ", "N", .)
	replace name1 = subinstr(name1, "Ň", "N", .)
	replace name1 = subinstr(name1, "Ō", "O", .)
	replace name1 = subinstr(name1, "Ő", "O", .)
	replace name1 = subinstr(name1, "Œ", "OE", .) //
	replace name1 = subinstr(name1, "Ŕ", "R", .)
	replace name1 = subinstr(name1, "Ř", "R", .)
	replace name1 = subinstr(name1, "Ś", "S", .)
	replace name1 = subinstr(name1, "Ş", "S", .)
	replace name1 = subinstr(name1, "Š", "S", .)
	replace name1 = subinstr(name1, "Ţ", "T", .)
	replace name1 = subinstr(name1, "Ť", "T", .)
	replace name1 = subinstr(name1, "Ũ", "U", .)
	replace name1 = subinstr(name1, "Ū", "U", .)
	replace name1 = subinstr(name1, "Ů", "U", .)
	replace name1 = subinstr(name1, "Ű", "U", .)
	replace name1 = subinstr(name1, "Ÿ", "Y", .)
	replace name1 = subinstr(name1, "Ź", "Z", .)
	replace name1 = subinstr(name1, "Ż", "Z", .)
	replace name1 = subinstr(name1, "Ž", "Z", .)
	replace name1 = subinstr(name1, "Ǣ", "AE", .) //
	replace name1 = subinstr(name1, "Ȅ", "E", .)
	replace name1 = subinstr(name1, "Ȍ", "O", .)
	replace name1 = subinstr(name1, "Ș", "S", .)
	replace name1 = subinstr(name1, "Ț", "T", .)
	}
	
	// merge by country and names
	capture drop gender_country
	ren name1 name
	merge n:1 country name using "$wgnd_path\countrynamesetfinal.dta"
	ren gender gender_country
	drop if _merge == 2
	drop _merge
	ren name name1
	replace gender_country = -2 if gender_country == .
	
	// merge by names
	capture drop gender_no
	ren name1 name
	merge n:1 name using "$wgnd_path\nocountrynamesetfinal.dta"
	ren gender gender_no
	drop if _merge == 2
	drop _merge
	ren name name1
	replace gender_no = -2 if gender_no == .
	
	//------ gender - aggregate information --------------------------------//
	// define label for later use
	capture label drop genderlab
	capture label define genderlab -2 missing -1 conflict 0 male 1 female 2 ambiguous

	capture drop gender
	gen gender = .
	
	// apply results from rules
	replace gender = gender_rule
	
	// apply results from cyryllic sets
	replace gender = gender_rus if gender == -2

	// apply results from countries
	replace gender = -2 if gender_country == -2 & gender == -2
	replace gender =  0 if gender_country == 0 & gender == -2
	replace gender =  1 if gender_country == 1 & gender == -2
	replace gender =  2 if gender_country == 2 & gender == -2
	
	// apply results without countries
	replace gender =  0 if gender_no ==  0 & gender ==  0
	replace gender =  0 if gender_no ==  0 & gender == -2
	
	replace gender =  1 if gender_no ==  1 & gender ==  1
	replace gender =  1 if gender_no ==  1 & gender == -2
	
	replace gender =  2 if gender_no ==  2 & gender ==  2
	replace gender =  2 if gender_no == -2 & gender ==  2
	replace gender =  2 if gender_no ==  2 & gender == -2

	replace gender = -1 if gender_no ==  1 & gender ==  0
	replace gender = -1 if gender_no ==  0 & gender ==  1
	replace gender = -1 if gender_no ==  2 & gender ==  1
	replace gender = -1 if gender_no ==  2 & gender ==  0
	
	replace gender = -2 if gender_no == -2 & gender == -2
	
	// additional corrections
	if ("`cntry'" == "BELGIUM" | "`cntry'" == "FRANCE" | "`cntry'" == "SWITZERLAND") {
		replace gender = 1 if name1 == "MICHELE"
		replace gender = 1 if name1 == "MICHELLE"
		replace gender = 1 if name1 == "ANDREE"
		replace gender = 0 if name1 == "JEAN"
		replace gender = 0 if name1 == "YVES"
		replace gender = 0 if name1 == "MICHEL"	
		replace gender = 0 if name1 == "REMY"
		replace gender = 0 if name1 == "VINCENT"
		replace gender = 0 if name1 == "FRANCIS"
		replace gender = 0 if name1 == "EMMANUEL"
		replace gender = 0 if name1 == "CHRISTIAN"
	}
	
	if ("`cntry'" == "SPAIN") {
		replace gender = 0 if name1 == "JOSE"
		replace gender = 0 if name1 == "JUAN"
		replace gender = 0 if name1 == "FERRAN"
		replace gender = 0 if name1 == "ANGEL"
	}
	
	if "`cntry'" == "PORTUGAL" {
		replace gender = 0 if name1 == "JOSE"
		replace gender = 0 if name1 == "RUI"
	}
	
	// when we have missing, conflict or ambiguous case we can use salutation to recognize gender
	capture drop gender_salutation
	gen gender_salutation = .
	
	replace gender_salutation = 0 if strpos(ustrleft(salutation, ustrlen("Mr")), "Mr") > 0 & strpos(salutation, "Mrs") == 0
	replace gender_salutation = 0 if strpos(ustrleft(salutation, ustrlen("Herr")), "Herr") > 0
	replace gender_salutation = 0 if strpos(ustrleft(salutation, ustrlen("Mr.")), "Mr.") > 0
	replace gender_salutation = 0 if strpos(ustrleft(salutation, ustrlen("Monsieur")), "Monsieur") > 0
	replace gender_salutation = 0 if strpos(ustrleft(salutation, ustrlen("Senor")), "Senor") > 0
	
	replace gender_salutation = 1 if strpos(ustrleft(salutation, ustrlen("Frau")), "Frau") > 0
	replace gender_salutation = 1 if strpos(ustrleft(salutation, ustrlen("Ms")), "Ms") > 0
	replace gender_salutation = 1 if strpos(ustrleft(salutation, ustrlen("Mrs")), "Mrs") > 0
	replace gender_salutation = 1 if strpos(ustrleft(salutation, ustrlen("Miss")), "Miss") > 0
	replace gender_salutation = 1 if strpos(ustrleft(salutation, ustrlen("Madame")), "Madame") > 0
	replace gender_salutation = 1 if strpos(ustrleft(salutation, ustrlen("Mme")), "Mme") > 0
	
	gen gender_wo_salutation = gender
	replace gender = gender_salutation if (gender == -2 | gender == -1 | gender == 2) & gender_salutation != .
	
	// assign label
	label values gender genderlab
	
	// save dataset
	keep $vars_to_save
	save "$gender_path\managers_gender_`cntry'.dta" , replace
	clear
}