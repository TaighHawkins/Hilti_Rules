%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TRAVIS PERKINS (HILTI)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( travis_perkins_tradacom, `11 January 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

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

i_default( new_invoice_page ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_page_split_rule_list( [ ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 set( purchase_order )

	, buyer_registration_number( `GB-TRAVISP` )

	, [ or([ 
       [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
         , supplier_registration_number( `P11_100` )                      %PROD
     ]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11025682` ) ]    %TEST
	    , suppliers_code_for_buyer( `12269802` )                      %PROD
	]) ]

	, buyer_party( `LS` )
	
	, supplier_party( `LS` )
	
	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ q0n(line), due_date_line ]
	
	, [ q0n(line), get_delivery_contact ]

	, [ q0n(line), get_delivery_details ]

	,[ q0n(line), order_date_line ]

	, [ q0n(line), ship_to_line ]

	, sales_attribution(`0`)

	, check( i_user_check( gen_cntr_set, 20, 1 ) )
	, get_order_lines

	, [ total_net(`0`), total_invoice(`0`) ]

%	, update_sales

	% , or([ test(test_flag), test_delay_rule, set_delay_rule ])

] ).



%=======================================================================
i_rule( add_to_sales, [
%=======================================================================

	or([ 
	  [ test(test_flag), check( i_user_check( retrieve_price_from_cache_test, ITEM, PRICE ) ) ]    %TEST
	    , check( i_user_check( retrieve_price_from_cache, ITEM, PRICE ) )     %PROD
	]) 

	, trace([ `found price`, PRICE ])

	, check(i_user_check( gen_str_multiply, line_quantity, PRICE, TP) )

	, with(invoice, sales_attribution, SA )

	, check(i_user_check( gen_str_add, SA, TP, NEW_SALE ) )

	, remove( sales_attribution ), sales_attribution(NEW_SALE)

	, trace([ `Sales total`, ITEM, TP, sales_attribution ])

])
:-
	i_mail(subject, SUBJECT)
	, string_to_upper(SUBJECT, SUBJECT_LW)
	, string_string_replace( SUBJECT_LW, ` `, ``, SUBJECT_LX )
	, q_sys_sub_string( SUBJECT_LX, I0, _, `ITEM=`)
	, q_sys_sub_string( SUBJECT_LX, I, _, `=`)
	, sys_calculate( IX, I + 1 )
	, q_sys_sub_string( SUBJECT_LX, IX, _, ITEM)
.



%=======================================================================
i_rule( add_to_sales, [
%=======================================================================

	or([ 
	  [ test(test_flag), check( i_user_check( retrieve_price_from_cache_test, line_item, PRICE ) ) ]    %TEST
	    , check( i_user_check( retrieve_price_from_cache, line_item, PRICE ) )     %PROD
	]) 

	, trace([ `found price`, PRICE ])

	, check(i_user_check( gen_str_multiply, line_quantity, PRICE, TP) )

	, with(invoice, sales_attribution, SA )

	, check(i_user_check( gen_str_add, SA, TP, NEW_SALE ) )

	, remove( sales_attribution ), sales_attribution(NEW_SALE)

	, trace([ `Sales total`, line_item, TP, sales_attribution ])

]).

%=======================================================================
i_rule( add_to_sales, [ set( price_lookup_failed), trace([ `price_lookup_failed` ]) ]).
%=======================================================================

%=======================================================================
i_user_check( retrieve_price_from_cache, ITEM, PRICE )
%-----------------------------------------------------------------------
:- lookup_cache( `travis.csv`, `travis`, `1`, ITEM, `PC`, PRICE ).
%=======================================================================

%=======================================================================
i_user_check( retrieve_price_from_cache_test, ITEM, PRICE )
%-----------------------------------------------------------------------
:- lookup_cache( `travis test.csv`, `travis`, `1`, ITEM, `PC`, PRICE ).
%=======================================================================


%=======================================================================
i_rule( update_sales, [ 
%=======================================================================

	with(invoice, sales_location, LOCATION)

	, check(i_user_check( read_cache_amount, LOCATION, VALUE ))

	, trace([ `old value`, LOCATION, VALUE ])

	, or([ [ test(price_lookup_failed), with(invoice, total_invoice, TI) ]

		, with(invoice, sales_attribution, TI)  ])

	, check( sys_calculate_str_add( TI, VALUE, NEW_VALUE ) )

	, check(i_user_check( write_cache_amount, LOCATION, NEW_VALUE ))

	, trace([ `new value`, LOCATION, NEW_VALUE ])

] ).


