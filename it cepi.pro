%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT CEPI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_cepi, `30 June 2015` ).

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

	, gen_vert_capture( [ [ `Numero`, tab, `Pag` ], `Numero`, end, order_number, s1 ] )
	, gen_vert_capture( [ [ `Data`, `Documento` ], `Data`, end, invoice_date, date ] )
	
	, get_delivery_note_reference
	
	, gen_capture( [ [ gen_beof, `Firma` ], buyer_contact, s1 ] )
	, gen_capture( [ [ gen_beof, `Firma` ], delivery_contact, s1 ] )
	
	, gen_capture( [ [ `Riferimento`, `Commessa`, `:` ], customer_comments, s1 ] )
	
	, gen_capture( [ [ `Vettore`, `:` ], shipping_instructions, s1 ] )

	, get_invoice_lines
	
	, gen_vert_capture( [ [ `Totale`, tab, `I`, `.`, `V`, `.`, `A`, `.` ], `Totale`, end, total_net, d ] )
	, gen_vert_capture( [ [ `Totale`, tab, `I`, `.`, `V`, `.`, `A`, `.` ], `Totale`, end, total_invoice, d ] )
	
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
	
	, sender_name( `CEPI S.p.a.` )

	, suppliers_code_for_buyer( `12950087` )
	
	, set( delivery_note_ref_no_failure )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE REFERENCE	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_reference, [
%=======================================================================

	  q(0,30,line)
	, generic_vertical_details( [ [ `Destinazione`, `merce`, `:` ], note_ref, w, prepend( note_ref( `ITCEPI` ), ``, `` ) ] )
	
	, check( string_to_upper( note_ref, Ref ) )
	, delivery_note_reference( Ref )

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

		or( [ line_invoice_rule

			, line

		] )

	)

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Descrizione`, `della`, `merce`, `o`, `servizio`, tab, `U`, `.`, `M`, `.`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `Totale`, tab, `I`, `.`, `V`, `.`, `A`, `.`

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, generic_line( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], [ q10( a(s1) ), newline ] ] ) ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ line_net_amount, d ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )

] ).