%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DISTRIMO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( distrimo, `11 February 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_user_field( line, potential_line_quantity, `possible quantity` ).

i_user_field( line, line_quantity_uom_code_x, `code` ).

i_user_field( line, line_item_ref, `blank` ).

%=======================================================================
i_page_split_rule_list( [ check_for_new_format ] ).
%=======================================================================
i_section( check_for_new_format, [ check_for_new_format_line ] ).
%=======================================================================
i_line_rule_cut( check_for_new_format_line, [ 
%=======================================================================

	check_text( `ADRESSEDELIVRAISONADRESSEFOURNISSEUR` )

	, set( chain, `fr distrimo` )
	, trace( [ `Chaining to new format` ] )
	, set( re_extract )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ livraison_defect_rule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	, get_fixed_variables 

	,[ q0n(line), get_order_number_date ]

	,[ qn0(line), invoice_total_line ]	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	[ q0n(line), get_delivery_note_number_line ]
	
	, get_delivery_note_reference_rule

	,[q0n(line), get_buyer_contact ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, get_invoice_two_lines

] ):- grammar_set( normal_order ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIVRAISON DEFECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( livraison_defect_rule, [ 
%=======================================================================

	  or( [ livraison_defect_combo_rule
	  
		, set( normal_order )
		
	] )

] ).

%=======================================================================
i_rule( livraison_defect_combo_rule, [ 
%=======================================================================

	 q0n(line),  livraison_header_line
	 
	, q(0,8,line), livraison_defect_line

] ).

%=======================================================================
i_line_rule( livraison_header_line, [ 
%=======================================================================

	`LIEU`, `DE`, `LIVRAISON`, `:`, gen_eof
	
	, trace( [ `found livraison header` ] )

] ).

%=======================================================================
i_line_rule( livraison_defect_line, [ 
%=======================================================================

	`Livraison`, `Directe`, `Chantier`
	
	, trace( [ `defect` ] )
	
	, force_result( `failed` )
	, force_sub_result( `by_rule` )
	, delivery_note_reference( `by_rule` )

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
	
	, set( delivery_note_ref_no_failure )
	
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
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` ) ]    %TEST
	    , suppliers_code_for_buyer( `11728554` )                      %PROD
	]) ]

	, delivery_from_contact( `FRDIST` )
	
	, buyer_dept( `FRDIST` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_reference_rule, [
%=======================================================================

	  test( test_flag )
	  
	, q0n(line), livraison_header_line
	
	, q(0,5,line), delivery_note_reference_line

] ).

%=======================================================================
i_line_rule( delivery_note_reference_line, [
%=======================================================================

	  q0n(word), wrap( delivery_note_reference( f( [ begin, q(dec,5,5), end ] ) ), `FRDIST`, `` )
	  
	, check( delivery_note_reference(end) < -150 )
	  
	, trace( [ `Delivery Note Reference`, delivery_note_reference ] )

] ).

