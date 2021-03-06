%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT GIUGLIANO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_giugliano, `05 May 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_address

	, get_buyer_contact
	
	, get_delivery_contact

	, get_order_date
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `12993199` )                      %PROD
	]) ]

	, buyer_ddi( `0823821148` )
	
	, delivery_ddi( `0823821148` )
	
	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * DELIVERY LOCATION * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Richiesta`, `da` ], buyer_contact, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Richiesta`, `da` ], delivery_contact, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Totale`, `netto`], 250, total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `Totale`, `netto` ], 250, total_invoice, d, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  invoice_date( Today_string )
	
	, trace( [`order date found`, invoice_date ]) 

] ) 
:- 
	date_get( today, Today )

	, date_string( Today, 'd/m/y', Today_string )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q0n(line), delivery_start_header
	
	, delivery_party_line
	
	, q10( delivery_dept_line )
	
	, delivery_street_line
	
	, delivery_postcode_city_location_line
	
] ).

%=======================================================================
i_line_rule_cut( delivery_start_header, [
%=======================================================================

	 `Indirizzo`, `di`, `spedizione`, `merce`
	 
	, trace( [`delivery start header found`] )

] ).

%=======================================================================
i_line_rule_cut( delivery_party_line, [
%=======================================================================

	  delivery_party(s1)
	  
	, check( delivery_party(end) < 0 )
	
	, trace( [ `delivery party`, delivery_party ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_dept_line, [
%=======================================================================

	  delivery_dept(s1)
	  
	, check( delivery_dept(end) < 0 )
	
	, trace( [ `delivery dept`, delivery_dept ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_street_line, [
%=======================================================================

	  delivery_street(s1)
	  
	, check( delivery_street(end) < 0 )
	
	, trace( [ `delivery street`, delivery_street ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_postcode_city_location_line, [
%=======================================================================

	  delivery_postcode(d)
	  
	, delivery_city(sf)
	
	, delivery_state(f( [ begin, q(alpha,2,2), end ] ) )
	
	, check( delivery_state(end) < 0 )
	
	, trace( [ `delivery stuffs`, delivery_postcode, delivery_city, delivery_state ] )

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

	, qn0( [ peek_fails(line_end_line)

		, or([ text_on_left
		
				, line_invoice_rule
			
				, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ q10( [ word, tab ] ), `Articolo`, tab, `lordo` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	  q10( [ word, tab ] )
	  
	, or( [ [ `Beni`, `nuovi`, `di`, `fabbrica` ]
	  
			, [ `Totale`, `netto` ]
			
		] )
	  
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  q10( [ word, tab ] )
	  
	, generic_item( [ line_item, d, q10( tab ) ] )
	  
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_unit_amount_x, d, q10( tab ) ] )
	
	, q10( generic_item( [ some_uom_thing, d ] ) )
	
	, generic_item( [ line_quantity_uom_code, w, [ q10( `.` ), tab ] ] )
	
	, generic_item( [ pre_discount_net, d, tab ] )
	
	, generic_item( [ line_percent_discount_x, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( text_on_left, [
%=======================================================================

	  dummy(w), newline
	  
	, check( dummy(end) < -400 )

] ).