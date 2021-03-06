%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MECHANICA SRL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_mechanica, `18 June 2015` ).

i_date_format( _ ).

i_pdf_paramater( x_tolerance_100, 100 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, get_fixed_variables

	, get_order_number
	
	, gen_vert_capture( [ [ `Data`, tab ], `DATA`, q(0,1), (start,0,150), invoice_date, date, tab ] )
	, gen_vert_capture( [ [ `SPEDIZIONE`, tab ], `SPEDIZIONE`, q(0,0), (start,0,40), shipping_instructions, s1, tab ] )
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_invoice_lines
	
	, set(reverse_punctuation_in_numbers)
	
	, gen_vert_capture( [ [ `DOCUMENTO`, newline ], `DOCUMENTO`, q(0,1), (start,0,100), total_net, d, newline ] )
	, gen_vert_capture( [ [ `DOCUMENTO`, newline ], `DOCUMENTO`, q(0,1), (start,0,100), total_invoice, d, newline ] )
	
	, clear(reverse_punctuation_in_numbers)
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%
	
	, sender_name( `Mechanica Srl` )
	
	, suppliers_code_for_buyer( `13237971` )
	
	, set( no_pc_cleanup )
	
	, buyer_dept(`ITMECHUFFICIO`)
	
	, delivery_from_contact(`ITMECHUFFICIO`)
	
	, set( delivery_note_ref_no_failure )
	
	, delivery_note_reference(`ITMECHUFFICIO`)
	
	, set( leave_spaces_in_order_number )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ q0n(line), order_number_line ] ).
%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	`ORDINE`, q10( `INTERNO` ), `N`, `°`, tab, order_number(s1), trace( [ `Got part 1 of ord number` ] ), tab, append(order_number(s1), ` `, ``)
	
	, trace( [ `Order Number`, order_number ] )

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

	, qn0( [ peek_fails(line_end_line)

		, or( [ 
		
			get_line_invoice

			, line_continuation_line
			
			, line
		
		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`CODICE`, tab, `DESCRIZIONE`, tab
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	or( [ 
	
		[ `TOTALE` ]

		, [	`ORDINE`, q10( `INTERNO` ), `N`, `°` ]
		
		, [ `1`, `.`, `RIBA`, `con`, `scadenza` ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================
	
	clear( got_item ), set(reverse_punctuation_in_numbers)
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, q10( [ read_ahead( [ q0n(word), line_item( f( [ begin, q(dec,5,9), end ] ) ) ] )
	
		, set( got_item ), trace( [ `line_item`, line_iem ] )
	
	] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_original_order_date, date, q10(tab) ] )
	
	, generic_item( [ customer_comments, s1, newline ] )
	
	, clear(reverse_punctuation_in_numbers)
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	q10( [ peek_fails( test( got_item ) )
	
		, read_ahead( [ q0n(word), line_item( f( [ begin, q(dec,5,9), end ] ) ) ] )
		
	] )
	
	, trace( [ `line_item`, line_item ] )
	
	, append( line_descr(s1), ` `, ``), newline
	
] ).



%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, string_string_replace( Delivery_L, `/`, ` / `, Delivery_Rep )
	, sys_string_split( Delivery_Rep, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport` ] )
	, trace( `delivery line, line being ignored` )
.

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).