%=======================================================================
i_user_check( read_cache_amount, LOCATION, VALUE )
:-
	string_to_lower( LOCATION, LL)
	, lookup_cache(`hilti_sales`, `territory`,  LL, `amount`,  VALUE )
.
%=======================================================================
%=======================================================================
i_user_check( write_cache_amount, LOCATION, VALUE )
:-
	set_cache(`hilti_sales`, `territory`, LOCATION, `amount`, VALUE )
	, save_cache
.
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET SHIP TO FROM LOWEST ACCOUMUATED SALES TOTAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( ship_to_line, [
%=======================================================================

		q0n(anything), `B69`, `4NQ`

		,trace([`getting lowest location`])

		,check( i_user_check( get_lowest_location, CUSTOMER, LOCATION ) )

		, sales_location(LOCATION)

		,trace([`found lowest location`, CUSTOMER, LOCATION ])

		,  or([ 
		  [ test(test_flag), check(i_user_check( get_ship_to_test, TP, SPEEDY, LOCATION ) ) ]						%TEST
	    		, [ peek_fails(test(test_flag)), check(i_user_check( get_ship_to, TP, SPEEDY, LOCATION ) )	]			%PROD
		]) 

		,delivery_note_number(TP)
		, trace([`ship to`, delivery_note_number]) 

%=======================================================================

		, q01([ check( i_user_check( get_cache_count, `location`, COUNT ) )             %%% q01 to disable
			, or([ 
				[ check(i_user_check( gen_q_sys_comp_str_gt, COUNT, `3` ) )
				, delivery_note_reference( `waiting` )
				, force_result( `defect` )
				, check( i_user_check( set_cache_count, `location`, `0` ))
				, trace([`reset cache count`, `0` ]) ]

				, [ q10([ check(i_user_check( gen_q_sys_comp_str_gt, COUNT, `0` ) )
					, delivery_note_reference( `waiting response` )
					, force_result( `defect` )
					])
				, check( i_user_check( gen_str_add, COUNT, `1`, COUNTX ))
				, check( i_user_check( set_cache_count, `location`, COUNTX ))
				, trace([`new cache count`, COUNTX]) ]
				])
			])
		
]).


%=======================================================================
i_user_check( get_cache_count, LOCATION, COUNT )
:-
	lookup_cache(`hilti_sales`, `count`, LOCATION, `value`, COUNT )
.
%=======================================================================
i_user_check( set_cache_count, LOCATION, COUNT )
:-
	set_cache(`hilti_sales`, `count`, LOCATION, `value`, COUNT )
	, save_cache
.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( delivery_note_number_rule, [
%=======================================================================

	  q0n(line), delivery_note_number_header_line
	  
	, q(0,2,line), delivery_note_number_line
	
] ).

%=======================================================================
i_line_rule( delivery_note_number_header_line, [ 
%=======================================================================

	  q0n(anything)

	, `Invoice`, `to`, `:`

]).

