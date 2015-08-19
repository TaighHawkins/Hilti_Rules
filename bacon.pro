%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BACON TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( bacon_test, `8 May 2013` ).

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

     ,[or([ [ test(test_flag), suppliers_code_for_buyer( `11205957` ) ]    %TEST
            , suppliers_code_for_buyer( `10041259` )                       %PROD
       ]) ]

	,[q0n(line), get_customer_comments]

%	,[q0n(line), get_shipping_instructions]

%	,[q0n(line), get_delivery_address ]

%	,[ q0n(line), get_delivery_party ]

	,[q0n(line), get_order_number, q0n(line), get_delivery_party, get_delivery_address  ]

	,[q0n(line),  get_order_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_email ]

	,[ q0n(line), get_line_original_order_date ]

	, get_invoice_lines

	, get_invoice_lines_two

	,[ q0n(line), get_invoice_totals ]


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( get_delivery_party, [
%=======================================================================
 
	 `Versandanschrift`, `:`, peek_fails(`abholung`)

	, delivery_party(s)

	, trace([ `delivery party`, delivery_party ])
	 
] ).


%=======================================================================
i_rule_cut( get_delivery_address, [
%=======================================================================
 
	 q01(line)

	, q01(delivery_dept_line)

	, q01(delivery_address_line_line)

	 , delivery_street_line

	 , delivery_postcode_and_city

	, q10( get_shipping_instructions )

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Versandanschrift`, `:`

	, trace([ `delivery header found` ])
	

]).


%=======================================================================
i_line_rule_cut( delivery_dept_line, [ 
%=======================================================================

	delivery_dept(s)

	, check(delivery_dept(start) > -300), check(delivery_dept(start) < -100)

	, trace([ `delivery dept`, delivery_dept ])

	, newline
	

]).


%=======================================================================
i_line_rule_cut( delivery_address_line_line, [ 
%=======================================================================

	delivery_address_line(s)

	, check(delivery_address_line(start) > -300), check(delivery_address_line(start) < -100)

	, trace([ `delivery address line`, delivery_address_line])

	, newline
	

]).


%=======================================================================
i_line_rule_cut( delivery_street_line, [ 
%=======================================================================

	delivery_street(s)

	, check(delivery_street(start) > -300), check(delivery_street(start) < -100)

	, trace([ `delivery street`, delivery_street ])

	, newline
	

]).

%=======================================================================
i_line_rule_cut( delivery_postcode_and_city, [ 
%=======================================================================

	q01([ word,`-` ]), delivery_postcode(d)

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
i_rule_cut( get_order_number, [ 
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

	or([ [`Sachbearbeiter`, `:`, tab], [`SachbearbeiterF`, `:`] ])

	, read_ahead([ dummy(w), buyer_contact(w) ]), append(buyer_contact(w), ` `, ``), name(w)

	, trace([ `buyer contact`, buyer_contact ])

	, `dw`, `:`

	, buyer_ddi(w), or([ `/`, `-` ])

	, append(buyer_ddi(w), ``, ``), or([ `-`, `/` ])

	, append(buyer_ddi(w), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

	, newline

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

	 get_customer_comments_line

] ).


%=======================================================================
i_line_rule( get_customer_comments_line, [ 
%=======================================================================

	`baustelle`, `:`,  tab, customer_comments(s)

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


	 shipping_instructions_line

	, bitte_line


] ).

%=======================================================================
i_line_rule( bitte_line, [ 
%=======================================================================

	`bitte`, `Auftragsbestätigung`

	, trace([ `bitte line found` ])

] ).

%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

	shipping_instructions(s)

	, check(shipping_instructions(y) > -60 )

	, check(shipping_instructions(y) < -40 )

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
i_section_end( get_invoice_lines, line_end_line ).
%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line, get_invoice_line2, get_invoice_line_without_values, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Liefer`, `-`, `Termin`, tab, `Preis` ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	or([ [`netto`, `-`, `summe`, tab] 

 	, [ `Bestellung`, tab] ])


] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	get_line_invoice_line

	%, q10(get_line_original_order_date)

] ).


