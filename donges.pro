%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DONGES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( donges, `26 Aug 2013` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `DE-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11202554` ) ]    %TEST
	    , suppliers_code_for_buyer( `10313423` )                      %PROD
	]) ]


%	, suppliers_code_for_buyer( `11202554` )   %TEST
%	, suppliers_code_for_buyer( `10313423` )   %PROD

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
	,[q0n(line), shipping_instructions_line ]

	, get_invoice_lines

	,[q0n(line), get_invoice_totals ]

	, default_vat_rate(`19`)

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

	, get_delivery_party_line

	, q10(get_delivery_dept_line)

	, q10(get_delivery_address_line)

	, q10(get_delivery_address_line_two)

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	 or([ [`Anlieferadresse`, `:`], [`Lieferadresse`]  ])

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])

] ).

%=======================================================================
i_line_rule( get_delivery_dept_line, [
%=======================================================================
 
	`c`, `/`, `o`

	, delivery_dept(s)

	, prepend(delivery_dept(`c/o`), ``, ` `)

	, trace([ `delivery party`, delivery_dept ])

] ).

%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================
 
	delivery_address_line(s1)

	, trace([ `delivery address line`, delivery_address_line ])

] ).

%=======================================================================
i_line_rule( get_delivery_address_line_two, [
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
	
	q0n(anything)

	, read_ahead([ dummy_pc(d), dummy_city(s) ])

	, delivery_postcode(w)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])

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

	`Einkäufer`, tab 

	, buyer_contact(s1)

	, trace([ `buyer contact`, buyer_contact ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`Telefon`, tab

	, buyer_ddi(s)

	, trace([ `buyer ddi`, buyer_ddi ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	`fax`, tab

	, buyer_fax(s1)

	, trace([ `buyer fax`, buyer_fax ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	`e`, `-`, `mail`, tab

	, buyer_email(s1)

	, trace([ `buyer email`, buyer_email ])

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

	,`Bestell`, `-`, `Nr`, `.`, tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	`Belegdatum`, tab
	
	, invoice_date(w), `.`

	, or([ [ `Januar`, append( invoice_date(`01`), ` `, `` ) ]
	
	, [ `Februar`, append(invoice_date(`02`), ` `, ``) ]
	
	, [ `märz`, append(invoice_date(`03`), ` `, ``) ]

	,[ `april`, append(invoice_date(`04`), ` `, ``) ]

	,[ `mai`, append(invoice_date(`05`), ` `, ``) ]

	,[ `juni`, append(invoice_date(`06`), ` `, ``) ]

	,[ `juli`, append(invoice_date(`07`), ` `, ``) ]

	,[ `august`, append(invoice_date(`08`), ` `, ``) ]

	,[ `september`, append(invoice_date(`09`), ` `, ``) ]

	,[ `oktober`, append(invoice_date(`10`), ` `, ``) ]

	,[ `november`, append(invoice_date(`11`), ` `, ``) ]

	,[ `dezember`, append(invoice_date(`12`), ` `, ``) ] ])

	, append(invoice_date(d), ` `, ``)

	, trace( [ `invoice date`, invoice_date] )

	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	`ihre`, `referenz`, tab
	
	, customer_comments(s1)

	, prepend(customer_comments(`Referenz`), ``, ` `)

	, check(customer_comments(end) < 90 )

	, trace( [ `customer comments`, customer_comments ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	get_totals_header_line

	, get_totals_line

] ).

%=======================================================================
i_line_rule( get_totals_header_line, [
%=======================================================================

	`total`, `eur`, tab

	,trace( [ `totals header found` ] )

] ).

%=======================================================================
i_line_rule( get_totals_line, [
%=======================================================================

	total_net(d), tab

	,trace( [ `total vat`, total_vat ] )

	,total_vat(d), tab

	,trace( [ `total vat`, total_vat ] )

	,total_invoice(d), newline

	,trace( [ `total invoice`, total_invoice ] )

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

	, qn0( [ peek_fails(line_end_line)

		, or([ lines_line, get_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Ihre`, `Artikel`, `Nr`, `.`, tab, `Einheit` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`Valore`, `merce`, `netto`, tab]

	, [`Bitte`, `versenden`, `Sie`, `die`]

	, [`Bestellung`, tab, `Bestellung`, `-`, tab] ])

] ).

%=======================================================================
i_line_rule( lines_line, [
%=======================================================================

	`_`, `_`, `_`, `_`, `_`, `_`, `_`

] ).

%=======================================================================
i_rule( get_invoice_line, [
%=======================================================================

	get_invoice_values_line

	, get_invoice_second_line
	

] ).

%=======================================================================
i_line_rule( get_invoice_values_line, [
%=======================================================================

	line_no(d), tab

	, line_item_for_buyer(s), tab

	, trace([`line item for buyer`, line_item_for_buyer ])

	, line_descr(s1), tab

	, trace([`line descr`, line_descr ])

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity ])

	, unitamount(d), tab

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, or([ line_original_order_date(date), `sofort` ])

	, trace([`line original order date`, line_original_order_date ])

	, newline

] ).

%=======================================================================
i_line_rule( get_invoice_second_line, [
%=======================================================================

	line_item(s), tab

	, trace([`line item`, line_item])

	, q01([append(line_descr(s), ` `, ``), tab])

	, line_quantity_uom_code(s1), tab

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, numb(d)

	, newline


] ).



