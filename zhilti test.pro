%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ZHILTI TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( zhilti_test, `30 June 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_pdf_parameter( max_pages, 1 )
:- 
	i_mail( subject, Sub ),
	trace( subject( Sub ) ),
	string_to_lower( Sub, SubL ),
	q_sys_sub_string( SubL, _, _, `macon` ),
	trace( `Sub completed` )
	
	;	i_mail( from, From ),
		trace( from( From ) ),
		string_to_lower( From, FromL ),
		q_sys_sub_string( FromL, _, _, `@maconsupply.net` ),
		trace( `From completed` )
.

i_pdf_parameter( max_pages, 20 ).

i_page_split_rule_list( [ set(chain,`unrecognised`), select_buyer] ).

%=======================================================================
i_no_lines_rule( encryption_error, Error_atom_in, Description_in, Error_atom_in, Description_in )
:- q_sys_sub_string( Description_in, _, _, `Unsupported encryption` ).
%=======================================================================
i_rule( encryption_error, [set( chain, `zhilti encryption error chain` ), trace( [ `UNSUPPORTED ENCRYPTION ERROR` ] ), set( re_extract ) ] ).
%=======================================================================

%=======================================================================
i_rule( select_buyer, [ 
%=======================================================================

	or( [ first_line_identifications_rule
	
		, junk_hoerlemann_attachments
	
		, i_mail_check_rule
	
		, body_identification

		, [ q0n(line), check_text_identification_line ]
	
		, [ q0n(line), buyer_id_line ]
	
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	FIRST LINE IDENTIFICATION
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
		
		, us_bechtel_rule
		
		, briggs_and_forrester_rule
		
		, de_popp_lauser_rule
		
		, ch_debrunner_rule
		
		, gb_already_hire_rule
		
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
		
		, [ check( q_sys_sub_string( From_L, _, _, `@capforminc.com` ) ), set( chain, `us capform` ), trace( [ `CAPFORM ...` ] ) ]
		
	] )
	
] )
:-
	i_mail( subject, Sub ),
	string_to_lower( Sub, Sub_L ),
	i_mail( from, From ),
	string_to_lower( From, From_L )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BODY IDENTIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ID LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( buyer_id_line, [
%=======================================================================

	q0n(anything)

	, or([

		[ `chep`, set(chain, `GB-CHEP`), trace([`CHEP ...`])  ]

		, [ `speedy`, q0n(anything), `limited`, set(chain, `GB-SPEEDY`), trace([`SPEEDY ...`])  ]

		, [ `network`,`rail`, set(chain, `GB-NWKRAIL`), trace([`NETWORK RAIL ...`])  ]

		, [ `harsco`,`infrastructure`, set(chain, `GB-HARSCO TEST`), trace([`HARSCO ...`])  ]

		, [ `afl`,set(chain, `US-AFL`), trace([`AFL ...`])  ]

		, [ `controlmatic`,set(chain, `DE-VINCI`), trace([`VINCI ...`])  ]
		, [ `ekorg`,set(chain, `DE-VINCI`), trace([`VINCI ...`])  ]

		, [ `pederzani`,set(chain, `pederzani`), trace([`PEDERZANI ...`])  ]

		, [ `doclink`, `.`, `tradex`, set(chain, `tradex`), trace([`TRADEX ...`])  ]

		, [ `ameon`, `limited`, set(chain, `ameon`), trace([`AMEON ...`])  ]

		, [ `stahlbau`, `pichler`, set(chain, `stahlbau pichler`), trace([`STALBAU PICHER ...`])  ]

		, [ `pos`, tab, `articolo`, tab, `descrizione`, tab, set(chain, `termigas`), trace([`TERMIGAS ...`])  ]

		, [ `brandon`, `hire`, set(chain, `gb-brandon test`), trace([`BRANDON HIRE ...`])  ]

		, [ `Bellotto`, or([ `Impianti`, `general`]), set(chain, `bellotto test`), trace([`BELLOTTO...`])  ]

		, [ `Frigoveneta`, set(chain, `frigoveneta`), trace([`FRIGOVENETA...`])  ]

		, [ `mascopurchasing`, set(chain, `masco test`), trace([`MASCO...`]), set( re_extract )  ]
		, [ `masco`, set(chain, `masco test`), trace([`MASCO...`]), set( re_extract )  ]
		, [ `fob`, tab, `supplier`, `contact`, set(chain, `masco test`), trace([`MASCO...`]), set( re_extract )  ]

		, [ `umdasch`,  set(chain, `umdasch`), trace([`UMDASCH GROUP...`])  ]

		, [ `cpl`, `concordia`, set(chain, `cpl concordia`), trace([`CPL CONCORDIA...`])  ]

		, [ `alusommer`, set(chain, `alusommer`), trace([`ALUSOMMER...`])  ]

		, [ `BABAK`, `GEBÄUDETECHNIK`, set(chain, `babak test`), trace([`BABAK...`])  ]

		, [ `Bacon`, `Gebudetechnik`, `GmbH`, set(chain, `bacon hilti`), trace([`BACON...`])  ]
		, [ `Bacon`, `.`, `at`, set(chain, `bacon hilti`), trace([`BACON...`])  ]
		, [ `Ordernummer`, `immer`, `anführen`, `!`,  newline, set(chain, `bacon hilti`), trace([`BACON...`])  ]
	
		, [ `ATZWANGER`, `AG`, `SPA`, set(chain, `atzwanger`), trace([`ATZWANGER...`])  ]

		, [ `SCHMIDHAMMER`, `SRL`, set(chain, `schmidhammer`), trace([`SCHMIDHAMMER...`])  ]

		, [ `ospelt`, set(chain, `ospelt test`), trace([`OSPELT...`])  ]

		, [ `Items`, `highlighted`, `grey`, `will`, `be`, `dispatched`, set(chain, `interserve call off test`), trace([`INTERSERVE CALL OFF...`])  ]
		, [ `VAT`, `No`, `.`, `-`, `527`, `218`, `256`, set(chain, `interserve`), trace([`INTERSERVE...`])  ]
		, [ `VAT`, `No`, `.`, `-`, `527`, `2182`, `56`, set(chain, `interserve`), trace([`INTERSERVE...`])  ]
		, [ `Areas`, `shaded`, `red`, `are`, `mandatory`, `and`, `areas`, `shaded`, `grey`, `are`, `optional`, `.`, newline, set(chain, `interserve firm order test`), trace([`INTERSERVE FIRM ORDER...`])  ]

		, [ `company`, q0n(anything), `type`, `standard`, `purchase`, `order`, newline, set(chain, `masco test`), trace([`MASCO...`]), set( re_extract )  ]

		, [ `EINKAUFSBEDINGUNGEN`, `BABAK`, set(chain, `hilti ignore`), trace([`BABAK T&C ...`])  ]

		, [ `FRENER`, `&`, `REIFER`, set(chain, `frener`), trace([`FRENER & REIFER...`])  ]

		, [ `Dönges`, `GmbH`, `&`, `Co`, set(chain, `donges`), trace([`DONGES...`])  ]

		, [ `Berliner`, `Wasserbetriebe`, set(chain, `bwb test`), trace([`BWB...`])  ]

		, [ `fill`, `metallbau`, set(chain, `fill`), trace([`FILL...`])  ]

		, [ `www`, `.`, `lonza`, `.`, `com`, set(chain, `lonza`), trace([`LONZA...`])  ]

		, [ `Item`, `/`, `Mfg`, `Number`, tab, `Due`, `Date`, `Order`, `Qty`, `U`, `/`, `M`, tab, `Unit`, `Cost`, `U`, `/`, `M`, `Tax`, tab, `Total`,  newline, set(chain, `terminix`), trace([`TERMINIX...`])  ]

		, [ `Potash`, `Corporation`, set(chain, `pcs`), trace([`PCS ...`])  ]

		, [ `Telamon`, set(chain, `telamon`), trace([`TELAMON...`])  ]
		
		, [ `Ludwig`, `BRANDSTÄTTER`, `Betriebs`, set(chain, `brandstaetter`), trace([`BRANDSTAETTER...`])  ]

		, [ `evg`, `entwicklungs`, set(chain, `evg`), trace([`EVG...`])  ]

		, [ `Pos`, `Artikel`, tab, `Menge`, `Meh`, tab, `Einzelpreis`, `Rabatt`, `MWST`, `EUR`, `-`, `Betrag`,  newline, set(chain, `kappa`), trace([`KAPPA...`])  ]

		, [ `Gemäß`, `unseren`, `Ihnen`, `bekannten`, `Bedingungen`, `bestellen`, `wir`, `:`,  newline, set(chain, `huber`), trace([`HUBER...`])  ]

		, [ `boulons`, `manic`, set(chain, `boulons manic`), trace([`BOULONS MANIC...`])  ]

		, [ `FOCCHI`, `S`, `.`, `p`, `.`, `a`, `.`, set(chain, `focchi`), trace([`FOCCHI...`]), set( re_extract ) ]

		, [ `Tata`, `Steel`, `UK`, `Limited`, set(chain, `tata uk`), trace([`TATA STEEL...`])  ]

		, [ `Carrier`, `Kältetechnik`, `Austria`, set(chain, `carrier`), trace([`CARRIER...`])  ]

		, [ `Doppelmayr`, `Seilbahnen`, `GmbH`, set(chain, `doppelmayr`), trace([`DOPPELMAYR...`])  ]

		, [ `schindler`, newline, set(chain, `schindler`), trace([`SCHINDLER...`])  ]

		, [ `pro`, `steel`, set(chain, `prosteel`), trace([`PROSTEEL...`])  ]
		
		, [ `PosNr`, `ArtikelNr`, `.`, tab, `Artikelbezeichnung`, tab, `Lieferdatum`, tab, `Menge`, tab, `EinzPr`, `/`, `Ntto`, tab, `Netto`, `/`, `Pos`,  newline, set(chain, `gig`), trace([`GIG...`])  ]

		, [ `firm`, `order`,  newline, set(chain, `firm order`), trace([`FIRM ...`])  ]

		, [ `knapp`, set(chain, `knapp`), trace([`KNAPP...`])  ]

 		, [`671`, `4344`, `39`, set(chain, `babcock rail`), trace([`BABCOCK...`]) ]

		, [ `unipart`, `rail`, `limited`, set(chain, `unipart rail`), trace([`UNIPART...`]) ]

		, [ `DIVISIONE`, `MECCANICA`, `-`, `Tel`, `:`, `030`, `.`, `9400001`, `Fax`, `:`, `030`, `.`, `9400026`,  newline, set(chain, `impianti`), trace([`IMPIANTI...`]) ]

		, [ `NOTA`, `:`, `COPIA`, `DEL`, `PRESENTE`, `ORDINE`, `VA`, `RESTITUITA`, `FIRMATA`, `PER`, `ACCETTAZIONE`,  newline, set(chain, `impianti`), trace([`IMPIANTI...`]) ]

		, [ `Code`, `TCI`, tab, `Description`, tab, set(chain, `translec`), trace([`TRANSLEC...`]) ]

		, [ `ONI`, `-`, `Wärmetrafo`, `GmbH`, set(chain, `oni`), trace([`ONI...`]) ]

		, [ `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `RECHNUNGSFAKTURA`, `AN`, `EXPERT`, `-`, `LANGENHAGEN`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`,  newline, set(chain, `heldele`), trace([`HELDELE...`]) ]

		, [ `PMS`, `Elektro`, `-`, `und`, `Automationstechnik`, set(chain, `pms`), trace([`PMS ELEKTRO...`]) ]

		, [ `CE`, `NUMÉRO`, `DOIT`, `PARAÎTRE`, `SUR`, set(chain, `stm`), trace([`STM...`]) ]

		, [ `propak`, `systems`, set(chain, `propak`), trace([`PROPAK...`]) ]

		, [ `Skanska`, `USA`, `Civil`, `Northeast`,  newline, set(chain, `skanska`), trace([`SKANSKA...`]) ]

		, [ `MODULBLOK`, `SPA`, tab, `N`, `:`, `movimento`, set(chain, `modulblok`), trace([`MODULBLOK...`]) ]

		, [ `@`, `fabbrovanni`, `.`, `com`,  newline, set(chain, `fabbro vanni`), trace([`FABBRO VANNI...`]) ]

		, [ `Gebr`, `.`, `Knuf`,  newline, set(chain, `knuf`), trace([`KNUFF...`])  ]

		, [ `@`, `roche`, `.`, `com`,  newline, set(chain, `la roche`), trace([`LA ROCHE...`])  ]

		, [ `Köb`, `Holzheizsysteme`, `GmbH`, set(chain, `koeb`), trace([`KOEB...`])  ]

		, [ or([ [`Heidenbauer`, `Industriebau`, `GmbH`], [`Metallbau`, `Heidenbauer`, `GmbH`, `&`, `Co`, `KG`] ]), newline, set(chain, `heidenbauer`), trace([`HEIDENBAUER...`])  ]

		, [  `Item`, `Description`, tab, `Catalogue`, `No`, tab, `Order`, `Qty`, tab, set(chain, `he simm po`), trace([`HE SIMM PO...`]) ] 

		, [ `SchwörerHaus`, `KG`, `·`, `Hans`, set(chain, `schworer`), trace([`SCHWORER...`])  ]

		, [ `claas`, set(chain, `claas`), trace([`CLAAS...`])  ]

		, [ `Références`, `à`, `rappeler`, `sur`, `toute`, `correspondance`, q10( `:` ),  newline, set(chain, `distrimo`), trace([`DISTRIMO...`])  ]

		, [ `ATTENZIONE`, `:`, `NON`, `SI`, `ACCETTANO`, `FORNITURE`, `O`, `PRESTAZIONI`, `SENZA`, `ORDINE`, `SCRITTO`, `.`, tab, `CONSEGNA`, tab, `FRANCO`, tab, `MEZZO`,  newline, set(chain, `ed impianti`), trace([`ED IMPIANTI...`])  ]

		, [ `gb`, `-`, `horbury`, set(chain, `horbury`), trace([`HORBURY...`])  ]

		, [ `otis`, set(chain, `otis`), trace([`OTIS...`])  ]
	
		, [ `(`, `01604`, `)`, `752424`, set(chain, `travis perkins (hilti)`), trace([`TRAVIS PERKINS (HILTI)`]), set( re_extract ) ]
		
		, [ or( [ [ `IT`, `00120730213` ], [ `IT00120730213` ] ] ), set(chain, `elpo`), trace([`ELPO...`]) ]
		
		, [ `INDICARE`, `IN`, `BOLLA`, `IL`, `NUMERO`, `DELL`, `'`, `ORDINE`, set(chain, `drusian`), trace([`DRUSIAN...`]) ]
		
		, [ `709`, `-`, `748`, `-`, `7502`, set(chain, `kbac`), trace([`KBAC...`]) ]
		
		, [ `info`, `@`, `breburltd`, `.`, `co`, `.`, `uk`, set(chain, `brebur`), trace([`BREBUR...`]) ]
		
		, [ `Pos`, tab, `Item`, `number`, tab, `Item`, `name`, tab, `Quantity`, tab, `U`, `/`, `M`, set(chain, `elekta`), trace([`ELEKTA...`]) ]
		
		, [ `label`, `line`, `1`, q10(tab), `HSS`, `Ecode`, q10( tab ), `Font`, `Size`, set( chain, `hss connectivity extended` ), trace( [ `HSS CONNECTIVITY EXTENDED...` ] ), set( re_extract ) ]
		
		, [ `HSS`, `Ecode`, q10( tab ), `Font`, `Size`, set( chain, `hss connectivity hilti` ), trace( [ `HSS CONNECTIVITY ...` ] ) ]
		
		, [ `Account`, tab, `20767630`,  newline, set( chain, `us-telect` ), trace( [ `US Telect - HILTI ...` ] ) ]
		
		, [ `LVD`, `Company`, `nv`, tab, set( chain, `lvd hilti` ), trace( [ `LVD BE - HILTI ...` ] ) ]
		
		
		
		
	
	] )
	
] ).

