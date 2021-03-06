%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BRIGGS & FORRESTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( briggs_and_forrester, `11 March 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_buyer_contact
	
	, get_delivery_contact
	
	, get_delivery_location

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

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

	, buyer_registration_number( `GB-BRIGMEP` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `15527259` )

	, sender_name( `Briggs & Forrester (MEP) Ltd.` )
	, delivery_party( `BRIGGS & FORRESTER (MEP) LIMITED` )
	
	, buyer_ddi( `01604720072` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,2,line), generic_horizontal_details( [ order_number, s1, [ tab, generic_item( [ invoice_date, date ] ) ] ] ) 
	 
	, generic_horizontal_details( [ due_date, date ] )
	  
	, q10( [ check( order_number = Order )
		, check( string_to_upper( Order, Order_U ) )
		, check( q_sys_sub_string( Order_U, 1, 2, `ES` ) )
		
		, remove( suppliers_code_for_buyer )
		, suppliers_code_for_buyer( `17119021` )
		
		, remove( buyer_registration_number )
		, buyer_registration_number( `GB-BRIGENG` )
		, set( es_order )
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  peek_fails( test( es_order ) )
	  
	, q(0,30,line), generic_horizontal_details( [ [ `FAO`, `:` ], buyer_contact, s1, check( buyer_contact(start) > 0 ) ] ) 

	, check( buyer_contact = Con )
	, check( string_string_replace( Con, ` `, `.`, Name ) )
	, check( strcat_list( [ Name, `@briggs.uk.com` ], Email ) )
	
	, buyer_email( Email )
	
] ).

%=======================================================================
i_rule( get_buyer_contact, [ test( es_order ), q0n(line), buyer_contact_line ] ).
%=======================================================================
i_line_rule( buyer_contact_line, [
%=======================================================================

	generic_item( [ buyer_contact, s1, [ check( buyer_contact(y) > 350 ), check( buyer_contact(start) < -400 ) ] ] )
	
] ).

%=======================================================================
i_rule( get_delivery_contact, [ test( es_order ), q0n(line), delivery_contact_line ] ).
%=======================================================================
i_line_rule( delivery_contact_line, [
%=======================================================================
	  
	  `Site`, `Contact`, q10( `is` )
	 
	, delivery_contact(w), append( delivery_contact(w), ` `, `` )
	, trace( [ `Delivery Contact`, delivery_contact ] )
	
	, q0n(word), `on`, generic_item( [ delivery_ddi, s1 ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	 q(0,2,line), q(2,2, generic_horizontal_details( [ some, date ] ) )

	, generic_horizontal_details( [ delivery_location, s1 ] ) 
	  
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
	  
	, generic_horizontal_details( [ [ `Total`, `Order`, `Value`, `:` ], total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
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

	, q0n( [

		  or( [ 
		
			  line_invoice_rule
	
			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `FAO` ] ), header_dummy(s1) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ q0n( [ dummy(s1), tab ] ), `Total`, `Order` ]
		
		, [ end_dummy(s1), check( end_dummy(page) > header_dummy(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, line_quantity_uom_code( `PC` )

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
	, q10( [ with( invoice, due_date, Date )
		, line_original_order_date( Date )
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, q10( `Hilti` ), or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ), line_item( `Missing` ) ] )

	, q10( generic_item( [ line_descr, s1 ] ) )
	
	, tab
	
	, generic_item( [ some_num, d, tab ] )
	
	, generic_item( [ some_uom, s1, tab ] )

	, generic_item_cut( [ line_unit_amount_x, d, tab ] )

	, generic_item_cut( [ line_net_amount, d,  [ q10( [ tab, generic_item( [ line_percent_discount_x, d ] ) ] ), newline ] ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  generic_item( [ extra_descr, s1, [ check( extra_descr(start) > -300 ), read_ahead( newline ) ] ] )
	  
	, check( extra_descr = Descr )
	
	, append( line_descr( Descr ), ` `, `` )
	
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
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport`, `quote`, `quotation` ] )
	, trace( `delivery line, line being ignored` )
.