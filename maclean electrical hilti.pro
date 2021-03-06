%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MACLEANS ELECTRICAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( macleans_electrical, `09 April 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( line, potential_quantity, `Potential quantity` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_address
	
	, get_order_number

	, get_invoice_date
	
	, get_buyer_details

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

	, buyer_registration_number( `GB-JOHNMAC` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12260436` )
	
	, delivery_party( `JOHN MACLEAN & SONS` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `No`, `:` ], order_number, s1 ] ) 
  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Order`, `Date`, `:` ], invoice_date, date, newline ] ) 
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_details, [ qn0(line), buyer_details_line ] ).
%=======================================================================
i_line_rule( buyer_details_line, [
%=======================================================================

	  q(0,5,word), `queries`
	  
	, `please`, `contact`
	
	, buyer_contact(w)
	
	, append( buyer_contact(w), ` `, `` )
	
	, `on`
	
	, generic_item( [ buyer_ddi, sf, `,` ] )
	
	, `or`, `email`
	
	, generic_item( [ buyer_email, s1, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q(0,10, line), delivery_header_line
	  
	, q10( line ), delivery_thing( [ delivery_street, s1 ] )
	
	, delivery_thing( [ delivery_street, s1 ] )
	
	, q10( line ), delivery_thing( [ delivery_city, s1 ] )
	
	, q10( line ), delivery_thing( [ delivery_postcode, pc ] )
	
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ `Supplier`, tab, delivery_hook(s1), tab, `Details` ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable, Parameter ] ), [
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	  
	, peek_fails( [ `United`, `Kingdom` ] )
	  
	, Read_Variable
	
	, trace( [ String, Variable ] )
	
] ):-

	  Read_Variable =.. [ Variable, Parameter ]
	, sys_string_atom( String, Variable )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Total` ], total_net, d, newline ] )
	  
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
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `VAT`, `Reg`, `No` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line( [ Left, Right ] )
	 
	, trace( [ `found header` ] )

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

	  q0n(anything)
	  
	, read_ahead( [ `Product`, `Code`, `/`, `Description` ] )

	, descr(s1), tab
	
	, check( descr(start) = Left_x )
	
	, check( sys_calculate( Left, Left_x - 5 ) )
	
	, qty(w)
	
	, check( qty(start) = Right_x )
	
	, check( sys_calculate( Right, Right_x - 40 ) )
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [  
%=======================================================================

	or( [ [ `Please`, `check`, `this`, `Order` ]
	
		, [ q0n(anything), `Total` ] 
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule( [ Left, Right ] ), [
%=======================================================================

	  read_ahead( line_invoice_line )
	  
	, or( [ [ gen1_parse_text_rule( [ Left, Right, or( [ line_check_line, line_end_line ] )
												, line_item, [ begin, q(dec,4,10), end ] ] )
		]
		
		, [ gen1_parse_text_rule( [ Left, Right, or( [ line_check_line, line_end_line ] )
												, thing, [ begin, q(any,1,10), end ] ] )
												
			, line_item( `Missing` )
												
		]
		
	] )

	, or( [ [ check( i_user_check( search_for_a_pack_size, captured_text, Pack ) )
	
			, check( sys_calculate_str_multiply( Pack, potential_quantity, Qty ) )
			
			, trace( [ `found quantity in text` ] )
			
		]
	
		, check( potential_quantity = Qty )
		
	] )
	
	, line_quantity( Qty )
	
	, trace( [ `line quantity`, line_quantity ] )
	
	, check( captured_text = Text ), line_descr( Text )
	
	, q10( [ check( i_user_check( check_for_delivery, Text ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
		
	, trace( [ `line descr from page`, line_descr ] )
	
] ).

%=======================================================================
i_user_check( search_for_a_pack_size, Text, Pack ):-
%=======================================================================

	  string_to_lower( Text, Text_L )
	, string_string_replace( Text_L, `(`, ` ( `, Text_1 )
	, string_string_replace( Text_1, `)`, ` ) `, Text_2 )
	, string_string_replace( Text_2, `ea`, ` ea `, Text_3 )
	, string_string_replace( Text_3, `pk`, ` pk `, Text_4 )
	, string_string_replace( Text_4, `pack`, ` pack `, Text_5 )
	, strip_string2_from_string1( Text_5, `/`, Text_6 )
	, sys_string_split( Text_6, ` `, Text_Split )
	, ( sys_append( _, [ Before, Pack | _ ], Text_Split )
		, before_words( Before )
	
	;	sys_append( _, [ Pack, After | _ ], Text_Split )
		, after_words( After )
		
	)
	
	, regexp_match( `^([\\d]{2,4})$`, Pack, _ )	
.

before_words( `pack` ).
before_words( `pk` ).

after_words( `pk` ).
after_words( `)` ).

%=======================================================================
i_line_rule_cut( line_check_line, [ q0n(anything), dummy(date) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, q10( tab ) ] )
	  
	, generic_item( [ tag_no, d, tab ] )
	
	, generic_item( [ dummy_descr, s1, tab ] )
	
	, generic_item( [ potential_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount_x, d, tab ] )
	
	, generic_item( [ per, s1, tab ] )
	
	, generic_item( [ line_original_order_date_x, date, tab ] )

	, generic_item( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage` ] )
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