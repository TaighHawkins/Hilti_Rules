%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_rules, `10 June 2015` ).

%i_pdf_parameter( tab, 16 ).
%i_pdf_parameter( direct_object_mapping, 0 ).

i_pdf_parameter( max_pages, 1 )
:- 
	i_mail( subject, Sub ),
	trace( subject( Sub ) ),
	string_to_lower( Sub, SubL ),
	( q_sys_sub_string( SubL, _, _, `macon` )
		;	q_sys_sub_string( SubL, _, _, `gb iof` )
	),
	trace( `Sub completed` )
	
	;	i_mail( from, From ),
		trace( from( From ) ),
		string_to_lower( From, FromL ),
		q_sys_sub_string( FromL, _, _, `@maconsupply.net` ),
		trace( `From completed` )
.
i_pdf_parameter( max_pages, 50).

i_page_split_rule_list( [ set(chain,`unrecognised`), select_buyer] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENCRYPTION CATCH - Only DK ATEA fails for this as of 24/11/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_no_lines_rule( encryption_error, Error_atom_in, Description_in, Error_atom_in, Description_in )
:- q_sys_sub_string( Description_in, _, _, `Unsupported encryption` ).
%=======================================================================
i_rule( encryption_error, [set( chain, `zhilti encryption error chain` ), trace( [ `UNSUPPORTED ENCRYPTION ERROR` ] ), set( re_extract ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER RULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( select_buyer, [ 
%=======================================================================

	or( [ i_mail_check_rule
	
%		, junk_hoerlemann_attachments
	
		, first_line_identifications_rule
	
		, body_identification
	
		, [ q0n(line), check_text_identification_line ]
		
		, [ q0n(line), buyer_id_line ] 
	
	] ) 
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IDENTIFICATION ON THE FIRST (two) LINES OF THE DOCUMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( first_line_identifications_rule, [ 
%=======================================================================

	q01(line)
	
	, or( [ bae_systems_line
	
		, it_tea_co_rule
		
		, it_ceu_rule
		
		, it_fpt_rule
		
		, it_tecnelit_line

		, briggs_and_forrester_rule
		
		, gb_already_hire_rule
		
		, from_domain_rule
		
		, de_popp_lauser_rule
		
		, ch_debrunner_rule
		
		, crown_house_alternate_id_rule
		
		, at_fill_gesellschaft_rule
		
		, linde_gas_rule
		
		, de_linde_rule
		
		, fr_siapoc_rule
		
		, us_big_d_rule
		
		, it_standard_tech_rule
		
	] ) 
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% JUNK HOERLEMANN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( junk_hoerlemann_attachments, [ 
%=======================================================================

	or( [ check( q_sys_sub_string( AttachL, _, _, `pdf` ) )
		, check( q_sys_sub_string( AttachL, _, _, `csv` ) )
	] )

	, or( [ generic_line( [ check_text( `AnsprechpartnerNachnameAnsprechpartnerVornameAnsprechpartnerTelefon` ) ] )
		
		, [ q(0,50,line), generic_line( [ check_text( `HorlemannElektrobauGmbH` ) ] ) ]
	] )
	
	, trace( [ `Trashing Hoerlemann attachments` ] )
	, set( chain, `junk` )

] ):- i_mail( attachment, Attach ), string_to_lower( Attach, AttachL ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FROM DOMAIN IDENTIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( i_mail_check_rule, [ 
%=======================================================================

	or( [ 
		[ check( q_sys_sub_string( Sub_L, _, _, `vallectric` ) ), set( chain, `vallectric hilti` ), trace( [ `VALLECTRIC ...` ] ), set( re_extract ) ]
		
		, [ check( q_sys_sub_string( From_L, _, _, `@smithshire.com` ) ), set(chain, `gb smiths equipment hire`), trace([`SMITHS EQUIPMENT HIRE ...`] ) ]
	
		, [ check( Sub_L = `ducos` ), set(chain, `fr ducos`), trace([`DUCOS ...`] ) ]
		
		, [ check( q_sys_sub_string( From_L, _, _, `@sedq.nc` ) ), set( chain, `fr ducos` ), trace( [ `DUCOS ...` ] ) ]
		
		, [ check( q_sys_sub_string( Sub_L, _, _, `gb iof` ) ), set(chain, `intelligent order form (hilti)`)
			, trace([` [FROM I_MAIL] INTELLIGENT ORDER FORM (HILTI) ...`]), set( re_extract ) 
		]
		
	] )
	
] )
:-
	i_mail( subject, Sub ),
	string_to_lower( Sub, Sub_L ),
	i_mail( from, From ),
	string_to_lower( From, From_L )
.

%=======================================================================
i_rule( body_identification, [ 
%=======================================================================

	check( q_sys_sub_string( Attachment_L, _, _, `body.` ) )
	, q0n( line )
	
	, generic_line( [ `Kontaktperson` ] )
	, generic_line( [ [ `Annan`, `mottagare` ] ] )
	, or( [ generic_line( [ [ `Mottagare` ] ] )
	
		, generic_line( [ check_text( `/littra` ) ] )
		
		, generic_line( [ check_text( `Märkning` ) ] )
		
	] )
	
	, set( chain, `se littra customer` )
	, trace( [ `SE LITTRA CUSTOMER ...` ] )
	
] ):- i_mail( attachment, Attachment ), string_to_lower( Attachment, Attachment_L ).

%=======================================================================
i_line_rule( bae_systems_line, [ check_text( `partclassificationaca` ), set( chain, `bae systems` ), trace( [ `BAE SYSTEMS...` ] ) ] ).
%=======================================================================
i_line_rule( buyer_id_line, [ q0n(anything), or( [	%	Defense in chain - hidden from main rule
%=======================================================================

		  [ `chep`, set(chain, `GB-CHEP`), trace([`CHEP ...`]) ]

		, [ `afl`,set(chain, `US-AFL`), trace([`AFL ...`])  ]

		, [ `doclink`, `.`, set(chain, `tradex`), trace([`TRADEX ...`])  ]

		, [ `ONI`, `-`, `Wärmetrafo`, `GmbH`, set(chain, `oni`), trace([`ONI...`]) ]

		, [ `Code`, `TCI`, tab, `Description`, tab, set(chain, `translec`), trace([`TRANSLEC...`]) ]

		, [ `articles`, `STM`, `,`, `doit`, `être`, `joint`, set(chain, `stm`), trace([`STM...`]) ]
		
		, [`CE`, `NUMÉRO`, `DOIT`, `PARAÎTRE`, `SUR`,  newline, set(chain, `stm`), trace([`STM...`])  ]

		, [ `@`, `fabbrovanni`, `.`, `com`,  newline, set(chain, `fabbro vanni`), trace([`FABBRO VANNI...`]) ]

		, [ `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `RECHNUNGSFAKTURA`, `AN`, `EXPERT`, `-`, `LANGENHAGEN`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`,  newline, set(chain, `heldele`), trace([`HELDELE...`]) ]

		, [ `MODULBLOK`, `SPA`, tab, `N`, `:`, `movimento`, set(chain, `modulblok`), trace([`MODULBLOK...`]) ]

		, [ `Gebr`, `.`, `Knuf`,  newline, set(chain, `knuf`), trace([`KNUFF...`])  ]

		, [ `@`, `roche`, `.`, `com`,  newline, set(chain, `la roche`), trace([`LA ROCHE...`])  ]

		, [ `Köb`, `Holzheizsysteme`, `GmbH`, set(chain, `koeb`), trace([`KOEB...`])  ]

		, [ `voelkl`, `.`, `co`, `.`, `at`, newline, set(chain, `voelkl`), trace([`VOELKL...`])  ]

		, [ or([ [`Heidenbauer`, `Industriebau`, `GmbH`], [`Metallbau`, `Heidenbauer`, `GmbH`, `&`, `Co`, `KG`] ]), newline, set(chain, `heidenbauer`), trace([`HEIDENBAUER...`])  ]

		, [ `SchwörerHaus`, `KG`, `·`, `Hans`, set(chain, `schworer`), trace([`SCHWORER...`])  ]

		, [ `claas`, set(chain, `claas`), trace([`CLAAS...`])  ]

		, [ `Références`, `à`, `rappeler`, `sur`, `toute`, `correspondance`, q10( `:` ),  newline, set(chain, `distrimo`), trace([`DISTRIMO...`])  ]

		, [ `ATTENZIONE`, `:`, `NON`, `SI`, `ACCETTANO`, `FORNITURE`, `O`, `PRESTAZIONI`, `SENZA`, `ORDINE`, `SCRITTO`, `.`, tab, `CONSEGNA`, tab, `FRANCO`, tab, `MEZZO`,  newline, set(chain, `ed impianti`), trace([`ED IMPIANTI...`])  ]

		, [ `otis`, set(chain, `otis`), trace([`OTIS...`])  ]

		, [ `gb`, `-`, `horbury`, set(chain, `horbury`), trace([`HORBURY...`])  ]

		, [ `(`, `01604`, `)`, `752424`, set(chain, `travis perkins (hilti)`), trace([`TRAVIS PERKINS (HILTI)`]), set( re_extract ) ]

		, [ or( [ [ `IT`, `00120730213` ], [ `IT00120730213` ] ] ), set(chain, `elpo`), trace([`ELPO...`]) ]
		
		, [ `INDICARE`, `IN`, `BOLLA`, `IL`, `NUMERO`, `DELL`, `'`, `ORDINE`, set(chain, `drusian`), trace([`DRUSIAN...`]) ]

		, [ `709`, `-`, `748`, `-`, `7502`, set(chain, `kbac`), trace([`KBAC...`]) ]

		, [ `Skanska`, `USA`, `Civil`, `Northeast`,  newline, set(chain, `skanska`), trace([`SKANSKA...`]) ]

		, [ `Pos`, tab, `Item`, `number`, tab, `Item`, `name`, tab, `Quantity`, tab, `U`, `/`, `M`, set(chain, `elekta`), trace([`ELEKTA...`]) ]

		, [ `info`, `@`, `breburltd`, `.`, `co`, `.`, `uk`, set(chain, `brebur`), trace([`BREBUR...`]) ]

		, [  `Item`, `Description`, tab, `Catalogue`, `No`, tab, `Order`, `Qty`, tab, set(chain, `he simm po`), trace([`HE SIMM PO...`]) ] 
		
		, [ `label`, `line`, `1`, q10(tab), `HSS`, `Ecode`, q10( tab ), `Font`, `Size`, set( chain, `hss connectivity extended` ), set( re_extract ), trace( [ `HSS CONNECTIVITY EXTENDED...` ] ) ]
		, [ `HSS`, `Ecode`, q10( tab ), `Font`, `Size`, set( chain, `hss connectivity hilti` ), trace( [ `HSS CONNECTIVITY ...` ] ) ]

		, [ check_text( `226555264` ), set(chain, `gb clancy docwra`), trace([`CLANCY DOCWRA...`])  ]
		
		, [ check_text( `PosStkEinheitArtikelBezeichnungPreisGesamtPreisR%` ), set(chain, `at kaltepol` ), trace([`KALTEPOL ...`]) ]
		
		, [ `Account`, tab, `20767630`,  newline, set( chain, `us-telect` ), trace( [ `US Telect - HILTI ...` ] ) ]
	
] ) ] ).	%	Because chain rule, nothing should ever go after OR - combined with end bracket.

%=======================================================================
i_line_rule( check_text_identification_line, [ or( [ %	Defense in chain - hidden from main rule
%=======================================================================
		[ check_text( `R_E1_DK_MOGB_RAIL` ), set(chain, `hilti sales update`), trace([`SALES UPDATE ...`]) ]

		,  [ check_text( i_speedy_check ), set(chain, `GB-SPEEDY`), trace([`SPEEDY ...`]) ]

		, [ check_text( `networkrail` ), set(chain, `GB-NWKRAIL`), trace([`NETWORK RAIL ...`]) ]

		, [ check_text( `harscoinfrastructure` ), set(chain, `GB-HARSCO`), trace([`HARSCO ...`]) ]

		, [ check_text( `controlmatic` ),set(chain, `DE-VINCI`), trace([`VINCI ...`]) ]
	%	, [ check_text( `ekorg` ),set(chain, `DE-VINCI`), trace([`VINCI ...`]) ]

		, [ check_text( `e-mailinfo@pederzaniitwebwwwpederzaniit` ),set(chain, `pederzani`), trace([`PEDERZANI ...`]) ]

		, [ check_text( `ameonlimited` ), set(chain, `ameon`), trace([`AMEON ...`]) ]

		, [ check_text( `brandonhire` ), set(chain, `gb-brandon`), trace([`BRANDON HIRE ...`]) ]

		, [ check_text( `stahlbaupichler` ), set(chain, `stahlbau pichler`), trace([`STALBAU PICHER ...`]) ]

		, [ check_text( `Bellotto` ), set(chain, `bellotto`), trace([`BELLOTTO...`]) ]
		, [ check_text( `Impiantigeneral` ), set(chain, `bellotto`), trace([`BELLOTTO...`]) ]

		, [ check_text( `Frigoveneta` ), set(chain, `frigoveneta`), trace([`FRIGOVENETA...`]) ]

		, [ check_text( `ospelt` ), set(chain, `ospelt`), trace([`OSPELT...`]) ]

		, [ check_text( `cplconcordia` ), set(chain, `cpl concordia`), trace([`CPL CONCORDIA...`]) ]

		, [ or( [ check_text( `umdaschshopfitting` ), check_text( `umdasch-shopfitting` ) ] )		
			, set(chain, `at umdasch shopfitting`), trace([`UMDASCH SHOPFITTING ...`]) 
		]

		, [ check_text( `umdasch` ), set(chain, `umdasch`), trace([`UMDASCH GROUP...`]) ]

		, [ check_text( `alusommer` ), set(chain, `alusommer`), trace([`ALUSOMMER...`]) ]

		, [ check_text( `BABAKGEBÄUDETECHNIK` ), set(chain, `babak`), trace([`BABAK...`]) ]
		, [ check_text( `Bestell-uOrdernummerimmeranfhren!` ), set(chain, `babak`), trace([`BABAK...`]) ]

		, [ check_text( `ATZWANGERAGSPA` ), set(chain, `atzwanger`), trace([`ATZWANGER...`]) ]

		, [ check_text( `SCHMIDHAMMERSRL` ), set(chain, `schmidhammer`), trace([`SCHMIDHAMMER...`]) ]

		, [ check_text( `EINKAUFSBEDINGUNGENBABAK` ), set(chain, `hilti ignore`), trace([`BABAK T&C ...`]) ]

		, [ check_text( `mortenson` ), set(chain, `mortenson`), trace([`MORTENSON...`]) ]

		, [ or( [ check_text( `mascopurchasing` )

				, check_text( `masco` )
				
				, check_text( `suppliernopaymenttermsfreighttermsfobsuppliercontactinformation` )
				
			] )
				
			, set(chain, `masco`), trace([`MASCO...`]) 
			
		]

		, [ check_text( `Itemshighlightedgreywillbedispatched` ), set(chain, `interserve call off`), trace([`INTERSERVE CALL OFF...`]) ]
		, [ check_text( `VATNo-527218256` ), set(chain, `interserve`), trace([`INTERSERVE...`]) ]
		, [ check_text( `VATNo-527218256` ), set(chain, `interserve`), trace([`INTERSERVE...`]) ]
		, [ check_text( `Areasshadedredaremandatoryandareasshadedgreyareoptional` ), set(chain, `interserve firm order`), trace([`INTERSERVE FIRM ORDER...`]) ]

%		, [ check_text( `Ns BancaIBANVsBancaIBAN` ), set(chain, `termigas`), trace([`TERMIGAS ...`]) ]
		, [ check_text( `posarticolodescrizione`), set(chain, `termigas`), trace([`TERMIGAS ...`]) ]

		, [ check_text( `BaconGebudetechnikGmbH` ), set(chain, `bacon`), trace([`BACON...`]) ]
		, [ check_text( `Baconat` ), set(chain, `bacon`), trace([`BACON...`]) ]
		, [ check_text( `Ordernummerimmeranführen!` ), set(chain, `bacon`), trace([`BACON...`]) ]
 
		, [ check_text( `fillmetallbau` ), set(chain, `fill`), trace([`FILL...`]) ]

		, [ check_text( `wwwlonzacom` ), set(chain, `lonza`), trace([`LONZA...`]) ]

		, [ check_text( `FRENER&REIFER` ), set(chain, `frener`), trace([`FRENER & REIFER...`]) ]

		, [ check_text( `DöngesGmbH&Co` ), set(chain, `donges`), trace([`DONGES...`]) ]

		, [ check_text( `BerlinerWasserbetriebe` ), set(chain, `bwb`), trace([`BWB...`]) ]

		, [ check_text( `LudwigBRANDSTÄTTERBetriebs` ), set(chain, `brandstaetter`), trace([`BRANDSTAETTER...`]) ]

		, [ check_text( `knapp` ), set(chain, `knapp`), trace([`KNAPP...`]) ]

		, [ check_text( `PosArtikelMengeMehEinzelpreisRabattMWSTEUR-Betrag` ), set(chain, `kappa`), trace([`KAPPA...`]) ]

		, [ check_text( `coiver` ), set(chain, `coiver`), trace([`COIVER...`]) ]

		, [ check_text( `konegmbh` ), set(chain, `kone`), trace([`KONE ...`]) ]
		, [ check_text( `KONESABondeCommande` ), set(chain, `kone fr`), trace([`KONE FR ...`]) ]

%		, [ check_text( `GemäßunserenIhnenbekanntenBedingungenbestellenwir` ), set(chain, `huber`), trace([`HUBER...`]) ]

		, [ check_text( `evgentwicklungs` ), set(chain, `evg`), trace([`EVG...`]) ]

		%	Removed on request
		% , [ check_text( `Telamon` ), set(chain, `telamon`), trace([`TELAMON...`]) ]

		, [ check_text( `TataSteelUKLimited` ), set(chain, `tata uk`), trace([`TATA STEEL...`]) ]

		, [ or( [ check_text( `KokosingConstructionCompany` ), check_text( `kccsupply` ) ] )
			, set(chain, `kokosing`), trace([`KOKOSING...`]), set( re_extract ) 
		]
	
		, [ check_text( `boulonsmanic` ), set(chain, `boulons manic`), trace([`BOULONS MANIC...`]) ]

		, [ check_text( `FOCCHISpa` ), set(chain, `focchi` ), trace([`FOCCHI...`]), set( re_extract ) ]

		, [ check_text( `CarrierKältetechnikAustria` ), set(chain, `carrier`), trace([`CARRIER...`]) ]

		, [ check_text( `Item/MfgNumberDueDateOrderQtyU/MUnitCostU/MTaxTotal` ), set(chain, `terminix`), trace([`TERMINIX...`]) ]

 		, [ check_text( `671434439` ), set(chain, `babcock rail`), trace([`BABCOCK...`]) ]

		, [ check_text( `unipartraillimited` ), set(chain, `unipart rail`), trace([`UNIPART...`]) ]
	
		, [ check_text(`GIGFassadenGmbH`),  set(chain, `gig`), trace([`GIG...`])  ]
		, [ check_text(`GIGService`),  set(chain, `gig`), trace([`GIG...`])  ]
		, [ check_text(`PosNrArtikelNrArtikelbezeichnung`),  set(chain, `gig`), trace([`GIG...`])  ]
	
		, [ check_text(`DoppelmayrSeilbahnenGmbH`), set(chain, `doppelmayr`), trace([`DOPPELMAYR...`])  ]

		, [ check_text(`prosteel`), set(chain, `prosteel`), trace([`PROSTEEL...`])  ]

		, [ check_text(`@atschindlercom`), set(chain, `schindler`), trace([`SCHINDLER...`])  ]

		, [ check_text( `DIVISIONEMECCANICA-Tel0309400001Fax0309400026` ), set(chain, `impianti`), trace([`IMPIANTI...`]) ]

		, [ check_text(`NOTACOPIADELPRESENTEORDINEVARESTITUITAFIRMATAPERACCETTAZIONE`), set(chain, `impianti`), trace([`IMPIANTI...`]) ]

		, [ check_text(`WirbestellenzudenBedingungendieserBestellungfolgendeArtikel`), set(chain, `lohr`), trace([`LOHR...`])  ]

		, [ `Call`, `Off`, `Order`,  newline, set(chain, `he_simm`), trace([`HE SIMM...`])  ]

		, [ check_text(`SkanskaUSACivilNortheast`), set(chain, `skanska`), trace([`SKANSKA...`]) ]

		, [ check_text(`TCIProduct`), set(chain, `translec`), trace([`TRANSLEC...`]) ]

		, [ check_text(`propaksystems`), set(chain, `propak`), trace([`PROPAK...`]) ]

		, [ check_text( `vaultdawnltd` ), set(chain, `vaultdawn`), trace([`VAULTDAWN...`]) ]

		, [ check_text( `giugliano` ), set(chain, `it giugliano`), trace([`IT GIUGLIANO ...`]) ]
		
		, [ check_text( `johnsoncontrols` ), set(chain, `ch johnson controls`), trace([`CH JOHNSON CONTROLS ...`]) ]
		
		, [ check_text( `alstomgridag` ), set(chain, `ch alstom`), trace([`CH ALSTOM ...`]) ]
		
		, [ check_text( `@tozziholdingcom` ), set(chain, `tozzi`), trace([`TOZZI ...`]) ]
	
		%	Removed on request
		% , [ check_text( `clementsupportservicesinc` ), set(chain, `us clement`), trace([`US CLEMENT ...`]) ]
		
		, [ check_text( `travisperkinstradingco+` ),set(chain, `travis perkins (tradacom)`), trace([`TP TRADACOM ...`]) ]
	
		, [ or( [ check_text( `info@mercuryie` ), check_text( `mercuryengineering` ) ] )
			, set(chain, `mercury`), trace([`MERCURY ...`]) 
		]
	
		, [ check_text( `N°DésignationQuantitéUnitéPU%Montant` ), set(chain, `morand`), trace([`MORAND ...`]) ]

		, [ check_text( `ngbailey` ), set(chain, `baileys limited`), trace([`BAILEY LIMITED ...`]), set( re_extract ) ]
		
		, [ check_text( `pleasesupplyanddespatchinaccordancewiththefollowing` ), set(chain, `intelligent order form (hilti)`), trace([`INTELLIGENT ORDER FORM (HILTI) ...`]) ]

		, [ check_text( `No644490` ), set(chain, `hss hire hilti`), trace([`HSS HIRE HILTI ...`]) ]

		, [ check_text( `termsofpaymentforlionweld` ), set(chain, `lionweld kennedy`), trace([`LIONWELD KENNEDY ...`]) ]
	
		, [ check_text( `a&teuropespa` ), set(chain, `it a&t`), trace([`IT A&T ...`]) ]
	
		, [ check_text( `alpiqintecmilanospa` ), set(chain, `it alpiq`), trace([`IT  ALPIQ ...`]) ]
	
		, [ check_text( `metalsistem` ), set(chain, `it metalsistem`), trace([`IT METALSISTEM ...`]) ]
		
		, [ check_text( `rigacodicearticolo/descrizioneqtàumimportoimportodatacons` ), set(chain, `it rivoira`), trace([`IT RIVOIRA ...`]) ]

		, [ check_text( `enermech` ), set(chain, `enermech hilti`), trace([`ENERMECH HILTI ...`]) ]

		, [ check_text( `nissanmotor` ), set(chain, `nissan hilti`), trace([`NISSAN HILTI ...`]) ]
		
		, [ check_text( `553239738` ), set(chain, `petrofac hilti`), trace([`PETROFAC ...`]) ]
		
		, [ check_text( `thyssenkrupp` ), set(chain, `fr thyssenkrupp`), trace([`FR THYSSENKRUPP ...`]) ]
		
		, [ check_text( `thermorefrigeration` ), set(chain, `fr thermo refrigeration`), trace([`FR THERMO REFRIGERATION ...`]) ]
		
		, [ check_text( `mcmullen` ), set(chain, `mcmullen hilti`), trace([`MCMULLEN ...`]) ]
	
		, [ check_text( `aeml@aemlfr` ), set(chain, `fr aeml` ), trace([`FR AEML ...`]) ]

		, [ check_text( `geaprocomacspa` ), set(chain, `it gea` ), trace([`IT GEA ...`]) ]

		, [ check_text( `giennoise` ), set(chain, `fr giennoise` ), trace([`FR GIENNOISE ...`]) ]
	
		, [ check_text( `VsriferimentoCodiceTelefonoFaxPartitaIVACodiceFiscale` ), set(chain, `it cesare fumagalli` ), trace([`IT CESARE FUMAGALLI ...`]) ]

		, [ check_text( `geaprocomacspa` ), set(chain, `it gea` ), trace([`IT GEA ...`]) ]

		, [ check_text( `simem` ), set(chain, `it simem` ), trace([`IT SIMEM ...`]) ]

		, [ check_text( `ValutaVsCodFornitoreRevisioneordineDatarevisioneordineRiferimentofornitore` ), set(chain, `it garbuio` ), trace([`IT GARBUIO ...`]) ]
	
		, [ check_text( `conergy` ), set(chain, `it conergy` ), trace([`IT CONERGY ...`]) ]
	
		, [ check_text( `wwwhuberde` ), set(chain, `de huber` ), trace([`DE HUBER ...`]) ]
		
		, [ check_text( `gb-amco` ), set( chain, `amco order form hilti` ), trace( [ `AMCO ORDER FORM ...` ] ) ]

		, [ check_text( `modulblok` ), set( chain, `modulblok` ), trace( [ `MODULBLOK ...` ] ) ]
	
		, [ or( [ check_text( `@fifegovuk` ), check_text( `fife` ) ] ), set( chain, `fife council` ), trace( [ `FIFE COUNCIL ...` ] ) ]
	
		, [ check_text( `@sematic` ), set( chain, `it sematic` ), trace( [ `SEMATIC ...` ] ) ]
		
		, [ check_text( `@siti-btcom` ), set( chain, `it siti` ), trace( [ `SITI ...` ] ) ]
	
		, [ check_text( `@teckcom` ), set( chain, `teck metals` ), trace( [ `TECK METALS ...` ] ) ]

		, [ check_text( `premierelectric` ), set( chain, `premier electric hilti` ), trace( [ `PREMIER ELECTRICS ...` ] ) ]
		
		, [ check_text( `kontech` ), set( chain, `dk kontech` ), trace( [ `DK KONTECH ...` ] ) ]
		
		, [ or( [ check_text( `konespaordinediacquisto` ), check_text( `konespapurchaseorder` ) ] ), set( chain, `it kone` ), trace( [ `IT KONE ...` ] ) ]

		, [ check_text( `premierelectric` ), set( chain, `premier electric hilti` ), trace( [ `PREMIER ELECTRICS ...` ] ) ]
	
		, [ or( [ check_text( `formulaone` ), check_text( `vatnumber997337752` ) ] ), set(chain, `formula one hilti`), trace([`FORMULA ONE...`])  ]
	
		, [ check_text( `rubaxlift` ), set(chain, `rubax lifts hilti`), trace([`RUBAX LIFTS ...`]), set( re_extract ) ]
		
		, [ check_text( `jacobsles` ), set(chain, `jacobs hilti`), trace([`JACOBS ...`]) ]
	
		, [ or( [ check_text( `petercoxltd` ), check_text( `gb-petrcox` ) ] )
			, set(chain, `peter cox hilti`), trace([`PETER COX ...`]) 
		]
	
		, [ check_text( `wellheadelectricalsupplies` ), set(chain, `wellhead electrical supplies`), trace([`WELLHEAD ELECTRICAL ...`]) ]
		
		, [ or( [ check_text( `plasteringcontractors` ), check_text( `stanmorecontractors` ) ] ), set(chain, `stanmore plastering hilti`), trace([`STANMORE PLASTERING ...`]) ]

		, [ check_text( `leongrosse` ), set(chain, `fr leongrosse`), trace([`FR LEONGROSSE ...`]) ]
		
		, [ check_text( `macleancouk` ), set(chain, `maclean electrical hilti`), trace([`MACLEAN ELECTRICAL ...`]) ]
		
		, [ check_text( `meiser` ), set(chain, `meiser`), trace([`MEISER ...`]) ]

		, [ check_text( `tel02083096699fax` ), set(chain, `imperial duct hilti`), trace([`IMPERIAL DUCT ...`]) ]

		, [ check_text( `manchesterairport` ), set(chain, `manchester airport hilti`), trace([`MANCHESTER AIRPORT ...`]) ]

		, [ check_text( `landispa` ), set(chain, `it landi`), trace([`IT LANDI ...`]) ]

		, [ check_text( `auerat` ), set(chain, `at auer`), trace([`AT AUER ...`]) ]

		, [ check_text( `chgudel` ), set(chain, `ch guedel`), trace([`CH GUDEL ...`]) ]

		, [ check_text( `unionengineering` ), set(chain, `dk union engineering`), trace([`DK UNION ENGINEERING ...`]) ]
		
		, [ check_text( `crownhousetechnologiesltd` ), set(chain, `crown house hilti`), trace([`CROWN HOUSE ...`]) ]
		
		, [ check_text( `westernpowerdistribution` ), set(chain, `western power hilti`), trace([`WESTERN POWER ...`]) ]
		
		, [ check_text( `gb440289653` ), set(chain, `bobst hilti`), trace([`BOBST ...`]) ]
		
		, [ check_text( `arthurmckaybuilding` ), set(chain, `arthur mckay`), trace([`ARTHUR MCKAY ...`]) ]
		
		, [ check_text( `tubelineslimited` ), set(chain, `tubelines hilti`), trace([`TUBELINES ...`]) ]
		
		, [ check_text( `756277008` ), set(re_extract), set(chain, `london ug bcv hilti`), trace([`LONDON UG BCV ...`]) ]
		
		, [ check_text( `caverion` ), set(chain, `at caverion`), trace([`AT CAVERION ...`]) ]
	
		, [ or( [ check_text( `CHE-102909703MWST` )
		
				, check_text( `SchweizerischeBundesbahnenSBB` )
				
			] ), set(chain, `ch sbb`), trace([`CH SBB ...`]) 
	
		]
		
		, [ check_text( `hennecke` ), set(chain, `de hennecke`), trace([`DE HENNECKE ...`]) ]
		
		, [ check_text( `oclfacades` ), set(chain, `ocl facades hilti`), trace([`OCL FACADES ...`]) ]
	
		, [ check_text( `truevalue` ), set(chain, `us true value`), trace([`US TRUE VALUE ...`]) ]
		
		, [ check_text( `chapcivilengineering` ), set(chain, `chap civils hilti`), trace([`CHAP CIVILS ...`]) ]
		
		, [ check_text( `chapconstruction` ), set(chain, `chap construction hilti`), trace([`CHAP CONSTRUCTION ...`]) ]
		
		, [ check_text( `johnndunngroup` ), set(chain, `john n dunn hilti`), trace([`JOHN N DUNN ...`]) ]

		, [ check_text( `vallectric` ), set(chain, `vallectric hilti`), trace([`VALLECTRIC ...`]) ]
		
		, [ or( [ check_text( `fabcon-usa` )
				, check_text( `LineYourPartNoYourDescriptionDockQtyDueQuantityUnitPriceDelDatePartRevision` )
			] )
			, set(chain, `us fabcon`), trace([`US FABCON ...`]) 
		]

		, [ check_text( `deborahservicesltd` ), set(chain, `deborah services hilti`), trace([`DEBORAH SERVICES ...`]) ]

		, [ check_text( `ContenantdescriptionValiditéPrixUnitTotalHT` ), set(chain, `fr otis`), trace([`FR OTIS ...`]) ]
			
		, [ check_text( `stenhøja/s` ), set(chain, `dk stenhoj`), trace([`STENHOJ ...`]) ]

		, [ check_text( `Ruhrverband` ), set(chain, `de ruhrverband`), trace([`DE RUHRVERBAND ...`]) ]

		, [ check_text( `IndustrialAcousticsCompany` ), set(chain, `industrial acoustics hilti`), trace([`INDUSTRIAL PIPING SERVICE ...`]), set( re_extract ) ]

		, [ check_text( `jessellaltd` ), set(chain, `jessella limited hilti`), trace([`JESSELLA LTD ...`]), set( re_extract ) ]

		, [ check_text( `barrattnorthscotland` ), set(chain, `gb barratt north scotland`), trace([`BARRATT NORTH SCOTLAND ...`]) ]

		, [ check_text( `moraycouncil` ), set(chain, `gb moray council`), trace([`MORAY COUNCIL ...`]) ]

		, [ check_text( `elektalimited` ), set(chain, `gb elekta`), trace([`ELEKTA LIMITED ...`]) ]

		, [ check_text( `transportforlondon(tfl)` ), set(chain, `tfl hilti`), trace([`TFL ...`]) ]
		
		, [ check_text( `http//wwwpotashcorpcom/media/POT_North_American_PO_Terms_and_Conditionspdf` ), dummy(s1)
	
			, or( [ [ check( dummy(y) < 0 ), set( chain, `pcs` ), trace( [ `PCS ...` ] ) ]
			
				, [ check( dummy(y) > 0 ), set(chain, `ca pcs`), trace( [`CA PCS ...`] ) ]
				
			] )
	
		]

		, [ check_text( `brandenergy&infrastructure` ), set(chain, `GB-HARSCO`), trace([`HARSCO ...`])  ]

		, [ or( [ check_text( `konebelgiumsa` )
		
				, check_text( `sakonebelgium` )
				
			] ), set(chain, `be kone`), trace([`BE KONE ...`]) 
			
		]

		, [ check_text( `cplheatingandplumbing` ), set(chain, `gb cpl heating & plumbing`), trace([`CPL HEATING & PLUMBING ...`]) ]
		
		, [ check_text( `@costruireimpiantiit` ), set(chain, `it costruire impianti`), trace([`IT COSTRUIRE IMPIANTI ...`])  ]
		
		, [ check_text( `FleetwoodArchitecturalAluminium` ), set(chain, `fleetwood architectural hilti`), trace([`FLEETWOOD ARCHITECTURAL ...`])  ]

		, [ check_text( `o'halloran&o'brien` ), set(chain, `gb ohalloran and obrien`), trace([`O'HALLORAN & O'BRIEN ...`])  ]

		%	Removed on request
		% , [ or( [ check_text( `Kiewitcom` ), check_text( `KiewitPower` ) ] ), set(chain, `kiewit marketplace`), trace([`KMP ...`]) ]
	
		, [ check_text( `stewartmilne` ), set(chain, `stewart milne hilti`), trace([`STEWART MILNE ...`]) ]

		, [ check_text( `(01604)752424` ), set(chain, `travis perkins (hilti)`), trace([`TRAVIS PERKINS (HILTI)`]), set( re_extract ) ]

		, [ check_text( `lindnerplc` ), set(chain, `gb lindner`), trace([`LINDNER ...`]) ]

		, [ check_text( `voestalpine` ), set(chain, `at voest`), trace([`AT VOEST ...`]) ]

		, [ check_text( `PARTITAIVAECODICEFISCALE00099440299-CAPITALESOCIALE` ), check_text( `17000000IV-REAROVIGOn72815-REGDELLEIMPRESEDIROVIGON00099440299` )
		
			, set(chain, `it guerrato`), trace([`IT GUERRATO ...`]) 
			
		]
	
		, [ check_text( `selectplanthire` ), set(chain, `gb select plant hire`), trace([`GB SELECT PLANT HIRE ...`]), set( re_extract ) ]
		
		, [ check_text( `BOUYGUESUK` ), set(chain, `gb bouygues uk`), trace([`GB BOUYGUES UK ...`]), set( re_extract ) ]
	
		, [ check_text( `dawcolectric` ), set(chain, `ca dawcolectric`), trace([`CA DAWCOELECTRIC ...`])  ]
		
		, [ check_text( `Hotchkiss` ), set(chain, `gb hotchkiss`), trace([`GB HOTCHKISS ...`]) ]
	
		, [ check_text( `expandedltd` ), set(chain, `gb expanded structures`), trace([`GB EXPANDED STRUCTURES ...`]) ]
	
		, [ check_text( `northerncladdingltd` ), set(chain, `gb northern cladding`), trace([`GB NORTHERN CLADDING ...`]) ]

		, [ check_text( `watkinsplumbing` ), set(chain, `gb watkins plumbing`), trace([`GB WATKINS PLUMBING ...`]), set( re_extract ) ]
		
		, [ or( [ check_text( `http//wwwlnecpt/qpe/marcacao/mandatos_tabela` )
		
				, check_text( `mota-engil` )
				
			] ), set(chain, `pt montaengil`), trace([`PT MONTAENGIL ...`])
		
		]
		
		, [ check_text( `grippleltd` ), set(chain, `gb gripple`), trace([`GB GRIPPLE ...`]) ]
		
		, [ check_text( `dawnusconstruction` ), set(chain, `gb dawnus construction`), trace([`GB DAWNUS CONSTRUCTION ...`]) ]
		
		, [ check_text( `cms-escouk` ), set(chain, `gb cms enviro systems`), trace([`GB CMS ENVIRO SYSTEMS ...`]), set( re_extract ) ]
	
		, [ check_text( `erikscouk` ), set(chain, `gb eriks`), trace([`GB ERIKS ...`]) ]
	
		, [ check_text( `strabagpropertyand` ), set(chain, `de strabag`), trace([`DE STRABAG ...`]) ]
	
		, [ check_text( `39009347399` ), set(chain, `au atom supply`), trace([`AU ATOM ...`]) ]

		, [ check_text( `ABN98000893667` ), set(chain, `au leighton`), trace([`AU LEIGHTON ...`]) ]

		, [ check_text( `groundconstructionltd` ), set(chain, `gb ground construction`), trace([`GB GROUND CONSTRUCTION ...`]) ]

		, [ check_text( `tecalemit` ), set(chain, `gb tecalemit garage`), trace([`GB TECALEMIT GARAGE EQUIPMENT CO ...`]) ]

		, [ check_text( `01822610610` ), set(chain, `gb beacon comms`), trace([`GB BEACON COMMUNICATIONS ...`]) ]
		
		, [ check_text( `TUVUNIENISO90012000CertNr501004448` ), set(chain, `it sech`), trace([`IT SECH ...`]), set( re_extract ) ]
		
		, [ check_text( `togaplanthireltd` ), set(chain, `gb toga plant hire`), trace([`GB TOGA PLANT HIRE ...`]) ]
		
		, [ check_text( `KrämerLufttechnik` ), set(chain, `de kraemer`), trace([`DE KRAEMER LUFFTECHNIK ...`]), set( re_extract ) ]
	
		, [ check_text( `DE251384104` ), set(chain, `de wolf`), trace([`DE WOLF ...`]), set( re_extract ) ]
	
		, [ or( [ check_text( `tclarkeplc` ), check_text( `235557257` ) ] ), set(chain, `gb t clarke`), trace([`T CLARKE...`])  ]

		, [ check_text( `35107210248` ), set(chain, `au pilbara iron`), trace([`AU PILBARA IRON ...`]) ]
	
		, [ check_text( `@cskdk` ), set(chain, `dk csk`), trace([`DK CSK ...`]) ]
	
		, [ check_text( `87010221486` ), set(chain, `au thiess`), trace([`AU THIESS ...`]) ]
	
		, [ check_text( `seas-nve` ), set(chain, `dk seas nve`), trace([`SEAS-NVE...`])  ]

		, [ or( [ check_text( `amecgroup` ), check_text( `amecfoster` ) ] ), set(chain, `gb amec group`), trace([`AMEC GROUP...`])  ]
		
		, [ check_text( `vdab` ), set(chain, `be vdab`), trace([`V.D.A.B. ...`])  ]
	
		, [ check_text( `(09)2634747` ), set(chain, `be eandis`), trace([`EANDIS...`])  ]

		, [ check_text( `PMSElektro-undAutomationstechnik` ), set(chain, `pms`), trace([`PMS ELEKTRO...`]) ]

		, [ check_text( `88374614` ), set(chain, `dk valmont`), trace([`VALMONT...`])  ]

		, [ check_text( `eternitnv` ), set(chain, `be eternit`), trace([`ETERNIT...`])  ]
		
		, [ check_text( `GB700949834` ), set(chain, `gb hire station`), trace([`HIRE STATION ...`]) ]
		
		, [ check_text( `modebestbuilders` ), set(chain, `gb modebest builders`), trace([`MODEBEST BUILDERS ...`]) ]
	
		, [ check_text( `151778156` ), set(chain, `gb smiths equipment hire`), trace([`SMITHS EQUIPMENT HIRE ...`]) ]
		
		, [ check_text( `swarovskicom` ), set(chain, `at swarovski`), trace([`SWAROVSKI ...`]) ]
	
		, [ check_text( `catobau` ), set(chain, `at catobau`), trace([`CATOBAU ...`]) ]
		
		, [ check_text( `COPIADELPRESENTEORDINEDOVRA'ESSERERESACONTROFIRMATAPERACCETTAZIONE` ), set(chain, `it mit`), trace([`MIT ...`]) ]
		
		, [ check_text( `KouvolanPutkityöOy` ), set(chain, `fi kouvolan putkityo oy`), trace([`KOUVOLAN PUTKITYÖ OY ...`]) ]
		
		, [ check_text( `fastemsoy` ), set(chain, `fi fastems`), trace([`FASTEMS ...`]) ]
		
		, [ check_text( `GB413633086` ), set(chain, `gb tyco fire solutions`), trace([`TYCO FIRE & INTEGRATE SOLUTIONS ...`]) ]

		, [ check_text( `IE8D47240T` ), set(chain, `ie siac`), trace([`SIAC ...`]) ]

		, [ check_text( `IE6543400W` ), set(chain, `gb techrete ireland`), trace([`GB TECHRETE ...`]) ]
	
		, [ check_text( `englisharchitecturalglazing` ), set(chain, `gb architectural glazing`), trace([`ARCHITECTURAL GLAZING ...`]) ]

		, [ check_text( `890015538` ), set(chain, `gb sapphire balustrades`), trace([`SAPPHIRE BALUSTRADES ...`]) ]
	
		, [ check_text( `AntR/OArtikelnr/beskrivningPrisBelopp` ), set(chain, `se ramirent`), trace([`RAMIRENT ...`]) ]
	
		, [ check_text( `volvogroup` ), set(chain, `se volvo`), trace([`VOLVO ...`]) ]
		
		, [ check_text( `kleblbaulogistik` ), set(chain, `de klebl baulogistik`), trace([`KLEBL BAULOGISTIK ...`]) ]
		
		, [ check_text( `AteaA/S` ), set(chain, `dk atea`), trace([`ATEA ...`]) ]
		
		, [ check_text( `zetabiopharma` ), set(chain, `at zeta biopharma`), trace([`ZETA BIOPHARMA ...`]) ]
		
		, [ check_text( `celticcontractors` ), set(chain, `gb celtic contractors`), trace([`CELTIC CONTRACTORS ...`]) ]
		
		, [ check_text( `truttmannag` ), set(chain, `ch truttmann`), trace([`TRUTTMANN ...`]) ]

		, [ check_text( `resologistique` ), set(chain, `fr reso logistique`), trace([`FR RESO LOGISTIQUE ...`]) ]
		
		, [ check_text( `ETNFRANZCOLRUYT` ), set(chain, `be colruyt group`), trace([`BE COLRUYT GROUP ...`]) ]
		
		, [ check_text( `656204837` ), set(chain, `gb metallic fabrications`), trace([`METALLIC FABRICATIONS ...`]) ]

		, [ or( [ check_text( `beck-pollitzercom` ), check_text( `beck&pollitzer` ) ] )
			, set(chain, `gb beck and pollitzer`), trace([`BECK & POLLITZER ...`]) 
		]
		
		, [ check_text( `laingorourke` ), set(chain, `gb laing orourke`), trace([`LAING O'ROURKE CONSTRUCTION ...`]) ]

		, [ or( [ check_text( `821284350` ), check_text( `grahamsmithuk` ) ] ), set(chain, `gb graham smith`), trace([`GRAHAM SMITH ...`]) ]
	
		, [ check_text( `dennertmassivhaus` ), set(chain, `de dennert massivhaus`), trace([`DENNERT MASSIVHAUS ...`]) ]

		, [ check_text( `915771313` ), set(chain, `gb keepmoat regeneration (fhm)`), trace([`KEEPMOAT REGENERATION (FHM) ...`]) ]

		, [ check_text( `TOYOTAMOTORMANUFACTURING` ), set(chain, `gb toyota motor manufacturing`), trace([`TOYOTA MOTOR MANUFACTURING ...`]) ]
	
		, [ check_text( `toyotamotor` ), set(chain, `toyota hilti` ), trace([`TOYOTA HILTI ...`]) ]
	
		, [ check_text( `imtechengineering` ), set(chain, `gb imtech engineering` ), trace([`IMTECH ENGINEERING ...`]) ]
	
		, [ check_text( `alstomgrid` ), set(chain, `fr alstom`), trace([`ALSTOM GRID ...`]) ]
	
		, [ check_text( `RAVATEPROFESSIONNEL` ), set(chain, `fr ravate professionnel`), trace([`RAVATE PROFESSIONNEL ...`]), set( re_extract ) ]
	
		, [ check_text( `eabse` ), set(chain, `se eab` ), trace([`EAB ...`]) ]
		
		, [ check_text( `@handtmannde` ), set(chain, `de handtmann service`), trace([`HANDTMANN SERVICE ...`]) ]

		, [ check_text( `writech` ), set(chain, `ie writech industrial` ), trace([`WRITECH...`]) ]
	
		, [ check_text( `Stadler+Schaaf` ), set(chain, `de stadler + schaaf`), trace([`STADLER + SCHAAF ...`]) ]
	
		, [ check_text( `<GENERATOR_INFO>INPLANGmbH</GENERATOR_INFO>` ), set(chain, `de hoerlemann`), trace([`HOERLEMANN ...`]), set( re_extract ) ]

		, [ check_text( `GEBHARDTFördertechnik` ), set(chain, `de gebhardt foedertechnik`), trace([`GEBHARDT FOEDERTECHNIK ...`]) ]
	
		, [ check_text( `LIEBHERR-HausgeräteLienzGmbH` ), set(chain, `at liebherr-hausgeräte lienz` ), trace([`LIEBHERR-HAUSGERATE LIENZE ...`]) ]
		
		, [ check_text( `SMPOCrippleGate` ), set(chain, `fr smpo`), trace([`SMPO ...`]) ]
		
		, [ check_text( `roccheggiani` ), set(chain, `it roccheggiani` ), trace([`ROCCHEGGIANI ...`]) ]
	
		, [ check_text( `PhiborEntreprises` ), set(chain, `fr phibor entreprises`), trace([`PHIBOR ENTREPRISES ...`]) ]
		
		, [ check_text( `acciaierievalbruna` ), set(chain, `it valbruna` ), trace([`VALBRUNA...`]) ]
	
		, [ check_text( `DE126117135` ), set(chain, `de westfalen ag`), trace([`WESTFALEN AG ...`]) ]
	
		, [ check_text( `graybarcouk` ), set(chain, `gb graybar` ), trace([`GRAYBAR...`]) ]

		, [ check_text( `GB217759047` ), set(chain, `gb air products` ), trace([`AIR PRODUCTS...`]) ]

		, [ or( [ check_text( `TuotenumeroTuotenimikeMintilmääräKPLMääräHintaperYhteens` )
				, check_text( `TuotenumeroTuotenimikekplKustannuspaikkaKäyttäjäkk€/kk` )
			] ), set(chain, `fi hilti iof` ), trace([`INTELLIGENT ORDER FORM (FI)...`]) 
		]
		
		, [ check_text( `mcdermottbuilding` ), set(chain, `gb mcdermott building` ), trace([`MCDERMOTT BUILDING...`]) ]

		, [ check_text( `sebinoeu` ), set(chain, `it sebino` ), trace([`SEBINO...`]) ]

		, [ check_text( `633414071` ), set(chain, `gb deepdale solutions` ), trace([`DEEPDALE SOLUTIONS...`]) ]

		, [ check_text( `stihlag` ), set(chain, `de stihl` ), trace([`STIHL ...`]) ]
		
		, [ check_text( `WalzGebäudetechnikGmbH` ), set(chain, `de walz gebäudetechnik` ), trace([`WALZ GEBAUDETECHNIK ...`]), set( re_extract ) ]
		
		% , [ check_text( `MaconSupplyInc` ), set(chain, `us macon` ), trace([`MACON...`]) ]

		, [ check_text( `tbsgmbhde` ), set(chain, `de tbs` ), trace([`TBS ...`]) ]
		
		, [ check_text( `413216008` ), set(chain, `gb air-serv` ), trace([`AIR-SERV ...`]) ]

		, [ check_text( `shepherdengineering` ), set(chain, `gb shepherd engineering` ), trace([`SHEPHERD ENGINEERING SERVICES...`]) ]

		, [ check_text( `wwwaplantcom` ), set(chain, `gb ashtead plant` ), trace([`ASHTEAD PLANT...`]) ]

		, [ check_text( `geatdsgmbh` ), set(chain, `de gea tds` ), trace([`GEA TDS ...`]) ]
	
		, [ check_text( `sagatertiaire` ), set(chain, `fr saga tertiaire` ), trace([`SAGA TERTIAIRE...`]) ]
		
		, [ check_text( `tritonconstruction` ), set(chain, `triton hiltigb` ), trace([`TRITON CONSTRUCTION ...`]) ]

		, [ check_text( `DDEE881155330022990033` ), set(chain, `de gruenbeck` ), trace([`GRUENBECK ...`]), set( re_extract ) ]
		
		, [ check_text( `LESCOMPAGNONSD'ERIC` ), set(chain, `fr les compagnons` ), trace([`LES COMPAGNONS D'ERIC ...`]) ]

		, [ or( [ check_text( `COFELYAXIMA` ), check_text( `AXIMAREFRIGERATION` ) ] ), set(chain, `fr axima` ), trace([`AXIMA...`]) ]
		
		, [ check_text( `FR65381362243` ), set(chain, `fr anvolia` ), trace([`ANVOLIA ...`]) ]

		, [ check_text( `SanitärFrei` ), set(chain, `ch sanitar frei` ), trace([`SANITAR FREI ...`]) ]
		
		, [ check_text( `valecanada` ), set(chain, `ca vale` ), trace([`VALE CANADA ...`]) ]
	
		, [ check_text( `997320973` ), set( chain, `gb brandon hire` ), trace( [ `BRANDON HIRE ...` ] ) ]

		, [ check_text( `ArtículosRefProveedorUdEspTécnCantidadPrecio%DtImporteFechaEntrega` )
			, set(chain, `es mac puar` ), trace([`MAC PUAR...`]) 
		]
		
		, [ check_text( `sunbeltrentals` ), set(chain, `us sunbelt` ), trace([`SUNBELT RENTALS...`]) ]

		, [ check_text( `<NAME1>IWB</NAME1>` ), set(chain, `ch iwb` ), trace([`IWB...`]) ]

		, [ check_text( `virklundsport` ), set(chain, `dk virklund` ), trace([`VIRKLUND SPORT...`]) ]

		, [ check_text( `BBCRIVELLI&CERNECCASA` ), set(chain, `ch bb crivelli & cernecca` ), trace([`BB CRIVELLI & CERNECCA ...`]) ]
		
		, [ check_text( `commessacrea` ), set(chain, `it crea` ), trace([`IT CREA ...`]), set( re_extract ) ]

		, [ check_text( `DDEE881155330022990033` ), set(chain, `de gruenbeck` ), trace([`GRUENBECK ...`]), set( re_extract ) ]

		, [ or( [ check_text( `@sistemit` ), check_text( `02251920365` ) ] )
			, set(chain, `sistem hilti` ), trace([`SISTEM ...`]) 
		]

		, [ check_text( `LafornituradeiprodottichimicideveessereaccompagnatadallaSchedadeiDatidisicurezzaredattasecondoilREG453/2010pena` ), set(chain, `it garc` ), trace([`GARC ...`]) ]

		, [ check_text( `ltwintralogistics` ), set(chain, `doppelmayr` ), trace([`LTW INTRALOGISTICS...`]) ]
		
		, [ check_text( `16009690251` ), set(chain, `au tom stoddart` ), trace([`TOM STODDART ...`]) ]

		, [ check_text( `siloscordobacom` ), set(chain, `es silos cordoba` ), trace([`SILOS CORDOBA ...`]) ]
		
		, [ or( [ check_text( `talleresagui` ), check_text( `LínCódArticuloDenominaciónCantidadUnPrecioTotallíneaFechaentreg` ) ] )
			, set(chain, `es talleres agui` ), trace([`TALLERES AGUI ...`]) 
		]

		, [ check_text( `DresdnerKühlanlagenbau` ), set(chain, `de dresdner kuehlanlangen` ), trace([`DRESDNER KUEHLANLANGEN...`]) ]
		
		, [ check_text( `<GENERATOR_INFO>INPLANGmbH</GENERATOR_INFO>` ), set(chain, `de hoerlemann`), trace([`HOERLEMANN ...`]), set( re_extract ) ]
	
		, [ check_text( `LafornituradeiprodottichimicideveessereaccompagnatadallaSchedadeiDatidisicurezzaredattasecondoilREG453/2010pena` ), set(chain, `it garc` ), trace([`GARC ...`]) ]

		, [ check_text( `NesteOilOyj` ), set( chain, `fi neste oil` ), trace( [ `NESTE OIL ...` ] ), set( re_extract ) ]
			
		, [ or( [ check_text( `wwwnordimpianti-srl` ), check_text( `wwwcaraglio` ) ] )
		
			, set( chain, `it nordimpianti` ), trace( [ `NORDIMPIANTI ...` ] )
			
		]
		
		, [ check_text( `CCIITTYYTTOOOOLLHHIIRREE` ), set( chain, `gb city tool hire` ), trace( [ `CITY TOOL HIRE ...` ] ) ]
		
		, [ check_text( `BHPBilliton` ), set( chain, `au bhp` ), trace( [ `BHP ...` ] ) ]
	
		, [ check_text( `carrierutccom` ), set(chain, `nl carrier` ), trace([`CARRIER REFRIGERATION ...`]) ]
	
		, [ check_text( `buildersequipmentltd` ), set( chain, `gb builders equipment` ), trace( [ `BUILDERS EQUIPMENT ...` ] ) ]
	
		, [ check_text( `dron&dicksonltd` ), set( chain, `gb dron and dickson` ), trace( [ `DRON & DICKSON ...` ] ) ]
		
		, [ check_text( `151778156` ), set( chain, `gb smiths equipment hire` ), trace( [ `SMITHS EQUIPMENT HIRE ...` ] ) ]

		, [ check_text( `GB582895876` ), set( chain, `gb nov mission` ), trace( [ `NOV MISSION ...` ] ) ]
	
		, [ check_text( `01708720170` ), set( chain, `it diesse electra` ), trace( [ `DIESSE ELECTRA ...` ] ) ]

		, [ check_text( `weigerstorfer` ), set( chain, `de weigerstorfer` ), trace( [ `WEIGERSTORFER ...` ] ), set( re_extract ) ]

		, [ check_text( `kamperhandwerk` ), set( chain, `at kamper` ), trace( [ `KAMPER HANDWERK ...` ] ) ]
	
		, [ check_text( `fcoservices` ), set( chain, `gb fco services` ), trace( [ `FCO SERVICES ...` ] ) ]

		, [ check_text( `purchasing@kaefercdcouk` ), set( chain, `gb kaefer c&d` ), trace( [ `KAEFER C&D ...` ] ) ]
		
		, [ check_text( `industrialpipingservice` ), set(chain, `de ips`), trace([`INDUSTRIAL PIPING SERVICE ...`]) ]
		
		, [ check_text( `sistavacpt` ), set( chain, `pt sistavac` ), trace( [ `SISTAVAC ...` ] ) ]
	
		, [ check_text( `Nilsen(SA)PtyLtd` ), set( chain, `au nilsen (sa) pty` ), trace( [ `NILSEN (SA) PTY ...` ] ) ]
		
		, [ check_text( `279987564` ), set( chain, `gb torrent trackside` ), trace( [ `TORRENT TRACKSIDE ...` ] ) ]
	
		, [ check_text( `DrywallSolutionsLtd` ), set( chain, `gb drywall solutions` ), trace( [ `DRYWALL SOLUTIONS ...` ] ), set( re_extract ) ]
	
		, [ check_text( `LAGUARIGUE` ), set( chain, `fr laguarigue` ), trace( [ `LAGUARIGUE ...` ] ) ]
		
		, [ check_text( `53000983700` ), set(chain, `au downer` ), trace([`DOWNER ...`]) ]

		, [ check_text( `Banedanmark` ), set( chain, `banedk hilti` ), trace( [ `BANE DANMARK ...` ] ) ]

		, [ check_text( `<NAME>KWO` ), set( chain, `ch kwo` ), trace( [ `KWO ...` ] ), set( re_extract ) ]

		, [ check_text( `ArestalferSA` ), set( chain, `pt arestalfer` ), trace( [ `ARESTALFER ...` ] ) ]

		, [ check_text( `@esschindlercom` ), set( chain, `es schindler` ), trace( [ `SCHINDLER ...` ] ) ]
	
		, [ check_text( `hochtiefpolska` ), set( chain, `pl hochtief` ), trace( [ `HOCHTIEF POLSKA ...` ] ) ]
	
		, [ check_text( `latechnique` ), set(chain, `be la technique`), trace([`LA TECHNIQUE ...`]) ]

		, [ check_text( `GARTNERCONTRACTINGCoLtd` ), set( chain, `hk gartner contracting` ), trace( [ `HK GARTNER CONTRACTING ...` ] ), set( re_extract ) ]
		
		, [ check_text( `TREIBACHERINDUSTRIEAG` ), set(chain, `at treibacher` ), trace([`TREIBACHER INDUSTRIE ...`]) ]
		
		, [ check_text( `andritzag` ), set( chain, `at andritz` ), trace( [ `ANDRITZ AG ...` ] ) ]
	
		, [ check_text( `CamecoCorporation` ), set( chain, `ca cameco` ), trace( [ `CA CAMECO ...` ] ) ]
		
		, [ check_text( `generaldatatech` ), set( chain, `us general datatech` ), trace( [ `GENERAL DATATECH ...` ] ) ]
		
		, [ or( [ check_text( `ADVANCEDCONNECTIONSINC` ), check_text( `JOBNAMEJOB#BUYER/PMTERMSSHIPVIA` ) ] )
			, set( chain, `us advanced connections` ), trace( [ `US ADVANCED CONNECTIONS ...` ] )
		]
	
		, [ check_text( `raymond-southern` ), set( chain, `us raymond` ), trace( [ `US RAYMOND ...` ] ) ]
		
		, [ or( [ check_text( `kuenzcom` ), check_text( `HansKünz` ) ] ), set(chain, `at kunz` ), trace([`KUENZ HANS ...`]) ]
		
		, [ check_text( `SniderBolt&Screw` ), set( chain, `us snider bolt screw` ), trace( [ `US SNIDER BOLT SCREW ...` ] ) ]
		
		, [ check_text( `kimbelmechanicalsystems` ), set( chain, `us kimbel mechanical` ), trace( [ `US KIMBEL MECHANICAL ...` ] ) ]
	
		, [ check_text( `Step3)SaveOrderbeforeSendingtoHiltiClickFileSaveusingExcel` ), set( chain, `us iof` ), trace( [ `US IOF ...` ] ) ]
	
		, [ check_text( `CodartMarcaCodProdutDescrizioneUMQtàPrezLordoImportoLordoSconti%PrezNettoImportoNettoCons` )
			, set( chain, `it pederzani` ), trace( [ `PEDERZANI ( NEW ) ...` ] ) 
		]
		
		, [ check_text( `TegometallIntSalesGmbH` ), set( chain, `de tegometall` ), trace( [ `TEGOMETALL ...` ] ) ]
		
		, [ check_text( `alpiqintecmilanospa` ), set(chain, `it alpiq`), trace([`IT  ALPIQ ...`]) ]
		
		, [ check_text( `uranservicios` ), set( chain, `es uran servicios` ), trace( [ `URAN SERVICIOS ...` ] ) ]

		, [ check_text( `Buck&HickmanNDC` ), set( chain, `gb buck and hickman` ), trace( [ `BUCK AND HICKMAN ...` ] ) ]
		
		, [ check_text( `GlobalHSESolutionsLimited` ), set( chain, `gb global hse solutions` ), trace( [ `GLOBAL HSE SOLUTIONS ...` ] ) ]
		
		, [ check_text( `WTCWärmetechnikChemnitz` ), set( chain, `de wtc` ), trace( [ `WTC WARMETECHNIK ...` ] ) ]
		
		, [ check_text( `mechanicasrl` ), set( chain, `it mechanica` ), trace( [ `MECHANICA SRL ...` ] ) ]
	
		, [ or( [ check_text( `deniosag` ), check_text( `deniosde` ) ] ), set( chain, `de denios ag` ), trace( [ `DENIOS AG ...` ] ) ]

		, [ check_text( `EstampacionesMetálicasÉpila` ), set( chain, `es estampaciones` ), trace( [ `ESTAMPACIONES ...` ] ), set( re_extract ) ]
		
		, [ check_text( `69001740727` ), set( chain, `au kennards hire` ), trace( [ `KENNARDS HIRE PTY LTD ...` ] ) ]

		, [ check_text( `htkgmbh` ), set( chain, `de htk` ), trace( [ `HTK GMBH HAUSTECHNIK ...` ] ) ]
		
		, [ check_text( `mastershomeimprovement` ), set( chain, `au masters` ), trace( [ `MASTERS HOME IMPROVEMENT AUSTRALIA PTY LTD ...` ] ) ]

		, [ check_text( `yunetung` ), set( chain, `fr yune tung` ), trace( [ `YUNE TUNG S.A. ...` ] ), set(re_extract) ]
		
		, [ check_text( `Liebherr-MCCtecRostockGmbH` ), set( chain, `de liebherr` ), trace( [ `LIEBHERR ...` ] ) ]

		, [ check_text( `cepi@cepisiloscom` ), set( chain, `it cepi` ), trace( [ `IT CEPI ...` ] ) ]

		, [ check_text( `jreddington` ), set( chain, `gb j reddington` ), trace( [ `J REDDINGTON ...` ] ) ]
		
		, [ check_text( `708964694` ), set( chain, `gb wood group services` ), trace( [ `WOOD GROUP SERVICES ...` ] ), set(re_extract) ]
		
		, [ check_text( `JOSEPHGALLAGHERLTD` ), set( chain, `gb joseph gallagher` ), trace( [ `JOSEPH GALLAGHER ...` ] ) ]

		, [ check_text( `KONEIndustrialOy` ), set( chain, `de kone industrial` ), trace( [ `KONE INDUSTRIAL ...` ] ) ]

		, [ check_text( `telectcom` ), set( chain, `us-telect` ), trace( [ `US Telect - HILTI ...` ] ) ]

		, [ check_text( `Frei&RunggaldierSrl` ), set( chain, `it frei and runggaldier` ), trace( [ `FREI AND RUNGGALDIER ...` ] ) ]
		
		, [ check_text( `YenişehirMhÖzgürSkNo23AAtaşehir-İstanbulSiparişiGönder` ), set( chain, `akyarlar hilti` ), trace( [ `Akyarlar Hilti Turk ...` ] ) ]

		, [ check_text( `CauntonEngineering` ), set( chain, `gb caunton engineering` ), trace( [ `CAUNTON ENGINEERING ...` ] ) ]
		
		, [ check_text( `hirolift` ), set( chain, `de hiro lift` ), trace( [ `HIRO LIFT ...` ] ) ]
		
		, [ check_text( `ComauSpA` ), set( chain, `it comau` ), trace( [ `COMAU ...` ] ) ]
	
		, [ check_text( `WebberLLC` ), set( chain, `us webber` ), trace( [ `WEBBER ...` ] ), set( re_extract ) ]
		
		, [ check_text( `heidelbergcement` ), set( chain, `de heidelbergercement` ), trace( [ `HEIDELBERGCEMENT AG ...` ] ) ]

		, [ check_text( `FEEIndustrieautomationGmbH` ), set( chain, `de fee` ), trace( [ `FEE ...` ] ) ]

		, [ check_text( `STOCKMAGASSTOCKMAGASIN` ), set( chain, `fr sotis` ), trace( [ `SOTIS ...` ] ) ]
	
		, [ check_text( `Step2)InputOrderData(GreyshadedareasofOrderForm)` ), set( chain, `us iof` ), trace( [ `US IOF ...` ] ) ]
		
		, [ check_text( `brockwhite` ), set( chain, `ca brock white` ), trace( [ `BROCK WHITE ...` ] ), set( re_extract ) ]
		
		, [ check_text( `EstampacionesMetálicasÉpila` ), set( chain, `es estampaciones` ), trace( [ `ESTAMPACIONES ...` ] ), set( re_extract ) ]
		
		, [ check_text( `LVDCompanynvTel+3256430511finances@lvdbe` ), set( chain, `lvd hilti` ), trace( [ `LVD Hilti BE ...` ] ) ]
		
		, [ or( [ check_text( `StageElectrics` ), check_text( `stage-electrics` ) ] )
			, set( chain, `gb stage electrics` ), trace( [ `STAGE ELECTRICS ...` ] ) 
		]

] ) ] ).	%	Because chain rule, nothing should ever go after OR - combined with end bracket.

i_speedy_check( TEXT ) :- string_to_lower(TEXT, TL), q_sys_sub_string( TL, _, _, `speedy`), q_sys_sub_string( TL, _, _, `limited`). 


%=========================================================================================
i_rule( it_tea_co_rule, [ it_tea_co_first_line, it_tea_co_second_line, set(chain, `it tea co` ), trace( [ `IT TEA CO ...` ] ) ] ).
%=========================================================================================
i_line_rule( it_tea_co_first_line, [ 
%=========================================================================================
	
	  some_num(d), some_other_num(d), tab
	   
	, a_date(date), tab
	
	, gibberish(s1), newline
	
] ).

%=========================================================================================
i_line_rule( it_tea_co_second_line, [ 
%=========================================================================================
	
	  q0n(word), `Hilti`, `Italia`
	
] ).

%=========================================================================================
i_rule( it_ceu_rule, [ it_ceu_first_line, it_ceu_second_line, set( chain, `it ceu` ), trace( [ `IT CEU ...` ] ) ] ).
%=========================================================================================
i_line_rule( it_ceu_first_line, [ 
%=========================================================================================
	
	  some_num(d), tab
	   
	, a_date(date), tab
	
	, a_num(f( [ q(dec,1,1) ] ) ), newline
	
	, trace( [ `done first line` ] )
	
] ).

%=========================================================================================
i_line_rule( it_ceu_second_line, [ 
%=========================================================================================
	
	  a_letter( f( [ q(alpha,1,1) ] ) ), tab

	, some_numbers(d), newline
	
] ).

%=========================================================================================
i_rule( it_fpt_rule, [
%=========================================================================================

	  it_fpt_first_line
	
	, or( [
	
		it_fpt_second_line
		
		, [ q(0,20,line), generic_line( [ check_text( `POSCODICEDESCRIZIONEUMQUANTITAUMAQUANTITAAPREZZOUNITARIOSCONTI` ) ] ) ]

	] )
	
	, set( chain, `it fpt industrie` ), trace( [ `IT FPT INDUSTRIE ...` ] )
	
] ).

%=========================================================================================
i_line_rule( it_fpt_first_line, [ 
%=========================================================================================
	
	  q10( [ some_num(f([q(dec("2"),1,1), q(dec("0"),1,1), q(dec("1"),1,1), q(dec,1,1) ] ) )

		, `-`, num(d), `-`, word, tab
		
	] )

	, `Spett`, `.`, `le`, newline
	
	, trace( [ `done first line` ] )
	
] ).

%=========================================================================================
i_line_rule( it_fpt_second_line, [ 
%=========================================================================================
	
	  read_ahead( `HILTI` ), hilti(w), `ITALIA`, `SPA`

	, check( hilti(start) > 0 )
	
	, check( hilti(y) > -415 )
	
	, check( hilti(y) < -405 )
	
] ).

%=========================================================================================
i_line_rule( it_tecnelit_line, [ 
%=========================================================================================
	
	  `NUMERO`, tab, `COMMESSA`, `N`, `:`
	  
	, set( chain, `it tecnelit` )
	
	, trace( [ `IT TECNELIT ...` ] )
	
] ).

%=========================================================================================
i_rule( briggs_and_forrester_rule, [ 
%=========================================================================================
	
	  or( [ [ q(2,2, generic_line( [ [ dummy(s1), tab, some(date), newline, check( dummy(start) > 100 ), check( dummy(end) < 250 ) ] ] ) ) ]
		
		, check( q_sys_sub_string( From_L, _, _, `@briggs.uk.com` ) )
		
	] )
	
	, set( chain, `gb briggs and forrester` )
	
	, trace( [ `GB BRIGGS & FORRESTER ...` ] )
	
] ):- i_mail( from, From ), string_to_lower( From, From_L ).

%=========================================================================================
i_rule( from_domain_rule, [ 
%=========================================================================================
	
	  check( q_sys_sub_string( From_L, _, _, `@lk-uk.com` ) ), set( chain, `lionweld kennedy` ), trace( [ `LIONWELD KENNEDY (from Domain) ...` ] )
	
] ):- i_mail( from, From ), string_to_lower( From, From_L ).

%=========================================================================================
i_rule( gb_already_hire_rule, [
%=========================================================================================
	
	generic_line( [ [ `Order`, `No`, `:` ] ] )
	
	, generic_line( [ [ `PURCHASE`, `ORDER`, newline ] ] )
	
	, generic_line( [ [ `Supplier`, `:`, tab ] ] )

	, set( chain, `gb already hire` )
	
	, trace( [ `GB ALREADY HIRE ...` ] )
	
] ).

%=========================================================================================
i_rule( ch_debrunner_rule, [
%=========================================================================================
	
	generic_horizontal_details( [ [ `Bestellung`, newline ] ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	, generic_line( [ [ nearest( generic_hook(start), 10, 10 ), `Kunden`, `-`, `Nr`, `.`, `:` ] ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	, generic_line( [ [ nearest( generic_hook(start), 10, 10 ), `Von` ] ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	, generic_line( [ [ nearest( generic_hook(start), 10, 10 ), `An`, `:` ] ] )

	, set( chain, `ch debrunner` )
	
	, trace( [ `CH DEBRUNNER ...` ] )
	
] ).

%=========================================================================================
i_rule( crown_house_alternate_id_rule, [
%=========================================================================================
	
	generic_line( [ check_text( `SUPPLIERDETAILSINVOICETOORDERNo` ) ] )
	
	, generic_line( [ check_text( `Hilti(GB)LimitedSECTOR` ) ] )

	, set(chain, `crown house hilti`)
	
	, trace([`CROWN HOUSE ...`])
	
] ).


%=========================================================================================
i_line_rule( de_popp_lauser_line_one, [ a(s1), tab, `*`, `*`, `*`, tab, `B`, `E`, `S`, `T`, `E`, `L`, `L`, `U`, `N`, `G`, tab, `*`, `*`, `*`,  newline ] ).
%=========================================================================================
i_line_rule( de_popp_lauser_dash_line, [ `-`, `-`, `-`, `-` ] ).
%=========================================================================================
i_rule( de_popp_lauser_rule, [
%=========================================================================================
	
	de_popp_lauser_line_one
	
	, q(0,4,line)
	
	, de_popp_lauser_dash_line
	
	, generic_line( [ [ `Bitte`, `stets`, `angeben` ] ] )
	
	, de_popp_lauser_dash_line
	
	, set( chain, `de popp lauser` )
	
	, trace( [ `POPP LAUSER ...` ] )
	
] ).

%=========================================================================================
i_rule( at_fill_gesellschaft_rule, [
%=========================================================================================
	
	q0n(line)
	
	, generic_line( [ check_text( `PosMengeMEArtikelnrLieferterminEinzelpreisjeMengeMEGesamtpreis` ) ] )
	
	, generic_line( [ check_text( `UTNrBezeichnungeintreffendEUREUR` ) ] )

	, set(chain, `at fill gesellschaft`)
	
	, trace([`AT FILL GESELLSCHAFT ...`])
	
] ).

%=========================================================================================
i_rule( linde_gas_rule, [
%=========================================================================================
	
	generic_line( [ check_text( `Bestellung` ) ] )
	
	, q0n(line)
	
	, generic_line( [ check_text( `LindeGas` ) ] )

	, set(chain, `lindegas`), trace([`LINDEGAS...`])
	
] ).

%=========================================================================================
i_rule( de_linde_rule, [
%=========================================================================================
	
	peek_fails( generic_line( [ check_text( `Bestellung` ) ] ) )
	
	, q0n(line)
	
	, generic_line( [ check_text( `LindeGas` ) ] )
	
	, set(chain, `de linde` ), trace([`LINDE ...`])
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FR SIAPOC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_rule( fr_siapoc_rule, [
%=========================================================================================
	
	generic_line( [ [ q0n( [ dummy(s1), tab ] ), `BON`, `DE`, `COMMANDE` ] ] )
	
	, q(0,5,line), generic_line( [ [ `N`, `°`, `de`, `commande`, `:` ] ] )
	
	, q(0,2,line), generic_line( [ [ `Code`, `fournisseur` ] ] )
	
	, q(0,2,line), generic_line( [ [ `Référence` ] ] )
	
	, q(0,2,line), generic_line( [ [ `Expéditeur` ] ] )
	
	, set( chain, `fr siapoc` )
	, trace( [ `FR SIAPOC - VIA STRUCTURE` ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% US BIG D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_rule( us_big_d_rule, [
%=========================================================================================
	
	q(0,20,line)
	
	, generic_line( [ check_text( `SUPPLIERNOSUPPLIERCONTACTSHIPTOCONTACTBUYER` ) ] )
	
	, q(0,7,line)
	
	, generic_line( [ check_text( `LINEQUANTITYUOMPRODUCTCODEandDESCRIPTIONREQUIREDDATEUNITPRICEAMOUNT` ) ] )
	
	, set( chain, `us big d tool center` )
	, trace( [ `US BIG D TOOL CENTER` ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IT STANDARD TECH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_rule( it_standard_tech_rule, [
%=========================================================================================
	
	q(0,20,line)
	
	, generic_line( [ check_text( `ORDINEDIACQUISTO` ) ] )
	
	, generic_line( [ check_text( `Data` ) ] )
	
	, generic_line( [ check_text( `Rifcomm` ) ] )
	
	, set( chain, `it standard tech` )
	, set(re_extract)
	, trace( [ `IT STANDARD TECH` ] )
	
] ).
