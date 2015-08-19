%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CLAAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( claas, `26 August 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `DE-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

%	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	,or([ [ test(test_flag), suppliers_code_for_buyer( `10139340` ) ]   %TEST
	    , suppliers_code_for_buyer( `10139340` ) ])                  %PROD  

	,[q0n(line), delivery_party_line ]

	,[q0n(line), delivery_street_line ]

	,[q0n(line), delivery_city_line ]

	,[q0n(line), delivery_postcode_line ]

	,[q0n(line), get_buyer_contact]

	,[q0n(line), get_buyer_ddi]

	,[q0n(line), get_buyer_fax]

	,[q0n(line), get_buyer_email]

	,[q0n(line), get_order_number]

	,[q0n(line), get_order_date]

	,[q0n(line), customer_comments_line ]

	,[q0n(line), get_customer_comments ]

	,[q0n(line), customer_comments_line_two ]

	,[q0n(line), shipping_instructions_line ]

	,[q0n(line), get_shipping_instructions ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	,[q0n(line), get_invoice_lines ]

	,[q0n(line), invoice_total_line ]
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	`<`, `NAME2`, `>`

	, delivery_party(s)

	, q(6, 0 ,[tab, append(delivery_party(s), ` `, ``)])

	, trace([ `delivery party`, delivery_party ])

	, `<`, `/`
	
]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	`<`, `stras`, `>`

	, delivery_street(s)

	, q10([tab, append(delivery_street(s), ` `, ``)])

	, trace([ `delivery street`, delivery_street ])

	, `<`, `/`

]).

%=======================================================================
i_line_rule( delivery_city_line, [ 
%=======================================================================

	`<`, `ort01`, `>`

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])

	, `<`, `/`

]).

