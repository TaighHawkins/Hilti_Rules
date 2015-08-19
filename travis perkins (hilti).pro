%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TRAVIS PERKINS (HILTI)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( travis_perkins_hilti, `04 February 2015` ).

i_date_format( _ ).

i_pdf_parameter( same_line, 10 ).
i_pdf_parameter( x_tolerance_100, 100 ).

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

	  buyer_registration_number( `GB-TRAVISP` )

	, [ or([ 
       [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
         , supplier_registration_number( `P11_100` )                      %PROD
     ]) ]

	, buyer_party( `LS` )
	
	, supplier_party( `LS` )
	
	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11025682` ) ]    %TEST
	    , suppliers_code_for_buyer( `12269802` )                      %PROD
	]) ]
	
%	, delivery_note_number_rule
	
	, scfb_rule

	, due_date_rule
	
	, type_of_supply_rule
	
	, delivery_location_rule

	, [ q0n(line), ship_to_line ]

	, get_delivery_details

	, get_buyer_details
	
	, get_order_number_rule

	, invoice_date_rule

	, sales_attribution(`0`)

	, get_invoice_lines

	, invoice_totals_rule	

%	, update_sales

	, or([ test(test_flag), test_delay_rule, set_delay_rule ])

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

		q0n(anything), `B69`, `4NQ`, newline

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
% TYPE OF SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( type_of_supply_rule, [
%=======================================================================

	  q0n(line), type_of_supply_header_line
	  
	, q(0,3,line), type_of_supply_line
	
] ).

%=======================================================================
i_line_rule( type_of_supply_header_line, [ 
%=======================================================================

	 `Delivery`, `instructions`, `:`

]).

%=======================================================================
i_line_rule( type_of_supply_line, [ 
%=======================================================================

	   type_of_supply(w), tab
	
	, check( type_of_supply(start) < -250 )
	
	, trace( [ `type of supply`, type_of_supply ] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( delivery_location_rule, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  q0n(line), deliver_to_header_line

	, q10([ q(0,2,line), delivery_location_line ])
	  
	, q(0,4,line), delivery_note_line
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_location_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	nearest(deliver_to(start), -20, 40)

	, delivery_location(w), or( [ tab, newline ] )
	  
	, trace( [ `delivery location`, delivery_location ] )
	
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_note_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	nearest(deliver_to(start), 10, 10)

	, or([ `0`, delivery_note_number(w) ]), or( [ tab, newline ] )
	  
	, trace( [ `delivery note number`, delivery_note_number ] )
	
] ).


%=======================================================================
i_line_rule( deliver_to_header_line, [ 
%=======================================================================

	  q0n(anything), read_ahead(deliver_to(w))

	, `deliver`, `to`, `:`
	
	, trace( [ `found header` ] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  without(delivery_note_number),

      gen1_address_details( [ delivery_left_margin, read_ahead(delivery_start_line), delivery_party, delivery_contact_x,
                           delivery_street, delivery_street_2, delivery_city, delivery_state_x, delivery_postcode,
                           delivery_end_line ] )

	, check(i_user_check(gen_same, delivery_left_margin, DS) )

	, delivery_street(DS)


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      q0n(anything)

    , `deliver`, `to`, `:`, tab, delivery_left_margin(s1), newline

    , check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 10, 10 ) )


] ).



%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or([ with(delivery_postcode), [ `Please`, `supply`, `the` ] ])
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_details, [ 
%=======================================================================

	  q0n(line), get_buyer_header_line
	  
	, q(0,6,line)
	
	, or( [ get_buyer_ddi_line, get_buyer_ddi_rule ] )
	
	, q(0,3,line), get_buyer_contact_line
	
	, q(0,3,line), get_buyer_email_line

] ).

%=======================================================================
i_line_rule( get_buyer_header_line, [ 
%=======================================================================

	  q0n(anything), `In`, `the`, `event`, `of`, `a`, `query`
	
	, trace( [ `found header` ] )

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	  q0n(anything), `contact`, tab
	  
	, buyer_contact(s1), or( [ tab, newline ] )

	, trace( [ `buyer contact`, buyer_contact ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi_line, [ 
%=======================================================================

	  q0n(anything), `Telephone`, q10( tab ), buyer_ddi(s1), tab

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_rule( get_buyer_ddi_rule, [ 
%=======================================================================

	read_ahead( generic_horizontal_details( [ `Telephone` ] ) )
	
	, or( [ q(0,2,up), q(0,1,line) ] )
	
	, buyer_ddi_line
	
] ).

%=======================================================================
i_line_rule( buyer_ddi_line, [ 
%=======================================================================

	q0n(anything), read_ahead( dummy(d) )
	
	, check( dummy(start) = DumStart )
	, check( generic_hook(end) = HookEnd )
	, check( sys_calculate( Diff, DumStart - HookEnd ) )
	, check( Diff > 0 )
	, check( Diff < 50 )
	
	, generic_item_cut( [ buyer_ddi, s1 ] )
	
] ).

%=======================================================================
i_line_rule( get_buyer_email_line, [ 
%=======================================================================

	  q0n(anything), or( [ at_start, tab ] )
	  
	, buyer_email(s1)

	, check( q_sys_sub_string( buyer_email, _, _, `@` ) )

	, trace( [ `buyer_email`, buyer_email ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_rule, [ 
%=======================================================================

	  q(0,5,line), order_number_header_line
	  
	, q(0,3,line), order_number_line

] ).

%=======================================================================
i_line_rule( order_number_header_line, [ 
%=======================================================================

	  q0n(anything), `Branch`, `Number`, tab, `Order`, `Number`, newline
	  
	, trace( [ `found the header` ] )

] ).

%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	  q0n(anything), dum_branch(s), tab, order_number_x(s1), newline
	  
	, check( order_number_x(start) > 180 )
	
	, check( order_number_x = Ord_x )
	
	, check( dum_branch = Branch )
	
	, check( strcat_list( [ Branch, Ord_x ], Order ) )
	
	, order_number( Order )
	
	, trace( [ `order number`, order_number ] )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( invoice_date_rule, [ 
%=======================================================================

	  q0n(line)
	  
	, or( [ invoice_date_line, [ invoice_date_header, invoice_date_two_line ] ] )

] ).

%=======================================================================
i_line_rule( invoice_date_line, [ 
%=======================================================================

	`Date`, `ordered`,  `:`, tab, invoice_date(date)

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%=======================================================================
i_line_rule( invoice_date_header, [ `Date`, `ordered`,  `:` ] ).
%=======================================================================
i_line_rule( invoice_date_two_line, [ 
%=======================================================================

	  invoice_date(date)

	, trace( [ `invoice date`, invoice_date ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( due_date_rule, [ 
%=======================================================================

	  q0n(line)
	  
	, or( [ due_date_line, [ due_date_header, due_date_two_line ] ] )

] ).

%=======================================================================
i_line_rule( due_date_line, [ 
%=======================================================================

	  `Delivery`, `required`, `by`, `:`, tab, due_date(date), or( [ tab, newline ] )
	
	, trace( [ `due date`, due_date ] )

] ).

%=======================================================================
i_line_rule( invoice_date_header, [ `Delivery`, `required`, `by`, `:` ] ).
%=======================================================================
i_line_rule( invoice_date_two_line, [ 
%=======================================================================

	  due_date(date)

	, trace( [ `due date`, due_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( invoice_totals_rule, [
%=======================================================================

	  q0n(line), total_net_line

] ).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================

	  q0n(anything), `Sub`, `Total`
	
	, tab, word, q10(tab)
	
	, read_ahead( total_net(d) )
	 
	, trace( [ `got the net` ] )
	 
	, total_invoice(d), newline
	  
	, trace( [ `total net`, total_net ] )
	
	, trace( [ `total amount`, total_invoice ] )

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

		, or([ line_invoice_line
		
			, [ set( no_item ), line_invoice_line, clear( no_item ) ]
			
			, line

			])

		] )
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Quantity`, tab, `Item`, tab, `Description`, `/`, `Order`, `in`, `multiples` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  q0n(word), tab, `Sub`, `Total`, tab

] ).


