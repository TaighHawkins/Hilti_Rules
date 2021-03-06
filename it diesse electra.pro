%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT DIESSE ELECTRA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_diesse_electra, `12 May 2015` ).

i_pdf_parameter( same_line, 8 ).

i_user_field( invoice, i_cig, `CIG` ).
i_user_field( invoice, i_cup, `CUP` ).

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

	, gen_vert_capture( [ [ `Numero`, `ordine` ], order_number, s1 ] )
	, gen_vert_capture( [ [ `Data`, `ordine` ], `ordine`, end, invoice_date, date ] )
	
	, get_delivery_address
	, gen_capture( [ [ gen_beof, `CIG` ], i_cig, s1 ] )
	, gen_capture( [ [ gen_beof, `CUP` ], i_cup, s1 ] )
	, populate_delivery_address_line
	
	, gen_vert_capture( [ [ `Emesso`, `da`, gen_eof ], buyer_contact, s1 ] )
	, gen_vert_capture( [ [ `Emesso`, `da`, gen_eof ], delivery_contact, s1 ] )
	
	, gen_capture( [ [ at_start, `Commessa` ], 200, customer_comments, s1 ] )
	
	, gen_capture( [ [ at_start, `Ns`, `riferimento`, `in`, `cantiere` ], 200, shipping_instructions, s1 ] )

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

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `13023176` ) ]    %TEST
	    , suppliers_code_for_buyer( `13023176` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Diesse Electra S.p.a.` )
	
	, delivery_party( `DIESSE ELECTRA SPA` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q(0,5,line)
	, generic_horizontal_details( [ [ `Destinazione`, `merce` ] ] )
	
	, q(0,3,line)
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_dept, s1 ] )
	
	, q(0,3,line)
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] )
	
	, q(0,6,line)
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	  nearest( generic_hook(start), 10, 20 )
	
	, q10( generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] ) )

	, generic_item( [ delivery_city, sf, `(` ] )

	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ], `)` ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POPULATE DELIVERY ADDRESS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( populate_delivery_address_line, [
%=======================================================================

	  or( [
	  
		[ with( invoice, i_cig, CIG )
		
			, or( [
				[ with( invoice, i_cup, CUP ), check( strcat_list( [ `CIG:`, CIG, ` CUP:`, CUP ], Address_line ) ) ]
				, check( strcat_list( [ `CIG:`, CIG ], Address_line ) )
			] )
			
		]
		
		, [ with( invoice, i_cup, CUP ), check( strcat_list( [ `CUP:`, CUP ], Address_line ) ) ]
		
	] )
	
	, delivery_address_line( Address_line )
	, trace( [ `delivery_address_line`, delivery_address_line ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	  or( [
	
		[ q0n(line), generic_vertical_details( [ [ `Tot`, `.`, `imp`, `.`, `Netto` ], `Netto`, end, total_net, d, tab ] )
			, check( total_net = Net )
			, total_invoice( Net )
		]
		
		, [ total_net( `0` ), total_invoice( `0` ), trace( [ `total_net`, total_net ] ), set( zero_value ) ]
		
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

	, trace( [ `found header` ] )

	, q0n( [

		  or( [
		
			  line_invoice_line
			
			, [ test( zero_value ), line_defect_line ]

			, line

		] )

	] )

	, line_end_line 

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Codice`, `articolo`, tab, `Descrizione`, tab, `U`, `.`, `M`, `.`, tab, `Quantità`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [
	
		[ `Emesso`, `da`, gen_eof ]
		
		, [ `ORDINE`, `FORNITORE`, newline ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_defect_line, [
%=======================================================================

	  q0n(anything), generic_no( [ a, d, tab ] ), generic_no( [ a, d ] )
	
	, generic_item( [ a, date, newline ] )
	
	, force_result( `defect` )
	, force_sub_result( `missed_line` )
	, trace( [ `missed line` ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  or( [
	
		[ generic_item( [ line_item, [ q(alpha("HIL"),0,3), begin, q(dec,1,8), end ], tab ] ), check( line_item(start) < -420 ) ]
		
		, set( ignore_line )
		
	] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, q01( generic_item( [ line_quantity_uom_code, s1, tab ] ) )
	
	, generic_no( [ line_quantity, d, tab ] )

	, generic_no( [ prezzo_un_listo, d, tab ] )
	
	, q10( generic_no( [ prezzo_tot_listo, d, q10(tab) ] ) )
	
	, generic_no( [ sc_1, d, tab ] )
	
	, generic_no( [ sc_2, d ] )
	
	, generic_no( [ sc_3, d, tab ] )
	
	, q10( generic_no( [ line_unit_amount, d, tab ] ) )
	
	, generic_no( [ line_net_amount, d, tab ] )

	, generic_no( [ iva, d ] )

	, generic_item( [ line_original_order_date, date, newline ] )
	
	, q10( [ test( ignore_line ), line_type( `ignore` ), trace( [ `line ignored` ] ) ] )
	
	, clear( ignore_line )

] ).