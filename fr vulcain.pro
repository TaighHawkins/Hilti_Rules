%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - VULCAIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( vulcain, `12 August 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_pdf_parameter( same_line, 9 ).
i_pdf_parameter( space, 3 ).

i_user_field( invoice, buyer_location, `Buyer Location` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables 

	, get_order_number
	, get_order_date
	
	, get_buyer_dept

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

	, type_of_supply(`01`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` ), delivery_note_number( `10558391` ) ]    %TEST
	    , [ suppliers_code_for_buyer( `11611479` ), delivery_note_number( `18150962` ) ]                 %PROD
	]) ]
	
	, sender_name( `S.A.S Vulcain` )
	
	, set( leave_spaces_in_order_number )
	
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
	  
	, generic_horizontal_details( [ [ `Commande`, `N`, `°` ], order_number_x, s1 ] )
	
	
	, q(0,10,line)
	
	, generic_horizontal_details( [ [ `N`, `°`, `AFFAIRE` ], order_number_y, s1 ] )
	
	, check( order_number_x = X )
	, check( order_number_y = Y )
	, check( strcat_list( [ X, ` `, Y ], Order ) )
	, order_number( Order )
	, trace( [ `Order Number`, Order ] )

] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_vertical_details( [ [ `Date` ], invoice_date, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER DEPT	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_dept, [
%=======================================================================

	q(0,25,line)
	
	, generic_horizontal_details( [ `DEMANDEUR`, dept_x, s1 ] )
	
	, check( strip_string2_from_string1( dept_x, ` `, DeptX ) )
	, check( strcat_list( [ `FRVULC`, DeptX ], DeptRaw ) )
	
	, check( sys_string_length( DeptRaw, DeptRawLen ) )
	
	, or( [ [ check( DeptRawLen < 18 )
			, check( Dept = DeptRaw )
		]
		
		, check( q_sys_sub_string( DeptRaw, 1, 17, Dept ) )
	] )
	
	, buyer_dept( Dept )
	, delivery_from_contact( Dept )
	, trace( [ `Depts`, Dept ] )
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
	
	, generic_vertical_details( [ [ at_start, `BASE`, `HT`, set( regexp_cross_word_boundaries ) ], total_net, d ] )
	, clear( regexp_cross_word_boundaries )
	
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
		
			, line

		] )

	), line_end_line
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Article`, tab, `Qté`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `BASE` ]
	
		, [ dummy, check( dummy(page) \= header(page ) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ [ test( need_descr ), generic_line( [ [ generic_item( [ line_descr, s1, newline ] ) ] ] ) ]
	
		, peek_fails( need_descr )
	] )
	  
	, or( [ line_descr_line, test( got_item ), [ test( need_item ), line_item( `Missing` ) ] ] )

	, count_rule
	
	, clear( need_item )
	, clear( got_item )
	, clear( need_descr )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item_cut( [ line_item_for_buyer_x, s1, tab ] )
	
	, set( regexp_cross_word_boundaries )
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	, clear( regexp_cross_word_boundaries )

	, or( [ 
		generic_item_cut( [ line_descr, sf
			, or( [ [ q10( line_item_heading )
					, generic_item( [ line_item, [ q(alpha("ref"),0,3), begin, q(dec,4,10), end ], q10( tab ) ] )
					, set( got_item )
				]
			
				, [ tab, set( need_item ) ] 
			] ) 
		] )
		, [ set( need_descr ), set( need_item ) ]
	] )

	, set( regexp_cross_word_boundaries )
	, generic_item_cut( [ line_unit_amount, d, tab ] )
	, generic_item_cut( [ line_net_amount, d, q10( tab ) ] )
	, clear( regexp_cross_word_boundaries )

	, generic_item_cut( [ line_original_order_date, date, newline ] )
	
	, q10( [ without( delivery_date ), check( line_original_order_date = Date )
		, delivery_date( Date )
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	  or( [ [ test( need_item )
			, or( [ 
				[ read_ahead( [ q0n( word ), line_item_heading, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ] ) ]
				
				, line_item( `Missing` )
			] )
		]
		
		, peek_fails( test( need_item ) )
	] )
	
	, append( line_descr(s1), ` `, `` ), newline
	
] ).

%=======================================================================
i_rule( line_item_heading, [
%=======================================================================

	or( [ `ref`
	
		, `réf`
		
		, [ `Article`, `#` ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).