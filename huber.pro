%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HUBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( huber, `26 June 2013` ).

i_date_format( _ ).

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
	  [ test(test_flag), suppliers_code_for_buyer( `10267671` ) ]    %TEST
	    , suppliers_code_for_buyer( `10267671` )                      %PROD
	]) ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_delivery_ddi ]

	,[q0n(line), get_delivery_fax ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
	,[q0n(line), customer_comments_line ] 

	,[q0n(line), customer_comments_line_2 ] 

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,or([ get_invoice_totals, [q0n(line), get_invoice_totals_two] ])

	, default_vat_rate(`19`)

] ).


%=======================================================================
i_line_rule( customer_comments_line_2, [
%=======================================================================
 
	peek_fails( test(project_found) )

	, `projekt`, q10(tab), q10(`:`), q10(tab)

	, append(customer_comments(w), ` projekt : `, ``)

	, set(project_found)

	, qn0( [q10(tab), append(customer_comments(w), ` `, ``) ])

	, trace([ `delivery header found ` ])

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

	, get_delivery_dept_line

	, q01(get_delivery_address_line)

	, get_delivery_street_line

	, get_delivery_postcode_city_line
	 
] ).

%=======================================================================
i_line_rule( get_delivery_header_line, [
%=======================================================================
 
	q0n(anything)

	, `lieferadresse`, newline

	, trace([ `delivery header found ` ])

] ).

%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_party(s1)

	, check(delivery_party(start) > 0 )

	, trace([ `delivery party`, delivery_party ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_dept_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_dept(s1)

	, check(delivery_dept(start) > 0 )

	, trace([ `delivery dept`, delivery_dept ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_address_line(s1)

	, check(delivery_address_line(start) > 0 )

	, trace([ `delivery address line`, delivery_address_line ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_street(s1)

	, check(delivery_street(start) > 0 )

	, trace([ `delivery street`, delivery_street ])

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_postcode_city_line, [
%=======================================================================
 
	q0n(anything)

	, delivery_postcode(d)

	, check(delivery_postcode(start) > 0 )

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s1)

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

	q0n(anything)

	, `Einkäufer`, tab, `:`

	, read_ahead([ dummy(w), `,`, buyer_contact(w) ])

	, append(buyer_contact(w), ` `, ``)

	, trace([ `buyer contact`, buyer_contact ])

	, `,`, dummy(w), newline

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	, `tel`, `:`, tab

	,`+`, num(d), buyer_ddi(`0`), `-`

	, append(buyer_ddi(d), ``, ``), `-`

	, append(buyer_ddi(d), ``, ``), `-`

	, append(buyer_ddi(d), ``, ``)

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	q0n(anything)

	, `fax`, `:`, tab

	,`+`, num(d), buyer_fax(`0`), `-`

	, append(buyer_fax(d), ``, ``), `-`

	, append(buyer_fax(d), ``, ``), `-`

	, append(buyer_fax(d), ``, ``)

	, newline

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	q0n(anything)

	, `Einkäufer`, tab, `:`

	, read_ahead([ dummy(w), `,`, delivery_contact(w) ])

	, append(delivery_contact(w), ` `, ``)

	, trace([ `delivery contact`, delivery_contact ])

	, `,`, dummy(w), newline

] ).

%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	q0n(anything)

	, `tel`, `:`, tab

	,`+`, num(d), delivery_ddi(`0`), `-`

	, append(delivery_ddi(d), ``, ``), `-`

	, append(delivery_ddi(d), ``, ``), `-`

	, append(delivery_ddi(d), ``, ``)

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_fax, [ 
%=======================================================================

	q0n(anything)

	, `fax`, `:`, tab

	,`+`, num(d), delivery_fax(`0`), `-`

	, append(delivery_fax(d), ``, ``), `-`

	, append(delivery_fax(d), ``, ``), `-`

	, append(delivery_fax(d), ``, ``)

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


	`BESTELLUNG`, `-`, `Nr`, tab

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


	`Bestelldatum`, `:`

	, invoice_date(date)

	, trace( [ `order number`, invoice_date ] ) 

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( customer_comments_line, [ 
%=======================================================================

	customer_comments_line_header

, get_customer_comments_line

]).

%=======================================================================
i_line_rule( customer_comments_line_header, [ 
%=======================================================================

	`Bestelldatum`, `:`

	, trace( [ `customer comments header found` ] )

]).

%=======================================================================
i_line_rule( get_customer_comments_line, [ 
%=======================================================================

	customer_comments(s1)

	, tab, append(customer_comments(s), ` `, ``)

	, tab, `Einkäufer`

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

	q0n(line), total_net_line

	, q0n(line), total_vat_line

	, q0n(line), total_invoice_line

] ).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================

	q0n(anything)

	,`Gesamtnetto`, tab, `EUR`, tab

	, total_net(d), newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( total_vat_line, [
%=======================================================================

	q0n(anything)

	,`USt`, tab, `19`, `,`, `0`, tab, `%`, tab

	, total_vat(d), newline

	, trace( [ `total vat`, total_vat ] )	

] ).

%=======================================================================
i_line_rule( total_invoice_line, [
%=======================================================================

	q0n(anything)

	,`Gesamtbrutto`, tab, `EUR`, tab

	, total_invoice(d), newline

	, trace( [ `total invoice`, total_invoice ] )	

] ).

%=======================================================================
i_line_rule( get_invoice_totals_two, [
%=======================================================================

	q0n(anything)

	,`Gesamtnetto`, tab, `EUR`, tab

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
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, tab, `Menge`, `Einh`, `Artikel` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Gesamtnetto`, tab, `EUR`, tab

] ).

%=======================================================================
i_rule_cut( line_invoice_line, [
%=======================================================================

	get_invoice_values_line

	, get_invoice_descr_line

	, or([ [q(0, 3, line), line_item_line], line_item(`Missing`) ])

	, q10([ q(0,2,line), line_date_line ])

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

	
	
] ).

%=======================================================================
i_line_rule_cut( line_date_line, [
%=======================================================================

	`anlieferdatum`, line_original_order_date(date), newline

] ).


%=======================================================================
i_line_rule_cut( get_invoice_values_line, [
%=======================================================================

	line_original_line_number(d), tab

	, trace([`line original line number`, line_original_line_number ])

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity ])

	, line_quantity_uom_code(w)

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, q0n(anything)

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, newline

] ).


%=======================================================================
i_line_rule_cut( get_invoice_descr_line, [
%=======================================================================

	q10([ `art`, `.`, `nr`, `:`, num(d), `/`, num(d) ])

	, line_descr(s1)

	, q10([ tab, append(line_descr(s), ` `, ``) ])

	, trace([`line descr`, line_descr ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	q0n(anything)

	, or([ [`art`, `.` `-`, `nr`, `:`, `.`]

	, [`artikel`, `-`, `nr`, `.`, `:`]

	, [`nr`, `.`, `:`]

	, [`art`, `.`, `:`] ])

	, line_item(sf)

	, q10([ `/`, dummy(w) ])

	, trace([`line item`, line_item ])

	, newline

] ).