%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  q10( [ q0n(word), tab ] ), line_quantity(d), tab
	  
	, or( [ [ check( line_quantity(start) > -325 )
	
			, check( line_quantity(end) < -230 )
			
		]
		
		, [ check( line_quantity(start) > -410 )
	
			, check( line_quantity(end) < -350 )
			
		]
		
	] )
	
	, trace( [ `line quantity`, line_quantity ] )
	
	, or( [ [ test( no_item ), line_item( `Missing` ), q(1,3,word) ]

		, line_item(d)
		
	] ), q10(tab)
	
	, trace( [ `line item`, line_item ] )
	
	, line_descr(s), `[`
	
	, or( [ [ line_quantity_uom_code(f([q(dec,0,9), begin, q(alpha,0,9), end ])) ]
	
		, [ dummy(d), line_quantity_uom_code(sf) ]
		
	] ), `]`, tab
	
	, trace( [ `line description`, line_descr ] )
	
	, word, tab, line_unit_amount(d), tab
	
	, per(w), tab, word, q10(tab), line_net_amount(d), newline
	
	, trace( [ `line amount`, line_net_amount ] )
	
	, q10([ with( invoice, due_date, DATE ), line_original_order_date( DATE ) ])

	, add_to_sales
	
] ).


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
sales_lookup_test( `11238606`, `11232143`, `TGB0200316`, `AM Andy Self`).
sales_lookup_test( `11238607`, `11238596`, `TGB0200314`, `AM Anthony Harvey`).
sales_lookup_test( `11238608`, `11238597`, `TGB0100801`, `AM Stuart Bailey`).
sales_lookup_test( `11238609`, `11238598`, `TGB0100512`, `AM Martin Scholey`).
sales_lookup_test( `11238610`, `11238599`, `TGB0200313`, `AM Christopher Windas`).
sales_lookup_test( `11238611`, `11238600`, `TGB0101105`, `AM Vacant 101105`).
sales_lookup_test( `11238612`, `11238601`, `TGB0200209`, `AM Ian Welch`).
sales_lookup_test( `11238614`, `11238603`, `TGB0100405`, `AM Chris Jordan`).
sales_lookup_test( `11238615`, `11238604`, `TGB0200501`, `AM Tom Clayton`).