%=======================================================================
i_line_rule( check_text_identification_line, [
%=======================================================================

	  or( [

		  [ check_text( i_speedy_check ), set(chain, `GB-SPEEDY`), trace([`SPEEDY ...`]) ]

		,  [ or( [ check_text( `KokosingConstructionCompany` ), check_text( `kccsupply` ) ] ), set(chain, `kokosing`), trace([`KOKOSING...`]), set( re_extract ) ]

		, [ check_text(`GIGFassadenGmbH`),  set(chain, `gig`), trace([`GIG...`])  ]
		, [ check_text(`GIGService`),  set(chain, `gig`), trace([`GIG...`])  ]
		, [ check_text(`PosNrArtikelNrArtikelbezeichnung`),  set(chain, `gig`), trace([`GIG...`])  ]

		, [ check_text(`TCIProduct`), set(chain, `translec`), trace([`TRANSLEC...`]) ]

		, [ `Call`, `Off`, `Order`,  newline, set(chain, `he_simm`), trace([`HE SIMM...`])  ]
	
		, [ check_text( `travisperkinstradingco+` ),set(chain, `travis perkins (tradacom)`), trace([`TP TRADACOM ...`]) ]
		
		, [ check_text( `commercialspring&toolco` ), set(chain, `cst`), trace([`CST...`]) ]
		
%		, [ check_text( `wwwbasdaorg` ), set(chain, `kier order (hilti) edi`), trace([`KIER ORDER EDI ...`]) ]
		
		, [ check_text( `info@mercuryie` ), set(chain, `mercury`), trace([`MERCURY ...`]) ]
		
		, [ check_text( `giugliano` ), set(chain, `it giugliano`), trace([`IT GIUGLIANO ...`]) ]
		
		, [ check_text( `johnsoncontrols` ), set(chain, `ch johnson controls`), trace([`CH JOHNSON CONTROLS ...`]) ]
		
		, [ check_text( `alstomgridag` ), set(chain, `ch alstom`), trace([`CH ALSTOM ...`]) ]
		
		, [ check_text( `pleasesupplyanddespatchinaccordancewiththefollowing` ), set(chain, `intelligent order form (hilti)`), trace([`INTELLIGENT ORDER FORM (HILTI) ...`]) ]
		
		, [ check_text( `@tozziholdingcom` ), set(chain, `tozzi`), trace([`TOZZI ...`]) ]
		
		, [ check_text( `konegmbh` ), set(chain, `kone`), trace([`KONE ...`]) ]
		, [ check_text( `KONESABondeCommande` ), set(chain, `kone fr`), trace([`KONE FR ...`]) ]

		, [ check_text( `clementsupportservicesinc` ), set(chain, `us clement`), trace([`US CLEMENT ...`]) ]
		
		, [ check_text( `N°DésignationQuantitéUnitéPU%Montant` ), set(chain, `morand`), trace([`MORAND ...`]) ]
		
		, [ check_text( `>Bailey` ), set(chain, `baileys limited`), trace([`BAILEY LIMITED ...`]), set( re_extract ) ]
		
%		, [ check_text( `hil001/1` ), set(chain, `kier order (hilti) edi`), trace([`KIER ...`]) ]

		, [ check_text( `No644490` ), set(chain, `hss hire hilti`), trace([`HSS HIRE HILTI ...`]) ]

		, [ check_text( `nissanmotor` ), set(chain, `nissan hilti`), trace([`NISSAN HILTI ...`]) ]
		
		, [ check_text( `a&teuropespa` ), set(chain, `it a&t`), trace([`IT A&T ...`]) ]
	
		, [ check_text( `termsofpaymentforlionweld` ), set(chain, `lionweld kennedy`), trace([`LIONWELD KENNEDY ...`]) ]

		, [ check_text( `alpiqintecmilanospa` ), set(chain, `it alpiq`), trace([`IT  ALPIQ ...`]) ]
		
		, [ check_text( `meiser` ), set(chain, `meiser`), trace([`MEISER ...`]) ]
		
		, [ check_text( `metalsistem` ), set(chain, `it metalsistem`), trace([`IT METALSISTEM ...`]) ]
		
		, [ check_text( `rigacodicearticolo/descrizioneqtàumimportoimportodatacons` ), set(chain, `it rivoira`), trace([`IT RIVOIRA ...`]) ]
		
		, [ check_text( `enermech` ), set(chain, `enermech hilti`), trace([`ENERMECH HILTI ...`]) ]
		
		, [ check_text( `thyssenkrupp` ), set(chain, `fr thyssenkrupp`), trace([`FR THYSSENKRUPP ...`]) ]
		
		, [ check_text( `petrofac` ), set(chain, `petrofac hilti`), trace([`PETROFAC ...`]) ]
		
		, [ check_text( `mcmullen` ), set(chain, `mcmullen hilti`), trace([`MCMULLEN ...`]) ]
		
		, [ check_text( `thermorefrigeration` ), set(chain, `fr thermo refrigeration`), trace([`FR THERMO REFRIGERATION ...`]) ]
	
		, [ check_text( `giennoise` ), set(chain, `fr giennoise` ), trace([`FR GIENNOISE ...`]) ]

		, [ check_text( `aeml@aemlfr` ), set(chain, `fr aeml` ), trace([`FR AEML ...`]) ]
	
		, [ check_text( `simem` ), set(chain, `it simem` ), trace([`IT SIMEM ...`]) ]

		, [ check_text( `VsriferimentoCodiceTelefonoFaxPartitaIVACodiceFiscale` ), set(chain, `it cesare fumagalli` ), trace([`IT CESARE FUMAGALLI ...`]) ]
		
		, [ check_text( `wwwhuberde` ), set(chain, `de huber` ), trace([`DE HUBER ...`]) ]

		, [ check_text( `geaprocomacspa` ), set(chain, `it gea` ), trace([`IT GEA ...`]) ]
		
		, [ check_text( `ValutaVsCodFornitoreRevisioneordineDatarevisioneordineRiferimentofornitore` ), set(chain, `it garbuio` ), trace([`IT GARBUIO ...`]) ]
	
		, [ check_text( `conergy` ), set(chain, `it conergy` ), trace([`IT CONERGY ...`]) ]
		
		, [ check_text( `gb-amco` ), set( chain, `amco order form hilti` ), trace( [ `AMCO ORDER FORM ...` ] ) ]
		
		, [ check_text( `modulblok` ), set( chain, `modulblok` ), trace( [ `MODULBLOK ...` ] ) ]
	
		, [ or( [ check_text( `@fifegovuk` ), check_text( `fife` ) ] ), set( chain, `fife council` ), trace( [ `FIFE COUNCIL ...` ] ) ]
	
		, [ check_text( `@teckcom` ), set( chain, `teck metals` ), trace( [ `TECK METALS ...` ] ) ]
		
		, [ check_text( `@sematic` ), set( chain, `it sematic` ), trace( [ `SEMATIC ...` ] ) ]
		
		, [ check_text( `@siti-btcom` ), set( chain, `it siti` ), trace( [ `SITI ...` ] ) ]
		
		, [ or( [ check_text( `konespaordinediacquisto` ), check_text( `konespapurchaseorder` ) ] ), set( chain, `it kone` ), trace( [ `IT KONE ...` ] ) ]
		
		, [ check_text( `premierelectric` ), set( chain, `premier electric hilti` ), trace( [ `PREMIER ELECTRICS ...` ] ) ]
		
		, [ check_text( `kontech` ), set( chain, `dk kontech` ), trace( [ `DK KONTECH ...` ] ) ]

		, [ check_text( `mortenson` ), set(chain, `mortenson`), trace([`MORTENSON...`])  ]
	
		, [ or( [ check_text( `formulaone` ), check_text( `vatnumber997337752` ) ] ), set(chain, `formula one hilti`), trace([`FORMULA ONE...`])  ]

		, [ check_text( `rubaxlift` ), set(chain, `rubax lifts hilti`), trace([`RUBAX LIFTS ...`]), set( re_extract ) ]

		, [ check_text( `WirbestellenzudenBedingungendieserBestellungfolgendeArtikel` ), set(chain, `lohr`), trace([`LOHR...`])  ]

		, [ check_text( `voelklcoat` ), set(chain, `voelkl`), trace([`VOELKL...`]) ]
		
		, [ check_text( `jacobsles` ), set(chain, `jacobs hilti`), trace([`JACOBS ...`]) ]
	
		, [ check_text( `petercoxltd` ), set(chain, `peter cox hilti`), trace([`PETER COX ...`]) ]
	
		, [ or( [ check_text( `CHE-102909703MWST` )
		
				, check_text( `SchweizerischeBundesbahnenSBB` )
				
			] ), set(chain, `ch sbb`), trace([`CH SBB ...`]) 
			
		]
	
		, [ check_text( `wellheadelectricalsupplies` ), set(chain, `wellhead electrical supplies`), trace([`WELLHEAD ELECTRICAL ...`]) ]
		
		, [ or( [ check_text( `plasteringcontractors` ), check_text( `stanmorecontractors` ) ] ), set(chain, `stanmore plastering hilti`), trace([`STANMORE PLASTERING ...`]) ]
			
		, [ check_text( `leongrosse` ), set(chain, `fr leongrosse`), trace([`FR LEONGROSSE ...`]) ]
		
		, [ or( [ check_text( `fabcon-usa` )
				, check_text( `LineYourPartNoYourDescriptionDockQtyDueQuantityUnitPriceDelDatePartRevision` )
			] )
			, set(chain, `us fabcon`), trace([`US FABCON ...`]) 
		]

		, [ check_text( `auerat` ), set(chain, `at auer`), trace([`AT AUER ...`]) ]

		, [ check_text( `voestalpine` ), set(chain, `at voest`), trace([`AT VOEST ...`]) ]
	
		, [ check_text( `stewartmilne` ), set(chain, `stewart milne hilti`), trace([`STEWART MILNE ...`]) ]
			
		, [ check_text( `truevalue` ), set(chain, `us true value`), trace([`US TRUE VALUE ...`]) ]
		
		, [ check_text( `macleancouk` ), set(chain, `maclean electrical hilti`), trace([`MACLEAN ELECTRICAL ...`]) ]

		, [ check_text( `landispa` ), set(chain, `it landi`), trace([`IT LANDI ...`]) ]

		, [ check_text( `chgudel` ), set(chain, `ch guedel`), trace([`CH GUDEL ...`]) ]

		, [ check_text( `unionengineering` ), set(chain, `dk union engineering`), trace([`DK UNION ENGINEERING ...`]) ]

		, [ check_text( `Ruhrverband` ), set(chain, `de ruhrverband`), trace([`DE RUHRVERBAND ...`]) ]

		, [ check_text( `manchesterairport` ), set(chain, `manchester airport hilti`), trace([`MANCHESTER AIRPORT ...`]) ]
		
		, [ check_text( `banconconstruction` ), set(chain, `bancon`), trace([`BANCON ...`]) ]
		
		, [ check_text( `gb440289653` ), set(chain, `bobst hilti`), trace([`BOBST ...`]) ]
		
		, [ check_text( `arthurmckaybuilding` ), set(chain, `arthur mckay`), trace([`ARTHUR MCKAY ...`]) ]
		
		, [ check_text( `tubelineslimited` ), set(chain, `tubelines hilti`), trace([`TUBELINES ...`]) ]
		
		, [ check_text( `tel02083096699fax` ), set(chain, `imperial duct hilti`), trace([`IMPERIAL DUCT ...`]) ]
		
		, [ check_text( `westernpowerdistribution` ), set(chain, `western power hilti`), trace([`WESTERN POWER ...`]) ]
		
		, [ check_text( `crownhousetechnologiesltd` ), set(chain, `crown house hilti`), trace([`CROWN HOUSE ...`]) ]
		
		, [ check_text( `756277008` ), set(re_extract), set(chain, `london ug bcv hilti`), trace([`LONDON UG BCV ...`]) ]
		
		, [ check_text( `caverion` ), set(chain, `at caverion`), trace([`AT CAVERION ...`]) ]
		
		, [ check_text( `hennecke` ), set(chain, `de hennecke`), trace([`DE HENNECKE ...`]) ]
		
		, [ check_text( `chapcivilengineering` ), set(chain, `chap civils hilti`), trace([`CHAP CIVILS ...`]) ]
		
		, [ check_text( `chapconstruction` ), set(chain, `chap construction hilti`), trace([`CHAP CONSTRUCTION ...`]) ]
		
		, [ check_text( `stenhøja/s` ), set(chain, `dk stenhoj`), trace([`STENHOJ ...`]) ]
		
		, [ check_text( `http//wwwpotashcorpcom/media/POT_North_American_PO_Terms_and_Conditionspdf` ), dummy(s1)
			
			, or( [ [ check( dummy(y) < 0 ), set( chain, `pcs` ), trace( [ `PCS ...` ] ) ]
			
				, [ check( dummy(y) > 0 ), set(chain, `ca pcs`), trace( [`CA PCS ...`] ) ]
				
			] )
			
		]
		
		, [ check_text( `oclfacades` ), set(chain, `ocl facades hilti`), trace([`OCL FACADES ...`]) ]

		, [ check_text( `deborahservicesltd` ), set(chain, `deborah services hilti`), trace([`DEBORAH SERVICES ...`]) ]

		, [ check_text( `ContenantdescriptionValiditéPrixUnitTotalHT` ), set(chain, `fr otis`), trace([`FR OTIS ...`]) ]

		, [ check_text( `johnndunngroup` ), set(chain, `john n dunn hilti`), trace([`JOHN N DUNN ...`]) ]

		, [ check_text( `vallectric` ), set(chain, `vallectric hilti`), trace([`VALLECTRIC ...`]) ]

		, [ check_text( `jessellaltd` ), set(chain, `jessella limited hilti`), trace([`JESSELLA LTD ...`]), set( re_extract ) ]

		, [ check_text( `industrialpipingservice` ), set(chain, `de ips`), trace([`INDUSTRIAL PIPING SERVICE ...`]) ]

		, [ check_text( `IndustrialAcousticsCompany` ), set(chain, `industrial acoustics hilti`), trace([`INDUSTRIAL ACOUSTICS COMPANY ...`]), set( re_extract ) ]

		, [ check_text( `Kiewit` ), set(chain, `kiewit marketplace`), trace([`KMP ...`]) ]

		, [ check_text( `PARTITAIVAECODICEFISCALE00099440299-CAPITALESOCIALE` ), check_text( `17000000IV-REAROVIGOn72815-REGDELLEIMPRESEDIROVIGON00099440299` )
		
			, set(chain, `it guerrato`), trace([`IT GUERRATO ...`]) 
			
		]

		, [ check_text( `barrattnorthscotland` ), set(chain, `gb barratt north scotland`), trace([`BARRATT NORTH SCOTLAND ...`]) ]

		, [ check_text( `moraycouncil` ), set(chain, `gb moray council`), trace([`MORAY COUNCIL ...`]) ]

		, [ check_text( `elektalimited` ), set(chain, `gb elekta`), trace([`ELEKTA LIMITED ...`]) ]

		, [ or( [ check_text( `konebelgiumsa` )
		
				, check_text( `sakonebelgium` )
				
			] ), set(chain, `be kone`), trace([`BE KONE ...`]) 
			
		]
		
		, [ check_text( `<party>Kier` ), set(chain, `kier order (hilti) edi`), trace([`KIER ORDER HILTI ...`]) ]

		, [ check_text( `cplheatingandplumbing` ), set(chain, `gb cpl heating & plumbing`), trace([`CPL HEATING & PLUMBING ...`]) ]

		, [ check_text( `brandenergy&infrastructure` ), set(chain, `GB-HARSCO TEST`), trace([`HARSCO ...`])  ]
		
		, [ check_text( `FleetwoodArchitecturalAluminium` ), set(chain, `fleetwood architectural hilti`), trace([`FLEETWOOD ARCHITECTURAL ...`])  ]
		
		, [ check_text( `@costruireimpiantiit` ), set(chain, `it costruire impianti`), trace([`IT COSTRUIRE IMPIANTI ...`])  ]
		
		, [ or( [ check_text( `http//wwwlnecpt/qpe/marcacao/mandatos_tabela` )
		
				, check_text( `mota-engil` )
				
			] ), set(chain, `pt montaengil`), trace([`PT MONTAENGIL ...`])
		
		]

		, [ check_text( `o'halloran&o'brien` ), set(chain, `gb ohalloran and obrien`), trace([`O'HALLORAN & O'BRIEN ...`])  ]

		, [ check_text( `dawcolectric` ), set(chain, `ca dawcolectric`), trace([`CA DAWCOELECTRIC ...`])  ]

		, [ check_text( `(01604)752424` ), set(chain, `travis perkins (hilti)`), trace([`TRAVIS PERKINS (HILTI)`]), set( re_extract ) ]

		, [ check_text( `lindnerplc` ), set(chain, `gb lindner`), trace([`LINDNER ...`]) ]

		, [ check_text( `resologistique` ), set(chain, `fr reso logistique`), trace([`FR RESO LOGISTIQUE ...`]) ]
		
		, [ check_text( `87010221486` ), set(chain, `au thiess`), trace([`AU THIESS ...`]) ]
		
		, [ check_text( `BOUYGUESUK` ), set(chain, `gb bouygues uk`), trace([`GB BOUYGUES UK ...`]), set( re_extract ) ]
		
		, [ check_text( `selectplanthire` ), set(chain, `gb select plant hire`), trace([`GB SELECT PLANT HIRE ...`]), set( re_extract ) ]
		
		, [ check_text( `northerncladdingltd` ), set(chain, `gb northern cladding`), trace([`GB NORTHERN CLADDING ...`]) ]

		, [ check_text( `northerncladding(york)` ), set(chain, `gb northern cladding york`), trace([`GB NORTHERN CLADDING YORK ...`]) ]
		
		, [ check_text( `HotchkissL` ), set(chain, `gb hotchkiss`), trace([`GB HOTCHKISS ...`]) ]
		
		, [ check_text( `expandedltd` ), set(chain, `gb expanded structures`), trace([`GB EXPANDED STRUCTURES ...`]) ]
		
		, [ check_text( `watkinsplumbing` ), set(chain, `gb watkins plumbing`), trace([`GB WATKINS PLUMBING ...`]), set( re_extract ) ]
		
		, [ check_text( `GB416706654` ), set(chain, `gb mitie`), trace([`GB MITIE ...`]) ]
		
		, [ check_text( `TUVUNIENISO90012000CertNr501004448` ), set(chain, `it sech`), trace([`IT SECH ...`]), set( re_extract ) ]
		
		, [ check_text( `strabagpropertyand` ), set(chain, `de strabag`), trace([`DE STRABAG ...`]) ]
		
		, [ check_text( `grippleltd` ), set(chain, `gb gripple`), trace([`GB GRIPPLE ...`]) ]
		
		, [ check_text( `dawnusconstruction` ), set(chain, `gb dawnus construction`), trace([`GB DAWNUS CONSTRUCTION ...`]) ]

		, [ check_text( `cms-escouk` ), set(chain, `gb cms enviro systems`), trace([`GB CMS ENVIRO SYSTEMS ...`]), set( re_extract ) ]

		, [ check_text( `erikscouk` ), set(chain, `gb eriks`), trace([`GB ERIKS ...`]) ]

		, [ check_text( `39009347399` ), set(chain, `au atom supply`), trace([`AU ATOM ...`]) ]

		, [ check_text( `DE251384104` ), set(chain, `de wolf`), trace([`DE WOLF ...`]), set( re_extract ) ]

		, [ check_text( `IE6543400W` ), set(chain, `gb techrete ireland`), trace([`GB TECHRETE ...`]) ]

		, [ check_text( `ABN98000893667` ), set(chain, `au leighton`), trace([`AU LEIGHTON ...`]) ]

		, [ check_text( `groundconstructionltd` ), set(chain, `gb ground construction`), trace([`GB GROUND CONSTRUCTION ...`]) ]

		, [ check_text( `01822610610` ), set(chain, `gb beacon comms`), trace([`GB BEACON COMMUNICATIONS ...`]) ]

		, [ check_text( `35107210248` ), set(chain, `au pilbara iron`), trace([`AU PILBARA IRON ...`]) ]
		
		, [ check_text( `@cskdk` ), set(chain, `dk csk`), trace([`DK CSK ...`]) ]
		
		, [ check_text( `146035291` ), set(chain, `gb tecalemit garage`), trace([`GB TECALEMIT GARAGE EQUIPMENT CO ...`]) ]
		
		, [ check_text( `KrämerLufttechnik` ), set(chain, `de kraemer`), trace([`DE KRAEMER LUFFTECHNIK ...`]), set( re_extract ) ]
		
		, [ check_text( `togaplanthireltd` ), set(chain, `gb toga plant hire`), trace([`GB TOGA PLANT HIRE ...`]) ]

		, [ or( [ check_text( `coiver` ), check_text( `Nonsonoautorizzatiaddebitiperspesediincassoe\\obancarie` ) ] )
			, set(chain, `coiver`), trace([`COIVER...`]) 
		]

		, [ check_text( `tclarke` ), set(chain, `gb t clarke`), trace([`T CLARKE...`])  ]

		, [ check_text( `226555264` ), set(chain, `gb clancy docwra`), trace([`CLANCY DOCWRA...`])  ]

		, [ check_text( `(09)2634747` ), set(chain, `be eandis`), trace([`EANDIS...`])  ]

		, [ check_text( `amecgroup` ), set(chain, `gb amec group`), trace([`AMEC GROUP...`])  ]

		, [ check_text( `seas-nve` ), set(chain, `dk seas nve`), trace([`SEAS-NVE...`])  ]

		, [ check_text( `88374614` ), set(chain, `dk valmont`), trace([`VALMONT...`])  ]

		, [ check_text( `eternitnv` ), set(chain, `be eternit`), trace([`ETERNIT...`])  ]
		
		, [ check_text( `vdab` ), set(chain, `be vdab`), trace([`V.D.A.B. ...`])  ]
		
		, [ check_text( `latechnique` ), set(chain, `be la technique`), trace([`LA TECHNIQUE ...`]) ]
		
		, [ check_text( `KouvolanPutkityöOy` ), set(chain, `fi kouvolan putkityo oy`), trace([`KOUVOLAN PUTKITYÖ OY ...`]) ]
		
		, [ check_text( `fastemsoy` ), set(chain, `fi fastems`), trace([`FASTEMS ...`]) ]
		
		, [ check_text( `151778156` ), set(chain, `gb smiths equipment hire`), trace([`SMITHS EQUIPMENT HIRE ...`]) ]
		
		, [ check_text( `GB700949834` ), set(chain, `gb hire station`), trace([`HIRE STATION ...`]) ]
		
		, [ check_text( `swarovskicom` ), set(chain, `at swarovski`), trace([`SWAROVSKI ...`]) ]
		
		, [ check_text( `umdaschshopfitting` ), set(chain, `at umdasch shopfitting`), trace([`UMDASCH SHOPFITTING ...`]) ]
		
		, [ check_text( `modebestbuilders` ), set(chain, `gb modebest builders`), trace([`MODEBEST BUILDERS ...`]) ]
		
		, [ check_text( `GB413633086` ), set(chain, `gb tyco fire solutions`), trace([`TYCO FIRE & INTEGRATE SOLUTIONS ...`]) ]
		
		, [ check_text( `catobau` ), set(chain, `at catobau`), trace([`CATOBAU ...`]) ]
		
		, [ check_text( `COPIADELPRESENTEORDINEDOVRA'ESSERERESACONTROFIRMATAPERACCETTAZIONE` ), set(chain, `it mit`), trace([`MIT ...`]) ]
	
		, [ check_text( `volvogroup` ), set(chain, `se volvo`), trace([`VOLVO ...`]) ]

		, [ check_text( `AteaA/S` ), set(chain, `dk atea`), trace([`ATEA ...`]) ]

		, [ check_text( `AntR/OArtikelnr/beskrivningPrisBelopp` ), set(chain, `se ramirent`), trace([`RAMIRENT ...`]) ]

		, [ check_text( `IE8D47240T` ), set(chain, `ie siac`), trace([`SIAC ...`]) ]

		, [ check_text( `890015538` ), set(chain, `gb sapphire balustrades`), trace([`SAPPHIRE BALUSTRADES ...`]) ]

		, [ check_text( `englisharchitecturalglazing` ), set(chain, `gb architectural glazing`), trace([`ARCHITECTURAL GLAZING ...`]) ]
		
		, [ check_text( `kleblbaulogistik` ), set(chain, `de klebl baulogistik`), trace([`KLEBL BAULOGISTIK ...`]) ]
		
		, [ check_text( `@handtmannde` ), set(chain, `de handtmann service`), trace([`HANDTMANN SERVICE ...`]) ]
		
		, [ check_text( `celticcontractors` ), set(chain, `gb celtic contractors`), trace([`CELTIC CONTRACTORS ...`]) ]
		
		, [ check_text( `truttmannag` ), set(chain, `ch truttmann`), trace([`TRUTTMANN ...`]) ]
	
		, [ check_text( `ETNFRANZCOLRUYT` ), set(chain, `be colruyt group`), trace([`BE COLRUYT GROUP ...`]) ]
		
		, [ check_text( `HerbsthoferGmbH` ), set(chain, `at herbsthofer`), trace([`AT HERBSTHOFER ...`]) ]
		
		, [ check_text( `zetabiopharma` ), set(chain, `at zeta biopharma`), trace([`ZETA BIOPHARMA ...`]) ]
		
		, [ check_text( `656204837` ), set(chain, `gb metallic fabrications`), trace([`METALLIC FABRICATIONS ...`]) ]
		
		, [ or( [ check_text( `beck-pollitzercom` ), check_text( `beck&pollitzer` ) ] )
			, set(chain, `gb beck and pollitzer`), trace([`BECK & POLLITZER ...`]) 
		]

		, [ check_text( `915771313` ), set(chain, `gb keepmoat regeneration (fhm)`), trace([`KEEPMOAT REGENERATION (FHM) ...`]) ]
		
		, [ check_text( `laingorourke` ), set(chain, `gb laing orourke`), trace([`LAING O'ROURKE CONSTRUCTION ...`]) ]

		, [ check_text( `dennertmassivhaus` ), set(chain, `de dennert massivhaus`), trace([`DENNERT MASSIVHAUS ...`]) ]

		, [ check_text( `DE126117135` ), set(chain, `de westfalen ag`), trace([`WESTFALEN AG ...`]) ]
		
		, [ check_text( `RAVATEPROFESSIONNEL` ), set(chain, `fr ravate professionnel`), trace([`RAVATE PROFESSIONNEL ...`]), set( re_extract ) ]
	
		, [ or( [ check_text( `821284350` ), check_text( `grahamsmithuk` ) ] ), set(chain, `gb graham smith`), trace([`GRAHAM SMITH ...`]) ]
	
		, [ check_text( `alstomgrid` ), set(chain, `fr alstom`), trace([`ALSTOM GRID ...`]) ]
	
		, [ or( [ check_text( `RéférenceQtéLibelléarticleQtéUnitéPUHT(Euros)TotalHT(Euros)` )
				, check_text( `Spiebatignolles` )
			] ), set(chain, `fr spie batignolles`), trace([`SPIE BATIGNOLLES ...`]) 
		]

		, [ check_text( `PhiborEntreprises` ), set(chain, `fr phibor entreprises`), trace([`PHIBOR ENTREPRISES ...`]) ]
	
		, [ check_text( `SMPOCrippleGate` ), set(chain, `fr smpo`), trace([`SMPO ...`]) ]
		
		, [ check_text( `GEBHARDTFördertechnik` ), set(chain, `de gebhardt foedertechnik`), trace([`GEBHARDT FOEDERTECHNIK ...`]) ]

		, [ check_text( `<GENERATOR_INFO>INPLANGmbH</GENERATOR_INFO>` ), set(chain, `de hoerlemann`), trace([`HOERLEMANN ...`]), set( re_extract ) ]
		
		, [ check_text( `Stadler+Schaaf` ), set(chain, `de stadler + schaaf`), trace([`STADLER + SCHAAF ...`]) ]
	
		, [ check_text( `TOYOTAMOTORMANUFACTURING` ), set(chain, `gb toyota motor manufacturing`), trace([`TOYOTA MOTOR MANUFACTURING ...`]) ]
	
		, [ check_text( `toyotamotor` ), set(chain, `toyota hilti` ), trace([`TOYOTA HILTI ...`]) ]
		
		, [ check_text( `imtechengineering` ), set(chain, `gb imtech engineering` ), trace([`IMTECH ENGINEERING ...`]) ]

		, [ check_text( `tbsgmbhde` ), set(chain, `de tbs` ), trace([`TBS ...`]) ]
		
		, [ check_text( `stihlag` ), set(chain, `de stihl` ), trace([`STIHL ...`]) ]

		, [ check_text( `eabse` ), set(chain, `se eab` ), trace([`EAB ...`]) ]

		, [ check_text( `roccheggiani` ), set(chain, `it roccheggiani` ), trace([`ROCCHEGGIANI ...`]) ]
		
		, [ check_text( `PosStkEinheitArtikelBezeichnungPreisGesamtPreisR%` ), set(chain, `at kaltepol` ), trace([`KALTEPOL ...`]) ]
	
		, [ check_text( `WalzGebäudetechnikGmbH` ), set(chain, `de walz gebäudetechnik` ), trace([`WALZ GEBAUDETECHNIK ...`]), set( re_extract ) ]
	
		, [ check_text( `LIEBHERR-HausgeräteLienzGmbH` ), set(chain, `at liebherr-hausgeräte lienz` ), trace([`LIEBHERR-HAUSGERATE LIENZE ...`]) ]
	
		, [ check_text( `MANDiesel&Turbo` ), set(chain, `dk man diesel & turbo` ), trace([`MAN DIESEL & TURBO ...`]) ]

		, [ or( [ check_text( `TuotenumeroTuotenimikeMintilmääräKPLMääräHintaperYhteens` )
				, check_text( `TuotenumeroTuotenimikekplKustannuspaikkaKäyttäjäkk€/kk` )
			] ), set(chain, `fi hilti iof` ), trace([`INTELLIGENT ORDER FORM (FI)...`]) 
		]
		
		, [ check_text( `FalckA/S` ), set(chain, `dk falck` ), trace([`FALCK...`]) ]

		, [ check_text( `writech` ), set(chain, `ie writech industrial` ), trace([`WRITECH...`]) ]
		
		, [ check_text( `sunbeltrentals` ), set(chain, `us sunbelt` ), trace([`SUNBELT RENTALS...`]) ]

		, [ check_text( `DresdnerKühlanlagenbau` ), set(chain, `de dresdner kuehlanlangen` ), trace([`DRESDNER KUEHLANLANGEN...`]) ]
		
		, [ check_text( `sagatertiaire` ), set(chain, `fr saga tertiaire` ), trace([`SAGA TERTIAIRE...`]) ]
	
		, [ check_text( `acciaierievalbruna` ), set(chain, `it valbruna` ), trace([`VALBRUNA...`]) ]

		, [ check_text( `sebinoeu` ), set(chain, `it sebino` ), trace([`SEBINO...`]) ]
		
		, [ check_text( `balasnet` ), set(chain, `fr balas` ), trace([`BALAS...`]) ]

		, [ or( [ check_text( `COFELYAXIMA` ), check_text( `AXIMAREFRIGERATION` ) ] ), set(chain, `fr axima` ), trace([`AXIMA...`]) ]
		
		% , [ check_text( `MaconSupplyInc` ), set(chain, `us macon` ), trace([`MACON...`]) ]

		, [ check_text( `graybarcouk` ), set(chain, `gb graybar` ), trace([`GRAYBAR...`]) ]

		, [ check_text( `GB217759047` ), set(chain, `gb air products` ), trace([`AIR PRODUCTS...`]) ]

		, [ check_text( `mcdermottbuilding` ), set(chain, `gb mcdermott building` ), trace([`MCDERMOTT BUILDING...`]) ]

		, [ check_text( `633414071` ), set(chain, `gb deepdale solutions` ), trace([`DEEPDALE SOLUTIONS...`]) ]

		, [ check_text( `ArtículosRefProveedorUdEspTécnCantidadPrecio%DtImporteFechaEntrega` )
			, set(chain, `es mac puar` ), trace([`MAC PUAR...`]) 
		]

		, [ check_text( `<NAME1>IWB</NAME1>` ), set(chain, `ch iwb` ), trace([`IWB...`]), set( re_extract ) ]

		, [ check_text( `wwwaplantcom` ), set(chain, `gb ashtead plant` ), trace([`ASHTEAD PLANT...`]) ]

		, [ check_text( `virklundsport` ), set(chain, `dk virklund` ), trace([`VIRKLUND SPORT...`]) ]

		, [ check_text( `ltwintralogistics` ), set(chain, `doppelmayr` ), trace([`LTW INTRALOGISTICS...`]) ]

		, [ check_text( `shepherdengineering` ), set(chain, `gb shepherd engineering` ), trace([`SHEPHERD ENGINEERING SERVICES...`]) ]

		, [ check_text( `geatdsgmbh` ), set(chain, `de gea tds` ), trace([`GEA TDS ...`]) ]
		
		, [ check_text( `SanitärFrei` ), set(chain, `ch sanitar frei` ), trace([`SANITAR FREI ...`]) ]
		
		, [ check_text( `LESCOMPAGNONSD'ERIC` ), set(chain, `fr les compagnons` ), trace([`LES COMPAGNONS D'ERIC ...`]) ]
		
		, [ check_text( `FR65381362243` ), set(chain, `fr anvolia` ), trace([`ANVOLIA ...`]) ]
		
		, [ check_text( `DDEE881155330022990033` ), set(chain, `de gruenbeck` ), trace([`GRUENBECK ...`]), set( re_extract ) ]
		
		, [ check_text( `413216008` ), set(chain, `gb air-serv` ), trace([`AIR-SERV ...`]) ]
		
		, [ check_text( `BBCRIVELLI&CERNECCASA` ), set(chain, `ch bb crivelli & cernecca` ), trace([`BB CRIVELLI & CERNECCA ...`]) ]
		
		, [ check_text( `commessacrea` ), set(chain, `it crea` ), trace([`IT CREA ...`]), set( re_extract ) ]
		
		, [ check_text( `tritonconstruction` ), set(chain, `triton hiltigb` ), trace([`TRITON CONSTRUCTION ...`]) ]
		
		, [ check_text( `valecanada` ), set(chain, `ca vale` ), trace([`VALE CANADA ...`]) ]
		
		, [ check_text( `16009690251` ), set(chain, `au tom stoddart` ), trace([`TOM STODDART ...`]) ]
		
		, [ or( [ check_text( `kuenzcom` ), check_text( `HansKünz` ) ] ), set(chain, `at kunz` ), trace([`KUENZ HANS ...`]) ]
		
		, [ check_text( `997320973` ), set( chain, `gb brandon hire` ), trace( [ `BRANDON HIRE ...` ] ) ]
		
		, [ check_text( `53000983700` ), set(chain, `au downer` ), trace([`DOWNER ...`]) ]

		, [ or( [ check_text( `@sistemit` ), check_text( `02251920365` ) ] )
			, set(chain, `sistem hilti` ), trace([`SISTEM ...`]) 
		]

		, [ check_text( `LafornituradeiprodottichimicideveessereaccompagnatadallaSchedadeiDatidisicurezzaredattasecondoilREG453/2010pena` ), set(chain, `it garc` ), trace([`GARC ...`]) ]
		
		, [ or( [ check_text( `talleresagui` ), check_text( `LínCódArticuloDenominaciónCantidadUnPrecioTotallíneaFechaentreg` ) ] )
			, set(chain, `es talleres agui` ), trace([`TALLERES AGUI ...`]) 
		]

		, [ check_text( `siloscordobacom` ), set(chain, `es silos cordoba` ), trace([`SILOS CORDOBA ...`]) ]
		
		, [ check_text( `TREIBACHERINDUSTRIEAG` ), set(chain, `at treibacher` ), trace([`TREIBACHER INDUSTRIE ...`]) ]

		, [ check_text( `carrierutccom` ), set(chain, `nl carrier` ), trace([`CARRIER REFRIGERATION ...`]) ]
		
		, [ check_text( `andritzag` ), set( chain, `at andritz` ), trace( [ `ANDRITZ AG ...` ] ) ]

		, [ check_text( `NesteOilOyj` ), set( chain, `fi neste oil` ), trace( [ `NESTE OIL ...` ] ), set( re_extract ) ]
		
		, [ check_text( `BHPBilliton` ), set( chain, `au bhp` ), trace( [ `BHP ...` ] ) ]

		, [ check_text( `weigerstorfer` ), set( chain, `de weigerstorfer` ), trace( [ `WEIGERSTORFER ...` ] ), set( re_extract ) ]
		
		, [ check_text( `sistavacpt` ), set( chain, `pt sistavac` ), trace( [ `SISTAVAC ...` ] ) ]
		
		, [ or( [ check_text( `wwwnordimpianti-srl` ), check_text( `wwwcaraglio` ) ] )
		
			, set( chain, `it nordimpianti` ), trace( [ `NORDIMPIANTI ...` ] )
			
		]
		
		, [ check_text( `SchindlerSA` ), set( chain, `es schindler` ), trace( [ `SCHINDLER ...` ] ) ]
		
		, [ check_text( `EstampacionesMetálicasÉpila` ), set( chain, `es estampaciones` ), trace( [ `ESTAMPACIONES ...` ] ), set( re_extract ) ]

		, [ check_text( `Banedanmark` ), set( chain, `banedk hilti` ), trace( [ `BANE DANMARK ...` ] ) ]
		
		, [ check_text( `CCIITTYYTTOOOOLLHHIIRREE` ), set( chain, `gb city tool hire` ), trace( [ `CITY TOOL HIRE ...` ] ) ]
	
		, [ check_text( `ArestalferSA` ), set( chain, `pt arestalfer` ), trace( [ `ARESTALFER ...` ] ) ]
		
		, [ check_text( `WTCWärmetechnikChemnitz` ), set( chain, `de wtc` ), trace( [ `WTC WARMETECHNIK ...` ] ) ]

		, [ check_text( `Nilsen(SA)PtyLtd` ), set( chain, `au nilsen (sa) pty` ), trace( [ `NILSEN (SA) PTY ...` ] ) ]
		
		, [ check_text( `buildersequipmentltd` ), set( chain, `gb builders equipment` ), trace( [ `BUILDERS EQUIPMENT ...` ] ) ]

		, [ check_text( `dron&dicksonltd` ), set( chain, `gb dron and dickson` ), trace( [ `DRON & DICKSON ...` ] ) ]

		, [ check_text( `kamperhandwerk` ), set( chain, `at kamper` ), trace( [ `KAMPER HANDWERK ...` ] ) ]
		
		, [ check_text( `LAGUARIGUE` ), set( chain, `fr laguarigue` ), trace( [ `LAGUARIGUE ...` ] ) ]
		
		, [ check_text( `01708720170` ), set( chain, `it diesse electra` ), trace( [ `DIESSE ELECTRA ...` ] ) ]
		
		, [ check_text( `GB582895876` ), set( chain, `gb nov mission` ), trace( [ `NOV MISSION ...` ] ) ]
		
		, [ check_text( `fcoservices` ), set( chain, `gb fco services` ), trace( [ `FCO SERVICES ...` ] ) ]
		
		, [ check_text( `purchasing@kaefercdcouk` ), set( chain, `gb kaefer c&d` ), trace( [ `KAEFER C&D ...` ] ) ]
		
		, [ check_text( `279987564` ), set( chain, `gb torrent trackside` ), trace( [ `TORRENT TRACKSIDE ...` ] ) ]
		
		, [ check_text( `DrywallSolutionsLtd` ), set( chain, `gb drywall solutions` ), trace( [ `DRYWALL SOLUTIONS ...` ] ), set( re_extract ) ]
	
		, [ check_text( `WebberLLC` ), set( chain, `us webber` ), trace( [ `WEBBER ...` ] ), set( re_extract ) ]
		
		, [ check_text( `GARTNERCONTRACTINGCoLtd` ), set( chain, `hk gartner contracting` ), trace( [ `HK GARTNER CONTRACTING ...` ] ), set( re_extract ) ]

		, [ check_text( `<NAME>KWO` ), set( chain, `ch kwo` ), trace( [ `KWO ...` ] ), set( re_extract ) ]

		, [ check_text( `FEEIndustrieautomationGmbH` ), set( chain, `de fee` ), trace( [ `FEE ...` ] ) ]
		
		, [ check_text( `hochtiefpolska` ), set( chain, `pl hochtief` ), trace( [ `HOCHTIEF POLSKA ...` ] ) ]
		
		, [ check_text( `mechanicasrl` ), set( chain, `it mechanica` ), trace( [ `MECHANICA SRL ...` ] ) ]
		
		, [ or( [ check_text( `deniosag` ), check_text( `deniosde` ) ] ), set( chain, `de denios ag` ), trace( [ `DENIOS AG ...` ] ) ]
		
		, [ check_text( `generaldatatech` ), set( chain, `us general datatech` ), trace( [ `GENERAL DATATECH ...` ] ) ]
		
		, [ check_text( `uranservicios` ), set( chain, `es uran servicios` ), trace( [ `URAN SERVICIOS ...` ] ) ]
		
		, [ or( [ check_text( `cofelyfabricom` ), check_text( `cofelyservices` ) ] ), set( chain, `be cofely fabricom` ), trace( [ `COFELY FABRICOM SA/NV ...` ] ) ]
		
		, [ check_text( `CodartMarcaCodProdutDescrizioneUMQtàPrezLordoImportoLordoSconti%PrezNettoImportoNettoCons` )
			, set( chain, `it pederzani` ), trace( [ `PEDERZANI ( NEW ) ...` ] ) 
		]
		
		, [ or( [ check_text( `ADVANCEDCONNECTIONSINC` ), check_text( `JOBNAMEJOB#BUYER/PMTERMSSHIPVIA` ) ] )
			, set( chain, `us advanced connections` ), trace( [ `US ADVANCED CONNECTIONS ...` ] )
		]
	
		, [ check_text( `Step2)InputOrderData(GreyshadedareasofOrderForm)` ), set( chain, `us iof` ), trace( [ `US IOF ...` ] ) ]
	
		, [ check_text( `raymond-southern` ), set( chain, `us raymond` ), trace( [ `US RAYMOND ...` ] ) ]
	
		, [ check_text( `kimbelmechanicalsystems` ), set( chain, `us kimbel mechanical` ), trace( [ `US KIMBEL MECHANICAL ...` ] ) ]
	
		, [ check_text( `CamecoCorporation` ), set( chain, `ca cameco` ), trace( [ `CA CAMECO ...` ] ) ]
		
		, [ check_text( `SniderBolt&Screw` ), set( chain, `us snider bolt screw` ), trace( [ `US SNIDER BOLT SCREW ...` ] ) ]
		
		, [ check_text( `heidelbergcement` ), set( chain, `de heidelbergercement` ), trace( [ `HEIDELBERGCEMENT AG ...` ] ) ]
		
		, [ check_text( `htkgmbh` ), set( chain, `de htk` ), trace( [ `HTK GMBH HAUSTECHNIK ...` ] ) ]
		
		, [ check_text( `yunetung` ), set( chain, `fr yune tung` ), trace( [ `YUNE TUNG S.A. ...` ] ), set(re_extract) ]
		
		, [ check_text( `GlobalHSESolutionsLimited` ), set( chain, `gb global hse solutions` ), trace( [ `GLOBAL HSE SOLUTIONS ...` ] ) ]
	
		, [ check_text( `TegometallIntSalesGmbH` ), set( chain, `de tegometall` ), trace( [ `TEGOMETALL ...` ] ) ]
		
		, [ check_text( `KONEIndustrialOy` ), set( chain, `de kone industrial` ), trace( [ `KONE INDUSTRIAL ...` ] ) ]
		
		, [ check_text( `Buck&HickmanNDC` ), set( chain, `gb buck and hickman` ), trace( [ `BUCK AND HICKMAN ...` ] ) ]
		
		, [ check_text( `NCCRakennusOy` ), set( chain, `fi ncc` ), trace( [ `NCC ...` ] ) ]
		
		, [ check_text( `@okgeonse` ), set( chain, `sk okg` ), trace( [ `OKG ...` ] ) ]
		
		, [ check_text( `1215183` ), set( chain, `gb hertel` ), trace( [ `HERTEL ...` ] ) ]
		
		, [ check_text( `69001740727` ), set( chain, `au kennards hire` ), trace( [ `KENNARDS HIRE PTY LTD ...` ] ) ]
		
		, [ check_text( `Liebherr-MCCtecRostockGmbH` ), set( chain, `de liebherr` ), trace( [ `LIEBHERR ...` ] ) ]
		
		, [ check_text( `ComauSpA` ), set( chain, `it comau` ), trace( [ `COMAU ...` ] ) ]
		
		, [ check_text( `STOCKMAGASSTOCKMAGASIN` ), set( chain, `fr sotis` ), trace( [ `SOTIS ...` ] ) ]
		
		, [ check_text( `708964694` ), set( chain, `gb wood group services` ), trace( [ `WOOD GROUP SERVICES ...` ] ), set(re_extract) ]
		
		, [ check_text( `mastershomeimprovement` ), set( chain, `au masters` ), trace( [ `MASTERS HOME IMPROVEMENT AUSTRALIA PTY LTD ...` ] ) ]
		
		, [ check_text( `Frei&RunggaldierSrl` ), set( chain, `it frei and runggaldier` ), trace( [ `FREI AND RUNGGALDIER ...` ] ) ]
		
		, [ check_text( `Lütfenaşağıdasiparişgeçtiğimürünleritedarikediniz` ), set( chain, `akyarlar hilti` ), trace( [ `AKYARLAR ORDER FORM ...` ] ) ]
		
		, [ check_text( `@prodex­nelsbe` ), set( chain, `be prodex` ), trace( [ `PRODEX ...` ] ) ]

		, [ check_text( `jreddington` ), set( chain, `gb j reddington` ), trace( [ `J REDDINGTON ...` ] ) ]

		, [ check_text( `cepi@cepisiloscom` ), set( chain, `it cepi` ), trace( [ `IT CEPI ...` ] ) ]
		
		, [ check_text( `01144610936` ), set( chain, `it telebit` ), trace( [ `IT TELEBIT ...` ] ) ]
		
		, [ check_text( `schuetz` ), set( chain, `de schutz` ), trace( [ `SCHUETZ ...` ] ) ]
		
		, [ check_text( `brockwhite` ), set( chain, `ca brock white` ), trace( [ `BROCK WHITE ...` ] ), set( re_extract ) ]
		
		, [ check_text( `JOSEPHGALLAGHERLTD` ), set( chain, `gb joseph gallagher` ), trace( [ `JOSEPH GALLAGHER ...` ] ) ]
				
		, [ check_text( `CauntonEngineering` ), set( chain, `gb caunton engineering` ), trace( [ `CAUNTON ENGINEERING ...` ] ) ]
		
		, [ check_text( `telectcom` ), set( chain, `us-telect` ), trace( [ `US Telect - HILTI ...` ] ) ]
	
		, [ check_text( `Item#CostVendorItem#ItemNameQtyUnitSubTotal` ), set( chain, `us capform` ), trace( [ `US CAPFORM ...` ] ) ]
		
		, [ check_text( `hirolift` ), set( chain, `de hiro lift` ), trace( [ `HIRO LIFT ...` ] ) ]

		, [ check_text( `osburncompanies` ), set( chain, `us osburn` ), trace( [ `OSBURN ...` ] ) ]
	
		, [ check_text( `mitietechnical` ), set( chain, `gb mitie technical` ), trace( [ `MITIE TECHNICAL ...` ] ) ]
	
		, [ check_text( `SASVULCAIN` ), set( chain, `fr vulcain` ), trace( [ `S.A.S. VULVAIN ...` ] ), set( re_extract ) ]
	
		, [ check_text( `canemsystem` ), set( chain, `ca canem` ), trace( [ `CANEM ...` ] ), set( re_extract ) ]
		
		, [ check_text( `SedeAmministrativaeStabilimentoPZAMONTANELLI20` ), set( chain, `fosber hilti` ), trace( [ `fosber hilti ...` ] ) ]
		
		, [ check_text( `836505033` ), set( chain, `gb soundtex` ), trace( [ `SOUNDTEX PARTITIONS ...` ] ) ]
		
		, [ or( [ check_text( `StageElectrics` ), check_text( `stage-electrics` ) ] )
			, set( chain, `gb stage electrics` ), trace( [ `STAGE ELECTRICS ...` ] ) 
		]

	] )
	
] ).

