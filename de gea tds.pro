%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE GEA TDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_gea_tds, `30 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number
	
	, get_due_date

	, get_delivery_details

	, get_contact_information

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

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, or( [ 
		[ test(test_flag), suppliers_code_for_buyer( `10293325` ) ]    %TEST
	    , suppliers_code_for_buyer( `10297294` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `GEA TDS GmbH` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_vertical_details( [ [ `Bestellnummer`, `/` ], order_number, sf, [ `/`, generic_item( [ invoice_date, date ] ) ] ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Liefertermin` ], due_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_information, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Ansprechpartner`, `/`, `Tel` ] ] )
	
	, contact_information_line
	
	, generic_horizontal_details( [ read_ahead( [ q0n(word), `@` ] ), buyer_email, s1 ] )
	, check( buyer_email = Email )
	, delivery_email( Email )

] ).

%=======================================================================
i_line_rule( contact_information_line, [ 
%=======================================================================

	  generic_item_cut( [ buyer_contact, sf, `/` ] )
	, check( buyer_contact = Con )
	, delivery_contact( Con )
	
	, generic_item( [ buyer_ddi_x, sf, `/` ] )
	, check( strip_string2_from_string1( buyer_ddi_x, `-`, DDI ) )
	, buyer_ddi( DDI )
	, delivery_ddi( DDI )
	
	, generic_item( [ buyer_fax_x, s1 ] )
	, check( strip_string2_from_string1( buyer_fax_x, `-`, Fax ) )
	, buyer_fax( Fax )
	, delivery_fax( Fax )

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
	, check( customer_comments = Com )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================
	  
	  q0n(line), generic_horizontal_details( [ [ at_start, `Bitte`, `liefern` ] ] )

	, delivery_thing( [ delivery_party ] )

	, q10( delivery_thing( [ delivery_dept ] ) )

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

	, generic_item( [ Var, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_and_city_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 50 )
	  
	, q10( `DE` ), generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
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

	  or( [ [ q0n(line), read_ahead( generic_horizontal_details( [ [ `Gesamtwert`, qn0(anything), tab ], total_net, d ] ) ) ]
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
i_line_rule_cut( line_end_section_line, [ `GEA`, `TDS`, `GmbH`, newline ] ).
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
i_line_rule_cut( line_header_line, [ `Bezeichnung`, tab, `Preis` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `*`, `*`, `*` ], `Gesamtwert` ] ) ] ).
%=======================================================================
i_line_rule_cut( line_defect_line, [ dum(f([ begin, q(dec,5,5), end ])), force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] )
	
	, or( [ [ q(0,15,line), line_item_line ]
		, line_item( `Missing` )
	] )
	
	, q(0,15,line)
	
	, or( [ line_net_line
	
		, peek_ahead( 
			or( [ generic_line( [ generic_item( [ no, [ begin, q(dec,5,5), end ], peek_fails( newline ) ] ) ] )
				, line_end_line
			] )
		)
	] )
	
	, q10( [ with( invoice, due_date, Date )
		, line_original_order_date( Date )
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, [ begin, q(dec,5,5), end ], q10( tab ) ] )
	
	, generic_item( [ dummy_item, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item( [ line_quantity_uom_code, w, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [ 
%=======================================================================

	  qn0(
		or( [
			`Ihre`
			, `Materialnummer`
			, `:`
		] )
	)
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], [ q10( word ), newline ] ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_net_line, [ 
%=======================================================================

	  or( [ `Nettowert`

		, `Nettopreis`
	
	] )

	, qn0(anything), tab
	
	, generic_item( [ line_net_amount, d, newline ] )
	
] ).
