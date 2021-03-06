%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HSS HIRE HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hss_hire_hilti, `05 June 2014` ).

i_date_format( _ ).

i_user_field( invoice, street_two, `street two storage` ).

i_user_field( invoice, due_date_year, `due date year storage` ).
i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_invoice_date
	
	, get_delivery_address

	, get_delivery_contact

	, get_buyer_details

	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, get_transport_line

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

	, buyer_registration_number( `GB-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12263778` )           

	, delivery_party( `HSS HIRE SERVICE GROUP LTD` )
	
	, buyer_email( `sales@hss.com` )

	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ q( 0, 5, line ), generic_horizontal_details( [ [ `ORDER`, `NO` ], order_number, s1, newline ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ q( 0, 5, line ), generic_horizontal_details( [ [ `Date` ], invoice_date, date, tab ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q( 0, 5, line ), delivery_start_header

	, q01( line ), delivery_something_line( [ delivery_street, s1 ] )
	
	, delivery_something_line( [ delivery_city, s1 ] )
	
	, delivery_something_line( [ delivery_postcode, pc ] )
	
	, check( i_user_check( gen_same, street_two, TWO ) )
	
	, wrap( delivery_street( TWO ), `C/O `, `` )
	
] ).

%=======================================================================
i_line_rule_cut( delivery_start_header, [
%=======================================================================

	  q0n(anything)
	  
	, `PLEASE`, `DELIVER`, `TO`, `:`
	
	, street_two(s1), newline

	, trace( [ `delivery start header found`, street_two ] )

] ).

%=======================================================================
i_line_rule( delivery_something_line( [ SOMETHING, PARAM ] ), [
%=======================================================================

	  nearest( street_two(start), 5, 20 )
	  
	, READ_SOMETHING
	
	, newline
	
	, trace( [ SOMETHING_STRING, SOMETHING ] )
	  
] )
:-

	  READ_SOMETHING=.. [ SOMETHING, PARAM ]
	
	, sys_string_atom( SOMETHING_STRING, SOMETHING )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ q0n( line ), delivery_contact_line ] ).
%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	  `SITE`, `CONTACT`, `:`
	  
	, delivery_contact(sf), `-`

	, trace( [ `delivery contact`, delivery_contact ] ) 
	
	, delivery_ddi(s1), gen_eof

	, trace( [ `delivery ddi`, delivery_ddi ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_details, [ q0n(line), buyer_contact_line, q( 0, 2, line ), buyer_ddi_line ] ).
%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	  `Approved`, `:`, q10( tab )
	  
	, buyer_contact(s1)
	
	, trace( [ `buyer_contact`, buyer_contact ] )

] ).

%=======================================================================
i_line_rule( buyer_ddi_line, [ 
%=======================================================================

	  q0n(anything)
	  
	, set( regexp_cross_word_boundaries )
	
	, buyer_ddi( f( [ begin, q(dec,11,11), end ] ) ), `(`
	
	, q0n(word)
	
	, buyer_fax( f( [ begin, q(dec,11,11), end ] ) ), `)`
	
	, clear( regexp_cross_word_boundaries )
	
	, trace( [ `dial ins`, buyer_ddi, buyer_fax ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ q0n(line), line_end_line, customer_comments_line ] ).
%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	  customer_comments(s1)

	, newline

	, trace( [ `customer comments`, customer_comments ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `TOTAL`, `ORDER`, `VALUE` ], total_net, d, newline ] ) )
	  
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

%=======================================================================
i_rule( get_transport_line, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Transport`, `Cost`, q10(tab), `:`, q10( tab ) ], delivery_charge, d, newline ] )

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
		
			  line_invoice_line
			
			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `QTY`, `PART`, `NO`, tab, `DESCRIPTION` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ q0n(anything), `TOTAL`, `ORDER`, `VALUE` ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  or( [ line_quantity_with_calculation_rule
	  
		, line_quantity_read_rule
		
	] )  
	
	, generic_item( [ pack_qty, d, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_item_for_buyer, s1, newline ] )

	, count_rule

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
i_rule_cut( line_quantity_with_calculation_rule, [
%=======================================================================

	  generic_item( [ qty_pt_1, d, none ] )
	  
	, generic_item( [ line_item, s1, tab ] )
	
	, `[`
	
	, set( regexp_allow_partial_matching )
	
	, qty_pt_2( f( [ begin, q(dec,1,5), end ] ) )
	
	, line_quantity_uom_code( f( [ begin, q(alpha,1,6), end ] ) )
	
	, `]`
	
	, clear( regexp_allow_partial_matching )
	
	, trace( [ `line uom`, line_quantity_uom_code ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, check( sys_calculate_str_multiply( qty_pt_1, qty_pt_2, Qty ) )

	, check( sys_calculate_str_round_2( Qty, Qty_2 ) )
	
	, line_quantity( Qty_2 )
		
	, trace( [ `line quantity from calculation`, line_quantity ] )

] ).

%=======================================================================
i_rule_cut( line_quantity_read_rule, [
%=======================================================================

	  generic_item( [ line_quantity, d, none ] )
	  
	, generic_item( [ line_item, s1, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )

] ).