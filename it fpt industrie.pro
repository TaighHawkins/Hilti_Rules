%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT FPT INDUSTRIE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_fpt_industrie, `31 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, street_two, `street two storage` ).

i_user_field( invoice, due_date_year, `due date year storage` ).

i_rules_file( `d_hilti_it_postcode.pro` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number_date_and_contact

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, [ q0n(line), line_header_line_2 ]
	
	, get_invoice_lines
	
	, get_invoice_lines_2

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
	    , suppliers_code_for_buyer( `13046941` )                      %PROD
	]) ]
	
	, [ or([ 
	  [ test(test_flag), delivery_note_number( `11238285` ) ]    %TEST
	    , delivery_note_number( `20138961` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	, set( no_total_validation )
	
	, buyer_ddi( `0415768111` )
	, delivery_ddi( `0415768111` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_date_and_contact, [ q(0,10,line), order_number_date_and_contact_line ] ).
%=======================================================================
i_line_rule( order_number_date_and_contact_line, [ 
%=======================================================================

	  generic_item( [ order_number, s1, tab ] )
	  
	, check( order_number(y) > -270 )
	
	, check( order_number(y) < -200 )
	
	, check( order_number(end) < -400 )
	
	, generic_item( [ invoice_date, date, none ] )
	
	, q10( tab )
	
	, generic_item( [ buyer_contact, s1, gen_eof ] )
	
	, check( buyer_contact = Con )
	
	, delivery_contact( Con ) 
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ qn0(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [ 
%=======================================================================

	  q01( [ a(s1), tab ] ), read_ahead( [ generic_item( [ total_net, d, newline ] ) ] )
	   
	, check( total_net(start) > 350 )
	
	, generic_item( [ total_invoice, d, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

		  or( [ 
		
			  line_invoice_line
			  
			, line_defect_line
			
			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ peek_fails( test( all_data_available ) ), dummy(s1), check( dummy(y) > -170) , check( dummy(y) < -130 ), check( dummy(page) = 1 ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ dummy(d), check( dummy(start) > 350 ) ] ).
%=======================================================================
i_line_rule_cut( line_defect_line, [ q(4,4, [ q0n(anything), tab ] ), force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  retab( [ -460, -350, 0, 40, 170, 260, 360, 415 ] )
	  
	, generic_item( [ line_order_line_number, d,  tab ] )
	  
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ other_quantity, d, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )

	, or( [ generic_item( [ line_percent_discount, d, tab ] ) , tab ] )

	, generic_item( [ line_original_order_date, date, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines_2, [
%=======================================================================

	  line_header_line_2
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_line_2
			  
			, line_defect_line
			
			, line

		] )

	] )

	, line_end_line_2

] ).

%=======================================================================
i_line_rule_cut( line_header_line_2, [ without( line_unit_amount ), `POS`, `.`, tab, `CODICE`, tab, `DESCRIZIONE`, tab, set( all_data_available ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line_2, [ q01( [ a(s1), tab ] ), dummy(d), check( dummy(start) > 350 ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line_2, [
%=======================================================================

	  generic_no( [ line_order_line_number, d ] )

	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, q01( [ append( line_descr(s1), ` `, `` ), tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_no( [ line_quantity, d, tab ] )
	
	, generic_no( [ other_quantity, d, tab ] )
	
	, generic_no( [ line_unit_amount, d, tab ] )

	, q10( generic_item_cut( [ line_percent_discount, d, q10( tab ) ] ) )

	, generic_item( [ line_original_order_date, date, newline ] )

] ).