%=======================================================================
i_line_rule( get_delivery_note_number_line, [
%=======================================================================

	  peek_fails( test( test_flag ) )
	  
	, q0n(anything)

	, or( [ [ `CHILLY`, `MAZARIN`, delivery_note_number( `11813529`) ]
	
			, [ `TOURVILLE`, `LA`, `RIV`, delivery_note_number( `11728554` ) ] ] )
	
	, trace( [ `del note`, delivery_note_number ] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	 red(f( [ begin, q(alpha("R"),1,1), q(any,8,8), end ] ) )
	 
	, check( red(start) < -400 )
	
	, tab, `:`, tab
	
	, q0n(word)

	, read_ahead( [ append( buyer_dept(w), ``, `` ), gen_eof ] )
	
	, append( delivery_from_contact(w), ``, `` ), gen_eof

	, trace( [ `buyer dept`, buyer_dept ] ) 

	, trace( [ `delivery dept`, delivery_from_contact ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_date, [ 
%=======================================================================

	  or( [ get_order_number_line( 1, 25, 500 )
	  
		, [ get_order_number_v2_line( 1, 25, 500 ), get_order_number_v2_p2_line( 1, 25, 500 ) ] 
		
	] )

	, qn0( gen_line_nothing_here( [ 200, 50, 50 ] ) )

	, q10( get_order_number_line_cont( 1, 25, 500 ) )

	, qn0( gen_line_nothing_here( [ 200, 50, 50 ] ) )

	, get_order_number_line_two( 1, 25, 500 )

	, qn0( gen_line_nothing_here( [ 200, 50, 50 ] ) )

	, get_order_date_line( 1, 25, 500 )

] ).

%=======================================================================
i_line_rule( line_on_left, [ 
%=======================================================================

	  dummy(s1)
	  
	, check( dummy(end) < 0 )
	
	, trace( [ `skipped the silly box` ] )
		
] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	  `COMMANDE`, `n`, `°`, `:`

	, set( regexp_cross_word_boundaries )

	, read_ahead( order_number(f( [ begin, q(alpha,2,2), end, q(any,4,10) ] ) ) )

	, append(order_number(` `), ``, ``)
	
	, append(order_number(f( [ q(alpha,2,2), begin, q(any,4,10), end ] ) ), ``, ``)
	
	, trace( [ `order number`, order_number ] )
	
	, clear( regexp_cross_word_boundaries )
	
	, newline

] ).

%=======================================================================
i_line_rule( get_order_number_v2_line, [ 
%=======================================================================

	  q0n(anything)

	, `COMMANDE`, `n`, `°`, `:`, order_number(w), newline
	
	, trace( [ `order number`, order_number ] )

] ).
	
%=======================================================================
i_line_rule( get_order_number_v2_p2_line, [ 
%=======================================================================
	
	  q0n(anything)
	  
	, read_ahead( dummy(s1) )
	
	, check( dummy(start) > 0 )
	
	, append(order_number(` `), ``, ``)
	
	, q0n(anything)
	
	, read_ahead( [ dummy_order(s1), check( dummy_order(start) > 100 ) ] )
	
	, append(order_number(s1), ``, ``), newline
	
	, trace( [ `order number`, order_number ] )

] ).

%=======================================================================
i_line_rule( get_order_number_line_cont, [ 
%=======================================================================

	  q0n(anything)
	  
	, read_ahead( dummy(s1) )
	
	, check( dummy(start) > 0 )
	
	, append(order_number(s1), ` `, ``)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_line_two, [ 
%=======================================================================

	  q0n(anything), `Centre`, `d`, `'`, `imputation`, `:`

	, append(order_number(s1), ` `, ``)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).

%=======================================================================
i_line_rule( get_order_date_line, [ 
%=======================================================================

	`DATE`, `:`

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	q0n(anything)

	,`TOTAL`, `HT`

	, q0n(anything)

	, set( regexp_cross_word_boundaries )

	, read_ahead(total_invoice(d))

	, total_net(d)

	, clear( regexp_cross_word_boundaries )

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_rule, line_invoice_two_rule
		
		, line

			])

		] )
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `DISTRIMO`, tab, `Fournisseur`, tab, `Désignation`, tab, `Unité`, `Qté` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`TOTAL`, `PORT`, `HT`], [`A`, `reporter`, tab] ])

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, q10( line_continuation_line )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  trace( [ `in first` ] )
	
	, generic_item_cut( [ line_item_for_buyer, w, q10(tab) ] )

	, q10( [ line_item(f( [ q(alpha("H"),0,1), begin, q(dec,4,8), end] ) ), q10(tab)
	
		, trace( [ `line item`, line_item ] )
		
	] )
	
	, generic_item_cut( [ line_descr, s	
		, [ q10(tab)
			, check( line_descr(start) > -300 )
			, check( line_descr(end) < 70 )
		]
	] )

	, q01( [ append( line_descr(s1), ` `, `` ), tab ] )
	
	, generic_item( [ line_quantity_uom_code_x, w
		, [ tab
			, check( line_quantity_uom_code_x(start) > 70 )	
		]
	] )

	, generic_item( [ potential_line_quantity, d
		, [ q10(tab)
			, check( potential_line_quantity(start) > 110 )
			, check( potential_line_quantity(end) > 138 ) 
			, check( potential_line_quantity(end) < 160 )
		]
	] )

	, set( regexp_cross_word_boundaries )
	
	, generic_item( [ line_unit_dummy, d
		, [ check( line_unit_dummy(start) > 162 )	
			, check( line_unit_dummy(end) > 200 )	
			, check( line_unit_dummy(end) < 225 )
		]
	] )
	
	, clear( regexp_cross_word_boundaries )
	
	, q01( dummy_percent(s) ), tab
	
	, set( regexp_cross_word_boundaries )
	
	, generic_item_cut( [ line_unit_dumm, d, tab ] )

	, generic_item_cut( [ line_total_amount, d, newline ] )
	
	, clear( regexp_cross_word_boundaries )

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
	
] ).

