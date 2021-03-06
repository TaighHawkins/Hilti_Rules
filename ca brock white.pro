%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CA BROCK WHITE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ca_brock_white, `13 August 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_pdf_parameter( same_line, 7 ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, buyer_dept, `Buyer Dept` ).


i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( line, line_item_098, `Line Item 098` ).
bespoke_e1edp19_segment( [ `098`, line_item_098 ] ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_delivery_details
	, check_shipping_method

	, get_order_date
	
	, get_order_number
	
	, get_buyer_contact
	, get_buyer_email

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, or( [ 
		[ test(test_flag), suppliers_code_for_buyer( `10453936` ) ]
		, suppliers_code_for_buyer( `21925063` )
	] )
	
	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `01` )
	
	, cost_centre( `Standard` )
	
	, sender_name( `Brock White Canada Co, LLC` )
	
	, set( no_uom_transform )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q10( [ read_ahead( [ q(0,30,line), generic_horizontal_details( [ [ `Invoice`, `To`, `:` ], invoice_to_name, s1 ] ) ] )
	  
		, check( string_to_lower( invoice_to_name, InvToName ) )
		
		, or( [ [ check( q_sys_sub_string( InvToName, _, _, `kelowna` ) )
				, set( kelowna )
				, delivery_note_number( `22007293` )
			]
			
			, [ check( q_sys_sub_string( InvToName, _, _, `thunder bay` ) )
				, set( thunder )
				, trace( [ `Found Thunder` ] )
			]
		] )
	] )
	
	, or( [ [ test( kelowna ), trace( [ `Kelowna detected, address NOT captured` ] ) ]
	
		, [ q(0,20,line), generic_horizontal_details( [ [ `Ship`, `To`, `:` ], delivery_party, s1 ] )
		
			, generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), delivery_street, s1 ] )
			
			, or( [ [ test( thunder )
					, trace( [ `Thunder` ] )
					, check( string_to_lower( delivery_street, StreetL ) )
					, trace( [ `Street Lower`, StreetL ] )
					, check( q_sys_sub_string( StreetL, _, _, `715 norah crescent` ) )
					, trace( [ `Found String` ] )
					, delivery_note_number( `10688130` )
					
					, remove( delivery_party )
					, remove( delivery_street )
					
					, shipping_instructions( `MUST SHIP NEXT DAY AIR` )
					, picking_instructions( `MUST SHIP NEXT DAY AIR` )
					, packing_instructions( `MUST SHIP NEXT DAY AIR` )
					
					, trace( [ `Thunder Bay detected, address NOT captured` ] )
					
					, q10( [ peek_fails( test( test_flag ) )
						, remove( suppliers_code_for_buyer )
						, suppliers_code_for_buyer( `10688130` )
					] )
				]
				
				, [ q(0,3, gen_line_nothing_here( [ delivery_party(start), 10, 10 ] ) )
					, delivery_city_state_and_postcode_line
				]
			] )
		]
	] )

] ).


%=======================================================================
i_line_rule( delivery_city_state_and_postcode_line, [
%=======================================================================

	nearest( delivery_party(start), 10, 10 )
	
	, generic_item( [ delivery_city, sf, q10( `,` ) ] )

	, q10( generic_item( [ delivery_state, w ] ) )
	
	, generic_item( [ delivery_postcode, sf
		, [ check( delivery_postcode = PC )
			, check( q_regexp_match( `^\\D\\d\\D.\\d\\D\\d$`, PC, _ ) ) 
		]
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,20,line), generic_vertical_details( [ [ `P`, `.`, `O`, `.`, `Date` ], invoice_date, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,20,line)
	
	, generic_vertical_details( [ [ `Order`, `No` ], order_number, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK SHIPPING METHOD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_shipping_method, [ 
%=======================================================================

	test( thunder )
	
	, q(0,30,line)
	, generic_vertical_details( [ [ `Via`, tab, `Freight` ], shipping_method, s1 ] )
	
	, check( string_to_lower( shipping_method, ShipL ) )
	, check( q_sys_sub_string( ShipL, _, _, `best way` ) )
	
	, remove( type_of_supply )
	, remove( cost_centre )
	
	, type_of_supply( `N7` )
	, cost_centre( `HNA:Air Priority` )
	
	, trace( [ `Cost Centre CHANGED` ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Buyer` ], 300, buyer_contact, s1 ] )

] ).

%=======================================================================
i_rule( get_buyer_email, [  
%=======================================================================

	q10( [ with( buyer_contact ), buyer_email( From ) ] )
	
	, q10( [ without( buyer_contact )
		, buyer_dept( Con )
	] )
	
] )
:- 
	i_mail( from, From ),
	sys_string_split( From, `@`, [ Names | _ ] ),
	strcat_list( [ `CABRW`, Names ], Con )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_invoice_rule
			
			, line

		] )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `No`, `.`, tab, `Item`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ num(d), or( [ `Line`, `Lines` ] ), `Total` ]
	
		, [ `Continued` ]
		
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, line_descr_line
	
	, q10( [ test( got_pc )
		, check( line_item = Item )
		, line_item_098( Item )
		, trace( [ `Populated 098 Item`, Item ] )
	] )
	
	, clear( got_pc )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, upc(d), tab
	
	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, or( [ [ or( [ `EA`, `Each`, `PC` ] ), line_quantity_uom_code( `PC` ), set( got_pc ) ]
	
		, word
		
	] ), tab
	
	, generic_item( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================
   
	  or( [ [ generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ] ] )
			, generic_item( [ line_descr, s1 ] )
		]
		
		, generic_item_cut( [ line_descr, s, [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], gen_eof ] ) ] ] )
		
		, [ generic_item_cut( [ line_dsecr, s1 ] ), line_item( `Missing` ) ]
		
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Purchase`, `Total`, `:` ], 250, total_invoice, d, newline ] )
	
	, check( total_invoice = Total )
	
	, total_net( Total )	
	
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