%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	`<`, `pstlz`, `>`

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, `<`, `/`

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

     retab([500]), `<`, `BNAME`, `>`

	, read_ahead([buyer_contact(s), `<`, `/`])

	, delivery_contact(s)

	, trace( [ `buyer contact`, buyer_contact ] ) 

	, `<`, `/`

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

     `<`, `telf1`, `>`

	, read_ahead([buyer_ddi(s), `<`, `/`])

	, delivery_ddi(s)

	, `<`, `/`

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

     `<`, `telfx`, `>`

	, read_ahead([buyer_fax(s), `<`, `/`])

	, delivery_fax(s)

	, `<`, `/`

	, trace( [ `buyer fax`, buyer_fax ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

     `<`, `telf2`, `>`

	, read_ahead( [ buyer_email(s), `<`, `/` ] )

	, delivery_email(s)

	, `<`, `/`

	, trace( [ `buyer email`, buyer_email ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

    `<`, `belnr`, `>`

	, order_number(s)

	, `<`, `/`

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

    `<`, `credat`, `>`

 	, read_ahead([ invoice_date( f( [ begin, q(dec,4,4), end, q(dec, 4,4) ]) ), append(invoice_date(`/`), ``,``) ])

	, read_ahead([ append(invoice_date( f( [ q(dec,4,4), begin, q(dec,2,2), end, q(dec,2,2) ]) ), ``, ``), append(invoice_date(`/`), ``, ``) ])

	, append(invoice_date( f( [ q(dec,6,6), begin, q(dec,2,2), end ]) ), ``, ``)

	, `<`, `/`

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	customer_comments_line_header

	, customer_comments_line_three

	, customer_comments_line_four

] ).

%=======================================================================
i_line_rule( customer_comments_line_header, [ 
%=======================================================================

    `<`, `ablad`, `>`

	, trace( [ `customer comments header found` ] ) 

] ).

%=======================================================================
i_line_rule( customer_comments_line_two, [ 
%=======================================================================

    `<`, `ablad`, `>`

	, append(customer_comments(s), `~`, ``)

	, `<`, `/`

	, trace( [ `customer comments`, customer_comments ] ) 

] ).

%=======================================================================
i_line_rule( customer_comments_line_three, [ 
%=======================================================================

    `<`, `telf1`, `>`

	, append(customer_comments(`Tel.`), `~`, ``)

	, append(customer_comments(s), ` `, ``)

	, `<`, `/`

	, trace( [ `customer comments`, customer_comments ] ) 

] ).

%=======================================================================
i_line_rule( customer_comments_line_four, [ 
%=======================================================================

    `<`, `telfx`, `>`

	, append(customer_comments(`FAX`), `~`, ``)

	, append(customer_comments(s), ` `, ``)

	, `<`, `/`

	, trace( [ `customer comments`, customer_comments ] ) 

] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

    `<`, `ilnnr`, `>`

	, customer_comments(s)

	, q(6, 0 ,[tab, append(customer_comments(s), ` `, ``)])

	, `<`, `/`

	, trace( [ `customer comments`, customer_comments ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	shipping_instructions_line_two

	, shipping_instructions_line_three

] ).

%=======================================================================
i_line_rule( shipping_instructions_line_two, [ 
%=======================================================================

    `<`, `ablad`, `>`

	, append(shipping_instructions(s), `~`, ``)

	, `<`, `/`

	, trace( [ `shipping instructions`, shipping_instructions ] ) 

] ).

%=======================================================================
i_line_rule( shipping_instructions_line_three, [ 
%=======================================================================

    `<`, `telf1`, `>`

	, append(shipping_instructions(`Tel.`), `~`, ``)

	, append(shipping_instructions(s), ` `, ``)

	, `<`, `/`

	, trace( [ `shipping instructions`, shipping_instructions ] ) 

] ).

%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

    `<`, `ilnnr`, `>`

	, shipping_instructions(s)

	, q(6, 0 ,[tab, append(shipping_instructions(s), ` `, ``)])

	, `<`, `/`

	, trace( [ `shipping instructions`, shipping_instructions ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

    `<`, `summe`, `>`

	, read_ahead(total_invoice(d))

	, total_net(d)

	, `<`, `/`

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_rule( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_rule, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `<`, `E1EDP01`, q10( tab ), `SEGMENT`, `=`, `"`, `1`, `"`, `>`,  newline ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`<`, `/`, `ORDERS05`, `>`,  newline

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_order_line_number_line

	, q(0, 2, line)

	, line_quantity_line

	, line_quantity_uom_line

	, q(0, 6, line)

	, line_net_amount_line

	, q(0, 8, line)

	, line_original_order_date_line

	, q(0, 4, line)

	, line_item_line

	, q(0, 4, line)

	, line_descr_line

] ).

%=======================================================================
i_line_rule_cut( line_order_line_number_line, [
%=======================================================================

    `<`, `posex`, `>`

	, line_order_line_number(d)

	, `<`, `/`

	, trace([ `line order line number`, line_order_line_number ])

] ).

%=======================================================================
i_line_rule_cut( line_quantity_line, [
%=======================================================================

    `<`, `menge`, `>`

	, line_quantity(s)

	, `<`, `/`

	, trace([ `line quantity`, line_quantity ])

] ).

%=======================================================================
i_line_rule_cut( line_quantity_uom_line, [
%=======================================================================

   	`<`, `menee`, `>`

	, line_quantity_uom_code(s)

	, `<`, `/`

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

] ).

%=======================================================================
i_line_rule_cut( line_net_amount_line, [
%=======================================================================

   	`<`, `netwr`, `>`

	, line_net_amount(d)

	, `<`, `/`

	, trace([ `line net amount`, line_net_amount ])

] ).

%=======================================================================
i_line_rule_cut( line_original_order_date_line, [
%=======================================================================

    `<`, `edatu`, `>`

 	, read_ahead([ line_original_order_date( f( [ begin, q(dec,4,4), end, q(dec, 4,4) ]) ), append(line_original_order_date(`/`), ``,``) ])

	, read_ahead([ append(line_original_order_date( f( [ q(dec,4,4), begin, q(dec,2,2), end, q(dec,2,2) ]) ), ``, ``), append(line_original_order_date(`/`), ``, ``) ])

	, append(line_original_order_date( f( [ q(dec,6,6), begin, q(dec,2,2), end ]) ), ``, ``)

	, `<`, `/`

	, trace([ `line original order date`, line_original_order_date ])

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

    `<`, `idtnr`, `>`

	, line_item(s)

	, `<`, `/`

	, trace([ `line item`, line_item ])

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

    `<`, `ktext`, `>`

	, line_descr(s)

	, q(10, 0 ,[tab, append(line_descr(s), ` `, ``)])

	, `<`, `/`

	, trace([ `line description`, line_descr ])

] ).