%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US KIMBEL MECHANICAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_kimbel_mechanical, `23 June 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_id, `Delivery ID` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

i_op_param( xml_transform( Var, In ), _, _, _, Out )
:-
	q_sys_member( Var, [ delivery_ddi, buyer_ddi ] ),
	extract_pattern_from_back( In, Out, [ dec,dec,dec,`-`,dec,dec,dec,`-`,dec,dec,dec ] )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, check_for_out_of_town
	, get_delivery_details
	
	, get_buyer_contact
	, get_buyer_ddi

	, get_order_date
	, get_order_number
	
	, get_customer_comments
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_totals
	, get_invoice_lines

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
	  [ test(test_flag), suppliers_code_for_buyer( `11265718` ) ]    %TEST
	    , suppliers_code_for_buyer( `13257753` )                      %PROD
	]) ]

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `01` )	
	, cost_centre( `Standard` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_out_of_town, [ 
%=======================================================================

	q(0,50,line), generic_horizontal_details( [ [ `Out`, `Of`, `Town` ] ] )
	
	, set( out_of_town )
	
] ).

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,50,line)
	  
	, or( [ [ peek_fails( test( out_of_town ) )
			, generic_horizontal_details( [ read_ahead( [ `Kimbel`, `Mechanical` ] ), delivery_party, s1 ] )
			
			, generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), delivery_street, s1 ] )

			, generic_line( [ [ nearest( delivery_party(start), 10, 10 ), delivery_city(sf), q10( `,` )
				, delivery_state( f( [ begin, q(alpha,2,2), end ] ) )
				, delivery_postcode( f( [ begin, q(dec,4,5), end ] ) )
			] ] )
			
			, trace( [ `Delivery stuff`, delivery_city, delivery_state, delivery_postcode ] )
			
		]
		
		, [ test( out_of_town )
		
			, delivery_party( `map address from Delivery note in IDOC` )
		]
	] )
	
] ).

%=======================================================================
i_line_rule( delivery_address_in_a_line, [ 
%=======================================================================

	`Delivery`, `Notes`
	
	, delivery_address_in_a_rule

] ).
	
%=======================================================================
i_rule( delivery_address_in_a_rule, [ 
%=======================================================================

	q0n(word), or( [ [ `Address`, `:` ], `at` ] )

	, read_ahead( generic_item( [ dummy, s1 ] ) )
	
	, generic_item( [ delivery_street, sf, `,` ] )
	, q10( [ delivery_city(sf), `,` ] )
	, delivery_state( f( [ begin, q(alpha,2,2), end ] ) ), q10( `,` )
	, delivery_postcode( f( [ begin, q(dec,4,5), end ] ) )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER & DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q(0,50,line)
	
	, generic_horizontal_details( [ [ `PO`, `#`, `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q(0,50,line)
	
	, or( [ generic_horizontal_details( [ [ `Delivery`, `Date` ], invoice_date, date ] )
	
		, [ generic_line( [ [ `Delivery`, `Date`, newline ] ] )
		
			, generic_horizontal_details( [ invoice_date, date ] )
		]
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

	  q(0,30,line)
	  
	, generic_horizontal_details( [ [ `Submitted`, `By`, `:` ], buyer_contact_x, s1 ] )
	
	, check( buyer_contact_x = ConX )
	, check( string_string_replace( ConX, `.`, ` `, ConRep ) )
	, check( string_to_capitalised( ConRep, Con ) )
	
	, check( strcat_list( [ ConX, `@kimbelmechanical.com` ], Email ) )
	
	, buyer_contact( Con )
	, delivery_contact( Con )
	
	, buyer_email( Email )
	, delivery_email( Email )
	
	, trace( [ `Buyer Contact`, Con ] )
	, trace( [ `Buyer Email`, Email ] )

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,40,line)
	  
	, generic_horizontal_details( [ [ `Kimbel`, `Mechanical` ] ] )
	
	, q(0,7,line)

	, generic_horizontal_details( [ [ at_start, read_ahead( `(` ) ], buyer_ddi, s1 ] )
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	q(0,50,line)
	
	, or( [ generic_horizontal_details( [ [ `Delivery`, `Notes` ], customer_comments, s1 ] )
	
		, [ read_ahead( [ generic_horizontal_details( [ read_ahead( [ at_start, `Delivery` ] ), hook, w ] ), generic_line( [ `Notes` ] ) ] )
			, check( hook(end) = Left )
			, generic_line( 2, Left, 500, [ customer_comments(s1) ] )
		]
	] )	
	
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
	  
	, generic_horizontal_details( [ `Total`, total_net, d, newline ] )
	
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
	
	, q10( generic_line( [ [ `Units`, tab, `Total` ] ] ) )

	, trace( [ `found header` ] )

	, q0n( [

		  or( [ line_invoice_rule

			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `ID`, tab, `Description`, tab, quantity_hook(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Total` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	peek_ahead( gen_count_lines( [ or( [ line_invoice_line, line_end_line ] ), Count ] ) )
	
	, trace( [ `Count`, Count ] )
	
	, q10( [ check( Count > 0 ), line_descr_line( Count ) ] )
	
	, line_invoice_line
	
	, q10( [ check( Count > 0 ), peek_fails( line_end_line ), line_descr_line( Count ) ] )
	
	, clear( descr )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	generic_item_cut( [ some_id, d, q10( tab ) ] )

	, q10( or( [
	
			[ test( descr ), append( line_descr(s1), ` `, `` ) ]
	
			, [ line_descr(s)
				, q(1,2, or( [ `#`, `(` ] ) )
				, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], [ q10( `)` ), q10( tab ) ] ] )
			]
		
			, [ line_descr(s1), tab, line_item( `Missing` ) ]
		
	] ) )

	, trace( [ `Line Descr`, line_descr ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item_cut( [ line_quantity_uom_code_x, w, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )
	
	, generic_item_cut( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	  q10( read_ahead( [ q0n(word), or( [ `#`, `(` ] ), generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ] ) )

	, or( [
	
		[ test( descr ), append( line_descr(s1), ` `, `` ) ]
		
		, [ generic_item( [ line_descr, s1 ] ), set( descr ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).