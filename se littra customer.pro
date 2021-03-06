%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SE LITTRA CUSTOMER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( se_littra_customer, `28 July 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_order_number, `Delivery Order Number` ).
i_user_field( invoice, z099_instructions, `Z099 Instructions` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_date

	, get_order_number

	, get_buyer_contact

	, get_delivery_contact
	
	, get_invoice_type
	
	, get_shipping_conditions
	
	, get_shipping_instructions
	
	, get_delivery_order_number
	
	, get_z099_instructions
	
	, get_suppliers_code_for_buyer
	
	, get_delivery_note_number

	, get_invoice_lines
	
	, get_other_invoice_lines

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, [ qn0(line), invoice_total_line]

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	  without( buyer_party )

	, buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `SE-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2600`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, total_net( `0` )
	, total_invoice( `0` )
	, set( z099_instructions_enabled )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Märkning` ], 600, order_number, s1 ] )

] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ `The`, `message`, `has`, q0n(word) ], invoice_date, date ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING CONDITIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_conditions, [ q0n(line), shipping_condition_line ] ).
%=======================================================================
i_line_rule( shipping_condition_line, [ 
%=======================================================================

	  `Skickas`, tab
	  
	, or( [ [ `Today`, `Must`, type_of_supply( `01` ) ]
	
		, [ `Today`, `Can`, type_of_supply( `S1` ) ]
		
		, [ `Sthlmsbilen`, type_of_supply( `UH` ) ]
		
		, [ `10`, `-`, `leverans`, type_of_supply( `42` ) ]
		
	] )
	
	, trace( [ `Shipping Conditions`, shipping_conditions ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TYPE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_type, [ q0n(line), invoice_type_line ] ).
%=======================================================================
i_line_rule( invoice_type_line, [ 
%=======================================================================

	or( [ `Övrig`
		, [ `Ö`, `vrig` ]
		
		, `Ãvrig`
		, [ `Ã`, `vrig` ] 
		
	] )

	, `information`, tab

	, invoice_type( `Z5` )
	, trace( [ `Got invoice type` ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Kontaktperson` ], 400, buyer_contact, s1 ] )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  or( [ [ q0n(line), generic_horizontal_details( [ [ at_start, q(0,3,word), `Mottagare` ], 400, delivery_contact, s1 ] ) ]
	  
		, [ with( invoice, buyer_contact, Con )
			, delivery_contact( Con )
		]
	
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPECIAL SECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_order_number, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Littera` ], 500, delivery_order_number, s1 ] )

] ).

%=======================================================================
i_rule( get_z099_instructions, [
%=======================================================================

	q0n(line), generic_horizontal_details( [ [ at_start, `ID06`, `/`, `BB`, `-`, `nr` ], 500, z099_instructions, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_rule( get_delivery_note_number, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Ship`, `To` ], 400, delivery_note_number, s1 ] )

] ).

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Sold`, `To` ], 400, suppliers_code_for_buyer, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ at_start, `Instruktion`, `till`, dummy(s1), peek_fails( [ tab, `Nej` ] ) ], 400, shipping_instructions, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, or( [ [ q0n( line_invoice_rule), line_end_line ]
	
		, [ force_result( `defect` ), force_sub_result( `missed_line` ) ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Fyll`, `ej`, `i`, `beteckning`] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Fler`, `orderrader` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  generic_line( [ [ `Artikelnr`, or( [ [ tab, generic_item( [ line_item, s1 ] ) ], [ newline, set( item_missing ) ] ] ) ] ] )
	  
	, generic_line( [ [ `Antal`, or( [ [ tab, generic_item( [ line_quantity, s1 ] ) ], [ newline, set( qty_missing ) ] ] ) ] ] )

	, generic_line( [ [ `Beteckning`, or( [ [ tab, generic_item( [ line_descr, s1 ] ) ], [ newline, line_descr( `Beteckning` ), set( descr_missing ) ] ] ) ] ] )
	
	, or( [ [ test( item_missing ), test( qty_missing ), test( descr_missing ), line_type( `ignore` ) ]
		
		, count_rule
		
	] )
	
	, clear( item_missing )
	, clear( qty_missing )
	, clear( descr_missing )

] ).

%=======================================================================
i_section( get_other_invoice_lines, [
%=======================================================================

	 line_other_header_line

	, or( [ [ q0n( line_invoice_line ), line_other_end_line, remove( force_result ), remove( force_sub_result ) ]
	
		, [ force_result( `defect` ), force_sub_result( `missed_line` ) ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_other_header_line, [ `Artikel`, tab, `Beteckning`, tab, `Antal`] ).
%=======================================================================
i_line_rule_cut( line_other_end_line, [ `The`, `message` ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	  
	, q10( generic_item( [ line_descr, s1, tab ] ) )
	
	, generic_item( [ line_quantity, d, newline ] )
	
	, count_rule

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).