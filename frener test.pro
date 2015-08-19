%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FRENER & REIFER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( frener_and_refier, `5 May 2013` ).

i_date_format( _ ).

i_default(continuation_page).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ii_page_split_rule_list( [new_invoice_page_section ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_section( new_invoice_page_section, [ new_invoice_page_line ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_line_rule( new_invoice_page_line, [

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 	`Indirizzo`, `di`, `fatturazione`, `:`

     , new_invoice_page

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, default_vat_rate(`21`)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `10658906` )   %TEST
%	, suppliers_code_for_buyer( `13003878` )   %PROD

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_delivery_ddi ]

	,[q0n(line), get_delivery_fax ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

%	, shipping_instructions( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
	,[q0n(line), shipping_instructions_line ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	, get_invoice_lines

	,[with(invoice, delivery_city, _), q0n(line), get_invoice_totals ]

%	, default_vat_rate(`21`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	 get_delivery_party_line

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	 `Indirizzo`, `di`, `consegna`, `:`, tab

	, delivery_party(s)

	, trace([ `delivery party`, delivery_party ])

	, newline 

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	delivery_street(s)

	, trace([ `delivery street`, delivery_street ])

	, newline 

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	delivery_postcode(d)

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
i_rule( get_buyer_contact, [ 
%=======================================================================

	get_buyer_header_contact

	, line

	, get_buyer_contact_line

] ).

%=======================================================================
i_line_rule( get_buyer_header_contact, [ 
%=======================================================================

	`IncoTerms`, `2000`, `:`,  newline

	, trace([ `buyer contact header found` ])

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	buyer_contact(s1)

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`Tel`, `:`, `+`

	, num(d)

	, buyer_ddi(w)

	, append(buyer_ddi(w), ``, ``)

	, append(buyer_ddi(w), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	`fax`,`+`

	, num(d)

	, buyer_fax(w)

	, append(buyer_fax(w), ``, ``)

	, append(buyer_fax(w), ``, ``)

	, check(buyer_fax(end) < 0 )

	, trace([ `buyer fax`, buyer_fax ])

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

	`ORDINE`, `D`, `'`, `ACQUISTO`

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

	`Data`, `:`
	
	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( customer_comments_line, [ 
%=======================================================================

	customer_comments_line1

	, q10(customer_comments_line2)

]).

%=======================================================================
i_line_rule( customer_comments_line1, [ 
%=======================================================================

	`progetto`, tab
	
	, customer_comments(s), tab

	, append(customer_comments(s), ` `, ``)

	, newline

	, trace( [ `customer comments`, customer_comments ] )

]).

%=======================================================================
i_line_rule( customer_comments_line2, [ 
%=======================================================================

	append(customer_comments(s), ` `, ``)

	, newline

	, trace( [ `customer comments`, customer_comments ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( shipping_instructions_line, [ 
%=======================================================================

	shipping_instructions_line1

	, q10(shipping_instructions_line2)

]).

%=======================================================================
i_line_rule( shipping_instructions_line1, [ 
%=======================================================================

	`progetto`, tab
	
	, shipping_instructions(s), tab

	, append(shipping_instructions(s), ` `, ``)

	, newline

	, trace( [ `shipping instructions `, shipping_instructions ] )

]).

%=======================================================================
i_line_rule( shipping_instructions_line2, [ 
%=======================================================================

	append(shipping_instructions(s), ` `, ``)

	, newline

	, trace( [ `shipping instructions `, shipping_instructions ] )

]).

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

	`Valore`, `merce`, `netto`, tab

	,total_net(d), newline

	,trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( total_vat_line, [
%=======================================================================

	`+`, `21`, `,`, `000`, `%`, tab, `IVA`, tab

	,total_vat(d), newline

	,trace( [ `total vat`, total_vat ] )

] ).

%=======================================================================
i_line_rule( total_invoice_line, [
%=======================================================================

	`Somma`, `totale`, `in`, `EUR`, tab

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

qn0([

	peek_fails(line_end_line)

	, get_line_header_line

	, qn0( [ peek_fails(line_end_line), or([ get_invoice_line, line ]) ] )

  ]) 

] ).

%=======================================================================
i_rule_cut( get_line_header_line, [ q0n(line), peek_fails(line_end_line), line_header_line ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_header_line, [ `Definizione`,  newline ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Valore`, `merce`, `netto`, tab

] ).

%=======================================================================
i_rule( get_invoice_line, [
%=======================================================================

	get_invoice_values_line

	, get_invoice_descr_line

	, q10(get_append_descr_line)
	

] ).

%=======================================================================
i_line_rule( get_invoice_values_line, [
%=======================================================================

	line_no(d), tab

	, line_quantity(d), line_quantity_uom_code(w)

	, trace([`line quantity`, line_quantity, line_quantity_uom_code])

%	, or([ [ `cf` , line_quantity_uom_code(`PAK`) ]

%		, [ `pz`, line_quantity_uom_code(`EA`) ]

%		, [ `	mt`, line_quantity_uom_code(`M`) ]

%	])

	, tab

	, line_item_for_buyer(s), tab

	, trace([`customer line item`, line_item_for_buyer])

	, q10( [ line_item( f( [ q(alpha("T"),0,1), q(alpha("H"),0,1),begin, q(dec,4, 10), end ]) ), tab

	, trace([`line item`, line_item]) ])

	, line_original_order_date(date)

	, trace([`line original order date`, line_original_order_date ])

	, q0n(anything)

	, or([ [tab, line_net_amount(d)], line_net_amount(`0`) ])

	, trace([`line net amount`, line_net_amount])

	, newline

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_line_rule( get_invoice_descr_line, [
%=======================================================================

	line_descr(s)

	, trace([`line descr`, line_descr])

	, newline


] ).

%=======================================================================
i_line_rule( get_append_descr_line, [
%=======================================================================

	append(line_descr(s), ` `, ``)

	, trace([`line descr`, line_descr])

	, newline


] ).



