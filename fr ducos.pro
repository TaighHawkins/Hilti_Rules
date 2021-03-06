%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR DUCOS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_ducos, `29 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, clear_excel_reverse_punctuation

	, get_order_number
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_order_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( clear_excel_reverse_punctuation, [ clear( reverse_punctuation_in_numbers ) ] )
%-----------------------------------------------------------------------
:- i_mail( attachment, Attach ), string_to_lower( Attach, AttachL ), q_sys_sub_string( AttachL, _, _, `.xls` ).
%=======================================================================

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
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]	
				, suppliers_code_for_buyer( `11538499` )		
	] )

	, type_of_supply( `F5` )

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Ducos` )
	
	, buyer_contact( `Jean Luc LIND` )
	, delivery_contact( `Jean Luc LIND` )

	, set( leave_spaces_in_order_number )
	, set( no_defect_invoice_date )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ q(0,15,line), order_number_line ] ).
%=======================================================================
i_line_rule( order_number_line, [
%=======================================================================

	`Notre`, `commande`, `:`, order_number( `` )
	
	, xor( [ [ read_ahead( [ q0n(word), `Vinci` ] ), delivery_note_number( `20151555` ) ]
	
		, delivery_note_number( `11538499` )
	] )
	
	, or( [ [ q(3,3, [ read_ahead( dum(d) ), append( order_number(w), ``, ` ` ) ] )
	
			, word
			
			, or( [ [ append( order_number(w), ``, `` ), newline ]
			
				, newline
				
			] )
		]
		
		, [ append( order_number(s1), ` `, `` ), newline ]
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

	total_net( `0` ), q0n(line), line_header_line 
	
	, qn0(
		or( [ add_to_total
			, line
		] )
	)
	
	, check( total_net = Net )
	, total_invoice( Net )
	
	, trace( [ `Final total`, total_invoice ] )
	
] ).


%=======================================================================
i_line_rule_cut( add_to_total, [
%=======================================================================

	  nearest( prix_hook(end), 10, 40 )
	  
	, generic_item_cut( [ total, d ] )
	
	, check( sys_calculate_str_add( total_net, total, Net ) )
	, total_net( Net )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_order_lines, [
%=======================================================================

	  line_header_line
	 
	, qn0(
		or( [ line_order_line
			, line
		] )
	)

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Reference`, q10( tab ), ref_hook(w)

	, q0n(anything), read_ahead( `Designation` ), designation_hook(w)
	
	, q0n(anything), read_ahead( `Quantite` ), quantity_hook(w)
	
	, q0n(anything), read_ahead( `Prix` ), prix_hook(s1)
	
] ).

%=======================================================================
i_line_rule_cut( line_order_line, [
%=======================================================================

	  check( ref_hook(start) = Ref )
	, check( designation_hook(start) = Des )
	, check( quantity_hook(start) = Qty )
	, check( prix_hook(start) = Prix )
	  
	, retab( [ Ref, Des, Qty, Prix ] )
	
	, generic_item( [ some_item, s1, tab ] )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
	, q10( [ `=`, dummy(s1) ] ), tab
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity_x, d, tab ] )

	, generic_item_cut( [ line_net_amount, d ] )
	
	, count_rule
	
	, or( [ [ check( q_sys_sub_string( line_descr, _, _, `LE%` ) )
			, check( sys_calculate_str_multiply( line_quantity_x, `100`, NewQty ) )
		]
		, check( line_quantity_x = NewQty )
	] )
	
	, line_quantity( NewQty )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).