%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE GEBHARDT FOEDERTECHNIK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_gebhardt_foedertechnik, `26 February 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_fixed_variables, check_for_enthalt ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_enthalt, [ 
%=======================================================================

	q0n( line )
	, generic_line( 1, -500, -430, [ `t` ] )
	, q0n(line)
	, generic_line( 1, -500, -430, [ `l` ] )
	, q0n(line)
	, generic_line( 1, -500, -430, [ `ä` ] )
	, q0n(line)
	, generic_line( 1, -500, -430, [ `h` ] )
	, q0n(line)
	, generic_line( 1, -500, -430, [ `t` ] )
	, q0n(line)
	, generic_line( 1, -500, -430, [ `n` ] )
	, q0n(line)
	, generic_line( 1, -500, -430, [ `e` ] )
	
	, delivery_note_reference( `special_rule` )
	, set( do_not_process )
	, trace( [ `Enthalt rule TRIGGERED - Order NOT being processed` ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_order_number
	  
	, get_due_date

	, get_delivery_details

	, get_contacts

	, get_faxes
	
	, get_ddis
	
	, get_emails
	
	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

	, get_invoice_lines

] ):- not( grammar_set( do_not_process ) ).

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
		[ test(test_flag), suppliers_code_for_buyer( `10135852` ) ]    %TEST
	    , suppliers_code_for_buyer( `10135852` )                      %PROD
	] )

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
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_vertical_details( [ [ `Bestellnummer`, `/`, `Datum` ], order_number, sf, [ `/`, generic_item( [ invoice_date, date ] ) ] ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q(0,30,[ line, peek_fails( line_header_line ) ] )
	  
	, generic_horizontal_details( [ [ `Liefertermin`, `:` ], 500, due_date, date ] )
	
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
	  
	, generic_vertical_details( [ [ `Ansprechpartner`, `/`, `in`, newline ], buyer_contact, s1 ] )
	
	, check( buyer_contact = Con )
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	  q(0,25,line), generic_vertical_details( [ `Telefon`, buyer_ddi_x, s1 ] )

	, check( strip_string2_from_string1( buyer_ddi_x, `/-`, DDI_2 ) )

	, buyer_ddi( DDI_2 )
	, delivery_ddi( DDI_2 )

] ).

%=======================================================================
i_rule( get_faxes, [ 
%=======================================================================

	  q(0,25,line), generic_vertical_details( [ [ `Fax` ], buyer_fax_x, s1 ] )

	, check( strip_string2_from_string1( buyer_fax_x, `/-`, Fax_2 ) )
	
	, buyer_fax( Fax_2 )
	, delivery_fax( Fax_2 )

] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  q(0,25,line), generic_vertical_details( [ [ `E`, `-`, `Mail` ], buyer_email, s1 ] )
	
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
	  
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), read_ahead( or( [ `Komission`, `Kommission` ] ) ) ], customer_comments, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q0n(line), generic_horizontal_details( [ [ `Bitte`, `liefern`, `Sie` ] ] )
	  
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )

	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_party, s1 ] )

	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )

	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] )

	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	
	, delivery_street_and_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_street_and_city_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
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

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Nettobetrag`, dummy(s1) ], 300, total_net, d, newline ] ) )
	  
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
i_line_rule_cut( line_end_section_line, [ `Geschäftsführende` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, qn0(

		or( [ 
		
			  line_invoice_rule

			, line

		] )

	)

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Bezeichnung`, tab, `EUR`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_underscore_line, [ `_`, `_`, `_` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Nettobetrag`, `zzgl` ]

	] )
	
] ).


%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, q0n( or( [ line_underscore_line, line_descr_line( 1, -260, 50 ) ] ) )
	
	, line_item_line
	
	, or( [ [ with( invoice, due_date, Date ), line_original_order_date( Date ) ]
	
		, [ q0n( line_descr_line( 1, -240, 50 ) )
			, generic_horizontal_details( [ [ at_start, `Liefertermin`, `:` ], 200, line_original_order_date, date ] )
		]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item( [ line_quantity_uom_code, w, q10( tab ) ] )
	
	, q10( generic_item( [ line_item_for_buyer, s1, tab ] ) )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ pro, s1, tab ] )

	, q10( generic_item_cut( [ line_percent_discount, d, [ `-`, `%`, tab ] ] ) )

	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  qn0(
		or( [ 
			`Ihre`
			, `Materialnummer`
			, `Hilti`
			, `Art`
			, `Nr`
			, `-`
			, `.`
			, `:`
		] )
	)

	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
] ).
