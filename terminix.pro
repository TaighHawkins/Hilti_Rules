%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TERMINIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( terminix, `29 July 2013` ).

i_date_format( 'm/d/y' ).

i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11232740` ) ]    %TEST
	    , suppliers_code_for_buyer( `10786171` )                      %PROD
	]) ]

	, type_of_supply(`01`), cost_centre(`Standard`)

	,[q0n(line), get_delivery_address ]

	,[q0n(line), delivery_street_2 ]

	,[q0n(line), get_buyer_contact ]

%	,[q0n(line), get_buyer_ddi ]

%	,[q0n(line), get_buyer_fax ]

%	,[q0n(line), get_buyer_email ]
	, buyer_email(`jmann@terminix.com`)

	,[q0n(line), get_delivery_contact ]

%	,[q0n(line), get_delivery_ddi ]

%	,[q0n(line), get_delivery_fax ]

%	,[q0n(line), get_delivery_email ]
	, delivery_email(`jmann@terminix.com`)

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
	,[q0n(line), shipping_instructions_line ]

	, check( i_user_check( gen_cntr_set, 20, 1 ) )
	, get_invoice_lines

	,[q0n(line), get_invoice_totals ]

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( delivery_street_2, [
%=======================================================================
 
	  delivery_header_line

	, del_street_2_line

	 
] ).

%=======================================================================
i_line_rule( delivery_header_line, [
%=======================================================================
 
	q0n(anything)

	, `ship`, `to`, `:`

	, trace([ `delivery header found ` ])

] ).


%=======================================================================
i_line_rule( del_street_2_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_par(s), delivery_street(`BRANCH `), append(delivery_street( f([begin, q(dec,3,4), end]) ),``, ``)

	, check(delivery_par(start) > -230 )

	, trace([ `delivery street`, delivery_street ])

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  get_delivery_header_line

	, get_delivery_party_line

	, get_delivery_street_line

	, q10(or([ get_continuation_line, line]))

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	q0n(anything)

	, `ship`, `to`, `:`

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_party(sf), q10([ `-`, num(d) ]), newline

	, check(delivery_party(start) > -230 )

	, trace([ `delivery party`, delivery_party ])

] ).

%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================
	
	q0n(anything) 

	, delivery_address_line(s1)

	, check(delivery_address_line(start) > -230 )

	, trace([ `delivery address line`, delivery_address_line ])

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_street(s1)

	, check(delivery_street(start) > -230 )

	, trace([ `delivery street`, delivery_street ])

] ).

%=======================================================================
i_line_rule( get_continuation_line, [
%=======================================================================
 
	q0n(anything), read_ahead(dummy(w))

	, check(dummy(start) > -230 )

	, append(delivery_street(s1), ` `, ``)

	, trace([ `delivery street`, delivery_street ])

] ).


%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_city(s), q10(tab)

	, check(delivery_city(start) > -230 )

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(f([ begin, q(alpha,2,2), end ]))

	, trace([ `delivery state`, delivery_state ])

	, delivery_postcode(w)

	, trace([ `delivery postcode`, delivery_postcode ])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`call`

	, buyer_contact(s), `@`

	, trace([ `buyer contact`, buyer_contact ])

	, buyer_ddi(s)

	, trace([ `buyer ddi`, buyer_ddi ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	 buyer_email(FROM)
	, trace([ `buyer email`, buyer_email ])

] )

:-
	i_mail( receivers, RECEIVERS ),
	sys_reverse( RECEIVERS, REV_REC ),
	q_sys_member( FROM, REV_REC ),
	string_to_lower( FROM, FROM_L ),
	customer_domain( FROM_L )
.

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	 buyer_email(FROM)
	, trace([ `buyer email`, buyer_email ])

] )

:-
	i_mail( from, FROM ),
	string_to_lower( FROM, FROM_L ),
	customer_domain( FROM_L )
.


%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	 delivery_email(FROM)
	, trace([ `delivery email`, delivery_email ])

] )

:-
	i_mail( receivers, RECEIVERS ),
	sys_reverse( RECEIVERS, REV_REC ),
	q_sys_member( FROM, REV_REC ),
	string_to_lower( FROM, FROM_L ),
	customer_domain( FROM_L )
.


%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	 delivery_email(FROM)
	, trace([ `delivery email`, delivery_email ])

] )

:-
	i_mail( from, FROM ),
	string_to_lower( FROM, FROM_L ),
	customer_domain( FROM_L )
.




customer_domain( Addr ) :- q_regexp_match( `.*terminix.com`, Addr, _ ).
customer_domain( Addr ) :- q_regexp_match( `.*cloudtrade.co.uk`, Addr, _ ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	`call`

	, delivery_contact(s), `@`

	, trace([ `delivery contact`, delivery_contact ])

	, delivery_ddi(s)

	, trace([ `delivery ddi`, delivery_ddi ])

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

	`po`, `number`, `:`

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	get_order_date_header

	, q(0, 8, line), get_order_date_line

]).

%=======================================================================
i_line_rule( get_order_date_header, [ 
%=======================================================================

	`po`, `number`, `:`

	, trace([ `order date header found` ])

]).

%=======================================================================
i_line_rule( get_order_date_line, [ 
%=======================================================================

	q0n(anything)

	, invoice_date(date(`m/d/y`))

	, trace([ `invoice date`, invoice_date ])

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	`progetto`, tab
	
	, customer_comments(s), tab

	, append(customer_comments(s), ` `, ``)

	, newline

	, trace( [ `customer comments`, customer_comments ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

	`progetto`, tab
	
	, shipping_instructions(s), tab

	, append(shipping_instructions(s), ` `, ``)

	, newline

	, trace( [ `shipping instructions`, shipping_instructions ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	q0n(line), total_net_line

	, q0n(line), total_vat_line

	, q0n(line), total_invoice_line

] ).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================

	`subtotal`, tab

	, total_net(d), newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( total_vat_line, [
%=======================================================================

	`tax`, tab

	, total_vat(d), newline

	, trace( [ `total vat`, total_vat ] )

] ).

%=======================================================================
i_line_rule( total_invoice_line, [
%=======================================================================

	`total`, tab

	, total_invoice(d)

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

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

	, qn0( [ peek_fails(line_end_line), get_a_line	] )

] ).


%=======================================================================
i_rule_cut( get_a_line, [
%=======================================================================

	get_invoice_values_line([ TERMINIX, PRICE, QTY ]), peek_fails(line_end_line)

	, or([ [ item_code_descr_line([ QTY ]), q10([  peek_fails(line_end_line), continuation_line ]) ]

		, [ descr_line, item_code_cont_line([ QTY ]) ]

		, [ descr_line, q10([  peek_fails(line_end_line), continuation_line ]), line_item(`MISSING`) ]
			
		])

	, append(line_descr(TERMINIX), `~Terminix Item # `, ``)

	, append(line_descr(PRICE), `~Terminix Unit Price on PO is `, ``)

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Item`, `/`, `Mfg`, `Number`, tab, `Due` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`=`, `=`, `=`, `=`

] ).


%=======================================================================
i_line_rule( get_invoice_values_line([ TERMINIX, PRICE, QTY ]), [
%=======================================================================

	line_no(w), tab

	, check(i_user_check(gen_same, line_no, TERMINIX))

	, line_original_order_date(date(`m/d/y`)), tab

	, trace([`line original order date`, line_original_order_date ])

	, line_qty(d)

	, check(i_user_check(gen_same, line_qty, QTY))

	, trace([`line quantity read`, line_qty ])

	, uom(w), tab

	, terminix_price(d), check(i_user_check(gen_same, terminix_price, PRICE))

	, q0n(anything)

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, newline

	, check( i_user_check( gen_cntr_inc_str, 20, LINE_NUMBER ) )

	, line_order_line_number(LINE_NUMBER)


] ).


%=======================================================================
i_line_rule( item_code_descr_line([ QTY ]), [
%=======================================================================

	read_ahead([ append(line_descr(s1), ` `, ``), q01([tab, append(line_descr(s1), ` `, ``) ]) , newline] )

	, or([ [ read_ahead( set_line_quantity([ QTY ]) ), line_item( f( [ begin, q(dec,4, 8), end ]) ) ]

		, [ qn0(word), read_ahead( set_line_quantity([ QTY ]) ), q01(tab), line_item( f( [ begin, q(dec,4, 8), end ]) ), newline ]

	])

	, trace([`line item`, line_item ])

] ).

%=======================================================================
i_line_rule( item_code_cont_line([ QTY ]), [
%=======================================================================

	read_ahead([ append(line_descr(s1), ` `, ``), q01([tab, append(line_descr(s1), ` `, ``) ]) , newline] )

	, or([ [ read_ahead( set_line_quantity([ QTY ]) ), line_item( f( [ begin, q(dec,4, 8), end ]) ) ]

		, [ qn0(word), read_ahead( set_line_quantity([ QTY ]) ), q01(tab), line_item( f( [ begin, q(dec,4, 8), end ]) ), newline ]

	])

	, trace([`line item`, line_item ])

] ).


%=======================================================================
i_rule_cut( set_line_quantity([ QTY ]), [
%=======================================================================

	or([ 

		[ `3484934`, check( i_user_check( gen_str_divide, QTY, `12`, NEW_QTY ) ), 	check( i_user_check( gen_str_add, NEW_QTY, `0.49`, Q1 ) ), check( sys_calculate_str_round_0( Q1, Q2 ) ), line_quantity(Q2) ]

		, [ `3484933`, check( i_user_check( gen_str_divide, QTY, `12`, NEW_QTY ) ), check( i_user_check( gen_str_add, NEW_QTY, `0.49`, Q1 ) ), check( sys_calculate_str_round_0( Q1, Q2 ) ), line_quantity(Q2) ]

		, [ line_quantity( QTY ) ]

	])

	, trace([`line quantity checked`, QTY, NEW_QTY, line_quantity])

] ).



%=======================================================================
i_line_rule( descr_line, [ line_descr(s1), newline ]).
%=======================================================================


%=======================================================================
i_line_rule( continuation_line, [ append( line_descr(s1), ` `, ``), newline ]).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `TERMINIX INTERNTNAL` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME1, `TERMINIX INTERNTNAL` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU ), string_to_upper(NU, NAME1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

