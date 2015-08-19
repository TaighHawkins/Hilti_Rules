%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SKANKSA USA CIVIL NORTHEAST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( skanska, `14 Oct 2013` ).

i_format_postcode( X, X ).

i_date_format( 'm/d/y' ).

i_orders05_idocs_e1edkt1(`0003`, header_note ).

i_user_field(invoice, header_note, `header note`).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`USADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ [ test(test_flag), suppliers_code_for_buyer( `11235582` ) ]    %TEST
	    
	, suppliers_code_for_buyer( `10856055` )                      %PROD
	
	]) ]

	,[q0n(line), get_suppliers_code_for_buyer ]

	, type_of_supply(`01`)

	, cost_centre(`Standard`)

%	,[q0n(line), get_delivery_address ]

% STRS2 is being hijacked for another field (!)

%	,[q0n(line), get_delivery_second_street ]

%	, [ peek_fails(test(job_name)), delivery_party(`SKANSKA CIVIL USA NORTHEAST`) ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_customer_comments ]

	,[q0n(line), get_customer_comments_two ]

	,[q0n(line), get_shipping_instructions ]

	, check( i_user_check( gen_cntr_set, 20, 1 ) )

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]

	, total_net(`0`)

	, total_vat(`0`)
	
%	, get_strange_strs2

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [
%=======================================================================
 
	get_shipping_instructions_header

	, get_shipping_instructions_line

] ).

%=======================================================================
i_line_rule( get_shipping_instructions_header, [
%=======================================================================
 
	`remarks`, newline

	, trace([`shipping_instructions header found`])

] ).

%=======================================================================
i_line_rule( get_shipping_instructions_line, [
%=======================================================================
 
	header_note(s1)

	, newline

	, trace([ `header note`, header_note ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_suppliers_code_for_buyer, [
%=======================================================================
 
	q0n(anything)

	, `Job`, `Name`, `:`, q01(tab)

	, `Job`, `024901`

	, suppliers_code_for_buyer(`19476725`)

	, delivery_note_number(`19537956`)

	, set(job_name)

	, trace([ `suppliers code for buyer`, suppliers_code_for_buyer ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	peek_fails(test(job_name))

	, delivery_header

	, q10([ q10(line), delivery_street_line ])

	, q10(delivery_street_line_cont)

	, q(0, 4, line)

	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_header, [ 
%=======================================================================

	`ship`, `to`, `:`

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	read_ahead(dummy(s1))

	, check(dummy(end) < -50 )

	, delivery_street(w)

	, check(delivery_street(end) < 0 )

	, append(delivery_street(s1), ` `, ``)

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( delivery_street_line_cont, [ 
%=======================================================================

	read_ahead(dummy(s1))

	, check(dummy(end) < -50 )

	, append(delivery_street(s1), ` `, ``)

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================
	
	delivery_city(s), `,`

	, trace([ `delivery city`, delivery_city ])

	, delivery_state(w), q10(tab)

	, trace([ `delivery state`, delivery_state ])

	, delivery_postcode(s)

	, trace([ `delivery postcode`, delivery_postcode ])

	, check(delivery_postcode(end) < 0 )

]).

%=======================================================================
iiii_rule( get_delivery_second_street, [ 
%=======================================================================

	peek_fails(test(job_name))

 	, get_delivery_second_street_line

 	, q10([ get_delivery_second_street_line_two, del_next_street_line

	, q(0,3,line), peek_ahead(delivery_postcode_city_line) ])

]).

%=======================================================================
iiii_line_rule( get_delivery_second_street_line, [ 
%=======================================================================

	`ship`, `to`, `:`

	, dummy(w), q10(dummy(d))

	, delivery_street(s1)

	, tab, `bill`, `to`

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
iiii_line_rule( del_next_street_line, [ 
%=======================================================================

	dummy(s1)

	, check(dummy(end) < -50 )

]).

%=======================================================================
iiii_line_rule( get_delivery_second_street_line_two, [ 
%=======================================================================

	read_ahead(dummy(s1))

	, check(dummy(end) < -50 )

	, append(delivery_street(s1), ` `, ``)

	, trace([ `delivery street`, delivery_street ])

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`ordered`, `by`, `:`

	, buyer_contact(s1)

	, newline

	, trace( [ `buyer contact`, buyer_contact] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	`att`, `:`, tab

	, delivery_contact(s1)

	, check(delivery_contact(end) < 0 )

	, trace( [ `delivery contact`, delivery_contact] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	, `pn`, `:`

	, read_ahead( order_number(s1) )

	, q10([ peek_fails(test(job_name)), wrap( delivery_location(w), `Job-`, `` ) ])

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_date, [ 
%=======================================================================

	q0n(anything)

	, `date`, `:`, tab

	, invoice_date(date)

	, newline

	, trace( [ `order date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	get_customer_comments_line

	, get_customer_comments_line_two

] ).

