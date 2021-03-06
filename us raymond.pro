%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US RAYMOND
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_raymond, `03 July 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_id, `Delivery ID` ).

i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
e1edkt1_tdformat_value( `Z012`, `/` ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).
i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
e1edkt1_tdformat_value( `Z011`, `/` ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
e1edkt1_tdformat_value( `0012`, `/` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

i_op_param( xml_transform( Var, In ), _, _, _, Out )
:-
	q_sys_member( Var, [ delivery_ddi, buyer_ddi ] ),
	extract_pattern_from_back( In, Out, [ dec,dec,dec,`-`,dec,dec,dec,`-`,dec,dec,dec ] )
.
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_details
	
	, get_buyer_contact
	, get_buyer_ddi
	, get_buyer_email
	
	, get_delivery_contact

	, get_order_date
	, get_order_number
	
	, check_job
	, write_comments
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	, get_totals
	
	, set( enable_duplicate_check )

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

	%	May need to update this with lookup
	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10797490` ) ]    %TEST
	    , suppliers_code_for_buyer( `10797490` )                      %PROD
	]) ]

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `NN` )	
	, cost_centre( `hna:jobsite_next_am` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Customer Comments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_job, [ 
%=======================================================================

	q(0,15,line), generic_horizontal_details( [ [ `Job`, `:`, q10( tab ), `316777` ] ] )
	
	, set( extended_notes )
	
] ).

