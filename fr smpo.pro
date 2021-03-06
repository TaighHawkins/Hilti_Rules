%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR SMPO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_smpo, `19 January 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, get_order_number
	
	, get_order_date
	
	, get_due_date
	
	, get_delivery_address
	
	, get_contacts

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

	, buyer_registration_number( `FR-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, type_of_supply( `F5` )
	
	, or( [ 
		[ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]
		, suppliers_code_for_buyer( `11635330` )
	] )

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `SMPO Cripple Gate` )
	
	, total_net( `0` )
	, total_invoice( `0` )
	
	, buyer_contact( `yannick ARMAND` )
	
	, set( leave_spaces_in_order_number )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ [ `Commande`, `N`, `°` ], order_number, s1 ] )

] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ [ `Date`, `:`, word ], invoice_date_x, s1 ] )
	
	, check( i_user_check( convert_the_month, invoice_date_x, Date ) )
	, invoice_date( Date )
	, trace( [ `Invoice Date after conversion`, Date ] )

] ).

%=======================================================================
i_user_check( convert_the_month, DateIn, DateOut )
%----------------------------------------
:-
%=======================================================================

	string_to_lower( DateIn, DateL )  ,
	month_lookup( Month, Num ),
	q_sys_sub_string( DateL, _, _, Month ),
	string_string_replace( DateL, ` `, `/`, DateRep ),
	string_string_replace( DateRep, Month, Num, DateOut )
.

month_lookup( `janvier`, `01` ).
month_lookup( `février`, `02` ).
month_lookup( `mars`, `03` ).
month_lookup( `avril`, `04` ).
month_lookup( `mai`, `05` ).
month_lookup( `juin`, `06` ).
month_lookup( `juillet`, `07` ).
month_lookup( `août`, `08` ).
month_lookup( `septembre`, `09` ).
month_lookup( `octobre`, `10` ).
month_lookup( `novembre`, `11` ).
month_lookup( `décembre`, `12` ).
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY PARTY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( delivery_thing( [ Var ] ), [ qn0( gen_line_nothing_here( [ delivery_party(start), 10, 20 ] ) ), delivery_thing_line( [ Var ] ) ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Var ] ), [ nearest( delivery_party(start), 10, 20 ), generic_item( [ Var, s1 ] ) ] ).
%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================	  
	  
	  generic_horizontal_details( [ delivery_party, s1 ] )
	  
	, delivery_thing( [ delivery_dept ] )
	
	, q( 1, 2, delivery_thing( [ delivery_street ] ) )
	
	, qn0( gen_line_nothing_here( [ delivery_party(start), 10, 20 ] ) )
	
	, delivery_postcode_and_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================	  
	  
	nearest( delivery_party(start), 10, 20 )
	
	, set( regexp_cross_word_boundaries )
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ], q10( tab ) ] )
	, clear( regexp_cross_word_boundaries )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, q0n( or( [ line_order_rule, line ] ) )

	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Code`, `article`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `Adresse`, `de` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_order_rule, [
%=======================================================================

	line_order_line
	
	, count_rule

] ).


%=======================================================================
i_line_rule_cut( line_order_line, [
%=======================================================================

	 generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity_x, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, s1, newline ] )

	, or( [ [ check( line_quantity_uom_code = `UT` )
			, check( line_quantity_x = Qty )
		]
		
		, [ check( sys_calculate_str_multiply( line_quantity_x, line_quantity_uom_code, Qty ) ) ]
		
	] )
	
	, line_quantity( Qty )
	, trace( [ `Actual Line Quantity`, Qty ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).