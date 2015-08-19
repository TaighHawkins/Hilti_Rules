%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KOKOSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( kokosing, `01 April 2015` ).

i_format_postcode( X, X ).

i_date_format( 'm/d/y' ).

ii_pdf_parameter( same_line, 6 ).
i_pdf_parameter( graphical_clipping, 1 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	   [ q0n(line), kcc_supply_line ]
	  
	 , buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, type_of_supply(`01`)
	, cost_centre(`Standard`)

	, or( [ [ test( kcc ), 
		  or([ 
			  [ test(test_flag), suppliers_code_for_buyer( `21265736` ) ]    %TEST
				, suppliers_code_for_buyer( `21265736` )                      %PROD
		] ) ]

		, [ or([ 
			[ test(test_flag), suppliers_code_for_buyer( `10480258` ) ]    %TEST
				, suppliers_code_for_buyer( `10827861` )                      %PROD
		]) ]
	
	] )

%	, or([ [ q0n(line), delivery_address_street_first ], [q0n(line), get_delivery_address_one ], [q0n(line), get_delivery_address_two ] ])

	, get_delivery_address

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_delivery_contact ]

	, default_contacts

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

	, get_invoice_lines

	, total_vat(`0`)

	,[q0n(line), get_total_invoice ]




] ).



