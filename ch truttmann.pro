%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CH TRUTTMANN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ch_truttmann, `15 January 2015` ).
i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_fixed_variables, check_for_bemerkungen ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FOR BEMERKUNGEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_bemerkungen, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Bemerkungen`, `:` ], some, s1 ] )
	  
	, delivery_note_reference( `special_rule` )
	, set( do_not_process )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_delivery_address
	
	, get_delivery_address_line

	, get_buyer_contact
	
	, get_order_number
	
	, get_order_date
	
	, get_due_date
	
	, get_customer_comments
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ):- not( grammar_set( do_not_process ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10527103` ) ]    %TEST
	    , suppliers_code_for_buyer( `10527103` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, sender_name( `Truttmann AG` )
	, delivery_dept( `Truttmann AG` )
	
	, total_net( `0` )
	, total_invoice( `0` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q0n(line), delivery_header_line
	  
	, delivery_thing_line( [ delivery_party ] )
	
	, q10( delivery_thing_line( [ delivery_address_line ] ) )

	, delivery_thing_line( [ delivery_street ] )
	
	, delivery_city_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ `lieferadresse`, `:` ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [ generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_city_postcode_line, [ 
%=======================================================================
	
	  delivery_postcode(f( [ begin, q(dec,4,5), end ] ) )
	  
	, delivery_city(s1)
	
	, trace( [ `other delivery stuffs`, delivery_postcode, delivery_city ] )
 
] ).

%=======================================================================
i_rule( get_delivery_address_line, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Referenz`, `vor`, `Ort`, `:` ], delivery_address_line, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER & DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Bestellung` ], order_number, sf, or( [ tab, `(` ] ) ] )
	  
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ invoice_date, date, newline ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Lieferdatum`, `:` ], due_date, date ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Unsere`, `Referenz`, `:` ], buyer_contact, s1 ] )
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Objekt`, `:` ], 200, customer_comments, s1 ] )
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, trace( [ `found header` ] )

	, q0n( [

		or( [  line_invoice_rule
			
				, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Artikel`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Truttmann`, `AG` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_values_line
	 
	, line_descr_line

	, with( invoice, due_date, DATE )
	
	, line_original_order_date( DATE )
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================
   
	  generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	  
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, newline ] )

] ).

%=======================================================================
i_rule( count_rule, [
%=======================================================================
   
	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	
	, line_order_line_number(NEXT_LINE_NUMBER)
	
] ).