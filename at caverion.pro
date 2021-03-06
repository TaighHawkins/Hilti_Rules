%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AT CAVERION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_caverion, `20 November 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( rules_for_everything, [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_bcfb

	, get_delivery_details

	, get_buyer_contact

	, get_buyer_ddi
	
	, get_buyer_fax

	, get_buyer_email

	, get_order_date

	, get_order_number

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, [ qn0(line), invoice_total_line]

] ).

%		Because Sections go weird in labelled lists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_fixed_variables, get_due_date, get_invoice_lines ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( reason_to_not_process, [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  delivery_note_reference( `Abholung` )
	  
	, chain_the_terms

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROCESSING CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( rules_for_everything, [ peek_fails( reason_to_not_process ) ] ).
%=======================================================================
i_rule( reason_to_not_process, [ abholung_rule ] ).
%=======================================================================
i_rule( abholung_rule, [ q0n(line), delivery_header_line, q(0,30,line), line_to_not_process ] ).
%=======================================================================
i_line_rule( line_to_not_process, [ q0n(anything), `Abholung`, trace( [ `No processing!` ] ) ] ).
%=======================================================================

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

	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SCFB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( line_on_right, [ dummy(s1), check( dummy(start) > 0 ) ] ).
%=======================================================================
i_rule( get_bcfb, [ 
%=======================================================================

	  without( buyers_code_for_buyer )
	  
	, q(0,20,line), generic_horizontal_details( [ read_ahead( [ `Rechnungsadresse`, `:` ] ), dummy, s1 ] )
	
	, q(2,6,line), generic_horizontal_details( [ buyers_code_for_buyer, [ begin, q(dec,4,5), end ] ] )
	
	, check( buyers_code_for_buyer(end) < 0 )
	
	, prepend( buyers_code_for_buyer( `ATCAVE` ), ``, `` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  without( buyer_contact )
	  
	, q(0,15,line), generic_horizontal_details( [ [ `Einkauf`, `:` ], buyer_contact, s1, newline ] )

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  without( buyer_ddi )
	  
	, q(0,15,line), generic_horizontal_details( [ [ `Tel`, `:` ], ddi_x, s1, newline ] )
	
	, check( ddi_x = DDI_x )
	
	, check( string_string_replace( DDI_x, `+43 (0)`, `0`, DDI ) )
	
	, buyer_ddi( DDI )

] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	  without( buyer_fax )
	  
	, q(0,15,line), generic_horizontal_details( [ [ `Fax`, `:` ], fax_x, s1, newline ] )
	
	, check( fax_x = Fax_x )
	
	, check( string_string_replace( Fax_x, `+43 (0)`, `0`, Fax ) )
	
	, buyer_fax( Fax )

] ).

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `e`, `-`, `mail`, `:` ], buyer_email, s1, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  without( delivery_party )
	  
	, q(0,20,line), delivery_header_line
	
	, delivery_thing( [ delivery_party ] )
	
	, q(2,0, delivery_address_line_line )
	
	, q01( delivery_thing( [ delivery_line_x ] ) )
	
	, q( 2, 2, or( [ [ without( delivery_street )
		
				, delivery_thing( [ delivery_street ] )
				
			]
			
			, [ without( delivery_postcode )
		
				, delivery_thing( [ delivery_postcode, delivery_city ] )
				
			]
		
		] )
	
	)
	
	, q10( [ q(2,0, line_on_left )
	
		, delivery_address_line_line
		
	] )
	
] ).

%=======================================================================
i_line_rule( line_on_left, [ dummy(s1), newline, check( dummy(end) < 0 ) ] ).
%=======================================================================
i_line_rule( delivery_header_line, [ q0n(anything), read_ahead( [ `Bitte`, `liefern` ] ), delivery_hook(s1) ] ).
%=======================================================================
i_line_rule( delivery_address_line_line, [
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	  
	, q10( [ or( [ `Kontakt`, `Telefon`, `Tel`, `Mobile` ] )
	
		, `:`, q10( tab )
			
	] )
	
	, or( [ [ test( got_name_2 ), generic_item( [ delivery_address_line, s1 ] ) ]
	
		, [ peek_fails( test( got_name_2 ) ), generic_item( [ delivery_dept, s1 ] ), set( got_name_2 ) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [ nearest( delivery_hook(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Postcode, Variable ] ), [
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	  
	, generic_item( [ Postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ Variable, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  without( order_number )
	  
	, q(0,10,line), generic_vertical_details( [ [ `Bestellnummer` ], `Bestellnummer`, order_number, s1, newline ] )

] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  without( invoice_date )
	  
	, q(0,10,line), generic_horizontal_details( [ [ `Bestellung`, q10( tab ) ], invoice_date, date ] )

] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  without( due_date )
	  
	, q(0,20,line), generic_horizontal_details( [ [ `Liefertermin`, `:` ], due_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	  without( total_invoice )
	
	, q0n(word), `ohne`, `Umsatzsteuer`, `EUR`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ qn0(anything), `Seite`, num(d), `/` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line
	 
	, peek_fails( test( completed_lines ) )
	 
	, set( completed_lines )

	, qn0( [ peek_fails(line_end_line)

		, or( [ line_invoice_rule
		
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Best`, `-`, `Pos`, `.`, tab, `Bezeichnung`] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ q0n(word), `ohne`, `Imsatzdteuer` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_values_line
	
	, line_descr_line
	
	, with( invoice, due_date, DD )
	
	, line_original_order_date( DD )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )
	
	, generic_item_cut( [ line_item, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item_cut( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_unit_amount_x, d, q10( tab ) ] )

	, q10( generic_item( [ disc, s1, tab ] ) )

	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [ generic_item( [ line_descr, s1, newline ] ) ] ).
%=======================================================================