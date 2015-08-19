%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TELAMON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( telamon, `11 December 2013` ).

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
	  [ test(test_flag), suppliers_code_for_buyer( `11232647` ) ]    %TEST
	    , suppliers_code_for_buyer( `10793621` )                      %PROD
	]) ]

	, buyer_email( `TDGTelamonPO@telamon.com` )
	
	, delivery_email( `TDGTelamonPO@telamon.com` )

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

%	,[q0n(line), get_buyer_fax ]

%	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_delivery_ddi ]

%	,[q0n(line), get_delivery_fax ]

%	,[q0n(line), get_delivery_email ]

	,[q0n(line), get_order_number ]

%	,[q0n(line), get_append_order_number ]

	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
	,[q0n(line), shipping_instructions_line_1, line, q10(shipping_instructions_line_2)  ]

	,[q0n(line), shipping_condition_line ]

	,[q0n(line), get_ups_line ]

	, get_invoice_lines

	,[qn0(line), get_invoice_totals ]

%	, default_vat_rate(`19`)

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

	, q10(get_delivery_address_line)

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	q0n(anything)

	 ,`ship`, `to`, newline

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_party(s1)

	, check(delivery_party(start) > -100 )

	, trace([ `delivery party`, delivery_party ])

] ).

%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_address_line(s1)

	, check(delivery_address_line(start) > -100 )

	, trace([ `delivery address line`, delivery_address_line ])

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_street(s1)

	, check(delivery_street(start) > -100 )

	, trace([ `delivery street`, delivery_street ])

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_city(s), `,`

	, check(delivery_city(start) > -100 )

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(w)

	, trace([ `delivery state`, delivery_state ])

	, delivery_postcode(f([begin, q(dec,5,5), end]))

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

	`full`

	, buyer_contact(s1)

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	get_buyer_ddi_header

	, q(0, 7, line), get_buyer_ddi_line

] ).

%=======================================================================
i_line_rule( get_buyer_ddi_header, [ 
%=======================================================================

	`invoice`, `to`, `:`

	, trace([ `buyer ddi header found` ])

] ).

%=======================================================================
i_line_rule( get_buyer_ddi_line, [ 
%=======================================================================

	`(`

	, buyer_ddi(d)

	, `)`, append(buyer_ddi(`-`), ``, ``)

	, append(buyer_ddi(s1), ``, ``)

	, trace([ `buyer contact`, buyer_contact ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	`full`

	, delivery_contact(s1)

	, trace([ `delivery contact`, delivery_contact ])

] ).

%=======================================================================
i_rule( get_delivery_ddi, [ 
%=======================================================================

	get_delivery_ddi_header

	, q(0, 7, line), get_delivery_ddi_line

] ).

%=======================================================================
i_line_rule( get_delivery_ddi_header, [ 
%=======================================================================

	`invoice`, `to`, `:`

	, trace([ `delivery ddi header found` ])

] ).

%=======================================================================
i_line_rule( get_delivery_ddi_line, [ 
%=======================================================================

	`(`

	, delivery_ddi(d)

	, `)`, append(delivery_ddi(`-`), ``, ``)

	, append(delivery_ddi(s1), ``, ``)

	, trace([ `delivery ddi`, delivery_ddi ])

] ).


%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	 trace([`looking for email`]), buyer_email(FROM)
	, trace([ `buyer email`, buyer_email ])

] )

:-
	i_mail( from, FROM ),
	customer_domain( FROM )
.


%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	 delivery_email(FROM)
	, trace([ `delivery email`, delivery_email ])

] )

:-
	i_mail( from, FROM ),
	customer_domain( FROM )
.


