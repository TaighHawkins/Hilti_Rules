%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_response_rules, `3 Feb 2015` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 set( purchase_order )

	, get_order_number

	, get_hilti_order_number

	, get_partn_code

	, get_logical_system

	, get_country_code

	, get_summe

	, update_cache

	, force_result( `success` )

] ).


%=======================================================================
i_section( get_order_number, [ 
%=======================================================================

	xml_tag_line( [ `E1EDK02` ] )

	, xml_tag_line( [ `QUALF`, `001` ] )

	, q10( [ q0n( line ), xml_tag_line( [ `BELNR`, order_number ] ) ] )

] ).

%=======================================================================
i_section( get_hilti_order_number, [ 
%=======================================================================

	xml_tag_line( [ `E1EDK02` ] )

	, xml_tag_line( [ `QUALF`, `002` ] )

	, q10( [ q0n( line ), xml_tag_line( [ `BELNR`, invoice_number ] ) ] )

] ).


%=======================================================================
i_section( get_partn_code, [ 
%=======================================================================

	xml_tag_line( [ `E1EDKA1` ] )

	, xml_tag_line( [ `PARVW`, `AG` ] )

	, q10( [ q0n( line ), xml_tag_line( [ `PARTN`, suppliers_code_for_buyer] ) ] )

] ).


%=======================================================================
i_section( get_logical_system, [ 
%=======================================================================

	xml_tag_line( [ `EDI_DC40` ] )

	, q10( [ q0n( line ), xml_tag_line( [ `SNDPRN`, buyer_registration_number] ) ] )

] ).


%=======================================================================
i_section( get_country_code, [ 
%=======================================================================

	xml_tag_line( [ `E1EDK14` ] )

	, xml_tag_line( [ `QUALF`, `008` ] )

	, q10( [ q0n( line ), xml_tag_line( [ `ORGID`, agent_code_3] ) ] )

] ).


%=======================================================================
i_section( get_summe, [ 
%=======================================================================

	xml_tag_line( [ `E1EDS01` ] )

	, xml_tag_line( [ `SUMID`, `002` ] )

	, q10( [ q0n( line ), xml_tag_line( [ `SUMME`, total_invoice] ) ] )

] ).


%=======================================================================
i_section( update_cache, [ 
%=======================================================================

	xml_tag_line( [ `E1EDKA1` ] )

	, xml_tag_line( [ `PARVW`, `WE` ] )

	, xml_tag_line( [ `PARTN`, delivery_note_number ] )

	, or([ 

		[ check( i_user_check( get_tp_ship_to, delivery_note_number, LOCATION ) ), customer_lookup(`territory`), set(customer, `travis`), trace([ `Travis` ]) ]
		, [ check( i_user_check( get_speedy_ship_to, delivery_note_number, LOCATION ) ), customer_lookup(`territory`), set(customer, `speedy`), trace([ `Speedy` ]) ]
%		, [ check( i_user_check( get_netrail_ship_to, delivery_note_number, LOCATION ) ), customer_lookup(`rail`), set(customer, `netrail`), trace([ `Network Rail` ]) ]
%		, [ check( i_user_check( get_unipart_ship_to, delivery_note_number, LOCATION ) ), customer_lookup(`rail`), set(customer, `unipart`), trace([ `Unipart` ]) ]
%		, [ check( i_user_check( get_graybar_ship_to, delivery_note_number, LOCATION ) ), customer_lookup(`rail`), set(customer, `graybar`), trace([ `Graybar` ]) ]
	])

	, trace([ `territory`, LOCATION ])

	, check(i_user_check( read_cache_amount, customer_lookup, LOCATION, VALUE ))

	, trace([ `old value`, VALUE ])

	, with(invoice, total_invoice, TI)

	, check( sys_calculate_str_add( TI, VALUE, NEW_VALUE ) )

	, trace([ `new value`, NEW_VALUE ])

	, check(i_user_check( write_cache_amount, customer_lookup, LOCATION, NEW_VALUE ))

	, delivery_note_reference(LOCATION)

	, trace([ `Sales updated`, LOCATION, VALUE, NEW_VALUE ])

	, or([

		 [ test(customer, `travis`), write([ `YTD Total`, `,`, `TP Ship-to`, `,`, `Speedy Ship-to`, `,`, `Territory`, `,`, `AM` ]) ]

		, [ test(customer, `speedy`), write([ `YTD Total`, `,`, `TP Ship-to`, `,`, `Speedy Ship-to`, `,`, `Territory`, `,`, `AM` ]) ]

		, [ test(customer, `netrail`), write([ `YTD Total`, `,`, `NetRail Ship-to`, `,`, `Unipart Ship-to`, `,`, `Graybar Ship-to`, `,`, `Territory`, `,`, `AM` ]) ]

		, [ test(customer, `unipart`), write([ `YTD Total`, `,`, `NetRail Ship-to`, `,`, `Unipart Ship-to`, `,`, `Graybar Ship-to`, `,`, `Territory`, `,`, `AM` ]) ]

		, [ test(customer, `graybar`), write([ `YTD Total`, `,`, `NetRail Ship-to`, `,`, `Unipart Ship-to`, `,`, `Graybar Ship-to`, `,`, `Territory`, `,`, `AM` ]) ]

	])


	, write_flush

     , check( i_user_check( get_list, customer_lookup, LIST ) ) 

     , apply_list( [ LIST ] )

	, trace([ `Sales report created` ])

] ).