i_speedy_check( TEXT ) :- string_to_lower(TEXT, TL), q_sys_sub_string( TL, _, _, `speedy`), q_sys_sub_string( TL, _, _, `limited`). 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ID RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BAE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( bae_systems_line, [ check_text( `partclassificationaca` ), set( chain, `bae systems` ), trace( [ `BAE SYSTEMS...` ] ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IT TEA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IT CEU
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IT FPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_rule( it_fpt_rule, [ it_fpt_first_line, it_fpt_second_line, set( chain, `it fpt industrie` ), trace( [ `IT FPT INDUSTRIE ...` ] ) ] ).
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
	
	  read_aheadl( `HILTI` ), hilti(w), `ITALIA`, `SPA`
	  
	, check( hilti(start) > 0 )
	
	, check( hilti(y) > -415 )
	
	, check( hilti(y) < -405 )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IT TECHNELIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_line_rule( it_tecnelit_line, [ 
%=========================================================================================
	
	  `NUMERO`, tab, `COMMESSA`, `N`, `:`
	  
	, set( chain, `it tecnelit` )
	
	, trace( [ `IT TECNELIT ...` ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% US BECHTEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_line_rule( us_bechtel_line_one, [ `Material`, `Request` ] ).
%=========================================================================================
i_line_rule( us_bechtel_line_two, [ `Request`, `#` ] ).
%=========================================================================================
i_line_rule( us_bechtel_line_three, [ `Employee`, `Name` ] ).
%=========================================================================================
i_line_rule( us_bechtel_line_four, [ `Foreman` ] ).
%=========================================================================================
i_rule( us_bechtel_rule, [ 
%=========================================================================================
	
	  us_bechtel_line_one
	  
	, us_bechtel_line_two
	
	, us_bechtel_line_three
	
	, us_bechtel_line_four
	
	, set( chain, `us bechtel` )
	
	, trace( [ `US BECHTEL ...` ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GB BRIGGS AND FORRESTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_rule( briggs_and_forrester_rule, [ 
%=========================================================================================
	
	  q(2,2, generic_line( [ [ dummy(w), tab, some(date), newline, check( dummy(start) > 100 ) ] ] ) )
	
	, set( chain, `gb briggs and forrester` )
	
	, trace( [ `GB BRIGGS & FORRESTER ...` ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DE POPP LAUSER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CH DEBRUNNER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GB ALREADY HIRE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_rule( gb_already_hire_rule, [
%=========================================================================================
	
	generic_line( [ [ `Order`, `No`, `:` ] ] )
	
	, generic_line( [ [ `PURCHASE`, `ORDER`, newline ] ] )
	
	, generic_line( [ [ `Supplier`, `:`, tab ] ] )

	, set( chain, `gb already hire` )
	
	, trace( [ `GB ALREADY HIRE ...` ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GB CROWN HOUSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_rule( crown_house_alternate_id_rule, [
%=========================================================================================
	
	generic_line( [ check_text( `SUPPLIERDETAILSINVOICETOORDERNo` ) ] )
	
	, generic_line( [ check_text( `Hilti(GB)LimitedSECTOR` ) ] )

	, set(chain, `crown house hilti`)
	
	, trace([`CROWN HOUSE ...`])
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AT FIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================================
i_rule( at_fill_gesellschaft_rule, [
%=========================================================================================
	
	q0n(line)
	
	, generic_line( [ check_text( `PosMengeMEArtikelnrLieferterminEinzelpreisjeMengeMEGesamtpreis` ) ] )
	
	, generic_line( [ check_text( `UTNrBezeichnungeintreffendEUREUR` ) ] )

	, set(chain, `at fill gesellschaft`)
	
	, trace([`AT FILL GESELLSCHAFT ...`])
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DE LINDE GAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
