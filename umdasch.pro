%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - UMDASCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( umdasch, `5 Aug 2013` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11205959` ) ]    %TEST
	    , suppliers_code_for_buyer( `10018984` )                      %PROD
	]) ]


%	, suppliers_code_for_buyer( `10018984` )  % PROD (SEE  BELOW)
%	, suppliers_code_for_buyer( `11205959` ) % TEST  (SEE BELOW)

%	, customer_comments( `Customer Comments` )
	
	, [ q0n(line), customer_comments_line ] 

	, [ q0n(line), shipping_instructions_line ] 

%	, shipping_instructions( `Shipping Instructions` )
%	, shipping_instructions( `` )

	,[q0n(line), get_delivery_party_line ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date_1 ]

	,[q0n(line), get_order_date_2 ]

	,[q0n(line), get_buyer_contact ]

	,[ q0n(line), get_general_original_order_date]

	, get_invoice_lines

	,[ q0n(line), get_invoice_totals]


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL ORIGINAL ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_general_original_order_date, [ 
%=======================================================================

	q0n(anything)

	, `Liefertermin`, or([ [ tab, `:`], [`:`, tab] ])

% read into due date, which isnt used in the Idocs XML, then use it on every line

	, due_date(date)
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( customer_comments_line, [ 
%=======================================================================

	customer_comments_header_line

	, get_customer_comments_line

	, q10(append_customer_comments_1)

	, q10(append_customer_comments_2)

	, q10(append_customer_comments_3)

] ).

%=======================================================================
i_line_rule( customer_comments_header_line, [ 
%=======================================================================

	`deliver`, `to`, `:`

	, trace( [ `customer comments header found` ] )

]).

%=======================================================================
i_line_rule( get_customer_comments_line, [ 
%=======================================================================

	customer_comments(s)

	, check(customer_comments(start) > -295 )

	, trace( [ `customer comments`,  customer_comments ] )

]).

%=======================================================================
i_line_rule( append_customer_comments_1, [ 
%=======================================================================

	q0n(anything)

	, read_ahead(dummy_1(s))

	, check(dummy_1(start) > -295 )

	, append(customer_comments(s), ` `, ``)

]).

%=======================================================================
i_line_rule( append_customer_comments_2, [ 
%=======================================================================

	q0n(anything)

	, read_ahead(dummy_2(s))

	, check(dummy_2(start) > -295 )

	, append(customer_comments(s), ` `, ``)

]).

%=======================================================================
i_line_rule( append_customer_comments_3, [ 
%=======================================================================

	q0n(anything)

	, read_ahead(dummy_3(s))

	, check(dummy_3(start) > -295 )
	
	, append(customer_comments(s), ` `, ``)


]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( shipping_instructions_line, [ 
%=======================================================================

	shipping_instructions_header_line

	, get_shipping_instructions_line

	, q10(append_shipping_instructions_1)

	, q10(append_shipping_instructions_2)

	, q10(append_shipping_instructions_3)

]).

%=======================================================================
i_line_rule( shipping_instructions_header_line, [ 
%=======================================================================

	`deliver`, `to`, `:`

	, trace( [ `shipping instructions`,  shipping_instructions ] )

]).

%=======================================================================
i_line_rule( get_shipping_instructions_line, [ 
%=======================================================================

	shipping_instructions(s)

	, check(shipping_instructions(start) > -295 )

	, trace( [ `shipping instructions`,  shipping_instructions ] )

]).

%=======================================================================
i_line_rule( append_shipping_instructions_1, [ 
%=======================================================================

	q0n(anything)

	, read_ahead(dummy_4(s))

	, check(dummy_4(start) > -295 )

	, append(shipping_instructions(s), ` `, ``)

]).

%=======================================================================
i_line_rule( append_shipping_instructions_2, [ 
%=======================================================================

	  q0n(anything)

	, read_ahead(dummy_5(s))

	, check(dummy_5(start) > -295 )

	, append(shipping_instructions(s), ` `, ``)

]).

%=======================================================================
i_line_rule( append_shipping_instructions_3, [ 
%=======================================================================
	
	q0n(anything)

	, read_ahead(dummy_6(s))

	, check(dummy_6(start) > -295 )

	, append(shipping_instructions(s), ` `, ``)

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_party_line, [ 
%=======================================================================

	`Lieferadresse`, tab
	
	, delivery_party(s)

	, trace([ `delivery party`, delivery_party ]) 

	
]).


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  

	  delivery_header_line

	, delivery_dept_line

 	, delivery_city_line

]).


 	
%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	
	`Lieferadresse`, tab

	, trace([ `delivery header found` ])
	

]).


%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	delivery_dept(s1)

	, trace([ `delivery dept`, delivery_dept ]) 

	
]).

%=======================================================================
i_line_rule( delivery_city_line, [ 
%=======================================================================

	q10([anyword(w), `-`])

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ]) 

	, or([ [delivery_city(w), `,`], [delivery_city(s), `,` ] ])

	, trace([ `delivery city`, delivery_city ]) 

	, delivery_street(s)

	, trace([ `delivery street`, delivery_street ]) 

	
]).	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date_1, [ 
%=======================================================================

	q0n(anything)

	, `Bestelldatum`, q10( tab ), `:`

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date] )

]).

%=======================================================================
i_line_rule( get_order_date_2, [ 
%=======================================================================

	without( invoice_date )
	
	, q0n(anything)

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	, `Bestell`, `-`, `Nr`, `.`, tab, `:`

	, order_number(s)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	, `purchasing`, tab, `:`	

	, q0n(anything), buyer_contact(w)

	, append(buyer_contact(w), ` `, ``), tab

	, num(d), newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	`Summe`, `Beleg`, `Netto`, tab

	, read_ahead(total_net(d))

	, total_invoice(d)

	, trace( [ `total net`, total_net ] )

	, trace( [ `total invoice`, total_invoice ] )

	, newline


] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_lines, [
%=======================================================================

	 q0n(line)

	, line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	
   	`Bezeichnung`, newline


] ).


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================


	`Summe`, `Beleg`, `Netto`, tab

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	get_line_invoice_line

	, get_descr_line

	, or([ [q(0, 20, line), get_item_code_line], line_item(`MISSING`) ])

] ).

%=======================================================================
i_line_rule_cut( get_line_invoice_line, [
%=======================================================================

	line_order_line_number(d), tab

	, line_item_for_buyer(w), tab

	, trace([`line item for buyer`, line_item_for_buyer ])

	, line_quantity(d)

	, trace([`line quantity`, line_quantity])

	, or([ [`st`, line_quantity_uom_code(`EA`)]

	, [`mrt`, line_quantity_uom_code(`M`)] ]), tab

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, lua(d), tab

	, trace([`lua`, lua ])

	, pe(d), tab

	, trace([`pe`, pe ])

 	, check( i_user_check( gen_str_divide, lua, pe, LINE_UA ) )

	, line_unit_amount(LINE_UA) 

	, trace([`line unita amount`, line_unit_amount ])

	, line_net_amount_x(d)

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace( [ `original order date set to`, line_original_order_date ] )

	, newline


] ).

%=======================================================================
i_line_rule_cut( get_descr_line, [
%=======================================================================

	line_descr(s)

	, q10( [ tab, `rabatt`, `-`, line_percent_discount(d), `%`, newline ])

	, trace([`line discount`, line_percent_discount])

	, trace([`line descr`, line_descr])


] ).

%=======================================================================
i_line_rule_cut( get_item_code_line, [
%=======================================================================

	or([ [ `Ihre`, `Artikelnummer`, q10(`:`), q10(tab) ], [`art`, q10(`.`), `nr`, q10(`.`) ], [`material`, `nr`, q10(`:`)] ])

	, q10( or([ 

	  [ test(test_flag), read_ahead([ or([ `277289`, `00277289`, `268476`, `00268476` ]), suppliers_code_for_buyer( `11205957` ) ])  ]    %TEST

	    , [ read_ahead([ or([ `277289`, `00277289`, `268476`, `00268476` ]), suppliers_code_for_buyer( `10115666` ) ])  ]                      %PROD

	]) )

	
%	, q10( read_ahead([ or([ `277289`, `00277289`, `268476`, `00268476` ]), suppliers_code_for_buyer( `11205957` ) ])  )  % TEST
%	, q10( read_ahead([ or([ `277289`, `00277289`, `268476`, `00268476` ]), suppliers_code_for_buyer( `10115666` ) ])  )  % PROD

	, line_item(d)

 	, trace([`line item`, line_item ])


] ).
