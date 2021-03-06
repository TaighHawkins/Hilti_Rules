%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT TELEBIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_telebit, `30 June 2015` ).

% i_pdf_parameter( same_line, 8 ).

i_date_format( _ ).
i_format_postcode( X, X ).
i_op_param( xml_transform( delivery_street, In ), _, _, _, Out )
:-
	string_string_replace( In, `,`, ` `, Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, gen_vert_capture( [ [ `ORDINE`, `N`, `°`, tab ], order_number, s1, tab ] )
	, gen_vert_capture( [ [ `Data`, tab ], invoice_date, date, tab ] )
	, gen_vert_capture( [ [ `Redatto`, `Da` ], buyer_contact, s1 ] )
	, [ with( invoice, buyer_contact, Contact ), check( Contact = `MAGAZZINO` ), buyer_dept( `ITTELEMAGAZZINO` ) ]
	
	, gen_capture( [ [ `Commessa`, `:` ], customer_comments, s1, newline ] )
	
	% , get_duplicate_details
	
	, get_special_rule
	
	, get_invoice_lines
	
	, get_notes_section
	
	, gen_vert_capture( [ [ `Totale`, `Imponibile` ], `Imponibile`, q(0,0), (end, 15, 15), total_net, d ] )
	, gen_vert_capture( [ [ `Totale`, `IVA` ], `IVA`, q(0,0), (end, 15, 15), total_vat, d ] )
	, gen_vert_capture( [ [ `Totale`, `Ordine` ], `Ordine`, q(0,0), (end, 15, 15), total_invoice, d ] )
	
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

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Telebit s.r.l` )

	, suppliers_code_for_buyer( `12946138` )
	
	, set( delivery_note_ref_no_failure )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DUPLICATE DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_duplicate_details, [ 
%=======================================================================

	q10( [
	
		with(invoice, buyer_contact, Cont)
		
		, delivery_contact(Cont)
		
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET NOTES SECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_notes_section, [ 
%=======================================================================

	q0n(line)
	
	, generic_line( [ [ at_start, `Note`, newline ] ] )
	
	, gen1_parse_text_rule( [ -500, 500, [ `Sulla`, `Vostra`, `Fattura` ] ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SPECIAL RULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_special_rule, [ 
%=======================================================================

	q0n(line)

	, generic_vertical_details( [ [ `DESTINAZIONE`, `MERCE` ], spec_rule, s1, newline ] )
	
	, check( spec_rule = DelivRef )
	
	, set(delivery_note_ref_no_failure)
	
	, or( [ 
	
		[ check( q_sys_sub_string( DelivRef, _, _, `MAGAZZINO BORGONOVO Z.A.` ) ), delivery_note_reference(`ITTELEMAGBORGON`), trace( [ `Delivery Note Reference`, delivery_note_reference ] ) ]
		
		, [ check( q_sys_sub_string( DelivRef, _, _, `MAGAZZINO DOSSON` ) ), delivery_note_reference(`ITTELEMAGDOSSON`), trace( [ `Delivery Note Reference`, delivery_note_reference ] ) ]
		
		, [ check( q_sys_sub_string( DelivRef, _, _, `MAGAZZINO VILLOTTA` ) ), delivery_note_reference(`ITTELEMAGVILLOT`), trace( [ `Delivery Note Reference`, delivery_note_reference ] ) ]
		
		, [ check( q_sys_sub_string( DelivRef, _, _, `MAGAZZINO LENDINARA` ) ), delivery_note_reference(`ITTELEMAGLENDIN`), trace( [ `Delivery Note Reference`, delivery_note_reference ] ) ]
		
		, [ check( q_sys_sub_string( DelivRef, _, _, `MAGAZZINO` ) ), buyer_dept(`ITTELEMAGAZZINO `), delivery_from_contact(`ITTELEMAGAZZINO`), trace( [ `Buyer Party`, buyer_party ] ) ]
		
	] )

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

	, q0n(

		or( [ line_invoice_line

			, line

		] )

	)

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`ARTICOLO`, tab, `DESCRIZIONE`, tab, `RIF`, `.`, `FORN`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `Spese`

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item( [ line_itemx, s1, tab ] )
	  
	, check( strip_string2_from_string1( line_itemx, `HIL`, Item) )
	
	, line_item(Item)
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ dummy, d, tab ] )
	
	, generic_no( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )
	
	, line_vat_rate(`22`)

] ).



















