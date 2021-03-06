%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT ALPIQ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_alpiq_2, `11 August 2015` ).

%i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, buyer_dept, `Buyer Dept` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_buyers_code_for_buyer

	, get_order_number

	, get_delivery_address
	
	, get_cig_cup
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

	, get_contact_depts
		
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Sebino Fire Protection` )
	, set( no_scfb )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyers_code_for_buyer, [
%=======================================================================

	q(0,3,line)
	
	, generic_horizontal_details( [ Search ] )
	
	, buyers_code_for_buyer( BCfB )
	, trace( [ `Buyers Code for Buyer`, BCfB ] )
	
	, set( Flag )
	
	, q10( [ test( milano ), delivery_party( `ALPIQ INTEC MILANO S.P.A` ) ] )
	, q10( [ test( verona ), delivery_party( `ALPIQ INTEC VERONA S.P.A` ) ] )
	
] ):- bcfb_search( Search, BCfB, Flag ).

bcfb_search( [ `Alpiq`, `InTec`, `Milano` ], `ITALPIMILANO`, milano ).
bcfb_search( [ `Alpiq`, `InTec`, `Verona` ], `ITALPIVERONA`, verona ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_depts, [
%=======================================================================

	  delivery_from_contact( Con )
	, buyer_dept( Con )
	
	, trace( [ `Contacts`, Con ] )
	
] )
:-

	i_mail( text, Clutter ),

	q_sys_sub_string( Clutter, _, _, `@alpiq` ),
	
	trace( [ `Alpiq Clutter`, Clutter ] ),
	sys_string_split( Clutter, `, `, ClutterList ),
	q_sys_member( ClutterMember, ClutterList ),
	
	q_sys_sub_string( ClutterMember, Domain_Start, Domain_Length, `@alpiq.com` ),
	!,
	
	trace( [ `Found Alpiq` ] ),
	
	q_sys_sub_string( ClutterMember, Start, _, `mailto` ),
	!,
	
	trace( [ `Found Mailto` ] ),
	
	sys_calculate( Difference, Domain_Start - Start ),
	
	q_sys_comp( Difference =< 50 ),
	
	q_sys_sub_string( ClutterMember, Start, _, Less_Clutter ),
	
	!,
	
	trace( [ `Less Clutter:`, Less_Clutter ] ),

	q_sys_sub_string( Less_Clutter, Colon, _, `:` ),
	
	sys_calculate( Colon_plus, Colon + 1 ),
	
	( q_sys_sub_string( Less_Clutter, Email_End, _, `"` )
	
		; q_sys_sub_string( Less_Clutter, Email_End, _, `]` )
		
		; q_sys_sub_string( Less_Clutter, Email_End, _, `<` )
		
	),
	
	sys_calculate( Length, Email_End - Colon_plus ),
	q_sys_sub_string( Less_Clutter, Colon_plus, Length, Email ),
	trace( [ `Email`, Email ] ),

	( grammar_set( milano )
		->	Pred = milano_contact_lookup
		
		;	Pred = verona_contact_lookup
	),
	
	( Lookup =.. [ Pred, Email, Con ],
		Lookup
			->	trace( [ `Got Con`, Con ] )
			
			;	trace( `Email not in lookup` )
	)
	
.