i_rule(write_to_line([LOCATION, VALUE]), [

	test(customer, `travis`),  trace([ LOCATION, VALUE ])
	, check(i_user_check( gen_normalise_2dp_in_string, VALUE , VALUE_2dp ))
	, check(i_user_check( gen_string_to_upper, LOCATION, LU ))
	, check(i_user_check( get_sales_data, TP, SPEEDY, LU, AM ))
	, write([ VALUE_2dp,  `,`, TP, `,`, SPEEDY, `,`, LU, `,`, AM ])
	, write_flush

]).

i_rule(write_to_line([LOCATION, VALUE]), [

	test(customer, `speedy`),  trace([ LOCATION, VALUE ])
	, check(i_user_check( gen_normalise_2dp_in_string, VALUE , VALUE_2dp ))
	, check(i_user_check( gen_string_to_upper, LOCATION, LU ))
	, check(i_user_check( get_sales_data, TP, SPEEDY, LU, AM ))
	, write([ VALUE_2dp,  `,`, TP, `,`, SPEEDY, `,`, LU, `,`, AM ])
	, write_flush

]).

i_rule(write_to_line([LOCATION, VALUE]), [

	test(customer, `netrail`),  trace([ LOCATION, VALUE ])
	, check(i_user_check( gen_normalise_2dp_in_string, VALUE , VALUE_2dp ))
	, check(i_user_check( gen_string_to_upper, LOCATION, LU ))
	, check(i_user_check( get_rail_data, NR, UR, GB, LU, AM ))
	, write([ VALUE_2dp,  `,`, NR, `,`, UR, `,`, GB, `,`, LU, `,`, AM ])
	, write_flush

]).

i_rule(write_to_line([LOCATION, VALUE]), [

	test(customer, `unipart`),  trace([ LOCATION, VALUE ])
	, check(i_user_check( gen_normalise_2dp_in_string, VALUE , VALUE_2dp ))
	, check(i_user_check( gen_string_to_upper, LOCATION, LU ))
	, check(i_user_check( get_rail_data, NR, UR, GB, LU, AM ))
	, write([ VALUE_2dp,  `,`, NR, `,`, UR, `,`, GB, `,`, LU, `,`, AM ])
	, write_flush

]).