%=======================================================================
i_rule( default_contacts, [
%=======================================================================
 
	 q10([ without(delivery_contact), with(invoice, buyer_contact, BC)

		, delivery_contact( BC )

	])

		
	 , q10([ without(buyer_contact), with(invoice, delivery_contact, DC)

		, buyer_contact( DC  )

	])

	 
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KKC SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( kcc_supply_line, [
%=======================================================================
 
	q0n(anything)

	, `kcc`, `supply`
	
	, set( kcc )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS STREET FIRST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%=======================================================================
i_rule( delivery_address_street_first, [
%=======================================================================
 
	  get_delivery_header_line_two

	, del_street_line

	, get_delivery_party_line_two

	, del_party_cont

	, get_delivery_postcode_city_line_two
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line_two, [
%=======================================================================
 
	q0n(anything)

	, `ship`, `to`, `:`, newline

	, trace([ `delivery header found ` ])

] ).


%=======================================================================
i_line_rule( del_street_line, [
%=======================================================================

	 q0n(anything)
 
	 , read_ahead([ q0n(word), str(s1), newline, check(str(start) > 0) ])

	 , read_ahead([ q0n(word), or([ `ave`, `avenue` `street`, `road`, `blvd`, `route` ]) ])

	, delivery_street(s1), newline

	, trace([ `delivery street`, delivery_street ])


] ).



%=======================================================================
i_line_rule( del_party_cont, [
%=======================================================================
 
 	q0n(anything)
 
	 , read_ahead([ q0n(word), par(s1), newline, check(par(start) > 0) ])

	, append(delivery_party(s1), ` `, ``)

	, newline

	, trace([ `delivery party`, delivery_party ])


] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line_two, [
%=======================================================================
 
	q0n(anything)

	, delivery_city(s), `,`

	, check(delivery_city(start) > 0 )

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(w)

	, trace([ `delivery state`, delivery_state ])

	, delivery_postcode( f( [ begin, q(dec,5,5), q(other("-"),0,1), q(dec,0, 4), end ]) )

	, trace([ `delivery postcode`, delivery_postcode ])

] ).








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	 q0n(line)

	, or([ ship_to_line_with_street( [ STREET ]), [ ship_to_line_without_street,  q01( gen_line_nothing_here( [ 100, 20, 20 ] ) ), street_line([STREET]) ] ]) 

	, delivery_party(`KOKOSING CONST CO`)

	, or([ [ q(0,3,line), delivery_street_line ], delivery_street_x(STREET)   ])

	, q(0,4,line)

	, delivery_postcode_city_line 

	, delivery_street(STREET)

	 
] ).


%=======================================================================
i_line_rule_cut( ship_to_line_with_street([STREET]), [ 
%=======================================================================

	q0n(anything), `ship`, `to`, `:`, q10(tab)

	, del_str(s1), qn0([ tab, append(del_str(s1), ` `, ``) ])

	, check(i_user_check(gen_same, del_str, STREET))


 ]).



%=======================================================================
i_line_rule_cut( ship_to_line_without_street, [ q0n(anything), `ship`, `to`, `:`, newline ]).
%=======================================================================


%=======================================================================
i_line_rule_cut( street_line([STREET]), [
%=======================================================================
 
	nearest(100, 20, 20)

	, del_str(s1)

	, check(i_user_check(gen_same, del_str, STREET))

] ).



%=======================================================================
i_line_rule_cut( delivery_street_line, [
%=======================================================================
 
	nearest(100, 20, 20)

	, or([ read_ahead( house_number( f([ begin, q(dec,1,6), end, q(any,0,99) ]) ) )

		, read_ahead([ q0n(word), or([ `ave`, `avenue` `street`, `road`, `blvd`, `route` ]) ]) ])

	, delivery_street(s)

	, trace([ `delivery street`, delivery_street ])

	, newline

] ).


%=======================================================================
i_line_rule_cut( delivery_postcode_city_line, [
%=======================================================================
 
	nearest(100, 20, 20)

	, delivery_city(s), `,`

	, check(delivery_city(start) > 0 )

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(f([begin, q(alpha,2,2), end ]))

	, trace([ `delivery state`, delivery_state ])

	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )

	, trace([ `delivery postcode`, delivery_postcode ])

] ).




%=======================================================================
i_rule( get_delivery_address_one, [
%=======================================================================
 
	 get_delivery_party_line_one

	, q10(get_delivery_address_line_one)

	, get_delivery_street_line_one

	, q10(get_second_delivery_address_line_one)

	, get_delivery_postcode_city_line_one
	 
] ).

%=======================================================================
i_line_rule( get_delivery_party_line_one, [
%=======================================================================
 
	q0n(anything)

	, `ship`, `to`, `:`, tab

	, delivery_party(s1)

	, q01([ tab, append(delivery_party(s), ` `, ``) ])

	, check(delivery_party(start) > 0 )

	, trace([ `delivery party`, delivery_party ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_address_line_one, [
%=======================================================================
 
	q0n(anything)

	, delivery_address_line(s1)

	, check(delivery_address_line(start) > 0 )

	, trace([ `delivery address line`, delivery_address_line ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_street_line_one, [
%=======================================================================
 
	q0n(anything)

	, delivery_street(d)

	, append(delivery_street(s), ` `, ``)

	, check(delivery_street(start) > 0 )

	, trace([ `delivery street`, delivery_street ])

	, newline


] ).

%=======================================================================
i_line_rule( get_second_delivery_address_line_one, [
%=======================================================================
 
	q0n(anything)

	, or([ [ read_ahead([ read_ahead(dummy(w)), `kokosing` ])

	, check(dummy(start) > 0)

	, append(delivery_party(s1), ` `, ``) ]

	, [ delivery_address_line(s1)

	, check(delivery_address_line(start) > 0) ] ])

	, trace([ `delivery address party`, delivery_party ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line_one, [
%=======================================================================
 
	q0n(anything)

	, delivery_city(s), `,`

	, check(delivery_city(start) > 0 )

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(w)

	, trace([ `delivery state`, delivery_state ])

	, delivery_postcode( f( [ begin, q(dec,5,5), q(other("-"),0,1), q(dec,0, 4), end ]) )

	, trace([ `delivery postcode`, delivery_postcode ])

] ).

%=======================================================================
i_rule( get_delivery_address_two, [
%=======================================================================
 
	  get_delivery_header_line_two

	, get_delivery_party_line_two

	, q10(get_delivery_address_line_two)

	, get_delivery_street_line_two

	, get_delivery_postcode_city_line_two
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line_two, [
%=======================================================================
 
	q0n(anything)

	, `ship`, `to`, `:`, newline

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line_two, [
%=======================================================================
 
	q0n(anything)

	, delivery_party(s1)

	, q01([ tab, append(delivery_party(s), ` `, ``) ])

	, check(delivery_party(start) > 0 )

	, trace([ `delivery party`, delivery_party ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_address_line_two, [
%=======================================================================
 
	q0n(anything)

	, delivery_address_line(s1)

	, check(delivery_address_line(start) > 0 )

	, trace([ `delivery address line`, delivery_address_line ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_street_line_two, [
%=======================================================================
 
	q0n(anything)

	, delivery_street(s1)

	, check(delivery_street(start) > 0 )

	, trace([ `delivery street`, delivery_street ])

	, newline


] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line_two, [
%=======================================================================
 
	q0n(anything)

	, delivery_city(s), `,`

	, check(delivery_city(start) > 0 )

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(w)

	, trace([ `delivery state`, delivery_state ])

	, delivery_postcode( f( [ begin, q(dec,5,5), q(other("-"),0,1), q(dec,0, 4), end ]) )

	, trace([ `delivery postcode`, delivery_postcode ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`contact`, `:` 

	, read_ahead([ q(1,3,dummy(w)), q10([`jr`, `.`]), `,`, buyer_contact(w) ])

	, or([ [ append(buyer_contact(w), ` `, ``), `,` ], append(buyer_contact(w), ` `, ``) ])

	, trace([ `buyer contact`, buyer_contact ])


] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	,`phone`, `:`

	, buyer_ddi(s1)

	, trace([ `buyer ddi`, buyer_ddi ])

	, tab, `fax`, `:`, newline

] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	q0n(anything)

	,`fax`, `:`

	, buyer_fax(s1)

	, trace([ `buyer fax`, buyer_fax ])

	, newline

] ).


%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)
	
	, `email`, `:`

	, buyer_email(s1)

	, trace([ `buyer email`, buyer_email ])

	, tab, `phone`, `:`

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	q0n(anything)

	, `requested`, `by`, `:`

	, read_ahead([ [q(1,3,dummy(w)), q10([`jr`, `.`]), `,`, delivery_contact(w)] ])

	, or([ [ append(delivery_contact(w), ` `, ``), `,` ], append(delivery_contact(w), ` `, ``) ] )

	, trace([ `delivery contact`, delivery_contact ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`purchase`, `order`, `#`, `:`

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

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

	,`date`, `ordered`, `:`
	
	, or( [ date_capture_rule
		
		, [ parent, line, date_capture_line ]
		
	] )

]).

%=======================================================================
i_line_rule( date_capture_line, [ date_capture_rule ] ).
%=======================================================================
i_rule( date_capture_rule, [ 
%=======================================================================

	q0n(anything), invoice_date(date)

	, trace( [ `invoice date`, invoice_date] )

	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	`purchase`, `order`, `#`, `:`

	, q10(order_no(w)), tab
	
	, customer_comments(s1), tab

	, append(customer_comments(s1), ` `, ``)

	, newline

	, trace( [ `customer comments`, customer_comments ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_total_invoice, [
%=======================================================================

	`subtotal`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, trace( [ `total invoice`, total_invoice ] )

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

		, or([ get_invoice_line, line_continuation_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Item`, tab, `Material`, tab, `Vendor`, `Matl`, tab, `Description` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`subtotal`, tab, num(d), newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_line, [
%=======================================================================

	generic_item_cut( [ line_order_line_number, d ] )

	, or([ [material(s), tab, q0n(word), line_item(w), tab]

		, [q0n(word), line_item(d), tab]

		, [line_item(d), q0n(word), tab]

		, [q0n(word), line_item(w), tab]

		, line_item(`Missing`) 
	])

	, trace([`line item`, line_item])

	, line_descr(s), q10( tab )

	, trace([`line descr`, line_descr ])

	, oumcode(w), tab

	, trace([`uom found`])

	, generic_item_cut( [ line_quantity, d, tab ] )

	, append(line_descr(d), `~Kokosing Unit Price on PO is `, ``)

	, tab

	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	append(line_descr(s), ` `, ``), newline

	, trace([`appended description` ])

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `KOKOSING CONST CO` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME1, `KOKOSING CONST CO` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU ), string_to_upper(NU, NAME1).