milano_contact_lookup( `marcello.abbate@alpiq.com`, `ITALMIITALMIABBAT` ).
milano_contact_lookup( ``, `ITALMIITALMIAIROL` ).
milano_contact_lookup( `sara.albegiani@alpiq.com`, `ITALMIITALMIALBEG` ).
milano_contact_lookup( `federico.aldrovandi@alpiq.com`, `ITALMIITALMIALDOV` ).
milano_contact_lookup( `mario.angelini@alpiq.com`, `ITALMIITALMIANGEL` ).
milano_contact_lookup( `daniele.argelli@alpiq.com`, `ITALMIITALMIARGEL` ).
milano_contact_lookup( `simone.arnoldi@alpiq.com`, `ITALMIITALMIARNOL` ).
milano_contact_lookup( `arrigonimarco67@alice.it`, `ITALMIITALMIARRIG` ).
milano_contact_lookup( `bacchi.giacomo@alpiq.com`, `ITALMIITALMIBACCH` ).
milano_contact_lookup( `patrizia.bagarotto@alpiq.com`, `ITALMIITALMIBAGAR` ).
milano_contact_lookup( `renato.battistello@alpiq.com`, `ITALMIITALMIBATTI` ).
milano_contact_lookup( `dumas.benitez@alpiq.com`, `ITALMIITALMIBENIT` ).
milano_contact_lookup( `antonio.bertari@alpiq.com`, `ITALMIITALMIBERTA` ).
milano_contact_lookup( `maurizio.bianchi@alpiq.com`, `ITALMIITALMIBIANC` ).
milano_contact_lookup( `mario.boario@alpiq.com`, `ITALMIITALMIBOARI` ).
milano_contact_lookup( `luciano.borin@alpiq.com`, `ITALMIITALMIBORIN` ).
milano_contact_lookup( `filippo.bottini@alpiq.com`, `ITALMIITALMIBOTTI` ).
milano_contact_lookup( `sergio.brigatti@alpiq.com`, `ITALMIITALMIBRIGA` ).
milano_contact_lookup( `maurizio.bufano@alpiq.com`, `ITALMIITALMIBUFAN` ).
milano_contact_lookup( `andrea.buzzi@alpiq.com`, `ITALMIITALMIBUZZI` ).
milano_contact_lookup( ``, `ITALMIITALMICADDE` ).
milano_contact_lookup( ``, `ITALMIITALMICARLO` ).
milano_contact_lookup( `bruno.catello@alpiq.com`, `ITALMIITALMICATEL` ).
milano_contact_lookup( `michele.chiaromonte@alpiq.com`, `ITALMIITALMICHIAR` ).
milano_contact_lookup( `marco.colombini@alpiq.com`, `ITALMIITALMICOLOM` ).
milano_contact_lookup( ``, `ITALMIITALMICOVEL` ).
milano_contact_lookup( `roberto.croda@alpiq.com`, `ITALMIITALMICRODA` ).
milano_contact_lookup( `umberto.croda@alpiq.com`, `ITALMIITALMICRODA` ).
milano_contact_lookup( `ivancrotta@alice.it`, `ITALMIITALMICROTT` ).
milano_contact_lookup( `paolo.dadda@alpiq.com`, `ITALMIITALMIDADDA` ).
milano_contact_lookup( `william.disalvo@alpiq.com`, `ITALMIITALMIDISA` ).
milano_contact_lookup( `paolo.disanto@alpiq.com`, `ITALMIITALMIDISA` ).
milano_contact_lookup( `daniele.esposito@alpiq.com`, `ITALMIITALMIESPOS` ).
milano_contact_lookup( `michele.forina@alpiq.com`, `ITALMIITALMIFORIN` ).
milano_contact_lookup( `marco.forti@alpiq.com`, `ITALMIITALMIFORTI` ).
milano_contact_lookup( `enrico.frigato@alpiq.com`, `ITALMIITALMIFRIGA` ).
milano_contact_lookup( `lidia.frigerio@alpiq.com`, `ITALMIITALMIFRIGE` ).
milano_contact_lookup( `mauro.frontini@alpiq.com`, `ITALMIITALMIFRONT` ).
milano_contact_lookup( `ivo.galimberti@alpiq.com`, `ITALMIITALMIGALIM` ).
milano_contact_lookup( `giacomo.bacchi@alpiq.com`, `ITALMIITALMIGARDI` ).
milano_contact_lookup( `davide.gardi@alpiq.com`, `ITALMIITALMIGARDI` ).
milano_contact_lookup( `elio.giudici@alpiq.com`, `ITALMIITALMIGIUDI` ).
milano_contact_lookup( `gabriele.gnocchi@alpiq.com`, `ITALMIITALMIGNOCC` ).
milano_contact_lookup( `lorenzo.guastalli@alpiq.com`, `ITALMIITALMIGUAST` ).
milano_contact_lookup( `barbara.ivone@alpiq.com`, `ITALMIITALMIIVONE` ).
milano_contact_lookup( `alessio.lamperti@alpiq.com`, `ITALMIITALMILAMPE` ).
milano_contact_lookup( `guido.longoni@alpiq.com`, `ITALMIITALMILONGO` ).
milano_contact_lookup( `fabio.magri@alpiq.com`, `ITALMIITALMIMAGRI` ).
milano_contact_lookup( `renato.marino@alpiq.com`, `ITALMIITALMIMARIN` ).
milano_contact_lookup( `michele.massa@alpiq.com`, `ITALMIITALMIMASSA` ).
milano_contact_lookup( `roberto.mauri@alpiq.com`, `ITALMIITALMIMAURI` ).
milano_contact_lookup( `maurizio.meneguz@alpiq.com`, `ITALMIITALMIMENEG` ).
milano_contact_lookup( `giuliano.milani@alpiq.com`, `ITALMIITALMIMILAN` ).
milano_contact_lookup( `maurizio.milesi@alpiq.com`, `ITALMIITALMIMILES` ).
milano_contact_lookup( `manuel.natali@alpiq.com`, `ITALMIITALMINATAL` ).
milano_contact_lookup( `cristian.pacecca@alpiq.com`, `ITALMIITALMIPACEC` ).
milano_contact_lookup( `marco.pandolfi@alpiq.com`, `ITALMIITALMIPANDO` ).
milano_contact_lookup( `gianluigi.paravisi@alpiq.com`, `ITALMIITALMIPARAV` ).
milano_contact_lookup( `claudia.pedone@alpiq.com`, `ITALMIITALMIPEDON` ).
milano_contact_lookup( `giuseppe.pescio@alpiq.com`, `ITALMIITALMIPESCI` ).
milano_contact_lookup( `carlo.quarteroni@alpiq.com`, `ITALMIITALMIQUART` ).
milano_contact_lookup( `ermanno.quarteroni@alpiq.com`, `ITALMIITALMIQUART` ).
milano_contact_lookup( ``, `ITALMIITALMIRAVEL` ).
milano_contact_lookup( ``, `ITALMIITALMIROTAM` ).
milano_contact_lookup( `marzio.sala@alpiq.com`, `ITALMIITALMISALAM` ).
milano_contact_lookup( `laura.scabbia@alpiq.com`, `ITALMIITALMISCABB` ).
milano_contact_lookup( `emanuele.stampacchia@alpiq.com`, `ITALMIITALMISTAMP` ).
milano_contact_lookup( `roberto.testoni@alpiq.com`, `ITALMIITALMITESTO` ).
milano_contact_lookup( `marco.travella@alpiq.com`, `ITALMIITALMITRAVE` ).
milano_contact_lookup( `fabio.vecchio@alpiq.com`, `ITALMIITALMIVECCH` ).
milano_contact_lookup( `mario.ventaglieri@alpiq.com`, `ITALMIITALMIVENTA` ).

