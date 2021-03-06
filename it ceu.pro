%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT CEU
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_ceu, `01 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, street_two, `street two storage` ).

i_user_field( invoice, due_date_year, `due date year storage` ).

i_rules_file( `d_hilti_it_postcode.pro` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_data_at_location( [ order_number, s1, -350, -320, -240, -125 ] )

	, get_data_at_location( [ invoice_date, date, -350, -320, -125, 20 ] )
	
	, get_data_at_location( [ buyer_contact, s1, 410, 460, 100, 350 ] )
	
	, get_data_at_location( [ delivery_contact, s1, 410, 460, 100, 350 ] )

	, get_delivery_address
	
	, get_customer_comments
	
	, get_cig_cup

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

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `13135298` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	
	, buyer_ddi( `07538231` )
	
	, delivery_ddi( `07538231` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%======================================================================= 	  

	  get_data_at_location( [ delivery_party, s1, -300, -260, 0, 500 ] )
	  
	, delivery_street_line
	
	, delivery_postcode_city_and_location_line

] ).

%=======================================================================
i_line_rule_cut( delivery_street_line, [
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, generic_item( [ delivery_street, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_postcode_city_and_location_line, [
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	
	, generic_item( [ delivery_city, s1, tab ] )
	
	, generic_item( [ delivery_state, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `EUR` ], total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `EUR` ], total_invoice, d, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ q0n(line), read_ahead( line_header_line ), customer_comments_line ] ).
%=======================================================================
i_line_rule( customer_comments_line, [ generic_item( [ customer_comments, s1, [ q10( [ tab, append( customer_comments(s1), ` `, `` ) ] ), newline ] ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CIG CUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_cig_cup, [ 
%=======================================================================

	q0n(line), cig_cup_line
	
	, q10( [ without( cig ), cig( `` ) ] )
	, q10( [ without( cup ), cup( `` ) ] )
	
	, check( cup = Cup )
	, check( cig = Cig )
	
	, check( strcat_list( [ `CIG:`, Cig, ` CUP:`, Cup ], AL ) )
	, delivery_address_line( AL )
	, trace( [ `Delivery Address Line`, delivery_address_line ] )

] ).

%=======================================================================
i_line_rule( cig_cup_line, [ 
%=======================================================================

	q(2,1,
		[ q0n(anything)
			, or( [ [ peek_fails( test( got_cig ) ), `CIG`, cig(w), set( got_cig ) ]
			
				, [ peek_fails( test( got_cup ) ), `CUP`, cup(w), set( got_cup ) ]
			] )
		]
	)	

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

		  or( [ 
		
			  line_invoice_line
			
			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ dummy(s1), check( dummy(y) > -210) , check( dummy(y) < -130 ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `EUR` ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  retab( [ -330, -15, 10, 100, 180, 280, 368 ] )
	  
	, line_no(d)
	  
	, read_ahead( generic_item( [ line_item_for_buyer, s1, tab ] ) )
	
	, line_item( f( [ q(alpha("HILT"),0,5), begin, q(dec,4,10), end ] ) ), tab
	
	, trace( [ `line item`, line_item ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
%	, line_unit_amount( fd( [ begin, q([dec,other(".")],1,10), q(other(","),1,1), q(dec,5,5), end ] ) )

	, or( [ generic_item( [ line_percent_discount, d, tab ] ), tab ] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )

	, count_rule

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_rule( get_data_at_location( [ Variable, Parameter, Y_above, Y_below, X_before, X_after ] ), [ 
%=======================================================================

	  q0n(line), find_the_data( [ Variable, Parameter, Y_above, Y_below, X_before, X_after ] )
	
] ).

%=======================================================================
i_line_rule( find_the_data( [ Variable, Parameter, Y_above, Y_below, X_before, X_after ] ), [ 
%=======================================================================

	  check_the_y( [ Y_above, Y_below ] )
	  
	, q0n(anything)
	
	, Read_Variable
	
	, check( Check_Start > X_before )
	
	, check( Check_End < X_after )
	
	, trace( [ Variable_S, Variable ] )

] )
:-
	  sys_string_atom( Variable_S, Variable )
	  
	, Read_Variable =.. [ Variable, Parameter ]
	
	, Check_Start =.. [ Variable, start ]
	
	, Check_End =.. [ Variable, end ]
.

%=======================================================================
i_rule( check_the_y( [ Y_above, Y_below ] ), [ 
%=======================================================================

	  read_ahead( dummy(w) )
	  
	, check( dummy(y) < Y_below )
	
	, check( dummy(y) > Y_above )
	
	, trace( [ `found line` ] )

] ).