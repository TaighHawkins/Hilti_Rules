%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MONTAENGIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( montaengil, `20 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, buyers_code_for_bill_to, `Buyers code for the bill to` ).
i_user_field( invoice, buyer_location, `Buyers Location Code` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_date
	
	, get_due_date

	, get_delivery_note_reference

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, get_more_detailed_invoice_lines

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

	, buyer_registration_number( `PT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]  	%TEST
	    , supplier_registration_number( `P11_100` )                   	%PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`3200`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10907232` ) ]  		%TEST
	    , suppliers_code_for_buyer( `16355667` )                   		%PROD
	]) ]

	, set( reverse_punctuation_in_numbers )

	, set( delivery_note_ref_no_failure )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,3,line)
	  
	, generic_horizontal_details( [ [ generic_item( [ order_number_x, s1, tab ] ), `Data` ], invoice_date, date ] )
	
	, check( sys_string_split( order_number_x, ` `, [ _, Order ] ) )
	
	, order_number( Order )

] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, read_ahead( `Entrega` ) ], due_date_hook, s1 ] )
	
	, q(0,2,line), generic_horizontal_details( [ [ `Data`, `:` ], due_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_reference, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Centro`, q10( `de` ), `custo`, `:` ], delivery_location, w ] )
	  
	, check( i_user_check( sort_reference, delivery_location, LIFNR ) )
	
	, buyer_dept( LIFNR )
	, delivery_from_contact( LIFNR )
	
	, trace( [ `Buyer Dept`, buyer_dept ] )

] ).

%=======================================================================
i_user_check( sort_reference, Cost_X, DNR )
%-----------------------------------------------------------------------
:-
%=======================================================================
	sys_string_split( Cost_X, ` `, [ Cost | _ ] ),
	strcat_list( [ `PTMOTA`, Cost ], DNR ) 
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q(0,200,line)
	  
	, or( [ after_discount_total_rule

		, generic_vertical_details( [ [ `Total`, `Encomenda` ], `Encomenda`, end, 10, 10, total_net, d, newline ] )
		
	] )
	
	, check( total_net = Net )
	
	, total_invoice( Net )

] ).

%=======================================================================
i_line_rule( after_discount_total_line, [ nearest( total_hook(start), 0, 50 ), generic_item( [ total_net, d ] ) ] ).
%=======================================================================
i_rule( after_discount_total_rule, [ 
%=======================================================================

	  generic_horizontal_details( [ [ `%`, `IVA`, `valor` ], total_hook, w ] )
	  
	, after_discount_total_line

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
		
			  line_invoice_rule

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Pos`, tab
	
	, descr(s1), tab

	, check( q_sys_sub_string( descr, 1, _, `Desc` ) )
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ `Moeda`, tab ] ).
%=======================================================================
i_line_rule_cut( line_check_line, [ or( [ [ q0n(anything), q(2,2, [ tab, dum(d) ] ), tab, dum(d), newline ], `ATENÇÃO` ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  read_ahead( line_invoice_line )

	, gen1_parse_text_rule( [ -250, 50, or( [ line_end_line, line_check_line ] )
							, line_item, [ begin, q(dec,4,10), end ]
						] )
						
	, check( captured_text = Descr )
	
	, line_descr( Descr )

	, trace( [ `Full description`, line_descr ] )
	
	, with( invoice, due_date, Due )
	
	, line_original_order_date( Due )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_item_for_buyer, s1, tab ] )

	, generic_item_cut( [ dummy_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )

	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET MORE DETAILED LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_more_detailed_invoice_lines, [
%=======================================================================

	  line_more_detailed_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_more_detaled_invoice_rule

			, line

		] )

	] )
		
	, line_more_detailed_end_line

] ).


%=======================================================================
i_line_rule_cut( line_more_detailed_header_line, [ 
%=======================================================================

	`Pos`, tab, dummy(s1), tab
	
	, descr(s1), tab

	, check( q_sys_sub_string( descr, 1, _, `Desc` ) )
	
	, q0n(anything), read_ahead( `Un` ), un_hook(w)
	
] ).

%=======================================================================
i_line_rule_cut( line_more_detailed_end_line, [ 
%=======================================================================

	or( [ [ dummy(s1), newline, check( q_sys_sub_string( dummy, 1, _, `OBSERV` ) ) ]
	
		, `Importante`
		
	] )

] ).

%=======================================================================
i_rule_cut( line_more_detaled_invoice_rule, [
%=======================================================================

	  read_ahead( line_more_detailed_invoice_line )

	, or( [ [ test( missing_item )
			, gen1_parse_text_rule( [ -250, -30, or( [ line_more_detailed_end_line, line_check_line ] )
				, [ `REFª`, `:` ], line_item, [ begin, q(dec,4,10), end ]
			] )
			, set( got_item )
		]
		
		, gen1_parse_text_rule( [ -250, -30, or( [ line_more_detailed_end_line, line_check_line ] )
			, nothing, [ begin, q(any,1,15), end ]
		] )
	] )
	
	, q10( [ test( missing_item ), peek_fails( test( got_item ) ), line_item( `Missing` ) ] )
	
	, check( captured_text = Descr )
	
	, line_descr( Descr )

	, trace( [ `Full description`, line_descr ] )
	
	, with( invoice, due_date, Due )
	, line_original_order_date( Due )
	
	, clear( missing_item )
	, clear( got_item )

] ).

%=======================================================================
i_line_rule_cut( line_more_detailed_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )
	
	, or( [ generic_item( [ line_item, s1, tab ] ), set( missing_item )] )

	, generic_item_cut( [ dummy_descr, s, [ q10( tab ), check( dummy_descr(end) < un_hook(start) ) ] ] )
	
	, generic_item_cut( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_disc, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).