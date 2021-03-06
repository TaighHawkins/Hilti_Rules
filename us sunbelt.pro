%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US SUNBELT RENTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_sunbelt_rentals, `10 July 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_user_field( invoice, lktext, `LKTEXT` ).
i_user_field( invoice, edi_customer_info, `EDI Customer Info` ).
i_orders05_idocs_e1edkt1( `Z016`, edi_customer_info ).

i_op_param( xml_empty_tags( `LKTEXT` ), _, _, _, LK ):- grammar_set( air ), result( _, invoice, lktext, LK ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

%=======================================================================
i_page_split_rule_list( [ check_for_sunbelt_tools_section ] ).
%=======================================================================
i_section( check_for_sunbelt_tools_section, [ check_for_sunbelt_tools_line ] ).
%=======================================================================
i_line_rule_cut( check_for_sunbelt_tools_line, [ 
%=======================================================================
	`If`, `you`, `have`, `a`, `problem`, `with`, `this`, `transmission`
	, `please`, `call`, `the`, `number`, `listed`, `above`, `.`,  newline
	
	, set( chain, `us sunbelt tools` ), trace( [ `Chaining to Sunbelt Tools` ] ) 
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_location

	, get_order_date
	
	, get_order_number
	
	, get_due_date
	
	, get_type_of_supply
	
	, get_air_delivery_vars
	
	, get_buyer_contact
	
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

	, buyer_registration_number( `US-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11262031` ) ]    %TEST
	    , suppliers_code_for_buyer( `10754887` )                      %PROD
	]) ]

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `01` )
	
	, cost_centre( `Standard` )

	, sender_name( `Sunbelt Rentals` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	  q(0,100,line), generic_horizontal_details( [ [ `Ship`, `To` ] ] )
	  
	, or( [ [ q(0,5,line), generic_horizontal_details( [ [ at_start, q0n(word), set( regexp_cross_word_boundaries ) ], delivery_location, [ begin, q(alpha("PC"),2,2), q(dec,3,3), end ] ] ) ]
		, [ q(0,5,line), generic_horizontal_details( [ [ set( regexp_cross_word_boundaries ) ], delivery_location, [ begin, q(alpha("PC"),2,2), q(dec,3,3), end ] ] ) ]
	] )
	, clear( regexp_cross_word_boundaries )
	
	, q10( [ check( delivery_location = `PC015` )
		, generic_horizontal_details( [ [ at_start, q0n(word)
			, or( [ [ `17950`, remove( delivery_location ), delivery_location( `PC351` ) ]
				, [ `18455`, remove( delivery_location ), delivery_location( `PC351 - Shop` ) ]
			] )
		] ] )
	] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER & DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), `Purchase`, `Order`, `#` ], 400, order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Order`, `Date` ], 400, invoice_date, date ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Requested`, `Date` ], 400, due_date, date ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TYPE OF SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_type_of_supply, [ 
%=======================================================================

	q0n(line), generic_horizontal_details( [ [ at_start, `Service`, `Level` ], 400, service, s1 ] )
	
	, check( service = Service )
	
	, or( [ [ check( Service = `GROUND` )
			, check( ToS = `01` )
		]
		
		, [ check( q_sys_member( Service, [ `AIR`, `AIR PRIORITY`, `NEXT DAY AIR` ] ) )
			, check( ToS = `N4` )
			, set( air )
			, contract_order_reference( `FCA` )
			
			, remove( cost_centre )
			, cost_centre( `HNA - Cust Acct` )
			
			, shipping_instructions( `SHIP NEXT DAY AIR VIA CUST FREIGHT ACCOUNT` )
			, picking_instructions( `SHIP NEXT DAY AIR VIA CUST FREIGHT ACCOUNT` )
			, packing_instructions( `SHIP NEXT DAY AIR VIA CUST FREIGHT ACCOUNT` )
		]
	] )
	
	, remove( type_of_supply )
	, type_of_supply( ToS )
	, trace( [ `Type of supply changed to`, ToS ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AIR DELIVERY VARS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_air_delivery_vars, [ 
%=======================================================================

	q0n(line), generic_horizontal_details( [ [ `Ship`, `To` ] ] )
	
	, q(0,5,line)
	
	, generic_horizontal_details( [ lktext, [ begin, q(alpha,2,2), end ]
		, [ check( lktext(end) < 0 ) 
			, check( lktext(font) = 1 )
		]
	] )
	
	, q(0,10,line)
	
	, generic_horizontal_details( [ [ `Carrier`, `Account`, `#` ], 500, buyers_code_for_location, s1 ] )
	
] ).
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Contact`, `Phone` ], 200, phone, s1 ] )
	  
	, q(0,5,line), generic_horizontal_details( [ [ at_start, `Ordered`, `By` ], 200, name, s1, [ tab, `Email`, q10( tab ), generic_item( [ email, s1 ] ) ] ] )
	
	, check( string_to_upper( name, NameU ) )
	, check( q_sys_sub_string( NameU, 1, 1, Initial ) )
	, check( q_sys_sub_string( NameU, 2, _, Sur ) )
	, check( phone = Phone )
	, check( email = Email )
	
	, check( strcat_list( [ `First Initial: `, Initial, `
`, `Last Name: `, Sur, `
`, `Phone #: `, Phone, `
`, `Email: `, Email ], EDI ) )

	, edi_customer_info( EDI )
	, trace( [ `EDI customer info`, EDI ] )

] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  qn0(line)
	  
	, read_ahead( generic_horizontal_details( [ [ or( [ at_start, tab ] ), `Total` ], total_net, d, newline ] ) )

	, check( total_net = Net )
	, total_invoice( Net )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [  line_invoice_rule
			
				, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Qty`, q10( tab ), `UOM`, q10( tab ), `Part`
	
	, q0n(anything), read_ahead( `WO` ), wo_hook(w) 
	
	, q0n(anything), read_ahead( `Equip` ), equip_hook(w) 
	
] ).
	
%=======================================================================
i_line_rule_cut( line_end_line, [ q0n( [ dummy(s1), tab ] ), `Total` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	
	  generic_item_cut( [ line_quantity, d, tab ] )
	  
	, generic_item_cut( [ line_quantity_uom_code_x, w, q10( tab ) ] )
	
	, or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
		, line_item( `Missing` )
	] )

	, generic_item_cut( [ line_descr, s, [ q10( tab ), check( line_descr(end) < wo_hook(start) ) ] ] )
	
	, q10( generic_item( [ wo_code, w
			, [ tab, check( wo_code(start) = WoStart )
				, check( wo_hook(start) = HookStart )
				, check( i_user_check( approx_equal, WoStart, HookStart ) ) 
			] 
		] ) 
	)
	
	, q10( generic_item( [ equip, w
			, [ tab, check( equip(start) = EquipStart )
				, check( equip_hook(start) = EqHookStart )
				, check( i_user_check( approx_equal, EquipStart, EqHookStart ) ) 
			] 
		] ) 
	)

	, generic_item_cut( [ line_unit_amount_x, d, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )

	, generic_item_cut( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).