%=======================================================================
i_line_rule( delivery_note_number_line, [ 
%=======================================================================

	  q0n(anything)

	, delivery_note_number(w)
	
	, check( delivery_note_number(start) > 0 )
	
	, check( delivery_note_number(end) < 100 )
	
	, trace( [ `delivery_note_number`, delivery_note_number ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCFB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( scfb_rule, [
%=======================================================================

	  q0n(line), scfb_header_line
	  
	, or([ [ q(0,2,line), scfb_line ], suppliers_code_for_buyer(`12269802`) ])
	
] ).

%=======================================================================
i_line_rule( scfb_header_line, [ 
%=======================================================================

	  q0n(anything), read_ahead(scfb_to(w))

	, `invoice`, `to`, `:`
	
	, trace( [ `found header` ] )

]).

%=======================================================================
i_line_rule( scfb_line, [ 
%=======================================================================

	nearest(scfb_to(start), 10, 10)

	, suppliers_code_for_buyer(w), or( [ tab, newline ] )
	
	, trace( [ `suppliers code for buyer`, suppliers_code_for_buyer ] )

]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( get_delivery_contact, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	`OOL`, `=`

	, supplier_code(sf), `:`, delivery_location(sf), qn1(`+`)

	, buyer_contact(sf)

	, or([ `+`, `'`, newline ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	`CLO`, `=`

	, supplier_code(sf), `:`, delivery_location(sf), qn1(`+`)

	, delivery_dept(sf), q10([ `+`, delivery_party(sf) ]), `:`

	, delivery_street(sf), `:`

	, q0n([ delivery_street_x(sf), `:` ])

	, q10([ delivery_street(sf), `:` ])

	, delivery_city(sf), qn1(`:`)

	, delivery_postcode(sf)

	, q10(`'`), newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_details, [ 
%=======================================================================

	  buyer_party(`TRAVIS PERKINS TRADING CO`)

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND  DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	`ORD`, `=`

	,  order_number(sf), qn1(`:`)

	, set( regexp_allow_partial_matching )

	, wrap( invoice_date(f([begin,q(dec,2,2),end])),`20`,``)

	, append( invoice_date(f([begin,q(dec,2,2),end])),`/`,``)

	, append( invoice_date(f([begin,q(dec,2,2),end])),`/`,``)

	, clear( regexp_allow_partial_matching )

	, trace( [ `order`, order_number, invoice_date ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( due_date_line, [ 
%=======================================================================

	  `DIN`, `=`, qn1(`+`)

	, set( regexp_allow_partial_matching )

	, wrap( due_date(f([begin,q(dec,2,2),end])),`20`,``)

	, append( due_date(f([begin,q(dec,2,2),end])),`/`,``)

	, append( due_date(f([begin,q(dec,2,2),end])),`/`,``)

	, clear( regexp_allow_partial_matching )
	
	, trace( [ `due date`, due_date ] )

	, q10([ qn1(`+`), shipping_instructions(sf), `:`

		, qn0([ append(shipping_instructions(sf), ` `, ``), or([ tab, `'`, `:` ]) ])

	])

	, or([ `'`, newline ])

] ).


%=======================================================================
i_section( get_order_lines, [ peek_ahead( order_line_header ), or([ special_line, order_line_line ]) ]).
%=======================================================================

%=======================================================================
i_line_rule( order_line_header, [ `COD`, `=` ]).
%=======================================================================
i_line_rule_cut( order_line_line, [
%=======================================================================

	`COD`, `=`
	
	, peek_fails( [ q0n(anything), `delivery` ] )
	
	, peek_fails([ q0n(anything), or([ `carriage`, `carrage`, `transport` ]) ])

	, line_order_line_number_x(d), qn1(`+`)

	, ean_number(d), qn1( or([ `+`, `:`]) )

	, or( [ generic_item( [ line_item, d, qn1( or([ `+`, `:`]) ) ] )
	
		, [ line_item( `Missing` ), generic_item_cut( [ dummy_item, sf, qn1( or([ `+`, `:`]) ) ] ) ] 
		
	] )

	, line_item_for_buyer(sf), qn1( or([ `+`, `:`]) )

	, pack_info(sf), qn1(`+`)

	, line_quantity(d), `:`, line_pack_size(d), `:`	

	, line_quantity_uom_code(sf), qn1(`+`)

	, unit_cost(sf), qn1(`+`)

	, line_descr(sf), qn0([ tab, append(line_descr(sf), ` `, ``) ]), or([ `'`, `+` ])

	, line_net_amount(`0`), line_total_amount(`0`)

	, q10([ with(invoice, due_date, DD), line_original_order_date(DD) ])

	, check( i_user_check( gen_cntr_inc_str, 20, LINE_NUMBER ) )

	, line_order_line_number(LINE_NUMBER)

	, add_to_sales

]).


%=======================================================================
i_line_rule_cut( special_line, [
%=======================================================================

	`COD`, `=`
	
	, peek_fails( [ q0n(anything), `delivery` ] )

	, line_order_line_number_x(d), qn1(`+`)

	, q0n(anything)

	, `special`, qn1(`+`)

	, peek_fails([ q0n(anything), or([ `carriage`, `carrage`, `transport` ]) ])

	, pack_info(sf), qn1(`+`)

	, line_quantity(d), `:`, line_pack_size(d), `:`	

	, line_quantity_uom_code(sf), qn1(`+`)

	, unit_cost(sf), qn1(`+`)

	, or([ read_ahead([ qn0(anything), space, line_item(f( [ begin, q(dec,4,10), end ] ) ) ]), line_item(`MISSING`) ])

	, line_descr(sf), or([ `'`, `+` ])

	, line_net_amount(`0`), line_total_amount(`0`)

	, q10([ with(invoice, due_date, DD), line_original_order_date(DD) ])

	, check( i_user_check( gen_cntr_inc_str, 20, LINE_NUMBER ) )

	, line_order_line_number(LINE_NUMBER)

	, add_to_sales

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( test, [
%=======================================================================

	check( i_user_check( get_lowest_location, CUSTOMER, LOCATION ) )

	, trace( [ `found`, CUSTOMER, LOCATION ] )

] ).

%=======================================================================
i_user_check( get_lowest_location, CUSTOMER, LOCATION )
%-----------------------------------------------------------------------
:-
%=======================================================================

	get_lowest_location_by_customer( `territory`, L1, V1 )

	, get_lowest_location_by_customer( `territory`, L2, V2 )

	, ( q_sys_comp( V1 =< V2 )

		->	CUSTOMER = `territory`, LOCATION = L1

		;	CUSTOMER = `territory`, LOCATION = L2
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
i_user_check( get_ship_to, TP, SPEEDY, LOCATION )
:-
	string_to_upper(LOCATION, LU)
	, sales_lookup(TP, SPEEDY, LU, _)
.
%=======================================================================

%=======================================================================
i_user_check( get_ship_to_test, TP, SPEEDY, LOCATION )
:-
	string_to_upper(LOCATION, LU)
	, sales_lookup_test(TP, SPEEDY, LU, _)
.
%=======================================================================


%=======================================================================
% PROD

sales_lookup( `Travis Perkins Ship-to's`, `Speedy Ship-to's`, `Territory`, `Account Manager`).
sales_lookup( `21109905`, `20048769`, `TGB0200316`, `AM Andy Self`).
sales_lookup( `21109971`, `21110219`, `TGB0200314`, `AM Anthony Harvey`).
sales_lookup( `21109975`, `21110253`, `TGB0200313`, `AM Christopher Windas`).
sales_lookup( `21109982`, `21110291`, `TGB0200209`, `AM Chas Baker`).
sales_lookup( `21109981`, `21110255`, `TGB0101105`, `AM Steven Young`).
sales_lookup( `21109972`, `21110220`, `TGB0100801`, `AM Stuart Bailey`).
sales_lookup( `21109974`, `21110252`, `TGB0100512`, `AM Martin Scholey`).
sales_lookup( `20947598`, `21110080`, `TGB0100608`, `AM Rob Groat`).
sales_lookup( `21109984`, `21110293`, `TGB0100405`, `AM Chris Jordan`).

%=======================================================================
% TEST

sales_lookup_test( `Travis Perkins Ship-to's`, `Speedy Ship-to's`, `Territory`, `Account Manager`).
sales_lookup_test( `11238605`, `11238595`, `TGB0100502`, `AM Michael Crawford`).
sales_lookup_test( `11238606`, `11232143`, `TGB0200316`, `AM Vince Edwards`).
sales_lookup_test( `11238607`, `11238596`, `TGB0200314`, `AM Anthony Harvey`).
sales_lookup_test( `11238608`, `11238597`, `TGB0100801`, `AM Stuart Bailey`).
sales_lookup_test( `11238609`, `11238598`, `TGB0100512`, `AM Martin Scholey`).
sales_lookup_test( `11238610`, `11238599`, `TGB0200313`, `AM Daljit Sangha`).
sales_lookup_test( `11238611`, `11238600`, `TGB0101105`, `AM Vacant 101105`).
sales_lookup_test( `11238612`, `11238601`, `TGB0200209`, `AM Ian Welch`).
sales_lookup_test( `11238614`, `11238603`, `TGB0100405`, `AM Chris Jordan`).
sales_lookup_test( `11238615`, `11238604`, `TGB0200501`, `AM Tom Clayton`).

