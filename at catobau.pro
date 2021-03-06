%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CATOBAU
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_catobau, `30 October 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_details

	, get_customer_comments
	
	, get_buyer_contact

	, get_order_date

	, get_order_number

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, [ qn0(line), invoice_total_line]
	
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

	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `18674331` ) ]
		, suppliers_code_for_buyer( `18674331` )
	] )
	
	, sender_name( `Catobau` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Besteller`, `:` ], 400, buyer_contact, s1, newline ] )
	
	, check( buyer_contact = Con )	
	, delivery_contact( Con )
	
	, generic_line( [ generic_item( [ buyer_ddi, s1, newline ] ) ] )
	
	, q(0,2,line), generic_horizontal_details( [ [ at_start, read_ahead( [ q0n(word), `@` ] ) ], buyer_email, s1 ] )
	
	, check( buyer_ddi = DDI )
	, delivery_ddi( DDI )
	
	, check( buyer_email = Email )
	, delivery_email( Email )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ `Lieferadresse` ] )
	  
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_party, s1 ] )
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] )
	
	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	  
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

	q(0,10,line), generic_horizontal_details( [ [ at_start, `Auftragsnummer`, `:` ], 400, order_number, s1 ] )

] ).


%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q(0,10,line), generic_horizontal_details( [ invoice_date, date ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ [ at_start, `Kostenstelle` ], 400, customer_comments, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	  `Auftragssumme`, `(`, `Netto`, `)`, `:`, q10( tab )

	, read_ahead(total_invoice(d))

	, total_net(d)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ 
		
			 line_continuation_line
			
			, line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `Preis`, newline ] ), header(w) ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ with( line_descr ), append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Auftragssumme` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_descr, s, q10( tab ) ] )

	, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], tab ] )

	, generic_item_cut( [ line_original_order_date, date, tab ] )
	
	, generic_item_cut( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, [ `EUR`, q10( tab ) ] ] )

	, generic_item( [ line_net_amount, d, [ `EUR`, newline ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  qn0( or( [ `Ihre`, `Materialnummer`
	  
			, `Art`, `.`, `Nr`
		
		] )
		
	)
	
	, set( regexp_cross_word_boundaries )
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	, clear( regexp_cross_word_boundaries )

] ).

