%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT SECH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_sech, `21 January 2015` ).

i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, get_shipping_instructions

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
	    , suppliers_code_for_buyer( `20271647` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10658906` ) ]    %TEST
	    , delivery_note_number( `22089312` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	
	, delivery_from_contact( `ITSECHRAGUSA` )
	
	, buyer_dept( `ITSECHRAGUSA` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ at_start, `Ordine`, `di`, `acquisto`, `nr`, `.` ]
									, order_number, sf
									, [ `del`, generic_item( [ invoice_date, date ] ) ] 
	] )
	
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
	  
	, generic_vertical_details( [ [ `Totale`, tab, `I`, `.`, `V`, `.` ], total_net, d ] )

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
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule
			  
			, line_double_dot_line

			, line_continuation_line
			
			, line

		] )

	] )
	
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Codice`, tab, `Descrizione` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `I`, `PAGAMENTI` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	line_invoice_line
	
	, or( [ [ line_item_line

		]
		
		, [ line_item( `Missing` ) ]
		
	] )
	
	, set( need_descr )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [ `ART`, `.`, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ codice, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )
	
	, q10( [ `-`, generic_item( [ some_discount, d, tab ] ) ] )

	, generic_item( [ line_net_amount, d, q10( tab ) ] )

	, generic_item( [ line_original_order_date, date, q10( tab ) ] )
	
	, generic_item( [ some_num, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_double_dot_line, [ 
%=======================================================================

	`.`, `.`, tab
	
	, or( [ [ with( customer_comments ), append( customer_comments(s1), `~`, `` ) ]
	
		, [ without( customer_comments ), generic_item( [ customer_comments, s1 ] ) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	test( need_descr )
	
	, read_ahead( generic_item( [ descr, s1 ] ) )
	
	, check( descr(start) > -400 )
	, check( descr(start) < -200 )
	
	, check( descr = Descr )
	, append( line_descr( Descr ), ` `, `` )
	
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
i_analyse_line_fields_first( LID )
%-----------------------------------------------------------------------
:- i_check_line_quantities( LID ).
%=======================================================================

%=======================================================================
i_check_line_quantities( LID )
%-----------------------------------------------------------------------
:-
%=======================================================================

	result( _, LID, line_quantity, Qty ),
	result( _, LID, line_descr, Descr ),
	
	q_sys_comp_str_gt( Qty, `1` ),
	
	string_string_replace( Descr, `.`, ` . `, DescrRep ),
	string_string_replace( DescrRep, `PZ`, ` PZ `, DescrRep1 ),
	sys_string_split( DescrRep1, ` `, DescrList ),
	
	sys_append( _, [ Num, `PZ` | _ ], DescrList ),
	q_regexp_match( `^\\d+$`, Num, _ ),
	
	sys_calculate_str_multiply( Num, Qty, NewQty ),
	sys_retract( result( _, LID, line_quantity, Qty ) ),
	assertz_derived_data( LID, line_quantity, NewQty, i_check_line_quantities ),
	!
.