%=======================================================================
i_rule( line_invoice_two_rule, [
%=======================================================================

	  line_invoice_two_line
	  
	, [ peek_fails(line_end_line), line_invoice_two_extra_line ]
	
	, q10( line_continuation_line )
	
	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
	
] ).
%=======================================================================
i_line_rule_cut( line_invoice_two_line, [
%=======================================================================

	  trace( [ `in second` ] )
	
	, generic_item_cut( [ line_item_for_buyer, w, q10(tab) ] )
	  
	, q10( [ line_item(f( [ q(alpha("H"),0,1), begin, q(dec,4,8), end] ) ), q10(tab)
	
		, trace( [ `line item`, line_item ] )
		
	] )
	
	, generic_item_cut( [ line_descr, s	
		, [ q10(tab)
			, check( line_descr(start) > -300 )
			, check( line_descr(end) < 70 )
		]
	] )
	
	, generic_item( [ potential_line_quantity, d
		, [ q10(tab)
			, check( potential_line_quantity(start) > 110 )
			, check( potential_line_quantity(end) > 138 ) 
			, check( potential_line_quantity(end) < 160 )
		]
	] )

	, set( regexp_cross_word_boundaries )
	
	, generic_item( [ line_unit_dummy, d
		, [ check( line_unit_dummy(start) > 162 )	
			, check( line_unit_dummy(end) > 200 )	
			, check( line_unit_dummy(end) < 225 )
		]
	] )
	
	, clear( regexp_cross_word_boundaries )
	
	, q01( dummy_percent(s) ), tab

	, set( regexp_cross_word_boundaries )
	
	, generic_item_cut( [ line_unit_dumm, d, tab ] )

	, clear( regexp_cross_word_boundaries )
	
	, generic_item( [ dummy_net, s, newline ] )
	
] ).


%=======================================================================
i_line_rule( line_invoice_two_extra_line, [
%=======================================================================

	  generic_item( [ line_quantity_uom_code_x, w
		, [ tab
			, check( line_quantity_uom_code_x(start) > 70 )	
		]
	] )
	
	, set( regexp_cross_word_boundaries )
	
	, generic_item_cut( [ line_total_amount, d
		, [ newline, check( line_total_amount(start) > 360 ) ]
	] )
	
	, clear( regexp_cross_word_boundaries )
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  read_ahead( dummy_descr(s) )
	  
	, check( dummy_descr(start) > -300 )	
	, check( dummy_descr(end) < 70 )
	  
	, append( line_descr(s), ` `, `` ), newline
	
	, trace( [ `Appended line decription`, line_descr ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SECOND LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_two_lines, [
%=======================================================================

	 line_header_two_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ line_invoice_three_rule, line_invoice_four_rule 
		
				, line

			] )

		] )
] ).


%=======================================================================
i_line_rule( line_header_two_line, [ `DISTRIMO`, `Fournisseur`, tab, `Désignation`, tab, `Unité`, tab, `Qté`, tab ] ).
%=======================================================================


%=======================================================================
i_rule( line_invoice_three_rule, [
%=======================================================================

	  line_invoice_three_line
	  
	, [ peek_fails(line_end_line), line_invoice_three_extra_line ]
	
	, q10( line_continuation_two_line )
	
	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
	
] ).