%=======================================================================
i_line_rule( get_customer_comments_line, [ 
%=======================================================================

	q0n(anything)

	, `job`, `name`, `:`

	, customer_comments(s1)

	, newline

	, trace( [ `customer_comments`, customer_comments ] ) 

] ). 

%=======================================================================
i_line_rule( get_customer_comments_line_two, [ 
%=======================================================================

	q0n(anything)

	, append(customer_comments(s1), ` `, ``)

	, newline

	, trace( [ `customer_comments`, customer_comments ] ) 

] ).

%=======================================================================
i_rule( get_customer_comments_two, [ 
%=======================================================================

	get_customer_comments_two_header

	, get_customer_comments_two_line

	, get_customer_comments_two_line_two

] ).

%=======================================================================
i_line_rule( get_customer_comments_two_header, [ 
%=======================================================================

	`job`, `site`

	, trace( [ `customer comments two header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_customer_comments_two_line, [ 
%=======================================================================

	append(customer_comments(s1), `~`, ``)

	, trace( [ `customer_comments`, customer_comments ] ) 

] ).

%=======================================================================
i_line_rule( get_customer_comments_two_line_two, [ 
%=======================================================================

	append(customer_comments(s1), ` `, ``)

	, trace( [ `customer_comments`, customer_comments ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`subtotal`, `:`, tab, `$`

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline

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

		, or([ invoice_line_rule_1

			, invoice_line_rule_2

			, invoice_line_rule_3

			, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 	`Freight`, `Terms`, `:`, `Delivered`, tab, `Ship` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`remarks`, newline

] ).

%=======================================================================
i_rule_cut( invoice_line_rule_1, [
%=======================================================================

	line_values_line

	, line_descr_line

	, check( i_user_check( gen_cntr_inc_str, 20, LINE_NUMBER ) )

	, line_order_line_number(LINE_NUMBER)

] ).


%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	frieght(d), q10(tab)

	, delivered(s)

	, hardware(s1), tab

	, line_quantity(d), tab

	, trace([ `line quantity`, line_quantity ])

	, quantity_uom(w), q10(tab)

	, read_ahead(line_descr(s1))

	, trace([ `line description`, line_descr ])

	, q0n(word), `hilti`, line_item(d)

] ).


%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	q0n(anything)

	, read_ahead([dummy(s1), newline])

	, check(dummy(start) > -145)

	, check(dummy(end) < 75)

	, append(line_descr(s1), ` `, ``)

	, newline


] ).


%=======================================================================
i_rule_cut( invoice_line_rule_2, [
%=======================================================================

	line_values_line_two

	, line_descr_line

	, check( i_user_check( gen_cntr_inc_str, 20, LINE_NUMBER ) )

	, line_order_line_number(LINE_NUMBER)

] ).


%=======================================================================
i_line_rule_cut( line_values_line_two, [
%=======================================================================

	frieght(d), q10(tab)

	, delivered(s)

	, hardware(s1), tab

	, line_quantity(d), tab

	, trace([ `line quantity`, line_quantity ])

	, quantity_uom(w), q10(tab)

	, read_ahead(line_descr(s1))

	, trace([ `line description`, line_descr ])

	, q0n(word), `no`, `.`, line_item(d)

] ).

%=======================================================================
i_rule_cut( invoice_line_rule_3, [
%=======================================================================

	line_values_line_3

	, q(3,0,[peek_fails(line_values_line_3), item_code_line ] )

	, check( i_user_check( gen_cntr_inc_str, 20, LINE_NUMBER ) )

	, line_order_line_number(LINE_NUMBER)

] ).


%=======================================================================
i_line_rule_cut( line_values_line_3, [
%=======================================================================

	frieght(d), q10(tab)

	, delivered(s)

	, hardware(s1), tab

	, line_quantity(d), tab

	, trace([ `line quantity`, line_quantity ])

	, quantity_uom(w), q10(tab)

	, line_descr(s1), tab, `$`

] ).


%=======================================================================
i_line_rule_cut( item_code_line, [
%=======================================================================

	q0n(anything)

	, read_ahead([dummy(s1), newline])

	, check(dummy(start) > -145)

	, check(dummy(end) < 75)

	, q10([ read_ahead([ q0n(word), or([ [`hilti`, line_item(d)], [`no`, `.`, line_item(d) ]  ])  ]) ])

	, append(line_descr(s1), ` `, ``)

	, newline

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Strange STRS2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_strange_strs2, [
%=======================================================================

	peek_fails(test(job_name))

	, q10( [ without( delivery_street ), delivery_street( `` ) ] ) % otherwise we will be feeding STRAS rather than STRS2

	, q0n( line )

	, pn_line

	, trace( [ `strange STRS2`, delivery_street ] )
] ).

%=======================================================================
i_line_rule( pn_line, [
%=======================================================================

	q0n( anything )

	, tab, `PN`, `:`

	, wrap( delivery_street(w1), `Job-`, `` )
	
	, `-`
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `SKANSKA CIVIL USA NORTHEAST` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME1, `SKANSKA CIVIL USA NORTHEAST` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU ), string_to_upper(NU, NAME1).



