%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - LEIGHTON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( leighton, `03 July 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

custom_e1edka1_segment( `ZH`, `PARTN`, `HAU2521` ):- grammar_set( 11126626 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
		
	, get_order_number
	
	, get_order_date
	
	, get_buyer_contact
	
	, get_delivery_note_number
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `AU-ADAPTRI` )

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Leighton Contractors Pty Ltd` )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Purchase`, `Order` ], order_number, s1 ] ) 
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ invoice_date, date ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Requester`, `/`, `Deliver` ] ] )
	  
	, generic_line( [ [ nearest_word( generic_hook(start), 2, 10 ), generic_item( [ buyer_contact, s1 ] ) ] ] )

	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_rule( get_totals, [ qn0(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  `Total`, `:`
	  
	, read_ahead( [ generic_item( [ total_net, d ] ) ] )
	
	, generic_item( [ total_invoice, d ] )
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_number, [ 
%=======================================================================

	  q(0,30,line), read_ahead( generic_horizontal_details( [ [ `Ship`, `To` ] ] ) )
	 
	, gen1_parse_text_rule( [ -360, 60, generic_line( [ [ `Customer`, tab, `Supplier` ] ] ) ] )
	, trace( [ `Captured`, captured_text ] )
	
	, check( i_user_check( perform_address_lookup, captured_text, DNN ) )
	
	, delivery_note_number( DNN )
	, trace( [ `Delivery Note Number`, DNN ] )
	
	, or( [ [ check( DNN = `20968133` )
			, set( 11126626 )
			, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10493821` ) ]
				, suppliers_code_for_buyer( `11126626` )
			] )
			, type_of_supply( `SX` )
		]
		
		, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10483878` ) ]
				, suppliers_code_for_buyer( `11126615` )
			] )
	] )

] ).

