%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HARSCO FOR HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( harsco_rules, `18 December 2012` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 set( purchase_order )

	, left_margin_section

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-HARSCO` )

	, supplier_registration_number( `P11_100` )

	, currency( `4400` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

%	, suppliers_code_for_buyer( `12279813` )
	, suppliers_code_for_buyer( `11205168` )


%	, customer_comments( `Customer Comments` )
	, customer_comments( `` )

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	, get_delivery_details

	, get_delivery_location

	, get_order_number

	, get_order_date

	, get_delivery_contact

	, get_delivery_ddi

	, get_delivery_email

	, get_delivery_party

	, get_buyer_contact

	, get_buyer_ddi

	, get_buyer_email

	, get_invoice_lines

	, [qn0(line), invoice_total_line ]

%	, gen_get_from_cache_at_end

%	, gen_set_cache
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEFT MARGIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
% this must be done as the first section to ensure it runs first

i_section( left_margin_section, [ left_margin_line ] ).

%=======================================================================

%=======================================================================
i_line_rule( left_margin_line, [
%=======================================================================

	read_ahead( actual_left_margin )
	
	, `harsco`

	, check( i_user_check( gen_add, actual_left_margin( start ), 452, LM ) )

	, set( left_margin, LM )

	, trace( [`left margin`, LM] )
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details_without_names( [ delivery_left_margin, delivery_start_line,  
					delivery_street, delivery_address_line, delivery_city, delivery_state1, delivery_postcode,
					delivery_end_line ] )
	
	, delivery_dept(``)
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	q0n(anything),

	read_ahead( delivery_left_margin ),

	`delivery`, `address`, tab,

	check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 10, 10 ) )
] ).


%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [ with(delivery_postcode), `contact`	] )

]).


%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	q0n(line)

	, delivery_start_line

	, q(0, 6, line)

	, delivery_location_line

]).


%=======================================================================
i_line_rule( delivery_location_line, [ 
%=======================================================================

	q0n(anything)

	, `GB`

	, delivery_location(f([begin, q(dec, 4, 6 ), end ]))

	, trace( [ `delivery location`, delivery_location] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q0n(line)

	, order_date_line


] ).




%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	q0n(anything), `date`, tab, `:`

	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date] )

	, newline

]).


%=======================================================================
i_rule( get_required_date, [ 
%=======================================================================

	q0n(line)

	, required_date_line


] ).




%=======================================================================
i_line_rule( required_date_line, [ 
%=======================================================================

	q0n(anything), `required`, `by`, tab, `:`

	, line_original_order_date(date)

	, trace( [ `required_date`, line_original_order_date ] )

	, newline

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

	, order_number_line

] ).





%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================


	q0n(anything), `purchase`, `order`,  `number`

	, q0n(anything), `:`, q10(tab)

	, or([ [order_number(s), `/` ], order_number(s) ])

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

	, read_ahead(buyer_contact_line)

	, or([ buyer_contact_line_again, [line, buyer_contact_line_two ], line ])

	, trace( [ `buyer contact`, buyer_contact ] ) 

	, check( i_user_check( gen_string_to_upper, buyer_contact, CU  ) )

	, buyer_contact( CU )


] ).


%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	q0n(anything)

	, `order`, `originator`, tab, `:`

	, or([ [ buyer_contact(s), `,` ]

		, [ buyer_contact(w) ]

	])

	, trace( [ `buyer contact one`, buyer_contact ] ) 

] ).


%=======================================================================
i_line_rule( buyer_contact_line_again, [ 
%=======================================================================

	q0n(anything)

	, `order`, `originator`, tab, `:`

	, q0n(anything), or([ `miss`, `.` ])

	, prepend(buyer_contact(w), ``, ` `)

	, trace( [ `buyer contact one again`, buyer_contact ] ) 

] ).


%=======================================================================
i_line_rule( buyer_contact_line_two, [ 
%=======================================================================

	read_ahead(dummy(w1)), check(dummy(start) > 250)

	, prepend(buyer_contact(w1), ``, ` `)

	, trace( [ `buyer contact two`, buyer_contact ] ) 

] ).






%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(line)

	, buyer_ddi_line

] ).

%=======================================================================
i_line_rule( buyer_ddi_line, [ 
%=======================================================================

	q0n(anything)

	, `phone`, `:`, q10(tab)

	, buyer_ddi(s1), newline

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).


%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	q0n(line)

	, buyer_email_line

	, trace( [ `buyer email`, buyer_email ] ) 


] ).



%=======================================================================
i_line_rule_cut( buyer_email_line, [ 
%=======================================================================

	q0n(anything), `email`, `to`, `:`

	 , buyer_email(s1)

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	q0n(line)

	, read_ahead(delivery_contact_line)

	, or([ delivery_contact_line_again, [line, delivery_contact_line_two ], line ])

	, trace( [ `delivery contact`, delivery_contact ] ) 

	, check( i_user_check( gen_string_to_upper, delivery_contact, CU  ) )

	, delivery_contact( CU )


] ).


%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	q0n(anything)

	, `order`, `originator`, tab, `:`

	, or([ [ delivery_contact(s), `,` ]

		, [ delivery_contact(w) ]

	])

	, trace( [ `delivery contact one`, delivery_contact ] ) 

] ).


%=======================================================================
i_line_rule( delivery_contact_line_again, [ 
%=======================================================================

	q0n(anything)

	, `order`, `originator`, tab, `:`

	, q0n(anything), or([ `miss`, `.` ])

	, prepend(delivery_contact(w), ``, ` `)

	, trace( [ `delivery contact one again`, delivery_contact ] ) 

] ).


%=======================================================================
i_line_rule( delivery_contact_line_two, [ 
%=======================================================================

	read_ahead(dummy(w1)), check(dummy(start) > 250)

	, prepend(delivery_contact(w1), ``, ` `)

	, trace( [ `delivery contact two`, delivery_contact ] ) 

] ).



%=======================================================================
i_rule( get_delivery_ddi, [ 
%=======================================================================

	q0n(line)

	, delivery_ddi_line

] ).



%=======================================================================
i_line_rule( delivery_ddi_line, [ 
%=======================================================================

	q0n(anything)

	, `phone`, `:`, q10(tab)

	, delivery_ddi(s1), newline

	, check(delivery_ddi(start) > -200)

	, trace( [ `delivery ddi`, delivery_ddi ] ) 

] ).


%=======================================================================
i_rule( get_delivery_email, [ 
%=======================================================================

	q0n(line)

	, delivery_email_line

	, trace( [ `delivery email`, delivery_email ] ) 


] ).



%=======================================================================
i_line_rule_cut( delivery_email_line, [ 
%=======================================================================

	q0n(anything), `email`, `to`, `:`

	 , delivery_email(s1)

] ).




%=======================================================================
i_rule( get_delivery_party, [ 
%=======================================================================

	delivery_party(`HARSCO INFRASTRUCTURE`)

] ).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================
		
	q0n(anything), `gbp`, tab

	, read_ahead(total_net(d)), total_invoice(d)
	
	, newline

	, trace( [ `invoice total`, total_invoice ] )

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

		, or([  [  or( [ [ get_line_invoice_line_with_item_code ]

					, [ or([ read_ahead([ q(0, 3, line), look_for_item_code ]), line_item(`MISSING`) ]), get_line_invoice_line_without_item_code ]

					])
		
				, q(3, 0, line_continuation_line ) 

				, q10( read_ahead( [ first_line, get_required_date ] ) ) ]

			, line

			])

		] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `item`, tab ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [ q0n(anything), `gbp`, tab] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( get_line_invoice_line_with_item_code, [
%=======================================================================

	retab([ -400, -320, -25, 90, 160, 230, 320]) 

	, line_order_line_number(w1), tab

	, q10(sqb_code(s1)), tab 

	, line_descr(s1), tab

	, trace([`line descr`, line_descr])

	, line_item(s1), tab

	, trace( [`line item`, line_item] )

	, decode_line_uom_code, tab

	, line_quantity(d), tab

	, trace( [`line quantity`, line_quantity] )

	, q10(line_unit_amount(d)), tab

	, read_ahead(line_net_amount(d)), line_total_amount(d)

	, trace( [`line net amount`, line_net_amount] )

	, newline
] ).

%=======================================================================
i_line_rule_cut( get_line_invoice_line_without_item_code, [
%=======================================================================

	retab([ -400, -320, -25, 90, 160, 230, 320]) 

	, line_order_line_number(w1), tab

	, q10(sqb_code(s1)), tab 

	, line_descr(s1), tab

	, trace([`line descr`, line_descr])

	, q10(line_item(s1)), tab

	, trace( [`line item`, line_item] )

	, decode_line_uom_code, tab

	, line_quantity(d), tab

	, trace( [`line quantity`, line_quantity] )

	, q10(line_unit_amount(d)), tab

	, read_ahead(line_net_amount(d)), line_total_amount(d)

	, trace( [`line net amount`, line_net_amount] )

	, newline
] ).


%=======================================================================
i_rule_cut( decode_line_uom_code, [
%=======================================================================

	or([ [ `pack`, line_quantity_uom_code( `PK` ), line_price_uom_code( `PK` ) ]

		, [ word, line_quantity_uom_code( `PCE` ),  line_price_uom_code( `PCE` ) ]

	])

	
] ).


%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	read_ahead(dummy)

	, check(dummy(start) > -320), check(dummy(end) < 0 )

	, append(line_descr(s1),`, `, ``)

	, trace([`line descr`, line_descr])

	, newline
] ).


%=======================================================================
i_line_rule_cut( look_for_item_code, [
%=======================================================================

	q0n( anything )

	, line_item(f([begin, q(dec, 5, 8 ), end ])) 

	, check(line_item(start) > -320), check(line_item(end) < 0 )

	, trace([`line item`, line_item])


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




