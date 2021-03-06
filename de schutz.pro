%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SCHÜTZ GMBH & CO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_shutz, `23 July 2015` ).

i_date_format( _ ).
i_format_postcode( X,X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, gen_capture( [ [ `Bestellnummer`, `/`, `Datum`, `:` ], order_number, s, `v` ] )
	, gen_capture( [ [ at_start, `Datum`,`:`, tab ], invoice_date, date, newline ] )
	, gen_capture( [ [ `Liefertermin`,`:`, tab ], delivery_date, date, newline ] )
	
	, get_delivery_location
	
	, get_buyer_details
			
	, set(reverse_punctuation_in_numbers)
	
	, get_invoice_lines
	
	, get_invoice_totals
	
	, clear(reverse_punctuation_in_numbers)
	
	, get_date
	
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
	
	, sender_name( `SCHÜTZ GMBH & CO.` )
	
	, suppliers_code_for_buyer(`10166112`)


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_date, [ 
%=======================================================================

	without(delivery_date)
	
	, with(1, line_original_order_date, Date)
	
	, delivery_date( Date )
	
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

	, generic_horizontal_details( [ [ `Telefon`, `:`, tab ], delivery_ddiy, s1, newline ] )
	
	, q01(line)
	
	, generic_horizontal_details( [ [ `Faxnummer`, `:`, tab ], delivery_faxy, s1, newline ] )
	
	, q01(line)

	, generic_horizontal_details( [ [ `E`, `-`, `Mail`, `:`, tab ], delivery_email, s1, newline ] )
	
	, with( invoice, delivery_email, Email )
	
	, buyer_email( Email )
	
	, manipulate_things( [ Email ] )
	
] ).

%=======================================================================
i_rule( manipulate_things( [ Email ] ), [
%=======================================================================
	
	  check( strip_string2_from_string1( delivery_ddiy, `-/ `, DDI ) )
	, check( strip_string2_from_string1( delivery_faxy, `-/ `, FAX ) )
	
	, delivery_ddi( DDI )
	, buyer_ddi( DDI )
	
	, delivery_fax( FAX )
	, buyer_fax( FAX )
	
	, delivery_contact( Contact )
	, buyer_contact( Contact )
	
] )
:-
	sys_string_split( Email, `@`, [ Name, Domain ] ),
	string_string_replace( Name, `.`, ` `, Contact )
.


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
	
	, q(0,2,line)
	
	, delivery_dept_line
	
	, q(0,2,line)
	
	, delivery_street_line
	
	, q(0,2,line)
	
	, delivery_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	q0n(anything), read_ahead( [ `Lieferung`, `erfolgt`, `an`, `:` ] ), header(w)
	
] ).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_party, s1, gen_eof ] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_street, s1, gen_eof ] )
	
] ).


%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 )
	
	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	
	, generic_item( [ delivery_city, s1, gen_eof ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ 
%=======================================================================

	`_`, `_`, `_`, a(w), check( a(size) = 7 ) 

] ).


%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ 
		
			get_line_invoice_rule
			
			, get_line_invoice_rule2

			,line
			
			] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Pos`, `.`, tab, `Art`, `.`, `-`, `Nr`, `.`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	`Gesamtnettowert`, `ohne`
	
] ).

%=======================================================================
i_rule_cut( get_line_invoice_rule, [
%=======================================================================
	
	invoice_line1
	
	, invoice_line2
	
	, q10( [ q(0,5,[ peek_fails( invoice_line1 ), line ] ), invoice_line3 ] )
	
	, generic_line( [ [ read_ahead( generic_item( [ dummy, s1 ] ) ) ] ] )
	
	, q(0,10,line)
	
	, invoice_line4
	
	
		
] ).

%=======================================================================
i_rule_cut( get_line_invoice_rule2, [
%=======================================================================
	
	invoice_line5
	
	, invoice_line2
	
	, q10( [ q(0,5,[ peek_fails( invoice_line1, line ) ] ), invoice_line3 ] )

] ).


%=======================================================================
i_line_rule_cut( invoice_line1, [
%=======================================================================
	
	generic_item( [ line_order_line_number, d ] )
	
	, q10( generic_item( [ line_item_for_buyer, d ] ) ), tab

	, generic_item( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1] )
	
	, q10( [ tab, generic_item( [ dummy, s, q10(tab) ] )
	
		, generic_item( [ line_original_order_date, date ] ) 
		
	] )
	
	, newline

] ).

%=======================================================================
i_line_rule_cut( invoice_line5, [
%=======================================================================
	
	generic_item( [ line_order_line_number, d ] )
	
	, q10( generic_item( [ line_item_for_buyer, d ] ) ), tab

	, generic_item( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_unit_amount, d ] )
	
	, generic_item( [ dummy, s1, tab ] )
	
	, generic_item( [ dummy, d, tab ] )
	
	, generic_item( [ line_net_amount, d ] )
	
	, q10( [ q10(tab), `Tag`, tab, generic_item( [ dummy, date ] ) ] )
	
	, newline

] ).

%=======================================================================
i_line_rule_cut( invoice_line2, [
%=======================================================================
	
	generic_item( [ line_descr, s1 ] )
	
	, q10( [ tab, generic_item( [ dummy, s, q10(tab) ] )
	
		, generic_item( [ line_original_order_date, date ] ) 
		
	] )

] ).

%=======================================================================
i_line_rule_cut( invoice_line3, [
%=======================================================================
	
	q0n(anything)
	
	, qn0( or( [
	
		`Ihr`, `Artikel`, `:`, `Nr`, `.`, `Art`, `Materialnummer`, `Artikelnummer`, `Artikelnr`, `BestNr`, `Anr`, `Lieferant`, `HerstellerteileNr` 
		
	] ) )
	
	, line_item( f( [ begin, q(dec,4,10), end ] ) )
	
	, trace( [ `Line Item`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( invoice_line4, [
%=======================================================================
	
	read_ahead( generic_item( [ dummy, s1 ] ) )
	
	, `Nettowert`, `Incl`, `.`, `Rabatte`, tab
	
	, generic_item( [ line_unit_amountx, d ] )
	
	, q0n(anything)
	
	, generic_item( [ line_net_amount, d, newline ] ) 

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






