%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GRAYBAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( graybar, `03 February 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).


i_user_field( invoice, sales_location, `Sales Location` ).
i_user_field( invoice, sales_attribution, `Sales Attribution` ).


%=======================================================================
i_rule( test_delay_rule, [
%=======================================================================

	check( i_user_check( test_delay ))

	, set( chain, `*delay*` )

	, trace( [ `Delay found`] )

]).

%=======================================================================
i_rule( set_delay_rule, [
%=======================================================================

	check( i_user_check( set_delay ))

	, trace( [ `Delay set`] )

]).



%=======================================================================
i_user_check( test_delay )
%-----------------------------------------------------------------------
:-
%=======================================================================

	lookup_cache(  `hilti`, `sales`, `0`, `delay`, `1` )


. %end%

%=======================================================================
i_user_check( set_delay )
%-----------------------------------------------------------------------
:-
%=======================================================================

	set_cache(  `hilti`, `sales`, `0`, `delay`, `1` )

	, time_get( now, time( _, M, _ ) )

	, sys_string_number( MS, M )

	, set_cache(  `hilti`, `delay`, `0`, `time`, MS )

	, save_cache

. %end%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_invoice_date
	
	, get_due_date

	, get_delivery_details
	
	, get_buyer_contact
	
	, get_buyer_email
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, [ q0n(line), ship_to_line ]

	, get_invoice_lines

	, get_totals

	, or([ test(test_flag), test_delay_rule, set_delay_rule ])


] ).


%=======================================================================
i_line_rule( ship_to_line, [
%=======================================================================

		trace([`getting lowest location`])

		,check( i_user_check( get_lowest_location, CUSTOMER, LOCATION ) )

		, sales_location(LOCATION)

		,trace([`found lowest location`, CUSTOMER, LOCATION ])

		,  or([ 
		  [ test(test_flag), check(i_user_check( get_ship_to_test, NR, UR, GB, LOCATION ) ) ]						%TEST
	    		, [ peek_fails(test(test_flag)), check(i_user_check( get_ship_to, NR, UR, GB, LOCATION ) )	]			%PROD
		]) 

		,delivery_note_number(GB)
		, trace([`ship to`, delivery_note_number]) 
	
]).



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

	, buyer_registration_number( `GB-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12413810` )

	, sender_name( `GrayBar Ltd.` )
	, delivery_party( `GRAYBAR LTD` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,30,line)
	  
	, generic_horizontal_details( [ [ `Purchase`, `Order`, `no`, `.` ], 200, order_number, s1 ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Tax`, `Date` ], 200, invoice_date, date ] ) 
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ `Delivery`, `Required` ], invoice_date, date ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	buyer_email( From )
	
] )
:-
	i_mail( from, From ),
	not( q_sys_sub_string( From, _, _, `@hilti.com` ) )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	qn0(line)
	
	, generic_horizontal_details( [ [ at_start, `Originator` ], buyer_contact, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q(0,10,line)
	
	, generic_horizontal_details( [ [ tab, `GrayBar` ] ] )
	
	, q(2,2, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] ) )
	
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_city, s1 ] )
	
	, q10(line), generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_postcode, pc ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  qn0(line)
	  
	, generic_horizontal_details( [ [ `Total`, `Net`, `Amount` ], 250, total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Qty`, `Ordered`, tab, `Product`, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Notes` ]
	
		, [ `Total`, `Net` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_unit_amount = Net )

		, delivery_charge( Net )
	
	] )
	
	, count_rule
	
	, q10( [ with( invoice, due_date, Date ), line_original_order_date( Date ) ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_descr, s, [ `(`, generic_item( [ line_item, [ begin, q(dec,4,10), end ], `)` ] ), tab ] ] )

	, generic_item_cut( [ line_quantity_uom_code, w, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )

	, generic_item( [ line_percent_discount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport` ] )
	, trace( `delivery line, line being ignored` )
.



%=======================================================================
i_user_check( get_lowest_location, CUSTOMER, LOCATION )
%-----------------------------------------------------------------------
:-
%=======================================================================

	get_lowest_location_by_customer( `rail`, L1, V1 )

	, get_lowest_location_by_customer( `rail`, L2, V2 )

	, ( q_sys_comp( V1 =< V2 )

		->	CUSTOMER = `rail`, LOCATION = L1

		;	CUSTOMER = `rail`, LOCATION = L2
	)
.


%=======================================================================
get_lowest_location_by_customer( CUSTOMER, LOCATION, VALUE )
%-----------------------------------------------------------------------
:-
%=======================================================================

	lookup_cache_list( `hilti_sales`, CUSTOMER, `amount`, CUST_LIST )

	, reverse_pairs( CUST_LIST, CUST_NORMALISED_LIST )

	, sys_sort( CUST_NORMALISED_LIST, [ cache( VALUE, LOCATION ) | _ ] )

	; LOCATION = `not found`, VALUE = -9999
.

%=======================================================================
reverse_pairs( [], [] ).
%=======================================================================
reverse_pairs( [ cache( X, Y ) | T_IN ], [ cache( NUMBER_Y, X ) | T_OUT ] ) :- sys_string_number( Y, NUMBER_Y ), !, reverse_pairs( T_IN, T_OUT ).
%=======================================================================

%=======================================================================
i_user_check( get_ship_to, NR, UR, GB, LOCATION )
:-
	string_to_upper(LOCATION, LU)
	, rail_lookup(NR, UR, GB, LU, _)
.
%=======================================================================

%=======================================================================
i_user_check( get_ship_to_test, NR, UR, GB, LOCATION )
:-
	string_to_upper(LOCATION, LU)
	, rail_lookup_test(NR, UR, GB, LU, _)
.
%=======================================================================

%=======================================================================
% PROD

rail_lookup( `Netrai1 Ship-to`, `Unipart Ship-to`, `Graybar Ship-to`, `Territory`, `Account Manager`).
rail_lookup( `21009924`, `19621590`, `22119538`, `TGB0500101`, `AM Lee Taylor`).
rail_lookup( `21009969`, `20691581`, `22119539`, `TGB0500102`, `AM Richard Kirman`).
rail_lookup( `21363697`, `22038023`, `22119540`, `TGB0500103`, `AM Chris Denyer`).
rail_lookup( `22038114`, `22038024`, `22119616`, `TGB0500106`, `Vacant`).
rail_lookup( `22046392`, `22038025`, `22119617`, `TGB0500107`, `AM Paul Alexander`).

%=======================================================================
% TEST

rail_lookup_test( `Netrai1 Ship-to`, `Unipart Ship-to`, `Graybar Ship-to`, `Territory`, `Account Manager`).
rail_lookup_test( `21009924`, `19621590`, `22119538`, `TGB0500101`, `AM Lee Taylor`).
rail_lookup_test( `21009969`, `20691581`, `22119539`, `TGB0500102`, `AM Richard Kirman`).
rail_lookup_test( `21363697`, `22038023`, `22119540`, `TGB0500103`, `AM Chris Denyer`).
rail_lookup_test( `22038114`, `22038024`, `22119616`, `TGB0500106`, `Vacant`).
rail_lookup_test( `22046392`, `22038025`, `22119617`, `TGB0500107`, `AM Paul Alexander`).