customer_domain( Addr ) :- q_regexp_match( `.*telamon.com`, Addr, _ ).
customer_domain( Addr ) :- q_regexp_match( `.*cloudtrade.co.uk`, Addr, _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================
	
	q0n(anything)

	, `po`, `number`, `:`, tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( get_append_order_number, [ 
%=======================================================================

	q0n(anything)

	, `change`, `order`, `:`, tab

	, append(order_number(`_`), ``, ``)

	, append(order_number(s1), ``, ``)

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

	, `order`, `date`, `:`

	, invoice_date(date)

	, trace( [ `order date`, invoice_date ] ) 

	, newline

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	`phone`, `:`

	, q0n(anything)
	
	, customer_comments(s)

	, check(customer_comments(start) > 0 )

	, newline

	, trace( [ `customer comments`, customer_comments ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( shipping_instructions_line_1, [ 
%=======================================================================

	`fax`, `:`

	, q0n(anything)

	, or([ [tab, shipping_instructions(s1), check(shipping_instructions(start) > 0 )], newline ])

	, trace( [ `shipping instructions`, shipping_instructions ] )

]).


%=======================================================================
i_line_rule( shipping_instructions_line_2, [ 
%=======================================================================

	nearest(-150, 10, 10)

	, prepend( shipping_instructions(s1), ``, ` `)

	, trace( [ `shipping instructions`, shipping_instructions ] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING CONDITION LOGIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( shipping_condition_line, [ 
%=======================================================================

	shipping_condition_line_header

	, get_shipping_condition_line

]).

%=======================================================================
i_line_rule( shipping_condition_line_header, [ 
%=======================================================================

	`Buyer`, tab, `Ship`, `Via`, tab, `F`, `.`, `O`, `.`, `B`, tab, `Terms`,  newline

	, trace( [ `shipping condition header found` ] )

]).

%=======================================================================
i_line_rule( get_shipping_condition_line, [ 
%=======================================================================

	q10([ dummy(s), tab ])

	, or([ [`WILL`, `CALL`,  type_of_supply(`04`), cost_centre(`Collection_Cust`), contract_order_reference(`CPT`), buyers_code_for_location(`CARMEL`)]

	,[`UPSS`, `-`, `Gnd`, type_of_supply(`N4`), cost_centre(`HNA - Cust Acct`), contract_order_reference(`EXW`), set(need_ups_line) ]

	,[type_of_supply(`01`), cost_centre(`Standard`), contract_order_reference(`CPT`), buyers_code_for_location(`CARMEL`)] ])


]).

%=======================================================================
i_line_rule( get_ups_line, [ 
%=======================================================================

 	test(need_ups_line)

	, q0n(anything)

	, `ups`, q10(`#`)

	, buyers_code_for_location(s1)

	, newline

]).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	q0n(anything)

	,`order`, `total`, tab

	, read_ahead(total_net(d))

	, trace( [ `total net`, total_net ] )

	, total_invoice(d), newline

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

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line_one, get_invoice_line_two, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Description`, tab, `Ordered`, tab, `Received` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`*`, `*`, `*`, `Telamon`, `requires`, `confirmation`, `of`] , [`subtotal`, tab ] ])

] ).

%=======================================================================
i_rule( get_invoice_line_one, [
%=======================================================================

	get_values_line_one

	, get_descr_line_one

] ).



%=======================================================================
i_line_rule( get_values_line_one, [
%=======================================================================

	line_order_line_number(w), tab

	, read_ahead( my_item(w) ), trace([`item lookup`, my_item ])
	, check( i_user_check( get_telamon_quantity, my_item, SIZE, PACK ) )
	, trace([`line item in table`, my_item ])

	, line_item(d), q10(tab)

	, line_original_order_date_x(date), tab

	, my_quantity(d), tab
	, trace([`line quantity read`, my_quantity ])
	, check( i_user_check( gen_str_divide, my_quantity, SIZE, LQ1 ) )
	, check( i_user_check( gen_str_add, LQ1, `0.49`, LQ2 ) )
	, check( sys_calculate_str_round_0( LQ2, LQ3 ) )
	, line_quantity(LQ3)

	, trace([`line quantity`, line_quantity ])

	, received(d), tab

	, backord(d), q01(tab)

	, line_quantity_uom_code_x( f([ q(dec,0,3), begin, q(alpha("E"),1,1), q(alpha("A"),1,1), end ]) )

	, tab

	, trace([`line quantity uom code`, line_quantity_uom_code_x ])

	, unitamount(d), tab

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, newline

] ) :- telamon_quantity( ITEM, SIZE, PACK ).


%=======================================================================
i_rule( get_descr_line_one, [
%=======================================================================

	get_line_descr_line_one

	, q10(get_line_descr_second_line_one)

] ).

%=======================================================================
i_line_rule( get_line_descr_line_one, [
%=======================================================================

	line_descr(s1), newline	

] ).

%=======================================================================
i_line_rule( get_line_descr_second_line_one, [
%=======================================================================

	append(line_descr(s), ` `, ``)

	, q10([ tab, append(line_descr(s), ` `, ``) ])

	, newline	

] ).


%=======================================================================
i_rule( get_invoice_line_two, [
%=======================================================================

	get_values_line_two

	, get_descr_line_two
	
] ).

%=======================================================================
i_line_rule( get_values_line_two, [
%=======================================================================

	line_order_line_number(w),  tab

	, or([ line_item(s1), line_item(`Missing`) ]), q10(tab)

	, trace([`line item`, line_item ])

	, line_original_order_date_x(date), tab

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity ])

	, received(d), tab

	, backord(d), q01(tab)

	, line_quantity_uom_code_x(s1), tab

	, trace([`line quantity uom code`, line_quantity_uom_code_x ])

	, unitamount(d), tab

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, newline

] ).

%=======================================================================
i_rule( get_descr_line_two, [
%=======================================================================

	get_line_descr_line_two

	, q10(get_line_descr_second_line_two)

] ).

%=======================================================================
i_line_rule( get_line_descr_line_two, [
%=======================================================================

	line_descr(s1), newline	

] ).

%=======================================================================
i_line_rule( get_line_descr_second_line_two, [
%=======================================================================

	append(line_descr(s), ` `, ``)

	, q10([ tab, append(line_descr(s), ` `, ``) ])

	, newline	

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `TELAMON TECHNOLOGIES` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME1, `TELAMON TECHNOLOGIES` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU ), string_to_upper(NU, NAME1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



i_user_check( get_telamon_quantity, ITEM, SIZE, PACK ) :- telamon_quantity( ITEM, SIZE, PACK ).

telamon_quantity( `371807`, `20`, `BOX`).
telamon_quantity( `371808`, `20`, `BOX`).
telamon_quantity( `371810`, `10`, `BOX`).
telamon_quantity( `284908`, `20`, `BOX`).
telamon_quantity( `336427`, `50`, `BOX`).
telamon_quantity( `336428`, `25`, `BOX`).
telamon_quantity( `282509`, `25`, `BOX`).
telamon_quantity( `282568`, `50`, `BOX`).
telamon_quantity( `219909`, `100`, `BOX`).
telamon_quantity( `256019`, `1`, `BOX`).
telamon_quantity( `219917`, `100`, `BOX`).
telamon_quantity( `369664`, `10`, `BOX`).
telamon_quantity( `369643`, `10`, `BOX`).
telamon_quantity( `339590`, `10`, `BOX`).
telamon_quantity( `369623`, `50`, `BOX`).
telamon_quantity( `236993`, `4`, `BOX`).
telamon_quantity( `378288`, `20`, `BOX`).
telamon_quantity( `2030022`, `6`, `BOX`).
telamon_quantity( `2030021`, `10`, `BOX`).
telamon_quantity( `338725`, `12`, `BOX`).
telamon_quantity( `314721`, `12`, `BOX`).
telamon_quantity( `309760`, `20`, `BOX`).
telamon_quantity( `333583`, `20`, `BOX`).
telamon_quantity( `339611`, `100`, `PACKAGE`).
telamon_quantity( `86224`, `1400`, `BOX`).
telamon_quantity( `311617`, `2000`, `BOX`).
telamon_quantity( `67400`, `20`, `BOX`).
telamon_quantity( `373339`, `50`, `PACKAGE`).

telamon_quantity( `00371807`, `20`, `BOX`).
telamon_quantity( `00371808`, `20`, `BOX`).
telamon_quantity( `00371810`, `10`, `BOX`).
telamon_quantity( `00284908`, `20`, `BOX`).
telamon_quantity( `00336427`, `50`, `BOX`).
telamon_quantity( `00336428`, `25`, `BOX`).
telamon_quantity( `00282509`, `25`, `BOX`).
telamon_quantity( `00282568`, `50`, `BOX`).
telamon_quantity( `00219909`, `100`, `BOX`).
telamon_quantity( `00256019`, `1`, `BOX`).
telamon_quantity( `00219917`, `100`, `BOX`).
telamon_quantity( `00369664`, `10`, `BOX`).
telamon_quantity( `00369643`, `10`, `BOX`).
telamon_quantity( `00339590`, `10`, `BOX`).
telamon_quantity( `00369623`, `50`, `BOX`).
telamon_quantity( `00236993`, `4`, `BOX`).
telamon_quantity( `00378288`, `20`, `BOX`).
telamon_quantity( `002030022`, `6`, `BOX`).
telamon_quantity( `002030021`, `10`, `BOX`).
telamon_quantity( `00338725`, `12`, `BOX`).
telamon_quantity( `00314721`, `12`, `BOX`).
telamon_quantity( `00309760`, `20`, `BOX`).
telamon_quantity( `00333583`, `20`, `BOX`).
telamon_quantity( `00339611`, `100`, `PACKAGE`).
telamon_quantity( `0086224`, `1400`, `BOX`).
telamon_quantity( `00311617`, `2000`, `BOX`).
telamon_quantity( `0067400`, `20`, `BOX`).
telamon_quantity( `00373339`, `50`, `PACKAGE`).
