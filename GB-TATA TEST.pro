%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TATA-HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( tata_rs_rules, `28 November 2012` ).

i_pdf_parameter( direct_object_mapping, 0 ).


i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 	 set( purchase_order )

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-TATA` )

	, supplier_registration_number( `P11_100` )

	, currency( `4400` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `10752895` )

%	, customer_comments( `Customer Comments` )
	, customer_comments( `` )

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	, get_delivery_details

	, get_buyer_details

%	, get_invoice_to_details

%	, get_supplier_address

	, get_order_number

	, get_order_date

%	, get_delivery_date

	, get_buyer_contact

%	, get_buyer_contact_2

	, get_invoice_lines

	, add_delivery_line

	, [qn0(line), invoice_total_line ]

	, [qn0(line), total_net_line ]

	, [ q0n(line), carriage_net_line]

	, gen_get_from_cache_at_end

	, gen_set_cache
] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details( [ delivery_left_margin, delivery_start_line, delivery_party1, delivery_contact,
					delivery_street, delivery_address_line, delivery_city, delivery_state, delivery_postcode,
					delivery_end_line ] )

	, delivery_country_code(`GBR`)

	, or([ with(delivery_contact) , get_delivery_contact ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	read_ahead( delivery_left_margin )

	, `delivery`, `address`, `:`	

	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 5, 5 ) )
	

] ).


%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [ with(delivery_postcode)

	, [`incoterms`, `:` ]

	] )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	without(delivery_contact)

	, q0n(up)

	, delivery_start_line	

	, delivery_contact_line


] ).

%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	delivery_contact(s1)

	, check(delivery_contact(start) < -400)

	, trace( [ `delivery contact`, delivery_contact] )


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_buyer_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details( [ buyer_left_margin, read_ahead(buyer_start_line), buyer_party1, buyer_contact1,
					buyer_street, buyer_address_line, buyer_city, buyer_state, buyer_postcode,
					buyer_end_line ] )

	, buyer_country_code(`GBR`)

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( buyer_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	read_ahead( buyer_left_margin )

	, `invoices`, `should`, `be`

	, check( i_user_check( gen1_store_address_margin( buyer_left_margin ), buyer_left_margin(start), 5, 5 ) )
] ).


%=======================================================================
i_line_rule( buyer_end_line, [ 
%=======================================================================

	or( [ with(buyer_postcode)

	, [ `page` ]

	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIER ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_supplier_address, [ 
%=======================================================================

	supplier_party(`RS Components`)

	, supplier_address_line(`PO Box 99`)

	, supplier_city(`Corby`)

	, supplier_state(`Northamptonshire`)

	, supplier_postcode(`NN179RS`)

	, supplier_country_code(`GBR`)

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TO ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_invoice_to_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details( [ invoice_to_left_margin, invoice_to_start_line, invoice_to_party, invoice_to_contact,
					invoice_to_street, invoice_to_address_line, invoice_to_city, invoice_to_state, invoice_to_postcode,
					invoice_to_end_line ] )

	, invoice_to_country_code(`GBR`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( invoice_to_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 read_ahead( invoice_to_left_margin )

	,`invoices`, `should`, `be`, `submitted`, `to`, `:`

	, check( i_user_check( gen1_store_address_margin( invoice_to_left_margin ), invoice_to_left_margin(start), 5, 5 ) )
] ).


%=======================================================================
i_line_rule( invoice_to_end_line, [ 
%=======================================================================

	 with(invoice_to_postcode)


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q0n(line)

	, order_date_header_line

	, q01(line)

	, order_date_line


] ).


%=======================================================================
i_line_rule( order_date_header_line, [ 
%=======================================================================

	q0n(anything)

	, `date`, newline

] ).




%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	q0n(anything)

	, invoice_date(date), newline

	, trace( [ `invoice date`, invoice_date] )

	

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_date, [ 
%=======================================================================

	q0n(line)

	, line_header_line_2

	, q01(line)

	, delivery_date_line


] ).




%=======================================================================
i_line_rule( delivery_date_line, [ 
%=======================================================================

	q0n(anything)

	, delivery_date(date)

	, trace( [ `delivery date`, delivery_date] )

	

]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q0n(line)

	, order_number_header_line

	, q01(line)

	, order_number_line

] ).



%=======================================================================
i_line_rule( order_number_header_line, [ 
%=======================================================================

	q0n(anything)

	, `order`, `number`, newline

] ).




%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	q0n(anything)

	, order_number(s1)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(line)

	, buyer_contact_header_line

	, q01(line)

	, buyer_contact_line

	, q01(line)

	, buyer_telephone_header_line

	, q01(line)

	, buyer_telephone_line

] ).



%=======================================================================
i_line_rule( buyer_contact_header_line, [ 
%=======================================================================

	q0n(anything)

	, `buyer`

	, newline	


] ).




%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	q0n(anything)

	, buyer_contact(s1)

	, check(buyer_contact(start) > 0)

	, trace( [ `buyer contact`, buyer_contact ] ) 

] ).

%=======================================================================
i_line_rule( buyer_telephone_header_line, [ 
%=======================================================================

	q0n(anything)

	, `telephone`

	, newline	


] ).



%=======================================================================
i_line_rule( buyer_telephone_line, [ 
%=======================================================================

	q0n(anything)

	, buyer_ddi(s1)

	, check(buyer_ddi(start) > 0)

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule_cut( get_buyer_contact_2, [ 
%=======================================================================

	q0n(line)

	, buyer_contact_line_2

	, q10(buyer_contact_email_line)

] ).


%=======================================================================
i_line_rule_cut( buyer_contact_line_2, [ 
%=======================================================================

	q0n(anything)

	, `non`, `-`, `commercial`, `contact`

	, or([ [buyer_contact(s), `:`], buyer_contact(s1) ])

	, q10([ read_ahead([q0n(anything), `@` ])

	, buyer_email(s1) ])

	, trace( [ `buyer contact`, buyer_contact ] ) 

	, trace( [ `buyer email`, buyer_email ] ) 


] ).

%=======================================================================
i_line_rule_cut( buyer_contact_email_line, [ 
%=======================================================================

	without(buyer_email)

	, read_ahead( [q0n(word), `@` ])

	, buyer_email(s1)

	, trace( [ `buyer email`, buyer_email ] ) 


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================
		
	`total`, `net`, `value`, `excl`, `.`, `vat`

	, q0n(anything)

	, total_invoice(d)
	
	, newline

	, trace( [ `invoice total`, total_invoice ] )

]).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================
		
	`total`, `net`, `value`, `excl`, `.`, `vat`

	, q0n(anything)

	, total_net(d)
	
	, newline

	, trace( [ `invoice net`, total_net ] )

]).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

	, or( [ [ get_line_invoice, q10( get_line_description ), q0n( [ peek_fails( or( [ get_line_invoice, line_end_line ] ) ), line ] ), product_code_line ]

 			, [ get_line_invoice, q10( get_line_description ) ]

 			, line
		] )

	] )

] ).




%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	or( [ [`the`, `item`, `covers`, `the`, `following`, `services`, `:` ]

		, [`no`, `.`, tab, `qty` ]

	])

] ).


%=======================================================================
i_line_rule_cut( product_code_line, [ 
%=======================================================================

	q0n(word)

	, or([ `rs`, `stock`, `part`, `catalogue`, `ref`,  `reference`, `cat` ,`number`, `no`, `code`, `material`, `your`, `product`, [`p`, `/`, `n`] ]) 

	, q0n(word)	

	, or([ 

		line_item( f([ begin, q(dec,3,4), q( other("-"),0,1 ), q(dec,3,4), q(alpha("AP"),0,1), end ]) )

		, line_item( f([ begin, q(dec,3,3), q( other("-"),0,1 ), q(dec,3,4), q(alpha("AP"),0,1), end ]) )

		, line_item( f([begin, q( alpha("DELUK"),5,5 ), q(dec,2,2), end]) )

	])


	, trace( [`line item`, line_item] )


] ).



%=======================================================================
ii_line_rule_cut( product_code_line, [ 
%=======================================================================

	or( [ [`product`, `code`], [`your`, `material`, `number`] 

		, [`RS`, or([ `stock`, `part`, `catalogue`, `ref`, `:` , `reference`, `cat` ,`number`, `no`]) ]
     ] )
	
	, q0n(word)	

	, or([ line_item( f([begin, q( [other("-"),dec],6,11 ), q(alpha("AP"),0,1), end]) )

		, line_item( f([begin, q( alpha("DELUK"),5,5 ), q(dec,2,2), end]) )

	])


	, trace( [`line item`, line_item] )


] ).




%=======================================================================
i_line_rule_cut( line_header_line_2, [ q0n(anything), `by`, tab, `(`, `excl`, `vat`, `)`, newline ] ).
%=======================================================================

%=======================================================================
i_line_rule( line_continuation_line, [ append(line_descr(s1), ` `,``), or([newline, tab]) ]).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [ or([ [`page`, word, `of`], [`total`, `net`, `value`, `excl`, `.`, `vat`] ]) ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================

	line_order_line_number(w1), tab

	, trace( [`line order line number`, line_order_line_number] )

	, line_quantity(d), tab

	, trace( [`line quantity`, line_quantity] )

	, q10( [ line_item_for_buyer(s1), trace( [`Buyer line item`, line_item_for_buyer] )

		, check(line_item_for_buyer(start) < -150) ])

	, qn0(anything)

	, tab, line_net_amount(d)

	, trace( [`line net amount`, line_net_amount] )

	, line_quantity_uom_code( `PCE` )

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_line_description, [
%=======================================================================

	line_descr(s1)

	, check(line_descr(start) < -400)

	, trace( [`line description`, line_descr] )

] ).



%=======================================================================
i_rule( add_delivery_line, [
%=======================================================================

	line_descr(`Delivery`)

	, line_net_amount(`0.01`) 

	, q0n(line)

	, delivery_address_header_line

	, q(0,8,line)

	, delivery_postcode_line

 	, line_order_line_number(data(`999`,[99,0,[0],0,0,0]))

	, line_quantity_uom_code( `PCE` )

	, trace( [`Delivery line`] )

] ).


%=======================================================================
i_line_rule( delivery_address_header_line, [ `delivery`, `address` ]).
%=======================================================================

%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	or([  [ `NN17`, line_item(`DELUK81`) ] 

		, [ `SA14`, line_item(`DELUK91`) ] 

	]) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( read_amount_and_set_sign( [ NAME ] ), [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

or( [
        [ test(credit_note), NEGATIVE_READ ]

        , [ peek_fails( test(credit_note)), NORMAL_READ ] 


  ] )
] )

:-

 NORMAL_READ =.. [ NAME, d ]

 , NEGATIVE_READ =.. [ NAME, n ]

 , VALUE_READ =.. [ NAME, VALUE ]

. %end%




