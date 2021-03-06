%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - Kaltepol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( kaltepol, `15 December 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_fixed_variables, check_for_abholung ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_abholung, [
%=======================================================================

	q(0,40,line), generic_horizontal_details( [ or( [ `Abholung`, `Selbstabholung` ] ) ] )
	
	, set( do_not_process )
	, delivery_note_reference( `special_rule` )
	, trace( [ `Abholung rule triggered - Order NOT processed` ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_delivery_details

	, get_order_date

	, get_order_number
	
	, get_due_date
	
	, get_buyer_contact

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_totals
	
	, get_invoice_lines

] ):- not( grammar_set( do_not_process ) ) .


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	  without( buyer_party )
	
	, set(reverse_punctuation_in_numbers)

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

	, sender_name( `Kältepol Kühlanlagen Ges.m.b.H.` )
	
	, suppliers_code_for_buyer( `10027067` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line)
	  
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), `bearbeitet`, `von` ], buyer_contact, s1, newline ] )
	
	, check( buyer_contact = Con )
	, delivery_contact( Con )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ `Lieferanschrift:` ] )
	  
	, generic_horizontal_details( [ nearest( generic_hook(end), 10, 10 ), delivery_party, s1 ] )
		  
	, generic_horizontal_details( [ nearest( generic_hook(end), 10, 10 ), delivery_dept, s1 ] )
	
	, generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), delivery_street, s1 ] )
	
	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [
%=======================================================================

	  q10( `A` ), q10( `-` )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )

	, generic_item( [ delivery_city, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q(0,10,line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), `Bestell`, `Nr`, `.` ], order_number, s1 ] )

] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ [ `Datum`, `:` ], invoice_date, date ] )

] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================
	
	qn0(line), generic_horizontal_details( [ [ at_start, `Liefertermin`, `:`, tab, q0n(word) ], due_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ `Gesamtsumme`, `:` ], 300, total_net, d ] )

	, check( total_net = Net )
	, total_invoice( Net )

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

			, line

		] )

	), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `Pos`, q10( tab ), `Stk`, `.` ] ), header(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `Gesamtsumme`, `:` ] 
	
		, [ dummy(w), check( not( dummy(page) = header(page) ) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ [ q01( generic_line( [ generic_item( [ dummy, s1, newline ] ) ] ) ), line_item_line ], line_item( `Missing` ) ] )
	
	, q10( [ with( invoice, due_date, Date ) 
		, line_original_order_date( Date )
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d, tab ] )
	
	, num(d), newline

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  qn0( or( [ `Ihre`, `Artikelnummer`, `:`, `.`
	  
			, `Art`, `Nr`, `Nummer`, `Artikel`
			
			, `artikelnr`
		
		] )
		
	)
	
	, set( regexp_cross_word_boundaries )
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], check( line_item(end) < 0 ) ] )
	, clear( regexp_cross_word_boundaries )

] ).

