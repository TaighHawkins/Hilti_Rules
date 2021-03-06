%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AT HERBSTHOFER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_herbsthofer, `15 December 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_capture( [ [ `Bestellung`, tab, `:` ], order_number, s1 ] )
	, gen_vert_capture( [ [ `Linz`, `,`, `am` ], invoice_date, date, newline ] )
	
	, get_delivery_details
	
	, gen_capture( [ [ `Liefertermin`, `:` ], due_date, date ] )
	
	, get_invoice_lines
	
	, gen_capture( [ [ `Bestellsumme`, `(`, `excl`, `.`, `MwSt`, `)`, tab, `EUR` ], 200, total_net, d, `EUR` ] )
	, gen_capture( [ [ `Bestellsumme`, `(`, `excl`, `.`, `MwSt`, `)`, tab, `EUR` ], 200, total_invoice, d, `EUR` ] )

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

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, suppliers_code_for_buyer( `10031762` )
	
	, buyer_dept( `16989201` )
	
	, delivery_from_location( `16989201` )

	, sender_name( `Herbsthofer GmbH` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,30,line)
	
	, generic_horizontal_details( [ [ `Frei`, `Baustelle`, `:` ], delivery_party, s1 ] )
	
	, generic_horizontal_details( [ at_start, delivery_street, s1 ] )
	
	, delivery_postcode_city_line
	
	, generic_horizontal_details( [ at_start, delivery_dept, s1 ] )
	
	, generic_horizontal_details( [ at_start, delivery_address_line, s1 ] )

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	  
	, generic_item( [ delivery_city, s1 ] )

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

	, q0n(

		or( [ line_invoice_rule

			, line

		] )

	)
	
	, or( [ line_header_line(1,-420,500), line_end_line(1,-420,500) ] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	q10( [ a(s1), tab ] ), `Pos`, `Artikelnr`, `.`, tab, `Menge`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Bestellsumme`, `(`, `excl`, `.`, `MwSt`
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line(1,-420,500)
	  
	, q10(
	
		read_ahead( [ q(0,6, [ peek_fails( line_header_line(1,-420,500) ), peek_fails( line_end_line(1,-420,500) ), line ] )
		
			, generic_horizontal_details( [ [ `Artikelrabatt`, tab, `-` ], line_percent_discount, d, `%` ] )
			
		] )
		
	)
	
	, read_ahead( [ q(0,10,line), generic_horizontal_details( [ [ `Pos`, `.`, `Summe` ], 300, line_net_amount, d, newline ] ) ] )
	
	, q(10,1
	
		, [ peek_fails( line_header_line(1,-420,500) ), peek_fails( line_end_line(1,-420,500) )
		
			, or( [ line_descr_line(1,-420,60), line ] )
		
		]
		
	)
	
	, clear( descr )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  line_order_line_number(d)
	  
	, generic_item( [ line_item, s1, tab ] )
	
	, line_quantity(d)
	
	, line_quantity_uom_code(w), tab

	, generic_item( [ line_unit_amount, d, newline ] )
	
	, with( invoice, due_date, Date ), line_original_order_date(Date)

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	  or( [
	
		[ test( descr ), append( line_descr(s1), ` `, `` ) ]
		
		, [ generic_item( [ line_descr, s1 ] ), set( descr ) ]
		
	] )

] ).