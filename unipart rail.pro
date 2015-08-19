%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - UNIPART RAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( unipart_rail_test, `23rd March 2015` ).

i_date_format( _ ).

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

	buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-UNIRAIL` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11234911` ) ]    %TEST
	    , suppliers_code_for_buyer( `12294655` )                      %PROD
	]) ]

%	, suppliers_code_for_buyer( `11234911` )   %TEST
%	, suppliers_code_for_buyer( `12294655` )   %PROD

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_delivery_contact]

	,[q0n(line), get_delivery_ddi_line ]

	,[q0n(line), get_delivery_email_line ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi_line ]

	,[q0n(line), get_buyer_email_line ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	, [ q0n(line), ship_to_line ]

	, get_invoice_lines

	,[q0n(line), get_invoice_totals ]

%	, or([ test(test_flag), test_delay_rule, set_delay_rule ])

] ).


%=======================================================================
i_line_rule( ship_to_line, [
%=======================================================================

		q0n(anything), `DN1`, `1QY`, or([ tab, newline ])

		,trace([`getting lowest location`])

		, check( i_user_check( get_lowest_location_by_customer( `rail`, LOCATION ) ) )

		,trace([`found lowest location`, LOCATION ])

		, sales_location(LOCATION)

		,trace([`allocated lowest location`, sales_location ])

		,  or([ 
		  [ test(test_flag), check(i_user_check( get_ship_to_test, NR, UR, LOCATION ) ) ]						%TEST
	    		, [ peek_fails(test(test_flag)), check(i_user_check( get_ship_to, NR, UR, LOCATION ) )	]			%PROD
		]) 

		,delivery_note_number(UR)
		, trace([`ship to`, delivery_note_number]) 
	
]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  get_delivery_header_line

	, q(0, 2, line)

	, get_delivery_party_line

	, get_delivery_dept_line

	, or([ [ co_line, get_delivery_street_line, up, up, get_delivery_street_line, line, q01(get_delivery_street_line) ]

	, q(3,0,get_delivery_street_line) ])

	, get_delivery_city_line

	, q10(get_delivery_state_line)

	, get_delivery_postcode_line
	 
] ).

%=======================================================================
i_line_rule( co_line, [
%=======================================================================
 
	 q0n(anything)

	, `c`, `/`, `o`, q0n(word), newline

] ).


