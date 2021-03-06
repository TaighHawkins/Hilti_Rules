%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SIAPOC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( siapoc, `28 April 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

% i_pdf_parameter( same_line, 6 ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables 

	, get_order_number
	
	, get_order_date

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
	    , suppliers_code_for_buyer( `11556865` )                      %PROD
	]) ]
	
	, or( [
		[ test( test_flag ), delivery_note_number( `10558391` ) ]
			, suppliers_code_for_buyer( `11556865` )
	] )
	
	, buyer_location( `0010495375` )
	, delivery_from_location( `0010495375` )
	
	, sender_name( `Siapoc les peintures tropicales ` )
	
	, buyer_dept( `FRSIAPCONTACT` )
	, delivery_from_contact( `FRSIAPCONTACT` )
	
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
	  
	, generic_horizontal_details( [ [ `N`, `°`, `de`, `commande`, `:` ], order_number, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Date`, `:`, tab ], invoice_date, date ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	qn0(line)
	
	, total_net_line

	, check( total_net = Net )
	, total_invoice( Net )
	
] ).

%=======================================================================
i_line_rule( total_net_line, [ 
%=======================================================================

	q0n( [ dummy(s1), tab ] )
	
	, `Total`, `HT`, `:`
	
	, set( regexp_cross_word_boundaries )	
	, or( [ [ tab, generic_item( [ total_net, d ] ) ]
	
		, [ newline, parent, or( [ [ up, up ], line ] )
			, generic_line( 1, 400, 500, [ generic_item( [ total_net, d, `EUR` ] ) ] )
		]
	] )
	, clear( regexp_cross_word_boundaries )
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

			, line

		] )

	), line_end_line
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Article`, tab, `Réf`, `.`, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Mode`, `livraison` ]
	
		, [ q0n( [ dummy(s1), tab ] ), `Total`, `HT` ]
		
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item_cut( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item_cut( [ line_item, [ begin, q(dec,3,10), end, q(alpha,0,1) ], tab ] )
	
	, generic_item_cut( [ line_descr, s, [ q10(tab), some(date), tab ] ] )

	, set( regexp_cross_word_boundaries )	
	, generic_item_cut( [ line_quantity, d ] )
	, clear( regexp_cross_word_boundaries )
	
	, generic_item_cut( [ line_quantity_uom_code_x, w, tab ] )
	
	, set( regexp_cross_word_boundaries )
	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d, newline ] )
	, clear( regexp_cross_word_boundaries )
	
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
:-  i_correct_quantities_and_uoms( LID ).
%=======================================================================
i_correct_quantities_and_uoms( LID )
%-----------------------------------------------------------------------
:-
%=======================================================================
	result( _, LID, line_descr, Descr ),
	result( _, LID, line_quantity, Qty ),
	
	string_to_lower( Descr, DescrL ),
	
	( 
		q_sys_member( Box, [ `bt`, `bte`, `boite` ] ),
		
		q_sys_sub_string( DescrL, _, _, Box ),
		strcat_list( [ ` `, Box ], BoxPreSpace ),
		strcat_list( [ BoxPreSpace, ` ` ], BoxBothSpace ),
		
		string_string_replace( DescrL, BoxPreSpace, BoxBothSpace, DescrRep1 ),
		
		trace( [ `DescrRep`, DescrRep1 ] ),
		
		sys_string_split( DescrRep1, ` `, DescrList ),

		
		sys_append( _, [ Box, Num | _ ], DescrList ),
		q_regexp_match( `^\\d+$`, Num, _ )
		->	trace( [ `Found Box` ] ),
			sys_calculate_str_multiply( Num, Qty, FinalQty ),
			sys_retract( result( _, LID, line_quantity, _ ) ),
			assertz_derived_data( LID, line_quantity, FinalQty, i_found_a_box_in_description )
			
		; true
	),	
	
	
	( q_sys_member( DescrMember, DescrList ),
		q_sys_member( DescrMember, [ `rail`, `rails` ] )
		->	trace( [ `Found Rails` ] ),
			sys_retract( result( _, LID, line_quantity_uom_code, _ ) ),
			assertz_derived_data( LID, line_quantity_uom_code, `M`, i_found_rail_in_the_description )
			
		;	true
	),
	
	!
.