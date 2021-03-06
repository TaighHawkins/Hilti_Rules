%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - OCL FACADES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ocl_facades, `05 February 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_location
	
	, get_order_number

	, get_invoice_date
	
	, get_due_date

	, get_delivery_contact_and_ddi
	
	, get_buyer_email
	
	, get_buyer_contact

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

	, buyer_registration_number( `GB-OCL` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `16519459` )
	
	, delivery_party( `OCL FACADES LTD` )
	
	, buyer_ddi( `01268407900` )

	, sender_name( `OCL Facades Limited` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `PURCHASE`, `ORDER` ], order_number, s1 ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Order`, `Date`, `:` ], invoice_date, date, newline ] ) 
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Delivery`, `Date`, `:` ], due_date, date, newline ] ) 
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [ buyer_email( From ) ] ):-
%=======================================================================
	
	  i_mail( from, From )
.

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,4,line), generic_horizontal_details( [ [ `Contact`, `:` ], buyer_contact, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_delivery_contact_and_ddi, [ q0n(line), delivery_contact_and_ddi_line ] ).
%=======================================================================
i_line_rule( delivery_contact_and_ddi_line, [
%=======================================================================
	
	  q10( `Site` ), or( [ `Contacts`, `Contact` ] ), `:`
	  
	, generic_item( [ delivery_contact, sf ] )
	
	, read_ahead( dummy(d) )
	
	, generic_item( [ delivery_ddi, sf, or( [ dummy(f( [ q(alpha,1,10) ] ) ), `or`, newline ] ) ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [
%=======================================================================

	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ `Contract`, `:` ], delivery_location, s1 ] )
	
] ).

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(10,30,line), read_ahead( delivery_address_header_line )
	  
	, q10( delivery_address_item( 1, -310, 0, [ delivery_trash, s1 ] ) )

	, q10( gen_line_nothing_here( [ -300, 10, 10 ] ) )

	, delivery_address_item( 1, -310, 0, [ delivery_street, s1 ] )

	, q10( gen_line_nothing_here( [ -300, 10, 10 ] ) )	

	, q( 2, 0, delivery_address_item( 1, -310, 0, [ delivery_trash, s1 ] ) )
	
	, q10( gen_line_nothing_here( [ -300, 10, 10 ] ) )	

	, or( [ delivery_city_and_postcode_line
	
		, [ delivery_address_item( 1, -310, 0, [ delivery_city, s1 ] )
		
			, delivery_address_item( 1, -310, 0, [ delivery_postcode, pc ] )
			
		]
		
	] )
	
] ).

%=======================================================================
i_line_rule( delivery_address_header_line, [ read_ahead( `Delivery` ), delivery(w), check( delivery(start) < -250 ) ] ).
%=======================================================================
i_line_rule( delivery_address_item( [ Variable, Parameter ] ), [ generic_item( [ Variable, Parameter ] ) ] ).
%=======================================================================
i_line_rule( delivery_city_and_postcode_line, [
%=======================================================================

	  generic_item( [ delivery_city, sf ] )
	
	, generic_item( [ delivery_postcode, pc ] ) 
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Order`, `Value`, tab, `£` ], total_net, d, newline ] )
	  
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

	 line_header_line( [ Left, Right ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule( [ Left, Right ] )
	
			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line( [ Left, Right ] ), [
%=======================================================================

	  `Your`, `Ref`, tab
	  
	, `Our`, `Ref`, tab
	  
	, descr(w), tab
	
	, read_ahead( `Quantity` )
	
	, qty(w)
	
	, check( descr(start) = Left_x )
	
	, check( sys_calculate( Left, Left_x - 5 ) )
	
	, check( qty(start) = Right_x )
	
	, check( sys_calculate( Right, Right_x - 5 ) )
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `Authorised`, `By` ], [ `Page`, num(d) ] ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule( [ Left, Right ] ), [
%=======================================================================

	  read_ahead( line_invoice_line )

	, gen1_parse_text_rule( [ Left, Right, or( [ line_check_line, line_end_line ] )
												, dummy, [ begin, q(any,1,10), end ] ] )
												
	, check( captured_text = Text ), line_descr( Text )
	
	, q10( [ check( i_user_check( check_for_delivery, Text ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, or( [ [ without( delivery_charge ), delivery_charge( Net ) ]
		
			, [ with( delivery_charge )
				, check( delivery_charge = Del )
				, check( sys_calculate_str_add( Del, Net, NewNet ) )
				, delivery_charge( NewNet )
			]
		] )
	
	] )
		
	, trace( [ `line descr from page`, line_descr ] )
	
	, count_rule
	
	, q10( [ with( invoice, due_date, Date )	
		, line_original_order_date( Date )
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ or( [ [ `Authorised`, `by` ], [ q0n(anything), `£` ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  q10( generic_item( [ some_item, s1, tab ] ) )
	  
	, or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
		, line_item( `Missing` )
		
	] )
	
	, generic_item( [ dummy_descr, s1, tab ] )

	, generic_item( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, [ `£`, q10( tab ) ] ] )

	, generic_item( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `frieght`, `carriage`, `haulage` ] )
	, trace( `delivery line, line being ignored` )
.

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).