i_rule(write_to_line([LOCATION, VALUE]), [

	test(customer, `graybar`),  trace([ LOCATION, VALUE ])
	, check(i_user_check( gen_normalise_2dp_in_string, VALUE , VALUE_2dp ))
	, check(i_user_check( gen_string_to_upper, LOCATION, LU ))
	, check(i_user_check( get_rail_data, NR, UR, GB, LU, AM ))
	, write([ VALUE_2dp,  `,`, NR, `,`, UR, `,`, GB, `,`, LU, `,`, AM ])
	, write_flush

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read an XML tag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( xml_tag_line( [ NAME ] ), [ `<`, NAME, q0n(anything), `>` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( xml_tag_line( [ NAME, VALUE ] ), [
%=======================================================================

	`<`, NAME, q0n(anything), `>`

	, q10( tab )

	, VALUE

	, q10( tab )

	, `<`
] )

:-
	q_sys_is_string( VALUE )

. %end%

%=======================================================================
i_line_rule_cut( xml_tag_line( [ NAME, VARIABLE ] ), [
%=======================================================================

	`<`, NAME, q0n(anything), `>`

	, q10( tab )

	, READ_VARIABLE

	, q0n( [ tab, READ_MORE_VARIABLE ] )

	, q10( tab )

	, `<`

	, trace( [ VARIABLE_NAME, VARIABLE ] )
] )

:-

	q_sys_is_atom( VARIABLE )
	
	, READ_VARIABLE =.. [ VARIABLE, s ]

	, READ_MORE_VARIABLE =.. [ append, READ_VARIABLE, ` `, `` ]

	, sys_string_atom( VARIABLE_NAME, VARIABLE )

. %end%


%=======================================================================
i_user_check( get_sales_data, TP, SPEEDY, LOCATION, AM )
:-
	sales_lookup(TP, SPEEDY, LOCATION, AM)
.
%=======================================================================
i_user_check( get_rail_data, NR, UR, GB, LOCATION, AM )
:-
	rail_lookup(NR, UR, GB, LOCATION, AM)
.
%=======================================================================
i_user_check( get_tp_ship_to, TP, LOCATION )
:-
	q_sys_sub_string( TP, 3, _, TPX )
	, sales_lookup(TPX, _, LOCATION, _)
.
%=======================================================================
%=======================================================================
i_user_check( get_speedy_ship_to, SPEEDY, LOCATION )
:-
	q_sys_sub_string( SPEEDY, 3, _, SPX )
	, sales_lookup(_, SPX, LOCATION, _)
.
%=======================================================================
i_user_check( get_netrail_ship_to, NETRAIL, LOCATION )
:-
	q_sys_sub_string( NETRAIL, 3, _, NRX )
	, rail_lookup(NRX, _, _, LOCATION, _)
.
%=======================================================================
i_user_check( get_unipart_ship_to, UNIPART, LOCATION )
:-
	q_sys_sub_string( UNIPART, 3, _, UPX )
	, rail_lookup(_, UPX, _, LOCATION, _)
.
%=======================================================================
i_user_check( get_graybar_ship_to, GRAYBAR, LOCATION )
:-
	q_sys_sub_string( GRAYBAR, 3, _, GBX )
	, rail_lookup(_, _, GBX, LOCATION, _)
.


%=======================================================================
% PROD

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
sales_lookup_test( `11238613`, `11238602`, `TGB0200408`, `AM Jeremy Ratcliffe`).
sales_lookup_test( `11238614`, `11238603`, `TGB0100405`, `AM Chris Jordan`).
sales_lookup_test( `11238615`, `11238604`, `TGB0200501`, `AM Tom Clayton`).

%=======================================================================
% PROD

rail_lookup( `Netrai1 Ship-to`, `Unipart Ship-to`, `Graybar Ship-to`, `Territory`, `Account Manager`).
rail_lookup( `21009924`, `19621590`, `22119538`, `TGB0500101`, `AM Lee Taylor`).
rail_lookup( `21009969`, `20691581`, `22119539`, `TGB0500102`, `AM Richard Kirman`).
rail_lookup( `21363697`, `22038023`, `22119540`, `TGB0500103`, `AM Chris Denyer`).
rail_lookup( `22038114`, `22038024`, `22119616`, `TGB0500106`, `AM Dipti Dodeja`).
rail_lookup( `22046392`, `22038025`, `22119617`, `TGB0500107`, `AM Paul Alexander`).

%=======================================================================
% TEST

rail_lookup_test( `Netrai1 Ship-to`, `Unipart Ship-to`, `Graybar Ship-to`, `Territory`, `Account Manager`).
rail_lookup_test( `21009924`, `19621590`, `22119538`, `TGB0500101`, `AM Lee Taylor`).
rail_lookup_test( `21009969`, `20691581`, `22119539`, `TGB0500102`, `AM Richard Kirman`).
rail_lookup_test( `21363697`, `22038023`, `22119540`, `TGB0500103`, `AM Chris Denyer`).
rail_lookup_test( `22038114`, `22038024`, `22119616`, `TGB0500106`, `MA Dipti Dodeja`).
rail_lookup_test( `22046392`, `22038025`, `22119617`, `TGB0500107`, `AM Paul Alexander`).


%=======================================================================
i_user_check( read_cache_amount, LOOKUP, LOCATION, VALUE )
:-
	string_to_lower( LOCATION, LL)
	, lookup_cache(`hilti_sales`, LOOKUP,  LL, `amount`,  VALUE )
.
%=======================================================================
%=======================================================================
i_user_check( write_cache_amount, LOOKUP, LOCATION, VALUE )
:-
	set_cache(`hilti_sales`, LOOKUP, LOCATION, `amount`, VALUE )
	, save_cache
.
%=======================================================================

%=======================================================================
i_user_check( set_cache_count, LOCATION, COUNT )
:-
	set_cache(`hilti_sales`, `count`, LOCATION, `value`, COUNT )
	, save_cache
.
%=======================================================================

%=======================================================================
ii_rule_list( [
%=======================================================================

     get_list( [ LIST ] )

     , apply_list( [ LIST ] )
] ).

%=======================================================================
i_rule( get_list( [ LOOKUP, LIST ] ), [ check( i_user_check( get_list, LOOKUP, LIST ) ) ] ).
%=======================================================================

%=======================================================================
i_user_check( get_list, LOOKUP, LIST )
%-----------------------------------------------------------------------
:- 	lookup_cache_list( `hilti_sales`, LOOKUP, `amount`, LIST ).
%=======================================================================

%=======================================================================
i_rule( apply_list( [ LIST ] ), RULES )
%=======================================================================

:-

     convert_list_to_rules( LIST, RULES )

.

%=======================================================================
convert_list_to_rules( [], [] ).
%=======================================================================
convert_list_to_rules( [ cache( A, B ) | T_IN ], [ write_to_line( [ A, B ] ) | T_OUT ] ) :- !, convert_list_to_rules( T_IN, T_OUT ).
%=======================================================================


