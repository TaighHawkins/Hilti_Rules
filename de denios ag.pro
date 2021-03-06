%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DENIOS AG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_denios_ag, `11 May 2015` ).

i_date_format( _ ).
i_format_postcode( X,X ).

i_pdf_paramater( x_tolerance_100, 100 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, gen_capture( [ [ `Bestellung` ], order_number, s1, newline ] )
	, gen_capture( [ [ `Liefertermin`, q10(tab), `Tag` ], delivery_date, date ] )
	, gen_capture( [ [ `Datum`,`:`, tab ], invoice_date, date, newline ] )

	, get_buyer_details
	
	, get_delivery_location
		
	, set(reverse_punctuation_in_numbers)
	
	, get_invoice_lines
	
	, get_invoice_totals
	
	, clear(reverse_punctuation_in_numbers)
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%
	
	, sender_name( `Denios AG` )
	
	, suppliers_code_for_buyer( `10307712` )
	
	, buyer_organisation( `Z099` )
	
	, set( no_pc_cleanup )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_details, [ 
%=======================================================================

	q0n(line)

	, generic_horizontal_details( [ [ `Es`, `schreibt`, `Ihnen`, `:`, tab ], buyer_contact, s1, newline ] )
	, generic_horizontal_details( [ [ `Telefon`, `:`, tab ], buyer_ddiy, s1, newline ] )
	, generic_horizontal_details( [ [ `Telefax`, `:`, tab ], buyer_faxy, s1, newline ] )
	, generic_horizontal_details( [ [ `E`, `-`, `Mail`, `:`, tab ], buyer_email, s1, newline ] )
	
	, check( string_string_replace( buyer_ddiy, `-`, ``, DDI ) )
	, check( string_string_replace( buyer_faxy, `-`, ``, FAX ) )
	, with(invoice, buyer_contact, CONTACT )
	, with(invoice, buyer_email, EMAIL )
	
	, buyer_ddi( DDI ), delivery_ddi( DDI )
	, buyer_fax( FAX ), delivery_fax( FAX )
	, delivery_contact( CONTACT ) 
	, delivery_email( EMAIL ) 
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	q0n(line)

	, delivery_header_line
	
	, trace( [ `Here` ] )
	
	, q(0,2,line)
	
	, delivery_dept_line
	
	, trace( [ `Here1` ] )
	
	, q(0,2,line)
	
	, delivery_street_line
	
	, trace( [ `Here2` ] )
	
	, q(0,2,line)
	
	, delivery_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	q0n(anything), read_ahead( [ `Bitte`, `liefern`, `Sie`, `an`, `:` ] ), header(w)
	
] ).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_party, s1, newline ] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_street, s1, newline ] )
	
] ).


%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 )
	
	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	
	, generic_item( [ delivery_city, s1 ] ), newline
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_section_control( get_invoice_lines, first_one_only ).
i_section_end( get_invoice_lines, line_section_end_line ).
i_line_rule( line_section_end_line, [ `Hilti`, `Deutschland`, `GmbH` ] ).

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ 
		
			get_line_invoice_rule

			,line
			])

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Bestellmenge`, tab, `Einheit`, tab, `Preis`, `pro`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	`Gesamtpositionsnettowert`, `EUR`
	
] ).

%=======================================================================
i_rule_cut( get_line_invoice_rule, [
%=======================================================================
	
	invoice_line1
	
	, invoice_line2
	
	, q(4,10,line)
	
	, q10(invoice_line3)
	
	, invoice_line4
	
	, q(0,4,line)
	
	, or( [
	
		[ test(`NetMissing`), invoice_line5 ]
		
		, [ peek_fails( test(`NetMissing`) ), trace( [ `Item Completed` ] ) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( invoice_line1, [
%=======================================================================
	
	generic_item( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s1, newline ] )
	

] ).

%=======================================================================
i_line_rule_cut( invoice_line2, [
%=======================================================================
	
	generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1 ] )

	, or( [ 
	
		[ newline, trace( [ `Net amount not on this line` ] ), set(`NetMissing`) ]
		
		, [ tab, line_unit_amount(d), q10( [ `/`, a(d) ] ), tab, line_net_amount(d), trace( [ `Got net amount` ] ) ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( invoice_line3, [
%=======================================================================

	`Liefertermin`, `Tag`
	
	, generic_item( [ line_original_order_date, date ] )

] ).

%=======================================================================
i_line_rule_cut( invoice_line4, [
%=======================================================================

	or( [ 
	
		[ `Artikel`, `Nr`, `.`, `Hilti`, `=` ]
		
		, [ `Ihre`, `Materialnummer` ]
		
		, [ `Artikelnr`, `.` ]
		
	] )
	
	, generic_item( [ line_item, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( invoice_line5, [
%=======================================================================

	generic_item( [ dummy, s1, tab ] ) 
	
	, generic_item( [ line_unit_amount, d, tab ] ) 
	
	, generic_item( [ dummy, s1, tab ] ) 
	
	, generic_item( [ dummy, s1, tab ] ) 
	
	, generic_item( [ line_net_amount, d, newline ] )

	, clear(`NetMissing`)

] ).

%=======================================================================
i_rule_cut( get_invoice_totals, [
%=======================================================================

	or( [ 
	
		gen_capture( [ [ `Gesamtpositionsnettowert`, `EUR`, tab ], total_net, d, newline ] )
		
		, gen_capture( [ [ `Gesamtnettowert`, `ohne`, `Mwst`, `EUR`, tab ], total_net, d, newline ] )
		
	] )
	
	, with(invoice, total_net, Net)
	, total_invoice(Net)

] ).