verona_contact_lookup( `iso.alzetta@alpiq.com`, `ITALVEALZETTAISO` ).
verona_contact_lookup( `info@alpiq.com`, `ITALVEAMBROSISTEF` ).
verona_contact_lookup( `info@alpiq.com`, `ITALVEANTONINIFRA` ).
verona_contact_lookup( `valentina.antonini@alpiq.com`, `ITALVEANTONINIVAL` ).
verona_contact_lookup( ``, `ITALVEBELLINISTEF` ).
verona_contact_lookup( ``, `ITALVEBERTOLDIMIR` ).
verona_contact_lookup( `stefano.bombieri@alpiq.com`, `ITALVEBOMBIERISTE` ).
verona_contact_lookup( `franco.bonato@alpiq.com`, `ITALVEBONATOFRANC` ).
verona_contact_lookup( `fabio.braga@alpiq.com`, `ITALVEBRAGAFABIO` ).
verona_contact_lookup( `giovanni.cacciatori@alpiq.com`, `ITALVECACCIATORIG` ).
verona_contact_lookup( `marco.cappelletti@alpiq.com`, `ITALVECAPPELLETTI` ).
verona_contact_lookup( `gabriella.cason@alpiq.com`, `ITALVECASONGABRIE` ).
verona_contact_lookup( ``, `ITALVECICOGNAALES` ).
verona_contact_lookup( `mariano.depretto@alpiq.com`, `ITALVEDE PRETTOMA` ).
verona_contact_lookup( ``, `ITALVEDINDOANDREA` ).
verona_contact_lookup( `giovanni.facci@alpiq.com`, `ITALVEFACCIGIOVAN` ).
verona_contact_lookup( `gabriele.fasoli@alpiq.com`, `ITALVEFASOLIGABRI` ).
verona_contact_lookup( `ferdinando.fiorio@alpiq.com`, `ITALVEFIORIOFERDI` ).
verona_contact_lookup( `roberto.forcato@alpiq.com`, `ITALVEFORCATOROBE` ).
verona_contact_lookup( ``, `ITALVEFOSCHINMARC` ).
verona_contact_lookup( `federico.francia@alpiq.com`, `ITALVEFRANCIAFEDE` ).
verona_contact_lookup( `katia.serratore@alpiq.com`, `ITALVEGASPARINILU` ).
verona_contact_lookup( `alessandro.gaspari@alpiq.com`, `ITALVEGASPERIALES` ).
verona_contact_lookup( ``, `ITALVEGASPERIGIOR` ).
verona_contact_lookup( `mirco.gennaro@alpiq.com`, `ITALVEGENNAROMIRC` ).
verona_contact_lookup( ``, `ITALVEGIANESEDINO` ).
verona_contact_lookup( `info@alpiq.com`, `ITALVEGRIGOLATOMA` ).
verona_contact_lookup( `stefano.guerra@alpiq.com`, `ITALVEGUERRASTEFA` ).
verona_contact_lookup( `michele.marchi@alpiq.com`, `ITALVEMARCHIMICHE` ).
verona_contact_lookup( `vittorio.masenelli@alpiq.com`, `ITALVEMASENELLIVI` ).
verona_contact_lookup( `silvano.masenelli@alpiq.com`, `ITALVEMASENELLISI` ).
verona_contact_lookup( `elena.mirandola@alpiq.com`, `ITALVEMIRANDOLAEL` ).
verona_contact_lookup( `marco.moschin@alpiq.com`, `ITALVEMOSCHINMARC` ).
verona_contact_lookup( `cristian.moschin@alpic.com`, `ITALVEMOSCHINCRIS` ).
verona_contact_lookup( ``, `ITALVEPAGANOTTOLU` ).
verona_contact_lookup( `info@alpiq.com`, `ITALVEPASTIPAOLO` ).
verona_contact_lookup( `simone.perin@alpiq.com`, `ITALVEPERINSIMONE` ).
verona_contact_lookup( `luca.perpoli@alpiq.com`, `ITALVEPERPOLILUCA` ).
verona_contact_lookup( `flavio.piccoli@alpiq.com`, `ITALVEPICCOLIFLAV` ).
verona_contact_lookup( `sabrina.piva@alpiq.com`, `ITALVEPIVASABRINA` ).
verona_contact_lookup( `luca.poletto@alpiq.com`, `ITALVEPOLETTOLUCA` ).
verona_contact_lookup( `pierino.raisa@alpiq.com`, `ITALVERAISAPIERIN` ).
verona_contact_lookup( `rosario.randazzo@alpiq.com`, `ITALVERANDAZZOROS` ).
verona_contact_lookup( `paolo.ravanini@alpiq.com`, `ITALVERAVANINIPAO` ).
verona_contact_lookup( ``, `ITALVERIGODANZODA` ).
verona_contact_lookup( `stefano.roboe@alpiq.com`, `ITALVEROBOESTEFAN` ).
verona_contact_lookup( `mattia.rossato@alpiq.com`, `ITALVEROSSATOMATT` ).
verona_contact_lookup( `gioele.scipioni@alpiq.com`, `ITALVESCIPIONIGIO` ).
verona_contact_lookup( `info@alpiq.com`, `ITALVESERENIMATTE` ).
verona_contact_lookup( `katia.serratore@alpiq.com`, `ITALVESERRATOREKA` ).
verona_contact_lookup( `luca.torni@alpiq.com`, `ITALVETORNILUCA` ).
verona_contact_lookup( ``, `ITALVEURSACHERADU` ).
verona_contact_lookup( `luigi.errico@alpiq.com`, `ITALVEVERZELUIGI` ).
verona_contact_lookup( `rinaldo.vicentini@alpiq.com`, `ITALVEVICENTINIRI` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line)

	, generic_vertical_details( [ [ `N`, `.`, `Documento` ], `N`, q(0,0), (start,0,30), order_number, s1
		, [ tab, generic_item( [ invoice_date, date ] ) ] 
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	q(0,50,line)
	, generic_horizontal_details( [ [ `Luogo`, `di`, `spedizione` ] ] )

	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_dept, s1 ] )
	
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	nearest( generic_hook(start), 10, 10 )
	
	, delivery_street(sf)
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ], q10( `-` ) ] )

	, generic_item( [ delivery_city, sf, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] ) ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CIG CUP	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_cig_cup, [ 
%=======================================================================

	q10( [ q(0,20,line), generic_horizontal_details( [ [ `CUP`, `:` ], 50, cup, s1 ] ), set( cup ) ] )
	
	, q10( [ q(0,20,line), generic_horizontal_details( [ [ `CIG`, `:` ], 50, cig, s1 ] ), set( cig ) ] )
	
	, q10( [ without( cig ), cig( `` ) ] )
	, q10( [ without( cup ), cup( `` ) ] )
	
	, or( [ test( cig ), test( cup ) ] )
	
	, check( cig = Cig )
	, check( cup = Cup )
	, check( strcat_list( [ `CIG: `, Cig, ` Cup: `, Cup ], AL ) )
	, delivery_address_line( AL )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `Totale`, `netto` ], 300, total_net, d ] )

	, check( total_net = Net )
	, total_invoice( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Il`, `presente` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )

	, line_end_line 

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `POSIZ`, `.`, q10( tab ), `Codice` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `*`, `*`, `*` ], [ `La`, `fatturazione` ] ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	line_invoice_line
	
	, or( [ [ test( got_descr ), clear( got_descr ) ]
	
		, line_descr_line
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )
	  
	, or( [ [ generic_item_cut( [ line_item_for_buyer, sf, [ q10( tab ), or( [ `HIl`, read_ahead( item_code( f( [ begin, q(dec,4,10), end ] ) ) ) ] ) ] ] )

			, q10( `-` )
			
			, generic_item( [ line_item, [ begin, q(dec,4,10), end ], [ q10( [ line_descr(s1), set( got_descr ) ] ), tab ] ] )
		]
		
		, [ generic_item_cut( [ line_item_for_buyer, s1, tab ] )
			, generic_item( [ line_descr, s1, tab ] )
			, set( got_descr )
		]
	] )
	
	, or( [ [ without( customer_comments ), customer_comments(sf) ]
	
		, [ with( customer_comments ), customer_comments_x(sf) ]
	] )
	
	, q10( tab )

	, generic_item( [ line_quantity_uom_code, w
		, [ q10( tab ), check( line_quantity_uom_code(start) > -5 )
			, check( line_quantity_uom_code(end) < 25 ) 
		] 
	] )

	, generic_item_cut( [ line_quantity, d, tab ] )
	
	, xor( [ [ generic_item_cut( [ line_unit_amount_x, d, `/` ] )
			, q10( tab ), uom(d)
		]
		
		, [ generic_item_cut( [ line_unit_amount_x, d ] ) ]	
	] )
	
	, generic_item_cut( [ line_percent_discount_x, d, tab ] ) 

	, generic_item_cut( [ line_net_amount, d, q10( tab ) ] )

	, generic_item( [ line_original_order_date, date, q10( tab ) ] )
	
	, thing(s1), newline

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [ generic_item( [ line_descr, s1, newline ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
] ).