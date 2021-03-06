%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE DRESDNER HUEHLANLAGEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_dresdner_kuehlanlagen, `29 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number
	
	, get_order_date

	, get_delivery_details

	, get_contacts

	, get_ddis
	
	, get_faxes
	
	, get_emails
	
	, get_customer_comments
	
	, get_shipping_instructions
	
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

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, or( [ 
		[ test(test_flag), suppliers_code_for_buyer( `10293325` ) ]    %TEST
	    , suppliers_code_for_buyer( `10392746` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Dresdner Kühlanlagenbau GmbH` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Bestellnummer`, `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Datum`, `:` ], 200, invoice_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Sachbearbeiter`, `:` ], 250, buyer_contact_x, s1 ] )
	
	, check( strip_string2_from_string1( buyer_contact_x, `,`, Con ) )
	, buyer_contact( Con )
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Telefon`, `:` ], 200, buyer_ddi_x, s1 ] )

	, check( strip_string2_from_string1( buyer_ddi_x, ` `, DDI_2 ) )
	, check( string_string_replace( DDI_2, `+49`, `0`, DDI ) )

	, buyer_ddi( DDI )
	, delivery_ddi( DDI )

] ).

%=======================================================================
i_rule( get_faxes, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Telefax`, `:` ], 200, buyer_fax_x, s1 ] )

	, check( strip_string2_from_string1( buyer_fax_x, ` `, Fax_2 ) )
	, check( string_string_replace( Fax_2, `+49`, `0`, Fax ) )

	, buyer_fax( Fax )
	, delivery_fax( Fax )

] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `E`, `-`, `Mail`, `:` ], 200, buyer_email, s1 ] )
	
	, check( buyer_email = Email )
	, delivery_email( Email )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), read_ahead( `Projekt` ), retab( [ 500 ] ) ], customer_comments, s1 ] )

] ).

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ at_start, `Lieferanschrift` ] ] )
	, q(0,10,line)
	
	, read_ahead( generic_horizontal_details( [ nearest( generic_hook(start), 10, 40 ), anchor, w, check( anchor(font) = generic_hook(font) ) ] ) )
	
	, peek_ahead( gen_count_lines( [ generic_line( [ `Nachfolgende` ] ), Count ] ) )
	
	, generic_line( Count, [ generic_item( [ shipping_instructions, s1 ] ) ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ delivery_party( `Dresdner Kühlanlagenbau GmbH` ),
%=======================================================================
	  
	  q0n(line), generic_horizontal_details( [ [ at_start, `Lieferanschrift` ] ] )

	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 50 ] ) )

	, q10( generic_line( [ [ `Dresdner`, `Kühlanlagenbau` ] ] ) )

	, delivery_thing( [ delivery_dept ] )

	, q(0,2, delivery_thing( [ delivery_address_line ] ) )

	, delivery_thing( [ delivery_street ] )

	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 50 ] ) )
	
	, delivery_street_and_city_line
	
] ).

%=======================================================================
i_rule_cut( delivery_thing( [ Var ] ), [ 
%=======================================================================
	
	qn0( gen_line_nothing_here( [ generic_hook(start), 10, 50 ] ) )
	
	, delivery_thing_line( [ Var ] )
	
] ).

%=======================================================================
i_line_rule( delivery_thing_line( [ Var ] ), [
%=======================================================================

	nearest( generic_hook(start), 10, 50 )
	
	, peek_fails( [ `Dresdner`, `Kühlanlagenbau` ] )
	
	, generic_item( [ Var, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_and_city_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 50 )
	  
	, q10( or( [ `DE`, `Deu`, `D` ] ) ), generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ tab, `Nettobestellwert` ], 200, total_net, d ] ) )
	  
	, check( total_net = Net )
	, total_invoice( Net )

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

	, q0n(

		or( [ 
		
			  line_invoice_rule

			, line

		] )

	), line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Artikel`, `-`, `Nr`, `.`, q10( tab ), `Bezeichnung` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Wir`, `bitten`, `um` ]
	
		, [ `Zahlungsbedingungen` ]
		
		, [ `Übertrag`, newline ]

	] )
	
] ).


%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, q01( line )
	
	, line_descr_and_date_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item( [ line_quantity_uom_code, w, q10( tab ) ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_and_date_line, [ 
%=======================================================================

	  generic_item( [ line_descr, s1, tab ] )
	  
	, `Liefertermin`, q10( generic_item( [ line_original_order_date, date, newline ] ) )
	
] ).
