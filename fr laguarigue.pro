%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - LAGUARIGUE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( laguarigue, `30 June 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

% i_pdf_parameter( same_line, 6 ).

i_user_field( invoice, buyer_location, `Buyer Location` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables 

	, get_order_number

	, get_totals
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_invoice_lines

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `FR-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`F5`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` ) ]    %TEST
	    , suppliers_code_for_buyer( `15880402` )                      %PROD
	]) ]
	
	, buyer_location( `0014852086` )
	, delivery_from_location( `0014852086` )
	
	, sender_name( `Laguarigue Materiaux` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Ref`, `cde`, `:`, `N`, `°` ], order_number, sf, [ `du`, invoice_date( date ) ] ] )
	
	, or( [ [ check( q_sys_sub_string( order_number, _, _, `VINCI` ) )
			, delivery_note_number( `20649697` )
		]
		
		, delivery_note_number( `15880402` )
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
	
	, generic_horizontal_details( [ [ at_start, `MONTANT`, `DE`, `LA`, dummy(s1) ], total_net, d ] )

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

	, q0n(

		or( [ line_invoice_rule
		
			, line_continuation_line
		
			, line

		] )

	), line_end_line
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `|`, `Nos`, `réfer`, `.`, `|` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `.`, `.`, `.` ], [ `-`, `-` ] ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	`|`, generic_item_cut( [ line_item_for_buyer, sf, [ q10( tab ), `|` ] ] )
	
	, or( [ [ set( regexp_cross_word_boundaries )
			, generic_item_cut( [ line_item, [ begin, q(dec,3,10), end, q(alpha,0,1) ], [ q10( dummy(s1) ), q10( tab ), `|` ] ] )
			, clear( regexp_cross_word_boundaries )
		]
		
		, [ tab, `|`, line_item( `Missing` ) ]
	] )
	
	, generic_item_cut( [ line_descr, sf, [ q01( [ tab, append( line_descr(sf), ` `, `` ) ] ), q10( tab ), `|`, q10( tab ) ] ] )
	
	, generic_item_cut( [ line_quantity, d ] )
	
	, or( [ [ or( [ `U`, `PAK` ] ), line_quantity_uom_codex( `EA` ) ]
	
		, [ or( [ `BTE`, `BLI` ] ), line_quantity_uom_code( `PAK` ) ]
		
		, generic_item( [ line_quantity_uom_codex, wf ] )
		
	] ), q10( tab ), `|`, q10( tab )
	
	, generic_item_cut( [ line_unit_amount, d, `|` ] ), newline
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  `|`, tab, `|`
	  
	, q10( tab ), append( line_descr(s), ` `, `` )
	
	, q10( tab ), `|`, tab, `|`, tab, `|`, newline
	
	, trace( [ `Appended line description`, line_descr ] )
	
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
i_analyse_line_fields_last(LID):-i_multiply_values(LID).
%=======================================================================
i_multiply_values(LID)
%-----------------------------------------------------------------------
:-
%=======================================================================

	result( _, LID, line_quantity_uom_code, UOM ),
	UOM=`PAK`,
	
	result( _, LID, line_quantity, Quantity ),
	result( _, LID, line_descr, Descr ),
	
	( string_to_upper(Descr, DescrU),
		string_string_replace(DescrU, `/`, ` / `, DescrRep),
		sys_string_split(DescrRep, ` `, DescrList),
		
		q_sys_member(BT, [ `BTE`, `BOITE`, `BT`, `LOT` ] ),
		( sys_append(_,[ BT, Num | _ ], DescrList)
			;	sys_append( _, [ BT, `DE`, Num | _ ], DescrList )
		),
		q_regexp_match( `^\\d{1,5}$`, Num, _ ),
		sys_calculate_str_multiply(Num, Quantity, NewQuantity),
		
		sys_retract( result( _, LID, line_quantity, Quantity) ),
		assertz_derived_data(LID, line_quantity, NewQuantity, i_multiply_values)
		
		;	true
	),
	
	sys_retract( result(_,LID,line_quantity_uom_code,UOM) ),
	
	!
.
	