%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US MACON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_macon, `09 April 2015` ).

i_pdf_parameter( max_pages, 1 ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_user_field( invoice, buyer_location, `Buyer Location` ).

i_op_param( addr( Res ), _, `hilti.orders@ecx.adaptris.com`, _, Addr )
:-
	Res = success
		->	Addr = `USADgroup@hilti.com`
		
		;	Addr = `USADgroup@hilti.com, roger.zeller@hilti.com`
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_details

	, get_order_date
	
	, get_order_number
	
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

	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10478866` ) ]    %TEST
	    , suppliers_code_for_buyer( `10751456` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_from_location( `909459` ) ]    %TEST
	    , delivery_from_location( `17345793` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), buyer_location( `909459` ) ]    %TEST
	    , buyer_location( `17345793` )                      %PROD
	]) ]

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `01` )
	, cost_centre( `Standard` )

	, sender_name( `Macon Supply Inc.` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER & DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `P`, `.`, `O`, `.`, `Number` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  invoice_date( TodayString )
	, trace( [ `Invoice Date`, TodayString ] )

] ):- date_get( today, Today ), date_string( Today, `m/d/y`, TodayString ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Ship`, `To`, `:` ] ] )
	  
	, generic_horizontal_details( [ nearest( generic_hook(end), 10, 50 ), delivery_party, s1 ] )
	
	, q10( generic_horizontal_details( [ nearest( generic_hook(end), 10, 50 ), delivery_dept, s1 ] ) )
	
	, q01(line), generic_horizontal_details( [ nearest( generic_hook(end), 10, 50 ), delivery_street, s1 ] )
	
	, delivery_city_and_state_line
	
	, or( [ test( gotpc )
		, generic_horizontal_details( [ nearest( generic_hook(end), 10, 150 ), delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	] )
	
] ).

%=======================================================================
i_line_rule_cut( delivery_city_and_state_line, [ 
%=======================================================================

	nearest( generic_hook(end), 10, 50 )
	
	, generic_item( [ delivery_city, sf, `,` ] )
	
	, generic_item( [ delivery_state, w ] )
	
	, q10( [ tab, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] ), set( gotpc ) ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  or( [ [ q0n(line)
	  
			, generic_horizontal_details( [ [ or( [ at_start, tab ] ), `Total`, `:` ], total_net, d, newline ] )

			, check( total_net = Net )
			, total_invoice( Net )
			
		]
		
		, [ set( no_total_validation ), total_net( `0` ), total_invoice( `0` ) ]
		
	] )
	
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
i_line_rule_cut( line_header_line, [ `*`, `ITEM`, `#` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ q0n( [ dummy(s1), tab ] ), `Total` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	
	  generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	  
	, generic_item( [ line_quantity, d, tab ] )

	, q10( generic_item( [ line_descr, s1, tab ] ) )

	, or( [ generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )
	
		, [ `#`, `N`, `/`, `A`, tab ]
		
	] )

	, or( [ generic_item( [ line_net_amount, d, newline ] )
	
		, [ `#`, `N`, `/`, `A`, newline ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).