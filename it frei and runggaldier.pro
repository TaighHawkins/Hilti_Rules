%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT FREI AND RUNGGALDIER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_frei_and_runggaldier, `26 June 2015` ).

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

	, gen_vert_capture( [ [ `Numero`, tab, `Data` ], order_number, s1, tab ] )
	, gen_vert_capture( [ [ `Data`, tab, `Pagina` ], invoice_date, date, tab ] )
	
	, get_delivery_address
	
	, gen_capture( [ [ `Incaricato`, `:` ], 200, buyer_contact, s1 ] )
	, gen_capture( [ [ `Incaricato`, `:` ], 200, delivery_contact, s1 ] )
	
	, gen_vert_capture( [ [ `Data`, `consegna`, tab, `Confermato` ], due_date, date ] )
	
	, gen_vert_capture( [ [ `CONDIZIONI`, `DI`, `RESA` ], shipping_instructions, s1 ] )

	, get_invoice_totals

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
	
	, sender_name( `Frei & Runggaldier Srl` )
	
	, delivery_note_reference( `ITFREIMAGAZZINO` )
	, set( delivery_note_ref_no_failure )

	, suppliers_code_for_buyer( `12949769` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q(0,35,line)
	
	, generic_horizontal_details( [ [ `Destinazione`, newline ] ] )
	
	, line
	
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_party, s1 ] )
	
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] )
	
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	  nearest( generic_hook(start), 10, 20 )
	
	, `I`, `-`, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )

	, generic_item( [ delivery_city, sf ] )

	, generic_item( [ delivery_state, [ q(other("("),0,1), begin, q(alpha,2,2), end, q(other(")"),0,1) ], gen_eof ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact, [
%=======================================================================

	  q(0,35,line)
	
	, generic_vertical_details( [ [ `CONTRATTATORE`, `/`, `BUYER`, `CODE` ], contact, s1, [ tab, `Tel` ] ] )
	
	, check( i_user_check( reverse_names_in_contact, contact, Contact ) )
	
	, buyer_contact( Contact )
	, delivery_contact( Contact )
	, trace( [ `contact`, Contact ] )
	
] ).

%-----------------------------------------------------------------------
i_user_check( reverse_names_in_contact, Contact_in, Contact )
%-----------------------------------------------------------------------
:-
	sys_string_split( Contact_in, ` `, [ Last, First ] ),
	strcat_list( [ First, ` `, Last ], Contact )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	  qn0(line), invoice_totals_line(2,200,500)
	
] ).

%=======================================================================
i_line_rule( invoice_totals_line, [
%=======================================================================

	  `Importo`, `totale`, generic_no( [ total_net, d, `€` ] )
	
	, check( total_net = Net ), total_invoice( Net )
	
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

	, q0n( [

		  or( [
		
			  line_invoice_line

			, line

		] )

	] )

	, line_end_line 

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Codice`, tab, `Descrizione`, tab, `UM`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `Importo`, `merce`, tab

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, generic_no( [ line_unit_amount_x, d, tab ] )
	
	, generic_no( [ discount_, d, tab ] )
	
	, generic_no( [ line_net_amount, d ] )
	
	, generic_no( [ iva_, d, [ `.`, newline ] ] )
	
	, with( invoice, due_date, Date )
	, line_original_order_date( Date )

] ).