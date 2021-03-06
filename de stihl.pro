%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE STIHL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_stihl, `9 June 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_suppliers_code_for_buyer

	, get_order_number

	, get_delivery_details

	, get_contacts
	
	, get_shipping_instructions
	
	, get_shipping_instructions_2

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

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

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [
%=======================================================================	  
	  
	  q(0,6,line)
	  
	, or( [ [ generic_horizontal_details( [ [ at_start, qn0(word) ], zip, [ begin, q(dec,5,5), end ]
	
			, check( i_user_check( pc_lookup, zip, SCFB ) ) ] )
			
		]
		
		, [ generic_horizontal_details( [ [ at_start, q0n(word) ], city, wf, check( i_user_check( pc_lookup, city, SCFB ) ) ] ) ]
		
	] )
	
	, suppliers_code_for_buyer( SCFB )
	
] ).

%=======================================================================
i_user_check( pc_lookup, Value_IN, SCFB )
%-----------------------------------------------------------------------
:-
%=======================================================================	  
	  
	string_to_lower( Value_IN, Value_L ),
	
	( pc_to_scfb_lookup( Value_L, _, SCFB_Test, SCFB_Live )
	
		;	pc_to_scfb_lookup( _, Value_L, SCFB_Test, SCFB_Live )		
	),
	
	( grammar_set( test_flag )
		->	SCFB = SCFB_Test
		
		;	SCFB = SCFB_Live
	)
.

pc_to_scfb_lookup( `71307`, `waiblingen`, `10275087`, `10275087` ).
pc_to_scfb_lookup( `54595`, `prüm-weinsheim`, `10275095`, `10275095` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_vertical_details( [ [ `Bestellnummer`, `/`, `Datum` ], order_number, sf, [ `vom`, generic_item( [ invoice_date, date ] ) ] ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Liefertermin`, `:` ], 300, due_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `Auftrags`, `-`, `Nr`, `:` ], shipping_instructions, s1 ] )
	
] ).

%=======================================================================
i_rule( get_shipping_instructions_2, [ 
%=======================================================================

	  q0n(line)

	, generic_vertical_details( [ [ `Technische`, `Rückfragen` ], comments_x, s1 ] )
	
	, check( comments_x = Ship )
	
	, or( [ [ with( shipping_instructions ), append( shipping_instructions( Ship ), `~`, `` ) ]
	
		, shipping_instructions( Ship )
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,15,line)
	  
	, contact_header_line
	
	, get_contact_information
	
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), read_ahead( [ q0n(word), `@` ] ) ], buyer_email, s1 ] )
	, check( buyer_email = Email )
	, delivery_email( Email )

] ).

%=======================================================================
i_line_rule( contact_header_line, [ 
%=======================================================================

	  `Einkäufer`, `/`, `in`, tab
	  
	, ddi_hook(s1), tab
	
	, fax_hook(s1), newline
	
] ).

%=======================================================================
i_line_rule( get_contact_information, [ 
%=======================================================================

	  generic_item_cut( [ buyer_contact, s, [ check( buyer_contact(end) < ddi_hook(start) ), q10( tab ) ] ] )
	  
	, generic_item_cut( [ buyer_ddi_x, s, [ check( buyer_ddi_x(end) < fax_hook(start) ), q10( tab ) ] ] )
	
	, generic_item( [ buyer_fax_x, s1, newline ] )
	
	, check( strip_string2_from_string1( buyer_ddi_x, `-`, DDI ) )
	, check( strip_string2_from_string1( buyer_fax_x, `-`, Fax ) )
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
	, buyer_ddi( DDI )
	, delivery_ddi( DDI )
	
	, buyer_fax( Fax )
	, delivery_fax( Fax )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_header_line, [ `Bitte`, `liefern` ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q0n(line), delivery_header_line

	, delivery_thing( [ delivery_party ] )
	
	, delivery_thing( [ delivery_dept ] )
	
	, q10( delivery_thing( [ delivery_address_line ] ) )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ).


%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [ generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	or( [ [ q0n(line), read_ahead( generic_horizontal_details( [ [ `Gesamtnettowert`, dummy(s1) ], 300, total_net, d, newline ] ) ) ]
	
		, [ total_net( `0` ), set( no_total_validation ) ]
	] )
	  
	, check( total_net = Net )
	, total_invoice( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Seite`, num(d) ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n(

		or( [ 
		
			  line_invoice_rule
			  
			, line_defect_line

			, line

		] )

	), line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Bestellmenge`, tab, `Einheit`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	  or( [ [ `Bitte`, `senden` ]
	
		, `Gesamtnettowert` 
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, q10( generic_line( [ [ `_`, `_`, `_` ] ] ) )

	, line_values_line

	, q10( generic_line( [ [ `_`, `_`, `_` ] ] ) )
	
	, line_item_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )

	, q10( generic_item( [ line_item_for_buyer, s1, tab ] ) )
	
	, generic_item( [ line_descr, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  generic_item_cut( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, w ] )

	, or( [ [ tab, generic_item( [ line_unit_amount, d, [ q10( [ `/`, dum(d) ] ), tab ] ] )
	
			, generic_item( [ line_net_amount, d, newline ] )
		]
		
		, newline
	] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  qn0( 
		or( [ 
			`Ihre`
			, `Materialnummer`
			, `Fa`
			, `Hilti`
			, `Nr`
			, `.`
			, `:`
			, `-`
			, `,`
		] )
	)
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_defect_line, [
%=======================================================================

	qn1( or( [ `Ihre`, `Materialnummer` ] ) )
	
	, trace( [ `Missed item` ] )
	, force_result( `defect` )
	, force_sub_result( `missed_line` )

] ).
