%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_rules, `25 July 2013` ).

%i_pdf_parameter( tab, 16 ).
%i_pdf_parameter( direct_object_mapping, 0 ).
% i_pdf_parameter( max_pages, 10).

i_page_split_rule_list( [ set(chain,`unrecognised`), select_buyer] ).

%=======================================================================
i_rule( select_buyer, [ q0n(line), buyer_id_line ] ).
%=======================================================================


%=======================================================================
i_line_rule( buyer_id_line, [
%=======================================================================

	q0n(anything)

	, or([

		[ `chep`, set(chain, `GB-CHEP TEST`), trace([`CHEP ...`])  ]

		, [ `speedy`, q0n(anything), `limited`, set(chain, `GB-SPEEDY`), trace([`SPEEDY ...`])  ]

		, [ `network`,`rail`, set(chain, `GB-NWKRAIL`), trace([`NETWORK RAIL ...`])  ]

		, [ `harsco`,`infrastructure`, set(chain, `GB-HARSCO TEST`), trace([`HARSCO ...`])  ]

		, [ `afl`,set(chain, `US-AFL`), trace([`AFL ...`])  ]

		, [ `controlmatic`,set(chain, `DE-VINCI`), trace([`VINCI ...`])  ]
		, [ `ekorg`,set(chain, `DE-VINCI`), trace([`VINCI ...`])  ]

		, [ `pederzani`,set(chain, `pederzani`), trace([`PEDERZANI ...`])  ]

		 , [ `doclink`, `.`, `tradex`, set(chain, `tradex`), trace([`TRADEX ...`])  ]

		 , [ `kone`, `gmbh`, set(chain, `kone`), trace([`KONE ...`])  ]
		 , [ `KONE`, `SA`, tab, `Bon`, `de`, `Commande`,  newline, set(chain, `kone fr test`), trace([`KONE FR ...`])  ]

		 , [ `ameon`, `limited`, set(chain, `ameon`), trace([`AMEON ...`])  ]

		 , [ `stahlbau`, `pichler`, set(chain, `stahlbau pichler`), trace([`STALBAU PICHER ...`])  ]

		 , [ `pos`, tab, `articolo`, tab, `descrizione`, tab, set(chain, `termigas test`), trace([`TERMIGAS ...`])  ]

		 , [ `brandon`, `hire`, set(chain, `gb-brandon test`), trace([`BRANDON HIRE ...`])  ]

		 , [ `Bellotto`, or([ `Impianti`, `general`]), set(chain, `bellotto test`), trace([`BELLOTTO...`])  ]

		 , [ `Frigoveneta`, set(chain, `frigoveneta test`), trace([`FRIGOVENETA...`])  ]

		 , [ `mortenson`, set(chain, `mortenson test`), trace([`MORTENSON...`])  ]

		 , [ `mascopurchasing`, set(chain, `masco test`), trace([`MASCO...`])  ]
		 , [ `masco`, set(chain, `masco test`), trace([`MASCO...`])  ]
		 , [ `fob`, tab, `supplier`, `contact`, set(chain, `masco test`), trace([`MASCO...`])  ]

		 , [ `umdasch`,  set(chain, `umdasch`), trace([`UMDASCH GROUP...`])  ]

		 , [ `cpl`, `concordia`, set(chain, `cpl concordia test`), trace([`CPL CONCORDIA...`])  ]

		 , [ `alusommer`, set(chain, `alusommer`), trace([`ALUSOMMER...`])  ]

		 , [ `BABAK`, `GEBÄUDETECHNIK`, set(chain, `babak test`), trace([`BABAK...`])  ]

		 , [ `Bacon`, `Gebudetechnik`, `GmbH`, set(chain, `bacon`), trace([`BACON...`])  ]
		 , [ `Bacon`, `.`, `at`, set(chain, `bacon`), trace([`BACON...`])  ]
		 , [ `Ordernummer`, `immer`, `anführen`, `!`,  newline, set(chain, `bacon`), trace([`BACON...`])  ]
	
		 , [ `ATZWANGER`, `AG`, `SPA`, set(chain, `atzwanger test`), trace([`ATZWANGER...`])  ]

		 , [ `SCHMIDHAMMER`, `SRL`, set(chain, `schmidhammer`), trace([`SCHMIDHAMMER...`])  ]

		 , [ `ospelt`, set(chain, `ospelt test`), trace([`OSPELT...`])  ]

		 , [ `Items`, `highlighted`, `grey`, `will`, `be`, `dispatched`, set(chain, `interserve call off test`), trace([`INTERSERVE CALL OFF...`])  ]
		 , [ `VAT`, `No`, `.`, `-`, `527`, `218`, `256`, set(chain, `interserve`), trace([`INTERSERVE...`])  ]
		 , [ `VAT`, `No`, `.`, `-`, `527`, `2182`, `56`, set(chain, `interserve`), trace([`INTERSERVE...`])  ]
		 , [ `Areas`, `shaded`, `red`, `are`, `mandatory`, `and`, `areas`, `shaded`, `grey`, `are`, `optional`, `.`, newline, set(chain, `interserve firm order test`), trace([`INTERSERVE FIRM ORDER...`])  ]

		 , [ `company`, q0n(anything), `type`, `standard`, `purchase`, `order`, newline, set(chain, `masco test`), trace([`MASCO...`])  ]

		 , [ `EINKAUFSBEDINGUNGEN`, `BABAK`, set(chain, `hilti ignore`), trace([`BABAK T&C ...`])  ]

		 , [ `FRENER`, `&`, `REIFER`, set(chain, `frener test`), trace([`FRENER & REIFER...`])  ]

		 , [ `Dönges`, `GmbH`, `&`, `Co`, set(chain, `donges`), trace([`DONGES...`])  ]

		 , [ `Berliner`, `Wasserbetriebe`, set(chain, `bwb test`), trace([`BWB...`])  ]

		 , [ `fill`, `metallbau`, set(chain, `fill`), trace([`FILL...`])  ]

		 , [ `www`, `.`, `lonza`, `.`, `com`, set(chain, `lonza`), trace([`LONZA...`])  ]

		 , [ `linde`, `gas`, `gmbh`, set(chain, `lindegas`), trace([`LINDEGAS...`])  ]

		 , [ `Item`, `/`, `Mfg`, `Number`, tab, `Due`, `Date`, `Order`, `Qty`, `U`, `/`, `M`, tab, `Unit`, `Cost`, `U`, `/`, `M`, `Tax`, tab, `Total`,  newline, set(chain, `terminix`), trace([`TERMINIX...`])  ]

		 , [ `Potash`, `Corporation`, set(chain, `pcs`), trace([`PCS ...`])  ]

		 , [ `Telamon`, set(chain, `telamon`), trace([`TELAMON...`])  ]

		 , [ `Kokosing`, `Construction`, `Company`, set(chain, `kokosing`), trace([`KOKOSING...`])  ]

		 , [ `Ludwig`, `BRANDSTÄTTER`, `Betriebs`, set(chain, `brandstaetter`), trace([`BRANDSTAETTER...`])  ]

		 , [ `coiver`, set(chain, `coiver`), trace([`COIVER...`])  ]

		 , [ `evg`, `entwicklungs`, set(chain, `evg`), trace([`EVG...`])  ]

		 , [ `Pos`, `Artikel`, tab, `Menge`, `Meh`, tab, `Einzelpreis`, `Rabatt`, `MWST`, `EUR`, `-`, `Betrag`,  newline, set(chain, `kappa`), trace([`KAPPA...`])  ]

		 , [ `Gemäß`, `unseren`, `Ihnen`, `bekannten`, `Bedingungen`, `bestellen`, `wir`, `:`,  newline, set(chain, `huber`), trace([`HUBER...`])  ]

		 , [ `boulons`, `manic`, set(chain, `boulons manic`), trace([`BOULONS MANIC...`])  ]

		 , [ `FOCCHI`, `S`, `.`, `p`, `.`, `a`, `.`, set(chain, `focchi`), trace([`FOCCHI...`])  ]

		 , [ `Tata`, `Steel`, `UK`, `Limited`, set(chain, `tata uk`), trace([`TATA STEEL...`])  ]

		 , [ `Carrier`, `Kältetechnik`, `Austria`, set(chain, `carrier`), trace([`CARRIER...`])  ]

		 , [ `Doppelmayr`, `Seilbahnen`, `GmbH`, set(chain, `doppelmayr`), trace([`DOPPELMAYR...`])  ]

		 , [ `Wir`, `bestellen`, `zu`, `den`, `Bedingungen`, `dieser`, `Bestellung`, `folgende`, `Artikel`, `:`,  newline, set(chain, `lohr`), trace([`LOHR...`])  ]

		 , [ `schindler`, newline, set(chain, `schindler`), trace([`SCHINDLER...`])  ]

		 , [ `pro`, `steel`, set(chain, `prosteel`), trace([`PROSTEEL...`])  ]

		 , [ check_text(`GIGFassadenGmbH`),  set(chain, `gig`), trace([`GIG...`])  ]
		 , [ check_text(`GIGService`),  set(chain, `gig`), trace([`GIG...`])  ]
		 , [ check_text(`PosNrArtikelNrArtikelbezeichnung`),  set(chain, `gig`), trace([`GIG...`])  ]

		 , [ `PosNr`, `ArtikelNr`, `.`, tab, `Artikelbezeichnung`, tab, `Lieferdatum`, tab, `Menge`, tab, `EinzPr`, `/`, `Ntto`, tab, `Netto`, `/`, `Pos`,  newline, set(chain, `gig`), trace([`GIG...`])  ]

		 , [ `firm`, `order`,  newline, set(chain, `firm order`), trace([`FIRM ...`])  ]

		 , [ `knapp`, set(chain, `knapp`), trace([`KNAPP...`])  ]

 		, [`671`, `4344`, `39`, set(chain, `babcock rail`), trace([`BABCOCK...`]) ]

		, [ `unipart`, `rail`, `limited`, set(chain, `unipart rail`), trace([`UNIPART...`]) ]

		, [ `DIVISIONE`, `MECCANICA`, `-`, `Tel`, `:`, `030`, `.`, `9400001`, `Fax`, `:`, `030`, `.`, `9400026`,  newline, set(chain, `impianti`), trace([`IMPIANTI...`]) ]

		, [ `NOTA`, `:`, `COPIA`, `DEL`, `PRESENTE`, `ORDINE`, `VA`, `RESTITUITA`, `FIRMATA`, `PER`, `ACCETTAZIONE`,  newline, set(chain, `impianti`), trace([`IMPIANTI...`]) ]

		, [ `Code`, `TCI`, tab, `Description`, tab, set(chain, `translec`), trace([`TRANSLEC...`]) ]
		, [ check_text(`TCIProduct`), set(chain, `translec`), trace([`TRANSLEC...`]) ]

		, [ `ONI`, `-`, `Wärmetrafo`, `GmbH`, set(chain, `oni`), trace([`ONI...`]) ]

		, [ `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `RECHNUNGSFAKTURA`, `AN`, `EXPERT`, `-`, `LANGENHAGEN`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`, `*`,  newline, set(chain, `heldele`), trace([`HELDELE...`]) ]

		, [ `PMS`, `Elektro`, `-`, `und`, `Automationstechnik`, set(chain, `pms`), trace([`PMS ELEKTRO...`]) ]

		, [ `articles`, `STM`, `,`, `doit`, `être`, `joint`, set(chain, `stm`), trace([`STM...`]) ]

		, [ `propak`, `systems`, set(chain, `propak`), trace([`PROPAK...`]) ]

		, [ `Skanska`, `USA`, `Civil`, `Northeast`,  newline, set(chain, `skanska`), trace([`SKANSKA...`]) ]

		, [ `MODULBLOK`, `SPA`, tab, `N`, `:`, `movimento`, set(chain, `modulblok`), trace([`MODULBLOK...`]) ]

		, [ `@`, `fabbrovanni`, `.`, `com`,  newline, set(chain, `fabbro vanni`), trace([`FABBRO VANNI...`]) ]

		 , [ check_text(`GB-HESIMM`), set(chain, `he_simm`), trace([`HE SIMM...`])  ]

		 , [ `Gebr`, `.`, `Knuf`,  newline, set(chain, `knuf`), trace([`KNUFF...`])  ]

		 , [ `@`, `roche`, `.`, `com`,  newline, set(chain, `la roche`), trace([`LA ROCHE...`])  ]

		 , [ `Köb`, `Holzheizsysteme`, `GmbH`, set(chain, `koeb`), trace([`KOEB...`])  ]

		 , [ `voelkl`, `.`, `co`, `.`, `at`, newline, set(chain, `voelkl`), trace([`VOELKL...`])  ]

		 , [ or([ [`Heidenbauer`, `Industriebau`, `GmbH`], [`Metallbau`, `Heidenbauer`, `GmbH`, `&`, `Co`, `KG`] ]), newline, set(chain, `heidenbauer`), trace([`HEIDENBAUER...`])  ]

		, [  `Item`, `Description`, tab, `Catalogue`, `No`, tab, `Order`, `Qty`, tab, set(chain, `he simm po`), trace([`HE SIMM PO...`]) ] 

		 , [ `SchwörerHaus`, `KG`, `·`, `Hans`, set(chain, `schworer`), trace([`SCHWORER...`])  ]

		 , [ `claas`, set(chain, `claas`), trace([`CLAAS...`])  ]

		 , [ `Références`, `à`, `rappeler`, `sur`, `toute`, `correspondance`, `:`,  newline, set(chain, `distrimo`), trace([`DISTRIMO...`])  ]

		 , [ `ATTENZIONE`, `:`, `NON`, `SI`, `ACCETTANO`, `FORNITURE`, `O`, `PRESTAZIONI`, `SENZA`, `ORDINE`, `SCRITTO`, `.`, tab, `CONSEGNA`, tab, `FRANCO`, tab, `MEZZO`,  newline, set(chain, `ed impianti`), trace([`ED IMPIANTI...`])  ]

		 , [ `gb`, `-`, `horbury`, set(chain, `horbury`), trace([`HORBURY...`])  ]

		 , [ `otis`, set(chain, `otis`), trace([`OTIS...`])  ]
		 
		, [ `(`, `01604`, `)`, `752424`, set(chain, `travis perkins (hilti)`), trace([`TRAVIS PERKINS (HILTI)`]) ]
	])
] ).
