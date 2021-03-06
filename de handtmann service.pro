%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE HANDTMANN SERVICE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_handtmann_service, `3 February 2015` ).

i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, gen_vert_capture( [ [ `Bestellnummer`, `/`, `Datum`, newline ], order_number, sf, [ `/`, generic_item( [ invoice_date, date, newline ] ) ] ] )
	
	, get_delivery_details
	
	, gen_vert_capture( [ [ `AnsprechpartnerIn`, newline ], buyer_contact, s1, newline ] )
	, gen_vert_capture( [ [ `AnsprechpartnerIn`, newline ], delivery_contact, s1, newline ] )
	
	, gen_vert_capture( [ [ `Unsere`, `e`, `-`, `Mail`, `Adresse`, newline ], buyer_email, s1, newline ] )
	, gen_vert_capture( [ [ `Unsere`, `e`, `-`, `Mail`, `Adresse`, newline ], delivery_email, s1, newline ] )
	
	, get_buyer_and_delivery_ddi
	, get_buyer_and_delivery_fax
	
	, get_shipping_instructions
	
	, get_due_date
	
	, gen_capture( [ [ `Gesamtnettowert`, `ohne`, `Mwst`, `EUR` ], 300, total_net, d, newline ] )
	, gen_capture( [ [ `Gesamtnettowert`, `ohne`, `Mwst`, `EUR` ], 300, total_invoice, d, newline ] )

	, get_invoice_lines
	
	, get_validation_totals

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, suppliers_code_for_buyer( `10163560` )

	, sender_name( `Handtmann Service GmbH` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================	  

	q(0,20,line)
	
	, generic_line( [ [ `Bitte`, `liefern`, `Sie`, `an`, `:` ] ] )
	
	, q01(line)
	
	, generic_horizontal_details( [ at_start, delivery_party, s1 ] )
	
	, generic_horizontal_details( [ at_start, delivery_dept, s1 ] )
	
	, generic_horizontal_details( [ at_start, delivery_street, s1 ] )
	
	, delivery_postcode_and_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================	  

	generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY DDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_ddi, [
%=======================================================================

	q(0,20,line), generic_vertical_details( [ [ `Unsere`, `Telefonnummer`, newline ], buyer_ddi_x, s1, newline ] )
	
	, check( strip_string2_from_string1( buyer_ddi_x, ` `, DDI_X ) )
	
	, check( string_string_replace( DDI_X, `+49(0)`, `0`, DDI ) )
	
	, buyer_ddi(DDI), trace( [ `Cleaned up buyer_ddi`, buyer_ddi ] )
	
	, delivery_ddi(DDI)
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY FAX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_fax, [
%=======================================================================

	q(0,20,line), generic_vertical_details( [ [ `Unsere`, `Faxnummer`, newline ], buyer_fax_x, s1, newline ] )
	
	, check( strip_string2_from_string1( buyer_fax_x, ` `, FAX_X ) )
	
	, check( string_string_replace( FAX_X, `+49(0)`, `0`, FAX ) )
	
	, buyer_fax(FAX), trace( [ `Cleaned up buyer_fax`, buyer_fax ] )
	
	, delivery_fax(FAX)
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [
%=======================================================================

	q(0,20,line)
	
%	Search too general - multiple postal codes on document - added this line to target search
	, generic_line( [ [ `Bitte`, `liefern`, `Sie`, `an`, `:` ] ] )
	
	, q(0,10,line)
	
	, peek_ahead( delivery_postcode_and_city_line ), line
	
	, q0n(shipping_instructions_line)
	
	, generic_line( [ [ `Lieferbed`, `.` ] ] )
	
	, trace( [ `got shipping instructions` ] )

] ).

%=======================================================================
i_line_rule( shipping_instructions_line, [
%=======================================================================

	or( [
	
		[ test( ship_instr ), append( shipping_instructions(s1), `~`, ` ` ) ]
		
		, [ generic_item( [ shipping_instructions, s1 ] ), set( ship_instr ) ]
		
	] )
	
	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DUE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_due_date, [
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ `Liefertermin`, due_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, trace( [ `found header` ] )

	, qn0( [ peek_fails( line_end_line )

		  , or( [
		
			generic_line( [ [ `_`, `_`, `_`, `_`, `_`, `_` ] ] )
			
			, line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`Menge`, tab, `ME`, tab
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [
	
		[ `=`, `=`, `=` ]
		
		, [ `Gesamtnettowert`, `ohne`, `Mwst` ]
		
		, [ `Handtmann`, `Service`, `GmbH` ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_item_descr_line
	
	, line_invoice_line
	
	, generic_horizontal_details( [ [ `Ihre`, `Materialnummer` ], line_item, s1, newline ] )
	
	, or( [

		[ test( discounted_line ), q(2,3,line), line_discounted_values_line ]
		
		, peek_fails( test( discounted_line ) )
		
	] )
	
	, clear( discounted_line )
	
	, q10( [ with( invoice, due_date, Date ), line_original_order_date(Date) ] )
	
	, q10( [ test( no_values_line ), line_net_amount(`1`) ] )
	
	, clear( no_values_line )

] ).

%=======================================================================
i_line_rule_cut( line_item_descr_line, [
%=======================================================================

	generic_item( [ line_order_line_number, w ] )
	
	, q10( line_item_for_buyer(s1) ), tab
	
	, generic_item( [ line_descr, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	line_quantity(d)
	
	, or( [
		
		[ line_quantity_uom_code(s1)
			, or( [
				[ tab, line_unit_amount_x(d), q10( [ `/`, a(d) ] ), tab, generic_item( [ line_net_amount, d ] ) ]
				, set( discounted_line )
			] )
		]
		
		, [ tab, line_quantity_uom_code(s1), set( no_values_line ) ]
		
	] )
	
	, newline

] ).

%=======================================================================
i_line_rule_cut( line_discounted_values_line, [
%=======================================================================

	trace( [ `line_discounted_values_line` ] )
	
	, `Nettowert`, `incl`, `R`, tab, a(d), tab, `EUR`, tab, a(d), word, tab
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET VALIDATION TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_validation_totals, [
%=======================================================================

	line_header_line
	
	, without( total_net )

	, qn0( [ peek_fails( line_end_line )

		, or( [ total_add_line, line ] )

	] )

] ).

%=======================================================================
i_line_rule_cut( total_add_line, [
%=======================================================================

	line_no(f([ begin, q(dec,5,5), end ]))
	
	, check( line_no(end) < -250 )
	
	, total_add_rule

] ).

%=======================================================================
i_rule_cut( total_add_rule, [
%=======================================================================

	or( [
	
		[ with( invoice, total_net, Net ), check( sys_calculate_str_add( Net, `1`, Total ) ) ]
		
		, check( Total = `1` )
		
	] )
	
	, total_net(Total), total_invoice(Total), trace( [ `new total`, Total ] )

] ).