%=======================================================================
i_rule( write_comments, [ 
%=======================================================================

	xor( [ with( invoice, buyer_contact, BCon ), check( BCon = `` ) ] )
	, xor( [ with( invoice, buyer_ddi, BDDI ), check( BDDI = `` ) ] )
	
	, xor( [ with( invoice, delivery_contact, DCon ), check( DCon = `` ) ] )
	, xor( [ with( invoice, delivery_ddi, DDDI ), check( DDDI = `` ) ] )
	
	, xor( [ [ check( DCon = `` ), check( DDDI = `` ), check( DelSec = `` ) ]
		, [ check( DDDI = `` ), check( DelSec = DCon ) ]	
		, check( strcat_list( [ DCon, ` `, DDDI ], DelSec ) )
	] )
	
	, check( strcat_list( [ BCon, ` `, BDDI ], BuySec ) )
	
	, xor( [ [ test( extended_notes )
			, check( HeadWrap = `DELIVERY DRIVER:~DO NOT DELIVER TO COLLEGE LOADING DOCK~THIS IS A DELIVERY FOR THE JOBSITE ON THE BACK SIDE OF CAMPUS~` )
			, check( FootWrap = `~TO GET TO JOBSITE FROM MAIN ENTRANCE, TAKE FIRST LEFT AND FOLLOW~ROAD AROUND TO THE BACK OF CAMPUS WHERE JOBSITE IS.` )
		]
		
		, [ check( HeadWrap = `` ), check( FootWrap = `` ) ]
		
	] )
	
	, check( sys_stringlist_concat( [ `MUST CONTACT BEFORE ENTERING SITE`, BuySec, DelSec ], `~`, MiddleSec ) )
	
	, check( strcat_list( [ HeadWrap, MiddleSec, FootWrap ], Note ) )
	
	, shipping_instructions( Note ) 
	, picking_instructions( Note ) 
	, packing_instructions( Note ) 
	
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,30,line)
	  
	, generic_horizontal_details( [ [ at_start, `Ship`, `To` ], delivery_party, s1 ] )
	
	, generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), delivery_street, s1 ] )
	
	, q01( generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), delivery_address_line, s1 ] ) )

	, generic_line( [ [ nearest( delivery_party(start), 10, 10 ), delivery_city(sf), q10( `,` )
		, delivery_state( f( [ begin, q(alpha,2,2), end ] ) )
		, delivery_postcode( f( [ begin, q(dec,4,5), end ] ) )
	] ] )
	, trace( [ `Delivery stuff`, delivery_city, delivery_state, delivery_postcode ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER & DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q(0,10,line)
	
	, generic_vertical_details( [ [ `Purchase`, `Order`, newline ], `Order`, q(0,1), (end,10,10), order_number, s1, newline ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Date`, `:` ], invoice_date, date ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [ buyer_email( From ) ] ):- i_mail( from, From ).
%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  last_line, q(0,10,up)
	  
	, generic_horizontal_details( [ [ `Ordered`, `By`, `:` ], buyer_contact, s1 ] )

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ at_start, `P`, `:` ], buyer_ddi, s1 ] )
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Onsite`, `Contact`, `:` ], delivery_contact, sf, [ q10( [ read_ahead( `(` ), delivery_ddi(s1) ] ), newline ] ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  qn0(line)
	  
	, generic_horizontal_details( [ `SubTotal`, 250, total_net, d, newline ] )
	
	, check( total_net = Net )
	, total_invoice( Net )
	
	, q10( [ check( q_sys_comp_str_eq( Net, `0` ) ), set( zero_value ) ] )
	
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
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [  line_invoice_rule
		  
			, [ test( zero_value ), line_check_line, force_result( `defect` ), force_sub_result( `missed_line` ) ]
		
			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`Code`, tab
	
	, q0n(anything), read_ahead( `Code` ), code_hook(w)
	, q0n(anything), read_ahead( `Description` ), descr_hook(w)
	, q0n(anything), read_ahead( `Agr` ), agr_hook(w)
	, q0n(anything), read_ahead( `Unit` ), unit_hook(w)
	, q0n(anything), read_ahead( `Order` ), order_hook(w)
	, q0n(anything), read_ahead( `Unit` ), price_hook(w)
	, q0n(anything), read_ahead( `Extended` ), total_hook(w)
	
] ).
	
	
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ `SubTotal`, [ dummy, check( dummy(page) \= code_hook(page) ) ] ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  check( code_hook(start) = Code )
	  
	, read_ahead( [ 
		line_invoice_line
		, q10( generic_line( [ [ peek_fails( test( no_lifb ) ), retab( [ Code ] ), append( line_item_for_buyer(s1), ``, `` ) ] ] ) )
	] )

	, check( descr_hook(start) = Left )
	, check( agr_hook(start) = Right )
	
	, or( [ gen1_parse_text_rule( [ Left, Right, or( [ line_check_line, line_end_line ] ), or( [ `#`, `(`, `PART` ] )
				, line_item, [ begin, q(dec,4,10), end ] 
			] )
		, [ gen1_parse_text_rule( [ Left, Right, or( [ line_check_line, line_end_line ] ) ] ), line_item( `Missing` ) ]
		
	] )
	
	, check( captured_text = Descr )
	, line_descr( Descr )
	
	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
	, clear( no_lifb )
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ q0n(anything), q(2,2,[ tab, num(d) ] ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	check( code_hook(start) = Code )
	, check( descr_hook(start) = Descr )
	, check( agr_hook(start) = Agr  )
	, check( unit_hook(start) = Unit )
	, check( order_hook(start) = Order )
	, check( price_hook(start) = Price )
	, check( total_hook(start) = Total )
	
	, retab( [ Code, Descr, Agr, Unit, Order, Price, Total ] )

	, or( [ generic_item_cut( [ line_item_for_buyer, s1, tab ] )
		, [ set( no_lifb ), tab ]
	] )
	, generic_item_cut( [ cost_code, s1, tab ] )

	, generic_item_cut( [ dummy_descr, s1, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d ] )
	, or( [ generic_item_cut( [ line_price_uom_code_x, s1, tab ] ), tab ] )

	, generic_item_cut( [ unit_size, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d ] )
	, generic_item_cut( [ line_quantity_uom_code_x, w, tab ] )

	, generic_item_cut( [ line_unit_amount_x, d, tab ] )
	
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

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport`, `shipping` ] )
	, q_sys_sub_string( Delivery_L, _, _, Delivery_Word )
	, trace( `delivery line, line being ignored` )
.