%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - LINDEGAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( lindegas, `20 November 2013` ).

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
	    , suppliers_code_for_buyer( `10028075` )                      %PROD
	]) ]


%	, suppliers_code_for_buyer( `11205959` )   %TEST
%	, suppliers_code_for_buyer( `10028075` )    %PROD

	,[q0n(line), get_delivery_date ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

%	,[q0n(line), get_buyer_ddi ]

%	,[q0n(line), get_buyer_fax ]

%	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_delivery_contact ]

%	,[q0n(line), get_delivery_ddi ]

%	,[q0n(line), get_delivery_fax ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
	,[q0n(line), shipping_instructions_line ]

	, get_invoice_lines

	, or([ [q0n(line), get_invoice_totals ], [ total_net(`0`), total_invoice(`0`) ] ])

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

	, q10(line)

	, get_delivery_party_line

	, q10(get_delivery_address_line)

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	 `Bitte`, `liefern`, `Sie`, `an`, `:`

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	delivery_party(sf), `,`, delivery_dept(s1)

	, trace([ `delivery party`, delivery_party ])

	, trace([ `delivery dept`, delivery_dept ])

] ).

%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================
 
	delivery_address_line(s1)

	, trace([ `delivery address line`, delivery_address_line ])

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	delivery_street(s1)

	, trace([ `delivery street`, delivery_street ])

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s1)

	, trace([ `delivery city`, delivery_city ])

] ).


%=======================================================================
i_line_rule( get_delivery_date, [
%=======================================================================
 
	q0n(anything), `Liefertermin`

	, delivery_date(date)

	, trace([ `delivery date`, delivery_date ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	get_buyer_contact_header

	, get_buyer_contact_line

] ).

%=======================================================================
i_line_rule( get_buyer_contact_header, [ 
%=======================================================================

	q0n(anything)

	,`AnsprechpartnerIn`, `/`, `Telefon`,  newline

	, trace([ `buyer contact header found` ])

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	q0n(anything)

	, `hr`, `.`

	, read_ahead([ dummy(w), buyer_contact(w), `/`, dummy(w), num(d), newline ]), append(buyer_contact(w), ` `, ``), name(w)

	, `/`, dummy(w), num(d), newline

	, trace([ `buyer contact`, buyer_contact ])


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	get_delivery_header_contact

	, get_delivery_contact_line

	, get_delivery_email

	, get_delivery_ddi

] ).

%=======================================================================
i_line_rule( get_delivery_header_contact, [ 
%=======================================================================

	`Zahlungsbed`, `.`, `:`

	, trace([ `delivery contact header found` ])

] ).

%=======================================================================
i_line_rule( get_delivery_contact_line, [ 
%=======================================================================

	delivery_contact(s1)

	, trace([ `delivery contact`, delivery_contact ])

] ).

%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	delivery_email(s1)

	, trace([ `delivery email`, delivery_email ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	`+`, num(d), `/`, `(`

	, delivery_ddi(d), `)`

	, append(delivery_ddi(d), ``, ``), `/`

	, append(delivery_ddi(d), ``, ``)

	, append(delivery_ddi(d), ``, ``), `-`

	, append(delivery_ddi(d), ``, ``)

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	get_order_number_header

	, get_order_number_line 

] ).

%=======================================================================
i_line_rule( get_order_number_header, [ 
%=======================================================================

	`Bestellnummer`, `/`, `Datum`,  newline

	, trace( [ `order number header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	order_number(s), `/`

	, trace( [ `order number`, order_number ] ) 

	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date ] ) 

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

	`progetto`, tab
	
	, customer_comments(sf), tab

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
i_line_rule( get_invoice_totals, [
%=======================================================================

	`Gesamtnettowert`, `ohne`, `Mwst`, `EUR`, tab

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
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `-`, numb(d), `-`,  newline ] ).
%=======================================================================

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ lines_line
		
				, get_invoice_line
				
				, get_invoice_line_two
				
				, get_invoice_line_three
				
				, line

			] )

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Bestellmenge`, tab, `Einheit`, tab, `Preis` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `Gesamtnettowert`, `ohne`, `Mwst`, `EUR`, tab

] ).

%=======================================================================
i_line_rule_cut( lines_line, [
%=======================================================================

	`_`, `_`, `_`, `_`, `_`, `_`, `_`

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

  	  get_invoice_descr_line

	, peek_fails(line_end_line), get_invoice_values_line

	, or( [ [ q(0,3,[ peek_fails(line_end_line), line ] )
	
				, peek_fails(line_end_line), get_invoice_item_line]
				
			, line_item(`MISSING`) 
			
		] )

	%, q10([ with(invoice, delivery_date, DD), line_original_order_date(DD) ])
	
] ).

%=======================================================================
i_line_rule_cut( get_invoice_descr_line, [
%=======================================================================

	  line_order_line_number(w), tab

	, line_descr(s1)

	, trace([`line descr`, line_descr ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_values_line, [
%=======================================================================

	line_quantity(d), tab

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(s1), tab

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, unitamount(d), tab

	, q10([per(s), tab])

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_item_line, [
%=======================================================================

	`Ihre`, `Materialnummer`, `:`

	, line_item(s1)

	, trace([`line item`, line_item])

	, newline

] ).

%=======================================================================
i_rule_cut( get_invoice_line_two, [
%=======================================================================

	  get_invoice_descr_line_two

	, peek_fails(line_end_line), line

	, peek_fails(line_end_line), get_invoice_quantity_line_two

	, peek_fails(line_end_line), get_invoice_item_line_two

	, q(0, 7, [ peek_fails(line_end_line), line ] )
	
	, peek_fails(line_end_line), get_values_line_two

	%, q10([ with(invoice, delivery_date, DD), line_original_order_date(DD) ])
	
] ).

%=======================================================================
i_line_rule_cut( get_invoice_descr_line_two, [
%=======================================================================

	line_order_line_number(w), tab

	, material(s1), tab

	, line_descr(s1)

	, trace([`line descr`, line_descr ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_quantity_line_two, [
%=======================================================================

	line_quantity(d), tab

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(s1)

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_item_line_two, [
%=======================================================================

	`Ihre`, `Materialnummer`, `:`

	, line_item(s1)

	, trace([`line item`, line_item])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_values_line_two, [
%=======================================================================

	`Nettowert`, `inkl`, `.`, `Rab`, `.`, tab

	, q0n(anything)

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount])

	, newline

] ).

%=======================================================================
i_rule_cut( get_invoice_line_three, [
%=======================================================================

	  get_invoice_descr_line_three

	, peek_fails(line_end_line), get_values_line_three
	
	%, q10([ with(invoice, delivery_date, DD), line_original_order_date(DD) ])
	
] ).

%=======================================================================
i_line_rule_cut( get_invoice_descr_line_three, [
%=======================================================================

	line_order_line_number(w), tab

	, line_descr(s1)

	, trace([`line descr`, line_descr ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_values_line_three, [
%=======================================================================

	line_quantity(d), tab

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(s1), tab

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, unitamount(d), tab

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount])

	, newline

] ).