%=======================================================================
i_user_check( perform_address_lookup, TextIn, DNN )
%=======================================================================
:-
	string_to_upper( TextIn, TextInU ),
	address_lookup( State, Street, PC, DNN ),
	trace( [ `Trying`, DNN ] ),
	( DNN = `Missing`
		->	true
		
		;	( PC \= `` -> q_sys_sub_string( TextInU, _, _, PC ); true ),
			( State \= `` -> q_sys_sub_string( TextInU, _, _, State ); true ),
			q_sys_sub_string( TextInU, _, _, Street )
	)
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		or( [  line_invoice_line
		
			, line_continuation_line
		
			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `(`, `AUD`, `)`, tab, `(` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `Total`, `:` ], [ `Authorised`, `Officer` ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, or( [ [ q10( qn0( or( [ `Code`, `:`, `-`, `.` ] ) ) )
			, generic_item( [ line_item, [ begin, q(dec,4,10), end ], q10( `-` ) ] )
		]
	
		, line_item( `Missing` )
		
	] )

	, generic_item_cut( [ line_descr, s, [ q10( tab ), or( [ `Needed`, [ `Promised`, `Date` ] ] ), `:`, tab ] ] )

	, generic_item_cut( [ line_quantity, d ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ 
%=======================================================================

	generic_item_cut( [ dummy_descr, s, check( dummy_descr(end) < -120 ) ] )
	
	, check( dummy_descr = Descr )
	
	, append( line_descr(Descr), ` `, `` )
	
	, q01( [ q10( tab ), dum(d), `-`, word, `-`, dum(d) ] ), newline 
	
] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` :-`, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage` ] )
	, trace( `delivery line, line being ignored` )
.

address_lookup( `DARWIN`, ``, ``, `20968133` ).
address_lookup( `ACTON`, `MARCUS CLARKE ST`, `2601`, `16634049` ).
address_lookup( `ARNCLIFFE`, `46-50 WEST BOTANY ST`, `2205`, `20289404` ).
address_lookup( `BALLINA`, `CNR TEVEN RD & PACIFIC HWY`, `2478`, `16685295` ).
address_lookup( `BEECROFT`, `WONGALA RD`, `2119`, `21655700` ).
address_lookup( `BIBRA LAKE`, `LOT 50 PHOENIX RD`, `6163`, `20674444` ).
address_lookup( `BOGGABRI`, `395 LEARDS FORREST RD`, `2382`, `21479702` ).
address_lookup( `BOW BOWING`, `BOUDDI ST`, `2566`, `20300043` ).
address_lookup( `CANLEY VALE`, `WEST ST, OFF BAREENA ST`, `2166`, `20897217` ).
address_lookup( `CASULA`, `45 GLENFIELD RD-ADJACENT RAILWAY`, `2170`, `20031357` ).
address_lookup( `CHATSWOOD`, `LVL 4, TOWER A, 799 PACIFIC HWY`, `2067`, `21647251` ).
address_lookup( `CHATSWOOD`, `465 VICTORIA AVE`, `2057`, `19020824` ).
address_lookup( `CHATSWOOD`, `465 VICTORIA ST`, `2057`, `19018597` ).
address_lookup( `CHRISTIES BEACH`, `MARINE DRIVE`, `5165`, `18435183` ).
address_lookup( `COFFS HARBOUR`, `CRN INDUSTRIAL DR & ENGINEERING DR`, `2450`, `21786021` ).
address_lookup( `COFFS HARBOUR`, `CNR INDUSTRIAL DR & ENGINEERING DR`, `2450`, `19171018` ).
address_lookup( `CROWS NEST`, `LEVEL 3, 11-15 FALCON ST`, `2065`, `20409464` ).
address_lookup( `DARRA`, `67 BERNOULLI ST`, `4076`, `20126364` ).
address_lookup( `ELLERSLIE`, `WENTWORTH POONCARIE RD`, `2729`, `20641406` ).
address_lookup( `EMERALD BEACH`, `1800 PACIFIC HWY`, `2456`, `18676713` ).
address_lookup( `FORTITUDE VALLEY`, `520 WICKHAM ST`, `4006`, `20759635` ).
address_lookup( `GARRAN`, `CNR GILLMORE & HOSPITAL RD`, `2605`, `20521398` ).
address_lookup( `HAYMARKET`, `LEE ST`, `2000`, `21879353` ).
address_lookup( `HENDERSON`, `AMC MARINE BASE 124 QUILL WAY`, `6166`, `20004073` ).
address_lookup( `HENDERSON`, `124 QUILL WAY`, `6166`, `20658842` ).
address_lookup( `HEXHAM`, `230 OLD MAITLAND RD`, `2322`, `21592548` ).
address_lookup( `KARRATHA`, `LOT 2543 COOLAWANYAH RD`, `6714`, `21723943` ).
address_lookup( `KEMPSEY`, `247 OLD STATION RD`, `2440`, `19131629` ).
address_lookup( `KUNUNURRA`, `CNR WEAVER PLAIN & CARLTON HILL RD`, `6743`, `19407115` ).
address_lookup( `KUNUNURRA`, `24 KONERBERRY RD`, `6743`, `19463254` ).
address_lookup( `LIVERPOOL`, `GATE 202C SHEPHERD ST UNDERBRIDGE`, `2170`, `20319486` ).
address_lookup( `MACARTHUR`, `1743 MACARTHUR-HAWKESDALE RD`, `3286`, `19907739` ).
address_lookup( `MACQUARIE PARK`, `CHRISTIE RD COMPOUND`, `2113`, `19221548` ).
address_lookup( `MAITLAND`, `22 ST ANDREWS RD`, `2320`, `19383868` ).
address_lookup( `MEDOWIE`, `529 MEDOWIE RD`, `2318`, `19739493` ).
address_lookup( `MELBOURNE AIRPORT`, `TERMINAL 4, SERVICE RD`, `3045`, `21916772` ).
address_lookup( `MICKLEHAM`, `135 DONNYBROOK RD`, `3064`, `21653005` ).
address_lookup( `MOUNT ISA`, `LOT 10 DIAMANTINA DEVELOPMENT RD`, `4825`, `21084800` ).
address_lookup( `NORTH ROCKS`, `PERRY ST (OFF BARCLAY RD)`, `2151`, `19154068` ).
address_lookup( `NORTH RYDE`, `25-27 EPPING RD`, `2113`, `21694557` ).
address_lookup( `NORTH RYDE`, `1-25 DELHI RD`, `2113`, `20499098` ).
address_lookup( `NORTH RYDE`, `OFF DELHI RD`, `2113`, `18869867` ).
address_lookup( `NORTH RYDE`, `CNR WICKS & WATERLOO RD`, `2113`, `19086269` ).
address_lookup( `NORTH SYDNEY`, `CNR PACIFIC HWY & BERRY ST`, `2060`, `21383663` ).
address_lookup( `NORTH TARCUTTA`, `45 HUME HWY`, `2652`, `18480401` ).
address_lookup( `SPEARWOOD`, `GCSB, CNR PHOENIX AND SUDLOW RD`, `6163`, `20276264` ).
address_lookup( `PERTH`, `202 PIER ST`, `6000`, `18461059` ).
address_lookup( `PINJARRA`, `ALCOA RD`, `6208`, `19433963` ).
address_lookup( `PORT HEADLAND`, `CNR OF PINGA & CARJINA RD`, `6722`, `21658957` ).
address_lookup( `PORT HEDLAND`, `2 TAYLOR ST`, `6221`, `20785405` ).
address_lookup( `SINGLETON`, `MIDDLE FALLBROOK RD`, `2330`, `19956126` ).
address_lookup( `SOUTHKEMPSEY`, `247 OLD STATION RD`, `2440`, `18454659` ).
address_lookup( `SPEARWOOD`, `SUDLOW RD AWH PTY LTD, GATE 3`, `6163`, `19611479` ).
address_lookup( `ST LEONARDS`, `472 PACIFIC HWY`, `2065`, `11126615` ).
address_lookup( `THORNBURY`, `15A ANDERSON ROAD`, `3071`, `20766946` ).
address_lookup( `THORNTON`, `28 HUNTINGDALE DRIVE`, `2323`, `21312456` ).
address_lookup( `TOM PRICE`, `WHITE QUARTZ RD`, `6751`, `20178531` ).
address_lookup( `TULLAMARINE`, `GATE 1, MELROSE DR`, `3043`, `21356137` ).
address_lookup( `VIA NEWMAN`, `OFF GREAT NORTHERN HIGHWAY`, `6753`, `20241764` ).
address_lookup( `SPEARWOOD`, `SUDLOW RD SAIPEM LEIGHTON CONSORTIUM SHED 1, DOOR 2`, `6163`, `20001491` ).
address_lookup( `WATTLEUP`, `MOYLAN ROAD`, `6166`, `21945368` ).
address_lookup( `WEDGEFIELD`, `CAJARINA & PINGA ST`, `6721`, `21671903` ).
address_lookup( `WEDGEFIELD`, `CAJARINA & PINGA ST`, `6721`, `21671904` ).
address_lookup( `WELSHPOOL`, `16-30 SHEFFIELD RD`, `6106`, `21692042` ).
address_lookup( `WELSHPOOL`, `16-30 SHEFFIELD RD`, `6106`, `21647212` ).
address_lookup( `WEST BALLINA`, `CNR OF PACIFIC MWY-BRUXNER`, `2478`, `21633704` ).
address_lookup( `WHYALLA`, `LINCOLN HIGHWAY`, `5600`, `20190081` ).
address_lookup( `WILLOW TREE`, `NEW ENGLAND HWY`, `2339`, `20721676` ).
address_lookup( `WODEN`, `CNR YAMBA DR & KITCHENER ST`, `2606`, `19170880` ).
address_lookup( `WOOLLOOMOOLOO`, `131 CATHEDERAL ST`, `2011`, `20101230` ).
address_lookup( `WOOLLOOMOOLOO`, `43 BOURKE ST`, `2011`, `16671486` ).


address_lookup( ``, ``, ``, `Missing` ).