%=======================================================================
i_rule( line_invoice_four_rule, [
%=======================================================================

	  line_invoice_four_line
	  
	, q10( line_continuation_two_line )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_three_line, [
%=======================================================================

	  trace( [ `in third` ] )
	
	, generic_item_cut( [ line_item_for_buyer, w, q10(tab) ] )
	  
	, q10( [ line_item(f( [ q(alpha("H"),0,1), begin, q(dec,4,8), end] ) ), q10(tab)
	
		, trace( [ `line item`, line_item ] )
		
	] )
	
	, generic_item_cut( [ line_descr, s
		, [ q10(tab)
			, check( line_descr(start) > -360 )
			, check( line_descr(end) < 20 )
		]
	] )
	
	, generic_item_cut( [ potential_line_quantity, d
		, [ q10(tab)
			, check( potential_line_quantity(start) > 105 )
			, check( potential_line_quantity(end) > 134 ) 
			, check( potential_line_quantity(end) < 155 ) 
		]
	] )

	, set( regexp_cross_word_boundaries )
	
	, generic_item( [ line_unit_dummy, d
		, [ check( line_unit_dummy(start) > 170 )	
			, check( line_unit_dummy(end) > 210 )
			, check( line_unit_dummy(end) < 235 )
		]
	] )

	, clear( regexp_cross_word_boundaries )
	
	, q01( dummy_percent(s) ), tab
	
	, set( regexp_cross_word_boundaries )
	
	, generic_item_cut( [ line_unit_dumm, d ] )
	
	, clear( regexp_cross_word_boundaries )
	
	, q10( [ tab, dummy_net(s) ] ), newline
	
] ).


%=======================================================================
i_line_rule( line_invoice_three_extra_line, [
%=======================================================================

	  generic_item( [ line_quantity_uom_code_x, w
		, [ tab
			, check( line_quantity_uom_code_x(start) > 40 )
		]
	] )
	
	, set( regexp_cross_word_boundaries )
	
	, generic_item( [ line_total_amount, d
		, [ newline, check( line_total_amount(start) > 360 ) ]
	] )
	
	, clear( regexp_cross_word_boundaries )
	
] ).

%=======================================================================
i_line_rule( line_continuation_two_line, [
%=======================================================================

	  read_ahead( dummy_descr(s) )
	  
	, check( dummy_descr(start) > -360 )
	, check( dummy_descr(end) < 20 )
 
	, append( line_descr(s), ` `, `` ), newline
	
	, trace( [ `line description`, line_descr ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_four_line, [
%=======================================================================

	  trace( [ `in fourth` ] )
	
	, generic_item_cut( [ line_item_for_buyer, w, q10(tab) ] )

	, q10( [ line_item(f( [ q(alpha("H"),0,1), begin, q(dec,4,8), end] ) ), q10(tab)
	
		, trace( [ `line item`, line_item ] )
		
	] )
	
	, generic_item_cut( [ line_descr, s
		, [ q10(tab)
			, check( line_descr(start) > -360 )
			, check( line_descr(end) < 20 )
		]
	] )
	
	, generic_item( [ line_quantity_uom_code_x, w
		, [ tab
			, check( line_quantity_uom_code_x(start) > 40 )
		]
	] )

	, set( regexp_cross_word_boundaries )

	, generic_item_cut( [ potential_line_quantity, d
		, [ q10(tab)
			, check( potential_line_quantity(start) > 100 )
			, check( potential_line_quantity(end) > 134 ) 
			, check( potential_line_quantity(end) < 155 ) 
		]
	] )

	, generic_item( [ line_unit_dummy, d
		, [ check( line_unit_dummy(start) > 170 )	
			, check( line_unit_dummy(end) > 210 )
			, check( line_unit_dummy(end) < 235 )
		]
	] )
	
	, clear( regexp_cross_word_boundaries )
	
	, q01( dummy_percent(s) ), tab

	, set( regexp_cross_word_boundaries )
	
	, generic_item_cut( [ line_unit_dumm, d, tab ] )

	, generic_item_cut( [ line_total_amount, d, newline ] )
	
	, clear( regexp_cross_word_boundaries )

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
	
] ).

%=======================================================================
i_analyse_line_fields_first( LID )
%-----------------------------------------------------------------------
:- i_analyse_things___( [ LID ] ).
%=======================================================================

%=======================================================================
i_analyse_things___( [ LID ] )
%-----------------------------------------------------------------------
:-
%=======================================================================

	result( _, LID, line_descr, DESC )

	, result( _, LID, potential_line_quantity, PQ )

	, result( _, LID, line_quantity_uom_code_x, QUOM )
	
	, trace( analysis( LID, DESC, PQ, QUOM ) )
	
	, sys_string_split( DESC, ` `, DESC_LIST )

	, (
		q_sys_member( QUOM, [ `BT`, `JE`, `LT` ] )
		
		, q_sys_member( PRE, [ `LOT`, `BTE`, `BOITE`, `JEU` ] )
		

			, ( 
				sys_append( _, [ PRE, COMPACT_LIST | _ ], DESC_LIST )
				
				, q_sys_sub_string( COMPACT_LIST, 1, _, `DE` )
				
				, q_sys_sub_string( COMPACT_LIST, 3, _, NUM )
				
				, q_sys_comp( NUM \= `` )
				
				;
				
				sys_append( _, [ PRE, `DE`, NUM | _ ], DESC_LIST )
			
			)

		, trace( packet_size( NUM ) )
		
		, sys_string_number( NUM, Num )

		, q_sys_is_number( Num )

		, trace( `is number` )
		
		, sys_calculate_str_multiply( PQ, NUM, QUANTITY )

		;

		QUANTITY = PQ
	)
	
	, assertz_derived_data( LID, line_quantity, QUANTITY, i_analyse_line_fields_first )
	
	, !

	, (
		result( _, LID, line_item, _ )

		;

		sys_append( _, [ `REF`, NEWREF | _ ], DESC_LIST )

		, trace( line_item_ref_new( NEWREF ) )	
	
		, assertz_derived_data( LID, line_item, NEWREF, i_analyse_line_fields_first )
		
		;
		
		assertz_derived_data( LID, line_item, `Missing`, i_analyse_line_fields_first )

	)
	
	, !
. 

i_op_param( orders05_idocs_first_and_last_name( buyer_dept, _, NAME1 ), _, _, _, _) :- result( _, invoice, buyer_dept, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_from_contact, _, NAME2 ), _, _, _, _) :- result( _, invoice, delivery_from_contact, NU2 ), string_to_upper(NU2, NAME2).
