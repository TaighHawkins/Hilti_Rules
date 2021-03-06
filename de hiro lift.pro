%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HIRO LIFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hiro_lift, `24 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number
	, get_order_date
	
	, check_delivery_existance
	, get_delivery_details

	, get_contacts
	, get_faxes
	, get_ddis
	
	, get_customer_comments

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
	
	, suppliers_code_for_buyer( `10335883` )
	
	, sender_name( `Hiro Lift` )
	
	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Bestellung`, `NR`, `.` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Datum`, `:` ], 250, invoice_date, date ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,30,line)
	  
	, generic_horizontal_details( [ [ `Ansprechpartner`, `:` ], 200, buyer_contact, s1 ] )
	
	, check( buyer_contact = Con )
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Telefon` ], 200, buyer_ddi_x, s1 ] )
	  
	, check( string_string_replace( buyer_ddi_x, `+49`, `0`, DDI ) )
	, check( strip_string2_from_string1( DDI, `- `, DDI_2 ) )

	, buyer_ddi( DDI_2 )	
	, delivery_ddi( DDI_2 )

] ).

%=======================================================================
i_rule( get_faxes, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Telefax` ], 200, buyer_fax_x, s1 ] )
	  
	, check( string_string_replace( buyer_fax_x, `+49`, `0`, Fax ) )	
	, check( strip_string2_from_string1( Fax, `-`, Fax_2 ) )
	
	, buyer_fax( Fax_2 )	
	, delivery_fax( Fax_2 )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_delivery_existance, [ q0n(line), generic_horizontal_details( [ `Lieferadresse` ] ), set( address_exists ) ] ).
%=======================================================================


%=======================================================================
i_line_rule( delivery_header_line, [ `Abw`, `.`, `Lieferadresse`, `:`, tab, generic_item( [ delivery_dept, s1 ] ) ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  or( [ [ test( address_exists )
			, delivery_party( `Hiro Lift` )
			, q0n(line), delivery_header_line

			, q(0,2, delivery_thing( [ delivery_address_line ] ) )
	
			, delivery_thing( [ delivery_street ] )

			, delivery_postcode_and_city_line
		]
		
		, [ peek_fails( test( address_exists ) )
			, delivery_note_number( `10335883` )
		]
	] )
	
] ).


%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [ generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

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
	
	, generic_horizontal_details( [ [ gen_beof, read_ahead( or( [ `Anlagennummer`, `Kostenstelle` ] ) ), retab( [ 500 ] ) ], customer_comments, s1 ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line), read_ahead( generic_horizontal_details( [ [ `Gesamt`, `Netto` ], 500, total_net, d, newline ] ) )
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

	, qn0( [ peek_fails( line_end_line )

		  , or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Artikel`, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ `Gesamt`
		
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
	, trace( [ `End line` ] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line

	, q0n( line_continuation_line )
	
	, line_item_line
	
	, q0n( line_continuation_line )
	
	, generic_line( [ [ q0n(word), `Leistungsdatum`, `:`, generic_item( [ line_original_order_date, date ] ) ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d ] )
	
	, generic_item_cut( [ line_quantity_uom_code, w, tab ] )

	, generic_item_cut( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  or( [ [ `Hersteller`, `-`, `Artikelnr`, `:` ] ] )

	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

] ).
