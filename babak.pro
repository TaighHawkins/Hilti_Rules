%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BABAK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( babak, `6 March 2013` ).

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

	, suppliers_code_for_buyer( `10031904` )  %PROD
	%, suppliers_code_for_buyer( `11205957` )  %TEST

	,[q0n(line), get_customer_comments]

	,[q0n(line), get_shipping_instructions]

	,[q0n(line), get_delivery_address ]

	,[ q0n(line), get_delivery_party ]

	,[q0n(line), get_order_number ]

	,[q0n(line),  get_order_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_email ]

	,[ q0n(line), get_line_original_order_date ]

	, get_invoice_lines

	,[ q0n(line), get_invoice_totals ]


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_party, [
%=======================================================================
 
	 `Versandanschrift`, `:`

	, delivery_party(s)

	, trace([ `delivery party`, delivery_party ])
	 
] ).


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  

	 delivery_header_line

	 , q(1, 1, line)

	 , delivery_street_line

	 , delivery_postcode_and_city

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Versandanschrift`, `:`

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s)

	, trace([ `delivery street`, delivery_street ])

	, newline
	

]).

%=======================================================================
i_line_rule( delivery_postcode_and_city, [ 
%=======================================================================

	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])
	

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	`datum`, `:`, tab
	
	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date] )

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

	order_number_line

	, order_number_line_2

] ).

%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	q0n(anything)

	, `Bestellung`, tab

	, order_number(s)

	, trace( [ `order number`, order_number ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( order_number_line_2, [ 
%=======================================================================

	q0n(anything)

	, `order`, `-`, `nr`, `:`, tab

	, append(order_number(s), `/`, ``)

	, trace( [ `order number`, order_number ] ) 

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

	`Sachbearbeiter`, `:`, tab

	, read_ahead([ dummy(w), buyer_contact(w) ]), append(buyer_contact(w), ` `, ``)

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	`email`, `:`, tab

	, buyer_email(s)

	, trace([ `buyer email`, buyer_email ])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	customer_comments_header_line

	, get_customer_comments_line

] ).

%=======================================================================
i_line_rule( customer_comments_header_line, [ 
%=======================================================================

	`Versandanschrift`, `:`

	, trace([ `customer comments header found` ])

] ).

%=======================================================================
i_line_rule( get_customer_comments_line, [ 
%=======================================================================

	customer_comments(s)

	, check(customer_comments(start) > -240 )

	, check(customer_comments(end) < 150 )

	, trace([ `customer comments`, customer_comments ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	shipping_instructions_header_line

	, get_shipping_instructions_line

] ).

%=======================================================================
i_line_rule( shipping_instructions_header_line, [ 
%=======================================================================

	`Versandanschrift`, `:`

	, trace([ `shipping instructions header found` ])

] ).

%=======================================================================
i_line_rule( get_shipping_instructions_line, [ 
%=======================================================================

	shipping_instructions(s)

	, check(shipping_instructions(start) > -240 )

	, check(shipping_instructions(end) < 150 )

	, trace([ `shipping instructions`, shipping_instructions ])

] ).

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
	`netto`, `-`, `summe`, tab

	,total_net(d), newline

	,trace( [ `total net`, total_net ] )

	
] ).

%=======================================================================
i_line_rule( total_vat_line, [
%=======================================================================

	`Mwst`, `2`, tab, `20`, `,`, `00`, `%`, tab

	,total_vat(d), newline

	,trace( [ `total vat`, total_vat ] )

] ).

%=======================================================================
i_line_rule( total_invoice_line, [
%=======================================================================

	`Gesamt`, tab, `EUR`, tab

	,total_invoice(d), newline

	,trace( [ `total invoice`, total_invoice ] )	

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

		, or([ get_invoice_line, get_invoice_line2, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Liefer`, `-`, `Termin`, tab, `Preis` ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`netto`, `-`, `summe`, tab

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	get_line_invoice_line

	, get_descr_line

] ).


%=======================================================================
i_line_rule_cut( get_line_invoice_line, [
%=======================================================================

	line_quantity(d)

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace([`line quantity`, line_quantity])

	, set( regexp_allow_partial_matching )

	, or([ [ or([`stck`, `st`, `stk` ]), q10([ q01(tab), line_item(d)]), line_quantity_uom_code(`EA`)]

	, [`mtr`, line_item(d), line_quantity_uom_code(`M`)]

	, [`m`, q01(tab), line_item(d), line_quantity_uom_code(`M`) ]

 	])

	, trace([`line quantity uom code`, line_quanity_uom_code ])

	, clear( regexp_allow_partial_matching )

	, trace([`line item`, line_item ])

	, tab, line_descr(s), tab

	, trace([`line descr`, line_descr ])

	, q0n(anything)

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, newline


] ).

%=======================================================================
i_line_rule_cut( get_descr_line, [
%=======================================================================

	peek_fails(`_`)

	, append(line_descr(s), ` `, ``), newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_line2, [
%=======================================================================

	line_quantity(d)

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace([`line quantity`, line_quantity])

	, set( regexp_allow_partial_matching )

	, or([ [or([`stck`, `st`, `stk`]), q10([ q01(tab), line_item(d) ]), line_quantity_uom_code(`EA`)]

	, [`mtr`, line_item(d), line_quantity_uom_code(`M`)] 

	, [`m`, q01(tab), line_item(d), line_quantity_uom_code(`M`) ]

	])

	, trace([`line quantity uom code`, line_quanity_uom_code ])

	, clear( regexp_allow_partial_matching )

	, trace([`line item`, line_item ])

	, tab, line_descr(s), tab

	, trace([`line descr`, line_descr ])

	, q0n(anything)

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, newline


] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LINE ORIGINAL ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_line_original_order_date, [ 
%=======================================================================

	`Liefertermin`, `:`, tab

	, due_date(date)

	, trace( [ `original order date`, original_order_date ] ) 

] ).


