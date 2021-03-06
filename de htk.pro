%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE HTK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_htk, `29 June 2015` ).

i_date_format( _ ).
i_format_postcode( X,X ).

i_pdf_paramater( x_tolerance_100, 100 ).

i_user_field( invoice, buyer_ddiy, `Buyer DDI` ).
i_user_field( invoice, buyer_faxy, `Buyer DDI` ).
i_user_field( invoice, buyers_code_for_buyery, `Buyers code for buyer` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, gen_capture( [ [ `Bestell`, `-`, `Nr`, `.`, `:` ], order_number, s1, newline ] )
	, gen_capture( [ [ `Lieferdatum`,`:` ], delivery_date, date, tab ] )
	, gen_capture( [ [ read_ahead( [ `Projekt`, `-`, `Nr`, `.`, `:` ] ) ], customer_comments, s1, newline ] )
	, gen_capture( [ [ `Sachbearbeiter`, `:` ], buyer_dept, s1, prepend( buyer_dept(`DEHTK`), ``, `` ) ] )
	
	, get_invoice_date 
	
	, get_delivery_location
	
	, fix_address_line
	
	, get_customer_comments
	
	, set(reverse_punctuation_in_numbers)
	
	, get_invoice_lines
	
	, gen_capture( [ [ `Gesamtpreis`, `netto`, tab ], total_net, d, [ `€`, newline ] ] )
	, gen_capture( [ [ `Mehrwertsteuer`, a(d), `%`, tab ], total_vat, d, [ `€`, newline ] ] )
	, gen_capture( [ [ `Gesamtpreis`, `brutto`, tab ], total_invoice, d, [ `€`, newline ] ] )
	
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

%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%

	, suppliers_code_for_buyer( `10284079` )
	
	, sender_name( `Heidelberger Beton GmbH` )
	
	, set( no_pc_cleanup )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================
	
	  q0n(line)
	
	, get_invoice_date_line
	
] ).

%=======================================================================
i_line_rule( get_invoice_date_line, [ 
%=======================================================================
	
	  q0n(anything), generic_item( [ invoice_date, date, newline ] )
	
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

	, customer_header_line
	
	, trace( [ `Here` ] )
	
	, customer_comment_line1
	
	, trace( [ `Here1` ] )
	
	, customer_comment_line2
	
	, trace( [ `Here2` ] )
	
	, customer_comment_line3
	

] ).

%=======================================================================
i_line_rule( customer_header_line, [ 
%=======================================================================

	  q0n(anything)
	
	, read_ahead( [ `Kommission`, `:` ] )
	
	, header1(s1), newline 
	
] ).

%=======================================================================
i_line_rule( customer_comment_line1, [ 
%=======================================================================

	  nearest_word( header1(start), 20,20 ), append( customer_comments(s1), `~Komm:`, `` ), newline
	
] ).

%=======================================================================
i_line_rule( customer_comment_line2, [ 
%=======================================================================

	  nearest_word( header1(start), 20,20 ), append( customer_comments(s1), `~`, `` ), newline
	
] ).

%=======================================================================
i_line_rule( customer_comment_line3, [ 
%=======================================================================

	  nearest_word( header1(start), 20,20 ), append( customer_comments(s1), `~`, `` ), newline
	
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
	
	, q10( delivery_dept_line )
	
	, or( [

		test( htk )
		
		, [ delivery_street_line
			, delivery_postcode_line
			, dummy_line
			, q10( shipping_instruction_line )
		]
		
	] )

] ).

%=======================================================================
i_line_rule( delivery_header_line, [
%=======================================================================

	  q0n(anything)
	
	, read_ahead( [ `Lieferadresse`, `:` ] )
	
	, header(s1), tab
	
] ).

%=======================================================================
i_line_rule( delivery_dept_line, [
%=======================================================================

	  nearest_word( header(start), 20,20 )
	
	, or( [
	
		[ `HTK`, `GmbH`, `Haustechnik`,  delivery_note_number( `10284079` ), trace( [ `HTK` ] ), set( htk ) ]
	
		, [ delivery_party( `HTK GmbH Haustechnik` ), generic_item( [ delivery_dept, s1 ] ) ]
		
	] ), tab
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	  nearest_word( header(start), 20,20 ), generic_item( [ delivery_street, s1, gen_eof ] )
	
] ).


%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	  nearest_word( header(start), 20,20 )
	
	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	
	, generic_item( [ delivery_city, s1 ] ), gen_eof
	
] ).

%=======================================================================
i_line_rule( dummy_line, [ 
%=======================================================================

	  nearest_word( header(start), 20,20 ), generic_item( [ dummy, s1, gen_eof ] )
	
] ).

%=======================================================================
i_line_rule( shipping_instruction_line, [ 
%=======================================================================

	  nearest_word( header(start), 20,20 )
	
	, read_ahead( append( customer_comments(s1), `~`, `` ) )
	
	, generic_item( [ shipping_instructions, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [
		
			get_line_invoice_rule

			,line
			
		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	  `lfd`, `.`, `nr`, tab, `art`, `.`, `-`, `nr`, `.`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	  `Gesamtpreis`, `netto`

] ).

%=======================================================================
i_rule_cut( get_line_invoice_rule, [
%=======================================================================
	
	  invoice_line1
	
	, invoice_line2 
	
] ).

%=======================================================================
i_line_rule_cut( invoice_line1, [
%=======================================================================
	
	  generic_item( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_item, w, [ qn0( append( line_item(w), ``, `` ) ), tab ] ] ) % removes spaces

	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity, d ] )
	
	, generic_item( [ dummy, s, tab ] )
	
	, generic_item( [ dummy, s1 ] )
	
	, q10( [ tab, generic_item( [ line_net_amount, d, `€` ] ) ] )
	
	, newline
	
	, with(invoice, delivery_date, Date )
	
	, line_original_order_date( Date ) 
	
	, line_vat_rate(`19`)	

] ).

%=======================================================================
i_line_rule_cut( invoice_line2, [
%=======================================================================

	  append( line_descr(s1), ` `, `` )
	
	, tab
	
	, generic_item( [ dummy, s1, tab ] )
	
	, generic_item( [ dummy, s1 ] )
	
	, q10( [ tab, generic_item( [ line_net_amount, d, `€` ] ) ] )
	
	, newline
	
] ).