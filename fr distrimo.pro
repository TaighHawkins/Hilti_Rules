%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DISTRIMO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( distrimo_2, `17 March 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_pdf_parameter( same_line, 6 ).
i_user_field( invoice, buyer_dept, `Buyer Dept` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	designation_defect_rule
	
	, get_delivery_note_number

	, get_fixed_variables 

	, get_order_number
	
	, get_order_date
	
	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_contacts

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

] ):- not( grammar_set( do_not_process ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESIGNATION DEFECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( designation_defect_rule, [ 
%=======================================================================

	  q0n(line), desigination_header_line
	  
	, q0n(line), designation_defect_line( 1, -260, 15 )

] ).

%=======================================================================
i_line_rule( desigination_header_line, [ 
%=======================================================================

	`Réf`, `.`, tab, `Réf`, `.`, tab, `Désignation`

] ).

%=======================================================================
i_line_rule( designation_defect_line, [ 
%=======================================================================

	q0n(word)
	
	, or( [ `BOUYGUES`, `CONTACT`, `LIVRAISON`, `REGULE`, `REGULARISATION`, `Regul`, `Régul`, `RÉGULARISATION` ] )
	
	, trace( [ `defect` ] )
	
	, delivery_note_reference( `special_rule` )
	
	, set( do_not_process )

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
	
	, set( leave_spaces_in_order_number )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_number, [
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Adresse`, `de`, `livraison` ] ] )

	, or( [ [ q(0,5,line), delivery_note_number_line ]
		
		, [ delivery_note_reference( `special_rule` ), set( do_not_process )
			, trace( [ `Address Not Found` ] )
		]
	] )
] ).

%=======================================================================
i_line_rule( delivery_note_number_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 50 )
	  
	, q0n(word)
	
	, or( [ [ `76410`, delivery_note_number( `11728554` ) ]
	
		, [ `91380`, delivery_note_number( `11813529` ) ]
		
	] )
	
	, trace( [ `Delivery Note Number`, delivery_note_number ] )
	
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
	  
	, read_ahead( generic_horizontal_details( [ [ `N`, `°`, `COMMANDE`, `D`, `'`, `ACHAT`, `:` ], order_number, s1 ] ) )
	
	, generic_line( [ [ q0n(anything), `Centre`, `Imputation`, `:`, append( order_number(s1), ` `, `` ) ] ] )

] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ `Date`, `:` ], invoice_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================

	qn0(line), generic_horizontal_details( [ [ `Emetteur`, `:` ], buyer_contact_x, s1 ] )

	, check( sys_string_split( buyer_contact_x, ` `, ConList ) )
	, check( sys_reverse( ConList, [ Surname | _ ] ) )
	, check( strcat_list( [ `FRDIST`, Surname ], LIFNR ) )
	
	, buyer_dept( LIFNR )
	, delivery_from_contact( LIFNR )
	
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
	
	, generic_vertical_details( [ [ at_start, `Total`, `HT`, set( regexp_cross_word_boundaries ) ], `HT`, end, 10, 40, total_net, d ] )

	, check( total_net = Net )
	, total_invoice( Net )
	
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
		
			, line_continuation_line
		
			, line

		] )

	), line_end_line
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `DISTRIMO`, tab, `Fournisseur` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `Adresse`, `de` ], [ `A`, `reporter` ] ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ peek_fails( test( need_descr ) )
		, [ test( need_descr ), generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] ) ]
	] )
	  
	, count_rule


] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  retab( [ -363, -257, 20, 45, 135, 215, 290, 375 ] )

	, generic_item_cut( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_item, [ q(alpha("H"),0,1), begin, q(dec,4,10), end ], tab ] )
	
	, or( [ generic_item_cut( [ line_descr, s1, tab ] ), [ tab, set( need_descr ) ] ] )

	, generic_item( [ line_quantity_uom_code_x, s1, tab ] )
	
	, set( regexp_cross_word_boundaries )
	, generic_item_cut( [ line_quantity, d, tab ] )
	, generic_item_cut( [ line_unit_amount_x, d, tab ] )
	, q10( generic_item( [ line_percent_discount, d ] ) ), tab
	, generic_item_cut( [ line_unit_after_disc, d, tab ] )
	, generic_item_cut( [ line_net_amount, d, newline ] )
	, clear( regexp_cross_word_boundaries )
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  append( line_descr(s), ` `, `` ), newline
	
	, trace( [ `Appended line decription`, line_descr ] )
	
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
:- i_analyse_things( LID ).
%=======================================================================

%=======================================================================
i_analyse_things( LID )
%-----------------------------------------------------------------------
:-
%=======================================================================

	result( _, LID, line_descr, DESC ),
	result( _, LID, line_quantity, PQ ),
	
	trace( analysis( LID, DESC, PQ ) ),
	string_string_replace( DESC, `/`, ` / `, DESCRREP ),
	string_string_replace( DESCRREP, `BOITE`, ` BOITE `, DESCRREP1 ),
	string_string_replace( DESCRREP1, `BTE`, ` BTE `, DESCRREP2 ),
	string_string_replace( DESCRREP2, `JEU`, ` JEU `, DESCRREP3 ),
	string_string_replace( DESCRREP3, `LOT`, ` LOT `, DESCRREP4 ),
	string_string_replace( DESCRREP4, `PAQUET`, ` PAQUET `, DESCRREP5 ),
	string_string_replace( DESCRREP5, `LEU`, ` LEU `, DESCRREP6 ),
	sys_string_split( DESCRREP6, ` `, DESC_LIST ),
	q_sys_member( PRE, [ `LOT`, `BTE`, `BOITE`, `JEU`, `LEU`, `PAQUET` ] ),
	
	( 
		sys_append( _, [ PRE, COMPACT_LIST | _ ], DESC_LIST ),
		q_sys_sub_string( COMPACT_LIST, 1, _, `DE` ),
		q_sys_sub_string( COMPACT_LIST, 3, _, NUM ),
		q_sys_comp( NUM \= `` )
		
		;	sys_append( _, [ PRE, `DE`, NUM | _ ], DESC_LIST )			
	),

	trace( packet_size( NUM ) ),
	sys_string_number( NUM, Num ),
	q_sys_is_number( Num ),
	trace( `is number` ),
	
	sys_calculate_str_multiply( PQ, NUM, QUANTITY ),
	
	sys_retract( result( _, LID, line_quantity, PQ ) ),
	assertz_derived_data( LID, line_quantity, QUANTITY, i_alter_quantities ),
	
	!
. 

i_op_param( orders05_idocs_first_and_last_name( Var, Name1L, Name2U ), _, _, _, _ )
:- 
	q_sys_member( Var, [ buyer_contact, delivery_contact ] ),
	result( _, invoice, Var, Names ), 
	sys_string_split( Names, ` `, [ Name1, Name2 ] ), 
	string_to_upper(Name2, Name2U), 
	string_to_lower( Name1, Name1L )
.