%=======================================================================
i_line_rule_cut( get_line_invoice_line, [
%=======================================================================

	line_quantity(d)

	, q10([ with( invoice, due_date, DATE )

	, line_original_order_date( DATE ) ])

	, trace([`line quantity`, line_quantity])

	, set( regexp_allow_partial_matching )

	, or([ [ or([`stck`, `stk` , `st` ]), q10([ q01(tab), line_item(w)]), line_quantity_uom_code(`EA`)]

	, [`mtr`, line_item(d), line_quantity_uom_code(`M`)]

	, [`m`, q01(tab), line_item(d), line_quantity_uom_code(`M`) ]

 	])

	, trace([`line quantity uom code`, line_quanity_uom_code ])

	, clear( regexp_allow_partial_matching )

	, trace([`line item`, line_item ])

	, q10(tab), line_descr(s), tab

	, trace([`line descr`, line_descr ])

	, q0n(anything)

	, line_net_amount(d)

	, check(line_net_amount(start) > 370 )

	, trace([`line net amount`, line_net_amount ])

	, newline


] ).


%=======================================================================
i_line_rule_cut( get_invoice_line2, [
%=======================================================================

	line_quantity(d)

	, q10([ with( invoice, due_date, DATE )

	, line_original_order_date( DATE ) ])

	, trace([`line quantity`, line_quantity])

	, set( regexp_allow_partial_matching )

	, or([ [or([`stck`, `stk`, `st`]), q10([ q01(tab), line_item(w) ]), line_quantity_uom_code(`EA`)]

	, [`mtr`, line_item(d), line_quantity_uom_code(`M`)] 

	, [`m`, q01(tab), line_item(d), line_quantity_uom_code(`M`) ]

	])

	, trace([`line quantity uom code`, line_quanity_uom_code ])

	, clear( regexp_allow_partial_matching )

	, trace([`line item`, line_item ])

	, q10(tab), line_descr(s), tab

	, trace([`line descr`, line_descr ])

	, q0n(anything)

	, line_net_amount(d)

	, check(line_net_amount(start) > 370 )

	, trace([`line net amount`, line_net_amount ])

	, newline


] ).

%=======================================================================
i_rule_cut( get_invoice_line_without_values, [
%=======================================================================

	invoice_without_vaules_quantity_line

	, invoice_without_vaules_descr_line

] ).

%=======================================================================
i_line_rule_cut( invoice_without_vaules_quantity_line, [
%=======================================================================

	without(line_net_amount)

	, line_quantity(d)

	, q10([ with( invoice, due_date, DATE )

	, line_original_order_date( DATE ) ])

	, trace([`line quantity`, line_quantity])

	, line_quantity_uom_code(w), tab

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, line_item, tab

	, line_descr(s1)

	, trace([`line descr`, line_descr ])

	, newline


] ).

%=======================================================================
i_line_rule_cut( invoice_without_vaules_descr_line, [
%=======================================================================

	append(line_descr(s), ` `, ``)

	, trace([`line descr`, line_descr ])

	, newline


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES TWO	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_end( get_invoice_lines_two, line_end_line_two ).
%=======================================================================
i_section_control( get_invoice_lines_two, first_one_only ).
%=======================================================================
%=======================================================================
i_section( get_invoice_lines_two, [
%=======================================================================

	 line_header_line_two

	, qn0( [ peek_fails(line_end_line_two)

		, or([ get_invoice_line_two, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line_two, [ `Liefertermin`, tab, `Preis`, tab ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line_two, [
%=======================================================================
	
	or([ [`netto`, `-`, `summe`, tab] 

 	, [ `Bestellung`, tab] ])


] ).

%=======================================================================
i_rule_cut( get_invoice_line_two, [
%=======================================================================

	get_line_invoice_line_two

	%, q10(get_line_original_order_date)

] ).


%=======================================================================
i_line_rule_cut( get_line_invoice_line_two, [
%=======================================================================

	q10([ line_no(d), tab])

	, line_quantity(d)

	, q10([ with( invoice, due_date, DATE )

	, line_original_order_date( DATE ) ])

	, trace([`line quantity`, line_quantity])

	, set( regexp_allow_partial_matching )

	, or([ [ or([`stck`, `stk` , `st` ]), q10([ q01(tab), line_item(w)]), line_quantity_uom_code(`EA`)]

	, [`mtr`, line_item(d), line_quantity_uom_code(`M`)]

	, [or([ `m1`, `m` ]), q01(tab), line_item(d), line_quantity_uom_code(`M`) ]

 	])

	, trace([`line quantity uom code`, line_quanity_uom_code ])

	, clear( regexp_allow_partial_matching )

	, trace([`line item`, line_item ])

	, q10(tab), line_descr(s), tab

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

	, trace( [ `line original order date`, line_original_order_date ] ) 

] ).