%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	 q0n(anything)

	, `should`, `be`, `delivered`, `to`, `:`, newline

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
	
	q0n(anything) 

	, delivery_party(s1)

	, check(delivery_party(start) > -70 )

	, trace([ `delivery party`, delivery_party ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_dept_line, [
%=======================================================================
	
	q0n(anything) 

	, delivery_dept(s1)

	, check(delivery_dept(start) > -70 )

	, trace([ `delivery dept`, delivery_dept ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
	
	q0n(anything) 

	, delivery_street(s1)

	, check(delivery_street(start) > -70 )

	, trace([ `delivery street`, delivery_street ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_street_line_two, [
%=======================================================================
	
	q0n(anything) 

	, delivery_street(s1)

	, check(delivery_street(start) > -70 )

	, trace([ `delivery street`, delivery_street ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_city_line, [
%=======================================================================
	
	q0n(anything) 

	, q10([ delivery_street(sf), `,` ]) , delivery_city(s1)

	, check(delivery_city(start) > -70 )

	, trace([ `delivery city`, delivery_city ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_state_line, [
%=======================================================================
	
	q0n(anything) 

	, delivery_state_x(sf), check( i_user_check( gen_recognised_county, delivery_state_x ) )

	, check(delivery_state_x(start) > -70 )

	, trace([ `delivery state`, delivery_state ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_line, [
%=======================================================================
	
	q0n(anything) 

	, delivery_postcode(pc)

	, check(delivery_postcode(start) > -70 )

	, trace([ `delivery postcode`, delivery_postcode ])

	, q10( `.` ), newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	get_delivery_contact_header

	, get_delivery_contact_line

] ).

%=======================================================================
i_line_rule( get_delivery_contact_header, [ 
%=======================================================================

	`Should`, `you`, `have`, `any`, `queries`, `with`, `this`, `purchase`, `order`, `please`, `contact`, `:`,  newline

	, trace([ `delivery contact header found`, delivery_contact ])

] ).

%=======================================================================
i_line_rule( get_delivery_contact_line, [ 
%=======================================================================
	
	delivery_contact(s1)

	, check(delivery_contact(end) < -50 )

	, trace([ `delivery contact`, delivery_contact ])

] ).

%=======================================================================
i_line_rule( get_delivery_ddi_line, [ 
%=======================================================================
	
	q0n(anything)

	, `tel`, `.`, tab

	, delivery_ddi(s1)

	, trace([ `delivery ddi`, delivery_ddi ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_email_line, [ 
%=======================================================================
	
	q0n(anything)

	, `fax`, `.`, tab

	, delivery_email(s1)

	, trace([ `delivery email`, delivery_email ])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	get_buyer_contact_header

	, get_buyer_contact_line

] ).

%=======================================================================
i_line_rule( get_buyer_contact_header, [ 
%=======================================================================

	`Should`, `you`, `have`, `any`, `queries`, `with`, `this`, `purchase`, `order`, `please`, `contact`, `:`,  newline

	, trace([ `buyer contact header found`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================
	
	buyer_contact(s1)

	, check(buyer_contact(end) < -50 )

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_ddi_line, [ 
%=======================================================================
	
	q0n(anything)

	, `tel`, `.`, tab

	, buyer_ddi(s1)

	, trace([ `buyer ddi`, buyer_ddi ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_email_line, [ 
%=======================================================================
	
	q0n(anything)

	, `fax`, `.`, tab

	, buyer_email(s1)

	, trace([ `buyer email`, buyer_email ])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`purchase`, `order`, `no`, `.`

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	q0n(anything)

	,`date`
	
	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date] )

	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals , [
%=======================================================================

	`Total`, `Net`, `Value`, `(`, `Excl`, `.`, `VAT`, `)`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Date`, tab, `Cat`, tab, `(`, `GBP`, `)`,  newline ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Total`, `Net`, `Value`, `(`, `Excl`, `.`, `VAT`, `)`, tab

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	get_line_values_line

%	, q10( read_ahead( [ q(0, 10, line), get_line_item_line ] ) )

] ).

%=======================================================================
i_line_rule( get_line_values_line, [
%=======================================================================

	line_order_line_number(d), tab

	, trace([`line order line number`, line_order_line_number ])

	, line_item_for_buyer(w)

	, trace([`line item for buyer`, line_item_for_buyer])

	, line_descr(sf)

	, q01([tab, append(line_descr(s), ` `, ``)]), q10(tab)

	, trace([`line descr`, line_descr ])

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(s1), tab

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, line_original_order_date(date), tab

	, q10([cat(d), tab])

	, or([ [ line_unit_amount(d), newline ]

	, [ line_unit(d), `/`, per(d) 

	, check( sys_calculate_str_divide(line_unit, per, UNIT_AMOUNT ) ) 

	, line_unit_amount(UNIT_AMOUNT), newline ] ])

	, trace([`line net amount`, line_net_amount ])


] ).

%=======================================================================
i_line_rule( get_line_item_line, [
%=======================================================================

	or([ [`hilti`, `part`, `number` ], [`part`, `no` ], [`hilti`, `part` ] ])

	, q10([ or([ `:`, `.` ]) ])

	, or([ peek_fails( test(line_item_found) )

	, [ read_ahead( new_line_item(s)), check(i_user_check( gen_gt, new_line_item(y), previous_line_item(y) )) ]

	])

	, read_ahead( previous_line_item(s) ), set(line_item_found)

	, line_item(s)

	, trace([`line item`, line_item ])

	, newline

] ).

%=======================================================================
i_user_check( get_lowest_location_by_customer( CUSTOMER, LOCATION ) )
%-----------------------------------------------------------------------
:-
%=======================================================================

	( lookup_cache_list( `hilti_sales`, CUSTOMER, `amount`, CUST_LIST )

		->	( reverse_pairs( CUST_LIST, CUST_NORMALISED_LIST )

				->	(	sys_sort( CUST_NORMALISED_LIST, [ cache( _, LOCATION ) | _ ] )
							
						;
						
						LOCATION = `not found`
					)

				;	LOCATION = `not legal`
			)

		;	LOCATION = `nothing found for customer at all`
	)
.

%=======================================================================
reverse_pairs( [], [] ).
%=======================================================================
reverse_pairs( [ cache( X, Y ) | T_IN ], [ cache( NUMBER_Y, X ) | T_OUT ] ) :- sys_string_number( Y, NUMBER_Y ), !, reverse_pairs( T_IN, T_OUT ).
%=======================================================================

%=======================================================================
i_user_check( get_ship_to, NR, UR, LOCATION )
:-
	string_to_upper(LOCATION, LU)
	, rail_lookup(NR, UR, LU, _)
.
%=======================================================================

%=======================================================================
i_user_check( get_ship_to_test, NR, UR, LOCATION )
:-
	string_to_upper(LOCATION, LU)
	, rail_lookup_test(NR, UR, LU, _)
.
%=======================================================================

%=======================================================================
% PROD

rail_lookup( `Netrai1 Ship-to's`, `Unipart Ship-to's`, `Territory`, `Account Manager`).
rail_lookup( `21009924`, `19621590`, `TGB0500101`, `AM Lee Taylor`).
rail_lookup( `21009969`, `20691581`, `TGB0500102`, `AM Richard Kirman`).
rail_lookup( `21363697`, `22038023`, `TGB0500103`, `AM Chris Denyer`).
rail_lookup( `22038114`, `22038024`, `TGB0500106`, `Vacant`).
rail_lookup( `22046392`, `22038025`, `TGB0500107`, `AM Paul Alexander`).

%=======================================================================
% TEST

rail_lookup_test( `Netrai1 Ship-to's`, `Unipart Ship-to's`, `Territory`, `Account Manager`).
rail_lookup_test( `21009924`, `19621590`, `TGB0500101`, `AM Lee Taylor`).
rail_lookup_test( `21009969`, `20691581`, `TGB0500102`, `AM Richard Kirman`).
rail_lookup_test( `21363697`, `22038023`, `TGB0500103`, `AM Chris Denyer`).
rail_lookup_test( `22038114`, `22038024`, `TGB0500106`, `Vacant`).
rail_lookup_test( `22046392`, `22038025`, `TGB0500107`, `AM Paul Alexander`).

