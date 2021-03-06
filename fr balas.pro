%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR BALAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_balas, `31 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  check_for_quotation 
	  
	, get_fixed_variables

	, get_order_date
	
	, get_order_number
	
	, get_totals
	
] ).

%=======================================================================
i_rule( check_for_quotation, [ 
%=======================================================================

	q(0,50,line), generic_line( [ [ `Vos`, `références` ] ] )
	
	, q(0,15,line), generic_horizontal_details( [ `Offre` ] )
	
	, set( do_not_process )
	, trace( [ `Quotation detected, not processing` ] )
	, delivery_note_reference( `special_rule` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_due_date
	
	, get_delivery_details
	
	, get_buyer_contact
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_order_lines

] ):- not( grammar_set( do_not_process ) ).

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

	, buyer_registration_number( `FR-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]	
		, suppliers_code_for_buyer( `11741416` )		
	] )

	, type_of_supply( `01` )

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Balas` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Commande`, `N`, `°` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Le` ], 20, invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Livraison`, `demandée`, `pour`, `Le` ], delivery_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Lieu`, `de`, `livraison` ] ] )
	
	, read_ahead( generic_horizontal_details( [ nearest( generic_hook(start), 100, 10 ), hook, s1 ] ) )
	
	, gen1_parse_text_rule_cut
	
	, delivery_postcode_and_city_line
	
	, check( i_user_check( use_address_lookup, captured_text, delivery_postcode_x, DNN ) )
	
	, or( [ [ check( DNN = `` )
			, trace( [ `Lookup failed` ] )
			, force_result( `failed` )
			, force_sub_result( `missing_ship_to` )
		]
		, [ delivery_note_number( DNN )
			, trace( [ `DNN`, DNN ] )
		]
	] )
	
	, q10( delivery_contact_line )
	
] ).

%=======================================================================
i_rule_cut( gen1_parse_text_rule_cut, [ gen1_parse_text_rule( [ -500, -100, delivery_postcode_and_city_line ] ) ] ).
%=======================================================================	
i_line_rule_cut( delivery_postcode_and_city_line, [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, generic_item( [ delivery_postcode_x, [ begin, q(dec,4,5), end ], q10( tab ) ] )
	
	, generic_item( [ delivery_city_x, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_contact_line, [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, generic_item( [ delivery_contact_x, sf
		, or( [ [ read_ahead( dum(d) ), generic_item( [ delivery_ddi, s1 ] ) ]
			, gen_eof
		] )		
	] )
	
	, check( sys_string_split( delivery_contact_x, ` `, NamesRev ) )
	, check( sys_reverse( NamesRev, Names ) )
	, check( wordcat( Names, Con ) )
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_user_check( use_address_lookup, ParaIn, PC, DNN )
%=======================================================================	  
:- 
	string_to_upper( ParaIn, ParaU ),
	trace( para( ParaIn ) ),
	
	( address_lookup( Street, PC, DNN ),
		q_sys_sub_string( ParaU, _, _, Street ),
		trace( `Found DNN` )
		
		;	q_sys_sub_string( PC, 1, 2, PCStart ),
			address_lookup( Street, PCLookup, DNN),
			q_sys_sub_string( PCLookup, 1, 2, PCLookupStart ),
			PCStart = PCLookupStart,
			trace( [ `Matched PC, need Street:`, Street ] ),
			q_sys_sub_string( ParaU, _, _, Street ),
			trace( `Found DNN from start of PC` )
		
		;	DNN = ``
	)
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q(0,30,line)
	
	, generic_horizontal_details( [ [ `Affaire`, `suivie`, `par` ], 200, buyer_contact, sf
	
		, or( [ [ `Tél`, generic_item( [ buyer_ddi, sf, some(f( [ q(alpha,1,15) ] ) ) ] ) ]
			, `Courriel`
			, gen_eof 
		] ) 
	] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	qn0(line), generic_horizontal_details( [ [ `Total`, tab, `EUR`, `HT` ], 200, total_net, d ] )
	
	, check( total_net = Net )
	, total_invoice( Net )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_order_lines, [
%=======================================================================

	  line_header_line
	 
	, q0n(
		or( [ line_order_rule
			, line
		] )
	)
	
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Vos`, `références`, tab, `Votre`, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Total`, tab, `EUR` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_order_rule, [
%=======================================================================

	line_order_line
	
	, line_item_line
	
	, count_rule
	
	, q10( [ with( invoice, delivery_date, Date )
		, line_original_order_date( Date )
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_order_line, [
%=======================================================================

	  `-`
	
	, q10( [ read_ahead( [ q(0,4,word), `-` ] ), generic_item( [ line_item_for_buyer, sf, `-` ] ) ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity_x, d ] )
	, or( [ [ `PAQ`, line_quantity_uom_codex( `M` ), tab ]
		, generic_item( [ line_quantity_uom_codex, s1, tab ] )
	] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ] ] )
	  
	, or( [ [ tab
			, q0n(word)
			, generic_item( [ quantity_y, d
				, or( [ `Piece`
					, `Mètre`
					, [ `Unité`, `de`
						, or( [ `Ba`, `Base` ] )
					]
				] ) 
			] )
			
			, check( sys_calculate_str_multiply( line_quantity_x, quantity_y, Qty ) )
			
		]
		
		, check( line_quantity_x = Qty )
	] )
	
	, line_quantity( Qty )
	, trace( [ `Line quantity`, Qty ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

address_lookup( `VENDOME`, `75001`, `0020922397` ).
address_lookup( `VENDÔME`, `75001`, `0020922397` ).
address_lookup( `VALOIS`, `75001`, `0021816615` ).
address_lookup( `REAUMUR`, `75002`, `0021806722` ).
address_lookup( `L'OPERA`, `75002`, `0021807053` ).
address_lookup( `SAINT-MARTIN`, `75003`, `0020821827` ).
address_lookup( `CONTI`, `75006`, `0020843210` ).
address_lookup( `SAINT-MICHEL`, `75006`, `0021994294` ).
address_lookup( `AUGUSTE COMTE`, `75006`, `0022013733` ).
address_lookup( `VANNEAU`, `75007`, `0020127280` ).
address_lookup( `SEVRES`, `75007`, `0020655041` ).
address_lookup( `L'UNIVERSITE`, `75007`, `0021363458` ).
address_lookup( `MASSERAN`, `75007`, `0021637161` ).
address_lookup( `DOCTEUR LANCEREAUX`, `75008`, `0020582447` ).
address_lookup( `JEAN GOUJON`, `75008`, `0021382087` ).
address_lookup( `BIENFAISANCE`, `75008`, `0021518763` ).
address_lookup( `LA REINE`, `75008`, `0021740982` ).
address_lookup( `D'AGUESSEAU`, `75008`, `0021966462` ).
address_lookup( `CONCORDE`, `75008`, `0022047576` ).
address_lookup( `SCRIBE`, `75009`, `0021852863` ).
address_lookup( `REUILLY`, `75012`, `0021441677` ).
address_lookup( `JEAN FAUTRIER`, `75013`, `0021641792` ).
address_lookup( `SAINT MARCEL`, `75013`, `0021819285` ).
address_lookup( `SAINT-MARCEL`, `75013`, `0021819285` ).
address_lookup( `CHATILLON`, `75014`, `0021060658` ).
address_lookup( `JEAN REY`, `75015`, `0021052712` ).
address_lookup( `DOCTEUR BLANCHE`, `75016`, `0015316532` ).
address_lookup( `PIERRE GUERIN`, `75016`, `0019885774` ).
address_lookup( `RANELAGH`, `75016`, `0020882826` ).
address_lookup( `SUCHET`, `75016`, `0021485470` ).
address_lookup( `EMILE BOREL`, `75017`, `0021235926` ).
address_lookup( `ST OUEN`, `75017`, `0021360394` ).
address_lookup( `CHRISTINE DE PISAN`, `75017`, `0021507440` ).
address_lookup( `KURNONSKY`, `75017`, `0022024074` ).
address_lookup( `MACDONALD`, `75019`, `0021521881` ).
address_lookup( `MAHATMA GANDHI`, `75116`, `0019174574` ).
address_lookup( `DEHODENCQ`, `75116`, `0021035383` ).
address_lookup( `GASTON DE SAINT-PAUL`, `75116`, `0021352778` ).
address_lookup( `D'IENA`, `75116`, `0021679117` ).
address_lookup( `DRAGONS`, `77000`, `0022027471` ).
address_lookup( `DISNEYLAND`, `77700`, `0022122651` ).
address_lookup( `PRINCESSES`, `78100`, `0020608956` ).
address_lookup( `RONDE`, `78290`, `0020415852` ).
address_lookup( `JEAN-PIERRE TIMBAUD`, `91260`, `0021310315` ).
address_lookup( `PARIS`, `91300`, `0020363766` ).
address_lookup( `MARECHAL FOCH`, `91400`, `0021272903` ).
address_lookup( `JEAN JAURES`, `92110`, `0019348892` ).
address_lookup( `ALBERT CALMETTE`, `92110`, `0021322564` ).
address_lookup( `50 AVENUE JEAN JAURES`, `92120`, `0021972760` ).
address_lookup( `REAUMUR`, `92140`, `0020240006` ).
address_lookup( `LA REPUBLIQUE`, `92250`, `0020144868` ).
address_lookup( `KLEBER`, `92250`, `0021488125` ).
address_lookup( `BASSOT`, `92300`, `0021025855` ).
address_lookup( `ANATOLE FRANCE`, `92300`, `0021910150` ).
address_lookup( `LA LIBERTE`, `92320`, `0021609703` ).
address_lookup( `CLAUDE PERROT`, `92330`, `0021728199` ).
address_lookup( `LE BOUVIER`, `92340`, `0021244589` ).
address_lookup( `D'ALSACE`, `92400`, `0019957154` ).
address_lookup( `COROLLES`, `92400`, `0020710409` ).
address_lookup( `2 GARES`, `92500`, `0020890599` ).
address_lookup( `SAINTE CLAIRE DEVILLE`, `92500`, `0021388285` ).
address_lookup( `MICHELET`, `92800`, `0020652425` ).
address_lookup( `LA RESISTANCE`, `93100`, `0020517707` ).
address_lookup( `VOLTAIRE`, `93100`, `0021335626` ).
address_lookup( `MONTAIGNE`, `93160`, `0021516292` ).
address_lookup( `CORNILLONS NORD`, `93200`, `0022091057` ).
address_lookup( `FRUITIERS`, `93210`, `0020370896` ).
address_lookup( `JEAN MARTIN`, `93400`, `0015601580` ).
address_lookup( `NICOLAU`, `93400`, `0020964243` ).
address_lookup( `EAN-MARTIN`, `93400`, `0021341107` ).
address_lookup( `NICOLAU`, `93400`, `0021806979` ).
address_lookup( `GENERAL COMPANS`, `93500`, `0021790461` ).
address_lookup( `DU LYCEE`, `93500`, `0021877237` ).
address_lookup( `ERNEST RENAN`, `93500`, `0021918027` ).
address_lookup( `RUE JULES AUFFRET`, `93500`, `0022057040` ).
address_lookup( `QUARTIER  JULES AUFFRET`, `93700`, `0022115357` ).
address_lookup( `MINIMES`, `94160`, `0019167355` ).
address_lookup( `VOEUX SAINT-GEORGES`, `94290`, `0021347261` ).
address_lookup( `ORLY`, `94310`, `0021143688` ).
address_lookup( `DU LYCEE`, `95000`, `0020711807` ).
address_lookup( `PRINCESSE`, `95000`, `0021857226` ).
address_lookup( `GENERAL LECLERC`, `95120`, `0021667960` ).
address_lookup( `MARAIS`, `95130`, `0020898867` ).