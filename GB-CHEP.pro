%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CHEP FOR HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( chep_rules, `20 March 2015` ).

i_pdf_parameter( direct_object_mapping, 0 ).

i_date_format( _ ).

i_op_param( custom_e1edk02_segments, _, _, _, `true` ).
i_user_field( invoice, quotation_number, `Quotation Number` ).
custom_e1edk02_segment( `004`, quotation_number ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 set( purchase_order )

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-CHEP` )

	, supplier_registration_number( `P11_100` )

	, currency( `4400` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `14195577` )

%	, customer_comments( `Customer Comments` )
%	, customer_comments( `` )

%	, shipping_instructions( `Shipping Instructions` )
%	, shipping_instructions( `` )

	, get_order_number
	, get_quotation_number
	
	, [ with( quotation_number ), delivery_note_number( `12345676` ) ]

	, [ without( quotation_number), get_order_date ]
	
	, [ without( quotation_number), get_delivery_details ]

	, [ without( quotation_number), get_delivery_location ]

%	, get_supplier_details

	, [ without( quotation_number), get_buyer_details ]

%	, get_invoice_to_details

%	, get_delivery_date

	, [ without( quotation_number), get_delivery_contact ]

	, [ without( quotation_number), get_buyer_contact ]

	, get_invoice_lines

	, [ without( quotation_number), qn0(line), invoice_total_line ] 

	, [ without( quotation_number), qn0(line), total_net_line ] 

	, [ without( quotation_number), q0n(line), carriage_net_line]
	
	, [ with( quotation_number ), with( order_number ), force_result( `success` ) ]

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Expectation
%		Standardised format will change - Quotation number will move
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_rule( get_quotation_number, [ 
%=======================================================================

	q0n(line)

	, or([ hilti_short_quotation_rule
	
		, hilti_order_line

		, generic_vertical_details( [ [ `hilti`, `order`], start, quotation_number, s1, or([ tab, newline ]) ] )

	] )

] ).

%=======================================================================
i_rule( hilti_short_quotation_rule, [ 
%=======================================================================
	
	line_header_line
	
	, q(0,4,line)
	
	, hilti_short_quotation_line( 2, -450, -90 )

] ).

%=======================================================================
i_line_rule( hilti_order_line, [
%=======================================================================
	
	q0n(anything)
	
	, or( [ [ `hilti`, `order` ]
	
		, [ `(`, `Quote`, `)` ]
		
	] )
	
	, generic_item( [ quotation_number, sf, or([ tab, newline]) ] )

] ).

%=======================================================================
i_line_rule( hilti_short_quotation_line, [
%=======================================================================
	
	q0n(anything)
	
	, or( [ [ or( [ `Hilti`, `Q`, `quote`, `quotation` ] )
			, generic_item( [ quotation_number, [ q(alpha("Q"),0,1), begin, q(dec,9,9), end ] ] )
		]
		
		, generic_item( [ quotation_number, [ q(alpha("Q"),1,1), begin, q(dec,9,9), end ] ] )
		
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details( [ delivery_left_margin, delivery_start_line, delivery_party, delivery_contact,
					delivery_street, delivery_address_line, delivery_city, delivery_state, delivery_postcode,
					delivery_end_line ] )
	
	, delivery_dept(``)
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	q0n(anything),

	read_ahead( delivery_left_margin ),

	`Deliver`, `To`, `:`,

	check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 5, 5 ) )
] ).


%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [ with(delivery_postcode)

	, [q0n(anything), `united`, kingdom(w1), check(kingdom(start) > 0) ]

	, [`supplier`, `no` ]

	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_location, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	q0n(line)

	, delivery_start_line

	, delivery_location_line
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_location_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	nearest( delivery_left_margin(start), 10, 10)

	,  delivery_location_l(s)

	, check( i_user_check( gen_string_to_upper, delivery_location_l, DL  ) )

	,  delivery_location(DL)

	, trace( [ `delivery location`, delivery_location ] )
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIER ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_supplier_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details( [ supplier_left_margin, supplier_start_line, supplier_party1, supplier_contact,
					supplier_street, supplier_address_line, supplier_city, supplier_state, supplier_postcode,
					supplier_end_line ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( supplier_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	q0n(anything),

	read_ahead( supplier_left_margin ),

	`Supplier`, `:`,

	check( i_user_check( gen1_store_address_margin( supplier_left_margin ), supplier_left_margin(start), 5, 5 ) )
] ).


%=======================================================================
i_line_rule( supplier_end_line, [ 
%=======================================================================

	or( [ with(supplier_postcode)

	, [ q0n(anything), `united`, kingdom(w1), check(kingdom(start) < -400) ]

	, [`supplier`, `no` ]

	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_buyer_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details( [ buyer_left_margin, buyer_start_line, buyer_party1, buyer_contact,
					buyer_street, buyer_address_line, buyer_city, buyer_state, buyer_postcode,
					buyer_end_line ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( buyer_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	q0n(anything),

	read_ahead( buyer_left_margin ),

	`Bill`, `To`, `:`,

	check( i_user_check( gen1_store_address_margin( buyer_left_margin ), buyer_left_margin(start), 5, 5 ) )
] ).


%=======================================================================
i_line_rule( buyer_end_line, [ 
%=======================================================================

	or( [ with(buyer_postcode)

	, [ q0n(anything), `united`, kingdom(w1), check(kingdom(start) > -400) , check(kingdom(start) < 0) ]

	, [`supplier`, `no` ]

	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TO ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_invoice_to_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details( [ invoice_to_left_margin, invoice_to_start_line, invoice_to_party1, invoice_to_contact,
					invoice_to_street, invoice_to_address_line, invoice_to_city, invoice_to_state, invoice_to_postcode,
					invoice_to_end_line ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( invoice_to_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	q0n(anything),

	read_ahead( invoice_to_left_margin ),

	`please`, `send`,

	check( i_user_check( gen1_store_address_margin( invoice_to_left_margin ), invoice_to_left_margin(start), 5, 5 ) )
] ).


%=======================================================================
i_line_rule( invoice_to_end_line, [ 
%=======================================================================

	or( [ with(invoice_to_postcode)

	, [ q0n(anything), `united`, kingdom(w1), check(kingdom(start) > 150) ]

	, [`supplier`, `no` ]

	] )

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

	, `order`, `date`, tab

] ).




%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	q0n(anything)

	, invoice_date(date)

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

	, line_header_line

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

	q01(line)

	, order_number_header_line

	, q01(line)

	, order_number_line

] ).



%=======================================================================
i_line_rule( order_number_header_line, [ 
%=======================================================================

	`PO`, `number`
] ).




%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	order_number(s1)

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
] ).



%=======================================================================
i_line_rule( buyer_contact_header_line, [ 
%=======================================================================

	q0n(anything),

	`CHEP`, `Contact`, `&`, `Phone`, `No`, `.`,  newline
] ).




%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	q0n(anything)

	, tab

	, buyer_contact(s)

	, peek_ahead( `+` )

	, buyer_ddi( s1 )

	, newline

	, trace( [ `buyer contact and phone`, buyer_contact, buyer_ddi ] ) 

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

	, delivery_contact_header_line

	, q01(line)

	, delivery_contact_line

] ).



%=======================================================================
i_line_rule( delivery_contact_header_line, [ 
%=======================================================================


	`inco`, `terms`, tab, `receiving`, `contact`

] ).




%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	q0n(anything)

	, set( regexp_allow_partial_matching )

	, delivery_contact(f([begin,q([alpha,other],0,999), end]))

	, qn0( append( delivery_contact(f([begin,q([alpha,other],0,999), end])), ` `, `` ) )

	, q10( [ delivery_ddi(s1), trace( [ `delivery ddi`, delivery_ddi ] ) ] )

	, clear( regexp_allow_partial_matching )

	, check(delivery_contact(start) > -200)

	, check(delivery_contact(end) < 10)

	, trace( [ `delivery contact`, delivery_contact ] ) 

] ).










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================
		
	q0n(anything), `total`, `value`, `:`

	, q0n(anything)

	, total_invoice(d)
	
	, `gbp`

	, newline

	, trace( [ `invoice total`, total_invoice ] )

]).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================
		
	q0n(anything), `total`, `value`, `:`

	, q0n(anything)

	, total_net(d)

	, `gbp`

	, newline

	, trace( [ `total net`, total_net ] )

]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
ii_section( get_invoice_lines, [
%=======================================================================

	line_header_line, without( quotation_number) 

	, q0n( [

		peek_fails( line_end_line )
		
		, or( [
			line_invoice_with_explicit_part_number
		
			, [ line_invoice_without_explicit_part_number, clear( line_item_read_in_line ) ]

			, [ test( line_item_read_in_line ), line_extra_description_without_part_number ]

			, [ peek_fails( test( line_item_read_in_line ) ), line_extra_description_with_part_number ]

			, line
		] )
	] )

	, line_end_line
] ).


%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line, without( quotation_number) 

	, q(0,2,line)

	, q0n( or( [ get_line_invoice_with_explicit_part_number, get_line_invoice_without_explicit_part_number, line ] ) )

	, line_end_line
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `line`, q10(tab), `suppl` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [ `total`, `value`, `:`] ).
%=======================================================================

%=======================================================================
i_rule( get_line_invoice_with_explicit_part_number, [
%=======================================================================

	  trace( [ `in line with part` ] )
	
	, peek_fails( line_end_line )

	, line_invoice_with_explicit_part_number

	, qn0( [ peek_fails( line_end_line ), line_extra_description_without_part_number ] )
	
	, trace( [ `completed with part` ] )
] ).

%=======================================================================
i_rule( get_line_invoice_without_explicit_part_number, [
%=======================================================================

	  trace( [ `without part number in first line` ] )
	
	, peek_fails( line_end_line )

	, line_invoice_without_explicit_part_number

	, qn0( [ peek_fails( or( [ line_gbp_line, line_end_line ] ) ), line_extra_description_with_part_number ] )
	
	, q10( [ peek_fails( test( got_item ) ), test( missing_item ), line_item( `missing` ) ] )
	
	, clear( missing_item )
	
	, clear( got_item )
	
	, trace( [ `completed without part` ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_with_explicit_part_number, [
%=======================================================================

	retab( [ -450, -300, -90, 0, 210 ] ) 

	, word

	, tab

	, line_descr( `` ) % force start of new line, since previous one might not have had an item code

	, line_item(f( [ begin, q(dec,4,8), end ] ) )

	, set( line_item_read_in_line )

	, trace( [ `line item (explicit)`, line_item ] )

	, tab

	, append( line_descr(s1), ``, `` ), tab

	, trace([`line descr`, line_descr])

	, remainder_of_invoice_line
] ).

%=======================================================================
i_line_rule_cut( line_invoice_without_explicit_part_number, [
%=======================================================================

	retab( [ -450, -300, -90, 0, 210 ] ) 

	, word

	, tab

	, tab

	, line_descr(``)

	, append_line_descr_with_possible_part_number( [ `` ] ), tab

	, remainder_of_invoice_line
] ).

%=======================================================================
i_rule( remainder_of_invoice_line, [
%=======================================================================

	q0n(anything), tab

	, line_quantity(d)

	, trace( [`line quantity`, line_quantity] )

	, decode_line_uom_code

	, q0n(anything)

	, line_total_amount(d), `GBP`

	, newline

	, trace( [`line total amount`, line_total_amount] )
] ).


%=======================================================================
i_rule_cut( decode_line_uom_code, [
%=======================================================================

	or([ [ `M`, line_quantity_uom_code( `MTR` ) ]

		, [ line_quantity_uom_code( `PCE` ) ]

	])

] ).

%=======================================================================
i_line_rule_cut( line_extra_description_without_part_number, [
%=======================================================================

	  trace( [ `descr without part` ] )
	  
	, retab( [ -450, -300, 0 ] ) 

	, tab

	, tab

	, q10( [
		read_ahead( appended_line_descr(s1) )
	
		, append( line_descr(s1), ` `, `` )

		, trace( [`appended line descr`, appended_line_descr ] )
	] )
	
	, trace( [ `completed descr without part` ] )
] ).

%=======================================================================
i_line_rule_cut( line_extra_description_with_part_number, [
%=======================================================================

	  trace( [ `descr with part` ] )
	  
	, retab( [ -450, -300, 0 ] ) 

	, tab

	, tab

	, q10( append_line_descr_with_possible_part_number( [ ` ` ] ) )
	
	, trace( [ `completed descr with part` ] )
] ).

%=======================================================================
i_line_rule_cut( line_gbp_line, [
%=======================================================================

	 qn0(anything), `GBP`, qn0( anything), `GBP`, newline
	 
] ).

%=======================================================================
i_rule_cut( append_line_descr_with_possible_part_number( [ PREDECESSOR ] ), [
%=======================================================================

	or([

	[ read_ahead( [ q0n(word), line_item( f([begin, q( dec, 4, 8 ), end]) )
	
		, q0n(word), set( line_item_read_in_line ), trace( [ `line item (within descr)`, line_item ] ) ] )

		, set( got_item )
		
	]

	, set( missing_item )

	])

	, read_ahead( appended_line_descr(s1) ), append( line_descr(s1), PREDECESSOR, `` )

	, trace( [ `appended line descr`, appended_line_descr ] )
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




