%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - COFELY FABRICOM SA/NV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( be_cofely_fabricom, `12 August 2015` ).

i_date_format( _ ).
i_format_postcode( X,X ).

i_pdf_paramater( x_tolerance_100, 100 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, get_invoice_date
	
	, get_order_number_line
	
	, get_contact_info
	
	, get_header_date
	
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

	buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `BE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, sender_name( `Cofely Fabricom sa/nv` )
	
	, set(no_scfb)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HEADER DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ q0n(line), invoice_date_line ] ).
%=======================================================================
i_line_rule( invoice_date_line, [ 
%=======================================================================
	
	or( [ 
	
		[ `Datum`,`:` ]
		
		, [ `Date`,`:` ]
		
	] )
	
	, generic_item( [ invoice_date, date, newline ] )
	
] ).

%=======================================================================
i_rule( get_order_number_line, [ q0n(line), order_number_line ] ).
%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	or( [ 
	
		[ `Bestelling`, `nr` ]
		
		, [ `Commande`, `n°` ]
		
	] )
	
	, generic_item( [ order_number, s, `/` ] )
	
	, q0n(word)
	
	, or( [
	
		[ `BTW`, `nr`, `.` ]
		
		, [ `TVA`, `n°` ]
		
	] )
	
	, generic_item( [ buyers_code_for_buyer, s1, newline ] )
	
] ).

%=======================================================================
i_rule( get_contact_info, [ 
%=======================================================================
	
	q0n(line)

	, contact_info_line 
	
	, q(0,4,line)
	
	, email_line
	
] ).

%=======================================================================
i_line_rule( contact_info_line, [ 
%=======================================================================

	q0n(anything)
	
	, or( [ 
	
		[ `Aanvrager` ]
		
		, [ `Demandeur`] 
		
	] ), q10(tab)
	
	, generic_item( [ delivery_contact_x, s1, newline ] )
	, check( sys_string_split( delivery_contact_x, ` `, ReversedContactList ) )
	, check( sys_reverse( ReversedContactList, ContactList ) )
	, check( wordcat( ContactList, CONT ) )
	
	, delivery_contact( CONT )
	, buyer_contact( CONT )

] ) .

%=======================================================================
i_line_rule( email_line, [ 
%=======================================================================

	q0n(anything), tab
	
	, generic_item( [ delivery_email, s, `@` ] ), append(delivery_email(s1), `@`, `` )
	
	, with(invoice, delivery_email, EMAIL)
	
	, buyer_email(EMAIL)
	
	, newline

] ).

%=======================================================================
i_rule( get_header_date, [ q0n(line), header_date_line ] ).
%=======================================================================
i_line_rule( header_date_line, [ 
%=======================================================================

	or( [ 
	
		[ `Date`, `de`, `livraison` ]
		
		, [ `Leveringstermijn` ]
		
	] ), tab
	
	, generic_item( [ delivery_date, date, newline ] )

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
	
	, delivery_party_line
	
	, q(0,4,line)
	
	, delivery_street_line
	
	, delivery_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	or( [ 
	
		[ `Adresse`, `de`, `livraison` ]
		
		, [ `Leveradres` ] 
		
	] )
	
] ).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	generic_item( [ delivery_party, s1 ] )
	
	, q10( [ tab, append(line_descr(s1),` `,``) ] )
	
	, newline
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	generic_item( [ delivery_street, s1, newline ] )
	
] ).


%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================
	
	delivery_postcode( f( [ begin, q(dec,4,5), end ] ) )
	
	, generic_item( [ delivery_city, s1, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_section_control( get_invoice_lines, first_one_only ).

i_section_end( get_invoice_lines, line_end_section_line ).

i_line_rule_cut( line_end_section_line, [

	`Cofely`, `Fabricom`, `sa`, `/`, `nv`

] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ 
		
			line_invoice_rule

			, line
			
		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	or( [
	
		[ `Poste`, tab, `Article`, tab, header(w) ]
		
		, [ `Pos`, `.`, tab, `Artikel`, tab, header(w) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	or( [
	
		[ `Val`, `.`, `nette`, `totale` ]
		
		, [ `Totale`, `nettowaarde` ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================
	
	invoice_line
	
	, q10( [ q0n(line), test(need_item), invoice_line1, peek_fails( or( [ invoice_line, line_end_line ] ) ) ] )
	
	, clear(need_item)

] ).

%=======================================================================
i_line_rule_cut( invoice_line1, [
%=======================================================================
	
	q10(`UW`), `Ref`, `:`
	
	, generic_item( [ line_itemx, s1,  gen_eof ] ) 
	
	, check( strip_string2_from_string1( line_itemx, ` "`, Item ) )
	
	, line_item(Item)

] ).

%=======================================================================
i_line_rule_cut( invoice_line, [
%=======================================================================
	
	generic_item( [ line_order_line_number, d, q10(tab) ] )
	
	, or( [
	
		[ 	
		
			generic_item( [ line_itemx, s1, tab ] )
		
			, check( strip_string2_from_string1( line_itemx, ` `, Item ) )
	
			, line_item(Item) 
			
		]
		
		, [ set(need_item) ]
		
	] )
	
	

	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_codex, s1, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, with(invoice, delivery_date, DATE)
	, line_original_order_date(DATE)
	
] ).

%=======================================================================
i_rule_cut( get_invoice_totals, [ q0n(line), invoice_totals ] ).
%=======================================================================
i_line_rule_cut( invoice_totals, [
%=======================================================================

	or( [ 

		[ `Totale`, `nettowaarde`, `exclusief`, `BTW`, `EUR` ]
		
		, [ `Val`, `.`, `nette`, `totale`, `hors`, `TVA`, `EUR` ]
		
	] ), tab
	
	, generic_item( [ total_net, d, newline ] )
	, with( invoice, total_net, NET ) 
	, total_invoice(NET)

] ).






