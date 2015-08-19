%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BRANDSTAETTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( brandstaetter, `11 November 2014` ).

i_date_format( _ ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_fixed_variables, check_for_abholung_line ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ABHOLUNG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_abholung_line, [
%=======================================================================
 
	  q0n(line), line_header_line
	  
	, q0n(line), generic_horizontal_details( [ `Abholung` ] )
	
	, delivery_note_reference( `by_rule` )
	, set( do_not_process )
	, trace( [ `ABHOLUNG RULE TRIGGERED` ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================
 
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
	  [ test(test_flag), suppliers_code_for_buyer( `11205959` ), delivery_note_number( `11205959` )  ]    %TEST
	    , [ suppliers_code_for_buyer( `10040617` ), delivery_note_number( `10040617` ) ]                      %PROD
	]) ]

%	, suppliers_code_for_buyer( `11205959` )  %TEST
	, suppliers_code_for_buyer( `10040617` )  % PROD 

%	, delivery_note_number( `11205959`)       % TEST
	, delivery_note_number( `10040617`)       % PROD

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_buyer_email ]

%	,[q0n(line), get_delivery_contact ]

%	,[q0n(line), get_delivery_ddi ]

%	,[q0n(line), get_delivery_fax ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	, total_net(`0`)

	, total_vat(`0`)

	, total_invoice(`0`)

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
	,[q0n(line), shipping_instructions_line ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

%	,[q0n(line), get_invoice_totals ]

	, total_net(`0`)

	, total_invoice(`0`)

] ):- not( grammar_set( do_not_process ) ).

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

	, q10(get_delivery_address_line)

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	 `Anlieferadresse`, `:`

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])

] ).

%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================
 
	delivery_address_line(s)

	, trace([ `delivery address line`, delivery_address_line ])

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	delivery_street(s)

	, trace([ `delivery street`, delivery_street ])

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	delivery_postcode(s)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(w)

	, trace([ `delivery city`, delivery_city ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`Techniker`, tab, `:`

	, q10([`hr`, `.`])

	, read_ahead([ dummy(w), q10([ `dw`, num(d) ]), or([ buyer_contact(w), buyer_contact(`.`) ]) ])

	, append(buyer_contact(w), ` `, ``)

	, trace([ `buyer contact`, buyer_contact ])

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
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	get_delivery_header_contact

	, line

	, get_delivery_contact_line

] ).

%=======================================================================
i_line_rule( get_delivery_header_contact, [ 
%=======================================================================

	`IncoTerms`, `2000`, `:`,  newline

	, trace([ `delivery contact header found` ])

] ).

%=======================================================================
i_line_rule( get_delivery_contact_line, [ 
%=======================================================================

	delivery_contact(s1)

	, trace([ `delivery contact`, delivery_contact ])

] ).

%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	`Tel`, `:`, `+`

	, num(d)

	, delivery_ddi(w)

	, append(delivery_ddi(w), ``, ``)

	, append(delivery_ddi(w), ``, ``)

	, trace([ `delivery ddi`, delivery_ddi ])

] ).

%=======================================================================
i_line_rule( get_delivery_fax, [ 
%=======================================================================

	`fax`,`+`

	, num(d)

	, delivery_fax(w)

	, append(delivery_fax(w), ``, ``)

	, append(delivery_fax(w), ``, ``)

	, check(delivery_fax(end) < 0 )

	, trace([ `delivery fax`, delivery_fax ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`BESTELLUNG`, `:`

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, tab, invoice_date(date)

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

	, or([ [ `märz`, append(invoice_date(`03`), ` `, ``) ]

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

	`progetto`, tab
	
	, customer_comments(s), tab

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

		, or([ get_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Anzahl`, `EHT`, tab, `Artikelbezeichnung`, tab, `Preis` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`LIEFERORT`, `:`], [`Ludwig`, `BRANDSTÄTTER`], [ `Anzahl`, `EHT` ] ])

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	or([ get_invoice_with_item_line

	, get_invoice_without_item_line ])

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)


] ).

%=======================================================================
i_rule_cut( get_invoice_with_item_line, [
%=======================================================================

	get_invoice_value_line


] ).

%=======================================================================
i_line_rule_cut( get_invoice_value_line, [
%=======================================================================

	line_no(s1), tab

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(w), tab

	, trace([`line quantity oum code`, line_quantity_uom_code ])

	, line_descr(s), q10(tab)

	, trace([`line descr`, line_descr ])

	, `nr`, `.`, `:`, line_item(w)

	, trace([`line item`, line_item ])

	, q10(tab)

	, line_unit_amount_x(d)



] ).

%=======================================================================
i_rule_cut( get_to_item, [
%=======================================================================

	qn1( 
		or( [ `art`
		
			, `.`
			
			, `:`
	
			, `nr`
		
		] )

	)
] ).

%=======================================================================
i_line_rule_cut( get_invoice_item_line, [
%=======================================================================

	get_to_item

	, set( regexp_cross_word_boundaries )
	
	, line_item( f( [ begin, q(dec,4,10), end ] ) )
	
	, clear( regexp_cross_word_boundaries )

	, trace([`line item`, line_item ])




] ).

%=======================================================================
i_rule_cut( get_invoice_without_item_line, [
%=======================================================================

	get_invoice_value_line_wi

	, or([ get_invoice_item_line, line_item(`Missing`) ])

] ).

%=======================================================================
i_line_rule_cut( get_invoice_value_line_wi, [
%=======================================================================

	line_no(s1), tab

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(w), tab

	, trace([`line quantity oum code`, line_quantity_uom_code ])

	, line_descr(s)

	, trace([`line descr`, line_descr ])

	, q10(tab)

	, line_unit_amount_x(d)



] ).
