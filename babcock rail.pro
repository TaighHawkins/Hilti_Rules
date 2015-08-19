%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BABCOCK RAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( babcock_rail_test, `11 September 2014` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set( postcode_format, [ begin,
       q( alpha, 1, 1 ),
       q( alpha, 0, 1 ),
       q( dec, 1, 1 ),
       q( [ alpha, dec ], 0, 1 ),
       q( other, 0, 1 ),
       q( [ alpha, dec ], 1, 1 ),
       q( alpha, 2, 2 ),
       end
      ] )

,	set( postcode_format_second_word, [ begin,
       q( [ alpha, dec ], 1, 1 ),
       q( alpha, 2, 2 ),
       end
      ] )

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-BABRAIL` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10585599` ) ]    %TEST
	    , suppliers_code_for_buyer( `12218856` )                      %PROD
	]) ]


	, get_deliver_to_address

	%,[q0n(line), get_delivery_address ]

	%, get_delivery_details

	%,[q0n(line), get_delivery_postcode ]

	%,[q0n(line), get_delivery_contact ]

	, delivery_party(`Babcock Rail Limited`) 

	,[q0n(line), get_delivery_contact_two ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	, get_invoice_lines

	,[q0n(line), get_invoice_totals ]

] ).



%=======================================================================
i_section( get_deliver_to_address, [
%=======================================================================

	deliver_to_start

	, peek_ahead( gen_count_lines( [ end_of_deliver_to, COUNT ] ) )

	, deliver_to_details( COUNT, 280, 500 )

	, trace( [ `deliver to`, delivery_party, delivery_contact, delivery_address_line, delivery_city, delivery_county, delivery_postcode ] )

] ).

%=======================================================================
i_line_rule_cut( deliver_to_start, [
%=======================================================================

	q0n(anything), `DELIVER`, `to`, `:`, newline

	, trace([ `delivery header found` ])

] ).


%=======================================================================
i_line_rule_cut( deliver_to_details, [
%=======================================================================

	delivery_party_x( sf ), `,`

	, trace([ `delivery party x`, delivery_party_x ])

	, q(3,0, [ delivery_street(sf), `,` ] )

	, delivery_city(sf), q10(`,`)

	, trace([ `delivery city`, delivery_city ])

	, q10([ delivery_state_x(sf), check( i_user_check( gen_recognised_county, delivery_state_x ) ), q10(`,`) ])

	, delivery_postcode(pc)


] ).

%=======================================================================
i_line_rule( end_of_deliver_to, [ q0n(anything), `ordered`, `by` , `:`] ).
%=======================================================================

%=======================================================================
i_rule( end_of_delivery_thing, [ or( [ `,`, newline ] ) ] ).
%=======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	get_delivery_contact_header

	, q10([ q(0, 2, line), get_delivery_contact_line ])

] ).

%=======================================================================
i_line_rule( get_delivery_contact_header, [ 
%=======================================================================

	`contact`

	, trace([ `delivery contact header found`, delivery_contact ])

	, q10(delivery_contact(s))

	, trace([ `delivery contact`, delivery_contact ])

] ).

%=======================================================================
i_line_rule( get_delivery_contact_line, [ 
%=======================================================================
	
	without(delivery_contact)

	, q10(`fao`), delivery_contact(w), append(delivery_contact(w), ` `, ``)

	, check(delivery_contact(end) < 0 )

	, trace([ `delivery contact`, delivery_contact ])

	, q10(delivery_ddi(s))

	, trace([ `delivery ddi`, delivery_ddi ])

] ).

%=======================================================================
i_line_rule( get_delivery_contact_two, [ 
%=======================================================================
	
	without(delivery_contact)

	, `fao`, delivery_contact(s)	

	, trace([ `delivery contact`, delivery_contact ])

	, `(`, delivery_ddi(s), `)`

	, trace([ `delivery ddi`, delivery_ddi ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	,`name`, `:`, tab

	, buyer_contact(s1)

	, trace( [ `buyer contact`, buyer_contact ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	,`telephone`, `:`

	, buyer_ddi(s1)

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_fax , [ 
%=======================================================================

	q0n(anything)

	,`fax`, `:`, tab

	, buyer_fax(s1)

	, trace( [ `buyer_fax`, buyer_fax ] ) 

	, newline

] ).

%=======================================================================
i_rule( get_buyer_email , [ 
%=======================================================================

	get_buyer_email_header 

	, get_buyer_email_line 

] ).

%=======================================================================
i_line_rule( get_buyer_email_header , [ 
%=======================================================================

	q0n(anything)

	,`email`, `:`, tab

	, buyer_email(s1)

	, trace( [ `buyer email`, buyer_email ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_email_line , [ 
%=======================================================================

	append(buyer_email(s), ``, ``)

	, trace( [ `buyer email`, buyer_email ] ) 

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

	q0n(anything)

	,`order`, `no`, `:`

	, read_ahead( shipping_instructions(s1) )

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, tab, `date`, `:`

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

	, `date`, `:`
	
	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals , [
%=======================================================================

	`TOTAL`, `VALUE`, `OF`, `THIS`, `ORDER`, `EX`, `VAT`, `:`, `£`, tab

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

	, q10(line)

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `£`, tab, `Type`, `(`, `*`, `)`, tab, `Total`, `£`, tab, `£`, tab, `Ex`, `VAT`, `£`, tab, `Delivery`, `Date`,  newline ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Materials`, `to`, `be`, `delivered`

] ).

%=======================================================================
i_line_rule_cut( get_invoice_line, [
%=======================================================================

	line_order_line_number(w), `.`, word,  q10( tab )

	, trace([`line order line number`, line_order_line_number ])


	, or([  line_item(d)

		, [ read_ahead([`pads`]), line_item(`MISSING`) ]

		, read_ahead([ q0n(word),  line_item( f( [ begin, q(dec,4, 10), end ]) ) ])

		, line_item(`MISSING`)

		])

	, q10(tab), line_descr(s1), tab

%	, check(line_descr(start) > -400)

	, trace([`line descr`, line_descr ])

	, line_quantity(d), q10( tab )

	, trace([`line item`, line_item])

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(s1), tab

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, line_unit_amount_x(d)

	, trace([`line unit amount`, line_unit_amount_x ])

	, q0n(anything)

	, line_net_amount(d), q10( tab ), del_date(date)

	, or([ tab, newline ])
	

] ).
